{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  # Native build inputs (tools needed to run on your machine)
  nativeBuildInputs = [
    pkgs.pkg-config # Helps find libraries like GLFW
  ];

  # Build inputs (libraries and tools needed for the project)
  buildInputs = [
    pkgs.clang-tools # 
    pkgs.emscripten # C/C++ to WebAssembly compiler and SDK
    pkgs.glfw # Windowing and input library
    # OpenGL/GLES headers are typically provided by emscripten's environment
  ];

  # Shell hook to set up environment
  shellHook = ''
    # Set a writable cache directory for Emscripten
    export EM_CACHE=$HOME/.emscripten_cache
    mkdir -p $EM_CACHE # Ensure the directory exists
    # Uncomment these lines if you encounter issues finding GLFW or other libraries later
    # export CPLUS_INCLUDE_PATH=${pkgs.glfw}/include:${pkgs.emscripten}/system/include:$CPLUS_INCLUDE_PATH
    # export LIBRARY_PATH=${pkgs.glfw}/lib:${pkgs.emscripten}/system/lib:$LIBRARY_PATH
  '';
}
