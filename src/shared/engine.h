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

#include "tiled_map.h"
#include "../script.h"
#include <list>

using namespace std;

extern list<TiledMap*> maps;

#define DIR_NONE		-1
#define DIR_UP			0
#define DIR_LEFT		1
#define DIR_RIGHT		2
#define DIR_DOWN		3




//===================   Engine functions   ===========================================

void update_objects();


//===================   Variables   ==================================================

extern bool exclusive_mode;


#endif
