#!/usr/bin/env bash

if [[ -e "inverse_permutation_example" ]]; then 
	echo make clean
	rm inverse_permutation_example inverse_permutation_example.o
	rm inverse_permutation.o
fi

nasm -g -f elf64 -w+all -w+error -o inverse_permutation.o inverse_permutation.asm
gcc -g -c -Wall -Wextra -std=c17 -O2 -o inverse_permutation_example.o inverse_permutation_example.c
gcc -z noexecstack -o inverse_permutation_example inverse_permutation_example.o inverse_permutation.o
./inverse_permutation_example
