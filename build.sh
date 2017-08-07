#! /bin/bash

rgbasm -obuild/main.o main.asm
rgbasm -obuild/memory.o memory.asm
rgbasm -obuild/data.o data.asm

rgblink -mbuild/snek.map -nbuild/snek.sym -obuild/snek.gb build/main.o build/memory.o build/data.o

rgbfix -v build/snek.gb
