---------------------------------------
Moonlight productions :: Cave Adventure
---------------------------------------

Here is our second small RPG, a Cave Adventure. It's been made for the Spring 
2003 MiniRPG compo. After washing down a river, Frode (the main character) fell 
down a waterfall and just managed to reach out for a branch that was hanging 
about halfway down. Incidently, swinging towards the rock side, there happens to 
be an entrance to a cave behind the wall of water. Frode has the choice between 
either falling drop dead on the rocks below the waterfall or entering the cave 
to face the perils within. Naturally, in the spirit of bold exploration, he 
enters the cave...


  Moonlight Productions (the part that worked on this game):

  Bjørn Lindeijer         (engine, scripts, graphics)
  Georg Muntingh          (maps, scripts, graphics)
  Frode Lindeijer         (graphics)


Have fun playing our game, we had great fun in making it!

The game can be found on: http://www.rpgdx.net


--------
Controls
--------

To prevent you from wasting minutes searching for the right keys, we present 
them to you here.

 Arrow keys - Move your character
 Spacebar   - Examine / Talk / Use / Activate / Continue dialogue
 Ctrl       - Attack


------------------------
The Moonlight RPG engine
------------------------

The DGE RPG uses the Moonlight RPG engine, which is licensed under GPL and will 
be distributed seperately when it's mature enough. Its current specifications 
are:

- Allegro for graphics, keyboard input and timers
- AllegroOGG for OGG file playback
- Using the Lua extension language for the scripting
- Using object oriented, flexible tile engine
- Comes with its own map/tile editor
- Allows use of multiple tile bitmaps per map, and the other way around


-------------------
Config file options
-------------------

In RPG.cfg you can specify if you want to run the RPG fullscreen or windowed.
You can also enable vsync there (might look smoother for some users). Further 
more, if you are running in windowed mode, you might want to enable the double 
size feature. You can also use this with the fullscreen mode if your videocard 
doesn't support 320x240 high/truecolor modes.

If the game runs choppy, try reducing the colordepth to 16 or 15 bit.


-------
History
-------

March, 7th -:-- (First post-contest release)

- Added 24 and 32 bit colordepth support (32 enabled by default)
- Added second layer to maps, above the objects
- Added music
/ Added level name when entering level
- Added experience/levelup system
/ Added inventory
- Added new enemy type, Spider Queen
- Added engine support for custom fonts
- Improved Game Over screen
- Improved GUI
- Fixed little bug in linear animations
- Fixed color of damage splats on spiders


April, 29th 2:00 (First public release)
