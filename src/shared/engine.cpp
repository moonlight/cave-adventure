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
#include <time.h>
#include <list>
#include "console.h"
#include "tiled_map.h"
#include "engine.h"
#include "../script.h"
#include "../common.h"

using namespace std;

list<TiledMap*> maps;

bool exclusive_mode = false;



//===================   Engine functions   ===========================================

void update_objects()
{
	// Iterate through all maps
	for (list<TiledMap*>::iterator i = maps.begin(); i != maps.end(); i++)
		(*i)->updateObjects();
}
