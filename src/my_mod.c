#include <lua.h>
#include <lauxlib.h>

int helloworld(lua_State *L)
{
    lua_pushstring(L, "Hello world");
    return 1;
}

static const luaL_Reg functions[] = {
    {"helloworld", helloworld},
    {NULL, NULL},
};

int luaopen_my_mod(lua_State *L)
{
    luaL_newlib(L, functions);
    return 1;
}
