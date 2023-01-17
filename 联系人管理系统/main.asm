assume ds:mydata, es:myheap

mystack segment stack
	db 10000H dup(?)
mystack ends

myheap segment
    db 10000H dup(?)
myheap ends

; 联系人信息结构
Con struc
    m_szNmae    db 32 dup(0)
    m_szPhone   db 12 dup(0)
    m_szAddr      db 32 dup(0)
Con ends

; 联系人节点
ConNode struc
    m_con  db 76 dup(0)
    m_prev dw 0
    m_next dw 0
ConNode ends

mystring segment
; void *memset( word segment, void *dest, int c, size_t count );
MEMSET:
    push bp
    mov bp, sp

    push cx
    push di
	push es

    mov ax, [bp + 6]
    mov es, ax

    ; 串存储
    mov di, [bp + 8]	; dest
    mov cx, [bp + 12]	; count
    mov al, [bp + 10]	; c
    rep stosb

	mov ax, [bp + 8]

	pop es
    pop di
    pop cx
    mov sp, bp
    pop bp
    retf 8

; int memcmp( const void *buf1, const void *buf2, size_t count );
MEMCMP:
    push bp
    mov bp, sp

    push bx
    push di
    push si
    
    xor bx, bx
    mov di, [bp + 6]
    mov si, [bp + 8]
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
        cmp bx, [bp + 10]
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
    retf 6

; void *memcpy( word destSegment, void *dest, word srcSegment, const void *src, size_t count );
MEMCPY:
    push bp
    mov bp, sp

    push ds
    push es
    push di
    push si
    push cx

    mov ax, [bp + 6]
    mov es, ax
    mov ax, [bp + 10]
    mov ds, ax
    
    ; 进行串传送
    mov di, [bp + 8]
    mov si, [bp + 12]
    mov cx, [bp + 14]
    rep movsb
    
    pop cx
    pop si
    pop di
    pop es
    pop ds

    mov sp, bp
    pop bp
    retf 6

; size_t strlen(word segment, const char *string );
STRLEN:
    push bp
    mov bp, sp

    push es
    push di

    mov ax, [bp + 6]  ;段基址
    mov es, ax

    mov di, [bp + 8] ;*string
    mov al, '$'
    repne scasb
    
    sub di, [bp + 8]
    mov ax, di
    dec ax

    pop di
    pop es
    mov sp, bp
    pop bp
    retf 2
; size_t strlens(word segment, const char *string );
STRLENS:
    push bp
    mov bp, sp

    push bx
    push di
    push ds

    mov ax, [bp + 6]  ;段基址
    mov ds, ax

    xor di, di

    mov bx, [bp + 8]
    mov al, '$'

    STRLENSSTART:
    cmp al, [bx + di]
    je STRLENSEND
    inc di
    jmp STRLENSSTART

    STRLENSEND:
    mov ax, di
    pop ds
    pop di
    pop bx

    mov sp, bp
    pop bp
    retf 4


; int strcmp( const char *string1, const char *string2 );
STRCMP:
    push bp
    mov bp, sp
    sub sp, 4 ; 申请局部变量空间

    push si
    push di
    push bx

    ; 获取字符串大小
    push [bp + 6] ; *string1
    call STRLEN
    mov [bp - 2], ax
    push [bp + 8] ; *string2
    call STRLEN
    mov [bp - 4], ax

    mov di, [bp + 6]
    mov si, [bp + 8]

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
        retf 4

; char *strcpy( char *strDestination, const char *strSource );
STRCPY:
    push bp
    mov bp, sp

    ; 获取源字符串大小
    push [bp + 8]
    call STRLEN

    ;进行内存copy
    push ax
    push [bp + 8]
    push [bp + 6]
    call MEMCPY
    mov ax, [bp + 6]

    mov sp, bp
    pop bp
    retf 4

; char *strcat( char *strDestination, const char *strSource );
STRCAT:
    push bp
    mov bp, sp
    sub sp, 4 ; 申请局部变量空间

    ; 获取字符串大小
    push [bp + 6] ; *strDestination
    call STRLEN
    mov [bp - 2], ax
    push [bp + 8] ; *strSource
    call STRLEN
    mov [bp - 4], ax

    ;进行内存copy
    push [bp - 2]
    push [bp + 8]
    mov ax, [bp + 6]
    add ax,[bp - 2] 
    push ax
    call MEMCPY
    mov ax, [bp + 6]
    
    add sp, 4 ; 释放局部变量空间
    mov sp, bp
    pop bp
    retf 4

