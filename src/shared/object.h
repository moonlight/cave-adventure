/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef _INCLUDED_OBJECT_H_
#define _INCLUDED_OBJECT_H_

#include <allegro.h>
#include "tiled_map.h"
#include "object.h"


//====================================================================================

class Object
{
public:
	static int id_counter;
	Point mapPos;						// The position on the map

	int _destroy;						// Object will be destroyed during next update.
	double walking, speed;
	int dir, prev_dir;
	int count, tick;
	BITMAP* bitmap;
	double x, y, px, py, nx, ny;
	int w, h;
	int obstacle;						// Object is an obstacle to other objects.
	int offset_x, offset_y, offset_z;
	int id;
	int tableRef;						// A reference to the associated Lua table
	char *className;

	Object(int luaTableRef, TiledMap* myMap);
	~Object();

	// Entity member variables/methods
	bool visible(BITMAP *dest, Point screenCoords);
	void draw(BITMAP *dest, Point topLeft);

	Point pos;
	int drawMode;
	int alpha;
	bool selected;
	int in_air;

	// Methods
	void walk(int dir, bool col);
	void set_dir(int dir);

	void initialize();
	void check_stand_on();
	void update();
	void update_entity();

	TiledMap* getMap() {return map;}
	void setMap(TiledMap *newMap);

private:
	TiledMap* map;
};

#endif
