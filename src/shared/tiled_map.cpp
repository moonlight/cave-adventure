/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#include "object.h"
#include "tiled_map.h"
#include "../common.h"
#include "../script.h"
#include <stdio.h>
#include <allegro.h>
#include <map>
#include <algorithm>



// Allegro DATAFILE map routines   ===========================================

void *load_tiledmapdata(PACKFILE *f, long size)
{
	void *map_data = malloc(size);
	memcpy(map_data, f, size);
	return map_data;
}

void destroy_tiledmapdata(void *data)
{
	if (data) free(data);
}


// Rectangle class ===========================================================

void Rectangle::rectToClip(BITMAP *dest)
{
	set_clip(dest, x, y, x + w - 1, y + h - 1);
}

void Rectangle::clipToRect(BITMAP *src)
{
	x = src->cl;
	y = src->ct;
	w = src->cr - src->cl + 1;
	h = src->cb - src->ct + 1;
}


// TileType ==================================================================
//  An object holding static information about a tile type.

TileType::TileType(BITMAP *tileBitmap, const char *tileName)
{
	bitmap = tileBitmap;
	name = (char*)malloc(ustrsizez(tileName));
	ustrcpy(name, tileName);
	int x, y;
	unsigned long r = 0, g = 0, b = 0;
	unsigned long pixels = tileBitmap->w * tileBitmap->h;

	// Calculate average color
	for (x = 0; x < tileBitmap->w; x++) {
		for (y = 0; y < tileBitmap->h; y++) {
			int c = getpixel(tileBitmap, x, y);
			r += getr(c);
			g += getg(c);
			b += getb(c);
		}
	}

	color = makecol(r / pixels, g / pixels, b / pixels);
}

TileType::~TileType()
{
	destroy_bitmap(bitmap);
	free(name);
}


// Tile class ================================================================

Tile::Tile()
{
	tileType = NULL;
	obstacle = 0;
}

void Tile::saveTo(PACKFILE *file)
{
	// Write tile name to file
	if (tileType) {
		pack_fputs(tileType->getName(), file);
	}
	pack_fputs("\n", file);

	pack_iputw(obstacle, file);
}

void Tile::loadFrom(PACKFILE *file, TileRepository *tileRepository)
{
	// Load tile name from file and look it up in the tile repository
	char name[32];
	pack_fgets(name, 32, file);
	setType(tileRepository->getTileType(name));

	obstacle = pack_igetw(file);
}

void Tile::setType(TileType *tileType)
{
	this->tileType = tileType;
}


// Entity sorting helper class ===============================================

bool EntityP::operator< (const EntityP& X) const {
	return (ent->pos.y + ent->pos.z < X.ent->pos.y + X.ent->pos.z);
}


// TileRepository ============================================================
//  A tile repository to handle a collection of tile types

TileRepository::~TileRepository()
{
	// Remove tile types from memory
	map<const char*, TileType*, ltstr>::iterator i;
	while (!tileTypes.empty())
	{
		i = tileTypes.begin();
		TileType* tempTileType = (*i).second;
		tileTypes.erase(i);
		delete tempTileType;
	}
}

void TileRepository::importDatafile(DATAFILE *file)
{
	if (!file) return;

	TileType *tempTileType;
	BITMAP *tempBitmap;

	// Import bitmaps from the datafile
	while (file->type != DAT_END) {
		switch (file->type) {
		case DAT_FILE:
			// Go recursively into nested datafiles
			importDatafile((DATAFILE*)file->dat);
			break;
		case DAT_BITMAP:
			// Create a new tile type and add it to the hash_map
			tempBitmap = create_bitmap(((BITMAP*)file->dat)->w, ((BITMAP*)file->dat)->h);
			blit((BITMAP*)file->dat, tempBitmap, 0, 0, 0, 0, tempBitmap->w, tempBitmap->h);

			tempTileType = new TileType(tempBitmap, get_datafile_property(file, DAT_ID('N','A','M','E')));

			tileTypes.insert(make_pair(tempTileType->getName(), tempTileType));
			break;
		}
		file++;
	}
}