; int strsub(word srcsegment, char* src, word subsegment, char* substr)
STRSUB:
    push bp
    mov bp, sp
    sub sp, 8

    push ds
    push es
    push si
    push di
    push bx

    mov ds, [bp + 6]
    mov es, [bp + 10]

    mov si, [bp + 8]
    mov di, [bp + 12]

    ; 获取源字符串长度
    mov ax, [bp + 8]
    push ax
    mov ax, [bp + 6]
    push ax
    call mystring:STRLENS
    mov [bp - 2], ax

    ; 获取子串字符串长度
    mov ax, [bp + 12]
    push ax
    mov ax, [bp + 10]
    push ax
    call mystring:STRLENS
    mov [bp - 4], ax

    dec word ptr[bp - 2]
    dec word ptr[bp - 4]

    ; 双指针清零
    mov word ptr[bp - 6], 0 ; src
    mov word ptr[bp - 8], 0 ; sub

    ; 寻找第一相同的位置 
    STRSUBFIND:
    mov bx, [bp - 6]
    mov al, byte ptr ds:[si]
    cmp al, byte ptr es:[di]
    je STRSUBSTARTINIT
    cmp bx, [bp - 2]
    je  STRSUBFINDEND
    inc word ptr[bp - 6]
    inc si
    jmp STRSUBFIND

    ; 从第一个开始相同的位置进行比较
    STRSUBSTARTINIT:
    xor bx, bx
    STRSUBSTART:
    mov al, byte ptr ds:[si + bx]
    cmp al, byte ptr es:[di + bx]
    jne STRSUBFINDFALI
    cmp bx, [bp - 4]
    je STRSUBSTARTEND
    inc bx
    jmp STRSUBSTART

    STRSUBFINDFALI:
    inc si
    jmp STRSUBFIND


    STRSUBFINDEND:
    mov ax, 0
    jmp STRSUBEND

    STRSUBSTARTEND:
    mov ax, 1
    jmp STRSUBEND


    STRSUBEND:
    pop bx
    pop di
    pop si
    pop es
    pop ds

    add sp, 8
    mov sp, bp
    pop bp
    retf 8

mystring ends

myio segment
; void print(const char *string)
PRINT:
	push bp
	mov bp, sp

	push dx

	; 输出字符串
	mov ah, 09h
	mov dx, [bp + 6]
	int 21H

	pop dx
	mov sp, bp
	pop bp
	retf 2

; void prints(word segment, const char *string)
PRINTS:
	push bp
	mov bp, sp

	push dx
    push ds

    mov ax, [bp + 6]
    mov ds, ax

	; 输出字符串
	mov ah, 09h
	mov dx, [bp + 8]
	int 21H

    pop ds
	pop dx
	mov sp, bp
	pop bp
	retf 4

; int scan(char *buf)
SCAN:
	push bp
	mov bp, sp

	push bx
	push es
	push cx
	push di
	push si
	push dx

	; 字符缓冲区
	sub sp, 257
	push ds
	mov ax, ss
	mov ds, ax
	mov bx, sp
	mov byte ptr[bx + 2], 255
	mov byte ptr[bx + 3], 0

	; 接收字符串
	mov dx, sp
	add dx, 2
	mov ah, 0aH
	int 21H

	xor cx, cx
	mov cl, byte ptr[bx + 3]
	
	mov si, cx
	mov byte ptr[bx + si + 4], '$'
	inc cx

	;进行串传送
	pop es
	add dx, 2
	mov si, dx
	mov di, [bp + 6]
	rep movsb

	mov ax, es
	mov ds, ax

	xor ax, ax
	mov al, byte ptr ss:[bx + 3]
	
	; 释放缓冲区
	add sp, 257

	pop dx
	pop si
	pop di
	pop cx
	pop es
	pop bx

	mov sp, bp
	pop bp
	retf 2

; FILE *fopen( const char *filename, word mode );
FOPEN:
	push bp
	mov bp, sp
    sub sp, 2

	push bx
	push cx
	push dx

	; 打开文件，W+
	mov ax, 1
	cmp ax, [bp + 8]
	je FOPENWP

	; 打开文件，RW
	mov ax, 2
	cmp ax, [bp + 8]
	je FOPENRW

	; 打开文件，RA+
	mov ax, 4
	cmp ax, [bp + 8]
	je FOPENAP
    jmp FOPENFAIL

	FOPENWP:
		mov ah, 3cH
		xor cx, cx
		mov dx, [bp + 6]
		int 21H
		jc FOPENFAIL
		jmp FOPENEND

	FOPENRW:
		mov ah, 3dH
		mov al, 2
		mov dx, [bp + 6]
		int 21H
		jc FOPENFAIL
		jmp FOPENEND

	FOPENAP:
		mov ah, 3dH
		xor cx, cx
		mov dx, [bp + 6]
		int 21H
		jc FOPENFAIL
        mov [bp - 2], ax
		; 偏移文件指针到尾部
        ; mov [bp - 2], ax
        ; push ds
        ; mov ax, ss
        ; mov ds, ax
        ; FOPENSEEK:
        ; mov bx, [bp - 2]
        ; mov cx, bp
        ; sub cx, 257
        ; mov dx, cx
        ; mov cx, 00ffH
        ; mov ah, 3fH
        ; int 21H
        ; jc FOPENFAIL
        ; cmp ax, 0
        ; jne FOPENSEEK
        ; mov ax, [bp - 2]
        ; pop ds

		mov bx, ax
		mov dx, 0
		mov cx, 0
		mov ah, 42H
        mov al, 02H
		int 21H
		jc FOPENFAIL
        mov ax, [bp - 2]
		jmp FOPENEND


	FOPENFAIL:
		mov ax, 0
		jmp FOPENEND

	FOPENEND:
	pop dx
	pop cx
	pop bx
    add sp, 2

	mov sp, bp
	pop bp
	retf 4

