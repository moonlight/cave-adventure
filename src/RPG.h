/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef _INCLUDED_RPG_H_
#define _INCLUDED_RPG_H_

#include "TiledMap.h"
#include "Engine.h"
#include "Console.h"
#include <map>
#include <allegro.h>

// Some engine settings
#define PROGRAM_ID			"Moonlight RPG engine"
#define LPS					100		// Game loops per second  -  sets the game speed and possible frame rate


extern volatile int frames_to_do;
extern volatile int fps, fps_counter;

extern int inkey;							// Last pressed key
extern int debug_mode;						// Show debug info

extern DATAFILE *interface_graphics;
extern DATAFILE *bitmap_data;
extern FONT *engine_font;

extern Console console;

extern TiledMap *tiledMap;
extern TileRepository *tileRepository;
extern TileType *selectedTile;

extern BITMAP *buffer;

extern bool game_end;

void ex_update_game(Object* excl_obj);
void wait_for_update();
void init_engine();
void init_rpg();
void init_graphics();
void handle_input();
void update_screen();
void draw_screen();
void exit_program();


#endif

