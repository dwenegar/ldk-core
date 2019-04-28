/***
 * Extensions to the `debug` module.
 * @module ldk.debugx
 */

#include "ldk.h"

#include <assert.h>
#include <lauxlib.h>
#include <stdbool.h>
#include <string.h>

static int find_env(lua_State *L)
{
    int i = 0;
    while (true)
    {
        const char *up_name = lua_getupvalue(L, -1, ++i); // function upvalue
        if (up_name == NULL)
        {
            return 0;
        }
        lua_pop(L, 1); // function
        if (strcmp(up_name, "_ENV") == 0)
        {
            return i;
        }
    }
}

/**
 * Gets the environment used by a given function.
 *
 * @function getenv
 * @tparam function f the function to get the environment of.
 * @treturn table the environment of the give function.
 */
static int debugx_getfenv(lua_State *L)
{
    if (lua_iscfunction(L, 1))
    {
        lua_pushglobaltable(L);
        return 1;
    }

    lua_Debug ar;
    if (lua_isfunction(L, 1))
    {
        lua_pushvalue(L, 1);
    }
    else if (!lua_getstack(L, (int)luaL_checkinteger(L, 1), &ar))
    {
        lua_pushnil(L);
        return 1;
    }
    int i = find_env(L);
    if (i == 0)
    {
        return 0;
    }
    lua_getupvalue(L, 1, i);
    return 1;
}

/**
 * Sets the environment to be used by a given function.
 *
 * @function setfenv
 * @tparam function f the function to get the environment of.
 * @treturn table the environment of the give function.
 */
static int debugx_setfenv(lua_State *L)
{
    if (lua_iscfunction(L, 1))
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    luaL_checktype(L, 1, LUA_TFUNCTION);
    luaL_checktype(L, 2, LUA_TTABLE);

    lua_Debug ar;
    if (lua_isfunction(L, 1))
    {
        lua_pushvalue(L, 1);
    }
    else if (!lua_getstack(L, (int)luaL_checkinteger(L, 1), &ar))
    {
        lua_pushboolean(L, 0);
        return 1;
    }

    int i = find_env(L);
    if (i == 0)
    {
        lua_pushboolean(L, 0);
        return 1;
    }
    luaL_loadstring(L, "return x");  // dummy
    lua_pushvalue(L, 2);             // dummy env
    lua_setupvalue(L, -2, 1);        // dummy
    lua_upvaluejoin(L, 1, i, -1, 1); // dummy
    lua_pop(L, 1);                   //
    lua_pushboolean(L, 1);
    return 1;
}

// clang-format off
static const struct luaL_Reg funcs[] =
{
#define XX(name) { #name, debugx_ ##name },
    XX(getfenv)
    XX(setfenv)
    { NULL, NULL }
#undef XX
};
//clang-format on

_LDK_EXTERN int luaopen_ldk_debugx(lua_State *L)
{
  lua_newtable(L);
  luaL_setfuncs(L, funcs, 0);
  return 1;
}