; size_t fwrite( const void *buffer, size_t count, FILE *stream );
FWRITE:
	push bp
	mov bp, sp

	push bx
	push cx
	push dx

	; 写入
	mov ah, 40H
	mov bx, [bp + 10]
	mov cx, [bp + 8]
	mov dx, [bp + 6]
	int 21H

	pop dx
	pop cx
	pop bx

	mov sp, bp
	pop bp
	retf 6

; int fseek( FILE *stream, word offset, word mode );
FSEEK:
    push bp
    mov bp, sp

    push bx
    push dx
    push cx

    ; 偏移文件指针
    mov bx, [bp + 6]
    mov dx, [bp + 8]
    mov cx, 0
    mov ah, 42H
    mov al, [bp + 10]
    int 21H

    pop cx
    pop dx
    pop bx

    mov sp, bp
    pop bp
    retf 6

; size_t fread( void *buffer, size_t count, FILE *stream );
FREAD:
    push bp
    mov bp, sp

    push bx
    push cx
    push dx

    ; 读文件到缓冲区
    mov bx, [bp + 10]
    mov cx, [bp + 8]
    mov dx, [bp + 6]
    mov ah, 3fh
    int 21H

    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp
    retf 6

; int fclose( FILE *stream );
FCLOSE:
    push bp
    mov bp, sp
    
    push bx

    mov ah, 3eH
    mov bx, [bp + 6]
    int 21H
    jc FCLOSEEND
    mov ax, 0

    FCLOSEEND:
    pop bx

    mov sp, bp
    pop bp
    retf 2

; size_t freadline(void *buffer, FILE *stream);a
myio ends

mylib segment
; void *malloc( size_t size );
MALLOC:
    push bp
    mov bp, sp

    push ds
    push bx

    ; 把堆置为数据段
    mov ax, myheap
    mov ds, ax
    xor bx, bx

    ; 循环查看块是否可用
    MALLOCSTART:
        mov ax, 0
        cmp [bx], ax         ; 查看块是否可用，等于0可用
        jne MALLOCNEXT      ; 可用查看块大小，不可用寻找下一个块

        cmp [bx + 2], ax     ; 查看是否是尾部，是返回空间
        je  MALLOCEND       
        mov ax, [bp + 6]
        cmp [bx + 2], ax
        jae MALLOCEND       ; 大小合适结束寻找
        jmp MALLOCNEXT

    MALLOCNEXT:     ;下一个块
        mov ax, [bx + 2]
        add bx, ax
        add bx, 4
        jmp MALLOCSTART

    MALLOCEND:
    mov word ptr[bx], 0ffffH
    mov ax, [bp + 6]
    mov [bx + 2], ax
    mov ax, bx
    add ax, 4

    pop bx
    pop ds

    mov sp, bp
    pop bp
    retf 2

; void free( void *memblock );
FREE:
    push bp
    mov bp, sp

    push bx

    mov bx, [bp + 6]

    ; 把块置为可用
    mov ax, 0
    mov es:[bx - 4], ax

    ; 块数据清零
    mov ax, es:[bx - 2]
    push ax
    mov ax, 0
    push ax
    push bx
    push es
    call mystring:MEMSET

    pop bx

    mov sp, bp
    pop bp
    retf 2
; void *stdmalloc( size_t size );
STDMALLOC:
    push bp
    mov bp, sp

    push bx

    mov ah, 48H
    mov bx, [bp + 6]
    int 21H

    pop bx

    mov sp, bp
    pop bp
    retf 2
; void stdfree(void *memblock);
STDFREE:
    push bp
    mov bp, sp

    push es

    mov ah, 49H
    mov es, [bp + 6]
    int 21H

    pop es

    mov sp, bp
    pop bp
    retf 2

mylib ends

mytools segment
; char* IntToStr(word n)
INTTOSTR:
    push bp
    mov bp, sp

    push cx
    push bx
    push si

    lea si, g_szNum

    ; 把最高位转化成字符
    mov bx, [bp + 6]
    mov cl, 12
    shr bx, cl
    mov al, [si + bx]
    mov byte ptr[g_szNumBuf], al
    
    ; 把次高位转化成字符
    mov bx, [bp + 6]
    mov cl, 8
    shr bx, cl
    and bx, 0fH
    mov al, [si + bx]
    mov byte ptr[g_szNumBuf + 1], al

    ; 把低位最高位转化成字符
    mov bx, [bp + 6]
    mov cl, 4
    shr bx, cl
    and bx, 0fH
    mov al, [si + bx]
    mov byte ptr[g_szNumBuf + 2], al

    ; 把最低位转化成字符
    mov bx, [bp + 6]
    and bx, 0fH
    mov al, [si + bx]
    mov byte ptr[g_szNumBuf + 3], al

    ; 填充$符
    mov al, '$'
    mov byte ptr[g_szNumBuf + 4], al

    mov ax, si

    pop si
    pop bx
    pop cx

    mov sp, bp
    pop bp
    retf 2

; int charToInt(word char)
CHARTOINT:
    push bp
    mov bp, sp

    push bx
    push dx
    push si

    lea si, g_szNum
    xor dx, dx

    CHARTOINTSTART:
        mov bx, [bp + 6]
        mov al, bl
        mov bx, dx
        cmp al, [bx + si]
        je CHARTOINTEND
        cmp dx, 15
        je CHARTOINTEND
        inc dx
        jmp CHARTOINTSTART

    CHARTOINTEND:
    mov ax, dx

    pop si
    pop dx
    pop bx

    mov sp, bp
    pop bp
    retf 2


