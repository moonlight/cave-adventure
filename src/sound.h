/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef _INCLUDED_SOUND_H_
#define _INCLUDED_SOUND_H_

#include <allegro.h>
#include "script.h"

#ifdef ENABLE_MUSIC
#include <alogg/alogg.h>
#endif


extern int sound_enabled;
extern int sfx_enabled;
extern int sfx_vol;
extern int music_vol;
extern int music_format;

#define MUSIC_MIDI 0
#define MUSIC_OGG  1


#define CHANNELS (1 << 1)  /* (2)     number of channels */
#define BLOCK_SIZE 40960

void init_sound();
int l_play_sample(lua_State *L);
void exit_sound();

void play_music(const char *filename);
int l_play_music(lua_State *L);

#ifdef ENABLE_MUSIC
void stop_music(int channel);
void poll_sound();
int l_get_number_of_channels(lua_State *L);
int l_stop_music(lua_State *L);
int l_adjust_channel(lua_State *L);
#endif


#endif // #ifndef _INCLUDED_SOUND_H_

