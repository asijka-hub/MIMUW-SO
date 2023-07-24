org 0x7c00


; Wykonujemy skok, wymuszając ustawienie cs na wartość 0.
jmp 0:start


clear:
    mov ah, 0x00
    mov al, 0x03

    int 0x10        ; Call BIOS interrupt to clear the screen
    ret


; Wypisujemy bajty spod adresu w ax, aż do napotkania 0x0.
print:
    mov bx, 0x7e00
    mov ah, 0x0e
print_loop:
    mov al, byte [bx]
    test al, al
    jz print_done

    cmp al, 10
    jne print_normal
print_cr:
    mov dl, al
    mov al, 13
    int 0x10
    mov al, dl
print_normal:
    int 0x10
    inc bx
    jmp print_loop
print_done:
    mov ah, 0x2 ; position cursor
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10
    ret


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


get_current_time:
    push cx

    mov ah, 0
    int 0x1a

    pop cx
    
    mov ax, dx
    ret


; time to print in ax
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

loop_print:
    pop dx          ; Pop the ASCII character from the stack
    ; Print the character to the screen
    push bx
    mov bh, 0       ; Display page 0
    mov ah, 0x0E    ; Video Services function to print character
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

; w cl trzymamy pozycje x
; w ch pozycje y
; przy kazdym callu musimy zapewnic ze sie nie zmieni

; Inicjujemy rejestry segmentowe i stos.
start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x8000
    push ax
    push ax

; kopiujemy dane

    mov ah, 0x02     ; read from disk
    mov al, 1        ; number of sectors to read
    mov ch, 0        ; cylinder number
    mov cl, 2        ; sector number
    mov dh, 0        ; head number
    mov dl, 0x80     ; drive number 0x80 first hard drive
    mov bx, 0x7e00   ; offset where to copy

    int 0x13

    xor cx, cx

    ; clear screan
    ; mov ah, 0x06    ; BIOS function to scroll the screen up and clear it
    ; mov al, 0x00    ; Attribute (0x00 means blank, you can use other values for different colors)
    ; mov cl, 0
    ; mov ch, 0
    ; mov dl, 70
    ; mov dh, 25


    

    ; during main loop this things preveiled
    ; in bx we have address on current char
    ; on stack we have 
    ; min value 
    ; time of start of loop
    ; TOP OF STACK

    ; before first pass of loop we push max 16 bits value as min value
    mov ax, 65535
    push ax

main_loop:
    ; we save time on start of loop
    call get_current_time
    push ax
    ; on top of stack is now saved time of start


    mov ah, 0
    int 0x1a

    ; in dx seconds 

    mov ax, dx
    call clear
    call print
    xor cx, cx

    mov bx, 0x7e00 ; we start from beginning

read_line:

    ; reseting line position
    sub bl, cl
    mov cl, 0
    call advance_position ; now in al we have previous y position of cursor

read_char:
    mov ah, 0

    push cx
    int 0x16
    pop cx
    
    cmp al, 0
    jz read_line ; some useless char was readed alt etc. TODO we must go begging of line

    cmp al, 0dh ; check if enter was readed
    je  is_enter
not_enter:
    cmp al, byte [bx] ; checking if character is matching
    je advance_c
    jmp read_line

is_enter:
    cmp ch, 6
    jne normal_line

last_line:
    cmp byte [bx], 0
    je last_step
    jmp read_line

normal_line:
    cmp byte [bx], 10
    jne read_line

    mov cl, 0
    inc ch
    call advance_position
    
    inc bx
    jmp read_line

    
advance_c:
    inc cl
    call advance_position ; advance one right
    
    inc bx
    
    jmp read_char

last_step:
    ; print time

    mov cl, 0
    mov ch, 24
    call advance_position

    call get_current_time ; in ax is current time
    pop dx ; in dx is now previous time

    sub ax, dx 

    pop dx  ; in dx we have minimum time up to this moment

    cmp dx, ax ; FIXME TODO WTF
    ja  current_smaller
    jmp current_larger
current_smaller:
    push ax ; now min is current

    push ax
    call print_time

    mov cl, 18
    mov ch, 24
    call advance_position
    pop ax

    call print_time
    jmp read_enter

current_larger:
    push dx ; min is the same

    push dx
    call print_time

    mov cl, 18
    mov ch, 24
    call advance_position
    pop dx
    mov ax, dx

    call print_time

read_enter:
    mov ah, 0
    int 0x16
    cmp al, 0dh ; check if enter was readed
    jne read_enter

    jmp main_loop


loop:
    jmp loop


times 510 - ($ - $$) db 0
dw 0xaa55