/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#include <allegro.h>
#include <stdarg.h>
#include "rpg.h"
#include "shared/engine.h"
#include "shared/object.h"
#include "shared/console.h"
#include "shared/tiled_map.h"
#include "sound.h"
#include "script.h"
#include "canvas.h"
#include "common.h"
#include <set>
#include <vector>

using std::set;
using std::vector;


lua_State* L = NULL;
set<const char*, ltstr> loadedScripts;
vector<char*> objectTypes;


char lua_include[] =
"function inherit(to, from)					\n"
"	for index, value in pairs(from) do		\n"
"		to[index] = value					\n"
"	end										\n"
"end										\n"

"DM_INVISIBLE = 0					\n"
"DM_ADD = 1							\n"
"DM_MASKED = 2						\n"
"DM_ALPHA = 3						\n"
"DM_TRANS = 4						\n"
"DM_MULTIPLY = 5					\n"

"DIR_UP = 0							\n"
"DIR_LEFT = 1						\n"
"DIR_RIGHT = 2						\n"
"DIR_DOWN = 3						\n"
"DIR_NONE = -1						\n"
;

int load_level;


//===================   The engine to script interface   ============================/

void import(const char *name)
{
	char *spaces = (char*)malloc((load_level + 1) * sizeof(char));
	int i;
	for (i = 0; i < load_level; i++) spaces[i] = ' ';
	spaces[load_level] = '\0';

	DATAFILE *found_object = find_datafile_object(bitmap_data, name);

	if (found_object && found_object->type == DAT_LUA) {
		const char* datname = get_datafile_property(found_object, DAT_NAME);

		if (loadedScripts.find(datname) == loadedScripts.end()) {
			loadedScripts.insert(datname);

			console.log(CON_LOG, CON_ALWAYS, "%s> \"%s\"", spaces, name);
			//handleLuaError(luaL_loadbuffer(L, (char*)found_object->dat, found_object->size, name), name);
			if (luaL_loadbuffer(L, (char*)found_object->dat, found_object->size, name)) {
				lua_error(L);
			}
			load_level++;
			lua_call(L, 0, 0);  /* call main */
			load_level--;
		}
	}
	else {
		console.log(CON_LOG, CON_ALWAYS, "%sX \"%s\" not found!", spaces, name);
	}

	free(spaces);
}

int l_import(lua_State *L)
{
	import(luaL_checkstring(L, 1));
	return 0;
}

