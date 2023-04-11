#!/bin/bash
nasm -DN=3 -f elf64 -w+all -w+error -o core.o core.asm
