#
#  RPG makefile
#
#   run "make" to compile the RPG
#   run "make remake" to recompile the RPG
#   run "make clean" to clean up the object files
#

CC = g++
CPPFLAGS = -Wall -O3 -D__GTHREAD_HIDE_WIN32API
LIBS = `allegro-config --libs` -llua -llualib -lalogg


default: install_exes
remake: clean default

clean:
	del *.o

install_exes: ..//RPG.exe


..//RPG.exe : RPG.o Console.o Canvas.o TiledMap.o Engine.o Sound.o Script.o
	$(CC) $(CPPFLAGS) -o ..//RPG.exe RPG.o Console.o Canvas.o TiledMap.o Engine.o Sound.o Script.o $(LIBS)



RPG.o         : RPG.cpp Console.h TiledMap.h Engine.h Script.h

TiledMap.o    : TiledMap.cpp TiledMap.h

Engine.o      : Engine.cpp Engine.h Console.h TiledMap.h RPG.h

Sound.o       : Sound.cpp Sound.h

Console.o     : Console.cpp Console.h

Canvas.o      : Canvas.cpp Canvas.h

Script.o      : Script.cpp Script.h
