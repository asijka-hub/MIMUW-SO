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
;    spin_lock_array   resd    N
    sleeping_array    resb    N

    swap_array      resq    N

section .data
    for_who_array     dq    18446744073709551615
align           4
    spin_lock:      dd 0



; jmp_op <reg8>, <imm8>, <label>
%macro  jmp_op      3
        cmp     %1, %2
        je      %3
%endmacro

; macro call <func>
%macro align_stack  1
        mov     rax, rsp
        mov     r9,  8
        xor     rdx, rdx
        div     r9
        cmp     rdx,    0
        je      .stack_align

        push    r8
        call    %1
        pop     r8
        jmp     .macro_end

.stack_align:
        call   %1
.macro_end:
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
    mjumpless         db  'we jump negative', 13, 10, 0
    mjumpmore         db  'we jump positive', 13, 10, 0

section .text

; argument in rdi
; we must fix stack
print_l:
        ;push    r10
        call    printf wrt ..plt
        ;pop     r10
        ret

print_letter: ; first argument in rdi
    mov     rax, rsp
    mov     r9,  16
    xor     rdx, rdx
    div     r9
    cmp     rdx,    0
    je      .stack_align

    push    r8
    mov     rsi,    rdi
    call    printf wrt ..plt
    pop     r8
    ret

.stack_align:
    mov     rsi,    rdi
    call   printf wrt ..plt
    ret

align_call: ; rdi -> <func>  rsi -> <arg1>  rdx -> <arg2>
    mov     r8,  rdx
    mov     rax, rsp
    mov     r9,  16
    xor     rdx, rdx
    div     r9
    cmp     rdx,    0
    je      .stack_align

    push    r8
    mov     rdx, r8
    mov     rax, rdi
    mov     rdi, rsi
    mov     rsi, rdx
    call    rax
    pop     r8
    ret

.stack_align:
    mov     rdx, r8
    mov     rax, rdi
    mov     rdi, rsi
    mov     rsi, rdx
    call    rax
    ret

;   RBX we save were to move stack pointer after whole program
;   we will store
;   n - first argument in R12
;   p - array pointer in R13

; ZMIANA RDX na RBX moze miec na cos wplyw
;   R10 CHYBA tez trzeba savefowac miedzy callami

core:
        push    r12
        push    r13
        push    rbx
        mov     rbx,    rsp
        mov     r12,    rdi
        mov     r13,    rsi

.main_loop:
        mov     r10b,     byte [r13]

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




        jmp     .program_end ; if all ifs failed that means that we reach end of instruction
                             ; so we jump out of switch
                             ; this is our deafault case
.J_PLUS:
;        mov     rdi,    mplus
;        call    print_letter
        pop     r8
        pop     r9
        add     r8,     r9
        push    r8
        jmp     .loop_continue
.J_ASTERISK:
;        mov     rdi,    masterisk
;        call    print_letter
        pop     rax
        pop     r8
        imul    r8
        push    rax

        jmp     .loop_continue
.J_MINUS:
;       mozemy zrobic tu rozkaz neg
;        mov     rdi,    mminus
;        call    print_letter

        pop     rax
        mov     r8, -1
        imul    r8
        push    rax
        jmp     .loop_continue
.J_NUMBER:
;        mov     rdi,    mnumber
;        push    r10
;        call    print_letter
;        pop     r10
        ;;; wyrownac stack!!!!
        sub     r10b,     48
        movzx   r10,    r10b
        push    r10
        jmp     .loop_continue
.J_n:
;        mov     rdi,    mn
;        call    print_letter
        push    r12
        jmp     .loop_continue
.J_B:
;        mov     rdi,    mB
;        call    print_letter
        pop     r8
        cmp     qword [rsp], 0
        jne     .J_B_moving
        jmp     .loop_continue
.J_B_moving:
        cmp     r8,    0
        jl      .J_B_less
;        mov     rdi,    mjumpmore
;        call    print_letter
        sub     r13,    r8
        ;jmp     .main_loop
        jmp     .loop_continue
.J_B_less:
;        mov     rdi,    mjumpless
;        call    print_letter
        add     r13,    r8
        ;jmp     .main_loop      ; wazne skaczemy na poczatek petli
        jmp     .loop_continue      ; wazne skaczemy na poczatek petli
.J_C:
;        mov     rdi,    mC
;        call    print_letter
        pop     rax
        jmp     .loop_continue
.J_D:
;        mov     rdi,    mD
;        call    print_letter
        pop     r8
        push    r8
        push    r8
        jmp     .loop_continue
