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
#include "gui_procs.h"
#include "editor.h"
#include "../shared/tiled_map.h"
#include "script.h"
#include "../shared/engine.h"
#include "../shared/object.h"
#include "../common.h"


float brightness = 0.7;


int d_new_bjorn_scroll_proc(int msg, DIALOG *d, int c)
{
	DIALOG* sd = (DIALOG*)d->dp;
	int sdw, sdh, offset_x, offset_y, vsb, hsb;

	if (sd) {
		sdw = sd->d1;		// Scrolling dialog wanted width
		sdh = sd->d2;		// Scrolling dialog wanted height
		offset_x = d->d1;	// Horizontal scrolling offset
		offset_y = d->d2;	// Vertical scrolling offset
	}
	else {
		sdw = 0;
		sdh = 0;
		offset_x = 0;
		offset_y = 0;
	}

	vsb = d->h - 4;			// Vertical scrollbar length
	hsb = d->w - 4;			// Horizontal scrollbar length

	switch (msg)
	{
	case MSG_DRAW:
		// Draw the border
		d_agup_box_proc(MSG_DRAW, d, 0);

		// Draw horizontal scrollbar
		//photon_scrollbar(buffer, d->x + 2, d->y + 2, d->w - 4, d->h - 4, 0, offset_x, len);

		// Draw vertical scrollbar
		//photon_scrollbar(buffer, d->x + 2, d->y + 2, d->w - 4, d->h - 4, 1, offset_y, len);
	}

	return D_O_K;
}


int d_bjorn_scroll_proc(int msg, DIALOG *d, int c)
{
	int size   = d->d1;
	int offset = d->d2;
	int height = ((d->flags & SCROLL_VER) ? d->h - 4 : d->w - 4);

    int pos, len, ds;

	if (d->dp) ds = (d->flags & SCROLL_VER) ? ((DIALOG*)d->dp)->h : ((DIALOG*)d->dp)->w;
	else ds = 0;

	if (d->dp && offset > 0 && size > 0 && size > ds) {
		pos = (offset * height + size / 2) / size;
	} else {
		pos = 0;
	}
	if (d->dp && size > 0 && size > ds) {
		len = (ds * height + size / 2) / size;
	} else {
		len = height;
	}

	switch (msg)
	{
	case MSG_DRAW:
		if (pos + len > height) pos = height - len;

		rect    (buffer, d->x + 1, d->y + 1, d->x + d->w - 2, d->y + d->h - 2, container_black);
		rectfill(buffer, d->x + 2, d->y + 2, d->x + d->w - 3, d->y + d->h - 3, scrollbar_gray1);
	
		photon_scrollbar(buffer, d->x + 2, d->y + 2, d->w - 4, d->h - 4, d->flags & SCROLL_VER, pos, len);

		if (d->flags & SCROLL_VER) {
			update_screen(d->x + 1, d->y + 1, d->w - 2, d->h - 2);
		} else {
			update_screen(d->x + 1, d->y + 1, d->w - 2, d->h - 2);
		}
		break;

	case MSG_CLICK:
		while (gui_mouse_b() && d->dp)
		{
			if (d->flags & SCROLL_VER)
			{
				if ((gui_mouse_y() >= d->y + pos) && (gui_mouse_y() <= d->y + pos + len))
				{
					int mouse_offset = gui_mouse_y() - pos;

					while (gui_mouse_b())
					{
						int new_offset = ((gui_mouse_y() - mouse_offset) * size) / height;

						if (new_offset > size - ds) new_offset = size - ds;
						if (new_offset < 0) new_offset = 0;
						
						if (new_offset != d->d2) {
							d->d2 = new_offset;
							scare_mouse();
							object_message(d, MSG_DRAW, 0);
							if (d->dp) object_message((DIALOG*)d->dp, MSG_DRAW, 0);
							unscare_mouse();
						}
						
						/* let other objects continue to animate */
						broadcast_dialog_message(MSG_IDLE, 0);
					}
				}
				else
				{
					// Jump offset half a page
				}

				/* let other objects continue to animate */
				broadcast_dialog_message(MSG_IDLE, 0);
			}
			else
			{
				if ((gui_mouse_x() >= d->x + pos) && (gui_mouse_x() <= d->x + pos + len))
				{
					int mouse_offset = gui_mouse_x() - pos;

					while (gui_mouse_b())
					{
						int new_offset = ((gui_mouse_x() - mouse_offset) * size) / height;

						if (new_offset > size - ds) new_offset = size - ds;
						if (new_offset < 0) new_offset = 0;
						
						if (new_offset != d->d2) {
							d->d2 = new_offset;
							scare_mouse();
							object_message(d, MSG_DRAW, 0);
							if (d->dp) object_message((DIALOG*)d->dp, MSG_DRAW, 0);
							unscare_mouse();
						}
						
						/* let other objects continue to animate */
						broadcast_dialog_message(MSG_IDLE, 0);
					}
				}
				else
				{
					// Jump offset half a page
				}

				/* let other objects continue to animate */
				broadcast_dialog_message(MSG_IDLE, 0);
			}
		}
		break;
	}

	return D_O_K;
}

