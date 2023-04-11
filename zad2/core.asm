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
OP_a        equ     97
OP_B        equ     66
OP_C        equ     67
OP_D        equ     68
OP_E        equ     69
OP_G        equ     71
OP_P        equ     80
OP_S        equ     83
NULL        equ     0

; jmp_op <reg16>, <imm16>, <label>
%macro  jmp_op      3
        cmp     %1, %2
        je      %3
%endmacro

section .text

;   first argument n in rdi
;   second argument p pointer in rsi
;   rbx as stack pointer
core:
        push    rbx
        mov     rbx,    rsi

.main_loop:
        mov     al,     byte [rbx]

;       skoki

        cmp     al,     0
        jne     .loop_continue
        jmp     .program_end

.loop_continue:
        inc     rbx
        jmp     main


.program_end:
        pop     rbx
        ret