void TileRepository::importBitmap(BITMAP* tileBitmap, const char* group_name, int tile_w, int tile_h, int tile_spacing)
{
	BITMAP *tempBitmap;
	TileType *tempTileType;
	char tempTilename[256];
	int x, y;

	ASSERT(tileBitmap);

	for (y = 0; y < (tileBitmap->h / (tile_h + tile_spacing)); y++)
	{
		for (x = 0; x < (tileBitmap->w / (tile_w + tile_spacing)); x++)
		{
			// Create a new tile type and add it to the hash_map
			tempBitmap = create_bitmap(tile_w, tile_h);
			blit(
				tileBitmap, tempBitmap,
				x * (tile_w + tile_spacing),
				y * (tile_h + tile_spacing),
				0, 0, tile_w, tile_h
			);

			sprintf(tempTilename, "%s%03d", group_name, y * (tileBitmap->w / tile_w) + x);

			tempTileType = new TileType(tempBitmap, tempTilename);
			tileTypes.insert(make_pair(tempTileType->getName(), tempTileType));
		}
	}
}

void TileRepository::importBitmap(const char *filename, int tile_w, int tile_h, int tile_spacing)
{
	BITMAP *tileBitmap;
	BITMAP *tempBitmap;
	TileType *tempTileType;
	char tempTilename[256];
	char tempFilename[256];
	PALETTE pal;
	int x, y;

	tileBitmap = load_bitmap(filename, pal);
	if (!tileBitmap) {
		allegro_message("Warning, %s is not a valid tile bitmap!\n", filename);
		return;
	}

	set_palette(pal);
	replace_extension(tempFilename, get_filename(filename), "", 256);

	ASSERT(tileBitmap);

	for (y = 0; y < (tileBitmap->h / (tile_h + tile_spacing)); y++)
	{
		for (x = 0; x < (tileBitmap->w / (tile_w + tile_spacing)); x++)
		{
			// Create a new tile type and add it to the hash_map
			tempBitmap = create_bitmap(tile_w, tile_h);
			blit(
				tileBitmap, tempBitmap,
				x * (tile_w + tile_spacing),
				y * (tile_h + tile_spacing),
				0, 0, tile_w, tile_h
			);

			sprintf(tempTilename, "%s%03d", tempFilename, y * (tileBitmap->w / tile_w) + x);

			tempTileType = new TileType(tempBitmap, tempTilename);
			tileTypes.insert(make_pair(tempTileType->getName(), tempTileType));
		}
	}

	destroy_bitmap(tileBitmap);
}

void TileRepository::exportBitmap(const char *filename, int tile_w, int tile_h, int tile_spacing, int tiles_in_row)
{
	list<TileType*> tiles_to_save;
	map<const char*, TileType*, ltstr>::iterator i;
	list<TileType*>::iterator j;
	char tempTilename[256];
	char tempFilename[256];
	replace_extension(tempFilename, get_filename(filename), "", 256);

	if (!(tiles_in_row > 0 && tile_w > 0 && tile_h > 0)) {
		allegro_message("WARNING: tiles_in_row (%d), tile_w (%d) and tile_h (%d) must all be larger than 0.", tiles_in_row, tile_w, tile_h);
		return;
	}

	for (i = tileTypes.begin(); i != tileTypes.end(); i++)
	{
		TileType* tempTileType = (*i).second;
		replace_extension(tempTilename, tempTileType->getName(), "", 256);
		if (ustrcmp(tempFilename, tempTilename) == 0) {
			tiles_to_save.push_back(tempTileType);
		}
	}

	if (tiles_to_save.empty()) {
		allegro_message("WARNING: No tiles to save in %s.", filename);
		return;
	}

	BITMAP *tile_bitmap;
	PALETTE pal;

	tile_bitmap = create_bitmap
	(
		tiles_in_row * tile_w,
		(tiles_to_save.size() / tiles_in_row +
		 tiles_to_save.size() % tiles_in_row) * tile_h
	);
	int x = 0;
	int y = 0;

	for (j = tiles_to_save.begin(); j != tiles_to_save.end(); j++)
	{
		blit((*j)->getBitmap(), tile_bitmap, 0, 0, x * tile_w, y * tile_h, tile_w, tile_h);
		x++;
		if (x == tiles_in_row) {
			y++;
			x = 0;
		}
	}

	get_palette(pal);
	save_bitmap(filename, tile_bitmap, pal);

	destroy_bitmap(tile_bitmap);
}

