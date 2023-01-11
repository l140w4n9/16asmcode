mystack segment stack
    db 512 dup(0)
mystack ends 

mydata segment
    g_szBufLen db 255
    g_szlen db ?
    g_szBuf db 255 dup (0)
    g_szOut1 db 0aH, 0dH, "Have P$"
    g_szOut2 db 0aH, 0dH, "NO P$"
mydata ends 

mycode segment
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax

    xor ax, ax
    mov ah, 0AH
    lea dx, g_szBufLen
    int 21H

    lea bx, g_szBuf
    mov si, 0

    xor cx, cx
    mov cl, g_szlen

FIND:
    ; 进行比较是否是P字符，不是调转到CONTINUEFIND，是输出
    cmp byte ptr[bx + si], 'P'
    jne CONTINUEFIND

    mov ah, 09H
    lea dx, g_szOut1
    int 21H

    mov ax, 4c00H
    int 21H

CONTINUEFIND:
    ; 循环索引加一，直到字符读完
    inc si
    cmp si, cx
    jl FIND

    
    mov ah, 09H
    lea dx, g_szOut2
    int 21H

    mov ax, 4c00H
    int 21H

mycode ends 
end START