.J_E:
;        mov     rdi,    mE
;        call    print_letter
        pop     r8
        pop     r9
        push    r8
        push    r9
        jmp     .loop_continue
.J_G:
;        mov     rdi,    mG
;        call    print_letter
       ; mov     rdi, r12
        ;call    get_value
        mov     rdi,    get_value
        mov     rsi,    r12
        call    align_call
        push    rax
        jmp     .loop_continue
.J_P:
;        mov     rdi,    mP
;        call    print_letter

        ;mov     rdi,    r12
        ;pop     rsi
        ;call    put_value

        mov     rdi,    put_value
        mov     rsi,    r12
        pop     rdx
        call    align_call

        jmp     .loop_continue
.J_S:
        ;  w rdi trzymamy [rel spin_lock]
        ;  w rsi trzymamy [rel sleeping_array]
        ;  w rcx trzymamy [rel for_who_array]
        ;  w rdx trzymamy [rel swap_array]
        pop     r8                      ; m value
        pop     r9                      ; value to be swapped

        lea     rdi,    [rel spin_lock]
        lea     rsi,    [rel sleeping_array]
        lea     rcx,    [rel for_who_array]
        lea     rdx,    [rel swap_array]


        mov     eax,    1
.busy_wait:
        xchg    dword [rdi], eax                          ; Jeśli blokada otwarta, zamknij ją.
        test    eax, eax                            ; Sprawdź, czy blokada była otwarta.
        jnz     .busy_wait                          ; Skocz, gdy blokada była zamknięta.
        ; now we are in critical section
        ; we must check if m was waiting for us
        ; if he was not than we should ourself go to sleep
        ; and we will put our value to be swapped to swap array so when m wakes our up he will have already our value

        cmp     r12,    [rcx + 8 * r8]    ; we are checking if m process is waiting for n (us)

        je      .we_wake_up
.we_sleep:
        ;   now we release lock on m-th array bcs we don't need it anymore
        ;mov     [spin_lock_array + 4 * r8], eax

        ;   before we go to sleep we must put our value to swap_array
        ;   we put it in n-th swap_array
        ;mov     eax,    1
        ;lea     rdx,    [spin_lock_array + 4 * r12]
;.busy_wait_2:
        ;xchg    [rdx], eax                          ; Jeśli blokada otwarta, zamknij ją.
        ;test    eax, eax                            ; Sprawdź, czy blokada była otwarta.
        ;jnz     .busy_wait_2
        ; now we know it's safe to modify n-th array element
        mov     [rdx + 8 * r12],     r9


        ; know we must sleep
        ; so we should release n-th lock so someone can wake us up

        mov     byte [rsi + r12],     1   ; we inform that we sleep
        mov     qword [rcx + 8 * r12], r8   ; we inform for who we wait
        mov     [rdi], eax                ; release

.sleeping:
        mov     eax, 1
.busy_sleep:
        xchg    [rdi], eax
        test    eax, eax
        jnz     .busy_sleep
        ;   we are in critical section
        ;   we are still sleeping!!!!!
        cmp     byte [rsi + r12],     0
        je      .waked_up
        mov     dword [rdi],  0
        jmp     .sleeping
.waked_up:
        ;   know we have to take value from swap array, this value was put by process m
        ;   IMPORTANT
        ;   swap_array element that will be used is index of first process that goes to sleep
        ;   so in this case is our index -> n

        mov     rax,    [rdx + 8 * r12]
        push    rax         ; we have to stare value that process m gave us
        mov     qword [rcx + 8 * r12], 18446744073709551615  ; we set flag that we don't wait for anyone
        mov     dword [rdi], 0  ; release

        jmp     .loop_continue

.we_wake_up:
        ; when we are waking up that means few things
        ; first before we wake sleeping process we must put on our stack
        ; value that this process gave us
        ; and than put to this swapping array our value
        ; important thing is index of swapping array and array that this process is sleeping
        ; is m second value as opposed to n-r12 first case

        mov     rax,    [rdx + 8 * r8]
        push    rax

        mov     [rdx + 8 * r8], r9
        mov     byte [rsi + r8], 0 ; we wake process up

        mov     dword [rdi], 0 ; realising lock



        jmp     .loop_continue

.loop_continue:
        inc     r13
        jmp     .main_loop


.program_end:
        mov     rax,    [rsp]
        mov     rsp,    rbx
        pop     rbx
        pop     r13
        pop     r12
        ret
