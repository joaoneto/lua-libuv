@echo off
REM Definindo o prompt do desenvolvedor para o Visual Studio 2019
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"

cd external\lua

REM Remove arquivos de build
del *.dll
del *.o
del *.exe
del *.obj

REM Compilando arquivos .c para .obj com otimizações
cl /MD /O2 /c /DLUA_BUILD_AS_DLL *.c

REM Renomeando os objetos gerados
ren lua.obj lua.o
ren luac.obj luac.o

REM Deletando arquivos se existirem
if exist onelua.obj del onelua.obj

REM Linkando arquivos objeto para criar a DLL
link /DLL /IMPLIB:lua.lib /OUT:lua.dll *.obj

REM Linkando para gerar o executável
link /OUT:lua.exe lua.o lua.lib
