#!/bin/bash
echo "Executing Lua script..."

# Define the path to libuv.dll (or equivalent libuv.so for Linux/Mac)
LIBUV_DIR="external/libuv/build/Release"
export LD_LIBRARY_PATH=$LIBUV_DIR:$LD_LIBRARY_PATH

LuaExecutable="external/lua/lua"
ScriptPath=$1

$LuaExecutable $ScriptPath
