/*
	The Moonlight Engine - An extendable, portable, RPG-focused game engine.
	Project Home: http://moeng.sourceforge.net/
	Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#define ALOGG_DLL

#include <allegro.h>
#include <alogg.h>
#include "Console.h"
#include "Sound.h"
#include "RPG.h"
#include "Script.h"

int sound_enabled = 1;


// Currently playing OGG file
OGGFILE *ogg[CHANNELS];

char* error = "";

int ChunkSize;  /* (default = 32768) amount of data to read from disk each time */
int BufferSize; /* (default = 65536) size of audiostream buffer */



void init_sound() {
	// Read config variables
	ChunkSize = (get_config_int("Sound", "StreamChunkSize", 1<<15));
	BufferSize = (get_config_int("Sound", "BufferSize", 1<<16));

	// To achieve the max possible volume
	set_volume_per_voice(0);

	// Install sound driver
	if (install_sound(DIGI_AUTODETECT, MIDI_NONE, NULL) != 0) {
		console.log(CON_LOG, CON_ALWAYS, "Error initialising sound system: %s", allegro_error);
		return;
	}

	// Initialize channels to NULL
	for (int i = 0; i < CHANNELS; i++) {
		ogg[i] = NULL;
	}
}

int poll_ogg_file(OGGFILE *ogg)
{
	char *data;
	long len;
	
	data = (char *)alogg_get_oggstream_buffer(ogg->s);
	if (data) {
		len = pack_fread(data, DATASZ, ogg->f);
		if (len < DATASZ)
			alogg_free_oggstream_buffer(ogg->s, len);
		else
			alogg_free_oggstream_buffer(ogg->s, -1);
	}
	
	return alogg_poll_oggstream(ogg->s);
}

OGGFILE *open_ogg_file(char *filename)
{
	OGGFILE *p = NULL;
	PACKFILE *f = NULL;
	ALOGG_OGGSTREAM *s = NULL;
	char data[DATASZ];
	int len;
	
	if (!(p = (OGGFILE *)malloc(sizeof(OGGFILE)))) {
		error = "not enough memory";
		goto error;
	}
	if (!(f = pack_fopen(filename, F_READ))) {
		error = "not able to open file";
		goto error;
	}
	if ((len = pack_fread(data, DATASZ, f)) <= 0) {
		error = "error reading data from file";
		goto error;
	}
	if (len < DATASZ) {
		if (!(s = alogg_create_oggstream(data, len, TRUE))) {
			error = "error creating stream";
			goto error;
		}
	}
	else {
		if (!(s = alogg_create_oggstream(data, ChunkSize, FALSE))) {
			error = "error creating stream";
			goto error;
		}
	}
	p->f = f;
	p->s = s;
	return p;

error:
	pack_fclose(f);
	free(p);
	return NULL;
}



/* play_music(filename, channel)
 */
int l_play_music(lua_State *L)
{
	char* filename;
	int channel;
	getLuaArguments(L, "si", &filename, &channel);

	error = NULL;

	if (sound_enabled) {
		// Stop currently playing music
		stop_music(ogg[channel]);
		ogg[channel] = NULL;

		if (channel < 0 || channel > CHANNELS) {error = "invalid channel";}
		else if (!exists(filename)) {error = "file does not exist";}
		
		if (error == NULL) {
			ogg[channel] = open_ogg_file(filename);
		}

		if (error == NULL && ogg[channel]) {
			alogg_play_oggstream(ogg[channel]->s, BufferSize, 255, 128);
			console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Playing OGG file (%s)", filename);
		}
		else {
			console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Error playing OGG file \"%s\" (%s)", filename, error);
		}
	}

	return 0;
}

/* adjust_channel(channel, volume, panning, speed)
 */
int l_adjust_channel(lua_State *L)
{
	int channel, vol, pan, speed;
	getLuaArguments(L, "iiii", &channel, &vol, &pan, &speed);

	error = NULL;

	if (sound_enabled) {
		if (channel < 0 || channel > CHANNELS) {error = "invalid channel";}
		else if (!ogg[channel]) {error = "no music on this channel to adjust";}
		else if (vol < 0 || vol > 255) {error = "illegal volume value";}
		else if (pan < 0 || pan > 255) {error = "illegal panning value";}
		else if (speed < 0) {error = "illegal speed value";}

		if (error == NULL) {
			alogg_adjust_oggstream(ogg[channel]->s, vol, pan, speed);
			//console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Adjusted channel parameters (%d, %d, %d, %d)", channel, vol, pan, speed);
		} else {
			console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Error adjusting channel parameters (%s)", error);
		}
	}

	return 0;
}

/* get_number_of_channels()
 */
int l_get_number_of_channels(lua_State *L)
{
	return putLuaArguments(L, "i", CHANNELS);
}


/* play_sample(filename)
 */
void play_sample(char *filename)
{
}


void stop_music(OGGFILE *ogg)
{
	if (ogg) {
		pack_fclose(ogg->f);
		alogg_destroy_oggstream(ogg->s);
		free(ogg);
		ogg = NULL;
	}
}


/* stop_music(channel)
 */
int l_stop_music(lua_State *L)
{
	int channel;
	getLuaArguments(L, "i", &channel);

	error = NULL;
	if (channel < 0 || channel >= CHANNELS) {error = "invalid channel";}

	if (error == NULL) {
		stop_music(ogg[channel]);
		ogg[channel] = NULL;
	} else {
		console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Error stopping music (%s)", error);
	}
	return 0;
}

void poll_sound()
{
	for (int i = 0; i < CHANNELS; i++) {
		if (ogg[i]) {
			poll_ogg_file(ogg[i]);
		}
	}
}

void exit_sound()
{
	for (int i = 0; i < CHANNELS; i++) {
		stop_music(ogg[i]);
		ogg[i] = NULL;
	}
}

