/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bj�rn Lindeijer
 *
 ************************************************************************************/

#ifndef _INCLUDED_SOUND_H_
#define _INCLUDED_SOUND_H_

#include <alogg.h>
#include "Script.h"

extern int sound_enabled;


#define DATASZ   (1<<15) /* (32768) amount of data to read from disk each time */
#define BUFSZ    (1<<16) /* (65536) size of audiostream buffer */
#define CHANNELS (1<<1)  /* (2)     number of channels */

typedef struct OGGFile {
  PACKFILE *f;
  ALOGG_OGGSTREAM *s;
} OGGFILE;


void init_sound();
void poll_sound();
void play_sample(const char *filename);
void play_music(const char *filename);
void stop_music(OGGFILE *ogg);
void exit_sound();


int l_play_music(lua_State *L);
int l_stop_music(lua_State *L);
int l_adjust_channel(lua_State *L);
int l_get_number_of_channels(lua_State *L);


#endif