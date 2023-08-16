all: file.o

# Rule to assemble the source file into an object file
file.o: file.s
	nasm -f bin file.s -o file	

# Clean up generated files
clean:
	rm -f file.o

