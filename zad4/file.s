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

advance_right:    
    push bx

    mov ah, 0x3
    mov bh, 0
    int 0x10 ; in dl and dh are x,y cursor position
    
    inc dl
    mov ah, 0x2
    int 0x10  ; mov cursor one position left

    pop bx
    ret

advance_down:    
    push bx

    mov ah, 0x3
    mov bh, 0
    int 0x10 ; in dl and dh are x,y cursor position
    
    inc dh
    mov dl, 0
    mov ah, 0x2
    int 0x10  ; mov cursor one position left

    pop bx
    ret

reset_line:
    push bx

    mov ah, 0x3
    mov bh, 0
    int 0x10 ; in dl and dh are x,y cursor position
    
    mov cl, dl ; we want to return x, to know how many chars we must go back
    mov dl, 0
    mov ah, 0x2
    int 0x10
    xor ax, ax
    mov al, cl

    pop bx
    ret

; main program ------------------------------------------------ 

; Inicjujemy rejestry segmentowe i stos.
start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x8000

; kopiujemy dane
    mov ah, 0x02     ; read from disk
    mov al, 1        ; number of sectors to read
    mov ch, 0        ; cylinder number
    mov cl, 2        ; sector number
    mov dh, 0        ; head number
    mov dl, 0x80     ; drive number 0x80 first hard drive
    mov bx, 0x7e00   ; offset where to copy

    int 0x13

    ; clear screan
    ; mov ah, 0x06    ; BIOS function to scroll the screen up and clear it
    ; mov al, 0x00    ; Attribute (0x00 means blank, you can use other values for different colors)
    ; mov cl, 0
    ; mov ch, 0
    ; mov dl, 70
    ; mov dh, 25


    ; during main lodhop this things preveiled
    ; in bx we have address on current char
main_loop:
    call clear
    call print
    
    mov bx, 0x7e00 ; we start from beginning

read_line:
    call reset_line ; now in al we have previous y position of cursor
    sub bx, ax      ; TODO legit check if ax is correct

read_char:
    mov ah, 0
    int 0x16
    cmp al, 0
    jz read_line ; some useless char was readed alt etc. TODO we must go begging of line

    cmp al, 0dh ; check if enter was readed
    je  is_enter
not_enter:
    cmp al, byte [bx] ; checking if character is matching
    je advance_c
    jmp read_line

is_enter:
    push bx

    mov ah, 0x3
    mov bh, 0
    int 0x10 ; in dl and dh are x,y cursor position

    pop bx

    cmp dh, 6
    jne normal_line

last_line:
    cmp byte [bx], 0
    je last_step
    jmp read_line

normal_line:
    cmp byte [bx], 10
    jne read_line

    push bx
    mov bx, 0
    inc dh
    mov dl, 0
    mov ah, 0x2
    int 0x10
    pop bx
    
    
    inc bx
    jmp read_line

    
advance_c:
    call advance_right
    inc bx
    jmp read_char

last_step:
    jmp main_loop

; TODO


; read_loop:
;     mov ah, 0
;     int 0x16
;     cmp al, 0
;     jz read_loop
    
;     mov ah, 0x0e
;     int 0x10
;     mov ah, 0
    
;     cmp al, 0dh
;     jne read_loop

;     mov bx, 0x7e00

loop:
    jmp loop


times 510 - ($ - $$) db 0
dw 0xaa55