void initScripting()
{
	// Create Lua state
	L = lua_open();

	// Enable these Lua libraries to the script
	luaopen_base(L);
	luaopen_string(L);
	luaopen_math(L);
	luaopen_table(L);

	// Add the Object type to Lua
	//Lunar<Object>::Register(L);

	// Enable object oriented stuff
	//lua_tobjlibopen(L);

	// Create meta table for objects
	lua_newtable(L);
	lua_pushstring(L, "__index");
	lua_pushcfunction(L, object_gettable);
	lua_rawset(L,-3);
	lua_pushstring(L, "__newindex");
	lua_pushcfunction(L, object_settable);
	lua_rawset(L,-3);
	lua_setglobal(L, "ObjectMetatable");

	// Set error handler
	lua_atpanic(L, l_alert);

	// Register global functions
	lua_register(L, "m_message",        l_console_message);

	lua_register(L, "m_import_tile_bmp", l_import_tile_bmp);
	lua_register(L, "m_get_bitmap",     l_get_bitmap);
	lua_register(L, "m_load_map",       l_load_map);
	lua_register(L, "m_create_sub_bitmap", l_create_sub_bitmap);

	lua_register(L, "m_add_object",     l_add_object);
	lua_register(L, "m_register_class", l_register_class);
	lua_register(L, "m_register_object", l_register_object);
	lua_register(L, "m_destroy_object", l_destroy_object);
	lua_register(L, "m_get_objects_at", l_get_objects_at);
	lua_register(L, "m_get_objects_on_map", l_get_objects_on_map);

	lua_register(L, "m_set_ex_mode",    l_set_ex_mode);
	lua_register(L, "m_get_ex_mode",    l_get_ex_mode);

	lua_register(L, "m_get_cursor",     l_get_cursor);
	lua_register(L, "m_set_cursor",     l_set_cursor);
	lua_register(L, "m_text_size",      l_text_size);
	lua_register(L, "m_bitmap_size",    l_bitmap_size);
	lua_register(L, "m_screen_size",    l_screen_size);
	lua_register(L, "m_set_font",       l_set_font);
	lua_register(L, "m_draw_text",      l_draw_text);
	lua_register(L, "m_draw_bitmap",    l_draw_bitmap);
	lua_register(L, "m_set_clip",       l_set_clip);
	lua_register(L, "m_get_clip",       l_get_clip);
	lua_register(L, "m_set_color",      l_set_color);
	lua_register(L, "m_set_drawmode",   l_set_drawmode);
	lua_register(L, "m_set_alpha",      l_set_alpha);
	lua_register(L, "m_get_alpha",      l_get_alpha);
	lua_register(L, "m_draw_viewport",  l_draw_viewport);
	lua_register(L, "m_map_to_screen",  l_map_to_screen);
	lua_register(L, "m_screen_to_map",  l_dummy);
	lua_register(L, "m_get_tile_at",    l_get_tile_at);

	lua_register(L, "m_walk_obj",       l_walk_obj);
	lua_register(L, "m_walk_obj_nocol", l_walk_obj_nocol);

	lua_register(L, "m_make_noise",     l_make_noise);

	lua_register(L, "m_play_sample",    l_play_sample);
	lua_register(L, "m_play_music",     l_play_music);
#ifdef ENABLE_MUSIC
	lua_register(L, "m_stop_music",     l_stop_music);
	lua_register(L, "m_adjust_channel", l_adjust_channel);
	lua_register(L, "m_get_number_of_channels", l_get_number_of_channels);
#else
	lua_register(L, "m_stop_music",     l_dummy);
	lua_register(L, "m_adjust_channel", l_dummy);
	lua_register(L, "m_get_number_of_channels", l_dummy);
#endif

	lua_register(L, "m_quit_game",      l_quit_game);
	lua_register(L, "import",           l_import);

	lua_register(L, "m_update_input",   l_update_input);
	lua_register(L, "m_get_shift",      l_get_shift);

	handleLuaError(lua_dostring(L, lua_include), "lua_include");



	// Load all scripts
	console.log(CON_LOG, CON_ALWAYS, "Loading scripts...");

	int i;
	const char* name;

	for (i = 0; bitmap_data[i].type != DAT_END; i++) {
		name = get_datafile_property(bitmap_data+i, DAT_NAME);
		if (bitmap_data[i].type == DAT_LUA) {
			load_level = 0;
			import(name);
		}
	}
}

void exitScripting()
{
	lua_close(L);
}


int pushLuaValues(const char* desc, va_list vals)
{
	int valc = 0;

	if (desc)
	{
		while (*desc != '\0')
		{
			switch (*desc) {
			case 'i': lua_pushnumber       (L,  va_arg(vals, int   ));             break; // Integer
			case 'd': lua_pushnumber       (L,  va_arg(vals, double));             break; // Double
			case 's': lua_pushstring       (L,  va_arg(vals, char* ));             break; // String
			case 'b': lua_pushlightuserdata(L,  va_arg(vals, BITMAP*));            break; // Bitmap
			case 'o': lua_getref           (L, (va_arg(vals, Object*))->tableRef); break; // Object
			case 'm': lua_pushlightuserdata(L,  va_arg(vals, TiledMap*));          break; // TiledMap
			default: valc--;
			}

			valc++;
			desc++;
		}

		va_end(vals);
	}

	return valc;
}


int callMemberFunction(int tableRef, const char *function, const char* args, ...)
{
	ASSERT(function);
	int ret = 0;

	lua_getref(L, tableRef);

	if (lua_istable(L, -1))
	{
		lua_pushstring(L, function);
		lua_gettable(L, -2);
		lua_remove(L, -2);

		if (lua_isfunction(L, -1))
		{
			lua_getref(L, tableRef);
			int argc = 0;

			if (args) {
				va_list ap;
				va_start(ap, args);
				argc = pushLuaValues(args, ap);
				va_end(ap);
			}

			//console.log(CON_CONSOLE | CON_LOG, CON_VDEBUG, "Lua: calling function %s with %d arguments.", function, argc);
			lua_call(L, argc + 1, 1);

			if (lua_isnumber(L, -1)) ret = int(lua_tonumber(L, -1));
			lua_pop(L, 1);
		}
		else {
			lua_pop(L, 1);
		}
	}
	else {
		console.log(CON_CONSOLE | CON_LOG, CON_VDEBUG, "Error: member function called on something that is not a table.");
	}

	return ret;
}

