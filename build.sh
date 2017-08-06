#! /bin/bash

rgbasm -obuild/main.o main.asm
rgbasm -obuild/memory.o memory.asm

rgblink -mbuild/snek.map -nbuild/snek.sym -obuild/snek.gb build/main.o build/memory.o

rgbfix -v build/snek.gb
