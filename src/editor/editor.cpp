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
#include <vector>
#include "agup.h"
#include "aphoton.h"
#include "editor.h"
#include "gui_procs.h"
#include "../shared/tiled_map.h"
#include "../shared/engine.h"
#include "../shared/object.h"


// Global variables

BITMAP* buffer;

DATAFILE *data;
int debug_mode = 0;
FONT* engine_font = NULL;
list<Object*> selectedObjects;
int selectedObjectType = 0;

bool selecting = false;
int selection_start_x, selection_end_x;
int selection_start_y, selection_end_y;

TiledMap* currentMap = NULL;
TileRepository* tileRepository = NULL;
TileType *selectedTile = NULL;
int selectedTileset = 0;
int selectedObstacle = 15;
int selectedLayer = 0;

vector<char*> tileSets;
vector<TileType*> activeTileset;

char map_filename[1024] = "";
char status_message[1024] = "";
char status_mapinfo[1024] = "";

int map_edit_mode = EM_TILE;

bool mapChanged = false;
bool showTileGrid = false;
bool snapToGrid = false;

Console console("rpgedit.log");

int selectedColor[6] =
{
	255,     // red
	255,     // green
	255,     // blue
	0,       // hue
	0,       // saturation
	255      // value
};



// Main dialogs

DIALOG main_dlg[] =
{
	/*(proc)                 (x)  (y)  (w)  (h)  (fg) (bg) (key) (flags)     (d1) (d2) (dp)           (dp2) (dp3)*/
	{ d_agup_box_proc,       -2,  -2,  804, 604, 0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_menu_proc,           0,   0,   800, 8,   0,   0,   0,    0,          0,   0,   menu_main,     NULL, NULL },
	{ d_agup_box_proc,       8,   24,  784, 421, 0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_bjorn_map_proc,      10,  26,  769, 406, 0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_bjorn_scroll_proc,   778, 24,  14,  410, 0,   0,   0,    SCROLL_VER, 0,   0,   NULL,          NULL, NULL },
	{ d_bjorn_scroll_proc,   8,   431, 773, 14,  0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_agup_box_proc,       0,   583, 544, 17,  0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_agup_box_proc,       544, 583, 256, 17,  0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_bjorn_autotext_proc, 3,   586, 538, 11,  0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_bjorn_autotext_proc, 547, 586, 250, 11,  0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_bjorn_camera_knop,   780, 433, 10,  10,  0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },
	{ d_yield_proc,          0,   0,   0,   0,   0,   0,   0,    0,          0,   0,   NULL,          NULL, NULL },

	// These nulls will be replaced with the extra widgets needed in certain modes.
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};


DIALOG edit_tile_layer[] = 
{
	/*(proc)                (x)  (y)  (w)  (h)  (fg) (bg) (key) (flags)     (d1) (d2) (dp)           (dp2)         (dp3)*/
	{ d_agup_box_proc,      8,   452, 123, 123, 0,   0,   0,    0,          0,   0,   NULL,          NULL,         NULL                },
	{ d_bjorn_tile_proc,    10,  454, 119, 119, 0,   0,   0,    0,          0,   0,   NULL,          NULL,         NULL                },
	{ d_bjorn_check_grid,   136, 560, 97,  14,  0,   0,   0,    0,          1,   0,   (void*)"grid", NULL,         NULL                },
	{ d_bjorn_slider_proc,  153, 455, 128, 8,   0,   0,   0,    0,          255, 0,   NULL,   (void*)update_color, &selectedColor[S_R] },
	{ d_bjorn_slider_proc,  153, 471, 128, 8,   0,   0,   0,    0,          255, 0,   NULL,   (void*)update_color, &selectedColor[S_G] },
	{ d_bjorn_slider_proc,  153, 487, 128, 8,   0,   0,   0,    0,          255, 0,   NULL,   (void*)update_color, &selectedColor[S_B] },
	{ d_bjorn_slider_proc,  153, 511, 128, 8,   0,   0,   0,    0,          255, 0,   NULL,   (void*)update_color, &selectedColor[S_S] },
	{ d_bjorn_slider_proc,  153, 527, 128, 8,   0,   0,   0,    0,          255, 0,   NULL,   (void*)update_color, &selectedColor[S_V] },
	{ d_text_proc,          138, 455, 16,  8,   0,   0,   0,    0,          0,   0,   (void*)"R",    NULL,         NULL                },
	{ d_text_proc,          138, 471, 16,  8,   0,   0,   0,    0,          0,   0,   (void*)"G",    NULL,         NULL                },
	{ d_text_proc,          138, 487, 16,  8,   0,   0,   0,    0,          0,   0,   (void*)"B",    NULL,         NULL                },
	{ d_text_proc,          138, 511, 16,  8,   0,   0,   0,    0,          0,   0,   (void*)"S",    NULL,         NULL                },
	{ d_text_proc,          138, 527, 16,  8,   0,   0,   0,    0,          0,   0,   (void*)"V",    NULL,         NULL                },
	{ d_bjorn_color_proc,   285, 454, 11, 10,   0,   0,   0,    0,          S_R, 0,   NULL,          NULL,         NULL                },
	{ d_bjorn_color_proc,   285, 470, 11, 10,   0,   0,   0,    0,          S_G, 0,   NULL,          NULL,         NULL                },
	{ d_bjorn_color_proc,   285, 486, 11, 10,   0,   0,   0,    0,          S_B, 0,   NULL,          NULL,         NULL                },
	{ d_bjorn_tileset_list, 322, 454, 104, 119, 0,   0,   0,    0,          0,   0,   (void*)list_tilesets, NULL,  NULL                },
	{ d_agup_box_proc,      426, 454, 365, 119, 0,   0,   0,    0,          0,   0,   NULL,          NULL,         NULL                },
	{ d_bjorn_tileset,      428, 456, 351, 115, 0,   0,   0,    0,          0,   0,   NULL,          NULL,         NULL                },
	{ d_bjorn_scroll_proc,  778, 454, 14,  119, 0,   0,   0,    SCROLL_VER, 0,   0,   NULL,          NULL,         NULL                },
	{ d_bjorn_color_proc,   299, 459, 18,  32,  0,   0,   0,    0,          S_C, 0,   NULL,          NULL,         NULL                },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};