TileType* TileRepository::getTileType(const char *tileName)
{
	map<const char*, TileType*, ltstr>::iterator found = tileTypes.find(tileName);
	if (found != tileTypes.end()) {
		return (*found).second;
	} else {
		return NULL;
	}
}

vector<TileType*> TileRepository::generateTileArray()
{
	map<const char*, TileType*, ltstr>::iterator i;
	vector<TileType*> tileArray;

	for (i = tileTypes.begin(); i != tileTypes.end(); i++)
	{
		tileArray.push_back((*i).second);
	}

	return tileArray;
}


// TiledMapLayer =============================================================
//  Defines a tiled layer, used by tiled maps

TiledMapLayer::TiledMapLayer()
{
	mapWidth = 0;
	mapHeight = 0;
	tileMap = NULL;
}

TiledMapLayer::~TiledMapLayer()
{
	// Delete tiles on map
	for (int y = 0; y < mapHeight; y++)
		for (int x = 0; x < mapWidth; x++)
			delete tileMap[x + y * mapWidth];

	free(tileMap);
}

void TiledMapLayer::resizeTo(int w, int h, int dx, int dy)
{
	Tile** newTileMap = NULL;
	int x, y;
	int xn, yn;

	// Create new map
	newTileMap = (Tile**) malloc(w * h * sizeof(Tile*));
	ASSERT(newTileMap);
	for (y = 0; y < h; y++)
		for (x = 0; x < w; x++)
			newTileMap[x + y * w] = new Tile();

	// Copy old map data
	for (y = 0; y < mapHeight; y++) {
		for (x = 0; x < mapWidth; x++)
		{
			xn = x + dx;
			yn = y + dy;

			if (xn >= 0 && yn >= 0 && xn < w && yn < h)
			{
				newTileMap[xn + yn * w]->setType(tileMap[x + y * mapWidth]->getType());
				newTileMap[xn + yn * w]->obstacle = tileMap[x + y * mapWidth]->obstacle;
			}
		}
	}

	// Delete tiles on old map
	for (y = 0; y < mapHeight; y++)
		for (x = 0; x < mapWidth; x++)
			delete tileMap[x + y * mapWidth];

	free(tileMap);
	tileMap = newTileMap;
	mapWidth = w;
	mapHeight = h;
}

void TiledMapLayer::saveTo(PACKFILE *file)
{
	ASSERT(file);

	// The layer header
	pack_iputw(mapWidth, file);
	pack_iputw(mapHeight, file);

	// The tile data
	for (int y = 0; y < mapHeight; y++)
		for (int x = 0; x < mapWidth; x++)
			getTile(Point(x,y))->saveTo(file);
}

void TiledMapLayer::loadFrom(PACKFILE *file, TileRepository *tileRepository)
{
	ASSERT(file);

	// Load the map header
	int w = pack_igetw(file);
	int h = pack_igetw(file);
	resizeTo(w, h);

	// Load the tile data
	for (int y = 0; y < mapHeight; y++)
		for (int x = 0; x < mapWidth; x++)
			getTile(Point(x,y))->loadFrom(file, tileRepository);
}

