/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#ifndef _INCLUDED_SCRIPT_H_
#define _INCLUDED_SCRIPT_H_

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#include "lunar.h"


#define DAT_LUA  DAT_ID('L','U','A',' ')

// Luna method and member table helpers
#define method(class, name) {#name, &class::name}
#define member(class, name, method) {#name, &class::method}

extern lua_State* L;


//===================   The engine to script interface   ============================/

void initScripting();
void exitScripting();

void handleLuaError(int err, const char *string);

int callMemberFunction(int tableRef, const char *function, const char *argfmt = NULL, ...);
int callFunction(const char *function, const char *argfmt = NULL, ...);

int  putLuaArguments(lua_State *L, const char *argfmt, ...);
void getLuaArguments(lua_State *L, const char *argfmt, ...);


//===================   The script to engine interface   ============================/

int l_alert(lua_State *L);
int l_console_message(lua_State *L);

int l_import_tile_bmp(lua_State *L);

int l_add_object(lua_State *L);
int l_register_object(lua_State *L);
int l_destroy_object(lua_State *L);
int l_get_objects_at(lua_State *L);

int l_get_ex_mode(lua_State *L);
int l_set_ex_mode(lua_State *L);

int l_get_cursor(lua_State *L);
int l_set_cursor(lua_State *L);
int l_text_size(lua_State *L);
int l_bitmap_size(lua_State *L);
int l_screen_size(lua_State *L);
int l_set_font(lua_State *L);
int l_draw_text(lua_State *L);
int l_draw_bitmap(lua_State *L);
int l_set_clip(lua_State *L);
int l_get_clip(lua_State *L);
int l_set_color(lua_State *L);
int l_set_drawmode(lua_State *L);
int l_set_alpha(lua_State *L);

int l_walk_obj(lua_State *L);
int l_walk_obj_nocol(lua_State *L);


//===================   Tag methods   ====================================================/

int object_gettable(lua_State *L);
int object_settable(lua_State *L);


#endif