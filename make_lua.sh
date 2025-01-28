#!/bin/bash

# Definindo diretório do Lua
LUA_DIR="external/lua"

# Acesse o diretório do Lua
cd $LUA_DIR

# Remover arquivos de build anteriores
rm -f *.o *.so lua liblua.a

# Compilando arquivos .c para .o com otimizações
gcc -O2 -fPIC -I. -DLUA_USE_DLOPEN -c *.c

rm -rf onelua.o

# Linkando arquivos objeto para criar a biblioteca compartilhada (liblua.so)
gcc -shared -o liblua.so *.o -lm

# Linkando para gerar o executável lua
gcc -o lua lua.o -L. -llua -lm

# Caso queira gerar o executável luac
# gcc -o luac luac.o -L. -llua -lm

# Limpando objetos
rm -f *.o
