/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#ifndef _INCLUDED_ENGINE_H_
#define _INCLUDED_ENGINE_H_

#include "TiledMap.h"
#include "Script.h"
#include <list>

using namespace std;

#define DIR_UP			0
#define DIR_LEFT		1
#define DIR_RIGHT		2
#define DIR_DOWN		3

#define TILES_W			24
#define TILES_H			24



//====================================================================================

class Object
{
  public:
	BITMAP* bitmap;
	int x, y, w, h, dir, prev_dir;
	int count, tick;
	int speed;
	int walking;
	int offset_x, offset_y, offset_z;
	int obstacle;						// Object is an obstacle to other objects.
	int destroy;						// Object will be destroyed during next update.
	int travel;							// Object remains when switching maps.

	void walk(int dir);
	void walk_nocol(int dir);
	void set_dir(int dir);


	Object(int luaTableRef);
	~Object();
	void initialize();
	void check_stand_on();
	void update();
	void update_entity();

	Entity* entity;
	//char type[256];
	char name[256];
	Point mapPos;

	int tableRef;
};


//===================   Engine functions   ===========================================

void update_objects();
void switch_area_now();


//===================   Script functions   ===========================================

void import_tile_bmp(const char* filename, int tiles_w, int tiles_h, int tile_spacing);
Object* add_object(int x, int y, const char* script);
void ex_walk(Object* obj, int dir, int dist);
void ex_wait(int updates);

int l_set_player(lua_State *L);
int l_get_player(lua_State *L);

int l_get_bitmap(lua_State *L);
int l_create_sub_bitmap(lua_State *L);
int l_load_map(lua_State *L);
int l_draw_viewport(lua_State *L);

int l_quit_game(lua_State *L);

void quit_game();


//===================   Variables   ==================================================

extern list<Object*> objects;
extern Object* player;

extern bool exclusive_mode;

extern bool switch_area;
extern char area_name[64];
extern char map_filename[64];

#endif
