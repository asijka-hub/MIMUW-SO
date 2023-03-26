#!/usr/bin/env bash

if [[ -e "test" ]]; then 
	echo make clean
	rm test test.o
	rm inverse_permutation.o
fi

nasm -g -f elf64 -w+all -w+error -o inverse_permutation.o inverse_permutation.asm
gcc -g -c -Wall -Wextra -std=c17 -O2 -o test.o test.c
gcc -z noexecstack -o test test.o inverse_permutation.o
./test 6969
