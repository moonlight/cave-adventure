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
#include "../shared/engine.h"
#include "../shared/object.h"
#include "editor.h"
#include "../shared/console.h"
#include "script.h"
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

	DATAFILE *found_object = find_datafile_object(data, name);

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

	lua_register(L, "m_get_bitmap",     l_get_bitmap);
	lua_register(L, "m_load_map",       l_load_map);
	lua_register(L, "m_create_sub_bitmap", l_create_sub_bitmap);
	lua_register(L, "m_bitmap_size",    l_bitmap_size);

	lua_register(L, "m_register_class", l_register_class);

	lua_register(L, "m_add_object",     l_add_object);
	lua_register(L, "m_register_object", l_register_object);
	lua_register(L, "m_destroy_object", l_destroy_object);

	lua_register(L, "import",           l_import);

	handleLuaError(lua_dostring(L, lua_include), "lua_include");



	// Load all scripts
	console.log(CON_LOG, CON_ALWAYS, "Loading scripts...");

	int i;
	const char* name;

	for (i = 0; data[i].type != DAT_END; i++) {
		name = get_datafile_property(data+i, DAT_NAME);
		if (data[i].type == DAT_LUA) {
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
			case 'm': lua_pushlightuserdata(L,  va_arg(vals, TiledMap*));               break; // TiledMap
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

	if (placeable) {
		if (lua_toboolean(L, -1)) {
			objectTypes.push_back(typeName);
		}
	}

	lua_settop(L, 0);
	return 0;
}

int l_register_object(lua_State *L)
{
	int ref;
	TiledMap *map;

	getLuaArguments(L, "tm", &ref, &map);
	
	if (!map) {
		lua_pushstring(L, "Error, no valid map reference given.");
		lua_error(L);
	}

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

int l_get_bitmap(lua_State *L)
{
	const char *name;
	BITMAP* found_bitmap = NULL;
	getLuaArguments(L, "s", &name);

	DATAFILE *found_object = find_datafile_object(data, name);

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
		else if (strcmp(index, "alpha"    ) == 0) {obj->alpha    = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "dir"      ) == 0) {obj->dir      = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "tick_time") == 0) {obj->tick     = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "obstacle" ) == 0) {obj->obstacle = (int)lua_tonumber(L, -1);}
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
