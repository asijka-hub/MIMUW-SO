global inverse_permutation

section .data

    INT_MAX     equ 2147483647

section .text

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
        cmp     rdi, 2147483647
        jbe     .n_okay
        jmp     .wrong

.n_okay:

; od tego momentu wiemy ze n jest poprawne

;        mov     rcx, rdi                        ; w rcx trzymamy licznik petli
;.check_number_correctness:
;        cmp     edi, dword [rbx]
;        jg      .wrong
;        add     rsi,    4
;        loop    .check_number_correctness

; od tego momentu wiemy ze wszystkie liczby w tablicy sa w dabrym zakresie tzn 0 .. n - 1
.okay:
        pop     rbx
        xor     rax, rax
        mov     rax, 1
        ret
.wrong:
        pop     rbx
        xor     rax, rax
        mov     rax, 0
        ret
