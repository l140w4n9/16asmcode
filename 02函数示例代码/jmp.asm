mystack segment stack
    db 512 dup(0)
mystack ends 

mydata segment
    g_szEnt db 0AH, 0DH, '$'
    g_szNojmp db "No jmp$" 
    g_szNear db "jmp near$"
    g_szShort db "jmp short$"
    g_szFor db "jmp for$"
    g_szOut db "output:$"
mydata ends 

forptr  segment

JMPFOR:
    xor ax, ax
    mov ah, 09H
    mov dx, offset g_szFor
    int 21H

    xor ax, ax
    mov ah, 09H
    mov dx, offset g_szEnt
    int 21H

forptr ends

mycode segment
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax

    ; 进行短跳
    jmp short JMPSHORT

    db 107 dup(0)

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

    mov ax, 4c00H
    int 21H

mycode ends 
end START