int callFunction(const char *function, const char* args, ...)
{
	ASSERT(function);
	int ret = 0;

	lua_getglobal(L, function);

	if (lua_isfunction(L, -1))
	{
		int argc = 0;

		if (args) {
			va_list ap;
			va_start(ap, args);
			argc = pushLuaValues(args, ap);
			va_end(ap);
		}

		//console.log(CON_CONSOLE | CON_LOG, CON_VDEBUG, "Lua: calling function %s with %d arguments.", function, argc);
		//handleLuaError(lua_call(L, argc, 1), function);
		lua_call(L, argc, 1);

		if (lua_isnumber(L, -1)) ret = int(lua_tonumber(L, -1));
		lua_pop(L, 1);	// Pop return value
	}
	else {
		console.log(CON_CONSOLE | CON_LOG, CON_VDEBUG, "Warning: called function undefined (%s).", function);
		lua_pop(L, 1);	// Pop function
	}

	return ret;
}

void handleLuaError(int err, const char *string)
{
	switch (err) {
	case LUA_ERRRUN:    console.log(CON_QUIT, CON_ALWAYS, "Lua error: Error while running script (\"%s\")", string); break;
	case LUA_ERRSYNTAX: console.log(CON_QUIT, CON_ALWAYS, "Lua error: Syntax error while precompiling script (\"%s\")", string); break;
	case LUA_ERRMEM:    console.log(CON_QUIT, CON_ALWAYS, "Lua error: Out of memory in script (\"%s\")", string); break;
	case LUA_ERRERR:    console.log(CON_QUIT, CON_ALWAYS, "Lua error: Error while running _ERRORMESSAGE in script (\"%s\")", string); break;
	case LUA_ERRFILE:   console.log(CON_QUIT, CON_ALWAYS, "Lua error: Error while opening script file (\"%s\")", string); break;
	}
}


int putLuaArguments(lua_State *L, const char *args, ...)
{
	int argc = 0;

	if (args) {
		va_list ap;
		va_start(ap, args);
		argc = pushLuaValues(args, ap);
		va_end(ap);
	}

	return argc;
}

void getLuaArguments(lua_State *L, const char *args, ...)
{
	int n = lua_gettop(L);    // Number of arguments
	int argc = 0;

	va_list ap;
	va_start(ap, args);

	while (*args != '\0')
	{
		if (argc == n) {
			lua_pushfstring(L, "This function does not take %d parameters.", n);
			lua_error(L);
		}

		switch (*args) {
		case 'i':
			{
				int *a = va_arg(ap, int*);
				if (lua_isnumber(L, -n + argc)) *a = (int)(lua_tonumber(L, -n + argc) + 0.5);
				else luaL_typerror(L, argc+1, lua_typename(L, LUA_TNUMBER));
			}
			break;

		case 'd':
			{
				double *a = va_arg(ap, double*);
				if (lua_isnumber(L, -n + argc)) *a = lua_tonumber(L, -n + argc);
				else luaL_typerror(L, argc+1, lua_typename(L, LUA_TNUMBER));
			}
			break;

		case 's':
			{
				const char **a = va_arg(ap, const char**);
				if (lua_isstring(L, -n + argc)) *a = lua_tostring(L, -n + argc);
				else luaL_typerror(L, argc+1, lua_typename(L, LUA_TSTRING));
			}
			break;

		case 'o':
			{
				Object **a = va_arg(ap, Object**);
				if (lua_istable(L, -n + argc)) {
					lua_pushstring(L, "_pointer");
					lua_gettable(L, -n + argc - 1);
					*a = (Object*)lua_touserdata(L, -1);
					lua_pop(L, 1);
				} else luaL_typerror(L, argc+1, lua_typename(L, LUA_TTABLE));
			}
			break;

		case 't':
			{
				int *a = va_arg(ap, int*);
				if (lua_istable(L, -n + argc)) {
					lua_pushvalue(L, -n + argc);
					*a = lua_ref(L, -1);
				} else luaL_typerror(L, argc+1, lua_typename(L, LUA_TTABLE));
			}
			break;

		case 'b':
			{
				BITMAP **a = va_arg(ap, BITMAP**);
				if (lua_islightuserdata(L, -n + argc)) *a = (BITMAP*)lua_touserdata(L, -n + argc);
				else luaL_typerror(L, argc+1, lua_typename(L, LUA_TLIGHTUSERDATA));
			}
			break;

		case 'm':
			{
				TiledMap **a = va_arg(ap, TiledMap**);
				if (lua_islightuserdata(L, -n + argc)) *a = (TiledMap*)lua_touserdata(L, -n + argc);
				else luaL_typerror(L, argc+1, lua_typename(L, LUA_TLIGHTUSERDATA));
			}
			break;

		default:
			argc--;
		}

		argc++;
		args++;
	}

	if (argc != n) {
		lua_pushfstring(L, "This function does not take %d parameters.", n);
		lua_error(L);
	}

	lua_settop(L, 0);

	va_end(ap);
}


