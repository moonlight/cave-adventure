/*
** Functions and globals to implement an object
** system based on tables. Uses delagation style
** inheritance, but differentiates between "class"
** objects and "instance" objects.
** 
** Last Update  2002-05-11  TeW
*/

#include <allegro.h>
#include "Script.h"
#include "ScriptObj.h"


// Lua usage: myobject = newobj(myclass, ...init values...)
//        or: myobject = myclass:new(...init values...)
int tobj_newobj(lua_State* L)
{
	allegro_message("New object created");
    int initargs;

    // check if no class supplied
	if (!lua_istable(L, 1)) {
		return 0;
	}

	// Figure out how many _init arguments are on the stack
	initargs = lua_gettop(L) - 1;

    // Create new table to be the object
    lua_newtable(L);  // stack: CL ... OBJ

    // Set the event table to ObjectEvents
	lua_getglobal(L, "ObjectEvents");
	lua_setmetatable(L, -2); // stack: CL ... OBJ

	// Set the _parent slot
	lua_pushstring(L, "_parent");
	lua_pushvalue(L, 1); // stack; CL ... OBJ "_parent" CL
	lua_rawset(L, -3);  // stack: CL ... OBJ

	// Check if there's an _init function in the class
	lua_pushstring(L, "_init");
	lua_gettable(L, 1);  // stack: CL ... OBJ _init()
    if (lua_isfunction(L, -1))
	{
		lua_insert(L, 2);
		lua_insert(L, 2); // stack: CL OBJ _init() ...
		lua_pushvalue(L, 2);
		lua_insert(L, 4); // stack: CL OBJ _init() OBJ ...
		lua_call(L, initargs + 1, 0);
	}
	else {
		lua_pop(L, 1);
		lua_insert(L, 2);
		lua_settop(L, 2);  // stack: CL OBJ
	}

	// Done, return the new table
	return 1;
}


// Lua usage: myclass = newclass(parentclass, [existingtable])
//        or: myclass = parentclass:subclass([existingtable])
int tobj_newclass(lua_State* L)
{
	int t = lua_gettop(L);
	allegro_message("New class created (%d)", t);

	// Ensure stack is: SUPERCLASS  SUBCLASS
	if (t == 0) {
		lua_pushnil(L);
		lua_newtable(L);
	}
	else if (t == 1) {
		lua_newtable(L);
	}

	// Set the _parent slot of the new table to the superclass
	lua_pushstring(L, "_parent");
	lua_pushvalue(L, 1);
	lua_rawset(L, -3);

	// Set the event table for the new class object
	lua_getglobal(L, "ClassEvents");
	lua_setmetatable(L, -2);

	// Done, return the new class table
	return 1;
}



// index "tag" method: index(table, index)
int tobj_keylookup(lua_State* L)
{
	lua_settop(L, 2);
	lua_pushvalue(L, 2);               // <table><index><index>
	lua_rawget(L, 1);                  // <table><index><rawval>
	if (lua_isnil(L, 3)) {
		lua_settop(L, 2);              // <table><index>
		lua_pushstring(L, "_parent");  // <table><index><string>
		lua_rawget(L, 1);              // <table><index><parent>
		if (lua_isnil(L, 3)) return 1;
		lua_remove(L, 1);
		lua_insert(L, 1);              // <parent><index>
		lua_gettable(L, 1);
	}
	return 1;
}

/*
** Open Tom library
*/
int lua_tobjlibopen(lua_State *L)
{
	allegro_message("Opening object lib");
	// Register related functions
	lua_register(L, "newobj",   tobj_newobj);
	lua_register(L, "newclass", tobj_newclass);

	// Setup the event table for classes
	lua_newtable(L);
	lua_pushstring(L, "__index");
	lua_pushcfunction(L, tobj_keylookup);
	lua_rawset(L, -3);
	lua_setglobal(L, "ClassEvents");

	// Setup the event table for objects
	lua_newtable(L);
	lua_pushstring(L, "__index");
	lua_pushcfunction(L, tobj_keylookup);
	lua_rawset(L, -3);
	lua_setglobal(L, "ObjectEvents");

	// Setup "Object" as an (optional) root class
	lua_settop(L, 0);
	lua_newtable(L);
	lua_getglobal(L, "ClassEvents");
	lua_setmetatable(L, 1);
	lua_pushstring(L, "new");
	lua_pushcfunction(L, tobj_newobj);
	lua_rawset(L, 1);
	lua_pushstring(L, "subclass");
	lua_pushcfunction(L, tobj_newclass);
	lua_rawset(L, 1);
	lua_setglobal(L, "Object");

	return 0;
}