; int strToint(char* str)
STRTOINT:
    push bp
    mov bp, sp

    sub sp, 2

    push bx
    push cx

    ; 第一个字符
    mov bx, [bp + 6]
    mov al, byte ptr[bx]
    push ax
    call mytools:CHARTOINT
    mov cl, 12
    sal ax, cl
    mov [bp - 2], ax

    ; 第二个字符
    mov al, byte ptr[bx + 1]
    push ax
    call mytools:CHARTOINT
    mov cl, 8
    sal ax, cl
    add [bp - 2], ax

    ; 第三个字符
    mov al, byte ptr[bx + 2]
    push ax
    call mytools:CHARTOINT
    mov cl, 4
    sal ax, cl
    add [bp - 2], ax

    ; 第四个字符
    mov al, byte ptr[bx + 3]
    push ax
    call mytools:CHARTOINT
    add [bp - 2], ax

    mov ax, [bp - 2]

    pop cx
    pop bx

    add sp, 2
    mov sp, bp
    pop bp
    retf 2
; void ptintspace(word count)
PRINTSPACE:
    push bp
    mov bp, sp

    push cx
    push bx

    mov cx, [bp + 6]
    xor bx, bx
    
    PRINTSPACESTART:
    cmp cx, bx
    je PRINTSPACEEND
    inc bx
    lea ax, g_szSpace
	push ax
	call myio:PRINT
    jmp PRINTSPACESTART

    PRINTSPACEEND:

    pop bx
    pop cx

    mov sp, bp
    pop bp
    retf 2
mytools ends

concode segment
; ConNode* createConNode(Con* pcon) 创建新的节点
CREATECONNODE:
    push bp
    mov bp, sp

    sub sp, 2   ; 局部变量用于保存节点指针


    ; 申请节点空间
    mov ax, 80
    push ax
    call mylib:MALLOC
    mov [bp - 2], ax

    ; 内存拷贝把stu拷贝到申请的堆上
    mov ax, 76
    push ax
    mov ax, [bp + 6]
    push ax
    mov ax, ds
    push ds
    mov ax, [bp - 2]
    push ax
    mov ax, es
    push ax
    call mystring:MEMCPY
    mov ax, [bp - 2]

    add sp, 2
    mov sp, bp
    pop bp
    retf 2


; void InitCon() 初始化，获取哨兵节点
INITCON:
    push bp
    mov bp, sp
    sub sp, 2

    push di

    ; 申请节点空间
    mov ax, 80
    push ax
    call mylib:MALLOC
    mov [bp - 2], ax

    ; 头尾都指向哨兵节点
    mov di, ax
    mov es:[di + 76], ax
    mov es:[di + 78], ax

    mov g_ConGuard, ax

    pop di

    add sp, 2
    mov sp, bp
    pop bp
    retf

; void ConPushFront(Con* pcon) 头插法插入节点
CONPUSHFRONT:
    push bp
    mov bp, sp

    sub sp, 2

    push si
    push di

    ; 获取新节点
    mov ax, [bp + 6]
    push ax
    call concode:CREATECONNODE
    mov [bp - 2], ax

    ; 把哨兵节点的下一个节点的头节点指向新的节点
    mov di, g_ConGuard
    mov di, es:[di + 78]
    mov es:[di + 76], ax

    ; 把新节点的下一个节点指向哨兵节点的下一个节点
    mov si, [bp - 2]
    mov di, g_ConGuard
    mov ax, es:[di+ 78]
    mov es:[si + 78], ax

    ; 把新节点的前一个节点指向哨兵节点
    mov es:[si + 76], di

    ; 把哨兵节点的下一个节点指向新节点
    mov ax, [bp -2]
    mov es:[di + 78], ax

    pop di
    pop si

    add sp, 2

    mov sp, bp
    pop bp
    retf 2

; void ConEarse(ConNode* pos) 删除指定节点
CONEARSE:
    push bp
    mov bp, sp

    sub sp, 4

    push bx

    ; 保存 删除节点的前一个节点
    mov bx, [bp + 6]
    mov ax, es:[bx + 76]
    mov [bp - 2], ax

    ; 保存 删除节点的后一个节点
    mov ax, es:[bx + 78]
    mov [bp - 4], ax

    ; 前一个节点的下一个节点指向 后一个节点
    mov bx, [bp - 2]
    mov es:[bx + 78], ax

    ; 后一个节点的前节点指向 删除的前节点
    mov bx, [bp - 4]
    mov ax, [bp - 2]
    mov es:[bx+76], ax

    ; 释放节点
    mov ax, [bp + 6]
    push ax
    call mylib:FREE

    pop bx

    add sp, 4

    mov sp, bp
    pop bp
    retf 2
    
; ConNode* ConFind(word ID) 寻找指定节点
CONFIND:
    push bp
    mov bp, sp

    push cx
    push dx
    push di

    ; 指定 ID的联系人
    xor cx, cx
    mov dx, g_nStuNum

    mov di, g_ConGuard
    mov di, es:[di + 78]
    CONFINDSTART: 
        ; 寻找指定的节点
        cmp cx, [bp + 6]
        je CONFINDEND
        inc cx
        mov di, es:[di + 78]
        jmp CONFINDSTART

    CONFINDEND:
    mov ax, di

    pop di
    pop dx
    pop cx

    mov sp, bp
    pop bp
    retf 2


