#!/bin/sh
#
# Updates the data.dat file, using the Allegro
# dat tool.

dat -a -t BMP  -c2 -k data.dat data/bitmaps/*.bmp
dat -a -t BMP  -c2 -k data.dat data/bitmaps/*.tga
dat -a -t FONT -c2 -k data.dat data/bitmaps/font_*.pcx
dat -a -t LUA  -c2 -k data.dat data/scripts/*.lua
