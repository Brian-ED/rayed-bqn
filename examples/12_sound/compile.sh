#!/bin/bash
gcc "$1.c" -c -I/home/brian/CBQNStuffs/CBQN/include/ -fPIC
gcc -shared -o "$1.so" "$1.o"
rm "$1.o"
echo "done"