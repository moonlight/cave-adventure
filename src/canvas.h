/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#ifndef _INCLUDED_CANVAS_H_
#define _INCLUDED_CANVAS_H_

#include <allegro.h>
#include "shared/tiled_map.h"

class Canvas
{
public:
	void init();
	void getCursor(int *x, int *y);
	void setCursor(int x, int y);
	void getClip(int *x1, int *y1, int *x2, int *y2);
	void setClip(int x1, int y1, int x2, int y2);
	void setColor(int color);
	void setDrawMode(int drawMode);
	int  getDrawMode() {return drawMode;}
	void setAlpha(int alpha);
	int  getAlpha() {return alpha;}
	void setFont(FONT* font);
	void textSize(const char *text, int *width, int *height);
	void bitmapSize(BITMAP *bmp, int *width, int *height);
	void drawText(const char *text);
	void drawBitmap(BITMAP *bmp, int dw, int dh, int sx, int sy, int sw, int sh);
	void drawViewport(int x, int y, int w, int h, int tx, int ty, TiledMap* map);

private:
	int curX, curY;		// The current cursor position
	int drawColor;		// The currently used draw color
	int alpha;			// The currently used opacity
	FONT* myFont;		// The currently used font
	int drawMode;		// The currently used drawmode
};


extern Canvas canvas;


#endif
