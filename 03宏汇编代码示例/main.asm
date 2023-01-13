include string.inc

mystack segment stack
    db 512 dup(0)
mystack ends

mydata segment
    g_szstr1 db "Hella World!$"
    g_szstr2 db "Hello World!$", 16 dup(?)
    g_szstr3 db "77777777777$"
    g_szstrd db 16 dup(?)
mydata ends

mycode segment
; main
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax

    ; memcpy使用
    invoke memcpy, offset g_szstrd, offset g_szstr1, offset g_szstr2 - offset g_szstr1

    ; memcmp使用
    invoke memcmp, offset g_szstr1, offset g_szstr2, 0cH

    ; memset使用
    invoke memset, offset g_szstrd, 'A', 16

    ; strlen使用
    invoke strlen, offset g_szstr1
    
    ; strcmp使用
    invoke strcmp, offset g_szstr1, offset g_szstr2

    ; strcat使用
    invoke strcat,  offset g_szstr2, offset g_szstr3

    ; strcpy使用
    invoke strcpy, offset g_szstrd, offset g_szstr1

    mov ax, 4c00H
    int 21H

mycode ends
end START
