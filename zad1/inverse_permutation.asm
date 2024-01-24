; author Andrzej Sijka as429592
; MIMUW 2023

global inverse_permutation

section .text

;------------------------------------------------ helper function for reversing cycle of permutation
; first argumet n, index of element where we start to look for inverse
; second argument pointer to array
; w r11 we hold current index
; w r9 we hold next index/current value
; w r10 we save value that will be swapped
; algorithm is simple reversal of permutation if we have original transition a -> b, we must have transition
; b -> a so we go to index b, put a there, save element thath we swapped and repeat

find_inverse:
        mov     r11, rdi                                   ; current index
        mov     r9d, dword [rsi + 4 * r11]                 ; current value/next index

.while_loop:
        mov     r10d, dword [rsi + 4 * r9]                 ; we save element that will be swapped
        mov     dword [rsi + 4 * r9], r11d                 ; swapping
        or      dword [rsi + 4 * r9], -2147483648          ; setting flag indicating that element was visited
        mov     r11d, r9d                                  ; updating current value
        mov     r9d, r10d                                  ; next index is element that was wiped out during swap

        cmp     dword [rsi + 4 * r9], 0                    ; if flag is set we end
        jge      .while_loop

        ret
;------------------------------------------------



;------------------------------------------------ simple helper function for disabling flags
disable_flags:
        mov     rcx, rdi
        mov     rbx, rsi
.fix_flags:
        and     dword [rbx], 2147483647                    ; setting oldest bit to 0
        add     rbx, 4
        loop    .fix_flags
        ret
;------------------------------------------------




;------------------------------------------------ MAIN FUNCTION
; first argumet in rdi
; second argument in rsi
; array pointer used to referencing array in rbx
; across program we will be using rcx as loop counter

; common theme across program will be using oldest bit in binary representation as flag
; telling as if for example this place in array was visited by previous algorith
; we can do this because our number in array are all non-negative which means that in U-2
; oldest bit is always 0, we can manipulate this bit by "and" and "or" operations on registers


inverse_permutation:
        push    rbx                                        ; rbx is called saved so we must stored it
        mov     rbx, rsi

        cmp     rdi, 0
        jne    .n_not_zero
        jmp     .wrong                                     ; is n==0 we break

.n_not_zero:
        mov     rax, 2147483648                            ; max accepted value for n is INT_MAX+1
        cmp     rdi, rax
        jbe     .n_okay
        jmp     .wrong                                     ; all negative numbers passed will be greater than INT_MAX+1
                                                           ; in unsigned representation so this check is sufficient

;------------------------------------------------
.n_okay:
                                                           ; from this point we know n is in right range [1,INT_MAX+1]
                                                           ; in this loop we if all integers in array are in range [0, INT_MAX]
        mov     rcx, rdi
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

;------------------------------------------------


                                                           ; from this point we know that all numbers are in correct range

        mov     rcx, rdi                                   ; same as before loop counter and array pointer
        mov     rbx, rsi

                                                           ; simple algorithm for founding duplicated in array
                                                           ; we are going to array element pointed by current value -> a[a[i]]
                                                           ; we use N flags, which is set if number is present in array
                                                           ; if we go to already set flag that means duplicate is found


.check_duplicates:
                                                           ; in r8 we will be storing abs(a[i])
        mov     r8d, dword [rbx]
        and     r8d, 2147483647                            ; 2147483647 = 2^31 - 1 -> 01111...111 in U2
                                                           ; setting oldest bit to 0 -> taking abs
                                                           ; now we need a[abs(a[i])]
        mov     r9d, dword [rsi + 4 * r8]                  ; in r9 we store a[abs(a[i])]
        cmp     r9d, 0
        jl     .duplicate_found                            ; if it's negative that means flag is set -> duplicate found
        or      dword [rsi + 4 * r8], -2147483648          ; setting oldest bit to 1, 2147483648=100...000 in U2
        add     rbx, 4
        loop    .check_duplicates

        jmp     .numbers_are_permutation


.duplicate_found:
        call    disable_flags                              ; if we found duplicate before exiting we must disable all flags
        jmp     .wrong

.numbers_are_permutation:
        call    disable_flags                              ; same in 'right' code flow

;------------------------------------------------
                                                           ; from now we know that numbers are permutations
                                                           ; now we must find it's inverse
                                                           ; algorithm is described in function find_inverse
        mov     rcx, rdi
        push    rdi                                        ; rdi will be used to pass first argument to function
                                                           ; so we must preserve it


.loop_inverse:
        mov     r8, rcx
        dec     r8                                         ; find inverse expected true array index 0,1,2 not 1,2,3 so we must decriment ours
        cmp     dword [rsi + 4 * r8], 0
        jl      .skip                                      ; we only call function if flag is not set
        mov     rdi, r8
        call    find_inverse
.skip:
        loop    .loop_inverse

        pop     rdi

        call    disable_flags                              ; as previous disabling all flags

                                                           ; in both code flows we must restore rbx, and return result 1 or 0
                                                           ; function return bool so we only use al
.okay:
        pop     rbx
        mov     al, 1
        ret
.wrong:
        pop     rbx
        mov     al, 0
        ret

