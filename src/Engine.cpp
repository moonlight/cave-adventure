/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#include <allegro.h>
#include <time.h>
#include <list>
#include "Console.h"
#include "TiledMap.h"
#include "Engine.h"
#include "RPG.h"
#include "Script.h"
#include "Canvas.h"

using namespace std;

list<Object*> objects;

bool exclusive_mode = false;

Object* player = NULL;

bool switch_area = false;
char area_name[64];
char map_filename[64];


//===================   Object   =====================================================

const char Object::className[16] = "Object";
int Object::id_counter = 0;

Object::Object(int luaTableRef):
	walking(0), speed(0), dir(0), prev_dir(0),
	count(0), tick(0),
	bitmap(NULL),
	x(0), y(0), w(1), h(1), obstacle(0),
	offset_x(0), offset_y(0), offset_z(0),
	_destroy(0),
	tableRef(luaTableRef),
	travel(0)
{
	id = ++id_counter;

	// Create my entity and put it on the map
	entity = new Entity();
	entity->pos = tiledMap->tileToMap(Point(x,y));
	tiledMap->addEntity(entity);

	// Set the metatable and _pointer value of my table in Lua
	lua_getref(L, tableRef);
	lua_getglobal(L, "ObjectMetatable");
	lua_setmetatable(L, -2);
	lua_pushstring(L, "_pointer" );
	lua_pushlightuserdata(L, this);
	lua_rawset(L, -3);
	lua_pop(L, 1);
}

Object::Object(lua_State *L):
	walking(0), speed(0), dir(0), prev_dir(0),
	count(0), tick(0),
	bitmap(NULL),
	x(0), y(0), w(1), h(1), obstacle(0),
	offset_x(0), offset_y(0), offset_z(0),
	_destroy(0),
	tableRef(0),
	travel(0)
{
	id = ++id_counter;

	// Create my entity and put it on the map
	entity = new Entity();
	entity->pos = tiledMap->tileToMap(Point(x,y));
	tiledMap->addEntity(entity);

	//Lunar<Object>::call(L, this, "event_init");
	update_entity();
}


Object::~Object()
{
	if (tableRef != 0) {
		// Notify the object that it is being destroyed
		callMemberFunction(tableRef, "event_destroyed");

		// Set the reference to the C++ object to NULL in the Lua table
		lua_getref(L, tableRef);         // 1
		lua_pushstring(L, "_pointer");   // 2
		lua_pushlightuserdata(L, NULL);  // 3
		lua_rawset(L, -3);               // 1
		lua_pop(L, 1);                   // 0

		// Allow Lua to garbage collect the object.
		lua_unref(L, tableRef);
	}

	if (entity != NULL) {
		// Remove the entity from the map and delete it.
		tiledMap->removeEntity(entity);
		delete entity;
		entity = NULL;
	}
}

void Object::walk(int dir)
{
	if (walking == 0)
	{
		set_dir(dir);
		update_entity();

		// Precalculate where the player is going
		int next_x = x, next_y = y;
		switch (dir) {
		case DIR_UP:    next_y -= 1; break;
		case DIR_DOWN:  next_y += 1; break;
		case DIR_LEFT:  next_x -= 1; break;
		case DIR_RIGHT: next_x += 1; break;
		}

		// Check for map obstacle
		Tile *nextTile = tiledMap->getLayer(0)->getTile(Point(next_x, next_y));
		if (!nextTile || 
			(dir == DIR_UP    && (nextTile->obstacle & OB_BOTTOM)) ||
			(dir == DIR_DOWN  && (nextTile->obstacle & OB_TOP)) ||
			(dir == DIR_LEFT  && (nextTile->obstacle & OB_RIGHT)) ||
			(dir == DIR_RIGHT && (nextTile->obstacle & OB_LEFT)))
		{
			callMemberFunction(tableRef, "event_bump_into");
			check_stand_on();
			return;
		}

		// Check for object in the way
		list<Object*>::iterator i;
		for (i = objects.begin(); i != objects.end(); i++) {
			Object *obj = (*i);
			if ((obstacle) &&
				(obj->obstacle) &&
				(obj->x + obj->w > next_x && obj->x <= next_x) &&
				(obj->y - obj->h < next_y && obj->y >= next_y))
			{
				callMemberFunction(tableRef, "event_bump_into", "o", obj);
				callMemberFunction(obj->tableRef, "event_bumped_into", "o", this);
				check_stand_on();
				return;
			}
		}

		// No obstacles, so start walking
		walking = 100;
		x = next_x;
		y = next_y;
		callMemberFunction(tableRef, "event_walk_start");
	}
}

