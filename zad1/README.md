# Odwracanie permutacji
Zaimplementuj w asemblerze wołaną z języka C funkcję:

`bool inverse_permutation(size_t n, int *p);`
Argumentami funkcji są wskaźnik p na niepustą tablicę liczb całkowitych oraz rozmiar tej tablicy n. Jeśli tablica wskazywana przez p zawiera permutację liczb z przedziału od 0 do n-1, to funkcja odwraca tę permutację w miejscu, a wynikiem funkcji jest true. W przeciwnym przypadku wynikiem funkcji jest false, a zawartość tablicy wskazywanej przez p po zakończeniu wykonywania funkcji jest taka sama jak w momencie jej wywołania. Funkcja powinna wykrywać ewidentnie niepoprawne wartości n – patrz przykład użycia. Wolno natomiast założyć, że wskaźnik p jest poprawny.

# Kompilowanie
Rozwiązanie będzie kompilowane poleceniem:

`nasm -f elf64 -w+all -w+error -o inverse_permutation.o inverse_permutation.asm`
Rozwiązanie musi się kompilować w laboratorium komputerowym.

# Przykład użycia
Przykład użycia znajduje się w pliku inverse_permutation_example.c. Można go skompilować i skonsolidować z rozwiązaniem poleceniami:

`gcc -c -Wall -Wextra -std=c17 -O2 -o inverse_permutation_example.o inverse_permutation_example.c
gcc -z noexecstack -o inverse_permutation_example inverse_permutation_example.o inverse_permutation.o"`
