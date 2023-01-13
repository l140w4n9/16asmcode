  
mycode segment

; void *memset( void *dest, int c, size_t count );
memset PROC far c uses cx di dest:word, char:word, count:word
    mov ax, ds
    mov es, ax
    
    ; 串存储
    mov di, dest
    mov cx, count
    mov ax, char
    rep stosb

    ret 6
memset ENDP

; int memcmp( const void *buf1, const void *buf2, size_t count );
memcmp PROC far c uses bx di si buf1:word, buf2:word, count:word

    xor bx, bx
    mov di, buf1
    mov si, buf2
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
        cmp bx, count
        je  MEMCMPEND
        inc bx
        jmp MEMCMPSTART
    
    MEMCMPEND:
        mov ax, 0
        jmp MEMCMPCLS
    
    MEMCMPCLS:
    ret 6
memcmp ENDP

; void *memcpy( void *dest, const void *src, size_t count );
memcpy PROC far c uses es di si cx dest:word, src:word, count:word
    mov ax, ds
    mov es, ax
    
    ; 进行串传送
    mov di, dest
    mov si, src
    mov cx, count
    rep movsb

    mov ax, dest
    
    ret 6
memcpy ENDP

; size_t strlen( const char *string );
strlen PROC far c uses es di string:word
    mov ax, ds  ;段基址
    mov es, ax

    mov di, string ;*string
    mov al, '$'
    repne scasb
    
    sub di, string
    mov ax, di
    dec ax

    ret 2
strlen ENDP

; int strcmp( const char *string1, const char *string2 );
strcmp PROC far c uses si di bx string1:word, string2:word
    local @str1len:word
    local @str2len:word

    ; 获取字符串大小
    invoke strlen, string1
    mov @str1len, ax
    invoke strlen, string2
    mov @str2len, ax

    mov di, string1
    mov si, string2

    ; 比较大小是否一样
    cmp ax, @str1len
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
            cmp bx, @str1len
            je CHARTCMPEND
            inc bx
            jmp CHARTCMP

        CHARTGRE:
            mov ax, -1
            jmp STRCMPEND

        CHARTCMPEND:
            mov ax, 0

    STRCMPEND:
        ret 4
strcmp ENDP

; char *strcpy( char *strDestination, const char *strSource );
strcpy PROC far c strDestination:word, strSource:word

    local @strSourceLen
    ; 获取源字符串大小
    invoke strlen, strSource
    inc ax
    mov @strSourceLen, ax

    ;进行内存copy
    invoke memcpy, strDestination, strSource, @strSourceLen
    mov ax, strDestination
    ret 4
strcpy ENDP

; char *strcat( char *strDestination, const char *strSource );
strcat PROC far c strDestination:word, strSource:word
    local @strDeslen
    local @strSoulen
   ; 申请局部变量空间

    ; 获取字符串大小
    invoke strlen, strDestination ; *strDestination
    mov @strDeslen, ax
    invoke strlen, strSource ; *strSource
    mov @strSoulen, ax

    ;进行内存copy
    mov ax, strDestination
    add ax, @strDeslen
    invoke memcpy, ax, strSource, @strSoulen
    mov ax, strDestination
    
    ret 4
strcat ENDP

mycode ends
end 
