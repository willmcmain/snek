#! /bin/bash
set -e
BUILD_DIR=build

mkdir -p $BUILD_DIR

for f in src/*.asm; do
    echo "Assembling $f ..."
    file=$(basename "$f" .asm)
    rgbasm -Lh -o$BUILD_DIR/$file.o src/$file.asm
done

echo "Linking..."
rgblink \
    -m $BUILD_DIR/snek.map \
    -n $BUILD_DIR/snek.sym \
    -o ./snek.gb \
    $BUILD_DIR/*.o
rgbfix -v -p 0 ./snek.gb
