#! /bin/bash

rgbasm -obuild/main.o main.asm
rgbasm -obuild/memory.o memory.asm
rgbasm -obuild/data.o data.asm
rgbasm -obuild/vars.o vars.asm

rgblink -mbuild/snek.map -nbuild/snek.sym -obuild/snek.gb build/*.o

rgbfix -v -p 0 build/snek.gb