Tile *TiledMapLayer::getTile(Point tile)
{
	if (tile.x < 0 || tile.x >= mapWidth ||
		tile.y < 0 || tile.y >= mapHeight)
	{
		return NULL;
	}
	else
	{
		return tileMap[tile.x + tile.y * mapWidth];
	}
}


// TiledMap class ============================================================
//  Defines a generic tiled map interface and data model.

TiledMap::TiledMap():
	nrLayers(2),
	mapWidth(0),
	mapHeight(0)
{
	mapLayers[0] = new TiledMapLayer();
	mapLayers[1] = new TiledMapLayer();
}

TiledMap::~TiledMap()
{
	// Delete the layers
	for (int i = 0; i < nrLayers; i++) {
		if (mapLayers[i]) {
			delete mapLayers[i];
			mapLayers[i] = NULL;
		}
	}

	// Delete the objects
	list<Object*>::iterator i;
	while (!objects.empty()) {
		i = objects.begin();
		delete (*i);
		objects.erase(i);
	}
}

void TiledMap::setCamera(Point cam, Rectangle rect, bool center, bool modify)
{
	if (center) {
		cam.x -= rect.w / 2;
		cam.y -= rect.h / 2;
	}
	if (modify) {
		Point mapSize = getMapSize();
		cam.x = MAX(0, MIN(mapSize.x - rect.w, cam.x));
		cam.y = MAX(0, MIN(mapSize.y - rect.h, cam.y));
	}
	
	cameraCoords = cam;
	cameraScreenRect = rect;
}

void TiledMap::resizeTo(int w, int h, int dx, int dy)
{
	mapLayers[0]->resizeTo(w, h, dx, dy);
	mapLayers[1]->resizeTo(w, h, dx, dy);
	mapWidth = w;
	mapHeight = h;
}

void TiledMap::saveTo(PACKFILE *file)
{
	ASSERT(file);

	// Version info
	// Version 1: No version number stored, one layer in map
	// Version 2: First int is version number, second one the number of layers
	// Version 3: Object list stored at end of tile data.
	pack_iputw(3, file);
	// The map header
	pack_iputw(nrLayers, file);

	// The tile data
	for (int i = 0; i < nrLayers; i++) {
		mapLayers[i]->saveTo(file);
	}

	// Object data
	list<Object*>::iterator i;
	pack_iputw(objects.size(), file);
	for (i = objects.begin(); i != objects.end(); i++) {
		pack_iputw(int(TILES_W * (*i)->x), file);
		pack_iputw(int(TILES_H * (*i)->y), file);
		pack_fputs((*i)->className, file);
		pack_fputs("\n", file);
	}	

	// Extra newline fixes last tile not loaded.
	pack_fputs("\n", file);
}

int TiledMap::loadMap(const char* mapName)
{
	char tempstr[256] = "";
	usprintf(tempstr, "%s", mapName);

	PACKFILE *file = pack_fopen(tempstr, F_READ_PACKED);
	this->loadFrom(file, tileRepository);
	pack_fclose(file);
	return 0;
}

