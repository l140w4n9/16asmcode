mystack segment stack
    db 512 dup(0)
mystack ends 

mydata segment
    g_szEnt db 0AH, 0DH, '$'
    g_szNojmp db "No jmp$" 
    g_szNear db "jmp near",0AH, 0DH,'$'
    g_szShort db "jmp short$"
    g_szOut db "output:$"
mydata ends 

forptr  segment

g_szFor db "jmp for",0AH, 0DH, '$'
JMPFOR:

    mov ax, forptr
    mov ds, ax

    xor ax, ax
    mov ah, 09H
    mov dx, offset g_szFor
    int 21H

    mov ax, 4c00H
    int 21H
forptr ends

mycode segment
START:
    assume ds:mydata
    assume ds:forptr
    mov ax, mydata
    mov ds, ax

    ; 进行短跳
    jmp short JMPSHORT

    db 102 dup(0)

    xor ax, ax
    mov ah, 09H
    lea dx, g_szNojmp
    int 21H

    xor ax, ax
    mov ah, 09H
    lea dx, g_szEnt
    int 21H

    mov ax, 4c00H
    int 21H
    
JMPSHORT:

    xor ax, ax
    mov ah, 09H
    mov dx, offset g_szShort
    int 21H

    xor ax, ax
    mov ah, 09H
    mov dx, offset g_szEnt
    int 21H

    ; 进行近跳
    jmp near ptr JMPNEAR
    db 32769 dup(0)

    xor ax, ax
    mov ah, 09H
    lea dx, g_szNojmp
    int 21H

JMPNEAR:


    xor ax, ax
    mov ah, 09H
    lea dx, g_szNear
    int 21H

    ; 进行远跳
    jmp far ptr JMPFOR

    mov ax, 4c00H
    int 21H

mycode ends 
end START
