/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#include <allegro.h>
#include <stdarg.h>
#include "RPG.h"
#include "Engine.h"
#include "Console.h"
#include "Sound.h"
#include "Script.h"
#include "Canvas.h"


lua_State* L = NULL;

char lua_include[] =
"function inherit(to, from)			\n"
"	for index, value in from do		\n"
"		to[index] = value			\n"
"	end								\n"
"end								\n"

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
;


//===================   The engine to script interface   ============================/

void initScripting()
{
	// Create Lua state
	L = lua_open();

	// Enable these Lua libraries to the script
	luaopen_base(L);
	luaopen_io(L);
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
	//lua_register(L, "_ALERT",           l_alert);
	lua_register(L, "m_message",        l_console_message);

	lua_register(L, "m_import_tile_bmp", l_import_tile_bmp);
	lua_register(L, "m_get_bitmap",     l_get_bitmap);
	lua_register(L, "m_load_map",       l_load_map);
	lua_register(L, "m_create_sub_bitmap", l_create_sub_bitmap);

	lua_register(L, "m_add_object",     l_add_object);
	lua_register(L, "m_destroy_object", l_destroy_object);
	lua_register(L, "m_set_player",     l_set_player);
	lua_register(L, "m_get_player",     l_get_player);
	lua_register(L, "m_get_objects_at", l_get_objects_at);

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
	lua_register(L, "m_draw_viewport",  l_draw_viewport);

	lua_register(L, "m_walk_obj",       l_walk_obj);
	lua_register(L, "m_walk_obj_nocol", l_walk_obj_nocol);

	lua_register(L, "m_play_music",     l_play_music);
	lua_register(L, "m_stop_music",     l_stop_music);
	lua_register(L, "m_adjust_channel", l_adjust_channel);
	lua_register(L, "m_get_number_of_channels", l_get_number_of_channels);

	lua_register(L, "m_quit_game",      l_quit_game);

	handleLuaError(lua_dostring(L, lua_include), "lua_include");



	// Load all scripts
	console.log(CON_LOG, CON_ALWAYS, "Loading scripts...");

	int i, j;
	DATAFILE_PROPERTY *prop;
	const char* name;
	char tmp[256];

	for (i=0; bitmap_data[i].type != DAT_END; i++) {
		name = get_datafile_property(bitmap_data+i, DAT_NAME);
		if (bitmap_data[i].type == DAT_LUA) {
			console.log(CON_LOG, CON_ALWAYS, "> \"%s\"", name);
			handleLuaError(lua_dobuffer(L, (char*)bitmap_data[i].dat, bitmap_data[i].size, name), name);
		}
	}


	/*
	char searchstr[256] = "scripts/*.lua";
	char foundfile[256];
	al_ffblk finfo;

	fix_filename_slashes(searchstr);

	for (int i = al_findfirst(searchstr, &finfo, FA_ARCH); i == 0; i = al_findnext(&finfo))
	{
		console.log(CON_LOG, CON_ALWAYS, "> \"%s\"", finfo.name);

		replace_filename(foundfile, searchstr, finfo.name, 256);
		handleLuaError(lua_dofile(L, foundfile), foundfile);
	}
	*/
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
			//handleLuaError(lua_call(L, argc + 1, 1), function);
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
				if (lua_isnumber(L, -n + argc)) {
					*a = (int)(lua_tonumber(L, -n + argc) + 0.5);
				} else {
					lua_pushstring(L, "Invalid argument to function.");
					lua_error(L);
				}
			}
			break;

		case 'd':
			{
				double *a = va_arg(ap, double*);
				if (lua_isnumber(L, -n + argc)) {
					*a = lua_tonumber(L, -n + argc);
				} else {
					lua_pushstring(L, "Invalid argument to function.");
					lua_error(L);
				}
			}
			break;

		case 's':
			{
				const char **a = va_arg(ap, const char**);
				if (lua_isstring(L, -n + argc)) {
					*a = lua_tostring(L, -n + argc);
				} else {
					lua_pushstring(L, "Invalid argument to function.");
					lua_error(L);
				}
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
				} else {
					lua_pushstring(L, "Invalid argument to function.");
					lua_error(L);
				}
			}
			break;

		case 'b':
			{
				BITMAP **a = va_arg(ap, BITMAP**);
				if (lua_islightuserdata(L, -n + argc)) {
					*a = (BITMAP*)lua_touserdata(L, -n + argc);
				} else {
					lua_pushstring(L, "Invalid argument to function.");
					lua_error(L);
				}
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
	lua_getstack(L, 0, &ar);
	lua_getinfo(L, "nSl", &ar);
	const char *error = lua_tostring(L, -1);

	console.log(CON_QUIT, CON_ALWAYS, "An error occured in a Lua script:\n %s\n", error);
	/*
	console.log(
		CON_QUIT, CON_ALWAYS,
		"An error occured in a Lua script:\n"
		" %s\n"
		"Stack traceback:\n"
		" 0: %s %s function `%s' at line %d %s",
		error, ar->namewhat, ar->what, ar->name, ar->currentline, ar->short_src
	);
	*/
	return 0;
}

int l_console_message(lua_State *L)
{
	const char *message;
	getLuaArguments(L, "s", &message);
	console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Script log: %s", message);
	return 0;
}


int l_add_object(lua_State *L)
{
	const char* type;
	int x, y;
	getLuaArguments(L, "iis", &x, &y, &type);
	return putLuaArguments(L, "o", add_object(x, y, type));
}

int l_destroy_object(lua_State *L)
{
	Object *obj;
	getLuaArguments(L, "o", &obj);
	if (obj) obj->destroy = true;
	lua_settop(L, 0);
	return 0;
}

