@echo off
echo Executing Lua script...

:: Adiciona o diretório que contém a libuv.dll ao PATH
set LIBUV_DIR=external\libuv\build\Release
set PATH=%LIBUV_DIR%;%PATH%

set LuaExecutable=external\lua\lua.exe
set ScriptPath=%1

%LuaExecutable% %ScriptPath%
