/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef INCLUDED_EDITOR

#include <allegro.h>
#include <vector>
#include "../shared/tiled_map.h"
#include "../shared/console.h"
#include "../shared/object.h"


#define PROGRAM_VERSION_STRING	"RPG Edit III 0.9.0"


// Global variables

extern DATAFILE *data;
extern int debug_mode;
extern FONT* engine_font;
extern Console console;
extern list<Object*> selectedObjects;
extern int selectedObjectType;
extern bool selecting;
extern int selection_start_x, selection_end_x;
extern int selection_start_y, selection_end_y;

extern TiledMap* currentMap;
extern TileType* selectedTile;
extern int selectedTileset;
extern int selectedObstacle;
extern int selectedLayer;

extern vector<char*> tileSets;
extern vector<TileType*> activeTileset;

extern int map_edit_mode;

extern bool mapChanged;
extern bool showTileGrid;
extern bool snapToGrid;

extern int selectedColor[6];

extern char map_filename[1024];
extern char status_message[1024];
extern char status_mapinfo[1024];

extern DIALOG main_dlg[];
extern DIALOG about_dlg[];
extern DIALOG import_tileset_dlg[];
extern DIALOG export_tileset_dlg[];
extern DIALOG resizemap_dlg[];
extern DIALOG newmap_dlg[];
extern DIALOG edit_tile_layer[];
extern DIALOG edit_obstacle_layer[];
extern DIALOG edit_objects_layer[];

extern MENU menu_file[];
extern MENU menu_main[];
extern MENU menu_edit[];
extern MENU menu_help[];


// Slider types (R, G, B, and H, S, V)

#define S_R					0
#define S_G					1
#define S_B					2
#define S_H					3
#define S_S					4
#define S_V					5

#define S_C					6


// Map edit modes

#define EM_TILE				0
#define EM_OBSTACLE			1
#define EM_OBJECTS			2


// Dialogs

#define MAIN_START_OF_NULL	12
#define NEWMAP_OK			9
#define IMPORT_TILESET_OK	7
#define EXPORT_TILESET_OK	5
#define RESIZEMAP_OK		13

#define D_MAP				main_dlg[3]
#define D_SCROLL_VER		main_dlg[4]
#define D_SCROLL_HOR		main_dlg[5]
#define D_AUTOTEXT_STATUS	main_dlg[8]
#define D_AUTOTEXT_MAPINFO	main_dlg[9]
#define D_TILE				main_dlg[ 1 + MAIN_START_OF_NULL]
#define D_CHECK_GRID		main_dlg[ 2 + MAIN_START_OF_NULL]
#define D_CHECK_SNAP		main_dlg[ 2 + MAIN_START_OF_NULL]
#define D_TILESET_LIST		main_dlg[16 + MAIN_START_OF_NULL]
#define D_TILESET			main_dlg[18 + MAIN_START_OF_NULL]
#define D_TILESET_SCROLL	main_dlg[19 + MAIN_START_OF_NULL]


// Messages

#define MSG_NEW_MAP			MSG_USER
#define MSG_NEW_TILESET		MSG_USER


// Flags

#define SCROLL_VER			D_USER


// Menu item functions

int menu_item_new_map();
int menu_item_load_map();
int menu_item_load_old_map();
int menu_item_save_map();
int menu_item_save_map_as();
int menu_item_import_tileset();
int menu_item_export_tileset();
int menu_item_exit();
int menu_item_resize_map();
int menu_item_edit_tiles_1();
int menu_item_edit_tiles_2();
int menu_item_edit_obs();
int menu_item_edit_objects();
int menu_item_about();
int menu_item_toggle_debug();
int menu_item_save_map_image();


void update_screen(int x, int y, int w, int h);

void deselect_objects();
void select_object(Object* obj);
void select_objects(list<Object*> objs);
void delete_objects(list<Object*> objs);

void import_tile_bitmap(const char* filename, int tile_w, int tile_h, int spacing);
//char* get_tileset_name(const char* name);

void set_map_changed(bool value);
bool close_current_map();
void update_window_title();

void set_dialog_size(DIALOG *d, int x, int y, int w, int h);

void activate_mode(DIALOG* dialog);


#endif