void TiledMap::loadFrom(PACKFILE *file, TileRepository *tileRepository)
{
	ASSERT(file);

	// Remove the objects from the map
	list<Object*>::iterator i;
	while (!objects.empty())
	{
		i = objects.begin();
		delete (*i);
		objects.erase(i);
	}

	// Load the map header
	int version = pack_igetw(file);
	int layers = pack_igetw(file);

	// Load the tile data
	//allegro_message("Loading %d layers from map version %d", layers, version);
	for (int i = 0; i < layers; i++) {
		mapLayers[i]->loadFrom(file, tileRepository);
	}

	// Load object data
	if (version == 3) {
		int nrObjects = pack_igetw(file);

		for (int i = 0; i < nrObjects; i++) {
			int x = pack_igetw(file); //int(TILES_W * (*i)->x), file);
			int y = pack_igetw(file); //pack_iputw(int(TILES_H * (*i)->y), file);
			char *className = new char[64];
			int objectInstance = 0;
			pack_fgets(className, 64, file);

			// Spawn the object
			// Assumes Lua environment is set up and such of course
			lua_pushstring(L, className);
			lua_gettable(L, LUA_GLOBALSINDEX);
			if (!lua_isnil(L, -1)) {
				lua_call(L, putLuaArguments(L, "m", this), 1);
				if (lua_istable(L, -1)) {
					objectInstance = lua_ref(L, -1);
				} else {
					console.log(CON_QUIT, CON_ALWAYS, "Error while instaniating object \"%s\"", className);
				}
			} else {
				console.log(CON_QUIT, CON_ALWAYS, "Error: could not find object class \"%s\"", className);
			}
			
			lua_getref(L, objectInstance);
			lua_pushstring(L, "_pointer");
			lua_gettable(L, -2);
			Object* obj = (Object*)lua_touserdata(L, -1);
			obj->x = (double(x) / TILES_W);
			obj->y = (double(y) / TILES_H);
			obj->className = className; // Assign class name (maybe not the best place for this)
			lua_pop(L, 1);
		}
	}

	mapWidth = mapLayers[0]->getWidth();
	mapHeight = mapLayers[0]->getHeight();
}

void TiledMap::loadFromOld(PACKFILE *file, TileRepository *tileRepository)
{
	ASSERT(file);

	// Remove the objects from the map
	list<Object*>::iterator i;
	while (!objects.empty())
	{
		i = objects.begin();
		delete (*i);
		objects.erase(i);
	}

	// Load the map header
	/*int version = 1;*/
	int layers = 1;

	// Load the tile data
	//allegro_message("Loading %d layers from map version %d", layers, version);
	for (int i = 0; i < layers; i++) {
		mapLayers[i]->loadFrom(file, tileRepository);
	}

	mapWidth = mapLayers[0]->getWidth();
	mapHeight = mapLayers[0]->getHeight();

	mapLayers[1]->resizeTo(0, 0, 0, 0);
	mapLayers[1]->resizeTo(mapWidth, mapHeight, 0, 0);
}

TiledMapLayer *TiledMap::getLayer(int i)
{
	if (i < 0 || i >= nrLayers) {
		return NULL;
	}
	else {
		return mapLayers[i];
	}
}

