data segment
    year db 0
    month db 0
    day db 0 
    value dw 0
    error db "Greska$" 
    address dw 0
    startPosition db 15d  
ends

stack segment
    dw   128  dup(0)
ends

code segment
    checkDate proc
        
    checkDate endp
    
    getIndex proc
        pop dx
        push 0
        push dx 
        ret        
    getIndex endp
    
    addBill proc
         
    addBill endp
    
    eraseBill proc 
        
    eraseBill endp
    
    maxBill proc  
              
    maxBill endp
    getMonthDaysNum proc
        pop dx
        if:                     ;za mesec fevruari
            cmp month, 2d       ;dali mesecot e fevruari
            jne elseIf1  
            mov ax, 0
            mov al, year
            and al, 011b
            cmp al, 0           ;ostatokot e nula
            jne else1
            mov cx, 28d         ;ako godinata ne e prestapna
            jmp kraj
            else1:
            mov cx, 29d         ;ako godinata e prestapna
            jmp kraj
        elseIf1:                ;za meseci pomali od 8
            cmp month, 2d       ;dali mesecot e pomal od 8
            jge else
            mov ax, 0
            mov al, month
            and al, 01b
            cmp al, 0           ;ostatokot e nula
            jne else2
            mov cx, 30d         ;ako mesecot e pomal od 8 i deliv so 2 ima 30 dena
            jmp kraj
            else2:
            mov cx, 31d         ;ako mesecot e pomal od 8 i ne e deliv so 2 ima 31 den
            jmp kraj
        else:                   ;za meseci pogolemi/ednakvi od 8
            mov ax, 0
            mov al, month
            and al, 01b
            cmp al, 0           ;ostatokot e nula
            jne else3
            mov cx, 31d         ;ako mesecot e pogolem/ednakov od 8 i deliv so 2 ima 31 den
            jmp kraj
            else3:
            mov cx, 30d         ;ako mesecot e pogolem/ednakov od 8 i ne e deliv so 2 ima 30 dena
            jmp kraj
        kraj:
        push cx
        push dx
        ret        
    getMonthDaysNum endp
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ;vlez izlez kod tuka 
    
;exit to operating system    
    mov ax, 4c00h
    int 21h    
ends

end start ; set entry point and stop the assembler.