DIALOG edit_obstacle_layer[] =
{
	/*(proc)                   (x) (y) (w) (h) (fg) (bg) (key) (flags) (d1) (d2) (dp)  (dp2) (dp3)*/
	{ d_agup_box_proc,         0,  0,  0,  0,  0,   0,   0,    0,      0,   0,   NULL, NULL, NULL },
	{ d_agup_box_proc,         0,  0,  0,  0,  0,   0,   0,    0,      0,   0,   NULL, NULL, NULL },
	{ d_agup_box_proc,         0,  0,  0,  0,  0,   0,   0,    0,      0,   0,   NULL, NULL, NULL },
	{ d_agup_box_proc,         0,  0,  0,  0,  0,   0,   0,    0,      0,   0,   NULL, NULL, NULL },
	{ d_agup_box_proc,         0,  0,  0,  0,  0,   0,   0,    0,      0,   0,   NULL, NULL, NULL },
	{ d_bjorn_obs_preset_proc, 0,  0,  0,  0,  0,   0,   0,    0,      15,  0,   NULL, NULL, NULL },
	{ d_bjorn_obs_preset_proc, 0,  0,  0,  0,  0,   0,   0,    0,      1,   0,   NULL, NULL, NULL },
	{ d_bjorn_obs_preset_proc, 0,  0,  0,  0,  0,   0,   0,    0,      2,   0,   NULL, NULL, NULL },
	{ d_bjorn_obs_preset_proc, 0,  0,  0,  0,  0,   0,   0,    0,      4,   0,   NULL, NULL, NULL },
	{ d_bjorn_obs_preset_proc, 0,  0,  0,  0,  0,   0,   0,    0,      8,   0,   NULL, NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};

DIALOG edit_objects_layer[] = 
{
	/*(proc)                (x)  (y)  (w)  (h)  (fg) (bg) (key) (flags)     (d1) (d2) (dp)           (dp2)         (dp3)*/
	{ d_bjorn_objects_list, 6,   454, 123, 120, 0,   0,   0,    0,          0,   0,   (void*)list_objects,   NULL, NULL },
	{ d_bjorn_check_snap,   136, 560, 97,  14,  0,   0,   0,    0,          1,   0,   (void*)"Snap to grid", NULL, NULL },
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};

DIALOG null_dialog[] =
{
	{ NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};


DIALOG newmap_dlg[] =
{
	/*(proc)              (x)  (y)  (w)  (h)  (fg) (bg) (key) (flags)     (d1) (d2) (dp)                     (dp2) (dp3)*/
	{ d_agup_window_proc, 0,   0,   168, 147, 0,   0,   0,    0,          0,   0,   (void*)"Create new map", NULL, NULL },
	{ d_text_proc,        8,   29,  88,  16,  0,   0,   0,    0,          0,   0,   (void*)"Map width:",     NULL, NULL },
	{ d_text_proc,        8,   48,  88,  16,  0,   0,   0,    0,          0,   0,   (void*)"Map height:",    NULL, NULL },
	{ d_agup_edit_proc,   104, 24,  56,  16,  0,   0,   0,    0,          3,   0,   NULL,                    NULL, NULL },
	{ d_agup_edit_proc,   104, 43,  56,  16,  0,   0,   0,    0,          3,   0,   NULL,                    NULL, NULL },
	{ d_text_proc,        8,   77,  88,  16,  0,   0,   0,    D_DISABLED, 0,   0,   (void*)"Tile width:",    NULL, NULL },
	{ d_text_proc,        8,   96,  88,  16,  0,   0,   0,    D_DISABLED, 0,   0,   (void*)"Tile height:",   NULL, NULL },
	{ d_agup_edit_proc,   104, 72,  56,  16,  0,   0,   0,    D_DISABLED, 3,   0,   NULL,                    NULL, NULL },
	{ d_agup_edit_proc,   104, 91,  56,  16,  0,   0,   0,    D_DISABLED, 3,   0,   NULL,                    NULL, NULL },
	{ d_agup_button_proc, 8,   120, 64,  19,  0,   0,   0,    D_EXIT,     0,   0,   (void*)"OK",             NULL, NULL },
	{ d_agup_button_proc, 80,  120, 80,  19,  0,   0,   0,    D_EXIT,     0,   0,   (void*)"Cancel",         NULL, NULL },
	{ d_yield_proc,       0,   0,   0,   0,   0,   0,   0,    0,          0,   0,   NULL,                    NULL, NULL },
	{ NULL,               0,   0,   0,   0,   0,   0,   0,    0,          0,   0,   NULL,                    NULL, NULL }
};

DIALOG import_tileset_dlg[] =
{
	/*(proc)              (x)  (y) (w)  (h)  (fg) (bg) (key) (flags) (d1) (d2) (dp)                      (dp2) (dp3)*/
	{ d_agup_window_proc, 0,   0,  168, 112, 0,   0,   0,    0,      0,   0,   (void*)"Import settings", NULL, NULL },
	{ d_text_proc,        8,   29, 88,  16,  0,   0,   0,    0,      0,   0,   (void*)"Tile width:",     NULL, NULL },
	{ d_text_proc,        8,   48, 88,  16,  0,   0,   0,    0,      0,   0,   (void*)"Tile height:",    NULL, NULL },
	{ d_text_proc,        8,   67, 88,  16,  0,   0,   0,    0,      0,   0,   (void*)"Tile spacing:",   NULL, NULL },
	{ d_agup_edit_proc,   104, 24, 56,  16,  0,   0,   0,    0,      3,   0,   NULL,                     NULL, NULL },
	{ d_agup_edit_proc,   104, 43, 56,  16,  0,   0,   0,    0,      3,   0,   NULL,                     NULL, NULL },
	{ d_agup_edit_proc,   104, 62, 56,  16,  0,   0,   0,    0,      1,   0,   NULL,                     NULL, NULL },
	{ d_agup_button_proc, 8,   85, 64,  19,  0,   0,   0,    D_EXIT, 0,   0,   (void*)"OK",              NULL, NULL },
	{ d_agup_button_proc, 80,  85, 80,  19,  0,   0,   0,    D_EXIT, 0,   0,   (void*)"Cancel",          NULL, NULL },
	{ d_yield_proc,       0,   0,  0,   0,   0,   0,   0,    0,      0,   0,   NULL,                     NULL, NULL },
	{ NULL,               0,   0,  0,   0,   0,   0,   0,    0,      0,   0,   NULL,                     NULL, NULL }
};

DIALOG export_tileset_dlg[] =
{
	/*(proc)              (x)  (y) (w)  (h) (fg) (bg) (key) (flags) (d1) (d2) (dp)                      (dp2) (dp3)*/
	{ d_agup_window_proc, 0,   0,  168, 96, 0,   0,   0,    0,      0,   0,   (void*)"Export settings", NULL, NULL },
	{ d_text_proc,        8,   29, 88,  16, 0,   0,   0,    0,      0,   0,   (void*)"Tile spacing:",   NULL, NULL },
	{ d_text_proc,        8,   48, 88,  16, 0,   0,   0,    0,      0,   0,   (void*)"Tiles in row:",   NULL, NULL },
	{ d_agup_edit_proc,   104, 24, 56,  16, 0,   0,   0,    0,      1,   0,   NULL,                     NULL, NULL },
	{ d_agup_edit_proc,   104, 43, 56,  16, 0,   0,   0,    0,      3,   0,   NULL,                     NULL, NULL },
	{ d_agup_button_proc, 8,   69, 64,  19, 0,   0,   0,    D_EXIT, 0,   0,   (void*)"OK",              NULL, NULL },
	{ d_agup_button_proc, 80,  69, 80,  19, 0,   0,   0,    D_EXIT, 0,   0,   (void*)"Cancel",          NULL, NULL },
	{ d_yield_proc,       0,   0,  0,   0,  0,   0,   0,    0,      0,   0,   NULL,                     NULL, NULL },
	{ NULL,               0,   0,  0,   0,  0,   0,   0,    0,      0,   0,   NULL,                     NULL, NULL }
};

DIALOG resizemap_dlg[] =
{
	/*(proc)              (x)  (y)  (w)  (h)  (fg) (bg) (key) (flags) (d1) (d2) (dp)                  (dp2)             (dp3)*/
	{ d_agup_window_proc, 0,   0,   168, 180, 0,   0,   0,    0,      0,   0,   (void*)"Resize map",  NULL,             NULL },
	{ d_text_proc,        8,   28,  88,  16,  0,   0,   0,    0,      0,   0,   (void*)"New width:",  NULL,             NULL },
	{ d_text_proc,        8,   48,  88,  16,  0,   0,   0,    0,      0,   0,   (void*)"New height:", NULL,             NULL },
	{ d_bjorn_edit_proc,  112, 24,  48,  16,  0,   0,   0,    0,      3,   0,   NULL,                 (void*)resizemap_change, NULL },
	{ d_bjorn_edit_proc,  112, 43,  48,  16,  0,   0,   0,    0,      3,   0,   NULL,                 (void*)resizemap_change, NULL },
	{ d_text_proc,        8,   76,  56,  16,  0,   0,   0,    0,      0,   0,   (void*)"Top:",        NULL,             NULL },
	{ d_text_proc,        8,   96,  56,  16,  0,   0,   0,    0,      0,   0,   (void*)"Bottom:",     NULL,             NULL },
	{ d_bjorn_edit_proc,  112, 72,  48,  16,  0,   0,   0,    0,      3,   0,   NULL,                 (void*)resizemap_change, NULL },
	{ d_bjorn_edit_proc,  112, 92,  48,  16,  0,   0,   0,    0,      3,   0,   NULL,                 (void*)resizemap_change, NULL },
	{ d_text_proc,        8,   116, 56,  16,  0,   0,   0,    0,      0,   0,   (void*)"Left:",       NULL,             NULL },
	{ d_text_proc,        8,   136, 56,  16,  0,   0,   0,    0,      0,   0,   (void*)"Right:",      NULL,             NULL },
	{ d_bjorn_edit_proc,  112, 112, 48,  16,  0,   0,   0,    0,      3,   0,   NULL,                 (void*)resizemap_change, NULL },
	{ d_bjorn_edit_proc,  112, 132, 48,  16,  0,   0,   0,    0,      3,   0,   NULL,                 (void*)resizemap_change, NULL },
	{ d_agup_button_proc, 7,   154, 64,  19,  0,   0,   0,    D_EXIT, 0,   0,   (void*)"OK",          NULL,             NULL },
	{ d_agup_button_proc, 79,  154, 82,  19,  0,   0,   0,    D_EXIT, 0,   0,   (void*)"Cancel",      NULL,             NULL },
	{ d_yield_proc,       0,   0,   0,   0,   0,   0,   0,    0,      0,   0,   NULL,                 NULL,             NULL },
	{ NULL,               0,   0,   0,   0,   0,   0,   0,    0,      0,   0,   NULL,                 NULL,             NULL }
};

DIALOG about_dlg[] =
{
	/*(proc)              (x) (y)  (w)  (h)  (fg) (bg) (key) (flags) (d1) (d2) (dp)                           (dp2) (dp3)*/
	{ d_agup_window_proc, 0,  0,   200, 77,  0,   0,   0,    0,      0,   0,   (void*)"About",                NULL, NULL },
	{ d_agup_icon_proc,   8,  24,  44,  44,  0,   0,   0,    0,      0,   0,   NULL,                          NULL, NULL },
	{ d_text_proc,        58, 28,  142, 16,  0,   0,   0,    0,      0,   0,   (void*)PROGRAM_VERSION_STRING, NULL, NULL },
	{ d_text_proc,        58, 42,  142, 16,  0,   0,   0,    0,      0,   0,   (void*)"(c) Bjorn Lindeijer",  NULL, NULL },
	{ d_bjorn_close_proc, 0,  0,   0,   0,   0,   0,   0,    0,      0,   0,   NULL,                          NULL, NULL },
	{ d_yield_proc,       0,  0,   0,   0,   0,   0,   0,    0,      0,   0,   NULL,                          NULL, NULL },
	{ NULL,               0,  0,   0,   0,   0,   0,   0,    0,      0,   0,   NULL,                          NULL, NULL }
};

// Menu structure

MENU menu_main[] =
{
   { "&File",                 NULL,                     menu_file, 0,          NULL },
   { "&Edit",                 NULL,                     menu_edit, 0,          NULL },
   { "&Help",                 NULL,                     menu_help, 0,          NULL },
   { 0 }
};

MENU menu_file[] =
{
   { "&New map...",           menu_item_new_map,        NULL,      0,          NULL },
   { "&Load map...",          menu_item_load_map,       NULL,      0,          NULL },
   { "Load &old map...",      menu_item_load_old_map,   NULL,      0,          NULL },
   { "&Save map",             menu_item_save_map,       NULL,      0,          NULL },
   { "Save map &as...",       menu_item_save_map_as,    NULL,      0,          NULL },
   { "Save map image",        menu_item_save_map_image, NULL,      0,          NULL },
   { "",                      NULL,                     NULL,      0,          NULL },
   { "&Import tileset...",    menu_item_import_tileset, NULL,      0,          NULL },
   { "&Export tileset as...", menu_item_export_tileset, NULL,      0,          NULL },
   { "",                      NULL,                     NULL,      0,          NULL },
   { "E&xit",                 menu_item_exit,           NULL,      0,          NULL },
   { 0 }
};

MENU menu_edit[] =
{
   //{ "&Undo",                     NULL,                     NULL,      D_DISABLED, NULL },
   //{ "&Redo",                     NULL,                     NULL,      D_DISABLED, NULL },
   //{ "",                          NULL,                     NULL,      0,          NULL },
   { "Resize &map...",            menu_item_resize_map,     NULL,      0,          NULL },
   { "",                          NULL,                     NULL,      0,          NULL },
   { "Switch to tile layer &1",   menu_item_edit_tiles_1,   NULL,      0,          NULL },
   { "Switch to tile layer &2",   menu_item_edit_tiles_2,   NULL,      0,          NULL },
   { "Switch to &obstacle layer", menu_item_edit_obs,       NULL,      0,          NULL },
   { "Switch to &objects layer",  menu_item_edit_objects,   NULL,      0,          NULL },
   { "",                          NULL,                     NULL,      0,          NULL },
   { "Toggle debug mode",         menu_item_toggle_debug,   NULL,      0,          NULL },
   { 0 }
};

MENU menu_help[] =
{
   { "&About",                menu_item_about,          NULL,      0,          NULL },
   { 0 }
};



// Menu handlers

int menu_item_new_map()
{
	if (close_current_map())
	{
		char map_w[8], map_h[8];
		char tile_w[8], tile_h[8];

		int imap_w, imap_h;
		int itile_w, itile_h;

		uszprintf(map_w, 8, "128");
		uszprintf(map_h, 8, "128");
		uszprintf(tile_w, 8, "24");
		uszprintf(tile_h, 8, "24");

		newmap_dlg[3].dp = (void*)map_w;
		newmap_dlg[4].dp = (void*)map_h;
		newmap_dlg[7].dp = (void*)tile_w;
		newmap_dlg[8].dp = (void*)tile_h;

		centre_dialog(newmap_dlg);
		int ret = popup_dialog(newmap_dlg, -1);

		if (ret == NEWMAP_OK) {
			imap_w = ustrtol(map_w, NULL, 10);
			imap_h = ustrtol(map_h, NULL, 10);
			itile_w = ustrtol(tile_w, NULL, 10);
			itile_h = ustrtol(tile_h, NULL, 10);

			if (itile_w > 0 && itile_h > 0 && imap_w > 0 && imap_h > 0)
			{
				//theMap->setMap(currentMap);
				currentMap->resizeTo(0, 0);
				currentMap->resizeTo(imap_w, imap_h);
				ustrzcpy(map_filename, sizeof map_filename, "untitled.map");
				object_message(&D_MAP, MSG_NEW_MAP, 0);
				set_map_changed(false);
				update_window_title();
			}
			else
			{
				alert(NULL, "Please fill in positive values for all variables!", NULL, "OK", NULL, 13, 0);
			}
		}
	}

	return D_O_K;
}

int menu_item_load_map()
{
	if (close_current_map())
	{
		char path_buf[1024] = "";

		if (file_select_ex(
			"Load map... (*.map)", path_buf, "map", sizeof path_buf,
			MAX(OLD_FILESEL_WIDTH,  SCREEN_W / 2),
			MAX(OLD_FILESEL_HEIGHT, SCREEN_H / 2)
			))
		{
			PACKFILE *file = pack_fopen(path_buf, F_READ_PACKED);
			if (file) {
				selectedObjects.clear();
				currentMap->loadFrom(file, tileRepository);
				pack_fclose(file);
				ustrcpy(map_filename, path_buf);
				object_message(&D_MAP, MSG_NEW_MAP, 0);
				set_map_changed(false);
				update_window_title();
			} else {
				alert(NULL, "Error while trying to load map!", NULL, "OK", NULL, 13, 0);
			}
		}
	}
	return D_O_K;
}

int menu_item_load_old_map()
{
	if (close_current_map())
	{
		char path_buf[1024] = "";

		if (file_select_ex(
			"Load map... (*.map)", path_buf, "map", sizeof path_buf,
			MAX(OLD_FILESEL_WIDTH,  SCREEN_W / 2),
			MAX(OLD_FILESEL_HEIGHT, SCREEN_H / 2)
			))
		{
			PACKFILE *file = pack_fopen(path_buf, F_READ_PACKED);
			if (file) {
				selectedObjects.clear();
				currentMap->loadFromOld(file, tileRepository);
				pack_fclose(file);
				ustrcpy(map_filename, path_buf);
				object_message(&D_MAP, MSG_NEW_MAP, 0);
				set_map_changed(false);
				update_window_title();
			} else {
				alert(NULL, "Error while trying to load old map!", NULL, "OK", NULL, 13, 0);
			}
		}
	}
	return D_O_K;
}

int menu_item_save_map()
{
	if (!currentMap) return D_O_K;

	if (ustrcmp(map_filename, "untitled.map") == 0) {
		menu_item_save_map_as();
		return D_O_K;
	}

	PACKFILE *file = pack_fopen(map_filename, F_WRITE_PACKED);
	if (file) {
		currentMap->saveTo(file);
		pack_fclose(file);
		set_map_changed(false);
	} else {
		menu_item_save_map_as();
	}
	return D_O_K;
}

int menu_item_save_map_as()
{
	if (!currentMap) return D_O_K;

	char path_buf[1024];

	ustrcpy(path_buf, map_filename);

	if (file_select_ex(
		"Save map... (*.map)", path_buf, "map", sizeof path_buf,
		MAX(OLD_FILESEL_WIDTH,  SCREEN_W / 2),
		MAX(OLD_FILESEL_HEIGHT, SCREEN_H / 2)
		))
	{
		PACKFILE *file = pack_fopen(path_buf, F_WRITE_PACKED);
		if (file) {
			currentMap->saveTo(file);
			pack_fclose(file);
			ustrcpy(map_filename, path_buf);
			set_map_changed(false);
			update_window_title();
		} else {
			alert(NULL, "Error while trying to save map!", NULL, "OK", NULL, 13, 0);
		}
	}
	return D_O_K;
}

int menu_item_import_tileset()
{
	char path_buf[1024] = "";

	if (file_select_ex(
		"Import tileset... (*.bmp)", path_buf, "bmp", sizeof path_buf,
		MAX(OLD_FILESEL_WIDTH,  SCREEN_W / 2),
		MAX(OLD_FILESEL_HEIGHT, SCREEN_H / 2)
		))
	{
		if (exists(path_buf))
		{
			char tile_w[8], tile_h[8], tile_spacing[8];
			int itile_w, itile_h, itile_spacing;

			uszprintf(tile_w, 8, "24");
			uszprintf(tile_h, 8, "24");
			uszprintf(tile_spacing, 8, "0");

			import_tileset_dlg[4].dp = (void*)tile_w;
			import_tileset_dlg[5].dp = (void*)tile_h;
			import_tileset_dlg[6].dp = (void*)tile_spacing;

			centre_dialog(import_tileset_dlg);
			int ret = popup_dialog(import_tileset_dlg, -1);

			if (ret == IMPORT_TILESET_OK)
			{
				itile_w = ustrtol(tile_w, NULL, 10);
				itile_h = ustrtol(tile_h, NULL, 10);
				itile_spacing = ustrtol(tile_spacing, NULL, 10);

				if (itile_w > 0 && itile_h > 0 && itile_spacing >= 0)
				{
					import_tile_bitmap(path_buf, itile_w, itile_h, itile_spacing);
				}
				else
				{
					alert(NULL, "Error, illegal value for either tile width, height or spacing!", NULL, "OK", NULL, 13, 0);
				}
			}
		}
		else
		{
			alert(NULL, "Error, file does not exist!", NULL, "OK", NULL, 13, 0);
		}
	}
	return D_O_K;
}

int menu_item_export_tileset()
{
	char path_buf[1024] = "";

	ustrncpy(path_buf, tileSets[D_TILESET_LIST.d1], sizeof path_buf);

	if (activeTileset.size() == 0) {
		alert(NULL, "Error, no tiles to save in active tileset!", NULL, "OK", NULL, 13, 0);
		return D_O_K;
	}

	if (file_select_ex(
		"Export tileset... (*.bmp)", path_buf, "bmp", sizeof path_buf,
		MAX(OLD_FILESEL_WIDTH,  SCREEN_W / 2),
		MAX(OLD_FILESEL_HEIGHT, SCREEN_H / 2)
		))
	{
		//if (exists(path_buf))
		//{
			char tile_spacing[8], tiles_in_row[8];
			int itile_spacing, itiles_in_row;

			uszprintf(tile_spacing, 8, "0");
			uszprintf(tiles_in_row, 8, "16");

			export_tileset_dlg[3].dp = (void*)tile_spacing;
			export_tileset_dlg[4].dp = (void*)tiles_in_row;

			centre_dialog(export_tileset_dlg);
			int ret = popup_dialog(export_tileset_dlg, -1);

			if (ret == EXPORT_TILESET_OK)
			{
				itile_spacing = ustrtol(tile_spacing, NULL, 10);
				itiles_in_row = ustrtol(tiles_in_row, NULL, 10);

				if (itile_spacing >= 0 && itiles_in_row > 0)
				{
					BITMAP *tile_bitmap;
					PALETTE pal;
					vector<TileType*>::iterator i;
					int x = 0;
					int y = 0;
					int tile_w = (activeTileset[0]->getBitmap())->w;
					int tile_h = (activeTileset[0]->getBitmap())->h;

					tile_bitmap = create_bitmap
					(
						itiles_in_row * (tile_w + itile_spacing),
						(activeTileset.size() / itiles_in_row + ((activeTileset.size() % itiles_in_row > 0) ? 1 : 0)) * (tile_h + itile_spacing)
					);

					clear_to_color(tile_bitmap, makecol(0,0,0));

					for (i = activeTileset.begin(); i != activeTileset.end(); i++)
					{
						blit((*i)->getBitmap(), tile_bitmap, 0, 0, x * (tile_w + itile_spacing), y * (tile_h + itile_spacing), tile_w, tile_h);
						x++;
						if (x == itiles_in_row) {
							y++;
							x = 0;
						}
					}

					get_palette(pal);
					save_bitmap(path_buf, tile_bitmap, pal);

					destroy_bitmap(tile_bitmap);
				}
				else
				{
					alert(NULL, "Error, illegal value for either tile spacing or tiles in row!", NULL, "OK", NULL, 13, 0);
				}
			}
		//}
		//else
		//{
			//alert(NULL, "Error, file does not exist!", NULL, "OK", NULL, 13, 0);
		//}
	}
	return D_O_K;
}

int menu_item_exit()
{
	if (close_current_map()) return D_CLOSE;
	else return D_O_K;
}

int menu_item_resize_map()
{
	char new_map_w[8], new_map_h[8];
	char top[8], left[8], right[8], bottom[8];

	int inew_map_w, inew_map_h;
	int itop, ileft, iright, ibottom;

	uszprintf(new_map_w, 8, "%d", currentMap->getWidth());
	uszprintf(new_map_h, 8, "%d", currentMap->getHeight());
	uszprintf(top, 8, "0");
	uszprintf(left, 8, "0");
	uszprintf(right, 8, "0");
	uszprintf(bottom, 8, "0");

	resizemap_dlg[3].dp = (void*)new_map_w;
	resizemap_dlg[4].dp = (void*)new_map_h;
	resizemap_dlg[7].dp = (void*)top;
	resizemap_dlg[8].dp = (void*)bottom;
	resizemap_dlg[11].dp = (void*)left;
	resizemap_dlg[12].dp = (void*)right;

	centre_dialog(resizemap_dlg);
	int ret = popup_dialog(resizemap_dlg, -1);

	if (ret == RESIZEMAP_OK)
	{
		inew_map_w = ustrtol(new_map_w, NULL, 10);
		inew_map_h = ustrtol(new_map_h, NULL, 10);
		itop = ustrtol(top, NULL, 10);
		ileft = ustrtol(left, NULL, 10);
		iright = ustrtol(right, NULL, 10);
		ibottom = ustrtol(bottom, NULL, 10);

		if (inew_map_w > 0 && inew_map_h > 0)
		{
			currentMap->resizeTo(inew_map_w, inew_map_h, ileft, itop);
			object_message(&D_MAP, MSG_NEW_MAP, 0);
			set_map_changed(true);
		}
		else
		{
			alert(NULL, "Error, illegal value(s) for new map size!", NULL, "OK", NULL, 13, 0);
		}
	}

	return D_O_K;
}

int menu_item_edit_tiles_1()
{
	map_edit_mode = EM_TILE;
	selectedLayer = 0;
	activate_mode(edit_tile_layer);
	return D_REDRAW;
}

int menu_item_edit_tiles_2()
{
	map_edit_mode = EM_TILE;
	selectedLayer = 1;
	activate_mode(edit_tile_layer);
	return D_REDRAW;
}

int menu_item_edit_obs()
{
	map_edit_mode = EM_OBSTACLE;
	selectedLayer = 0;
	activate_mode(edit_obstacle_layer);
	return D_REDRAW;
}

int menu_item_edit_objects()
{
	map_edit_mode = EM_OBJECTS;
	selectedLayer = 0;
	activate_mode(edit_objects_layer);
	return D_REDRAW;
}

int menu_item_about()
{
	centre_dialog(about_dlg);
	about_dlg[4].x = 0;
	about_dlg[4].y = 0;
	about_dlg[4].w = SCREEN_W;
	about_dlg[4].h = SCREEN_H;
	popup_dialog(about_dlg, -1);
	return D_O_K;
}

int menu_item_toggle_debug()
{
	debug_mode = !debug_mode;
	D_MAP.flags |= D_DIRTY;
	return D_O_K;
}

int menu_item_save_map_image()
{
	// Create bitmap the size of the map
	BITMAP* temp_bitmap = create_bitmap(currentMap->getWidth(), currentMap->getHeight());

	if (currentMap->getWidth() > 0 && currentMap->getHeight() > 0 && temp_bitmap) {
		int x, y;
		
		// Paint current map to temporary bitmap
		for (x = 0; x < temp_bitmap->w; x++) {
			for (y = 0; y < temp_bitmap->h; y++) {
				TileType* tileType = currentMap->getLayer(0)->getTile(Point(x, y))->getType();
				putpixel(temp_bitmap, x, y, tileType->getColor());
			}
		}

		// Save the bitmap to a file
		save_bitmap("map.bmp", temp_bitmap, NULL);
	}
	
	if (temp_bitmap) destroy_bitmap(temp_bitmap);
	return D_O_K;
}


// Double buffer, screen update function

void update_screen(int x, int y, int w, int h)
{
	blit(buffer, screen, x, y, x, y, w, h);
}


// Import tile bitmap

void import_tile_bitmap(const char* filename, int tile_w, int tile_h, int spacing)
{
	char buf[1024];
	char* tileset_name;

	tileRepository->importBitmap(filename, tile_w, tile_h, spacing);

	replace_extension(buf, get_filename(filename), "bmp", 1024);

	tileset_name = (char*)malloc(ustrsizez(buf));
	strcpy(tileset_name, buf);
	
	tileSets.push_back(tileset_name);

	D_TILESET_LIST.flags |= D_DIRTY;
}


// Used to change the map changed status (updates window tile when neccesary)

void set_map_changed(bool value)
{
	if (value != mapChanged) {
		mapChanged = value;
		update_window_title();
	}
}


// Check changed map before it gets closed

bool close_current_map()
{
	if (mapChanged) {
		int ret = alert3(
			"You've made changes to:",
			map_filename,
			"Do you want to save your changes?",
			"Yes", "No", "Cancel", 0, 0, 0
		);

		if (ret == 1) {
			menu_item_save_map();
		}

		if ((ret == 1 && !mapChanged) || ret == 2) return true;
		else return false;
	}
	else
	{
		return true;
	}
}


// Set the window title, with map filename and changed indicator

void update_window_title()
{
	static char window_title[1024];

	uszprintf(
		window_title, sizeof window_title, 
		"%s - [%s%s]", PROGRAM_VERSION_STRING, map_filename, (mapChanged) ? " *" : ""
	);

	set_window_title(window_title);
}


// Sets the size of a dialog

void set_dialog_size(DIALOG *d, int x, int y, int w, int h)
{
	d->x = x;
	d->y = y;
	d->w = w;
	d->h = h;
}


// Switch to either tile or obstacle edit mode

void activate_mode(DIALOG* dialog)
{
	int i = MAIN_START_OF_NULL;
	int nowhere;

	while (dialog->proc != NULL) {
		main_dlg[i] = *dialog;
		i++;
		dialog++;
	}

	main_dlg[i] = null_dialog[0];
	set_dialog_color(main_dlg, agup_fg_color, agup_bg_color);
	dialog_message(&main_dlg[MAIN_START_OF_NULL], MSG_START, 0, &nowhere);

	// Resize main edit map area
	int margin = 6;
	int x, y, w, h;

	x = margin;
	y = 16 + margin;
	w = SCREEN_W - 2 * margin;
	h = main_dlg[MAIN_START_OF_NULL].y - margin - y;
	set_dialog_size(&main_dlg[2],          x,                 y,               w,                     h);
	set_dialog_size(&main_dlg[3],          x + 2,             y + 2,           w - 15,                h - 15);
	set_dialog_size(&main_dlg[4],          x + w - 14,        y,               14,                    h - 11);
	set_dialog_size(&main_dlg[5],          x,                 y + h - 14,      w - 11,                14);
	set_dialog_size(&main_dlg[10],         x + w - 12,        y + h - 12,      10,                    10);
}

/*
char* get_tileset_name(const char* name)
{
	char *tmp, *tileset_name;

	tmp = get_filename(name);

	tileset_name = (char*)malloc(ustrsizez(tmp));
	strcpy(tileset_name, tmp);

	tmp = get_extension(tileset_name);

	if (tmp > tileset_name) {
		*(--tmp) = '\0';
	}

	return tileset_name;
}
*/

void deselect_objects()
{
	// Deselect all others (should check for CTRL modifyer)
	while (selectedObjects.size() > 0) {
		Object* obj = selectedObjects.front();
		obj->selected = false;
		selectedObjects.remove(obj);
	}
}

void select_object(Object* obj)
{
	deselect_objects();

	obj->selected = true;
	selectedObjects.push_front(obj);
}

void select_objects(list<Object*> objs)
{
	deselect_objects();

	list<Object*>::iterator i;
	for (i = objs.begin(); i != objs.end(); i++) {
		(*i)->selected = true;
		selectedObjects.push_front((*i));
	}
}

void delete_objects(list<Object*> objs)
{
	while (objs.size() > 0) {
		Object* obj = objs.front();
		if (obj->selected) selectedObjects.remove(obj);
		//callMemberFunction(obj->tableRef, "destroy", "");
		objs.remove(obj);
		currentMap->removeReference(obj);
		delete obj;
	}
}
