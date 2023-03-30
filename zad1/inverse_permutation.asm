global inverse_permutation

section .text

; first argumet n, index of element where we start to look for inverse
; second argument pointer to array
; w r11 trzymamy indeks
; w r9 nastepny indeks/aktualna wartosc
; w r10 savujemy wartosc ktora aktualnie zmienilismy

find_inverse:
        mov     r11, rdi
        mov     r9d, dword [rsi + 4 * r11]

        ;  pierwszy zawsze jest okej

.while_loop:
        mov     r10d, dword [rsi + 4 * r9]
        mov     dword [rsi + 4 * r9], r11d
        or      dword [rsi + 4 * r9], -2147483648
        mov     r11d, r9d
        mov     r9d, r10d

        cmp     dword [rsi + 4 * r9], 0
        jge      .while_loop

        ret

disable_flags:
        mov     rcx, rdi
        mov     rbx, rsi
.fix_flags:
        and     dword [rbx], 2147483647
        add     rbx, 4
        loop    .fix_flags
        ret

; first argumet in rdi
; second argument in rsi
; array pointer used to referencing array in rbx

inverse_permutation:
        push    rbx
        mov     rbx, rsi

        cmp     rdi, 0
        jne    .n_not_zero
        jmp     .wrong                         ; n is 0

.n_not_zero:
        mov     rax, 2147483648
        cmp     rdi, rax
        jbe     .n_okay
        jmp     .wrong

.n_okay:

; od tego momentu wiemy ze n jest poprawne

        mov     rcx, rdi                        ; w rcx trzymamy licznik petli
.check_number_correctness:
        cmp     dword [rbx], 0
        jge     .array_element_bigger_than_zero
        jmp     .wrong
.array_element_bigger_than_zero:
        cmp     edi, dword [rbx]
        jg      .array_element_okay
        jmp     .wrong
.array_element_okay:
        add     rbx,    4
        loop    .check_number_correctness

; od tego momentu wiemy ze wszystkie liczby w tablicy sa w dabrym zakresie tzn 0 .. n - 1

        mov     rcx, rdi
        mov     rbx, rsi

;   w r8 bedziemy trzymac abs(a[i])

.check_duplicates:
        mov     r8d, dword [rbx]
        and     r8d, 2147483647                  ; 2^31 - 1 -> 01111111 zerujemy najstarszy bit czyli bierzemy abs
                                                 ; teraz musimy znalesc a[abs(a[i])]
        mov     r9d, dword [rsi + 4 * r8]        ; w r9 jest a[abs(a[i])]
        cmp     r9d, 0
        jl     .duplicate_found
        or      dword [rsi + 4 * r8], -2147483648        ; -2^31 ustawiamy najstarzy bit na 1
        add     rbx, 4
        loop    .check_duplicates

        jmp     .numbers_are_permutation


.duplicate_found:
;       w czesci liczb flagi ktorych uzywamy czyli najstarsze bity sa ustawione
;       musimy je wylaczac
        call    disable_flags
        jmp     .wrong

.numbers_are_permutation:
        call    disable_flags


        mov     rcx, rdi
        push    rdi

.loop_inverse:
        mov     r8, rcx
        dec     r8
        cmp     dword [rsi + 4 * r8], 0            ; rcx iterowane od n, my liczymy -1
        jl      .skip
        mov     rdi, r8
        call    find_inverse
.skip:
        loop    .loop_inverse

        pop     rdi

        call    disable_flags


.okay:
        pop     rbx
        mov     al, 1
        ret
.wrong:
        pop     rbx
        mov     al, 0
        ret
