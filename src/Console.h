/*
 *  The Moonlight RPG engine  (see readme.txt about version info)
 *  By Bjørn Lindeijer
 *
 ************************************************************************************/

#ifndef _INCLUDED_CONSOLE_H_
#define _INCLUDED_CONSOLE_H_
#include <stdio.h>
#include <list>

using namespace std;


#define CON_CONSOLE		1
#define CON_LOG			2
#define CON_QUIT		4
#define CON_POPUP		8

#define CON_ALWAYS		1
#define CON_DEBUG		2
#define CON_VDEBUG		4


class Console
{
public:
	Console(const char* filename);
	~Console();

	void update();
	void draw(BITMAP *dest);
	bool handleInput(int key);
	void log(int where, int when, const char* what, ...);

private:
	FILE* logFile;
	char* logFilename;
	list<char*> logMessages;
	bool active;
	int progress;
};


#endif