; void cls() ;清屏
CLS:
    push bp
    mov bp, sp

    push cx
    push dx
    push bx

    mov ah,06H
    mov al,0

    mov ch,0  ;(0,0)
    mov cl,0
    mov dh,24  ;(24,79)
    mov dl,79
    mov bh,07H ;黑底白字
    int 10H

    pop bx
    pop dx
    pop cx

    mov sp, bp
    pop bp
    retf

; void printMenu() 打印主菜单
PRINTMENU:
    push bp
    mov bp, sp

    lea ax, g_szview1
	push ax
	call myio:PRINT

    lea ax, g_szview2
	push ax
	call myio:PRINT

    lea ax, g_szview3
	push ax
	call myio:PRINT

    lea ax, g_szview4
	push ax
	call myio:PRINT

    lea ax, g_szview5
	push ax
	call myio:PRINT

    lea ax, g_szview6
	push ax
	call myio:PRINT

    lea ax, g_szview7
	push ax
	call myio:PRINT

    lea ax, g_szview8
	push ax
	call myio:PRINT

    mov sp, bp
    pop bp
    retf

; void printselmenu() 打印查询菜单
PRINTSELMENU:
    push bp
    mov bp, sp

    lea ax, g_szSelview1
	push ax
	call myio:PRINT

    lea ax, g_szSelview2
	push ax
	call myio:PRINT

    lea ax, g_szSelview3
	push ax
	call myio:PRINT

    lea ax, g_szSelview4
	push ax
	call myio:PRINT

    lea ax, g_szSelview5
	push ax
	call myio:PRINT

    lea ax, g_szSelview6
	push ax
	call myio:PRINT

    lea ax, g_szSelview7
	push ax
	call myio:PRINT

    lea ax, g_szSelview8
	push ax
	call myio:PRINT

    mov sp, bp
    pop bp
    retf

; void insertStu() 插入联系人
INSERTSTU:
    push bp
    mov bp, sp

    ; 输入联系人姓名
    lea ax, g_szInsConTip1
	push ax
	call myio:PRINT
    
    lea ax, g_Con.m_szNmae
    push ax
    call myio:SCAN

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 输入联系人手机
    lea ax, g_szInsConTip2
	push ax
	call myio:PRINT

    lea ax, g_Con.m_szPhone
    push ax
    call myio:SCAN

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 输入联系人地址
    lea ax, g_szInsConTip3
	push ax
	call myio:PRINT

    lea ax, g_Con.m_szAddr
    push ax
    call myio:SCAN

    ; 插入新的节点
    lea ax, g_Con
    push ax
    call concode:CONPUSHFRONT

    ; 联系人数加一
    inc word ptr[g_nStuNum]

    ; 保存联系人信息
    call concode:SAVECON

    mov sp, bp
    pop bp
    retf
; void deleteCon() 删除联系人
DELETECON:
    push bp
    mov bp, sp

    ; 输入联系人编号
    lea ax, g_szDelConTip1
	push ax
	call myio:PRINT
    
    lea ax, g_szNumBuf
    push ax
    call myio:SCAN

    ; 把字符转换成数字
    lea ax, g_szNumBuf
    push ax
    call mytools:STRTOINT

    ; 寻找指定节点
    push ax
    call concode:CONFIND

    ; 删除指定的节点
    push ax
    call concode:CONEARSE

    ; 人数减一
    dec g_nStuNum

    ; 保存联系人信息
    call concode:SAVECON

    mov sp, bp
    pop bp
    retf

; void updateCon() 更新联系人信息
UPDATECON:
    push bp
    mov bp, sp

    sub sp, 2

    ; 输入联系人编号
    lea ax, g_szDelConTip1
	push ax
	call myio:PRINT
    
    lea ax, g_szNumBuf
    push ax
    call myio:SCAN

    ; 把字符转换成数字
    lea ax, g_szNumBuf
    push ax
    call mytools:STRTOINT

    ; 寻找指定节点
    push ax
    call concode:CONFIND
    mov [bp - 2], ax

    ; 输入联系人姓名
    lea ax, g_szInsConTip1
	push ax
	call myio:PRINT
    
    lea ax, g_Con.m_szNmae
    push ax
    call myio:SCAN

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 输入联系人手机
    lea ax, g_szInsConTip2
	push ax
	call myio:PRINT

    lea ax, g_Con.m_szPhone
    push ax
    call myio:SCAN

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 输入联系人地址
    lea ax, g_szInsConTip3
	push ax
	call myio:PRINT

    lea ax, g_Con.m_szAddr
    push ax
    call myio:SCAN

    ; 更新联系人信息 内存拷贝把stu拷贝到申请的堆上
    mov ax, 76
    push ax
    lea ax, g_Con
    push ax
    push ds
    mov ax, [bp - 2]
    push ax
    push es
    call mystring:MEMCPY

    ; 保存联系人信息
    call concode:SAVECON

    add sp, 2

    mov sp, bp
    pop bp
    retf 