int d_bjorn_camera_knop(int msg, DIALOG *d, int c)
{
	switch (msg)
	{
	case MSG_CLICK:
		{
			int prev_mouse_x = gui_mouse_x();
			int prev_mouse_y = gui_mouse_y();
			int mickey_x, mickey_y;
			int dw = D_MAP.w;
			int dh = D_MAP.h;
			int hs = D_SCROLL_HOR.d1;
			int vs = D_SCROLL_VER.d1;
			int new_offset_x, new_offset_y;

			get_mouse_mickeys(&mickey_x, &mickey_y);

			show_mouse(NULL);

			d->flags |= D_SELECTED;
			object_message(d, MSG_DRAW, 0);

			while (gui_mouse_b())
			{
				get_mouse_mickeys(&mickey_x, &mickey_y);

				new_offset_x = D_SCROLL_HOR.d2 + mickey_x;
				new_offset_y = D_SCROLL_VER.d2 + mickey_y;

				if (new_offset_x > hs - dw) new_offset_x = hs - dw;
				if (new_offset_y > vs - dh) new_offset_y = vs - dh;
				if (new_offset_x < 0) new_offset_x = 0;
				if (new_offset_y < 0) new_offset_y = 0;

				if (new_offset_x != D_SCROLL_HOR.d2 || new_offset_y != D_SCROLL_VER.d2)
				{
					if (new_offset_x != D_SCROLL_HOR.d2) {
						D_SCROLL_HOR.d2 = new_offset_x;
						object_message(&D_SCROLL_HOR, MSG_DRAW, 0);
					}
					if (new_offset_y != D_SCROLL_VER.d2) {
						D_SCROLL_VER.d2 = new_offset_y;
						object_message(&D_SCROLL_VER, MSG_DRAW, 0);
					}

					object_message(&D_MAP, MSG_DRAW, 0);
				}

				broadcast_dialog_message(MSG_IDLE, 0);
			}

			d->flags &= ~D_SELECTED;
			object_message(d, MSG_DRAW, 0);

			position_mouse(prev_mouse_x, prev_mouse_y);
			show_mouse(screen);
		}
		break;

	default:
		return d_agup_button_proc(msg, d, c);
		break;
	}

	return D_O_K;
}


