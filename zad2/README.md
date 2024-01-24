# Symulator rozproszonej maszyny stosowej x86_64

## Specyfikacja

Zaimplementuj w asemblerze x86_64 symulator rozproszonej maszyny stosowej. Maszyna składa się z N rdzeni, które są numerowane od 0 do N − 1, gdzie N jest pewną stałą ustalaną podczas kompilowania symulatora. Symulator będzie używany z języka C w ten sposób, że będzie uruchamianych N wątków i w każdym wątku będzie wywoływana funkcja:

```c
uint64_t core(uint64_t n, char const *p);
```

Parametr `n` zawiera numer rdzenia. Parametr `p` jest wskaźnikiem na napis ASCIIZ i definiuje obliczenie, jakie ma wykonać rdzeń. Obliczenie składa się z operacji wykonywanych na stosie, który na początku jest pusty.

### Interpretacja znaków napisu

- `+` – zdejmij dwie wartości ze stosu, oblicz ich sumę i wstaw wynik na stos;
- `*` – zdejmij dwie wartości ze stosu, oblicz ich iloczyn i wstaw wynik na stos;
- `-` – zaneguj arytmetycznie wartość na wierzchołku stosu;
- `0` do `9` – wstaw na stos odpowiednio wartość 0 do 9;
- `n` – wstaw na stos numer rdzenia;
- `B` – zdejmij wartość ze stosu, jeśli teraz na wierzchołku stosu jest wartość różna od zera, potraktuj zdjętą wartość jako liczbę w kodzie uzupełnieniowym do dwójki i przesuń się o tyle operacji;
- `C` – zdejmij wartość ze stosu i porzuć ją;
- `D` – wstaw na stos wartość z wierzchołka stosu, czyli zduplikuj wartość na wierzchu stosu;
- `E` – zamień miejscami dwie wartości na wierzchu stosu;
- `G` – wstaw na stos wartość uzyskaną z wywołania funkcji `uint64_t get_value(uint64_t n)`;
- `P` – zdejmij wartość ze stosu (oznaczmy ją przez `w`) i wywołaj funkcję `void put_value(uint64_t n, uint64_t w)`;
- `S` – synchronizuj rdzenie, zdejmij wartość ze stosu, potraktuj ją jako numer rdzenia `m`, czekaj na operację `S` rdzenia `m` ze zdjętym ze stosu numerem rdzenia `n` i zamień wartości na wierzchołkach stosów rdzeni `m` i `n`.

Po zakończeniu przez rdzeń wykonywania obliczenia jego wynikiem, czyli wynikiem funkcji `core`, jest wartość z wierzchołka stosu. Wszystkie operacje wykonywane są na liczbach 64-bitowych modulo 2 do potęgi 64.

### Synchronizacja rdzeni

Synchronizację rdzeni, czyli operację `S`, należy zaimplementować za pomocą jakiegoś wariantu wirującej blokady.

### Kompilowanie

Rozwiązanie będzie kompilowane poleceniem:

```bash
nasm -DN=XXX -f elf64 -w+all -w+error -o core.o core.asm
```

gdzie `XXX` określa wartość stałej N. Rozwiązanie musi się kompilować w laboratorium komputerowym.

### Przykład użycia

Przykład użycia znajduje się w załączonym pliku `example.c`. Kompiluje się go poleceniami:

```bash
nasm -DN=2 -f elf64 -w+all -w+error -o core.o core.asm
gcc -c -Wall -Wextra -std=c17 -O2 -o example.o example.c
gcc -z noexecstack -o example core.o example.o -lpthread
```