void Object::walk_nocol(int dir)
{
	if (walking == 0)
	{
		set_dir(dir);

		// Precalculate where the player is going
		int next_x = x, next_y = y;
		switch (dir) {
		case DIR_UP:    next_y -= 1; break;
		case DIR_DOWN:  next_y += 1; break;
		case DIR_LEFT:  next_x -= 1; break;
		case DIR_RIGHT: next_x += 1; break;
		}

		// No obstacles, so start walking
		walking = 100;
		x = next_x;
		y = next_y;
		callMemberFunction(tableRef, "event_walk_start");
	}
}

void Object::set_dir(int dir)
{
	if (this->dir != dir) {
		this->dir = dir;
		callMemberFunction(tableRef, "event_dir_change");
	}
}

void Object::check_stand_on()
{
	// Check if this object is now standing on something

	list<Object*>::iterator i;
	for (i = objects.begin(); i != objects.end(); i++) {
		Object *obj = (*i);
		if ((obj != this) &&
			(obj->x + obj->w > x && obj->x <= x) &&
			(obj->y - obj->h < y && obj->y >= y))
		{
			callMemberFunction(tableRef, "event_standing_on", "o", obj);
			callMemberFunction(obj->tableRef, "event_stand_on", "o", this);
		}
	}
}

void Object::initialize()
{
	callMemberFunction(tableRef, "event_init");
	update_entity();
}

void Object::update()
{
	if (walking > 0) {
		walking -= speed;

		if (walking <= 0) {
			if (walking < 0) walking = 0;
			callMemberFunction(tableRef, "event_walk_finished");
			// Check if this object is now standing on something
			check_stand_on();
		}
	}

	if (tick > 0) {
		count++;
		if (count >= tick) {
			// Call script "tick" function
			callMemberFunction(tableRef, "event_tick");
			count = 0;
		}
	} else {
		count = 0;
	}

	if (dir != prev_dir) {
		prev_dir = dir;
		callMemberFunction(tableRef, "event_dir_change");
	}

	// Updating the entities should only be done when the
	// map is going to be drawn.
	update_entity();
}

void Object::update_entity()
{
	if (entity->bitmap) {
		destroy_bitmap(entity->bitmap);
		entity->bitmap = NULL;
	}

	if (bitmap) {
		entity->bitmap = create_sub_bitmap(bitmap, 0, 0, bitmap->w, bitmap->h);
	}

	mapPos = tiledMap->tileToMap(Point(x,y));
	if (walking > 0) {
		switch (dir) {
		case DIR_UP:    offset_y = -6+(TILES_H * walking) / 100; break;
		case DIR_DOWN:  offset_y = -6-(TILES_H * walking) / 100; break;
		case DIR_LEFT:  offset_x = (TILES_W * walking) / 100; break;
		case DIR_RIGHT: offset_x = -(TILES_W * walking) / 100; break;
		}
	}

	mapPos.x += offset_x;
	mapPos.y += offset_y;
	mapPos.z += offset_z;

	entity->pos = mapPos;
}

int Object::walk(lua_State *L)
{
	lua_settop(L, 2);
	int dir = luaL_checknumber(L, 1);
	if (!lua_isnumber(L, 2) || !lua_tonumber(L, 2)) {
		walk_nocol(dir);
	} else {
		walk(dir);
	}
	return 0;
}

int Object::subclass(lua_State *L)
{
	allegro_message("subclass called!");
	lua_settop(L, 1);
	if (!lua_istable(L, 1)) {
		lua_newtable(L);
		lua_replace(L, 1);
	}
	lua_getmetatable(L, 1);
	lua_pushstring(L, "__index");
	lua_getref(L, tableRef);
	lua_settable(L, -3);
	lua_pop(L, 1);
	return 1;
}



Lunar<Object>::RegType Object::methods[] = {
  method(Object, destroy),
  method(Object, walk),
  //method(Object, subclass),
  {0,0}
};

Lunar<Object>::RegType Object::getters[] = {
  member(Object, id,       getid),
  member(Object, x,        getx),
  member(Object, y,        gety),
  member(Object, w,        getw),
  member(Object, h,        geth),
  member(Object, offset_x, getoffset_x),
  member(Object, offset_y, getoffset_y),
  member(Object, offset_z, getoffset_z),
  member(Object, travel,   gettravel),
  member(Object, speed,    getspeed),
  member(Object, tick,     gettick),
  member(Object, obstacle, getobstacle),
  member(Object, bitmap,   getbitmap),
  {0,0}
};