int d_bjorn_map_proc(int msg, DIALOG *d, int c)
{
	Point map_size = currentMap->getMapSize();
	Point map_dim = Point(currentMap->getWidth(), currentMap->getHeight());

	switch (msg)
	{
	case MSG_START:
		D_SCROLL_VER.dp = &D_MAP;
		D_SCROLL_HOR.dp = &D_MAP;
		// fallthrough...

	case MSG_NEW_MAP:
		D_SCROLL_VER.d1 = map_size.y;
		D_SCROLL_HOR.d1 = map_size.x;
		D_SCROLL_VER.d2 = 0;
		D_SCROLL_HOR.d2 = 0;
		D_SCROLL_VER.flags |= D_DIRTY;
		D_SCROLL_HOR.flags |= D_DIRTY;
		d->flags |= D_DIRTY;
		uszprintf(status_mapinfo, 1024, "Map dimensions: %dx%d", map_dim.x, map_dim.y);
		break;

	case MSG_DRAW:
		rectfill(
				 buffer,
				 d->x, d->y, d->x + d->w - 1, d->y + d->h - 1,
				 makecol(int(128 * brightness),int(128 * brightness),int(128 * brightness))
				 );
		currentMap->setCamera(Point(D_SCROLL_HOR.d2, D_SCROLL_VER.d2), Rectangle(d->x, d->y, d->w, d->h));
		currentMap->drawLayer(buffer, (map_edit_mode == EM_OBSTACLE), currentMap->mapLayers[0]);

		{
			list<Object*>::iterator i;
			// Iterate through all objects, calling the preRender function
			for (i = currentMap->objects.begin(); i != currentMap->objects.end(); i++) {
				callMemberFunction((*i)->tableRef, "preRender");
				(*i)->update_entity();
			}
		}

		currentMap->drawEntities(buffer);
		if (selectedLayer == 1) {
			set_trans_blender(0,0,0,128);
			drawing_mode(DRAW_MODE_TRANS, NULL, 0, 0);
			rectfill(buffer, d->x, d->y, d->x + d->w - 1, d->y + d->h - 1, makecol(0,0,128));
			drawing_mode(DRAW_MODE_SOLID, NULL, 0, 0);
		}
		currentMap->drawLayer(
			buffer,
			(map_edit_mode == EM_OBSTACLE),
			currentMap->mapLayers[1],
			(selectedLayer == 0) ? 128 : 255
		);

		if (selecting) {
			Point start = currentMap->mapToScreen(Point(selection_start_x, selection_start_y));
			Point end = currentMap->mapToScreen(Point(selection_end_x, selection_end_y));

			rect(buffer, start.x+1, start.y+1, end.x+1, end.y+1, makecol(0,0,0));
			rect(buffer, start.x, start.y, end.x, end.y, makecol(100,200,200));
		}

		if (debug_mode) {
			textprintf(buffer, font, d->x+10, d->y+30, makecol(255,255,255), "%d selected entities", selectedObjects.size());
		}

		update_screen(d->x, d->y, d->w, d->h);
		break;

	case MSG_WANTFOCUS:
		return D_WANTFOCUS;

	case MSG_CHAR:
		{
			int key = c >> 8;

			if (key == KEY_LEFT || key == KEY_RIGHT || key == KEY_UP || key == KEY_DOWN) {return D_USED_CHAR;}
			if (key == KEY_F5) {return D_REDRAW;}

			// Map floodfill
			if (key == KEY_F && d->flags & D_GOTMOUSE)
			{
				Point hoverTile = currentMap->screenToTile(Point(gui_mouse_x(), gui_mouse_y()));
				Tile* cursorTile = currentMap->getLayer(selectedLayer)->getTile(hoverTile);

				// Create bitmap the size of the map
				BITMAP* temp_bitmap = create_bitmap(currentMap->getWidth(), currentMap->getHeight());

				if (currentMap->getWidth() > 0 && currentMap->getHeight() > 0 &&
					temp_bitmap && cursorTile && cursorTile->getType() != selectedTile)
				{
					TileType* tileType = cursorTile->getType();

					int x, y;

					// Paint current map to temporary bitmap
					for (x = 0; x < temp_bitmap->w; x++) {
						for (y = 0; y < temp_bitmap->h; y++) {
							if ((currentMap->getLayer(selectedLayer)->getTile(Point(x, y)))->getType() == tileType) {
								putpixel(temp_bitmap, x, y, makecol(255,0,0));
							} else {
								putpixel(temp_bitmap, x, y, makecol(0,255,0));
							}
						}
					}

					// Use floodfill on the bitmap
					floodfill(temp_bitmap, hoverTile.x, hoverTile.y, makecol(0,0,255));

					// Set all effected coordinates to the selected tile
					for (x = 0; x < temp_bitmap->w; x++) {
						for (y = 0; y < temp_bitmap->h; y++) {
							if (getpixel(temp_bitmap, x, y) == makecol(0,0,255)) {
								(currentMap->getLayer(selectedLayer)->getTile(Point(x, y)))->setType(selectedTile);
							}
						}
					}

					set_map_changed(true);
					d->flags |= D_DIRTY;
				}

				if (temp_bitmap) destroy_bitmap(temp_bitmap);

				return D_USED_CHAR;
			}

			if (key == KEY_DEL) {
				// Delete selected objects
				delete_objects(selectedObjects);
				d->flags |= D_DIRTY;

				return D_USED_CHAR;
			}

			return D_O_K;
		}
		break;

	case MSG_IDLE:
		if (d->flags & D_GOTMOUSE) {
			Point hoverTile = currentMap->screenToTile(Point(gui_mouse_x(), gui_mouse_y() + TILES_H));
			//Point new_hover = currentMap->tileToMap(hoverTile);
			//Tile* cursorTile = currentMap->getLayer(0)->getTile(hoverTile);
			
			// Do something with the following
			//d->flags |= D_DIRTY;
			
			if (hoverTile.x >= 0 && hoverTile.y >= 0) {
				/*
				if (cursorTile && cursorTile->getType()) {
					uszprintf(status_message, 1024, "Position: (%d, %d)  Tile: \"%s\"", hoverTile.x, hoverTile.y, cursorTile->getType()->getName());
				} else {
				}
				*/
				uszprintf(status_message, 1024, "Position: (%d, %d)", hoverTile.x, hoverTile.y);
			}
		}
		if (d->flags & D_GOTFOCUS) {
			int prev_scroll_x = D_SCROLL_HOR.d2;
			int prev_scroll_y = D_SCROLL_VER.d2;

			if (key[KEY_LEFT]) D_SCROLL_HOR.d2 = MAX(0, D_SCROLL_HOR.d2 - 24);
			if (key[KEY_RIGHT]) D_SCROLL_HOR.d2 = MIN(map_size.x - d->w, D_SCROLL_HOR.d2 + 24);
			if (key[KEY_UP]) D_SCROLL_VER.d2 = MAX(0, D_SCROLL_VER.d2 - 24);
			if (key[KEY_DOWN]) D_SCROLL_VER.d2 = MIN(map_size.y - d->h, D_SCROLL_VER.d2 + 24);

			if (prev_scroll_x != D_SCROLL_HOR.d2 || prev_scroll_y != D_SCROLL_VER.d2) {
				D_SCROLL_VER.flags |= D_DIRTY;
				D_SCROLL_HOR.flags |= D_DIRTY;
				d->flags |= D_DIRTY;
			}
		}
		break;

	case MSG_LOSTMOUSE:
		status_message[0] = '\0';
		break;

	case MSG_CLICK:
		if (gui_mouse_b() & 1) {
			// Response to left mouse button
			if (map_edit_mode == EM_TILE)
			{
				// In tile edit mode: paint tile
				while (gui_mouse_b() & 1) {
					Tile* cursorTile = currentMap->getLayer(selectedLayer)->getTile(currentMap->screenToTile(Point(gui_mouse_x(), gui_mouse_y())));

					if (cursorTile && selectedTile != cursorTile->getType())
					{
						set_map_changed(true);

						cursorTile->setType(selectedTile);
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}
			}
			else if (map_edit_mode == EM_OBSTACLE)
			{
				// In obstacle edit mode
				while (gui_mouse_b() & 1) {
					Tile* cursorTile = currentMap->getLayer(0)->getTile(currentMap->screenToTile(Point(gui_mouse_x(), gui_mouse_y())));

					if (cursorTile && selectedObstacle != cursorTile->obstacle)
					{
						set_map_changed(true);

						cursorTile->obstacle |= selectedObstacle;
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}
			}
			else if (map_edit_mode == EM_OBJECTS && selectedObjectType >= 0)
			{
				// Spawn object
				int objectInstance = 0;
				char* typeName = objectTypes[selectedObjectType];

				lua_pushstring(L, typeName);
				lua_gettable(L, LUA_GLOBALSINDEX);
				if (!lua_isnil(L, -1)) {
					lua_call(L, putLuaArguments(L, "m", currentMap), 1);
					if (lua_istable(L, -1)) {
						objectInstance = lua_ref(L, -1);
					}
					else {
						console.log(CON_QUIT, CON_ALWAYS, "Error while instaniating object \"%s\"", typeName);
					}
				}
				else {
					console.log(CON_QUIT, CON_ALWAYS, "Error: could not find object class \"%s\"", typeName);
				}

				lua_getref(L, objectInstance);
				lua_pushstring(L, "_pointer");
				lua_gettable(L, -2);
				Object* obj = (Object*)lua_touserdata(L, -1);
				obj->className = typeName; // Assign class name (not the best place for this)
				lua_pop(L, 1);

				select_object(obj);

				double px = 0, py = 0;

				while (gui_mouse_b() & 1) {
					Point pos = currentMap->screenToMap(Point(gui_mouse_x(), gui_mouse_y()));

					double npx = (snapToGrid) ? pos.x / TILES_W : (float)pos.x / TILES_W;
					double npy = (snapToGrid) ? pos.y / TILES_H : (float)pos.y / TILES_H;

					if (px != npx || py != npy) {
						px = npx;
						py = npy;

						// Drag object (synchronize position with mouse pointer)
						callMemberFunction(objectInstance, "setPosition", "dd", px, py);

						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();
					}

					if (gui_mouse_b() & 2) {
						// Remove the object
						callMemberFunction(objectInstance, "destroy", "");
						selectedObjects.remove(obj);
						delete obj;
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();

						while (gui_mouse_b() & (1 || 2)) {
							broadcast_dialog_message(MSG_IDLE, 0);
						}
						return D_O_K;
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}

				set_map_changed(true);
				lua_unref(L, objectInstance);
			}
		}
		else if (gui_mouse_b() & 2) {
			// Response to right mouse button
			if (map_edit_mode == EM_TILE)
			{
				// In tile edit mode: grap tile
				while (gui_mouse_b() & 2) {
					Tile* cursorTile = currentMap->getLayer(selectedLayer)->getTile(currentMap->screenToTile(Point(gui_mouse_x(), gui_mouse_y())));

					if (cursorTile && selectedTile != cursorTile->getType())
					{
						selectedTile = cursorTile->getType();
						scare_mouse();
						object_message(&D_TILE, MSG_DRAW, 0);
						object_message(&D_TILESET, MSG_DRAW, 0);
						unscare_mouse();
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}
			}
			else if (map_edit_mode == EM_OBSTACLE)
			{
				// In tile edit mode: clear tile obstacle settings
				while (gui_mouse_b() & 2) {
					Tile* cursorTile = currentMap->getLayer(0)->getTile(currentMap->screenToTile(Point(gui_mouse_x(), gui_mouse_y())));

					if (cursorTile && cursorTile->obstacle)
					{
						set_map_changed(true);

						cursorTile->obstacle = 0;
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}
			}
			else if (map_edit_mode == EM_OBJECTS) {
				// Start selection process
				selecting = true;
				Point start = currentMap->screenToMap(Point(gui_mouse_x(), gui_mouse_y()));
				selection_start_x = start.x;
				selection_start_y = start.y;
				double new_end_x, new_end_y;
				selection_end_x = selection_start_x;
				selection_end_y = selection_start_y;
				list<Object*> objects;
				list<Object*>::iterator i;
				select_objects(objects);

				while (gui_mouse_b() & 2) {
					Point start = currentMap->screenToMap(Point(gui_mouse_x(), gui_mouse_y()));
					new_end_x = (float)start.x;
					new_end_y = (float)start.y;

					if (new_end_x != selection_end_x || new_end_y != selection_end_y) {
						selection_end_x = int(new_end_x);
						selection_end_y = int(new_end_y);

						// Select the objects within the rectangle
						objects.clear();
						for (i = currentMap->objects.begin(); i != currentMap->objects.end(); i++) {
							Point pos = (*i)->pos;
							Point start, end;
							
							if (selection_start_x < selection_end_x) {
								if (selection_start_y < selection_end_y) {
									start = Point(selection_start_x, selection_start_y);
									end = Point(selection_end_x, selection_end_y);
								} else {
									start = Point(selection_start_x, selection_end_y);
									end = Point(selection_end_x, selection_start_y);
								}
							} else {
								if (selection_start_y < selection_end_y) {
									start = Point(selection_end_x, selection_start_y);
									end = Point(selection_start_x, selection_end_y);
								} else {
									start = Point(selection_end_x, selection_end_y);
									end = Point(selection_start_x, selection_start_y);
								}
							}
							
							if (pos.x > start.x &&
								pos.y > start.y &&
								pos.x < end.x &&
								pos.y < end.y) {
								objects.push_back((*i));
							}
						}
						select_objects(objects);
						
						
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}

				selecting = false;
				d->flags |= D_DIRTY;
			}
		}
		break;
	}


	return D_O_K;
}

int d_bjorn_tile_proc(int msg, DIALOG *d, int c)
{
	switch (msg)
	{
	case MSG_DRAW:
		rectfill(buffer,
				 d->x, d->y, d->x + d->w - 1, d->y + d->h - 1,
				 makecol(int(128 * brightness),int(128 * brightness),int(128 * brightness)));

		if (selectedTile && selectedTile->getBitmap()) {
			stretch_sprite(buffer, selectedTile->getBitmap(), d->x, d->y, d->w, d->h);

			if (showTileGrid) {
				int i;
				for (i = 1; i < selectedTile->getBitmap()->w; i++) {
					vline(buffer, d->x + ((i * d->w) / selectedTile->getBitmap()->w), d->y, d->y + d->h - 1, makecol(0,0,0));
				}
				for (i = 1; i < selectedTile->getBitmap()->h; i++) {
					hline(buffer, d->x, d->y + ((i * d->h) / selectedTile->getBitmap()->h), d->x + d->w - 1, makecol(0,0,0));
				}
			}
		}
		update_screen(d->x, d->y, d->w, d->h);
		break;

	case MSG_WANTFOCUS:
		return D_WANTFOCUS;

	case MSG_CHAR:
		{
			int key = c >> 8;

			// Floodfill
			if (key == KEY_F && (d->flags & D_GOTMOUSE))
			{
				if (selectedTile && selectedTile->getBitmap())
				{
					BITMAP* tileBitmap = selectedTile->getBitmap();
					int x = ((gui_mouse_x() - d->x) * tileBitmap->w) / d->w;
					int y = ((gui_mouse_y() - d->y) * tileBitmap->h) / d->h;

					int selColor = makecol(selectedColor[S_R], selectedColor[S_G], selectedColor[S_B]);
					if (getpixel(tileBitmap, x, y) != selColor)
					{
						floodfill(tileBitmap, x, y, selColor);
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						object_message(&D_MAP, MSG_DRAW, 0);
						object_message(&D_TILESET, MSG_DRAW, 0);
						unscare_mouse();
					}
				}

				return D_USED_CHAR;
			}
		}
		break;

	case MSG_CLICK:
		if (selectedTile && selectedTile->getBitmap())
		{
			BITMAP* tileBitmap = selectedTile->getBitmap();

			if (gui_mouse_b() & 1)
			{
				// Paint with the selected color
				while (gui_mouse_b() & 1)
				{
					int x = ((gui_mouse_x() - d->x) * tileBitmap->w) / d->w;
					int y = ((gui_mouse_y() - d->y) * tileBitmap->h) / d->h;
					int prev_color = getpixel(tileBitmap, x, y);

					putpixel(tileBitmap, x, y, makecol(selectedColor[S_R], selectedColor[S_G], selectedColor[S_B]));
					if (prev_color != getpixel(tileBitmap, x, y))
					{
						scare_mouse();
						object_message(d, MSG_DRAW, 0);
						object_message(&D_MAP, MSG_DRAW, 0);
						object_message(&D_TILESET, MSG_DRAW, 0);
						unscare_mouse();
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}
			}
			else
			{
				// Grab the color
				while (gui_mouse_b() & 2)
				{
					int x = ((gui_mouse_x() - d->x) * tileBitmap->w) / d->w;
					int y = ((gui_mouse_y() - d->y) * tileBitmap->h) / d->h;

					if (x >= 0 && y >= 0 && x < tileBitmap->w && y < tileBitmap->h) {
						int color = getpixel(tileBitmap, x, y);

						update_color(&selectedColor[S_R], getr(color));
						update_color(&selectedColor[S_G], getg(color));
						update_color(&selectedColor[S_B], getb(color));
					}

					broadcast_dialog_message(MSG_IDLE, 0);
				}
			}
		}
		break;

	case MSG_IDLE:
		if (d->flags & D_GOTMOUSE && selectedTile && selectedTile->getBitmap())
		{
			BITMAP* tileBitmap = selectedTile->getBitmap();

			int x = ((gui_mouse_x() - d->x) * tileBitmap->w) / d->w;
			int y = ((gui_mouse_y() - d->y) * tileBitmap->h) / d->h;

			if (x >= 0 && y >= 0 && x < tileBitmap->w && y < tileBitmap->h)
			{
				// Update status message to mouse tile coordinates
				uszprintf(status_message, 1024, "Tile: %s  Position: (%d, %d)", selectedTile->getName(), x, y);
			}
		}
		break;

	case MSG_LOSTMOUSE:
		status_message[0] = '\0';
		//uszprintf(status_message, 1024, "");
		break;
	}
	return D_O_K;
}

int d_bjorn_check_grid(int msg, DIALOG *d, int c)
{
	int selected = d->flags & D_SELECTED;
	int ret = d_agup_check_proc(msg, d, 0);

	if (msg == MSG_START) {
		if (showTileGrid) d->flags |= D_SELECTED;
		else d->flags &= ~D_SELECTED;
	}
	
	showTileGrid = d->flags & D_SELECTED;
	if (selected != (d->flags & D_SELECTED)) {D_TILE.flags |= D_DIRTY;}
	return ret;
}


int d_bjorn_check_snap(int msg, DIALOG *d, int c)
{
	//int selected = d->flags & D_SELECTED;
	int ret = d_agup_check_proc(msg, d, 0);

	if (msg == MSG_START) {
		if (snapToGrid) d->flags |= D_SELECTED;
		else d->flags &= ~D_SELECTED;
	}
	
	snapToGrid = d->flags & D_SELECTED;
	//if (selected != (d->flags & D_SELECTED)) {D_TILE.flags |= D_DIRTY;}
	return ret;
}


/* This slider is like a normal slider, but it synchronizes it's
 * position with the variable pointed to by dp3
 */
int d_bjorn_slider_proc(int msg, DIALOG *d, int c)
{
	int *color = (int*)d->dp3;

	switch (msg)
	{	
	case MSG_START:
		/* Initialise the slider position */
		d->d2 = *color;
		break;

	case MSG_IDLE:
		/* Update slider when neccesary */
		if (d->d2 != *color) {
			d->d2 = *color;
			scare_mouse();
			object_message(d, MSG_DRAW, 0);
			unscare_mouse();
		}
		break;
	}

	return d_agup_slider_proc(msg, d, c);
}

int update_color(void *dp3, int d2)
{
	int type = ((unsigned long)dp3 - (unsigned long)selectedColor) / sizeof(selectedColor[0]);
	int r, g, b;
	float h, s, v;
	
	if (selectedColor[type] != d2) {
		selectedColor[type] = d2;
		
		if ((type == S_R) || (type == S_G) || (type == S_B)) {
			/* Convert RGB color to HSV */
			r = selectedColor[S_R];
			g = selectedColor[S_G];
			b = selectedColor[S_B];
			
			rgb_to_hsv(r, g, b, &h, &s, &v);
			
			selectedColor[S_H] = (int)(h * 255.0 / 360.0);
			selectedColor[S_S] = (int)(s * 255.0);
			selectedColor[S_V] = (int)(v * 255.0);
		}
		else {
			/* Convert HSV color to RGB */
			h = selectedColor[S_H] * 360.0 / 255.0;
			s = selectedColor[S_S] / 255.0;
			v = selectedColor[S_V] / 255.0;
			
			hsv_to_rgb(h, s, v, &r, &g, &b);
			
			selectedColor[S_R] = r;
			selectedColor[S_G] = g;
			selectedColor[S_B] = b;
		}
	} 
	
	return D_O_K;
}

int d_bjorn_color_proc(int msg, DIALOG *d, int c)
{
	if (msg == MSG_DRAW) 
	{
		int ret = d_agup_box_proc(msg, d, c);
		rectfill(screen, d->x + 2, d->y + 2, d->x + d->w - 3, d->y + d->h - 3, d->d2);
		return ret;
	}
	else if (msg == MSG_IDLE)
	{
		int color = 0;

		switch (d->d1)
		{
		case S_R: color = makecol(selectedColor[S_R], 0, 0); break;
		case S_G: color = makecol(0, selectedColor[S_G], 0); break;
		case S_B: color = makecol(0, 0, selectedColor[S_B]); break;
		case S_C: color = makecol(selectedColor[S_R], selectedColor[S_G], selectedColor[S_B]); break;
		}

		if (d->d2 != color) {
			d->d2 = color;
			scare_mouse();
			object_message(d, MSG_DRAW, 0);
			unscare_mouse();
		}

		return d_agup_box_proc(msg, d, c);
	}
	else
	{
		return d_agup_box_proc(msg, d, c);
	}
}

/*
 * When this proc is clicked, it will close the dialog.
 * Is used for close-on-click at about box.
 */
int d_bjorn_close_proc(int msg, DIALOG *d, int c)
{
	if (msg == MSG_CLICK) {
		while (gui_mouse_b()) {;}
		return D_CLOSE;
	} else {
		return D_O_K;
	}
}

/*
 * A standard d_agup_edit_proc but this one will call
 * a callback function specified by dp2 when it loses
 * focus. The function should be of the form:
 *
 *  void lost_focus(DIALOG *d);
 */
int d_bjorn_edit_proc(int msg, DIALOG *d, int c)
{
	if (msg == MSG_LOSTFOCUS && d->dp2)
	{
		((void (*)(struct DIALOG *))d->dp2)(d);
	}

	return d_agup_edit_proc(msg, d, c);
}

char *list_objects(int index, int *list_size)
{
	if (index >= 0)
	{
		return objectTypes[index];
	}
	else
	{
		*list_size = objectTypes.size();
		return NULL;
	}
}

int d_bjorn_objects_list(int msg, DIALOG *d, int c)
{
	int ret;
	//int selected = d->d1;
	
	ret = d_agup_list_proc(msg, d, c);

	if (msg == MSG_START) {
		d->d1 = selectedObjectType;
	}

	/*
	if (d->d1 != selected || msg == MSG_START) {
		// Refresh the active tileset according to the new selection.
		char tempTilename[256];
		vector<TileType*> tileTypes;
		vector<TileType*>::iterator i;

		activeTileset.clear();
		tileTypes = tileRepository->generateTileArray();

		for (i = tileTypes.begin(); i != tileTypes.end(); i++)
		{
			replace_extension(tempTilename, (*i)->getName(), "bmp", 256);
			if (ustrcmp(tileSets[d->d1], tempTilename) == 0) {
				activeTileset.push_back(*i);
			}
		}

		object_message(&D_TILESET, MSG_NEW_TILESET, 0);
	}
	*/
	selectedObjectType = d->d1;

	return ret;
}


char *list_tilesets(int index, int *list_size)
{
	if (index >= 0)
	{
		return tileSets[index];
	}
	else
	{
		*list_size = tileSets.size();
		return NULL;
	}
}

int d_bjorn_tileset_list(int msg, DIALOG *d, int c)
{
	int ret;
	int selected = d->d1;
	
	ret = d_agup_list_proc(msg, d, c);

	if (msg == MSG_START) {
		d->d1 = selectedTileset;
	}

	if (d->d1 != selected || msg == MSG_START) {
		// Refresh the active tileset according to the new selection.
		char tempTilename[256];
		vector<TileType*> tileTypes;
		vector<TileType*>::iterator i;

		activeTileset.clear();
		tileTypes = tileRepository->generateTileArray();

		for (i = tileTypes.begin(); i != tileTypes.end(); i++)
		{
			replace_extension(tempTilename, (*i)->getName(), "bmp", 256);
			if (ustrcmp(tileSets[d->d1], tempTilename) == 0) {
				activeTileset.push_back(*i);
			}
		}

		object_message(&D_TILESET, MSG_NEW_TILESET, 0);
	}

	selectedTileset = d->d1;

	return ret;
}

int d_bjorn_tileset(int msg, DIALOG *d, int c)
{
	unsigned int tile_w = 0;
	unsigned int tile_h = 0;
	int nr_tiles = 0;
	int total_height = 0;
	unsigned int tiles_in_row = 0;

	if (activeTileset.size() > 0)
	{
		tile_w = (activeTileset[0]->getBitmap())->w;
		tile_h = (activeTileset[0]->getBitmap())->h;
		nr_tiles = activeTileset.size();

		tiles_in_row = (d->w - 1) / (tile_w + 1);

		if (tiles_in_row > 0) {
			total_height = ((nr_tiles + tiles_in_row - 1) / tiles_in_row) * (tile_h + 1) + 1;
		}
	}


	switch (msg)
	{
	case MSG_START:
		D_TILESET_SCROLL.dp = &D_TILESET;
		break;

	case MSG_DRAW:
		{
			rectfill(buffer, d->x, d->y, d->x + d->w - 1, d->y + d->h - 1, makecol(int(128 * brightness),int(128 * brightness),int(128 * brightness)));

			int start_y = (D_TILESET_SCROLL.d2 / (tile_h + 1));
			unsigned int end_y = start_y + (d->h - 1) / (tile_h + 1) + 1;


			// Draw the tiles
			for (unsigned int y = start_y; y <= end_y; y++) {
				for (unsigned int x = 0; x < tiles_in_row; x++) {
					if (x + y * (tiles_in_row) < activeTileset.size()) {
						BITMAP* tileBmp = activeTileset[x + y * tiles_in_row]->getBitmap();

						int tile_x = x * (tile_w + 1) + d->x + 1;
						int tile_y = y * (tile_h + 1) + d->y + 1 - D_TILESET_SCROLL.d2;

						draw_sprite(buffer, tileBmp, tile_x, tile_y);

						if (activeTileset[x + y * tiles_in_row] == selectedTile) {
							set_trans_blender(0,0,0,128);
							drawing_mode(DRAW_MODE_TRANS, NULL, 0, 0);
							hline(buffer, tile_x, tile_y, tile_x + tile_w - 2, makecol(255,255,255));
							vline(buffer, tile_x, tile_y + 1, tile_y + tile_w - 2, makecol(255,255,255));

							hline(buffer, tile_x, tile_y + tile_w - 1, tile_x + tile_w - 1, makecol(0,0,0));
							vline(buffer, tile_x + tile_w - 1, tile_y, tile_y + tile_w - 2, makecol(0,0,0));
							drawing_mode(DRAW_MODE_SOLID, NULL, 0, 0);
						}
					}
				}
			}

			update_screen(d->x, d->y, d->w, d->h);
		}
		break;

	case MSG_NEW_TILESET:
		D_TILESET_SCROLL.d1 = total_height;
		D_TILESET_SCROLL.d2 = 0;
		D_TILESET_SCROLL.flags |= D_DIRTY;
		d->flags |= D_DIRTY;
		break;

	case MSG_CLICK:
		if (gui_mouse_b())
		{
			while (gui_mouse_b())
			{
				int mouse_x = gui_mouse_x();
				int mouse_y = gui_mouse_y();

				unsigned int x = (mouse_x - d->x) / (tile_w + 1);
				unsigned int y = (mouse_y - d->y + D_TILESET_SCROLL.d2) / (tile_h + 1);

				x = MAX(0, MIN(tiles_in_row - 1, x));
				y = MAX(0, MIN(nr_tiles / tiles_in_row, y));

				if (x + y * tiles_in_row < activeTileset.size())
				{
					if (activeTileset[x + y * tiles_in_row] != selectedTile)
					{
						selectedTile = activeTileset[x + y * tiles_in_row];
						scare_mouse();
						object_message(&D_TILE, MSG_DRAW, 0);
						object_message(d, MSG_DRAW, 0);
						unscare_mouse();
					}
				}

				broadcast_dialog_message(MSG_IDLE, 0);
			}
		}
		break;

	case MSG_IDLE:
		if (d->flags & D_GOTMOUSE) {
			int mouse_x = gui_mouse_x();
			int mouse_y = gui_mouse_y();

			unsigned int x = (mouse_x - d->x) / (tile_w + 1);
			unsigned int y = (mouse_y - d->y + D_TILESET_SCROLL.d2) / (tile_h + 1);

			x = MAX(0, MIN(tiles_in_row - 1, x));
			y = MAX(0, MIN(nr_tiles / tiles_in_row, y));

			if (x + y * tiles_in_row < activeTileset.size()) {
				uszprintf(status_message, 1024, "Tile: %s", activeTileset[x + y * tiles_in_row]->getName());
			} else {
				status_message[0] = '\0';
			}
		}
		break;

	case MSG_LOSTMOUSE:
		status_message[0] = '\0';
		break;
	}

	return D_O_K;
}

int d_bjorn_autotext_proc(int msg, DIALOG *d, int c)
{
	switch (msg)
	{
	case MSG_IDLE:
		// Check if the text string has changed
		if (d->dp && d->dp2) {
			if (ustrcmp((char*)d->dp, (char*)d->dp2) != 0) {
				ustrncpy((char*)d->dp, (char*)d->dp2, 1024);
				scare_mouse();
				object_message(d, MSG_DRAW, 0);
				unscare_mouse();
			}
		}
		break;

	case MSG_START:
		d->dp = new char[1024];
		ustrcpy((char*)d->dp, "");
		return d_text_proc(msg, d, c);
		break;

	case MSG_END:
		{
			int ret = d_text_proc(msg, d, c);
			delete (char*)d->dp;
			return ret;
		}
		break;

	case MSG_DRAW:
		rectfill(buffer, d->x, d->y, d->x + d->w - 1, d->y + d->h - 1, d->bg);
		if (d->dp) {
			int ptm = text_mode(-1);
			textout(buffer, font, (char*)d->dp, d->x, d->y, d->fg);
			text_mode(ptm);
		}
		update_screen(d->x, d->y, d->w, d->h);
		break;
	}

	return D_O_K;
}


int d_bjorn_obs_preset_proc(int msg, DIALOG *d, int c)
{
	switch (msg)
	{
	case MSG_DRAW:
		if (selectedObstacle == d->d1) {
			rectfill(buffer, d->x, d->y, d->x + d->w - 1, d->y + d->h - 1, makecol(64,64,64));
		} else {
			rectfill(buffer, d->x, d->y, d->x + d->w - 1, d->y + d->h - 1, d->bg);
		}

		if (d->d1 & OB_TOP) {
			line(buffer, d->x + 2,        d->y + 2,        d->x + d->w - 3, d->y + 2,        makecol(255,0,0));
			line(buffer, d->x + 3,        d->y + 3,        d->x + d->w - 2, d->y + 3,        makecol(0,0,0));
		}
		if (d->d1 & OB_LEFT) {
			line(buffer, d->x + 2,        d->y + 2,        d->x + 2,        d->y + d->h - 3, makecol(255,0,0));
			line(buffer, d->x + 3,        d->y + 3,        d->x + 3,        d->y + d->h - 2, makecol(0,0,0));
		}
		if (d->d1 & OB_RIGHT) {
			line(buffer, d->x + d->w - 3, d->y + 2,        d->x + d->w - 3, d->y + d->h - 3, makecol(255,0,0));
			line(buffer, d->x + d->w - 2, d->y + 3,        d->x + d->w - 2, d->y + d->h - 2, makecol(0,0,0));
		}
		if (d->d1 & OB_BOTTOM) {
			line(buffer, d->x + 2,        d->y + d->h - 3, d->x + d->w - 3, d->y + d->h - 3, makecol(255,0,0));
			line(buffer, d->x + 3,        d->y + d->h - 2, d->x + d->w - 2, d->y + d->h - 2, makecol(0,0,0));
		}

		update_screen(d->x, d->y, d->w, d->h);
		break;

	case MSG_CLICK:
		if (gui_mouse_b())
		{
			int nowhere;
			selectedObstacle = d->d1;
			dialog_message(&main_dlg[MAIN_START_OF_NULL + 5], MSG_DRAW, 0, &nowhere);

			while (gui_mouse_b()) {
				broadcast_dialog_message(MSG_IDLE, 0);
			}
		}
	}

	return D_O_K;
}

int d_bjorn_obs_proc(int msg, DIALOG *d, int c)
{
	return d_bjorn_obs_preset_proc(msg, d, c);
}


void resizemap_change(DIALOG *d)
{
	int inew_map_w = ustrtol((char*)resizemap_dlg[3].dp, NULL, 10);
	int inew_map_h = ustrtol((char*)resizemap_dlg[4].dp, NULL, 10);
	int itop = ustrtol((char*)resizemap_dlg[7].dp, NULL, 10);
	int ibottom = ustrtol((char*)resizemap_dlg[8].dp, NULL, 10);
	int ileft = ustrtol((char*)resizemap_dlg[11].dp, NULL, 10);
	int iright = ustrtol((char*)resizemap_dlg[12].dp, NULL, 10);

	if (d == &resizemap_dlg[3] && (inew_map_w - currentMap->getWidth() - ileft - iright != 0)) {
		ileft = 0;
		iright = inew_map_w - currentMap->getWidth();
		resizemap_dlg[11].flags |= D_DIRTY;
		resizemap_dlg[12].flags |= D_DIRTY;
	}
	if (d == &resizemap_dlg[4] && (inew_map_h - currentMap->getHeight() - itop - ibottom != 0)) {
		itop = 0;
		ibottom = inew_map_h - currentMap->getHeight();
		resizemap_dlg[7].flags |= D_DIRTY;
		resizemap_dlg[8].flags |= D_DIRTY;
	}
	if (d == &resizemap_dlg[7]) {
		ibottom = inew_map_h - currentMap->getHeight() - itop;
		resizemap_dlg[8].flags |= D_DIRTY;
	}
	if (d == &resizemap_dlg[8]) {
		itop = inew_map_h - currentMap->getHeight() - ibottom;
		resizemap_dlg[7].flags |= D_DIRTY;
	}
	if (d == &resizemap_dlg[11]) {
		iright = inew_map_w - currentMap->getWidth() - ileft;
		resizemap_dlg[12].flags |= D_DIRTY;
	}
	if (d == &resizemap_dlg[12]) {
		ileft = inew_map_w - currentMap->getWidth() - iright;
		resizemap_dlg[11].flags |= D_DIRTY;
	}

	uszprintf((char*)resizemap_dlg[3].dp, 8, "%d", inew_map_w);
	uszprintf((char*)resizemap_dlg[4].dp, 8, "%d", inew_map_h);
	uszprintf((char*)resizemap_dlg[7].dp, 8, "%d", itop);
	uszprintf((char*)resizemap_dlg[8].dp, 8, "%d", ibottom);
	uszprintf((char*)resizemap_dlg[11].dp, 8, "%d", ileft);
	uszprintf((char*)resizemap_dlg[12].dp, 8, "%d", iright);
}


