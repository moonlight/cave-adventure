/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#ifndef _INCLUDED_CANVAS_H_
#define _INCLUDED_CANVAS_H_

#include <allegro.h>

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
	void drawViewport(int x, int y, int w, int h, Object* cameraTarget);

private:
	int curX, curY;		// The current cursor position
	int drawColor;		// The currently used draw color
	int alpha;			// The currently used opacity
	FONT* myFont;		// The currently used font
	int drawMode;		// The currently used drawmode
};


extern Canvas canvas;


#endif