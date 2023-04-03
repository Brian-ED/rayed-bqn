# Rayed BQN
Rayed bqn is a library made to write windowed applications using the [BQN programming language](https://mlochbaum.github.io/BQN/).
It interops with [Raylib](https://github.com/raysan5/raylib), but changes a lot of the functions to be more in-lined with BQN's syntax.

Breaking changes to any feature in raylib.bqn should be expected for now, as this library is very young and experimental. 
raylib.ffi is only for bindings and therefore shouldn't change, so you can probably rely on those, but no guarentees.

## Getting started
First download [raylib](https://github.com/raysan5/raylib/releases/) and place it inside this project, at the same level as tests, rayffi.bqn and raylib.bqn and rename the raylib folder to "raylibSorce".

Tested raylib versions:
"raylib-4.5.0_win64_mingw-w64" on windows 10

The binary file in raylib differs from OS to OS,
On Windows: raylib.dll
On MacOS:   libraylib.dylib   (I think)
On linux:   libraylib.so

The most important file in raylibSorce is the binary file, which should be located at:
./rayed-bqn/raylibSorce/lib/(BINARY)

## Windows
On windows you should be ready to go.

## Linux
I have not finished making this library work well for linux, so if you try, expect issues. Making the tests work on linux is on my todo list.

## Mac
I have never tested mac, but it could be similar to Linux.

# Ideologies
Having as little magic as possible, magic meaning magic numbers and global values (available to the user) changing outside user's control.

# Credits
Lots of thanks to [@dzaima](https://github.com/dzaima) for helping with FFI.

I owe credit to [@nulldatamap](https://gist.github.com/nulldatamap) for showing a lovely [example](https://gist.github.com/nulldatamap/30b10389bf91d6f25bb262da9c9e9709) to get me started with using FFI for BQN, and for making it easy to start with making this library.