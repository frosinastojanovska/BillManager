data segment
    year db 17
    month db 1
    day db 28 
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
    ;28/29 -> February(2)
    ;30 -> April(4), June(6), September(9), November(11)
    ;31 -> January(1), March(3), May(5), July(7), August(8), October(10), December(12) 
        ;before 01.01.2000   
        cmp year, 0d
        jl endNotValid
        cmp month, 0d
        jle endNotValid
        cmp day, 0d
        jle endNotValid
        
        ;valid date
        call getMonthDaysNum 
        pop cx
        cmp day, cl  
        jg endNotValid     
        
        ;after today
        mov ah, 2ah
        int 21h   
        mov bl, year
        mov bh, 0d
        add bx, 2000
        cmp bx, cx
        jl endValid ;godinata e pred tekovnata
        jg endNotValid ;godinata e posle tekovnata   
        cmp month, dh ;ako e ista godinata, se sporeduva mesecot
        jl endValid ;mesecot e pred tekovniot
        jg endNotValid ;mesecot e posle tekovniot
        cmp day, dl ;ako mesecot e ist, se sporeduva denot
        jg endNotValid ;denot e posle tekovniot
        jmp endValid ;denot e pred (ili e ednakov na) tekovniot
        
        endNotValid: 
        pop dx
        push 0 ;not valid date  
        push dx
        ret   
        
        endValid:
        pop dx
        push 1 ;valid date     
        push dx
        ret       
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
            je else1
            mov cx, 28d         ;ako godinata ne e prestapna
            jmp kraj
            else1:
            mov cx, 29d         ;ako godinata e prestapna
            jmp kraj
        elseIf1:                ;za meseci pomali od 8
            cmp month, 8d       ;dali mesecot e pomal od 8
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
