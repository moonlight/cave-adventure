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
#include "agup.h"
#include "aphoton.h"
#include "editor.h"
#include "../shared/tiled_map.h"
#include "script.h"
#include "../common.h"
#include "../shared/engine.h"


void initialize();
void clean_up();



int main(int argc, char *argv[])
{
	initialize();

	// Handle a map file passed as argument
	if (argc == 2 && exists(argv[1]))
	{
		PACKFILE *file = pack_fopen(argv[1], F_READ_PACKED);
		if (file) {
			currentMap->loadFrom(file, tileRepository);
			pack_fclose(file);
			ustrcpy(map_filename, argv[1]);
			update_window_title();
		} else {
			alert("Invalid map file:", argv[1], NULL, "OK", NULL, 13, 0);
		}
	}

	do_dialog(main_dlg, -1);
	clean_up();
	return 0;
}
END_OF_MAIN();



void initialize()
{
	char buf[1024];
	int i;

	// Initialise Allegro
	allegro_init();
	install_keyboard();
	install_mouse();
	install_timer();

	set_config_file("rpgedit.cfg");
	int grph_drv = (get_config_int("video", "fullscreen", 1)) ? GFX_AUTODETECT_FULLSCREEN : GFX_AUTODETECT_WINDOWED;
	int screen_w = get_config_int("video", "width", 800);
	int screen_h = get_config_int("video", "height", 600);

	if (get_config_int("tile_zoom", "grid", 1)) {
		showTileGrid = true;
	}

	set_color_conversion(
		(COLORCONV_TOTAL & ~(
			COLORCONV_32A_TO_8  |
			COLORCONV_32A_TO_15 |
			COLORCONV_32A_TO_16 |
			COLORCONV_32A_TO_24
		))
	);

	int colordepth = 0;
	if (grph_drv == GFX_AUTODETECT_WINDOWED) {colordepth = desktop_color_depth();}
	if (colordepth == 0) {colordepth = 16;}
	set_color_depth(colordepth);

	if (set_gfx_mode(grph_drv, screen_w, screen_h, 0, 0) != 0) {
		set_color_depth(15);
		if (set_gfx_mode(grph_drv, screen_w, screen_h, 0, 0) != 0) {
			set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);
			allegro_message("Unable to set any graphic mode\n%s\n", allegro_error);
			exit(1);
		}
	}

	buffer = create_bitmap(SCREEN_W, SCREEN_H);


	// Initialize GUI look and feel stuff
	agup_init(aphoton_theme);
    gui_fg_color = agup_fg_color;
    gui_bg_color = agup_bg_color;
    gui_shadow_box_proc = d_agup_shadow_box_proc;
    gui_button_proc = d_agup_button_proc;
    gui_edit_proc = d_agup_edit_proc;
    gui_text_list_proc = d_agup_text_list_proc;

	DATAFILE* font_data = load_datafile_object("gui.dat", "SmallFont");
	if (font_data) font = (FONT*)font_data->dat;

	engine_font = font;

	DATAFILE* mouse_pointer = load_datafile_object("gui.dat", "_MS_STD_BMP");
	if (mouse_pointer) set_mouse_sprite((BITMAP*)mouse_pointer->dat);

	DATAFILE* logo = load_datafile_object("gui.dat", "MoonlightLogo");
	about_dlg[1].dp = (BITMAP*)logo->dat;

	console.log(CON_LOG, CON_ALWAYS, "Loading data.dat...");
	data = load_datafile("data.dat");
	if (!data) {
		console.log(CON_QUIT, CON_ALWAYS, "Error while loading: data.dat");
	}

	// Lua initialisation
	console.log(CON_LOG, CON_ALWAYS, "Initialising Lua scripting environment...");
	initScripting();

	D_AUTOTEXT_STATUS.dp2 = status_message;
	D_AUTOTEXT_MAPINFO.dp2 = status_mapinfo;

	set_dialog_color(main_dlg, agup_fg_color, agup_bg_color);
	set_dialog_color(newmap_dlg, agup_fg_color, agup_bg_color);
	set_dialog_color(import_tileset_dlg, agup_fg_color, agup_bg_color);
	set_dialog_color(export_tileset_dlg, agup_fg_color, agup_bg_color);
	set_dialog_color(resizemap_dlg, agup_fg_color, agup_bg_color);
	set_dialog_color(about_dlg, agup_fg_color, agup_bg_color);
	

	// Position the dialogs on the screen
	int margin = 6;
	int zoom_w = get_config_int("tile_zoom", "zoom_width", 120) - 1;
	int zoom_h = get_config_int("tile_zoom", "zoom_height", 120) - 1;
	int x, y, w, h;
	
	// Main (back + menu)
	set_dialog_size(&main_dlg[0],          -2,                -2,              SCREEN_W + 4,          SCREEN_H + 4);
	set_dialog_size(&main_dlg[1],          0,                 0,               SCREEN_W,              15);

	// Status bars
	set_dialog_size(&main_dlg[6],          0,                 SCREEN_H - 17,   SCREEN_W - 256,        17);
	set_dialog_size(&main_dlg[7],          SCREEN_W - 256,    SCREEN_H - 17,   256,                   17);
	set_dialog_size(&main_dlg[8],          3,                 SCREEN_H - 14,   SCREEN_W - 262,        11);
	set_dialog_size(&main_dlg[9],          SCREEN_W - 253,    SCREEN_H - 14,   250,                   11);

	// Edit tile area
	w = zoom_w + 4;
	h = zoom_h + 4;
	x = margin;
	y = main_dlg[6].y - margin - h;
	set_dialog_size(&edit_tile_layer[0],   x,                 y,               w,                     h);
	set_dialog_size(&edit_tile_layer[1],   x + 2,             y + 2,           w - 4,                 h - 4);
	set_dialog_size(&edit_tile_layer[2],   x + margin + w,    y + h - 14,      50,                    14);

	// Color sliders
	x += w + margin;
	w = 128;
	set_dialog_size(&edit_tile_layer[8],   x,                 y,               16,                    8);
	set_dialog_size(&edit_tile_layer[9],   x,                 y + 16,          16,                    8);
	set_dialog_size(&edit_tile_layer[10],  x,                 y + 32,          16,                    8);
	set_dialog_size(&edit_tile_layer[11],  x,                 y + 48 + 8,      16,                    8);
	set_dialog_size(&edit_tile_layer[12],  x,                 y + 64 + 8,      16,                    8);
	set_dialog_size(&edit_tile_layer[3],   x + 16,            y,               w,                     8);
	set_dialog_size(&edit_tile_layer[4],   x + 16,            y + 16,          w,                     8);
	set_dialog_size(&edit_tile_layer[5],   x + 16,            y + 32,          w,                     8);
	set_dialog_size(&edit_tile_layer[6],   x + 16,            y + 48 + 8,      w,                     8);
	set_dialog_size(&edit_tile_layer[7],   x + 16,            y + 64 + 8,      w,                     8);
	set_dialog_size(&edit_tile_layer[13],  x + 16 + w + 4,    y - 1,           11,                    10);
	set_dialog_size(&edit_tile_layer[14],  x + 16 + w + 4,    y + 16 - 1,      11,                    10);
	set_dialog_size(&edit_tile_layer[15],  x + 16 + w + 4,    y + 32 - 1,      11,                    10);
	set_dialog_size(&edit_tile_layer[20],  x + 16 + w + 18,   y + 4,           18,                    32);

	// Select tile area
	x = edit_tile_layer[20].x + edit_tile_layer[20].w + margin;
	w = SCREEN_W - x - margin;
	set_dialog_size(&edit_tile_layer[16],  x,                 y,               104,                   h);
	set_dialog_size(&edit_tile_layer[17],  x + 104,           y,               w - 104,               h);
	set_dialog_size(&edit_tile_layer[18],  x + 104 + 2,       y + 2,           w - 104 - 4 - 11,      h - 4);
	set_dialog_size(&edit_tile_layer[19],  x + w - 14,        y,               14,                    h);

	// Obstacle edit stuff
	w = 24;
	h = 24;
	x = margin;
	y = main_dlg[6].y - margin - h;
	for (i = 0; i < 5; i++) {
		set_dialog_size(&edit_obstacle_layer[i],   x + i*(w+margin),     y,     w,     h);
		set_dialog_size(&edit_obstacle_layer[i+5], x + i*(w+margin) + 2, y + 2, w - 4, h - 4);
	}

	// Edit map area
	x = margin;
	y = 16 + margin;
	w = SCREEN_W - 2 * margin;
	h = edit_obstacle_layer[0].y - margin - y;
	set_dialog_size(&main_dlg[2],          x,                 y,               w,                     h);
	set_dialog_size(&main_dlg[3],          x + 2,             y + 2,           w - 15,                h - 15);
	set_dialog_size(&main_dlg[4],          x + w - 14,        y,               14,                    h - 11);
	set_dialog_size(&main_dlg[5],          x,                 y + h - 14,      w - 11,                14);
	set_dialog_size(&main_dlg[10],         x + w - 12,        y + h - 12,      10,                    10);

	// Edit objects area
	w = 123;
	h = 120;
	x = margin;
	y = main_dlg[6].y - margin - h;
	set_dialog_size(&edit_objects_layer[0], x,                y,               w,                     h);
	set_dialog_size(&edit_objects_layer[1], 136, main_dlg[6].y - margin - 14,  97,                    14);
	

	// Initialize map and tile stuff
	tileRepository = new TileRepository();

	// Import tilesets specified in rpgedit.cfg
	i = 1;
	while (i > 0) 
	{
		uszprintf(buf, sizeof buf, "tileset%d", i);

		const char* filename = get_config_string(buf, "filename", NULL);
		int tile_w = get_config_int(buf, "tile_w", 16);
		int tile_h = get_config_int(buf, "tile_h", 16);
		int tile_spacing = get_config_int(buf, "tile_spacing", 0);

		if (filename) {
			if (tile_w > 0 && tile_h > 0 && tile_spacing >= 0) {
				import_tile_bitmap(filename, tile_w, tile_h, tile_spacing);
			} else {
				allegro_message("Error, incorrect parameters for automatic tile import (%s)!", filename);
				// Print warning in log file
			}
			i++;
		} else  {
			i = -1;
		}
	}

	currentMap = new SquareMap(TILES_W, TILES_H);
	ustrcpy(map_filename, "untitled.map");

	// Load map specified in rpgedit.cfg
	const char* filename = get_config_string("startup", "load_map", NULL);
	if (filename) {
		PACKFILE *file = pack_fopen(filename, F_READ_PACKED);
		if (file) {
			currentMap->loadFrom(file, tileRepository);
			pack_fclose(file);
			ustrcpy(map_filename, filename);
			object_message(&D_MAP, MSG_NEW_MAP, 0);
			set_map_changed(false);
		} else {
			allegro_message("Error while loading default map (%s)!\n", filename);
			// Print warning in log file
		}
	}

	update_window_title();

	map_edit_mode = EM_TILE;
	menu_item_edit_objects();
	//activate_mode(edit_objects_layer);
}


void clean_up()
{
	delete currentMap;
	delete tileRepository;

	destroy_bitmap(buffer);

	agup_shutdown();
}
