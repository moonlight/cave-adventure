/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#include "RPG.h"
#include "Console.h"
#include "Sound.h"
#include "TiledMap.h"
#include "Engine.h"
#include "Script.h"
#include "Canvas.h"
#include <allegro.h>

volatile int frames_to_do;
volatile int fps, fps_counter;

void handle_game_time()	{frames_to_do++;}
END_OF_FUNCTION(handle_game_time);
void handle_fps_counter() {fps = fps_counter; fps_counter = 0;}
END_OF_FUNCTION(handle_fps_counter);

int sound_counter = 0;

int inkey;							// Last pressed key
int debug_mode = 1;					// Show debug info

bool game_end = false;
bool bVSync = false;
bool bDoubleSize = false;
char filename[256];
DATAFILE *interface_graphics;
DATAFILE *bitmap_data;
FONT* engine_font;

Console console("RPG.log");

TiledMap *tiledMap = NULL;
TileRepository *tileRepository;
TileType *selectedTile = NULL;

BITMAP *buffer;

void main()
{
	init_engine();

	do {
		// Handle user input
		if (frames_to_do > 0) {
			handle_input();
			frames_to_do--;

			// If less than 2 extra frames are waiting, take time to display current frame
			if (frames_to_do < 2) {draw_screen();}
			else if (frames_to_do > 10) {frames_to_do = frames_to_do % 10;}
		}
	} while (!game_end);

	exit_program();
}
END_OF_MAIN();


void ex_update_game(Object* excl_obj)
{
	// Handle user input
	if (frames_to_do > 0) {
		if (excl_obj) excl_obj->update();

		list<Object*>::iterator i;
		for (i = objects.begin(); i != objects.end(); i++) {
			(*i)->update_entity();
		}

		frames_to_do--;
		draw_screen();
	}
}

void init_engine()
{
	// Allegro initialisation
	console.log(CON_LOG, CON_ALWAYS, "Initializing Allegro...");
	allegro_init();
	install_keyboard();
	install_timer();
	three_finger_flag = 0;

	//register_datafile_object(DAT_MAPDATA, load_tiledmapdata, destroy_tiledmapdata);

	set_config_file("RPG.cfg");

	debug_mode = (get_config_int("Engine", "DebugMode", 0)) ? 1 : 0;
	debug_mode += (get_config_int("Engine", "DebugVerbose", 0)) ? 1 : 0;

	int driver = GFX_AUTODETECT_WINDOWED;
	if (get_config_int("Engine", "Fullscreen", 1)) {
		driver = GFX_AUTODETECT_FULLSCREEN;
	}

	set_color_conversion(
		(COLORCONV_TOTAL & ~(
			COLORCONV_32A_TO_8  |
			COLORCONV_32A_TO_15 |
			COLORCONV_32A_TO_16 |
			COLORCONV_32A_TO_24
		))
	);

	bVSync = get_config_int("Engine", "VSync", 0);
	sound_enabled = (get_config_int("Sound", "EnableMusic", 1)) ? 1 : 0;

	// Screen initialisation
	int width, height, colordepth;
	width = get_config_int("Engine", "ResolutionWidth", 640);
	height = get_config_int("Engine", "ResolutionHeight", 480);
	colordepth = get_config_int("Engine", "ColorDepth", 16);

	bDoubleSize = get_config_int("Engine", "DoubleSize", 0);
	if (bDoubleSize) {
		width = width * 2;
		height = height * 2;
	}

	console.log(CON_LOG, CON_ALWAYS, "Setting screen mode (%dx%dx%d)...", width, height, colordepth);
	set_color_depth(colordepth);
	if (set_gfx_mode(driver, width, height, 0, 0) < 0) {
		console.log(CON_LOG, CON_ALWAYS, "Failed, trying screen mode (%dx%dx15)...", width, height);
		set_color_depth(15);
		if (set_gfx_mode(driver, width, height, 0, 0) < 0) {
			console.log(CON_QUIT, CON_ALWAYS, "%s", allegro_error);
		}
	}

	set_window_title("Moonlight RPG engine");

	text_mode(-1);
	textprintf_centre(screen, font, SCREEN_W/2, SCREEN_H/2, makecol(255,0,0), "LOADING...");

	console.log(CON_LOG, CON_ALWAYS, "Creating screen buffer...");
	if (bDoubleSize) {
		buffer = create_bitmap(SCREEN_W / 2, SCREEN_H / 2);
	} else {
		buffer = create_bitmap(SCREEN_W, SCREEN_H);
	}
	clear(buffer);

	console.log(CON_LOG, CON_ALWAYS, "Creating tile repository...");
	tileRepository = new TileRepository();

	console.log(CON_LOG, CON_ALWAYS, "Creating tiled map...");
	tiledMap = new SquareMap(TILES_W, TILES_H);
	tiledMap->setCamera(
		Point(0,0),
		Rectangle(0, 0, buffer->w, buffer->h),
		false, false
	);

	console.log(CON_LOG, CON_ALWAYS, "Loading gui.dat...");
	interface_graphics = load_datafile("gui.dat");
	if (!interface_graphics) {
		console.log(CON_QUIT, CON_ALWAYS, "Error while loading: gui.dat");
	}

	// Set font to use
	DATAFILE *temp = find_datafile_object(interface_graphics, "Terminal");
	if (temp) {engine_font = ((FONT *)temp->dat);}

	console.log(CON_LOG, CON_ALWAYS, "Loading data.dat...");
	bitmap_data = load_datafile("data.dat");
	if (!bitmap_data) {
		console.log(CON_QUIT, CON_ALWAYS, "Error while loading: data.dat");
	}

	// Lua initialisation
	console.log(CON_LOG, CON_ALWAYS, "Initialising Lua scripting environment...");
	initScripting();

	if (sound_enabled) {
		console.log(CON_LOG, CON_ALWAYS, "Initialising sound...");
		init_sound();
	}

	console.log(CON_LOG, CON_ALWAYS, "Installing timers...");
	LOCK_VARIABLE(frames_to_do);			// Game speed handler
	LOCK_FUNCTION(handle_game_time);
	LOCK_VARIABLE(fps);						// Frames per second counter
	LOCK_VARIABLE(fps_counter);
	LOCK_FUNCTION(handle_fps_counter);
	install_int_ex(handle_game_time, BPS_TO_TIMER(LPS));
	install_int_ex(handle_fps_counter, BPS_TO_TIMER(1));

	console.log(CON_LOG, CON_ALWAYS, "Initialising canvas...");
	canvas.init();

	console.log(CON_LOG, CON_ALWAYS, "All finished, initializing game...");
	callFunction("event_init");

	clear(screen);
}


