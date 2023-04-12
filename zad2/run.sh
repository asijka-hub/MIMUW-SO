#!/bin/bash
rm core.o example example.o
nasm -DN=2 -f elf64 -w+all -w+error -o core.o core.asm
gcc -no-pie -c -Wall -Wextra -std=c17 -O2 -o example.o example.c
gcc -no-pie -z noexecstack -lpthread -o example core.o example.o
./example