//===================   The script to engine interface   ============================/

int l_alert(lua_State *L)
{
	lua_Debug ar;
	char error[1024] = "";
	char error_line[256] = "";
	int level = 0;

	strcat(error, lua_tostring(L, -1));
	strcat(error, "\n\nStack traceback:\n");

	while (lua_getstack(L, level, &ar) != 0)
	{
		lua_getinfo(L, "nSl", &ar);
		sprintf(
			error_line,
			" %d: function `%s' at line %d %s\n",
			level, /*ar.namewhat, ar.what, */ar.name, ar.currentline, ar.short_src
		);
		strcat(error, error_line);
		level++;
	}

	console.log(CON_QUIT, CON_ALWAYS, "An error occured in a Lua script:\n %s", error);
	return 0;
}

int l_dummy(lua_State *L)
{
    lua_settop(L, 0);
    return 0;
}

int l_console_message(lua_State *L)
{
	const char *message;
	getLuaArguments(L, "s", &message);
	console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "%s", message);
	return 0;
}


int l_add_object(lua_State *L)
{
	int x, y;
	const char* type;
	TiledMap* map;

	getLuaArguments(L, "iism", &x, &y, &type, &map);

	return putLuaArguments(L, "o", map->addObject(x, y, type));
}

int l_register_class(lua_State *L)
{
	char* typeName;
	int placeable;
	getLuaArguments(L, "si", &typeName, &placeable);
	console.log(CON_LOG, CON_DEBUG, "- %s class defined", typeName);
	objectTypes.push_back(typeName);
	return 0;
}

int l_register_object(lua_State *L)
{
	int ref;
	TiledMap *map;

	getLuaArguments(L, "tm", &ref, &map);
	
	map->registerObject(ref);
	// The object may not be garbage collected while in use by the engine
	//lua_unref(L, ref);
	lua_settop(L, 0);
	lua_getref(L, ref);
	return 1;
}

int l_destroy_object(lua_State *L)
{
	Object *obj;
	getLuaArguments(L, "o", &obj);
	if (obj) obj->_destroy = true;
	lua_settop(L, 0);
	return 0;
}

int l_get_objects_at(lua_State *L)
{
	double x = luaL_checknumber(L, 1);
	double y = luaL_checknumber(L, 2);
	TiledMap* map;
	int c = 1;

	getLuaArguments(L, "ddm", &x, &y, &map);

	lua_newtable(L);

	list<Object*>::iterator i;
	for (i = map->objects.begin(); i != map->objects.end(); i++) {
		Object *obj = (*i);
		if (((obj->x  + obj->w > x && obj->x  <= x) &&
			 (obj->y  - obj->h < y && obj->y  >= y)) ||
			((obj->nx + obj->w > x && obj->nx <= x) && obj->walking > 0 &&
			 (obj->ny - obj->h < y && obj->ny >= y)))
		{
			lua_getref(L, obj->tableRef);
			lua_rawseti(L, -2, c);
			c++;
		}
	}

	return 1;
}

int l_get_objects_on_map(lua_State *L)
{
	TiledMap* map;
	int c = 1;

	getLuaArguments(L, "m", &map);

	lua_newtable(L);

	list<Object*>::iterator i;
	for (i = map->objects.begin(); i != map->objects.end(); i++) {
		Object *obj = (*i);
		lua_getref(L, obj->tableRef);
		lua_rawseti(L, -2, c);
		c++;
	}

	return 1;
}


int l_set_ex_mode(lua_State *L)
{
	int mode, prev_mode;
	getLuaArguments(L, "i", &mode);
	prev_mode = exclusive_mode;
	exclusive_mode = (mode == 1) ? true : false;
	return putLuaArguments(L, "i", prev_mode);
}

int l_get_ex_mode(lua_State *L)
{
	lua_settop(L, 0);
	return putLuaArguments(L, "i", (exclusive_mode) ? 1 : 0);
}