void wait_for_update()
{
	frames_to_do = 0;
	while (frames_to_do == 0) {;}
}


void handle_input()
{
	if (switch_area) {
		switch_area_now();
	}

	if (key[KEY_ESC]) {game_end = true;}

	if (keypressed()) {
		inkey = (readkey() >> 8);
		if (console.handleInput(inkey)) inkey = 0;
	}
	else {
		inkey = 0;
	}
	
	if ((!player || exclusive_mode) && inkey > 0)
	{
		char *key_name = "anykey";

		if (inkey == KEY_SPACE) key_name = "action";
		if (inkey == KEY_UP) key_name = "up";
		if (inkey == KEY_LEFT) key_name = "left";
		if (inkey == KEY_RIGHT) key_name = "right";
		if (inkey == KEY_DOWN) key_name = "down";
		//if (inkey == KEY_CTRL) key_name = "attack";

		callFunction("event_keypress", "s", key_name);
	}


	update_objects();
	callFunction("event_logic_update");

	console.update();

	if (sound_enabled && sound_counter == 0) {
		poll_sound();
		sound_counter = 10;
	}
	sound_counter--;
}


void draw_screen()
{
	clear_bitmap(buffer);
	callFunction("event_render");

	canvas.init();

	if (debug_mode) {
		font = engine_font;
		textprintf_centre(buffer, font, buffer->w / 2 + 1, 12, makecol(0,0,0)      , "%d fps", fps);
		textprintf_centre(buffer, font, buffer->w / 2,     11, makecol(128,128,150), "%d fps", fps);
	}

	console.draw(buffer);
	update_screen();
	fps_counter++;
}

void update_screen()
{
	if (bVSync) vsync();
	if (bDoubleSize) {
		stretch_blit(buffer, screen, 0, 0, buffer->w, buffer->h, 0, 0, buffer->w * 2, buffer->h * 2);
	} else {
		blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);
	}
}


void exit_program()
{
	console.log(CON_LOG, CON_ALWAYS, "Game ended");

	console.log(CON_LOG, CON_ALWAYS, "Deleting objects...");
	list<Object*>::iterator i;
	while (!objects.empty())
	{
		i = objects.begin();
		delete (*i);
		objects.erase(i);
	}

	console.log(CON_LOG, CON_ALWAYS, "Deleting tiled map...");
	delete tiledMap;

	console.log(CON_LOG, CON_ALWAYS, "Deleting tile repository...");
	delete tileRepository;

	console.log(CON_LOG, CON_ALWAYS, "Removing timers...");
	remove_int(handle_fps_counter);
	remove_int(handle_game_time);

	console.log(CON_LOG, CON_ALWAYS, "Unloading datafiles...");
	unload_datafile(interface_graphics);
	unload_datafile(bitmap_data);

	if (sound_enabled) {
		console.log(CON_LOG, CON_ALWAYS, "Deinitializing sound...");
		exit_sound();
	}

	console.log(CON_LOG, CON_ALWAYS, "Destroying screen buffer...");
	destroy_bitmap(buffer);

	console.log(CON_LOG, CON_ALWAYS, "Closing Lua scripting environment...");
	exitScripting();

	exit(0);
}
