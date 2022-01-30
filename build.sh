#!/bin/sh
NAME=pong
rm -f $NAME $NAME.o
gcc -c $NAME.s
ld -o $NAME -T mbr-alignment.ld $NAME.o
#qemu-system-x86_64 -drive format=raw,file=./$NAME -s