int l_import_tile_bmp(lua_State *L)
{
	const char *filename;
	int tile_w, tile_h, tile_spacing;
	getLuaArguments(L, "siii", &filename, &tile_w, &tile_h, &tile_spacing);

	console.log(CON_CONSOLE, CON_DEBUG, "Importing tile bitmap \"%s\"...", filename);

	BITMAP* tileBitmap;
	char tempFilename[256];
	DATAFILE *found_object = find_datafile_object(bitmap_data, filename);

	if (found_object) {
		tileBitmap = (BITMAP*)found_object->dat;
		if (tileBitmap) {
			replace_extension(tempFilename, get_filename(filename), "", 256);
			tileRepository->importBitmap(tileBitmap, tempFilename, tile_w, tile_h, tile_spacing);
		} else {
			console.log(CON_QUIT, CON_ALWAYS, "Error: failed loading tile bitmap: \"%s\"", filename);
		}
	} else {
		console.log(CON_QUIT, CON_ALWAYS, "Error: file for tile bitmap not found: \"%s\"", filename);
	}

	return 0;
}



int l_get_cursor(lua_State *L)
{
	int x, y;
	canvas.getCursor(&x, &y);
	lua_settop(L, 0);
	return putLuaArguments(L, "ii", x, y);
}

int l_set_cursor(lua_State *L)
{
	int x, y;
	getLuaArguments(L, "ii", &x, &y);
	canvas.setCursor(x, y);
	return 0;
}

int l_text_size(lua_State *L)
{
	const char *text;
	int w, h;
	getLuaArguments(L, "s", &text);
	canvas.textSize(text, &w, &h);
	return putLuaArguments(L, "ii", w, h);
}

int l_bitmap_size(lua_State *L)
{
	BITMAP *bmp;
	int w = 0, h = 0;
	getLuaArguments(L, "b", &bmp);
	if (bmp) {
		w = bmp->w;
		h = bmp->h;
	}
	return putLuaArguments(L, "ii", w, h);
}

int l_screen_size(lua_State *L)
{
	lua_settop(L, 0);
	return putLuaArguments(L, "ii", buffer->w, buffer->h);
}

int l_set_font(lua_State *L)
{
	const char *font_name;
	FONT* found_font = NULL;
	getLuaArguments(L, "s", &font_name);

	DATAFILE *found_object = find_datafile_object(bitmap_data, font_name);

	if (found_object) {
		found_font = (FONT*)found_object->dat;
		canvas.setFont(found_font);
	} else {
		lua_pushstring(L, "Error: Cannot find requested font!");
		lua_error(L);
	}

	lua_settop(L, 0);
	return 0;
}

int l_draw_text(lua_State *L)
{
	const char *text;
	getLuaArguments(L, "s", &text);
	canvas.drawText(text);
	return 0;
}

int l_draw_bitmap(lua_State *L)
{
	BITMAP *bmp;
	int dw, dh, sx, sy, sw, sh;
	getLuaArguments(L, "biiiiii", &bmp, &dw, &dh, &sx, &sy, &sw, &sh);
	canvas.drawBitmap(bmp, dw, dh, sx, sy, sw, sh);
	return 0;
}

int l_set_clip(lua_State *L)
{
	int x1, y1, x2, y2;
	getLuaArguments(L, "iiii", &x1, &y1, &x2, &y2);
	canvas.setClip(x1, y1, x2, y2);
	return 0;
}

int l_get_clip(lua_State *L)
{
	int x1, y1, x2, y2;
	canvas.getClip(&x1, &y1, &x2, &y2);
	lua_settop(L, 0);
	return putLuaArguments(L, "iiii", x1, y1, x2, y2);
}

int l_set_color(lua_State *L)
{
	int r, g, b;
	getLuaArguments(L, "iii", &r, &g, &b);
	canvas.setColor(makecol(
		MIN(255, MAX(0, r)),
		MIN(255, MAX(0, g)),
		MIN(255, MAX(0, b))
	));
	lua_settop(L, 0);
	return 0;
}

int l_set_drawmode(lua_State *L)
{
	int drawMode;
	getLuaArguments(L, "i", &drawMode);
	canvas.setDrawMode(drawMode);
	lua_settop(L, 0);
	return 0;
}

int l_set_alpha(lua_State *L)
{
	int alpha;
	int prev_alpha = canvas.getAlpha();
	getLuaArguments(L, "i", &alpha);
	canvas.setAlpha(alpha);
	if (alpha < 255 && canvas.getDrawMode() == DM_MASKED)
		canvas.setDrawMode(DM_TRANS);
	else if (alpha == 255 && canvas.getDrawMode() == DM_TRANS)
		canvas.setDrawMode(DM_MASKED);
	lua_settop(L, 0);
	return putLuaArguments(L, "i", prev_alpha);
}

