/*
    The Moonlight Engine - An extendable, portable, RPG-focused game engine.
    Project Home: http://moeng.sourceforge.net/
    Copyright (C) 2003  Bjørn Lindeijer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#include <stdio.h>
#include <stdarg.h>
#include <allegro.h>
#include <list>
#include "console.h"
#include "../common.h"
#include <math.h>

#ifndef M_PI
#define M_PI   3.14159
#endif


Console::Console(const char* filename)
{
	logFilename = new char[strlen(filename) + 1];
	strcpy(logFilename, filename);
	logFilename[strlen(filename)] = '\0';

	logFile = fopen(logFilename, "w");
	fclose(logFile);
	log(CON_LOG, CON_ALWAYS, "----- Start of RPG log file -----");

	progress = 0;
	active = false;
	enableLogfile = true;
}


Console::~Console()
{
	// Deallocate console string messages
	list<char*>::iterator i;
	while (!logMessages.empty())
	{
		i = logMessages.begin();
		delete (*i);
		logMessages.erase(i);
	}

	log(CON_LOG, CON_ALWAYS, "----- End of RPG log file -----");

	delete logFilename;
}

void Console::update()
{
	if (active && progress < 100) progress = MIN(100, progress + 2);
	if (!active && progress > 0) progress = MAX(0, progress - 2);
}

void Console::draw(BITMAP *dest)
{
	if (progress > 0) {
		int posY = (int)((double)(dest->h / 4) * sin(((0.5 * M_PI) / (double)100) * (double)progress) - text_height(font));

		line(dest, 0, posY + text_height(font) + 1, dest->w - 1, posY + text_height(font) + 1, makecol(0,0,0));
		set_trans_blender(0,0,0,100);
		drawing_mode(DRAW_MODE_TRANS, NULL, 0, 0);
		rectfill(dest, 0, 0, dest->w - 1, posY + text_height(font), makecol(0,0,0));
		drawing_mode(DRAW_MODE_SOLID, NULL, 0, 0);

		font = engine_font;

		list<char*>::iterator i = logMessages.begin();
		while (i != logMessages.end() && posY > - text_height(font))
		{
			textprintf(dest, font, 2, posY, makecol(200,200,200), (*i));
			posY -= text_height(font) + 1;
			i++;
		}
	}
}

bool Console::handleInput(int key)
{
	if ((progress == 0 || progress == 100) && (key == KEY_TILDE || key == KEY_C)) {
		active = !active;
		return true;
	}
	return false;
}

void Console::log(int where, int when, const char *what, ...)
{
	if ((when & CON_ALWAYS) || ((when & CON_DEBUG) && debug_mode) || ((when & CON_VDEBUG) && debug_mode == 2))
	{
		char* buf = (char*)malloc(1024 * sizeof(char));

		va_list ap;
		va_start(ap, what);
		uvsprintf(buf, what, ap);
		va_end(ap);

		if (where & (CON_LOG | CON_QUIT))
		{
			time_t t;
			time(&t);

			if (enableLogfile) {
				logFile = fopen(logFilename, "a");
				fprintf(
					logFile,
					"[%s%d:%s%d:%s%d] ",
					(((t / 60) / 60) % 24 < 10) ? "0" : "",
					(int)(((t / 60) / 60) % 24),
					((t / 60) % 60 < 10) ? "0" : "",
					(int)((t / 60) % 60),
					(t % 60 < 10) ? "0" : "",
					(int)(t % 60)
				);
				fprintf(logFile, buf);
				fprintf(logFile, "\n");
				fclose(logFile);
			}

			if (where & CON_QUIT)
			{
				logFile = fopen(logFilename, "a");
				fprintf(logFile, "FATAL ERROR!\n");
				fclose(logFile);
				set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);
				allegro_message(buf);
				exit(1);
			}
		}

		if (where & CON_POPUP)
		{
			allegro_message(buf);
		}

		if (where & CON_CONSOLE)
		{
			// Add the message to the console
			logMessages.push_front(buf);

			// Clean up the log memory (only keep the last 20 messages)
			if (logMessages.size() > 20) {
				free(logMessages.back());
				logMessages.pop_back();
			}
		}
		else
		{
			// Clean up the allocated string space
			delete buf;
		}
	}
}

