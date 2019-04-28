#include "ldk.h"

#include <lauxlib.h>
#include <stdbool.h>
#include <string.h>

static int array_shrink(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer size = luaL_len(L, 1);
    lua_Integer n = luaL_checkinteger(L, 2);
    while (size > n)
    {
        lua_pushnil(L);
        lua_seti(L, 1, size--);
    }
    return 0;
}

static int array_grow(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer size = luaL_len(L, 1);
    lua_Integer n = luaL_checkinteger(L, 2);

    if (size == 0)
    {
        return 0;
    }

    lua_geti(L, 1, size);
    while (n-- > 0)
    {
        lua_pushvalue(L, -1);
        lua_seti(L, 1, ++size);
    }

    lua_pop(L, -1);
    return 0;
}

// clang-format off
static const struct luaL_Reg funcs[] =
{
#define XX(name) { #name, array_ ##name },
    XX(shrink)
    XX(grow)
    { NULL, NULL }
#undef XX
};
//clang-format on

_LDK_EXTERN int luaopen_ldk_array_native(lua_State *L)
{
  lua_newtable(L);
  luaL_setfuncs(L, funcs, 0);
  return 1;
}