Lunar<Object>::RegType Object::setters[] = {
  member(Object, x,        setx),
  member(Object, y,        sety),
  member(Object, w,        setw),
  member(Object, h,        seth),
  member(Object, offset_x, setoffset_x),
  member(Object, offset_y, setoffset_y),
  member(Object, offset_z, setoffset_z),
  member(Object, travel,   settravel),
  member(Object, speed,    setspeed),
  member(Object, tick,     settick),
  member(Object, obstacle, setobstacle),
  member(Object, bitmap,   setbitmap),
  {0,0}
};


//===================   Engine functions   ===========================================

void update_objects()
{
	list<Object*>::iterator i;

	// Destroy all objects at the beginning of the object map
	// that should be destroyed
	while (!objects.empty() && (*objects.begin())->_destroy)
	{
		i = objects.begin();

		delete (*i);
		objects.erase(i);
	}

	// Iterate through all objects, destroying the dead and updating the others.
	for (i = objects.begin(); i != objects.end(); i++)
	{
		if ((*i)->_destroy)
		{
			//console.log(CON_CONSOLE, CON_DEBUG, "Destroying object at (%d, %d)", (*i)->x, (*i)->y);
			list<Object*>::iterator i2 = i;

			// We can safely iterate one back because the first object never needs to
			// be destroyed.
			i--;

			delete (*i2);
			objects.erase(i2);
		}
		else
		{
			(*i)->update();
		}
	}
}

void switch_area_now()
{
	if (!switch_area) return;
	switch_area = false;

	console.log(CON_CONSOLE | CON_LOG, CON_DEBUG, "Switching to area \"%s\".", area_name);

	// Get rid of all the objects and the previous map
	list<Object*> travelObjects;
	list<Object*>::iterator i;
	while (!objects.empty())
	{
		i = objects.begin();
		Object* temp = (*i);
		objects.erase(i);

		if (temp->travel) {
			// This object is allowed to travel to other areas, so put it in the
			// travelObjects list.
			travelObjects.push_front(temp);
		} else {
			// This object is not allowed to travel to other areas, so delete it
			// when a new area is loaded.
			delete temp;
		}
	}

	// Load the new area map
	char tempstr[256] = "";
	usprintf(tempstr, "%s", area_name);

	PACKFILE *file = pack_fopen(tempstr, F_READ_PACKED);
	tiledMap->loadFrom(file, tileRepository);
	pack_fclose(file);

	/*
	DATAFILE *found_object = find_datafile_object(bitmap_data, area_name);

	if (found_object) {
		tiledMap->loadFrom((PACKFILE*)found_object->dat, tileRepository);
	} else {
		console.log(CON_QUIT, CON_DEBUG, "Error: Cannot find a map called \"%s\"", area_name);
	}
	*/

	// Make the objects list the list of objects that have travelled to this
	// new map.
	objects = travelObjects;

	// Execute the map script
	callFunction("event_load_map", "s", area_name);
}


//===================   Script functions   ===========================================

void import_tile_bmp(const char* filename, int tiles_w, int tiles_h, int tile_spacing)
{
	console.log(CON_CONSOLE, CON_DEBUG, "Importing tile bitmap \"%s\"...", filename);

	PALETTE pal;
	BITMAP* tileBitmap;
	char tempFilename[256];
	DATAFILE *found_object = find_datafile_object(bitmap_data, filename);

	if (found_object) {
		tileBitmap = (BITMAP*)found_object->dat;
		if (tileBitmap) {
			replace_extension(tempFilename, get_filename(filename), "", 256);
			tileRepository->importBitmap(tileBitmap, tempFilename, tiles_w, tiles_h, tile_spacing);
		} else {
			console.log(CON_QUIT, CON_ALWAYS, "Error: failed loading tile bitmap: \"%s\"", filename);
		}
	} else {
		console.log(CON_QUIT, CON_ALWAYS, "Error: file for tile bitmap not found: \"%s\"", filename);
	}


	/*
	console.log(CON_CONSOLE, CON_DEBUG, "Importing tile bitmap \"%s\"...", filename);

	PALETTE pal;
	BITMAP* tileBitmap;
	char tempFilename[256];

	if (exists(filename)) {
		tileBitmap = load_bitmap(filename, pal);
		if (tileBitmap) {
			replace_extension(tempFilename, get_filename(filename), "", 256);
			tileRepository->importBitmap(tileBitmap, tempFilename, tiles_w, tiles_h, tile_spacing);
			destroy_bitmap(tileBitmap);
		} else {
			console.log(CON_QUIT, CON_ALWAYS, "Error: failed loading tile bitmap: \"%s\"", filename);
		}
	} else {
		console.log(CON_QUIT, CON_ALWAYS, "Error: file for tile bitmap not found: \"%s\"", filename);
	}
	*/
}