int l_get_objects_at(lua_State *L)
{
	int x, y, c = 1;
	getLuaArguments(L, "ii", &x, &y);

	lua_newtable(L);

	list<Object*>::iterator i;
	for (i = objects.begin(); i != objects.end(); i++) {
		Object *obj = (*i);
		if ((obj->x + obj->w > x && obj->x <= x) &&
			(obj->y - obj->h < y && obj->y >= y))
		{
			lua_getref(L, obj->tableRef);
			lua_rawseti(L, -2, c);
			c++;
		}
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
	import_tile_bmp(filename, tile_w, tile_h, tile_spacing);
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
	getLuaArguments(L, "b", &bmp);
	int w = bmp->w, h = bmp->h;
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
	getLuaArguments(L, "i", &alpha);
	canvas.setAlpha(alpha);
	if (alpha < 255 && canvas.getDrawMode() == DM_MASKED)
		canvas.setDrawMode(DM_TRANS);
	else if (alpha == 255 && canvas.getDrawMode() == DM_TRANS)
		canvas.setDrawMode(DM_MASKED);
	lua_settop(L, 0);
	return 0;
}


int l_walk_obj(lua_State *L)
{
	Object* obj;
	int dir;
	getLuaArguments(L, "oi", &obj, &dir);
	obj->walk(dir);
	return 0;
}

int l_walk_obj_nocol(lua_State *L)
{
	Object* obj;
	int dir;
	getLuaArguments(L, "oi", &obj, &dir);
	obj->walk_nocol(dir);
	return 0;
}


//===================   Tag methods   ===============================================/

int object_gettable(lua_State *L)
{
	if (lua_isstring(L, -1)) 
	{
		const char *index = lua_tostring(L, -1);

		lua_pushstring(L, "_pointer");
		lua_rawget(L, -3);
		Object *obj = (Object*)lua_touserdata(L, -1);
		lua_pop(L, 1);

		// Exit with error when the object pointer is NULL
		if (!obj) {
			//lua_error(L, "Script tried to get variable of non-existing (destroyed?) object.");
			console.log(CON_LOG, CON_VDEBUG, "Warning: Script tried to get variable of non-existing object.");
			lua_settop(L, 0);
			return 0;
		}

		if (strcmp(index, "speed"    ) == 0) {putLuaArguments(L, "i", obj->speed           ); return 1;}
		if (strcmp(index, "walking"  ) == 0) {putLuaArguments(L, "i", obj->walking         ); return 1;}
		if (strcmp(index, "x"        ) == 0) {putLuaArguments(L, "i", obj->x               ); return 1;}
		if (strcmp(index, "y"        ) == 0) {putLuaArguments(L, "i", obj->y               ); return 1;}
		if (strcmp(index, "w"        ) == 0) {putLuaArguments(L, "i", obj->w               ); return 1;}
		if (strcmp(index, "h"        ) == 0) {putLuaArguments(L, "i", obj->h               ); return 1;}
		if (strcmp(index, "offset_x" ) == 0) {putLuaArguments(L, "i", obj->offset_x        ); return 1;}
		if (strcmp(index, "offset_y" ) == 0) {putLuaArguments(L, "i", obj->offset_y        ); return 1;}
		if (strcmp(index, "offset_z" ) == 0) {putLuaArguments(L, "i", obj->offset_z        ); return 1;}
		if (strcmp(index, "draw_mode") == 0) {putLuaArguments(L, "i", obj->entity->drawMode); return 1;}
		if (strcmp(index, "alpha"    ) == 0) {putLuaArguments(L, "i", obj->entity->alpha   ); return 1;}
		if (strcmp(index, "dir"      ) == 0) {putLuaArguments(L, "i", obj->dir             ); return 1;}
		if (strcmp(index, "tick_time") == 0) {putLuaArguments(L, "i", obj->tick            ); return 1;}
		if (strcmp(index, "obstacle" ) == 0) {putLuaArguments(L, "i", obj->obstacle        ); return 1;}
		if (strcmp(index, "travel"   ) == 0) {putLuaArguments(L, "i", obj->travel          ); return 1;}
		if (strcmp(index, "bitmap"   ) == 0) {putLuaArguments(L, "b", obj->bitmap          ); return 1;}

		// None of the above, so deal with the value normally
		lua_rawget(L, -2);
		lua_remove(L, -2);
		return 1;
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

		     if (strcmp(index, "speed"    ) == 0) {obj->speed            = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "walking"  ) == 0) {obj->walking          = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "x"        ) == 0) {obj->x                = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "y"        ) == 0) {obj->y                = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "w"        ) == 0) {obj->w                = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "h"        ) == 0) {obj->h                = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "offset_x" ) == 0) {obj->offset_x         = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "offset_y" ) == 0) {obj->offset_y         = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "offset_z" ) == 0) {obj->offset_z         = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "draw_mode") == 0) {obj->entity->drawMode = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "alpha"    ) == 0) {obj->entity->alpha    = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "dir"      ) == 0) {obj->dir              = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "tick_time") == 0) {obj->tick             = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "obstacle" ) == 0) {obj->obstacle         = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "travel"   ) == 0) {obj->travel           = (int)lua_tonumber(L, -1);}
		else if (strcmp(index, "bitmap"   ) == 0) {obj->bitmap           = (BITMAP*)lua_touserdata(L, -1);}
		else {
            // Deal with the assigned value normally
			lua_rawset(L, -3);
		}
	}

	lua_settop(L, 0);
	return 0;
}