int l_get_alpha(lua_State *L)
{
	return putLuaArguments(L, "i", canvas.getAlpha());
}

int l_walk_obj(lua_State *L)
{
	Object* obj;
	int dir;
	getLuaArguments(L, "oi", &obj, &dir);
	obj->walk(dir, true);
	return 0;
}

int l_walk_obj_nocol(lua_State *L)
{
	Object* obj;
	int dir;
	getLuaArguments(L, "oi", &obj, &dir);
	obj->walk(dir, false);
	return 0;
}

int l_make_noise(lua_State *L)
{
	double loudness;
	Object* nm;        // The noise maker
	list<Object*>::iterator i;

	getLuaArguments(L, "od", &nm, &loudness);

	// hearedLoudness = max(0.1, loudness / (distanceInTiles ^ 2))
	for (i = nm->getMap()->objects.begin(); i != nm->getMap()->objects.end(); i++)
	{
		Object* obj = *i;
		if (obj != nm) {
			double dist2 = (obj->x - nm->x) * (obj->x - nm->x) + (obj->y - nm->y) * (obj->y - nm->y);
			double hearLoudness = MIN(loudness, loudness / dist2);
			if (hearLoudness > 0.1) {
				callMemberFunction(obj->tableRef, "hearNoise", "do", hearLoudness, nm);
			}
		}
	}

	return 0;
}


int l_update_input(lua_State *L)
{
	if (lua_istable(L, 1))
	{
		lua_pushstring(L, "bUp");       lua_pushboolean(L, key[KEY_UP]);    lua_settable(L, -3);
		lua_pushstring(L, "bRight");    lua_pushboolean(L, key[KEY_RIGHT]); lua_settable(L, -3);
		lua_pushstring(L, "bDown");     lua_pushboolean(L, key[KEY_DOWN]);  lua_settable(L, -3);
		lua_pushstring(L, "bLeft");     lua_pushboolean(L, key[KEY_LEFT]);  lua_settable(L, -3);
		lua_pushstring(L, "bActivate"); lua_pushboolean(L, key[KEY_SPACE]); lua_settable(L, -3);
		lua_pushstring(L, "bAttack");   lua_pushboolean(L, key[KEY_LCONTROL] || key[KEY_RCONTROL] || key_shifts & KB_CTRL_FLAG); lua_settable(L, -3);
		lua_settop(L, 1);
		return 1;
	}
	lua_settop(L, 0);
	return 0;
}

int l_get_shift(lua_State *L)
{
	lua_settop(L, 0);
	lua_pushboolean(L, key[KEY_LSHIFT] | key[KEY_RSHIFT]);
	return 1;
}


int l_get_bitmap(lua_State *L)
{
	const char *name;
	BITMAP* found_bitmap = NULL;
	getLuaArguments(L, "s", &name);

	DATAFILE *found_object = find_datafile_object(bitmap_data, name);

	if (found_object) {
		found_bitmap = (BITMAP*)found_object->dat;
		return putLuaArguments(L, "b", found_bitmap);
	} else {
		return luaL_error(L, "Error: Cannot find requested bitmap (%s)!", name);
	}
}

int l_create_sub_bitmap(lua_State *L)
{
	BITMAP* parent;
	BITMAP* sub_bitmap;
	int x, y, w, h;
	getLuaArguments(L, "biiii", &parent, &x, &y, &w, &h);

	if (!parent) {
		lua_pushstring(L, "Error: No bitmap passed to function!");
		lua_error(L);
	}
	if (x < 0 || y < 0 || x >= parent->w || y >= parent->h) {
		if (debug_mode) {
			luaL_error(L, "Error: Creating subbitmap failed, invalid origin (%d, %d)", x, y);
		}
		else {
			console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Warning: Creating subbitmap failed, invalid origin (%d, %d)", x, y);
		}
		return 0;
	}

	sub_bitmap = create_sub_bitmap(parent, x, y, w, h);

	return putLuaArguments(L, "b", sub_bitmap);
}


