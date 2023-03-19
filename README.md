# Rayed BQN
Rayed bqn is a library made to write windowed applications using the [BQN programming language](https://mlochbaum.github.io/BQN/).
It interops with [Raylib](https://github.com/raysan5/raylib), but changes a lot of the functions to be more in-lined with BQN's syntax.

## Getting started
First download [raylib](https://github.com/raysan5/raylib/releases/) and place it inside this project, at the same level as tests, rayffi.bqn and raylib.bqn and rename the raylib folder to "raylibSorce".
The most important file here is raylib.dll file (or libraylib.so on linux), located at:
./rayed-bqn/raylibSorce/lib/raylib.dll 

## Windows
On windows you should be ready to go.

## Linux
I have not finished making this library work well for linux, so if you try, expect issues. Making the tests work on linux is on my todo list.

# Credits
I owe credit to [@nulldatamap](https://gist.github.com/nulldatamap) for showing a lovely [example](https://gist.github.com/nulldatamap/30b10389bf91d6f25bb262da9c9e9709) to get me started with using FFI for BQN, and for making it easy to start with making this library.