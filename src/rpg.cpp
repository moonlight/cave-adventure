/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#include "rpg.h"
#include "shared/console.h"
#include "sound.h"
#include "shared/tiled_map.h"
#include "shared/engine.h"
#include "script.h"
#include "canvas.h"
#include <allegro.h>

volatile int frames_to_do;
volatile int fps, fps_counter;

void handle_game_time()	{frames_to_do++;}
END_OF_FUNCTION(handle_game_time);
void handle_fps_counter() {fps = fps_counter; fps_counter = 0;}
END_OF_FUNCTION(handle_fps_counter);

#ifdef ENABLE_MUSIC
int sound_counter = 0;
#endif

int inkey;							// Last pressed key
int debug_mode = 1;					// Show debug info

bool game_end = false;
bool bVSync = false;
bool bDoubleSize = false;
char filename[256];
DATAFILE *interface_graphics;
DATAFILE *bitmap_data;
FONT* engine_font;
int gameClassInstance = 0;

int lps = 100;

Console console("rpg.log");

//TiledMap *tiledMap = NULL;
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


void init_engine()
{
	// Allegro initialisation
	console.log(CON_LOG, CON_ALWAYS, "Initializing Allegro...");
	allegro_init();
	install_keyboard();
	install_timer();
	three_finger_flag = 0;
	set_display_switch_mode(SWITCH_BACKAMNESIA);

	//register_datafile_object(DAT_MAPDATA, load_tiledmapdata, destroy_tiledmapdata);

	set_config_file("rpg.cfg");

	lps = get_config_int("Engine", "GameSpeed", 100);
	debug_mode = (get_config_int("Engine", "DebugMode", 0)) ? 1 : 0;
	debug_mode += (get_config_int("Engine", "DebugVerbose", 0)) ? 1 : 0;

	int driver = GFX_AUTODETECT_WINDOWED;
	if (get_config_int("Video", "Fullscreen", 0)) {
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

	bVSync = get_config_int("Video", "VSync", 0);
	
	sound_enabled = (get_config_int("Sound", "MusicEnabled", 1)) ? 1 : 0;
	sfx_enabled = (get_config_int("Sound", "SfxEnabled", 1)) ? 1 : 0;
	music_vol = get_config_int("Sound", "MusicVolume", 255);
	sfx_vol = get_config_int("Sound", "SfxVolume", 255);
	music_format = (strcmp(get_config_string("Sound", "MusicFormat", "MIDI"), "MIDI") == 0) ? MUSIC_MIDI : MUSIC_OGG;
	console.enableLogfile = (get_config_int("Engine", "LogEnabled", 1));

	// Screen initialisation
	int width, height, colordepth = 0;
	width = get_config_int("Video", "ResolutionWidth", 640);
	height = get_config_int("Video", "ResolutionHeight", 480);

	if (driver == GFX_AUTODETECT_FULLSCREEN) {colordepth = desktop_color_depth();}
	if (colordepth == 0) {colordepth = 16;}
	colordepth = get_config_int("Video", "ColorDepth", colordepth);

	bDoubleSize = get_config_int("Video", "DoubleSize", 0);
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

 	console.log(CON_LOG, CON_ALWAYS, "Loading gui.dat...");
	interface_graphics = load_datafile("gui.dat");
	if (!interface_graphics) {
		console.log(CON_QUIT, CON_ALWAYS, "Error while loading: gui.dat");
	}

	// Set font to use
	DATAFILE *temp = find_datafile_object(interface_graphics, "SmallFont");
	if (temp) {engine_font = ((FONT *)temp->dat);}

	console.log(CON_LOG, CON_ALWAYS, "Loading data.dat...");
	bitmap_data = load_datafile("data.dat");
	if (!bitmap_data) {
		console.log(CON_QUIT, CON_ALWAYS, "Error while loading: data.dat");
	}

	if (sound_enabled || sfx_enabled) {
		console.log(CON_LOG, CON_ALWAYS, "Initialising sound...");
		init_sound();
	}

	// Lua initialisation
	console.log(CON_LOG, CON_ALWAYS, "Initialising Lua scripting environment...");
	initScripting();

	console.log(CON_LOG, CON_ALWAYS, "Installing timers...");
	LOCK_VARIABLE(frames_to_do);			// Game speed handler
	LOCK_FUNCTION(handle_game_time);
	LOCK_VARIABLE(fps);						// Frames per second counter
	LOCK_VARIABLE(fps_counter);
	LOCK_FUNCTION(handle_fps_counter);
	install_int_ex(handle_game_time, BPS_TO_TIMER(lps));
	install_int_ex(handle_fps_counter, BPS_TO_TIMER(1));

	console.log(CON_LOG, CON_ALWAYS, "Initialising canvas...");
	canvas.init();

	console.log(CON_LOG, CON_ALWAYS, "All finished, initializing game...");

	const char* gameClass = get_config_string("Engine", "GameClass", "Game");
	lua_pushstring(L, gameClass);
    lua_gettable(L, LUA_GLOBALSINDEX);
	if (!lua_isnil(L, -1)) {
		lua_call(L, 0, 1);
		if (lua_istable(L, -1)) {
			gameClassInstance = lua_ref(L, -1);
		}
		else {
			console.log(CON_QUIT, CON_ALWAYS, "Error while instaniating game class \"%s\"", gameClass);
		}
	}
	else {
		console.log(CON_QUIT, CON_ALWAYS, "Error: could not find game class \"%s\"", gameClass);
	}

	clear(screen);
}


void handle_input()
{
	if (keypressed()) {
		inkey = (readkey() >> 8);
		if (console.handleInput(inkey)) inkey = 0;
	}
	else {
		inkey = 0;
	}

	if (inkey > 0)
	{
		char *key_name = "anykey";

		if (inkey == KEY_ESC)   key_name = "esc";
		if (inkey == KEY_TAB)   key_name = "tab";
		if (inkey == KEY_SPACE || inkey == KEY_ENTER) key_name = "action";
		if (inkey == KEY_UP)    key_name = "up";
		if (inkey == KEY_LEFT)  key_name = "left";
		if (inkey == KEY_RIGHT) key_name = "right";
		if (inkey == KEY_DOWN)  key_name = "down";
		if (inkey == KEY_LCONTROL || inkey == KEY_RCONTROL)  key_name = "ctrl";

		callMemberFunction(gameClassInstance, "event_keypress", "s", key_name);
	}


	update_objects();
	callMemberFunction(gameClassInstance, "event_logic_update");

	console.update();

#ifdef ENABLE_MUSIC
	if (sound_enabled && sound_counter == 0) {
		poll_sound();
		sound_counter = 10;
	}
	sound_counter--;
#endif
}


void draw_screen()
{
	clear_bitmap(buffer);

	callMemberFunction(gameClassInstance, "event_render");

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
	list<TiledMap*>::iterator i;
	while (!maps.empty())
	{
		i = maps.begin();
		delete (*i);
		maps.erase(i);
	}

	console.log(CON_LOG, CON_ALWAYS, "Deleting tile repository...");
	delete tileRepository;

	console.log(CON_LOG, CON_ALWAYS, "Removing timers...");
	remove_int(handle_fps_counter);
	remove_int(handle_game_time);

	console.log(CON_LOG, CON_ALWAYS, "Unloading datafiles...");
	unload_datafile(interface_graphics);
	unload_datafile(bitmap_data);

	if (sound_enabled || sfx_enabled) {
		console.log(CON_LOG, CON_ALWAYS, "Deinitializing sound...");
		exit_sound();
	}

	console.log(CON_LOG, CON_ALWAYS, "Destroying screen buffer...");
	destroy_bitmap(buffer);

	console.log(CON_LOG, CON_ALWAYS, "Closing Lua scripting environment...");
	exitScripting();

	exit(0);
}
