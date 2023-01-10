mystack segment stack
    db 512 dup(0)
mystack ends

mydata segment
    g_szStr1 db 11H, 22H, 33H, 44H, 55H, 66H, 77H, 88H, 99H, 0aaH, 0bbH, 0ccH, 0ddH, 0eeH, 0ffH
    g_szStr2 db 16 dup(0)
mydata ends

mycode segment
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax
    
    mov ax, mydata
    mov es, ax
    ; 串传送
    lea si, g_szStr1
    lea di, g_szStr2
    mov cx, offset g_szStr2 - offset g_szStr1
    
    movsb
    movsb
    movsb
    movsb
    movsb
    movsw
    movsw
    movsw
    movsw
    movsw
    movsw
    movsw
    movsw

    mov ax, 4200H
    int 21H
mycode ends
end START