; void formatprintcon(Con* pcon) 格式化输出联系人信息
FORMATPRINTCON:
    push bp
    mov bp, sp

    sub sp, 2

    push cx

    ; 格式姓名
    mov ax, [bp + 6]
    push ax
    push es
    call mystring:STRLENS
    mov [bp - 2], ax

    mov ax, [bp + 6]    ;姓名
    push ax
    push es
    call myio:PRINTS

    mov cx, 20          ; 打印空格
    sub cx, [bp - 2]
    push cx
    call mytools:PRINTSPACE

    ; 格式电话
    mov ax, [bp + 6]
    add ax, 32
    push ax
    push es
    call mystring:STRLENS
    mov [bp - 2], ax

    mov ax, [bp + 6]    ;电话
    add ax, 32
    push ax
    push es
    call myio:PRINTS

    mov cx, 20          ; 打印空格
    sub cx, [bp - 2]
    push cx
    call mytools:PRINTSPACE
    
    ; 格式地址
    mov ax, [bp + 6]
    add ax, 44
    push ax
    push es
    call mystring:STRLENS
    mov [bp - 2], ax

    mov ax, [bp + 6]    ;电话
    add ax, 44
    push ax
    push es
    call myio:PRINTS

    ; mov cx, 32          ; 打印空格
    ; sub cx, [bp - 2]
    ; push cx
    ; call mytools:PRINTSPACE

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    pop cx

    add sp, 2

    mov sp, bp
    pop bp
    retf 2

; void searchConByName() 根据姓名查找联系人
SEARCHCONBYNAME:
    push bp
    mov bp, sp

    push cx
    push bx
    push ds
    push dx

    ; 输入联系人姓名
    lea ax, g_szInsConTip1
	push ax
	call myio:PRINT
    
    lea ax, g_Con.m_szNmae
    push ax
    call myio:SCAN

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 联系人数量
    mov cx, word ptr [g_nStuNum]
    mov bx, g_ConGuard
    mov bx, es:[bx + 78]
    xor dx, dx

    ; 循环显示所有联系人
    SEARCHCONBYNAMESTART:
        cmp cx, 0
        je SEARCHCONBYNAMEEND

        ; 子串查找
        lea ax, g_Con.m_szNmae
        push ax
        push ds
        push bx
        push es
        call mystring:STRSUB

        cmp ax, 1
        je SEARCHCONBYNAMEPRINT
        jmp SEARCHCONBYNAMENEXT

        SEARCHCONBYNAMEPRINT:
        ; 打印编号
        push dx
        call mytools:INTTOSTR
        lea ax, g_szNumBuf
        push ax
        call myio:PRINT
        mov ax, 3   ;空格
        push ax
        call mytools:PRINTSPACE

        ; 输出联系人信息
        push bx
        call concode:FORMATPRINTCON

        SEARCHCONBYNAMENEXT:
        mov bx, es:[bx + 78]
        dec cx
        inc dx
        jmp SEARCHCONBYNAMESTART

    SEARCHCONBYNAMEEND:

    pop dx
    pop ds
    pop bx
    pop cx

    mov sp, bp
    pop bp
    retf

; void searchConByPhone() 根据手机号查找联系人
SEARCHCONBYPHONE:
    push bp
    mov bp, sp

    push cx
    push bx
    push ds
    push dx

    ; 输入联系人手机
    lea ax, g_szInsConTip2
	push ax
	call myio:PRINT

    lea ax, g_Con.m_szPhone
    push ax
    call myio:SCAN

    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 联系人数量
    mov cx, word ptr [g_nStuNum]
    mov bx, g_ConGuard
    mov bx, es:[bx + 78]
    xor dx, dx

    ; 循环显示所有联系人
    SEARCHCONBYPHONESTART:
        cmp cx, 0
        je SEARCHCONBYPHONEEND

        ; 子串查找
        lea ax, g_Con.m_szPhone
        push ax
        push ds
        mov ax, bx
        add ax, 32
        push ax
        push es
        call mystring:STRSUB

        cmp ax, 1
        je SEARCHCONBYPHONEPRINT
        jmp SEARCHCONBYPHONENEXT

        SEARCHCONBYPHONEPRINT:
        ; 打印编号
        push dx
        call mytools:INTTOSTR
        lea ax, g_szNumBuf
        push ax
        call myio:PRINT
        mov ax, 3   ;空格
        push ax
        call mytools:PRINTSPACE

        ; 输出联系人信息
        push bx
        call concode:FORMATPRINTCON

        SEARCHCONBYPHONENEXT:
        mov bx, es:[bx + 78]
        dec cx
        inc dx
        jmp SEARCHCONBYPHONESTART

    SEARCHCONBYPHONEEND:

    pop dx
    pop ds
    pop bx
    pop cx

    mov sp, bp
    pop bp
    retf

