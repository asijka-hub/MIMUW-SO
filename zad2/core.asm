extern putchar
extern printf
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
        mov     al,     byte [rbx]

;       skoki
        jmp_op     al,  PLUS,  .J_PLUS
        jmp_op     al,  ASTERISK,  .J_ASTERISK
        jmp_op     al,  MINUS,  .J_MINUS
        jmp_op     al,  OP_0,  .J_NUMBER
        jmp_op     al,  OP_1,  .J_NUMBER
        jmp_op     al,  OP_2,  .J_NUMBER
        jmp_op     al,  OP_3,  .J_NUMBER
        jmp_op     al,  OP_4,  .J_NUMBER
        jmp_op     al,  OP_5,  .J_NUMBER
        jmp_op     al,  OP_6,  .J_NUMBER
        jmp_op     al,  OP_7,  .J_NUMBER
        jmp_op     al,  OP_8,  .J_NUMBER
        jmp_op     al,  OP_9,  .J_NUMBER
        jmp_op     al,  OP_n,  .J_n
        jmp_op     al,  OP_B,  .J_B
        jmp_op     al,  OP_C,  .J_C
        jmp_op     al,  OP_D,  .J_D
        jmp_op     al,  OP_E,  .J_E
        jmp_op     al,  OP_G,  .J_G
        jmp_op     al,  OP_P,  .J_P
        jmp_op     al,  OP_S,  .J_S




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
        sub     al,     48
        movzx   rax,    al
        push    rax
        jmp     .switch_end
.J_n:
        ;mov     r10,    mn
        push    rdi
        ;call    print_l
        jmp     .switch_end
.J_B:
        ;mov     r10,    mB
        ;call    print_l
        pop     rax
        add     rbx,    rax

        jmp     .main_loop      ; wazne skaczemy na poczatek petli
.J_C:
        ;mov     r10,    mC
        pop     rax
        ;call    print_l
        jmp     .switch_end
.J_D:
        ;mov     r10,    mD
        ;call    print_l
        pop     rax
        push    rax
        push    rax
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
        mov     r10,    mG
        call    print_l
        jmp     .switch_end
.J_P:
        mov     r10,    mP
        call    print_l
        jmp     .switch_end
.J_S:
        mov     r10,    mS
        call    print_l
        jmp     .switch_end

.switch_end:
        cmp     al,     0
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
