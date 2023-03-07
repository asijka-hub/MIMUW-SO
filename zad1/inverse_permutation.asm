global inverse_permutation

section .data

    INT_MAX     equ 2147483647

section .text

; first argumet in rdi
; second argument in rsi

inverse_permutation:
        cmp     rdi, 0
        je      .wrong
        cmp     rdi, 2147483647
        ja      .wrong

; od tego momentu wiemy ze n jest poprawne

        mov     rcx, rdi    ; w rcx trzymamy licznik petli
.check_number_correctness:
                            ; w rdi mamy n
                            ; w rsi mamy pointer na array
        cmp     dword [rsi], edi
        ja      .wrong
        add     rsi,    4
        loop    .check_number_correctness


.okay:
        xor     rax, rax
        mov     rax, 1
        ret
.wrong:
        xor     rax, rax
        mov     rax, 0
        ret