Object* TiledMap::addObject(int x, int y, const char* type)
{
	console.log(CON_LOG, CON_VDEBUG, "Adding object of type \"%s\"...", type);

	lua_getglobal(L, type);
	if (!lua_istable(L, -1)) {
		console.log(CON_LOG | CON_CONSOLE, CON_ALWAYS, "Error: object type \"%s\" not defined.", type);
	}
	lua_pop(L, 1);

	lua_newtable(L);
	Object* newObject = new Object(lua_ref(L, 1), this);
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

void TiledMap::removeReference(Object* obj)
{
	if (obj) objects.remove(obj);
}

void TiledMap::addReference(Object* obj)
{
	if (obj) objects.push_back(obj);
}

Object* TiledMap::registerObject(int tableRef)
{
	console.log(CON_LOG, CON_VDEBUG, "Registering object.");
	Object* newObject = new Object(tableRef, this);
	
	objects.push_back(newObject);
	newObject->initialize();

	return newObject;
}


void TiledMap::drawEntities(BITMAP *dest)
{
	list<EntityP> visibleEnts;
	list<Object*>::iterator i;
	list<EntityP>::iterator j;

	for (i = objects.begin(); i != objects.end(); i++)
	{
		if (!(*i)->in_air && (*i)->visible(dest, mapToScreen((*i)->pos)))
		{
			visibleEnts.push_back(EntityP((*i)));
		}
	}

	// Sort the visible entities on y value.
	visibleEnts.sort();

	for (j = visibleEnts.begin(); j != visibleEnts.end(); j++) {
		(*j).ent->draw(dest, mapToScreen((*j).ent->pos));
	}

	if (debug_mode) {
		textprintf(dest, font, cameraScreenRect.x + 10, cameraScreenRect.y + 10, makecol(200,200,200), "%i entities", objects.size());
		textprintf(dest, font, cameraScreenRect.x + 10, cameraScreenRect.y + 20, makecol(200,200,200), "%i drawn entities", visibleEnts.size());
	}
}

void TiledMap::drawAirborneEntities(BITMAP *dest)
{
	list<EntityP> visibleEnts;
	list<Object*>::iterator i;
	list<EntityP>::iterator j;

	for (i = objects.begin(); i != objects.end(); i++)
	{
		if ((*i)->in_air && (*i)->visible(dest, mapToScreen((*i)->pos)))
		{
			visibleEnts.push_back(EntityP((*i)));
		}
	}

	// Sort the visible entities on y value.
	visibleEnts.sort();

	for (j = visibleEnts.begin(); j != visibleEnts.end(); j++) {
		(*j).ent->draw(dest, mapToScreen((*j).ent->pos));
	}

	if (debug_mode) {
		textprintf(dest, font, cameraScreenRect.x + 10, cameraScreenRect.y + 10, makecol(200,200,200), "%i entities", objects.size());
		textprintf(dest, font, cameraScreenRect.x + 10, cameraScreenRect.y + 20, makecol(200,200,200), "%i drawn entities", visibleEnts.size());
	}
}

void TiledMap::updateObjects()
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


Point TiledMap::screenToTile(Point screenCoords)
{
	return mapToTile(screenToMap(screenCoords));
}

Point TiledMap::tileToScreen(Point tileCoords)
{
	return mapToScreen(tileToMap(tileCoords));
}


// SquareMap class ===========================================================
//  Provides algorithms for simple square-tiled maps

SquareMap::SquareMap(int tileSize)
{
	this->tileWidth = tileSize;
	this->tileHeight = tileSize;
	setCamera(
		Point(0,0),
		Rectangle(0, 0, buffer->w, buffer->h),
		false, false
	);
}

SquareMap::SquareMap(int tileWidth, int tileHeight)
{
	this->tileWidth = tileWidth;
	this->tileHeight = tileHeight;
	setCamera(
		Point(0,0),
		Rectangle(0, 0, buffer->w, buffer->h),
		false, false
	);
}

void SquareMap::draw(BITMAP *dest, bool drawObstacle)
{
	Rectangle oldClip;
	oldClip.clipToRect(dest);
	cameraScreenRect.rectToClip(dest);

	if (mapLayers[0]) drawLayer(dest, drawObstacle, mapLayers[0]);
	drawEntities(dest);
	if (mapLayers[1]) drawLayer(dest, drawObstacle, mapLayers[1]);
	drawAirborneEntities(dest);

	oldClip.rectToClip(dest);
}

void SquareMap::drawLayer(BITMAP *dest, bool drawObstacle, TiledMapLayer *layer, int opacity)
{
	Rectangle oldClip;
	TileType *tempTileType;
	Tile* tempTile;

	oldClip.clipToRect(dest);
	cameraScreenRect.rectToClip(dest);

	// Calculate the part of the map that needs to be drawn (visible part)
	Point start = screenToTile(Point(cameraScreenRect.x, cameraScreenRect.y));
	Point end = screenToTile(Point(cameraScreenRect.x + cameraScreenRect.w - 1, cameraScreenRect.y + cameraScreenRect.h - 1));

	start.x = MAX(0, MIN(mapWidth  - 1, start.x));
	start.y = MAX(0, MIN(mapHeight - 1, start.y));

	if (opacity < 255) {
		set_trans_blender(0,0,0,opacity);
		drawing_mode(DRAW_MODE_TRANS, NULL, 0, 0);
	}

	for (int y = start.y; y <= end.y; y++) {
		for (int x = start.x; x <= end.x; x++) {
			tempTile = layer->getTile(Point(x, y));
			tempTileType = tempTile->getType();
			if (tempTileType) {
				if (opacity < 255) {
					draw_trans_sprite(
						dest,
						tempTileType->getBitmap(),
						cameraScreenRect.x - cameraCoords.x + x * tileWidth,
						cameraScreenRect.y - cameraCoords.y + y * tileHeight
					);
				}
				else {
					draw_sprite(
						dest,
						tempTileType->getBitmap(),
						cameraScreenRect.x - cameraCoords.x + x * tileWidth,
						cameraScreenRect.y - cameraCoords.y + y * tileHeight
					);
				}
			}
			if (drawObstacle) {
				int tx = cameraScreenRect.x - cameraCoords.x + x * tileWidth;
				int ty = cameraScreenRect.y - cameraCoords.y + y * tileHeight;
				int tw = tileWidth;
				int th = tileHeight;
				int to = tempTile->obstacle;
				
				if (to & OB_TOP) {
					line(dest, tx + 2,      ty + 2,      tx + tw - 3, ty + 2,      makecol(255,0,0));
					line(dest, tx + 3,      ty + 3,      tx + tw - 2, ty + 3,      makecol(0,0,0));
				}
				if (to & OB_LEFT) {
					line(dest, tx + 2,      ty + 2,      tx + 2,      ty + th - 3, makecol(255,0,0));
					line(dest, tx + 3,      ty + 3,      tx + 3,      ty + th - 2, makecol(0,0,0));
				}
				if (to & OB_RIGHT) {
					line(dest, tx + tw - 3, ty + 2,      tx + tw - 3, ty + th - 3, makecol(255,0,0));
					line(dest, tx + tw - 2, ty + 3,      tx + tw - 2, ty + th - 2, makecol(0,0,0));
				}
				if (to & OB_BOTTOM) {
					line(dest, tx + 2,      ty + th - 3, tx + tw - 3, ty + th - 3, makecol(255,0,0));
					line(dest, tx + 3,      ty + th - 2, tx + tw - 2, ty + th - 2, makecol(0,0,0));
				}
			}
		}
	}

	if (opacity < 255) {
		drawing_mode(DRAW_MODE_SOLID, NULL, 0, 0);
	}

	oldClip.rectToClip(dest);
}

Point SquareMap::screenToMap(Point screenCoords)
{
	return Point(
		cameraCoords.x - cameraScreenRect.x + screenCoords.x,
		cameraCoords.y - cameraScreenRect.y + screenCoords.y,
		screenCoords.z
	);
}

Point SquareMap::mapToScreen(Point mapCoords)
{
	return Point(
		cameraScreenRect.x - cameraCoords.x + mapCoords.x,
		cameraScreenRect.y - cameraCoords.y + mapCoords.y,
		mapCoords.z
	);
}

Point SquareMap::mapToTile(Point mapCoords)
{
	return Point(
		MIN(mapWidth - 1, MAX(0, mapCoords.x / tileWidth)),
		MIN(mapHeight - 1, MAX(0, mapCoords.y / tileHeight)),
		mapCoords.z
	);
}

Point SquareMap::tileToMap(Point tileCoords)
{
	return Point(
		(tileCoords.x + 1) * tileWidth - tileWidth / 2,
		(tileCoords.y + 1) * tileHeight,
		tileCoords.z
	);
}

Point SquareMap::getMapSize()
{
	return Point(
		tileWidth  * mapWidth,
		tileHeight * mapHeight
	);
}


// IsometricMap class ========================================================
//  Provides algorithms for isometric-tiled maps
/*
IsometricMap::IsometricMap(int tileStepX, int tileStepY)
{
	this->tileGridSize = tileStepX;
	this->tileStepX = tileStepX;
	this->tileStepY = tileStepY;
}

void IsometricMap::draw(BITMAP *dest, bool drawObstacle)
{
	if (tileMap == NULL) return;

	Rectangle oldClip;
	Tile *tempTile;
	TileType *tempTileType;
	Point temp, temp2, area;

	oldClip.clipToRect(dest);
	cameraScreenRect.rectToClip(dest);

	temp = screenToTile(Point(cameraScreenRect.x, cameraScreenRect.y));
	area = Point(cameraScreenRect.w / (tileStepX * 2) + 3, cameraScreenRect.h / tileStepY + 3);

	// Move up one row
	temp.x--;

	for (int y = 0; y < area.y; y++) {
		// Initialize temp2 to draw a horizontal line of tiles
		temp2 = temp;

		for (int x = 0; x < area.x; x++) {
			// Check if we are drawing a valid tile
			tempTile = getTile(temp2);
			if (tempTile) {
				tempTileType = tempTile->getType();
			} else {
				tempTileType = NULL;
			}

			// Draw the tile if valid
			if (tempTileType) {
				draw_sprite(
					dest,
					tempTileType->getBitmap(),
					cameraScreenRect.x - cameraCoords.x + (temp2.x - temp2.y - 1) * tileStepX + mapHeight * tileStepX,
					cameraScreenRect.y - cameraCoords.y + (temp2.x + temp2.y    ) * tileStepY
				);
			}

			// Advance to the next tile (to the right)
			temp2.x++; temp2.y--;
		}

		// Advance to the next row
		if ((y & 1) > 0) temp.x++; else temp.y++;
	}

	// Draw a red line along the edges of the map
	//Point top    = mapToScreen(Point(-1,                      0));
	//Point right  = mapToScreen(Point(tileGridSize * mapWidth, 0));
	//Point bottom = mapToScreen(Point(tileGridSize * mapWidth, tileGridSize * mapHeight + 1));
	//Point left   = mapToScreen(Point(-1,                      tileGridSize * mapHeight + 1));
	//line(dest, top.x,    top.y,    right.x,  right.y,  makecol(255,0,0));
	//line(dest, right.x,  right.y,  bottom.x, bottom.y, makecol(255,0,0));
	//line(dest, bottom.x, bottom.y, left.x,   left.y,   makecol(255,0,0));
	//line(dest, left.x,   left.y,   top.x,    top.y,    makecol(255,0,0));

	// Now draw the entities
	drawEntities(dest);

	oldClip.rectToClip(dest);
}

Point IsometricMap::screenToMap(Point screenCoords)
{
	screenCoords.x = screenCoords.x + cameraCoords.x - cameraScreenRect.x - mapHeight * tileStepX;
	screenCoords.y = screenCoords.y + cameraCoords.y - cameraScreenRect.y;
	return Point(
		screenCoords.y + screenCoords.x / 2,
		screenCoords.y - screenCoords.x / 2,
		screenCoords.z
	);
}

Point IsometricMap::mapToScreen(Point mapCoords)
{
	return Point(
		cameraScreenRect.x - cameraCoords.x + (mapCoords.x - mapCoords.y) + mapHeight * tileStepX,
		cameraScreenRect.y - cameraCoords.y + (mapCoords.x + mapCoords.y) / 2,
		mapCoords.z
	);
}

Point IsometricMap::mapToTile(Point mapCoords)
{
	return Point(
		(mapCoords.x < 0) ? mapCoords.x / tileGridSize - 1 : mapCoords.x / tileGridSize,
		(mapCoords.y < 0) ? mapCoords.y / tileGridSize - 1 : mapCoords.y / tileGridSize,
		mapCoords.z
	);
}

Point IsometricMap::tileToMap(Point tileCoords)
{
	return Point(
		(tileCoords.x + 1) * tileGridSize,
		(tileCoords.y + 1) * tileGridSize,
		tileCoords.z
	);
}

Point IsometricMap::getMapSize()
{
	return Point(
		tileStepX * (mapWidth + mapHeight),
		tileStepY * (mapWidth + mapHeight)
	);
}
*/