; void searchConByaddres() 根据地址查找联系人
SEARCHCONBYADDRES:
    push bp
    mov bp, sp

    push cx
    push bx
    push ds
    push dx

    ; 输入联系人地址
    lea ax, g_szInsConTip3
	push ax
	call myio:PRINT

    lea ax, g_Con.m_szAddr
    push ax
    call myio:SCAN


    lea ax, g_szEnt
	push ax
	call myio:PRINT

    ; 联系人数量
    mov cx, word ptr [g_nStuNum]
    mov bx, g_ConGuard
    mov bx, es:[bx + 78]
    xor dx, dx

    ; 循环显示所有联系人
    SEARCHCONBYADDRESSTART:
        cmp cx, 0
        je SEARCHCONBYADDRESEND

        ; 子串查找
        lea ax, g_Con.m_szAddr
        push ax
        push ds
        mov ax, bx
        add ax, 44
        push ax
        push es
        call mystring:STRSUB

        cmp ax, 1
        je SEARCHCONBYADDRESPRINT
        jmp SEARCHCONBYADDRESNEXT

        SEARCHCONBYADDRESPRINT:
        ; 打印编号
        push dx
        call mytools:INTTOSTR
        lea ax, g_szNumBuf
        push ax
        call myio:PRINT
        mov ax, 3   ;空格
        push ax
        call mytools:PRINTSPACE

        ; 输出联系人信息
        push bx
        call concode:FORMATPRINTCON

        SEARCHCONBYADDRESNEXT:
        mov bx, es:[bx + 78]
        dec cx
        inc dx
        jmp SEARCHCONBYADDRESSTART

    SEARCHCONBYADDRESEND:

    pop dx
    pop ds
    pop bx
    pop cx

    mov sp, bp
    pop bp
    retf

; void showallcon() 显示所有联系人
SHOWALLCON:
    push bp
    mov bp, sp

    push cx
    push bx
    push ds
    push dx

    ; 联系人数量
    mov cx, word ptr [g_nStuNum]
    mov bx, g_ConGuard
    mov bx, es:[bx + 78]
    xor dx, dx

    ; 循环显示所有联系人
    SHOWALLCONSTART:
        cmp cx, 0
        je SHOWALLCONEND

        ; 打印编号
        push dx
        call mytools:INTTOSTR
        lea ax, g_szNumBuf
        push ax
        call myio:PRINT
        inc dx
        mov ax, 3   ;空格
        push ax
        call mytools:PRINTSPACE

        push bx
        call concode:FORMATPRINTCON
        mov bx, es:[bx + 78]
        dec cx
        jmp SHOWALLCONSTART

    SHOWALLCONEND:

    pop dx
    pop ds
    pop bx
    pop cx

    mov sp, bp
    pop bp
    retf
; void selectCon() 查询联系人
SELECTCON:
    push bp
    mov bp, sp
    SELECTWHILE:
        ; 清屏
        call concode:CLS

        ; 打印主菜单
        call concode:PRINTSELMENU

        ; 等待输入操作scan
        lea ax, g_cOpt
        push ax
        call myio:SCAN

        ; 根据操作选择
        cmp g_cOpt, '1' ; 显示所有联系人
        je OPTINSELALL

        cmp g_cOpt, '2' ; 根据姓名查询联系人
        je OPTINSELNAME

        cmp g_cOpt, '3' ; 根据手机号查询联系人
        je OPTINSELPHONE

        cmp g_cOpt, '4' ; 根据地址查询联系人
        je OPTINSELADDRES

        cmp g_cOpt, '5' ; 退出
        je SELECTCONEND
        jmp SELECTWHILE

        OPTINSELALL:
        lea ax, g_szSelConTip1
	    push ax
	    call myio:PRINT
        call concode:SHOWALLCON
        lea ax, g_cOpt
        push ax
        call myio:SCAN
        jmp SELECTWHILE

        OPTINSELNAME:
        lea ax, g_szSelConTip1
	    push ax
	    call myio:PRINT
        call concode:SEARCHCONBYNAME
        lea ax, g_cOpt
        push ax
        call myio:SCAN
        jmp SELECTWHILE

        OPTINSELPHONE:
        lea ax, g_szSelConTip1
	    push ax
	    call myio:PRINT
        call concode:SEARCHCONBYPHONE
        lea ax, g_cOpt
        push ax
        call myio:SCAN
        jmp SELECTWHILE

        OPTINSELADDRES:
        lea ax, g_szSelConTip1
	    push ax
	    call myio:PRINT
        call concode:SEARCHCONBYADDRES
        lea ax, g_cOpt
        push ax
        call myio:SCAN
        jmp SELECTWHILE

    SELECTCONEND:
	mov sp, bp
    pop bp
    retf

; void saveCon() 保存联系人信息
SAVECON:
    push bp
    mov bp, sp

    sub sp, 2

    push ds
    push cx
    push bx

    ; 打开数据库文件 w
    mov ax, 1
    push ax
    lea ax, g_szDbName
    push ax
    call myio:FOPEN
    mov [bp - 2], ax

    mov cx, word ptr [g_nStuNum]
    mov bx, g_ConGuard
    mov bx, es:[bx + 78]

    mov ax, es
    mov ds, ax

    ; 循环写入数据
    SAVECONSTART:
        cmp cx, 0
        je SAVECONEND
        mov ax, [bp - 2]
        push ax
        mov ax, 76
        push ax
        push bx
        call myio:FWRITE
        mov bx, es:[bx + 78]
        dec cx
        jmp SAVECONSTART

    SAVECONEND:
    ; 关闭文件
    mov ax, [bp - 2]
    push ax
    call myio:FCLOSE

    pop bx
    pop cx
    pop ds

    add sp, 2

    mov sp, bp
    pop bp
    retf

