/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef _INCLUDED_SCRIPT_H_
#define _INCLUDED_SCRIPT_H_

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#include <vector>

using std::vector;

#define DAT_LUA  DAT_ID('L','U','A',' ')

extern lua_State* L;
extern vector<char*> objectTypes;


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

int l_add_object(lua_State *L);
int l_register_object(lua_State *L);
int l_destroy_object(lua_State *L);

int l_bitmap_size(lua_State *L);

int l_register_class(lua_State *L);

int l_get_bitmap(lua_State *L);
int l_create_sub_bitmap(lua_State *L);
int l_load_map(lua_State *L);


//===================   Tag methods   ====================================================/

int object_gettable(lua_State *L);
int object_settable(lua_State *L);


#endif
