data segment
year db 0
month db 0
day db 0 
value dw 0
error db "Greska$"
startPosition db 0  
ends

stack segment
    dw   128  dup(0)
ends

code segment
    proc checkDate
        
    endp
    
    proc getIndex
        
    endp
    
    proc addBill
    endp
    
    proc eraseBill
        
    endp
    
    proc maxBill
        
    endp
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
