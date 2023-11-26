# Rayed BQN
Rayed BQN is a library made to write windowed applications using the [BQN programming language](https://mlochbaum.github.io/BQN/).
It inter-ops with [Raylib](https://github.com/raysan5/raylib), but changes a lot of the functions to be more in-lined with BQN's syntax.

Breaking changes to any feature in raylib.bqn should be expected for now, as this library is very young and experimental. 
raylib.ffi is only for bindings and therefore shouldn't change, so you can probably rely on those, but no guarantees.

# Getting started

## Windows


First, clone rayed-bqn
```SH
git clone https://github.com/Brian-ED/rayed-bqn.git
cd rayed-bqn
git submodule update --init --recursive
cd ..
```

second download [Raylib](https://github.com/raysan5/raylib/releases/) with release `raylib-VERSION_win64_mingw-w64`(replace `VERSION` with whichever is latest, it should be most stable) and place it inside this project, at the same level as tests, rayffi.bqn and raylib.bqn and rename the raylib folder to "raylib".

## Linux

First, clone rayed-bqn
```SH
git clone https://github.com/Brian-ED/rayed-bqn.git
cd rayed-bqn
git submodule update --init --recursive
cd ..
```

Next, Build [raylib](https://github.com/raysan5/raylib/) and install it:
```sh
git clone https://github.com/raysan5/raylib.git
cd raylib/src
make RAYLIB_LIBTYPE=SHARED
sudo make install RAYLIB_LIBTYPE=SHARED
cd ../../
```

Now run an example, if it doesn't work please post an issue.

## Mac
This section is based on other user reports as I have never tested mac.

First, clone rayed-bqn
```SH
git clone https://github.com/Brian-ED/rayed-bqn.git
cd rayed-bqn
git submodule update --init --recursive
cd ..
```

Next, install [raylib](https://github.com/raysan5/raylib/). If you use [Homebrew](https://brew.sh) this is very straightforward: just run
```SH
brew install raylib
```

And the raylib `.dylib` and header files will be installed to the usual `/opt` locations. But you'll need to change your `config.txt` file to point at this location. You can just create a `config.txt` file in the root `rayed-bqn` folder, or try to run any of the examples (which will fail, but they'll create a `config.txt` file you can edit).
In the `config.txt` file set `raylib` to point to the homebrew location as follows:
```
raylibPath:/opt/homebrew/lib/libraylib.dylib
```

That should be immune to any raylib version changes that occur if you ever upgrade your local installation.

If you don't use homebrew you can use the normal linux instructions above to clone and build a local raylib installation. Just set the `raylibPath` accordingly. Note you'll need raylib's header file, not just the `.dylib`, for the next step.

### If you receive errors about undefined symbols
Undefined symbols usually occur on foot of raylib library updates (though raylib is pretty stable). To fix these, you need to re-parse the yarlib header to update your local auto-generated wrapper. Run the following:

```SH
BQN src/parseC_FFI_BQN/parseRaylibJson.bqn
```

After that run one of the example files to see if you've resolved the issue, e.g.
```SH
BQN examples/1_shapes/DrawEllipse.bqn
```


# Tested Raylib versions:

## Windows

"raylib-4.5.0_win64_mingw-w64" on Windows 10

## Linux

Raylib version 4.5.0 built from source on Pop!_OS.
Raylib version 4.5.0 built from source on Ubuntu 22.04.2 LTS.
Raylib version 5.0.0 built from source on Ubuntu 22.04.2 LTS.

## Mac

Raylib version 5.0.0 via homebrew

# Extra info

## config file

A config file named "config.txt" will be generated at `./rayed-bqn/config.txt`. Each line of this file has one colon, with a keyword before the colon to indicate the config and after colon is a value to set that config to. If there are two lines with same config, then the bottom most line is picked.

The only values supported for now is the path to binary.

The binary being one of the following raylib.ddl/libraylib.so/etc.
examples are below:

```txt
raylibPath:raylib/lib/raylib.dll
```

```txt
raylibPath:raylib/lib/libraylib.so
```


The most important file in ./raylib/lib/ is the binary file, which could be located at:
windows: ./rayed-bqn/raylib/lib/raylib.dll
linux: /usr/local/lib/libraylib.so"
macOS: ./some/path/libraylib.dylib (I think)

# Ideologies

Having as little magic as possible, magic meaning magic numbers and global values (available to the user) changing outside user's control.

Mutations localized in namespaces like "clock" are fine.

# Contributing

If you have any questions on contributing to this project, feel free to mention me on the bqn forum that's mentioned on the [bqn-wiki](https://mlochbaum.github.io/BQN/index.html#where-can-i-find-bqn-users), my username is Brian E.

You can submit however many issues as you'd like, I see them as a TODO list.

You can make pull requests and submit them for merges if you'd like, though be sure to discuss with me for any features you add to make sure you didn't put in wasted effort, though if it's mentioned in a github-issue and isn't taken do make sure you say you're working on it. Also say when you've stopped working on it, and share the roadblocks and progress, so someone can continue where you left off.

# Credits

Lots of thanks to [@dzaima](https://github.com/dzaima) for helping with FFI.

I owe credit to [@nulldatamap](https://gist.github.com/nulldatamap) for showing a lovely [example](https://gist.github.com/nulldatamap/30b10389bf91d6f25bb262da9c9e9709) to get me started with using FFI for BQN, and for making it easy to start with making this library.
