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

; void *memset( void *dest, int c, size_t count );
MEMSET:
    push bp
    mov bp, sp

    push cx
    push di

    mov ax, ds
    mov es, ax

    ; 串存储
    mov di, [bp + 4]
    mov cx, [bp + 8]
    mov al, [bp + 6]
    rep stosb

    pop di
    pop cx
    mov sp, bp
    pop bp
    ret 6

; int memcmp( const void *buf1, const void *buf2, size_t count );
MEMCMP:
    push bp
    mov bp, sp

    push bx
    push di
    push si
    
    xor bx, bx
    mov di, [bp + 4]
    mov si, [bp + 6]
    MEMCMPSTART:
        mov al, [di + bx]
        cmp al, [si + bx]
        je  MEMCMPEQU
        jg  MEMCMPGRE
        mov ax, 1
        jmp MEMCMPCLS

    MEMCMPGRE:
        mov ax, -1
        jmp MEMCMPCLS

    MEMCMPEQU:
        cmp bx, [bp + 8]
        je  MEMCMPEND
        inc bx
        jmp MEMCMPSTART
    
    MEMCMPEND:
        mov ax, 0
        jmp MEMCMPCLS
    
    MEMCMPCLS:
    pop si
    pop di
    pop bx
    mov sp, bp
    pop bp
    ret 6

; void *memcpy( void *dest, const void *src, size_t count );
MEMCPY:
    push bp
    mov bp, sp

    push es
    push di
    push si
    push cx

    mov ax, ds
    mov es, ax
    
    ; 进行串传送
    mov di, [bp + 4]
    mov si, [bp + 6]
    mov cx, [bp + 8]
    rep movsb
    
    pop cx
    pop si
    pop di
    pop es
    mov sp, bp
    pop bp
    ret 6

; size_t strlen( const char *string );
STRLEN:
    push bp
    mov bp, sp

    push es
    push di

    mov ax, ds  ;段基址
    mov es, ax

    mov di, [bp + 4] ;*string
    mov al, '$'
    repne scasb
    
    sub di, [bp + 4]
    mov ax, di
    dec ax

    pop di
    pop es
    mov sp, bp
    pop bp
    ret 2


; int strcmp( const char *string1, const char *string2 );
STRCMP:
    push bp
    mov bp, sp
    sub sp, 4 ; 申请局部变量空间

    push si
    push di
    push bx

    ; 获取字符串大小
    push [bp + 4] ; *string1
    call STRLEN
    mov [bp - 2], ax
    push [bp + 6] ; *string2
    call STRLEN
    mov [bp - 4], ax

    mov di, [bp + 4]
    mov si, [bp + 6]

    ; 比较大小是否一样
    cmp ax, [bp - 2]
    je STRCMPCONTENT    ; 相等继续比较
    jg STRCMPSGF        ; 2大于1返回-1

    mov ax, 1
    jmp STRCMPEND       ;2小于1返回1

    STRCMPSGF:
        mov ax, -1
        jmp STRCMPEND

    
    STRCMPCONTENT:
        xor bx, bx
        CHARTCMP:
            mov al, [si+bx]
            cmp al, [di+bx]
            je CHARTEQU
            jg CHARTGRE
            mov ax, 1
            jmp STRCMPEND       ;2小于1返回1

        CHARTEQU:
            cmp bx, [bp - 2]
            je CHARTCMPEND
            inc bx
            jmp CHARTCMP

        CHARTGRE:
            mov ax, -1
            jmp STRCMPEND

        CHARTCMPEND:
            mov ax, 0

    STRCMPEND:
        pop bx
        pop di
        pop si
         
        add sp, 4 ; 释放局部变量空间
        mov sp, bp
        pop bp
        ret 4

; char *strcpy( char *strDestination, const char *strSource );
STRCPY:
    push bp
    mov bp, sp

    ; 获取源字符串大小
    push [bp + 6]
    call STRLEN

    ;进行内存copy
    push ax
    push [bp + 6]
    push [bp + 4]
    call MEMCPY
    mov ax, [bp + 4]

    mov sp, bp
    pop bp
    ret 4

; char *strcat( char *strDestination, const char *strSource );
STRCAT:
    push bp
    mov bp, sp
    sub sp, 4 ; 申请局部变量空间

    ; 获取字符串大小
    push [bp + 4] ; *strDestination
    call STRLEN
    mov [bp - 2], ax
    push [bp + 6] ; *strSource
    call STRLEN
    mov [bp - 4], ax

    ;进行内存copy
    push [bp - 2]
    push [bp + 6]
    mov ax, [bp + 4]
    add ax,[bp - 2] 
    push ax
    call MEMCPY
    mov ax, [bp + 4]
    
    add sp, 4 ; 释放局部变量空间
    mov sp, bp
    pop bp
    ret 4

; main
START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax

    ; memset使用
    mov ax, 16
    push ax
    mov ax, 'A'
    push ax
    lea ax, g_szstrd
    push ax
    call MEMSET

    ; memcmp使用
    mov ax,0cH
    push ax
    lea ax, g_szstr1
    push ax
    lea ax, g_szstr2
    push ax
    call MEMCMP
    

    ; strcat使用
    lea ax, g_szstr3
    push ax
    lea ax, g_szstr2
    push ax
    call STRCAT

    ; strcpy使用
    lea ax, g_szstr1
    push ax
    lea ax, g_szstrd
    push ax
    call STRCPY

    ; memcpy使用
    mov ax, offset g_szstr2 - offset g_szstr1
    push ax
    lea ax, g_szstr1
    push ax
    lea ax, g_szstrd
    push ax
    call MEMCPY

    ; strcmp使用
    mov ax, offset g_szstr2
    push ax
    mov ax, offset g_szstr1
    push ax
    call STRCMP

    ; strlen使用
    lea ax, g_szstr1
    push ax
    call STRLEN
    

    mov ax, 4c00H
    int 21H

mycode ends
end START
