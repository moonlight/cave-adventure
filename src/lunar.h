extern "C" {
#include "lua.h"
#include "lauxlib.h"
}

template <typename T> class Lunar {
	typedef struct { T *pT; } userdataType;
public:
	typedef int (T::*mfp)(lua_State *L);
	typedef const struct rt { const char *name; mfp mfunc; } RegType;

	static void Register(lua_State *L) {
		lua_newtable(L);
		int methods = lua_gettop(L);

		luaL_newmetatable(L, T::className);
		int metatable = lua_gettop(L);

		// store method table in globals so that
		// scripts can add functions written in Lua.
		lua_pushvalue(L, methods);
		set(L, LUA_GLOBALSINDEX, T::className);

		// hide metatable from Lua getmetatable()
		lua_pushvalue(L, methods);
		set(L, metatable, "__metatable");

		lua_pushcfunction(L, tostring_T);
		set(L, metatable, "__tostring");

		lua_newtable(L);
		addmembers(L, T::getters); // fill with getters from class T
		lua_pushvalue(L, methods);
		addmethods(L, thunk, T::methods); // fill with methods from class T
		lua_pushcclosure(L, index_handler, 2);
		set(L, metatable, "__index");

		lua_newtable(L);
		addmembers(L, T::setters); // fill with setters from class T
		lua_pushcclosure(L, newindex_handler, 1);
		set(L, metatable, "__newindex");

		deletetable(L);
		lua_pushvalue(L, -1);           // dup
		lua_pushcclosure(L, gc_T, 1);   // delete table is an upvalue of gc_T
		set(L, metatable, "__gc");
		lua_pushcclosure(L, new_T, 1);  // delete table is an upvalue of new_T
		lua_pushvalue(L, -1);           // dup new_T function
		set(L, methods, "new");         // add new_T to method table

		lua_pushcclosure(L, subclass_T, 0);  // subclass table is an upvalue of subclass_T
		set(L, methods, "subclass");

		lua_newtable(L);                // mt for method table
		lua_insert(L, -2);              // swap
		set(L, -3, "__call");           // mt.__call = new_T
		lua_setmetatable(L, methods);

		lua_pop(L, 2);  // drop metatable and method table
	}

	// call named lua method from userdata method table
	static int call(lua_State *L, T *obj, const char *method,
		int nargs=0, int nresults=LUA_MULTRET)
	{
		push(L, obj);                      // userdata containing pointer to T obj
		int base = lua_gettop(L) - nargs;  // function index
		lua_insert(L, base);               // put userdata under args

		lua_pushstring(L, method);         // method name
		lua_gettable(L, base);             // get method from userdata
		if (lua_isnil(L, -1)) {            // no method?
			lua_settop(L, base-1);           // drop userdata and args
			lua_pushfstring(L, "%s missing method '%s'", T::className, method);
			return -1;
		}
		lua_insert(L, base);               // put method under userdata, args

		lua_pushliteral(L, "_TRACEBACK");
		lua_rawget(L, LUA_GLOBALSINDEX);   // get traceback function
		lua_insert(L, base);               // put it under method, userdata, args

		int status = lua_pcall(L, 1+nargs, nresults, base);  // call method
		lua_remove(L, base);               // remove traceback function
		if (status) {
			const char *msg = lua_tostring(L, -1);
			if (!msg) msg = "no message";
			lua_pushfstring(L, "%s:%s status = %d\n%s",
				T::className, method, status, msg);
			lua_remove(L, base);             // remove old message
			return -1;
		}
		return lua_gettop(L) - base + 1;   // number of results
	}

	// push onto the Lua stack a userdata containing a pointer to T object
	static int push(lua_State *L, T *obj) {
		userdataType *ud =
			static_cast<userdataType*>(lua_newuserdata(L, sizeof(userdataType)));
		ud->pT = obj;  // store pointer to object in userdata
		luaL_getmetatable(L, T::className);  // lookup metatable in Lua registry
		lua_setmetatable(L, -2);
		return 1;                 // userdata containing pointer to T object
	}

	// get userdata from Lua stack and return pointer to T object
	static T *check(lua_State *L, int narg) {
		luaL_checktype(L, narg, LUA_TUSERDATA);
		userdataType *ud =
			static_cast<userdataType*>(luaL_checkudata(L, narg, T::className));
		if(!ud) luaL_typerror(L, narg, T::className);
		return ud->pT;
	}

private:
	Lunar();  // hide default constructor

	// member function dispatcher
	static int thunk(lua_State *L) {
		// stack has userdata, followed by method args
		T *obj = check(L, 1);  // get 'self', or if you prefer, 'this'
		lua_remove(L, 1);  // remove self so member function args start at index 1
		// get member function from upvalue
		RegType *l = static_cast<RegType*>(lua_touserdata(L, lua_upvalueindex(1)));
		return (obj->*(l->mfunc))(L);  // call member function
	}

	// create a new T object and
	// push onto the Lua stack a userdata containing a pointer to T object
	static int new_T(lua_State *L) {
		lua_remove(L, 1);         // use classname:new(), instead of classname.new()
		T *obj = new T(L);        // call constructor for T objects
		push(L, obj);             // userdata containing pointer to T obj

		// store userdata in delete table so that gc_T will delete it
		lua_pushvalue(L, -1);     // dup userdata to use as key in delete table
		lua_pushboolean(L, 1);    // true value
		lua_rawset(L, lua_upvalueindex(1));  // store in delete table

		return 1;                 // userdata containing pointer to T object
	}

	// subclass this class in Lua
	static int subclass_T(lua_State *L)
	{
		allegro_message("Lunar subclass called!");
		lua_settop(L, 1);
		if (!lua_istable(L, 1)) {
			lua_newtable(L);
			lua_replace(L, 1);
		}                                  // stack: c
		lua_getmetatable(L, 1);            // stack: c cm
		lua_pushstring(L, "__index");      // stack: c cm "__index"
		lua_pushstring(L, T::className);   // stack: c cm "__index" className
		lua_gettable(L, LUA_GLOBALSINDEX); // stack: c cm "__index" p
		lua_settable(L, -3);               // stack: c cm
		lua_pushstring(L, "__call");       // stack: c cm "__call"
		lua_pushstring(L, "new");          // stack: c cm "__call" "new"
		lua_gettable(L, -4);               // stack: c cm "__call" new 
		lua_settable(L, -3);               // stack: c cm
		lua_pop(L, 1);                     // stack: c
		return 1;
	}

	// garbage collection metamethod
	static int gc_T(lua_State *L) {
		userdataType *ud = static_cast<userdataType*>(lua_touserdata(L, 1));
		T *obj = ud->pT;
		lua_pushvalue(L, -1);  // dup userdata to use as key in delete table
		lua_rawget(L, lua_upvalueindex(1));  // try lookup in delete table
		if (lua_toboolean(L, -1)) {  // check if userdata was created by new_T
			delete obj;  // call destructor for T objects
			// printf("deleted (%p)\n", obj);
		}
		return 0;
	}

	static int deletetable(lua_State *L) {
		lua_newtable(L);  // delete table has userdata created by new_T
		int deltable = lua_gettop(L);
		lua_pushvalue(L, deltable);  // delete table is its own metatable
		lua_setmetatable(L, deltable);
		lua_pushliteral(L, "__mode");
		lua_pushliteral(L, "k");
		lua_rawset(L, deltable);  // delete table.__mode = "k"
		return deltable;
	}

	static int set(lua_State *L, int table_index, const char *key) {
		lua_pushstring(L, key);
		lua_insert(L, -2);  // swap value and key
		lua_settable(L, table_index);
		return 0;
	}

	static int addmethods(lua_State *L, lua_CFunction func, RegType *l) {
		for (; l->name; l++) {
			lua_pushstring(L, l->name);
			lua_pushlightuserdata(L, (void*)l);
			lua_pushcclosure(L, func, 1);
			lua_settable(L, -3);
		}
		return 0;
	}

	static void addmembers(lua_State *L, RegType *l) {
		for (; l->name; l++) {
			lua_pushstring(L, l->name);
			lua_pushlightuserdata(L, (void*)l);
			lua_settable(L, -3);
		}
	}

	static int index_handler(lua_State *L) {
		// stack has userdata, index
		lua_pushvalue(L, 2);                     // dup index
		lua_rawget(L, lua_upvalueindex(1));      // lookup member by name
		if (!lua_islightuserdata(L, -1)) {
			lua_pop(L, 1);                         // drop nil value
			lua_pushvalue(L, 2);                   // dup index
			lua_gettable(L, lua_upvalueindex(2));  // else try methods
			if (lua_isnil(L, -1))                  // invalid member
				luaL_error(L, "cannot get member '%s'", lua_tostring(L, 2));
			return 1;
		}
		return xet_member(L);                    // call get function
	}

	static int newindex_handler (lua_State *L) {
		// stack has userdata, index, value
		lua_pushvalue(L, 2);                     // dup index
		lua_rawget(L, lua_upvalueindex(1));      // lookup member by name
		if (!lua_islightuserdata(L, -1))         // invalid member
			luaL_error(L, "cannot set member '%s'", lua_tostring(L, 2));
		return xet_member(L);                    // call set function
	}

	static int xet_member (lua_State *L) {
		RegType *l = static_cast<RegType*>(lua_touserdata(L, -1));
		lua_pop(L, 1);     // drop lightuserdata
		userdataType *ud = static_cast<userdataType*>(lua_touserdata(L, 1));
		T *obj = ud->pT;
		lua_remove(L, 2);  // remove index
		lua_remove(L, 1);  // remove userdata
		return (obj->*(l->mfunc))(L);  // call get function
	}

	static int tostring_T (lua_State *L)
	{
		char buff[sizeof(T::className)+24];
		userdataType *ud = static_cast<userdataType*>(lua_touserdata(L, 1));
		T *obj = ud->pT;
		sprintf(buff, "%s (%p)", T::className, obj);
		lua_pushstring(L, buff);
		return 1;
	}
};