// Exclusive functions (no scripts called while executing!)

void ex_walk(Object* obj, int dir, int dist)
{
	exclusive_mode = true;

	int dist_walked = 0;
	while (dist_walked < dist) {
		if (obj->walking == 0) {
			dist_walked++;
			obj->walk_nocol(dir);
		}
		ex_update_game(obj);
	}
	while (obj->walking) ex_update_game(obj);

	exclusive_mode = false;
}

void ex_wait(int updates)
{
	exclusive_mode = true;
	frames_to_do = 0;

	int waited = 0;
	while (waited < updates) {
		while (frames_to_do == 0) {;}
		ex_update_game(NULL);
		waited++;
	}

	exclusive_mode = false;
}





// Object manipulation

Object* add_object(int x, int y, const char* type)
{
	console.log(CON_LOG, CON_VDEBUG, "Adding object of type \"%s\"...", type);

	lua_getglobal(L, type);
	if (!lua_istable(L, -1)) {
		console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Error: object type \"%s\" not defined.", type);
	}
	lua_pop(L, 1);

	lua_newtable(L);
	Object* newObject = new Object(lua_ref(L, 1));
	newObject->x = x;
	newObject->y = y;
	
	lua_getglobal(L, "inherit");
	lua_getref(L, newObject->tableRef);
	lua_getglobal(L, type);
	if (lua_istable(L, -1)) {
		lua_call(L, 2, 0);
	}

	objects.push_back(newObject);
	newObject->initialize();

	return newObject;
}

Object* register_object(int tableRef)
{
	console.log(CON_LOG, CON_VDEBUG, "Registering object.");
	Object* newObject = new Object(tableRef);
	
	objects.push_back(newObject);
	newObject->initialize();

	return newObject;
}


int l_set_player(lua_State *L)
{
	Object *new_player;
	getLuaArguments(L, "o", &new_player);
	player = new_player;
	return 0;
}

int l_get_player(lua_State *L)
{
	lua_settop(L, 0);
	lua_getref(L, player->tableRef);
	return 1;
}


// Retrieving resources

int l_get_bitmap(lua_State *L)
{
	const char *name;
	BITMAP* found_bitmap = NULL;
	getLuaArguments(L, "s", &name);
	char tmp[256];

	DATAFILE *found_object = find_datafile_object(bitmap_data, name);

	if (found_object) {
		found_bitmap = (BITMAP*)found_object->dat;
		return putLuaArguments(L, "b", found_bitmap);
	} else {
		sprintf(tmp, "Error: Cannot find requested bitmap (%s)!", name);
		lua_pushstring(L, tmp);
		lua_error(L);
		return 0;
	}
}

int l_create_sub_bitmap(lua_State *L)
{
	BITMAP* parent;
	BITMAP* sub_bitmap;
	int x, y, w, h;
	getLuaArguments(L, "biiii", &parent, &x, &y, &w, &h);

	if (!parent) {
		lua_pushstring(L, "Error: No bitmap passed to function!");
		lua_error(L);
	}
	if (x < 0 || y < 0 || x >= parent->w || y >= parent->h) {
		console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Warning: Creating subbitmap failed, invalid origin (%d, %d)", x, y);
		return 0;
	}

	sub_bitmap = create_sub_bitmap(parent, x, y, w, h);

	return putLuaArguments(L, "b", sub_bitmap);
}



// Switching to another level

int l_load_map(lua_State *L)
{
	const char *new_map_name;
	getLuaArguments(L, "s", &new_map_name);

	if (exists(new_map_name)) {
		console.log(CON_LOG, CON_DEBUG, "Preparing switch to area \"%s\"...", new_map_name);
		strncpy(area_name, new_map_name, 64);
		switch_area = true;
	} else {
		console.log(CON_LOG, CON_ALWAYS, "Warning: Attempt to switch to non-existing map (%s)!", new_map_name);
		allegro_message("Warning: Attempt to switch to non-existing map (%s)!", new_map_name);
	}

	return 0;
}


// Drawing viewports

int l_draw_viewport(lua_State *L)
{
	int x, y, w, h;
	Object *target;

	getLuaArguments(L, "iiiio", &x, &y, &w, &h, &target);

	canvas.drawViewport(x, y, w, h, target);

	return 0;
}


int l_quit_game(lua_State *L)
{
	quit_game();
	return 0;
}


void quit_game()
{
	game_end = true;
}