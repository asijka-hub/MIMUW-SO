extern putchar
extern printf
extern put_value
extern get_value
global core

PLUS        equ     43
ASTERISK    equ     42
MINUS       equ     45
OP_0        equ     48
OP_1        equ     49
OP_2        equ     50
OP_3        equ     51
OP_4        equ     52
OP_5        equ     53
OP_6        equ     54
OP_7        equ     55
OP_8        equ     56
OP_9        equ     57
OP_n        equ     110
OP_B        equ     66
OP_C        equ     67
OP_D        equ     68
OP_E        equ     69
OP_G        equ     71
OP_P        equ     80
OP_S        equ     83
NULL        equ     0

section .bss
    spin_lock_array   resd    N
    sleeping_array    resb    N
    for_who_array     resq    N
    swap_array      resq    N

section .data
align           4
    spin_lock:      dd 0



; jmp_op <reg8>, <imm8>, <label>
%macro  jmp_op      3
        cmp     %1, %2
        je      %3
%endmacro

section .rodata
    mplus           db  '+', 13, 10, 0
    masterisk       db  '*', 13, 10, 0
    mminus          db  '-', 13, 10, 0
    m0              db  '0', 13, 10, 0
    m1              db  '1', 13, 10, 0
    m2              db  '2', 13, 10, 0
    m3              db  '3', 13, 10, 0
    m4              db  '4', 13, 10, 0
    m5              db  '5', 13, 10, 0
    m6              db  '6', 13, 10, 0
    m7              db  '7', 13, 10, 0
    m8              db  '8', 13, 10, 0
    m9              db  '9', 13, 10, 0
    mn              db  'n', 13, 10, 0
    mB              db  'B', 13, 10, 0
    mC              db  'C', 13, 10, 0
    mD              db  'D', 13, 10, 0
    mE              db  'E', 13, 10, 0
    mG              db  'G', 13, 10, 0
    mP              db  'P', 13, 10, 0
    mS              db  'S', 13, 10, 0
    mnumber         db  'num', 13, 10, 0
section .text

; argument in r10
print_l:
        push    rdi
        mov     rdi, r10
        call    printf wrt ..plt
        pop     rdi
        ret

pop:


;   first argument n in rdi
;   second argument p pointer in rsi
;   rbx as stack pointer
;   rdx we save were to move stack pointer after whole program
core:
        push    rbx
        mov     rbx,    rsi
        mov     rdx,    rsp

.main_loop:
        mov     r10b,     byte [rbx]

;       skoki
        jmp_op     r10b,  PLUS,  .J_PLUS
        jmp_op     r10b,  ASTERISK,  .J_ASTERISK
        jmp_op     r10b,  MINUS,  .J_MINUS
        jmp_op     r10b,  OP_0,  .J_NUMBER
        jmp_op     r10b,  OP_1,  .J_NUMBER
        jmp_op     r10b,  OP_2,  .J_NUMBER
        jmp_op     r10b,  OP_3,  .J_NUMBER
        jmp_op     r10b,  OP_4,  .J_NUMBER
        jmp_op     r10b,  OP_5,  .J_NUMBER
        jmp_op     r10b,  OP_6,  .J_NUMBER
        jmp_op     r10b,  OP_7,  .J_NUMBER
        jmp_op     r10b,  OP_8,  .J_NUMBER
        jmp_op     r10b,  OP_9,  .J_NUMBER
        jmp_op     r10b,  OP_n,  .J_n
        jmp_op     r10b,  OP_B,  .J_B
        jmp_op     r10b,  OP_C,  .J_C
        jmp_op     r10b,  OP_D,  .J_D
        jmp_op     r10b,  OP_E,  .J_E
        jmp_op     r10b,  OP_G,  .J_G
        jmp_op     r10b,  OP_P,  .J_P
        jmp_op     r10b,  OP_S,  .J_S




        jmp     .switch_end
.J_PLUS:
        ;mov     r10,    mplus
        pop     r8
        pop     r9
        add     r8,     r9
        push    r8
        ;call    print_l
        jmp     .switch_end
.J_ASTERISK:
        ;mov     r10,    masterisk
        pop     rax
        pop     r8
        push    rdx
        imul    r8
        pop     rdx
        push    rax
        ;call    print_l
        jmp     .switch_end
.J_MINUS:
;       mozemy zrobic tu rozkaz neg
        ;mov     r10,    mminus
        pop     rax
        mov     r8, -1
        push    rdx
        imul    r8
        pop     rdx
        push    rax
        ;call    print_l
        jmp     .switch_end
.J_NUMBER:
        ;mov     r10,    mnumber
        ;call    print_l
        mov     r8b,    r10b      ; przenosimy do r8 zeby nie koncu nie popsuc warunku z al w switch_end
        sub     r8b,     48
        movzx   r8,    r8b
        push    r8
        jmp     .switch_end
