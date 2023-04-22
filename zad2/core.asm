; author Andrzej Sijka as429592
; MIMUW 2023

extern put_value
extern get_value
global core

;----------------------------------------------------------
section .bss
    sleeping_array    resb    N
    swap_array        resq    N

section .data
    for_who_array  times N dq  18446744073709551615
align           4
    spin_lock      dd 0

; global data used for S operation
; detail describe in S operation
;----------------------------------------------------------

; jmp_op <reg8>, <imm8>, <label>
%macro  jmp_op      3
        cmp     %1, %2
        je      %3
%endmacro

section .text

; function used for save calling function
; this function align stack if it's needed
; than call passed function with some passed argunets

align_call: ; rdi -> <func>  rsi -> <arg1>  rdx -> <arg2>
        mov     r8,  rdx                                   ; we must save value of rdx bcs div operation changes it

        mov     rax, rsp                                   ;
        mov     r9,  16                                    ;
        xor     rdx, rdx                                   ;
        div     r9                                         ; calculating rsp mod 16

        cmp     rdx,    0                                  ;
        je      .stack_align                               ; checking if stack was align

        push    r8                                         ; aligning stack

        mov     rdx, r8                                    ; restoring value of rdx
        mov     rax, rdi                                   ; in rax address of function to call
        mov     rdi, rsi                                   ;
        mov     rsi, rdx                                   ; moving args rsi -> rdi, rdx -> rsi
        call    rax

        pop     r8                                          ; poping stack bcs abi must be preserve after this functon
        ret                                                 ; we can just return bcs in rax we have result
                                                            ; after ret this will be result of this function
.stack_align:
        mov     rdx, r8
        mov     rax, rdi
        mov     rdi, rsi
        mov     rsi, rdx
        call    rax                                             ; same as above, just without stack aligning
        ret

;   called save register that we will be using
;   RBX we save were to move stack pointer after whole program
;   n - first argument in R12
;   p - array pointer in R13

core:
        push    r12
        push    r13
        push    rbx                                        ; these are called saved registers so we must preserve their states
        mov     rbx,    rsp                                ; in rbx we save were to move stack pointer after whole program execution
        mov     r12,    rdi
        mov     r13,    rsi                                ; we keep in them values as described above

.main_loop:
        mov     r10b,     byte [r13]                       ; in r10b we keep current operation label

        ; we are jumping if r10b is equal to some label
        ; it works similar to switch case
        ; if all cases failed we jump to program end
        jmp_op     r10b,  '+',  .J_PLUS
        jmp_op     r10b,  '*',  .J_ASTERISK
        jmp_op     r10b,  '-',  .J_MINUS

        ; we can optimize few jump doe to the fact that '1','2'... '9' has consecutive value in ASCII
        cmp        r10b,  48
        jl         .program_end
        cmp        r10b,  57
        jg         .rest
        jmp        .J_NUMBER

.rest:
        jmp_op     r10b,  'n',  .J_n
        jmp_op     r10b,  'B',  .J_B
        jmp_op     r10b,  'C',  .J_C
        jmp_op     r10b,  'D',  .J_D
        jmp_op     r10b,  'E',  .J_E
        jmp_op     r10b,  'G',  .J_G
        jmp_op     r10b,  'P',  .J_P
        jmp_op     r10b,  'S',  .J_S




        jmp     .program_end ; if all ifs failed that means that we reach end of instruction
                             ; so we jump out of switch
                             ; this is our deafault case
.J_PLUS:
        pop     r8
        pop     r9
        add     r8,     r9
        push    r8

        jmp     .loop_continue
.J_ASTERISK:
        pop     rax
        pop     r8
        imul    r8
        push    rax

        jmp     .loop_continue
.J_MINUS:
        pop     rax
        mov     r8, -1
        imul    r8                                         ; negating value on the top
        push    rax

        jmp     .loop_continue
.J_NUMBER:
        ; we are taking advantage of fact that for example '1' = 48 + 1, '2' = 48 + 2 etc.
        sub     r10b,     48
        movzx   r10,    r10b                               ; stack is 8-bytes so we must extend our number
        push    r10
        jmp     .loop_continue
.J_n:
        push    r12

        jmp     .loop_continue
.J_B:
        pop     r8
        cmp     qword [rsp], 0                             ; we execute B if top of stack is not 0
        jne     .J_B_moving
        jmp     .loop_continue
.J_B_moving:
        add     r13,    r8                                 ; number is in U2 so we simple add

        jmp     .loop_continue
.J_C:
        pop     rax

        jmp     .loop_continue
.J_D:
        pop     r8
        push    r8
        push    r8

        jmp     .loop_continue
.J_E:
        pop     r8
        pop     r9
        push    r8
        push    r9

        jmp     .loop_continue
