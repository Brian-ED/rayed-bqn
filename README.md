# Rayed BQN
Rayed BQN is a library made to write cross-platform applications using the [BQN programming language](https://mlochbaum.github.io/BQN/).
It inter-ops with [raylib](https://github.com/raysan5/raylib) via [FFI](https://mlochbaum.github.io/BQN/spec/system.html#foreign-function-interface-ffi), but changes a lot of raylib's functions to be more in-lined with BQN's syntax.

Breaking changes to any feature in rayed.bqn should be expected for now, as this library is very young and experimental.
`imports/raylib-bqn/raylib.bqn` from [raylib-bqn](https://github.com/Brian-ED/raylib-bqn) contains the bindings to raylib. Because of [c-header-to-bqn-ffi](https://github.com/Brian-ED/c-header-to-bqn-ffi) for parsing `raylib.h`, the binding is made automatically.

# Getting started
Rayed-bqn works on Windows, Linux and MacOS.
Make sure you've installed [git](https://git-scm.com/downloads) and CBQN on [Windows](https://github.com/vylsaz/cbqn-win-docker-build/releases), [Linux](https://github.com/dzaima/CBQN) or [MacOS](https://github.com/dzaima/CBQN). Rayed-bqn works with CBQN version 0.7.0, and hopefully >0.7.0 as well.

Make sure bqn is on `PATH`. To check, run `bqn` in the terminal, in the case of windows it's the `Command Prompt` or `Windows PowerShell`. Then type `1+1` in the terminal and get `2`. If `bqn` wasn't found, and you're on linux or mac, make sure you've installed CBQN correctly and ran `sudo make install` - and if you're on windows, add the bqn folder from [cbqn-win-docker-build](https://github.com/vylsaz/cbqn-win-docker-build/releases) to PATH, [here's a tutorial](https://www.computerhope.com/issues/ch000549.htm).

First step in installing is cloning rayed-bqn and installing raylib by typing the following in the terminal:
```SH
git clone --filter=blob:none --recurse-submodules https://github.com/Brian-ED/rayed-bqn.git
bqn rayed-bqn/install-raylib.bqn
```

Run the following example to make sure rayed-bqn is set up properly:
```SH
bqn rayed-bqn/examples/1_shapes/circleInsideSquares.bqn
```

### Explanation
`git clone` has the option [`--filter=blob:none`](https://github.blog/open-source/git/get-up-to-speed-with-partial-clone-and-shallow-clone/) to clone the repository faster, and [`--recurse-submodules`](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to also install the submodules automatically.

Running `bqn install-raylib.bqn` downloads [raylib](https://github.com/raysan5/raylib/releases/) with release 5.0. In the case of windows, this is `raylib-5.0_win64_msvc16`. It then takes the shared-binary from `raylib/lib/` folder and places it in `rayed-bqn/lib/`.

# Tested raylib versions:
`raylib-4.5.0_win64_mingw-w64` on Windows 10  
raylib version 4.5.0 built from source on Pop!_OS.  
raylib version 4.5.0 built from source on Ubuntu 22.04.2 LTS.  
raylib version 5.0.0 built from source on Ubuntu 22.04.2 LTS.  
raylib version 5.0.0 via homebrew on mac  


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
