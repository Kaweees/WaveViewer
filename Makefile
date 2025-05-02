# --- Emscripten ---
# !!! ADJUST THIS PATH to your emsdk installation !!!
EMCONFIGURE := emconfigure
EMMAKE      := emmake
EMCC        := emcc
EMCXX       := em++

# --- Directories ---
IMGUI_DIR    := imgui
NGSPICE_DIR  := ngspice

# --- ngspice ---
# The exact output library path/name might differ depending on ngspice build configuration.
# Emscripten often produces .a or .bc files. Check the ngspice build output.
NGSPICE_LIB := $(NGSPICE_DIR)/src/libngspice.a

# --- Application ---
APP_MAIN_SRC := src/main.cpp # Your main application source file
APP_OUT      := waveviewer.html # Final output name (HTML + JS + WASM)

# --- ImGui Sources ---
IMGUI_SOURCES := $(IMGUI_DIR)/backends/imgui_impl_glfw.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp
IMGUI_SOURCES += $(IMGUI_DIR)/imgui.cpp $(IMGUI_DIR)/imgui_draw.cpp $(IMGUI_DIR)/imgui_demo.cpp $(IMGUI_DIR)/imgui_widgets.cpp $(IMGUI_DIR)/imgui_tables.cpp

# --- All Application Sources ---
APP_SOURCES := $(APP_MAIN_SRC) $(IMGUI_SOURCES)

# --- Compiler/Linker Flags ---
# Include paths
CPPFLAGS := -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
# Add ngspice includes if your main app needs them directly
# CPPFLAGS += -I$(NGSPICE_DIR)/src/include

# C++ Compiler Flags
CXXFLAGS := -std=c++11 -O2

# Linker Libraries
LDFLAGS := -lGL

# Emscripten Specific Flags (Combined)
EM_FLAGS := -s WASM=1
EM_FLAGS += -s USE_WEBGL2=1 -s USE_GLFW=3 -s FULL_ES3=1 # WebGL/GLFW for ImGui
EM_FLAGS += -s ALLOW_MEMORY_GROWTH=1                  # Memory growth for ngspice?
EM_FLAGS += -s ERROR_ON_UNDEFINED_SYMBOLS=0           # Use cautiously, might hide issues
EM_FLAGS += -s EXPORTED_FUNCTIONS="['_main','_ngSpice_Init','_ngSpice_Command']" # Adjust if app exports more/different functions
EM_FLAGS += -s EXIT_RUNTIME=1                         # Exit runtime after main() finishes
# EM_FLAGS += --preload-file data                      # Uncomment if you need to bundle data files

# Default target: Build the final application
# Depends on the application output file
all: $(APP_OUT)

# --- Build Rules ---

# Build ngspice library for WASM
$(NGSPICE_LIB):
	@echo ">> Building ngspice as WASM library..."
	cd $(NGSPICE_DIR) && \
	 echo ">> Running autoreconf..." && \
	 autoreconf -f -i && \
	 echo ">> Configuring ngspice for Emscripten..." && \
	 YACC="bison -y" BISON="bison" CFLAGS="-Devent_auto_incr=1" $(EMCONFIGURE) ./configure \
		--disable-debug \
		--disable-openmp --disable-xspice --without-x \
		--enable-static --disable-shared \
		--without-readline && \
	 echo ">> Building ngspice library..." && \
	 $(EMMAKE) make CFLAGS="-Devent_auto_incr=1" && \
	 cd src && find . -name '*.o' > object_files.txt && emar rcs libngspice.a $$(cat object_files.txt)

# Build the C++ application linking ngspice and ImGui
$(APP_OUT): $(APP_SOURCES) $(NGSPICE_LIB) $(IMGUI_DIR)/imgui.h
	@echo ">> Building application and linking with ngspice & ImGui..."
	$(EMCXX) $(CXXFLAGS) $(CPPFLAGS) $(APP_SOURCES) $(NGSPICE_LIB) -o $(APP_OUT) $(LDFLAGS) $(EM_FLAGS)

# --- Clean Rule ---
clean:
	@echo ">> Cleaning build artifacts..."
	rm -f $(APP_OUT) *.js *.wasm # Remove application output
	rm -rf $(NGSPICE_DIR)         # Remove cloned ngspice directory

.PHONY: all clean
