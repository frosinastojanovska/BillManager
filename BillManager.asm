data segment
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    
;exit to operating system    
    mov ax, 4c00h
    int 21h    
ends

end start ; set entry point and stop the assembler.
