/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef _INCLUDED_ENGINE_H_
#define _INCLUDED_ENGINE_H_

#include "TiledMap.h"
#include "Script.h"
#include <list>

using namespace std;

#define DIR_UP			0
#define DIR_LEFT		1
#define DIR_RIGHT		2
#define DIR_DOWN		3

#define TILES_W			24
#define TILES_H			24



//====================================================================================

class Object
{
	static int id_counter;
	Point mapPos;						// The position on the map

public:
	int _destroy;						// Object will be destroyed during next update.
	BITMAP* bitmap;
	int count, tick;
	int speed;
	int offset_x, offset_y, offset_z;
	int obstacle;						// Object is an obstacle to other objects.
	int id;
	int prev_dir;

	int x, y, w, h, dir;
	int tableRef;						// A reference to the associated Lua table
	int walking;
	int travel;							// Object remains when switching maps.
	Entity* entity;						// A pointer to the associated map entity


	// Lua getters and setters
	int getid(lua_State *L) { lua_pushnumber(L, id); return 1; }
	int getspeed(lua_State *L) { lua_pushnumber(L, speed); return 1; }
	int setspeed(lua_State *L) { x = luaL_checknumber(L, 1); return 0; }
	int getobstacle(lua_State *L) { lua_pushnumber(L, obstacle); return 1; }
	int setobstacle(lua_State *L) { obstacle = luaL_checknumber(L, 1); return 0; }
	int gettick(lua_State *L) { lua_pushnumber(L, tick); return 1; }
	int settick(lua_State *L) { tick = luaL_checkint(L, 1); return 0; }
	int gettravel(lua_State *L) { lua_pushnumber(L, travel); return 1; }
	int settravel(lua_State *L) { travel = luaL_checkint(L, 1); return 0; }
	int getx(lua_State *L) { lua_pushnumber(L, x); return 1; }
	int setx(lua_State *L) { x = luaL_checknumber(L, 1); return 0; }
	int gety(lua_State *L) { lua_pushnumber(L, y); return 1; }
	int sety(lua_State *L) { y = luaL_checknumber(L, 1); return 0; }
	int getw(lua_State *L) { lua_pushnumber(L, w); return 1; }
	int setw(lua_State *L) { w = luaL_checknumber(L, 1); return 0; }
	int geth(lua_State *L) { lua_pushnumber(L, h); return 1; }
	int seth(lua_State *L) { h = luaL_checknumber(L, 1); return 0; }
	int getoffset_x(lua_State *L) { lua_pushnumber(L, offset_x); return 1; }
	int setoffset_x(lua_State *L) { offset_x = luaL_checknumber(L, 1); return 0; }
	int getoffset_y(lua_State *L) { lua_pushnumber(L, offset_y); return 1; }
	int setoffset_y(lua_State *L) { offset_y = luaL_checknumber(L, 1); return 0; }
	int getoffset_z(lua_State *L) { lua_pushnumber(L, offset_z); return 1; }
	int setoffset_z(lua_State *L) { offset_z = luaL_checknumber(L, 1); return 0; }
	int setbitmap(lua_State *L) { bitmap = (BITMAP*)lua_touserdata(L, -1); return 0; }
	int getbitmap(lua_State *L) { lua_pushlightuserdata(L, bitmap); return 1; }

	// Lua methods
	int destroy(lua_State *L) { _destroy = 1; return 0; }
	int walk(lua_State *L);
	int subclass(lua_State *L);

	// Methods
	void walk(int dir);
	void walk_nocol(int dir);
	void set_dir(int dir);

	Object(int luaTableRef);
	Object(lua_State *L);

	~Object();

	void initialize();
	void check_stand_on();
	void update();
	void update_entity();

	static const char className[16];
	static Lunar<Object>::RegType methods[];
	static Lunar<Object>::RegType getters[];
	static Lunar<Object>::RegType setters[];
};



//===================   Engine functions   ===========================================

void update_objects();
void switch_area_now();


//===================   Script functions   ===========================================

void import_tile_bmp(const char* filename, int tiles_w, int tiles_h, int tile_spacing);
Object* add_object(int x, int y, const char* script);
Object* register_object(int tableRef);
void ex_walk(Object* obj, int dir, int dist);
void ex_wait(int updates);

int l_set_player(lua_State *L);
int l_get_player(lua_State *L);

int l_get_bitmap(lua_State *L);
int l_create_sub_bitmap(lua_State *L);
int l_load_map(lua_State *L);
int l_draw_viewport(lua_State *L);

int l_quit_game(lua_State *L);

void quit_game();


//===================   Variables   ==================================================

extern list<Object*> objects;
extern Object* player;

extern bool exclusive_mode;

extern bool switch_area;
extern char area_name[64];
extern char map_filename[64];

#endif
