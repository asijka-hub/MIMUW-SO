#!/bin/bash
rm core.o simple simple_test.o
nasm -DN=2 -f elf64 -w+all -w+error -o core.o core.asm
gcc -no-pie -c -Wall -Wextra -std=c17 -O2 -o simple_test.o simple_test.c
gcc -no-pie -z noexecstack -lpthread -o simple simple_test.o core.o
./simple
