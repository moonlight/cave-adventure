#
#  RPG makefile
#
#   run "make" to compile the RPG and RPG Edit
#   run "make remake" to recompile everything
#   run "make clean" to clean up the object files
#

CC = g++
CPPFLAGS = -Wall -O3


default: install_exes
remake: clean default

clean:
	del *.o

install_exes: ..//RPG.exe


..//RPG.exe : RPG.o Console.o Canvas.o TiledMap.o Engine.o Sound.o Script.o
	$(CC) $(CPPFLAGS) -o ..//RPG.exe RPG.o Console.o Canvas.o TiledMap.o Engine.o Sound.o Script.o -lalleg -llua -llualib


RPG.o         : RPG.cpp Console.h TiledMap.h Engine.h Script.h

TiledMap.o    : TiledMap.cpp TiledMap.h

Engine.o      : Engine.cpp Engine.h DRS.h GUI.h Console.h tiledmap.h RPG.h

Sound.o       : Sound.cpp Sound.h

Console.o     : Console.cpp Console.h

Canvas.o      : Canvas.cpp Canvas.h

Script.o      : Script.cpp Script.h