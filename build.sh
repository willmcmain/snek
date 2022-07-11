#! /bin/bash
set -e

for f in src/*.asm; do
    echo "Assembling $f ..."
    file=$(basename "$f" .asm)
    rgbasm -Lh -obuild/$file.o src/$file.asm
done

echo "Linking..."
rgblink -mbuild/snek.map -nbuild/snek.sym -obuild/snek.gb build/*.o
rgbfix -v -p 0 build/snek.gb