; void loadCon() 加载联系人信息
LOADCON:
    push bp
    mov bp, sp

    sub sp, 2

    ; 打开数据库文件 rw
    mov ax, 2
    push ax
    lea ax, g_szDbName
    push ax
    call myio:FOPEN
    mov [bp - 2], ax

    ; size_t fread( void *buffer, size_t count, FILE *stream );
    LOADCONSTART:
        mov ax, [bp - 2]
        push ax
        mov ax, 76
        push ax
        lea ax, g_Con
        push ax
        call myio:FREAD
        cmp ax, 0
        je LOADCONEND

        ; 插入新的节点
        lea ax, g_Con
        push ax
        call concode:CONPUSHFRONT
        inc word ptr[g_nStuNum]
        jmp LOADCONSTART
        

    LOADCONEND:
    ; 关闭文件
    mov ax, [bp - 2]
    push ax
    call myio:FCLOSE

    add sp, 2

    mov sp, bp
    pop bp
    retf

concode ends

mydata segment
    g_szview1 db "----------------Contact Management System----------------", 0dH, 0aH, '$'
    g_szview2 db "|              Press the number to operate              |", 0dH, 0aH, '$'
    g_szview3 db "|                   1 Insert Contacts                   |", 0dH, 0aH, '$'
    g_szview4 db "|                   2 Delete Contacts                   |", 0dH, 0aH, '$'
    g_szview5 db "|                   3 Update Contacts                   |", 0dH, 0aH, '$'
    g_szview6 db "|                   4 Select Contacts                   |", 0dH, 0aH, '$'
    g_szview7 db "|                   5 Exit the system                   |", 0dH, 0aH, '$'
    g_szview8 db "---------------------------------------------------------", 0dH, 0aH, '$'

    g_szSelview1 db "----------------------Select Contact---------------------", 0dH, 0aH, '$'
    g_szSelview2 db "|              Press the number to operate              |", 0dH, 0aH, '$'
    g_szSelview3 db "|                1 Show all contacts                    |", 0dH, 0aH, '$'
    g_szSelview4 db "|                2 Search contacts by name              |", 0dH, 0aH, '$'
    g_szSelview5 db "|                3 Search contacts by phone             |", 0dH, 0aH, '$'
    g_szSelview6 db "|                4 Search contacts by address           |", 0dH, 0aH, '$'
    g_szSelview7 db "|                5 Exit the select                      |", 0dH, 0aH, '$'
    g_szSelview8 db "---------------------------------------------------------", 0dH, 0aH, '$'


    g_szInsConTip1 db "Please enter the contact name:", 0dH, 0AH, '$'
    g_szInsConTip2 db "Please enter the contact phone:", 0dH, 0AH, '$'
    g_szInsConTip3 db "Please enter the contact address:", 0dH, 0AH, '$'

    g_szDelConTip1 db "Please enter the deleted ID:", 0dH, 0AH, '$'

    g_szUpdConTip1 db "Please enter the update ID:", 0dH, 0AH, '$'

    g_szSelConTip1 db "Number Name                Phone               Address", 0dH, 0AH, '$'
    
    g_szEnt db 0dH, 0aH, '$'
    g_szSpace db " ", '$'

    g_szNum db "0123456789ABCDEF"

    g_szAge db 3 dup(0)

    g_szDbName db "cons.db", 0,

    g_cOpt      db 0, 0, 0, 0
    g_nStuNum  dw 0

    g_szNumBuf db 25 dup(0)
    
    ; 联系人缓冲区，用于接收用户输入
    g_Con Con <"xiaoming$", "11254515$", "18xcccc$">

    ; 联系人链表哨兵节点指针，记录链表
    g_ConGuard dw 0

    g_Testsrc db "123456789$"
    g_Testsub db "xiao$"

mydata ends

mycode segment
; main
START:
	mov ax, mydata
	mov ds, ax

    mov ax, myheap
    mov es, ax

    ; 初始化哨兵节点
    call concode:INITCON

    ; 加载数据
    call concode:LOADCON

    MYWHILE:
        ; 清屏
        call concode:CLS

        ; 打印主菜单
        call concode:PRINTMENU

        ; 等待输入操作scan
        lea ax, g_cOpt
        push ax
        call myio:SCAN

        ; 根据操作选择
        cmp g_cOpt, '1' ; 插入联系人信息
        je OPTINSERT

        cmp g_cOpt, '2' ; 删除联系人信息
        je OPTDELETE

        cmp g_cOpt, '3' ; 更新联系人信息
        je OPTUPDATE

        cmp g_cOpt, '4' ; 查询联系人信息
        je OPTSELECT

        cmp g_cOpt, '5' ; 退出
        je STARTEND
        jmp MYWHILE

        OPTINSERT:
        call concode:INSERTSTU
        jmp MYWHILE

        OPTDELETE:
        call concode:DELETECON
        jmp MYWHILE

        OPTUPDATE:
        call concode:UPDATECON
        jmp MYWHILE

        OPTSELECT:
        call concode:SELECTCON
        jmp MYWHILE

    STARTEND:
	mov ax, 4c00H
	int 21H

mycode ends
end START