.J_n:
        ;mov     r10,    mn
        push    rdi
        ;call    print_l
        jmp     .switch_end
.J_B:
        ;mov     r10,    mB
        ;call    print_l
        pop     r8
        cmp     dword [rsp], 0
        jne     .J_B_moving
        jmp     .switch_end
.J_B_moving:
        cmp     r8,    0
        jl      .J_B_less
        add     rbx,    r8
        jmp     .main_loop
.J_B_less:
        sub     rbx,    rax
        jmp     .main_loop      ; wazne skaczemy na poczatek petli
.J_C:
        ;mov     r10,    mC
        pop     rax
        ;call    print_l
        jmp     .switch_end
.J_D:
        ;mov     r10,    mD
        ;call    print_l
        pop     r8
        push    r8
        push    r8
        jmp     .switch_end
.J_E:
        ;mov     r10,    mE
        ;call    print_l
        pop     r8
        pop     r9
        push    r8
        push    r9
        jmp     .switch_end
.J_G:
        ;mov     r10,    mG
        ;call    print_l
        call    get_value
        push    rax
        jmp     .switch_end
.J_P:
        ;mov     r10,    mP
        ;call    print_l
        pop     r8
        push    rsi
        mov     rsi,    r8
        call    put_value
        pop     rsi
        jmp     .switch_end
.J_S:
        ;mov     r10,    mS
        ;call    print_l
        pop     r8                      ; m value
        pop     r9                      ; value to be swapped

        mov     eax,    1
        lea     r11,    [rel spin_lock_array]   ; now we have m-th barrier
        lea     r11,    [r11 + 4 * r8]
.busy_wait:
        xchg    dword [r11], eax                          ; Jeśli blokada otwarta, zamknij ją.
        test    eax, eax                            ; Sprawdź, czy blokada była otwarta.
        ;jnz     .busy_wait                          ; Skocz, gdy blokada była zamknięta.
        ; now we are in critical section
        ; we must check if m was waiting for us
        ; if he was not than we should ourself go to sleep
        ; and we will put our value to be swapped to swap array so when m wakes our up he will have already our value

        cmp     rdi,    [rel for_who_array + 8 * r8]    ; we are checking if m process is waiting for n (us)

        je      .we_wake_up
.we_sleep:
        ;   now we release lock on m-th array bcs we don't need it anymore
        ;mov     [spin_lock_array + 4 * r8], eax

        ;   before we go to sleep we must put our value to swap_array
        ;   we put it in n-th swap_array
        mov     eax,    1
        ;lea     rdx,    [spin_lock_array + 4 * rdi]
.busy_wait_2:
        ;xchg    [rdx], eax                          ; Jeśli blokada otwarta, zamknij ją.
        test    eax, eax                            ; Sprawdź, czy blokada była otwarta.
        ;jnz     .busy_wait_2
        ; now we know it's safe to modify n-th array element
        ;mov     [swap_array + 8 * rdi],     r9


        ; know we must sleep
        ; so we should release n-th lock so someone can wake us up

        ;mov     byte [sleeping_array + rdi],     1   ; we inform that we sleep
        ;mov     [rdx], eax

        mov     eax, 1
.sleeping:
        ;xchg    [rdx], eax
        test    eax, eax
        ;jnz     .sleeping
        ;   we are in critical section
        ;   we are still sleeping!!!!!
        ;cmp     byte [sleeping_array + rdi],     0
        ;je      .waked_up
        ;mov     [rdx],  eax
        ;jmp     .sleeping
.waked_up:
        ;   know we have to take value from swap array, this value was put by process m
        ;   IMPORTANT
        ;   swap_array element that will be used is index of first process that goes to sleep
        ;   so in this case is our index -> n

        ;mov     rax,    [swap_array + 8 * rdi]
        push    rax         ; we have to stare value that process m gave us
        ;mov     [rdx], eax

        jmp     .program_end

.we_wake_up:
        ; when we are waking up that means few things
        ; first before we wake sleeping process we must put on our stack
        ; value that this process gave us
        ; and than put to this swapping array our value
        ; important thing is index of swapping array and array that this process is sleeping
        ; is m second value as opposed to n-rdi first case

        ;mov     rax,    [swap_array + 8 * r8]
        push    rax

        ;mov     [swap_array + 8 * r8], r9
        ;mov     byte [sleeping_array + r8], 0 ; we wake process up

        ;mov     [spin_lock_array + 4 * r8], eax ; realising lock



        jmp     .switch_end

.switch_end:
        cmp     r10b,     0
        jne     .loop_continue
        jmp     .program_end

.loop_continue:
        inc     rbx
        jmp     .main_loop


.program_end:
        mov     rax,    [rsp]
        mov     rsp,    rdx
        pop     rbx
        ret