.J_G:
        ; in this point stack may be not align so in order to preserve ABI
        ; we need to execute function that will automatically align stack
        ; it's detail description is above
        mov     rdi,    get_value
        mov     rsi,    r12
        call    align_call
        push    rax                                        ; we must push rax, as it's first return register
                                                           ; result of get_value
        jmp     .loop_continue
.J_P:
        ; save in this case
        ; in both G and P case, we put value according to api of align_call
        mov     rdi,    put_value
        mov     rsi,    r12
        pop     rdx                                        ; align_call take 3-argument in rdx and we know that this
                                                           ; value is on the stack so we can pop directly to rdx
        call    align_call

        jmp     .loop_continue
.J_S:
        ; to achieve synchronization in S operation we need to use global
        ; data that will be seen by all calls of core function
        ; algorithm for synchronization:
        ; first process check if m-th process is waiting for him
        ; if not he will put value to be swapped to global array
        ; and go sleep and waiting to be awake by m-th process
        ; When, second process see that someone is sleeping
        ; he take value from array, put his value, and wake sleeping process
        ; then awaken process take value from global array


        ; we are using this global structs
        ; spin_lock -> as mutex for access
        ; sleeping array -> where thread will be sleeping
        ; for_who_array -> telling us for which process we wait to be awaken
        ;                  we use 2^64-1 = 18446744073709551615 as default value instead of 0
        ;                  to ensure interlacing won't happen witch has n=0
        ; swap_array -> for swapping element, here we put or take our value

        pop     r8                              ; m value
        pop     r9                              ; value to be swapped

        ; here across we store global adresses for easier calculation when we need to access some element
        lea     rdi,    [rel spin_lock]         ; dword
        lea     rsi,    [rel sleeping_array]    ; byte
        lea     rcx,    [rel for_who_array]     ; qword
        lea     rdx,    [rel swap_array]        ; qword

;   taking lock
        mov     eax,    1
.busy_wait:
        xchg    dword [rdi], eax
        test    eax, eax
        jnz     .busy_wait

        ; now we are in critical section
        ; we must check if m was waiting for us
        ; if he was not than we should ourself go to sleep

        cmp     r12,    [rcx + 8 * r8]    ; we are checking if m process is waiting for n (us)

        je      .we_wake_up
.we_sleep:
        ;we are first so we put our value and go to sleep
        ;   IMPORTANT
        ;   swap_array element that will be used is index of FIRST process that goes to sleep
        ;   so is our index -> n

        mov     [rdx + 8 * r12],     r9       ; putting value
        mov     byte [rsi + r12],     1       ; we inform that we sleep
        mov     [rcx + 8 * r12], r8           ; we inform for who we wait -> FOR M
        mov     dword [rdi], 0                ; release

;   loop for sleeping
.sleeping:
        mov     eax, 1
.busy_sleep:
        xchg    [rdi], eax
        test    eax, eax
        jnz     .busy_sleep
        ;   we are in critical section
        ;   we must check if we sleep or someone waked us up
        cmp     byte [rsi + r12],     0
        je      .waked_up
        mov     dword [rdi],  0              ; giving away access -> we are still sleeping
        jmp     .sleeping
.waked_up:
        mov     rax,    [rdx + 8 * r12]
        push    rax                                          ; taking value that m-th process gave us
        mov     qword [rcx + 8 * r12], 18446744073709551615  ; we set flag that we don't wait for anyone
        mov     dword [rdi], 0                               ; release

        jmp     .loop_continue

.we_wake_up:
        ; when we are waking up that means few things
        ; first before we wake sleeping process we must put on our stack
        ; value that this process gave us
        ; and than put to this swapping array our value
        ; important thing is index of swapping array and array that this process is sleeping
        ; is m second value as opposed to n-r12 first case

        mov     rax,    [rdx + 8 * r8]
        push    rax                                        ; taking value that sleeping process left for us
                                                           ; and pushing it on our stack

        mov     [rdx + 8 * r8], r9                          ; puting swap value for process that will be awaken
        mov     byte [rsi + r8], 0                          ; we wake process up
        mov     qword [rcx + 8 * r12], 18446744073709551615 ; we set flag that we don't wait for anyone
        mov     qword [rcx + 8 * r8], 18446744073709551615  ; we set same flag for process that will be awaken
                                                            ; to ensure some weird interlacing won't happen

        mov     dword [rdi], 0                             ; release lock

        jmp     .loop_continue

.loop_continue:
        inc     r13                                        ; simply moving to next operation label
        jmp     .main_loop


.program_end:
        mov     rax,    [rsp]                              ; top of the stack is result
        mov     rsp,    rbx                                ; now we must restore ABI, so we move stack pointer
        pop     rbx                                        ; to point where we have stored save values of calles saved registers
        pop     r13
        pop     r12
        ret
