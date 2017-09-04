#! /bin/bash

rgbasm -obuild/main.o src/main.asm
rgbasm -obuild/memory.o src/memory.asm
rgbasm -obuild/data.o src/data.asm
rgbasm -obuild/vars.o src/vars.asm

rgblink -mbuild/snek.map -nbuild/snek.sym -obuild/snek.gb build/*.o

rgbfix -v -p 0 build/snek.gb
