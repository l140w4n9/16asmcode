mystack segment stack
    db 512 dup(0)
mystack ends

mydata segment
    g_szStr1 db 11H, 22H, 33H, 44H, 55H, 66H, 77H, 88H, 99H, 0aaH, 0bbH, 0ccH, 0ddH, 0eeH, 0ffH
    g_szStr2 db 16 dup(0)
    g_szStr3 db 11H, 22H, 33H, 44H, 77H, 66H, 77H, 88H, 99H, 0aaH, 55H, 0ccH, 0ddH, 0eeH, 0ffH
mydata ends

mycode segment
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax
    
    mov ax, mydata
    mov es, ax

    lea di, g_szStr1

    mov ax, 1122H
    scasw

    mov ax, 4200H
    int 21H
mycode ends
end START
