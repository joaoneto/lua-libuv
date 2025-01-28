LIBUV_REPO := https://github.com/libuv/libuv
LIBUV_VERSION := v1.50.0
LUA_REPO := https://github.com/lua/lua
LUA_VERSION := v5.4.7

EXTERNAL_DIR := external
LIBUV_DIR := $(EXTERNAL_DIR)/libuv
LUA_DIR := $(EXTERNAL_DIR)/lua
MODULES_DIR := modules
SRC_DIR := src

CC := gcc
CFLAGS := -O2 -fPIC -I$(LUA_DIR) -I$(LIBUV_DIR)/build/include -I$(LIBUV_DIR)/include 
LDFLAGS := -L$(LUA_DIR) -L$(LIBUV_DIR)/build/lib -L$(LIBUV_DIR)/build/Release -llua -luv

ifeq ($(OS),Windows_NT)
    MKDIR := mkdir
    RM := rmdir /S /Q
    SHELL := cmd
else
    MKDIR := mkdir -p
    RM := rm -rf
endif

.PHONY: all clean externals build_lua build_libuv build_modules

all: externals build_lua build_libuv build_modules

externals:
	@echo "Ensuring externals exist..."
	git submodule update --init --recursive
	@cd $(LIBUV_DIR) && git checkout $(LIBUV_VERSION) --force
	@cd $(LUA_DIR) && git checkout $(LUA_VERSION) --force

build_libuv:
	@echo "Building libuv..."
ifeq ($(OS),Windows_NT)
	cd $(LIBUV_DIR) && if not exist build $(MKDIR) build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && cmake --build . --config Release
else
	cd $(LIBUV_DIR) && $(MKDIR) build && ./autogen.sh && ./configure --prefix=$(realpath $(LIBUV_DIR))/build && make && make install
endif

build_lua:
	@echo "Building Lua..."
ifeq ($(OS),Windows_NT)
	.\make_lua.bat
else
	@bash ./make_lua.sh
endif

build_modules:
	@echo "Building modules..."
ifeq ($(OS),Windows_NT)
		if not exist $(MODULES_DIR) $(MKDIR) $(MODULES_DIR)
		for /R $(SRC_DIR) %%f in (*.c) do $(CC) -o $(MODULES_DIR)\%%~nf.dll -shared %%f $(CFLAGS) $(LDFLAGS) -Wl,--export-all-symbols
else
		@if [ ! -d "$(MODULES_DIR)" ]; then $(MKDIR) $(MODULES_DIR); fi
		@for cfile in $(SRC_DIR)/*.c; do \
			module_name=$$(basename $$cfile .c); \
			$(CC) -o $(MODULES_DIR)/$$module_name.so -shared $$cfile $(CFLAGS) $(LDFLAGS); \
		done
endif

clean:
	@echo "Cleaning build artifacts..."
	$(RM) $(EXTERNAL_DIR)
