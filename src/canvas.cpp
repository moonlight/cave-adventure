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
#include "common.h"
#include "rpg.h"
#include "canvas.h"


//===================   The canvas   =======================================/

Canvas canvas;



//===================   The canvas methods   ===============================/

void Canvas::init()
{
	curX = 0;
	curY = 0;
	set_clip(buffer, 0, 0, SCREEN_W - 1, SCREEN_H - 1);
	myFont = font;
	drawColor = makecol(255,255,255);
	alpha = 255;
	drawMode = DM_MASKED;
}

void Canvas::getCursor(int *x, int *y)
{
	ASSERT(x && y);
	*x = curX;
	*y = curY;
}

void Canvas::setCursor(int x, int y)
{
	curX = x;
	curY = y;
}

void Canvas::getClip(int *x1, int *y1, int *x2, int *y2)
{
	ASSERT(x1 && y1 && x2 && y2);
	*x1 = buffer->cl;
	*y1 = buffer->ct;
	*x2 = buffer->cr;
	*y2 = buffer->cb;
}

void Canvas::setClip(int x1, int y1, int x2, int y2)
{
	set_clip(buffer, x1, y1, x2, y2);
}

void Canvas::setColor(int color)
{
	drawColor = color;
}

void Canvas::setDrawMode(int drawMode)
{
	this->drawMode = drawMode;
}

void Canvas::setAlpha(int alpha)
{
	this->alpha = alpha;
}

void Canvas::setFont(FONT *font)
{
	if (font) myFont = font;
}

void Canvas::textSize(const char *text, int *w, int *h)
{
	ASSERT(w && h);
	*w = text_length(myFont, text);
	*h = text_height(myFont);
}

void Canvas::drawText(const char *text)
{
	ASSERT(text);
	int tm = text_mode(-1);		// Text will be drawn masked
	textout(buffer, myFont, text, curX, curY, drawColor);
	curX += text_length(myFont, text);
	text_mode(tm);
}

void Canvas::drawBitmap(BITMAP *bmp, int dw, int dh, int sx, int sy, int sw, int sh)
{
	/*
	console.log(
		CON_LOG | CON_CONSOLE,
		CON_DEBUG,
		"Processing draw_bitmap(bmp, %d, %d, %d, %d, %d, %d)",
		dw, dh, sx, sy, sw, sh
	);
	*/
	ASSERT(bitmap);
	BITMAP *src = NULL;

	// Don't try to process invalid surfaces
	if (dw < 0 || dh < 0) return;

	if (sx != 0 || sy != 0 || sw != bmp->w || sh != bmp->h)
	{
		// The source bitmap needs to be adapted first
		src = create_bitmap(sw, sh);
		ASSERT(src);

		// Determine the point where we should start drawing
		int start_x = -sx % bmp->w;
		int start_y = -sy % bmp->h;
		if (start_x > 0) start_x -= bmp->w;
		if (start_y > 0) start_y -= bmp->h;
		int x = start_x;
		int y = start_y;

		// Create tiled pattern
		while (y < sh) {
			while (x < sw) {
				blit(bmp, src, 0, 0, x, y, bmp->w, bmp->h);
				x += bmp->w;
			}
			x = start_x;
			y += bmp->h;
		}

		bmp = src;
	}

	// Now we'll put this sprite on the screen
	switch (drawMode) {
	case DM_ALPHA:
		set_alpha_blender();
		break;
	case DM_TRANS:
        set_trans_blender(0,0,0,alpha);
		drawing_mode(DRAW_MODE_TRANS, NULL, 0, 0);
		break;
	}
	if ((drawMode == DM_TRANS && alpha < 255) || drawMode == DM_ALPHA || drawMode == DM_ADD) {
		if (sw == dw && sh == dh) {
			draw_trans_sprite(buffer, bmp, curX, curY);
		}
		else {
			BITMAP *stretch = create_bitmap(dw, dh);
			if (stretch) {
				stretch_sprite(stretch, bmp, 0, 0, dw, dh);
				draw_trans_sprite(buffer, stretch, curX, curY);
				destroy_bitmap(stretch);
			}
		}
	}
	else
	{
		if (sw == dw && sh == dh) {
			draw_sprite(buffer, bmp, curX, curY);
		}
		else {
			stretch_sprite(buffer, bmp, curX, curY, dw, dh);
		}
	}
	switch (drawMode) {
	case DM_TRANS:
		drawing_mode(DRAW_MODE_SOLID, NULL, 0, 0);
		break;
	}

	if (src) destroy_bitmap(src);

	// And don't forget to move that cursor
	curX += dw;
}

void Canvas::drawViewport(int x, int y, int w, int h, int tx, int ty, TiledMap* map)
{
	map->setCamera(
		Point(tx, ty),
		Rectangle(x, y, w, h),
		true, true
	);

	map->draw(buffer);
}
