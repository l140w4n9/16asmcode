mystack segment stack
    db 512 dup(0)
mystack ends 

mydata segment
    g_szNum db '0123456789ABCDF'
    g_szOut db 4 dup('$')
    g_szEnt db 0ah, 0dh, '$'
mydata ends 

mycode segment

MYFOO:
    push bp ; 保存bp，栈帧指针
    mov bp ,sp

    sub sp, 6   ; 申请局部变量空间

    ; 保存寄存器环境
    push cx
    push dx

    mov word ptr [bp - 4], 11H   ; 第一个局部变量空间
    mov word ptr [bp - 6], 11H   ; 第二个局部变量空间
    mov word ptr [bp - 8], 11H   ; 第二个局部变量空间

    mov ax, [bp + 2]    ; 第一个参数
    mov cx, [bp + 4]    ; 第二个参数

    add ax, cx
    mov ch, al

    mov ah, 09H
    lea dx, g_szNum
    int 21H

    mov ah, 09H
    lea dx, g_szEnt
    int 21H

    ; 恢复寄存器环境
    pop dx
    pop cx
    
    add sp, 6   ; 释放局部变量
    pop bp      ; 恢复bp
    ret 4

START:
    assume ds:mydata
    mov ax, mydata
    mov ds, ax

    mov ax, 3
    push ax
    mov ax, 5
    push ax
    call MYFOO

    mov ax, 3
    push ax
    mov ax, 2
    push ax
    call MYFOO

    mov ax, 8
    push ax
    mov ax, 5
    push ax
    call MYFOO

    mov ax, 4c00H
    int 21H

mycode ends 
end START
