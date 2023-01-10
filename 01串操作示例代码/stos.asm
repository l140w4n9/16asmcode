mystack segment stack
    db 512 dup(0)
mystack ends

mydata segment
    g_szStr2 db 16 dup(0)
mydata ends

mycode segment
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax
    
    mov ax, mydata
    mov es, ax
    lea di, g_szStr2

    mov ax, 6568H
    stosw
    mov ax, 6c6cH
    stosw
    mov al, 6fH
    stosb

    mov ax, 4200H
    int 21H
mycode ends
end START