int l_load_map(lua_State *L)
{
	const char *map_name;
	getLuaArguments(L, "s", &map_name);

	if (exists(map_name)) {
		console.log(CON_LOG, CON_ALWAYS, "Loading map \"%s\"...", map_name);
		TiledMap* map = new SquareMap(TILES_W, TILES_H);
		map->loadMap(map_name);
		maps.push_front(map);
		return putLuaArguments(L, "m", map);
	}
	else {
		if (debug_mode) {
			luaL_error(L, "Error: Attempt to load a non-existing map (%s)!", map_name);
		}
		else {
			console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Warning: Attempt to load a non-existing map (%s)!", map_name);
		}
	}

	return 0;
}


int l_draw_viewport(lua_State *L)
{
	int x, y, w, h;
	double tx, ty;
	TiledMap* map;
	getLuaArguments(L, "iiiiddm", &x, &y, &w, &h, &tx, &ty, &map);

	if (map) {
		list<Object*>::iterator i;
		// Iterate through all objects, calling the preRender function
		for (i = map->objects.begin(); i != map->objects.end(); i++) {
			callMemberFunction((*i)->tableRef, "preRender");
			(*i)->update_entity();
		}

		canvas.drawViewport(x, y, w, h, (int)(tx * TILES_W), (int)(ty * TILES_H), map);
	}
	else {
		console.log(CON_CONSOLE | CON_LOG, CON_DEBUG, "Warning: draw_viewport called without a map.");
	}

	return 0;
}

int l_map_to_screen(lua_State *L)
{
	int px, py, pz;
	int x, y, w, h;
	double tx, ty;
	TiledMap* map;
	getLuaArguments(L, "iiiiiiiddm", &px, &py, &pz, &x, &y, &w, &h, &tx, &ty, &map);

	if (map) {
		map->setCamera(
			Point(int(tx * TILES_W), int(ty * TILES_H)),
			Rectangle(x, y, w, h),
			true, true
		);

		Point screenCoords = map->mapToScreen(Point(px, py, px));
		return putLuaArguments(L, "ii", screenCoords.x, screenCoords.y);
	}
	else {
		console.log(CON_CONSOLE | CON_LOG, CON_DEBUG, "Warning: map_to_screen called without a map.");
	}

	return 0;
}

int l_get_tile_at(lua_State *L)
{
	TiledMap* map;
	int x, y;
	getLuaArguments(L, "mii", &map, &x, &y);

	if (map) {
		Tile* tile = map->mapLayers[0]->getTile(Point(x, y));
		if (tile) {
			char *tileTypeName = tile->getType()->getName();
			return putLuaArguments(L, "si", tileTypeName, tile->obstacle);
		} else {
			return 0;
		}
	}
	else {
		console.log(CON_CONSOLE | CON_LOG, CON_DEBUG, "Warning: get_tile_at called without a map.");
	}

	return 0;
}


int l_quit_game(lua_State *L)
{
	game_end = true;
	return 0;
}



//===================   Tag methods   ===============================================/

