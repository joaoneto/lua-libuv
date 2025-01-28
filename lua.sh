#!/bin/bash
echo "Executing Lua script..."

# Define the path to libuv.dll (or equivalent libuv.so for Linux/Mac)
LUA_DIR="./external/lua"
LIBUV_DIR="./external/libuv/build"

export LD_LIBRARY_PATH="$LUA_DIR:$LIBUV_DIR/lib:$LD_LIBRARY_PATH"
export PATH="$PATH:$LUA_DIR:$LIBUV_DIR/lib"

LuaExecutable="$LUA_DIR/lua"
ScriptPath=$1

$LuaExecutable $ScriptPath
