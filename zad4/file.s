org 0x7c00


; we make jump so cs is 0
jmp 0:start

; clear first 7 lines of the screen
clear:
    mov ah, 0x2 ; position cursor
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10


    xor cx, cx
    mov bh, 0x7
    mov dh, 7
    mov dl, 80
    mov ah, 0x06
    mov al, 0
    int 0x10

    ret

; clear last line of the screen
clear_last_line:
    mov ah, 0x2 ; position cursor
    mov bh, 0
    mov dh, 24
    mov dl, 0
    int 0x10

    mov bh, 0x7
    mov ch, 24
    mov cl, 0
    mov dh, 24
    mov dl, 80
    mov ah, 0x07
    mov al, 0
    int 0x10

    ret

; prints bytes untill \n or 0
print_line:
    push cx
    push bx
    mov ah, 0x0e
print_loop:
    mov al, byte [bx]
    cmp al, 10
    je print_done
    cmp al, 0
    je print_done

    int 0x10

    inc bx
    jmp print_loop
print_done:
    pop bx
    pop cx
    ret

; advance cursor position to that in cl and ch
advance_position:
    push bx
    push cx

    mov bh, 0
    mov dl, cl
    mov dh, ch
    mov ah, 0x2
    int 0x10

    pop cx
    pop bx    

    ret

; in ax return current time
get_current_time:
    push cx

    mov ah, 0
    int 0x1a

    pop cx
    
    mov ax, dx
    ret


; time to print in ax
; flag in si
; if flag is 0
; printf in left corner
; if flag is set to 1 print in left corner
print_time:
    push cx
    push bx

    mov cx, 18
    xor dx, dx
    div cx

    mov cx, 10      ; Set CX to 10 (used to divide the number by 10)
    mov bx, 0       ; Initialize BX to 0 (used to store the number of digits)

convert_loop:
    xor dx, dx      ; Clear DX to prepare for division
    div cx          ; Divide AX by CX, quotient in AX, remainder in DX
    add dl, '0'     ; Convert the remainder (single-digit) to ASCII character
    push dx         ; Push the ASCII character onto the stack
    inc bx          ; Increment BX to count the number of digits
    test ax, ax     ; Check if quotient (AX) is zero
    jnz convert_loop ; If not zero, continue the loop

    cmp si, 0
    jne right_corner
left_corner:
    mov cl, 0
    mov ch, 24
    call advance_position
    jmp loop_print
right_corner:
    mov cl, 80
    sub cl, bl
    dec cl
    mov ch, 24
    call advance_position

loop_print:
    pop dx          ; Pop the ASCII character from the stack
    ; Print the character to the screen
    push bx
    mov bh, 0       ; Display page 0
    mov ah, 0x0e    ; Video Services function to print character
    mov al, dl
    int 0x10        ; Call interrupt 0x10 to print the character
    pop bx

    dec bx          ; Decrement BX to keep track of the remaining digits
    test bx, bx
    jnz loop_print  ; If not zero, continue printing

    pop bx
    pop cx
    ret


; main program ------------------------------------------------ 

; in cl we keep x position of cursor
; in ch we keep y position of cursor

; intialized the stack registers
start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x8000
    push ax
    push ax

; copying the data from drive

    mov ah, 0x02     ; read from disk
    mov al, 1        ; number of sectors to read
    mov ch, 0        ; cylinder number
    mov cl, 2        ; sector number
    mov dh, 0        ; head number
    mov dl, 0x80     ; drive number 0x80 first hard drive
    mov bx, 0x7e00   ; offset where to copy

    int 0x13

    xor cx, cx

    
    mov ax, 0x3      ; BIOS video mode 03h (80x25 text mode)
    int 0x10            ; BIOS video services

    ; during main loop this things preveiled
    ; in bx we have address on current char
    ; on stack we have 

    ; min time of loop -> time of start of loop -> TOP OF STACK

    ; before first pass of loop we push max 16 bits value as min value (in u2 2^15-1)
    mov ax, 32767 ; 
    push ax

main_loop:
    ; we save time on start of loop
    call get_current_time
    push ax
    ; on top of stack is now saved time of start

    call clear

    ; call print
    xor cx, cx ; cursor in now at start of first line

    mov bx, 0x7e00 ; we start from beginning
process_line:
    call print_line

read_line:

    ; reseting line position
    sub bl, cl
    mov cl, 0
    call advance_position ; cursor in now at the start of the line

read_char:
    mov ah, 0

    push cx
    int 0x16
    pop cx
    
    cmp al, 0
    jz read_line ; some useless char was readed alt etc, we must go to beginning of line

    cmp al, 27  ; check if escape was readed, if so reset loop
    je main_loop

    cmp al, 0dh ; check if enter was readed
    je  is_enter
not_enter:
    cmp al, byte [bx]   ; checking if character is matching
    je advance_c        ; if character is matching we move cursor 1 place right
    jmp read_line

is_enter:
    cmp ch, 6           ; we must check if it's potentialy last line or not
    jne normal_line

last_line:
    cmp byte [bx], 0    ; if it's last line, we check if last byte is 0, end of file
    je last_step
    jmp read_line

normal_line:
    cmp byte [bx], 10   ; if not last line, we check if we goot new line character
    jne read_line

    mov cl, 0
    inc ch              ; we advance cursor to the beginning of the next line
    call advance_position
    
    inc bx
    jmp process_line

    
advance_c:
    inc cl
    call advance_position ; advance one right
    
    inc bx
    
    jmp read_char

last_step:
    ; in the last step of the looop we must print min time, and time that passed since begging of loop

    call clear_last_line ; we must clear last line with times so in the next loop they don't colidate

    mov cl, 0
    mov ch, 24
    call advance_position  


    call get_current_time ; in ax is current time
    pop dx ; in dx is now time when loop started

    sub ax, dx ; now in the ax is the time that passed

    pop dx  ; in dx we have minimum time up to this moment

    cmp dx, ax ; FIXME TODO WTF
    jae  current_smaller ; >=
    jmp current_larger
current_smaller:
    push ax ; now min is current

    push ax ; we must preserve value of ax 
    mov  si, 0 ; first we printf curent time in left corner so flag is 0
    call print_time
    pop ax

    mov si, 1  ; then we printf min time (that is the same) in the right corner
    call print_time
    jmp read_escape

current_larger:
    push dx ; min is the same

    push dx ; preserving dx
    mov  si, 0
    call print_time
    pop dx  ; restoring dx
    mov ax, dx ; min is in the dx
    
    mov si, 1
    call print_time

read_escape:    ; wait for escape
    mov ah, 0
    int 0x16
    cmp al, 27 ; check if enter was readed
    jne read_escape

    jmp main_loop

times 510 - ($ - $$) db 0 ; fill the rest of sector with 0
dw 0xaa55                 ; magic value for bios to find our bootloader