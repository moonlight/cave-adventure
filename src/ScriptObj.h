/*
** Functions and globals to implement an object
** system based on tables. Uses delagation style
** inheritance, but differentiates between "class"
** objects and "instance" objects.
** 
** Last Update  2002-05-11  TeW
*/

#ifndef _INCLUDED_SCRIPTOBJ_H_
#define _INCLUDED_SCRIPTOBJ_H_

// Lua usage: myobject = newobj(myclass, ...init values...)
//        or: myobject = myclass:new(...init values...)
int tobj_newobj(lua_State* L);

// Lua usage: myclass = newclass(parentclass, [existingtable])
//        or: myclass = parentclass:subclass([existingtable])
int tobj_newclass(lua_State* L);

// index "tag" method: index(table, index)
int tobj_keylookup(lua_State* L);

// Open Tom library
int lua_tobjlibopen(lua_State *L);

#endif