int object_gettable(lua_State *L)
{
	if (lua_isstring(L, -1)) 
	{
		const char *index = lua_tostring(L, -1);      // table key

		lua_pushstring(L, "_pointer");                // table key "_pointer"
		lua_rawget(L, -3);                            // table key _pointer
		Object *obj = (Object*)lua_touserdata(L, -1); // table key _pointer
		lua_pop(L, 1);                                // table key

		// Exit with error when the object pointer is NULL
		if (!obj) {
			//lua_error(L, "Script tried to get variable of non-existing (destroyed?) object.");
			console.log(CON_LOG, CON_VDEBUG, "Warning: Script tried to get variable of non-existing object.");
			lua_settop(L, 0);
			return 0;
		}

		if (strcmp(index, "speed"    ) == 0) {return putLuaArguments(L, "d", obj->speed    );}
		if (strcmp(index, "walking"  ) == 0) {return putLuaArguments(L, "d", obj->walking  );}
		if (strcmp(index, "x"        ) == 0) {return putLuaArguments(L, "d", obj->x        );}
		if (strcmp(index, "y"        ) == 0) {return putLuaArguments(L, "d", obj->y        );}
		if (strcmp(index, "w"        ) == 0) {return putLuaArguments(L, "i", obj->w        );}
		if (strcmp(index, "h"        ) == 0) {return putLuaArguments(L, "i", obj->h        );}
		if (strcmp(index, "offset_x" ) == 0) {return putLuaArguments(L, "i", obj->offset_x );}
		if (strcmp(index, "offset_y" ) == 0) {return putLuaArguments(L, "i", obj->offset_y );}
		if (strcmp(index, "offset_z" ) == 0) {return putLuaArguments(L, "i", obj->offset_z );}
		if (strcmp(index, "draw_mode") == 0) {return putLuaArguments(L, "i", obj->drawMode );}
		if (strcmp(index, "alpha"    ) == 0) {return putLuaArguments(L, "i", obj->alpha    );}
		if (strcmp(index, "dir"      ) == 0) {return putLuaArguments(L, "i", obj->dir      );}
		if (strcmp(index, "tick_time") == 0) {return putLuaArguments(L, "i", obj->tick     );}
		if (strcmp(index, "obstacle" ) == 0) {return putLuaArguments(L, "i", obj->obstacle );}
		if (strcmp(index, "bitmap"   ) == 0) {return putLuaArguments(L, "b", obj->bitmap   );}
		if (strcmp(index, "map"      ) == 0) {return putLuaArguments(L, "m", obj->getMap() );}
		if (strcmp(index, "id"       ) == 0) {return putLuaArguments(L, "i", obj->id       );}
		if (strcmp(index, "in_air"   ) == 0) {return putLuaArguments(L, "i", obj->in_air   );}

		// None of the above, so deal with the value normally
		/*
		local h = table._class
		if h == nil then return nil end
		if type(h) == "function" then return h(table, key)        -- call the handler
		else return h[key] end                                    -- or repeat operation on it
		*/
		lua_pushstring(L, "_class");                  // table key "_class"
		lua_rawget(L, -3);                            // table key _class
		if (lua_isnil(L, -1)) return 0;
		else if (lua_isfunction(L, -1)) {
			// Call the handler
			lua_insert(L, 1);                         // _class table key
			lua_call(L, 2, 1);                        // result
			return 1;
		}
		else {
			// Repeat operation on it
			lua_insert(L, -2);                        // table _class key
			lua_remove(L, 1);                         // _class key
			lua_gettable(L, -2);                      // value
			return 1;
		}
	}
	else
	{
		lua_rawget(L, -2);
		lua_remove(L, -2);
		return 1;
	}
}

int object_settable(lua_State *L)
{
	if (lua_isstring(L, -2))
	{
		// Get the name of the assigned variable
		const char *index = lua_tostring(L, -2);

		// Get the pointer to the object
		lua_pushstring(L, "_pointer");
		lua_rawget(L, -4);
		Object *obj = (Object*)lua_touserdata(L, -1);
		lua_pop(L, 1);

		// Exit with error when the object pointer is NULL
		if (!obj) {
			//lua_error(L, "Script tried to set variable of non-existing (destroyed?) object.");
			console.log(CON_LOG, CON_VDEBUG, "Warning: Script tried to set variable of non-existing object.");
			lua_settop(L, 0);
			return 0;
		}

		     if (strcmp(index, "speed"    ) == 0) {obj->speed    = lua_tonumber(L, -1);}
		else if (strcmp(index, "walking"  ) == 0) {obj->walking  = lua_tonumber(L, -1);}
		else if (strcmp(index, "x"        ) == 0) {obj->x        = lua_tonumber(L, -1);}
		else if (strcmp(index, "y"        ) == 0) {obj->y        = lua_tonumber(L, -1);}
		else if (strcmp(index, "w"        ) == 0) {obj->w        = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "h"        ) == 0) {obj->h        = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "offset_x" ) == 0) {obj->offset_x = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "offset_y" ) == 0) {obj->offset_y = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "offset_z" ) == 0) {obj->offset_z = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "draw_mode") == 0) {obj->drawMode = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "alpha"    ) == 0) {
			obj->alpha = (int)lua_tonumber(L, -1);
			obj->drawMode = (obj->alpha == 255) ?
				((obj->drawMode == DM_TRANS) ? DM_MASKED : obj->drawMode) :
				((obj->drawMode == DM_MASKED) ? DM_TRANS : obj->drawMode);
		}
		else if (strcmp(index, "dir"      ) == 0) {obj->dir      = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "tick_time") == 0) {obj->tick     = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "obstacle" ) == 0) {obj->obstacle = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "in_air"   ) == 0) {obj->in_air   = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "bitmap"   ) == 0) {obj->bitmap   = (BITMAP*)lua_touserdata(L, -1);}
		else if (strcmp(index, "map"      ) == 0) {
			TiledMap* newMap = (TiledMap*)lua_touserdata(L, -1);
			if (newMap != obj->getMap()) obj->setMap(newMap);
		}
		else {
			// Deal with the assigned value normally
			lua_rawset(L, -3);
		}
	}

	lua_settop(L, 0);
	return 0;
}
