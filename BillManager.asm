data segment
    year db 0
    month db 0
    day db 0 
    value dw 0
    error db "Greska$" 
    stringPrint1 db "Na den $"
    stringPrint2 db " maksimalnata suma e $"  
    komanda db 21 dup(?)     
    max dw 0 
    startPosition db 68d   
    endPosition dw 68d
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
        mov bx, 0
        mov bl, startPosition            ;za da pomestime adresata na prvata data
        mov cx, 0
        ciklus: 
            mov ax, 0
            mov al, [bx]
            cmp ax, 0
            je posledno
            cmp al, day                  ;proverka dali denot od datumot e toj sto ni treba
            uslovif:  
                jne uslovelse    
                inc bx  
                inc cx
                mov al, [bx] 
                cmp al, month            ;proverka dali mesecot od datumot e toj sto ni treba
                uslovif2:
                    jne uslovelse
                    inc bx 
                    inc cx
                    mov al, [bx] 
                    cmp al, year         ;proverka dali godinata od datumot e taa sto ni treba
                    uslovif3:
                        jne uslovelse
                        inc bx  
                        mov ax, bx       ;se stava vo ax adresata na brojachot kolku smetki ima na taa data
                        jmp posledno
                      
                
            uslovelse:
                sub bx, cx                ;ako ne sum na den, primer sme se pomestile na mesec ili godina
                                          ;da se vratam na den 
                mov ax, 0    
                add bx, 3d
                mov al, [bx]           ;za da se zeme vrednosta kolku smetki treba da skokneme
                mov cx, 2
                mul cl
                add bx, ax 
                inc bx                    ;so ova se skoknuvaat smetkite i se odi na denot od slednata data
                mov cx, 0
                jmp ciklus
            
        posledno: 
        push ax
        push dx 
        ret        
    getIndex endp
    
    addBill proc
        call getIndex
        pop bx
        cmp bx, 0d
        jne write
        ;nema zapis za tekovniot datum, se dodava zapis na krajot  
        mov bx, endPosition 
        mov dl, day
        mov [bx], dl 
        inc bx
        inc endPosition 
        mov dl, month
        mov [bx], dl 
        inc bx
        inc endPosition 
        mov dl, year
        mov [bx], dl
        inc bx   
        inc endPosition         
        mov dl, 1d
        mov [bx], dl
        inc bx
        inc endPosition 
        mov dx, value
        mov [bx], dx
        add endPosition, 2d
        jmp endAdd
        
        write:
        ;ima zapis za tekovniot datum, se dodava na soodvetnoto mesto
        mov dl, [bx] 
        inc dl
        mov [bx], dl 
        mov cx, bx  
        add cx, 2d ;cx pokazuva na pozicijata kade shto treba da se stavi value
        mov bx, endPosition ;slednata pozicija na koja moze da se zapishe   
        
        shiftLoop:
        mov al, [bx-2]
        mov [bx], al ;se pomestuva za dva bajti vo levo
        dec bx
        cmp cx, bx ;dali sme stignale do pozicijata kade shto treba da se zapishe
        jne shiftLoop 
        mov ax, value
        mov [bx-1], ax
        add endPosition, 2d
          
        endAdd:  
        ret      
    addBill endp
    
    eraseBill proc 
        call getIndex
        pop bx
        cmp bx, 0d
        je endFunc 
        ;ima zapis za toj datum, se brishe soodvetniot
        mov dl, [bx]
        cmp dl, 1d
        je izbrishiZapis
        ;se brishe vrednosta, a ostanatite se pomestuvaat 
        mov cl, 0d 
        push bx ;se dodava bx na stek za podocna da se smeni brojot na smetki (ako se izbrishe nekoja) 
        inc bx
        findValue:
        cmp dl, cl 
        je nemaVrednost ;sme gi izminale site smetki i ne e najdena smetka so taa vrednost
        inc cl
        mov ax, [bx]         
        add bx, 2d
        cmp ax, value
        jne findValue 
        sub bx, 2d
        
        shiftLoop1:
        mov al, [bx+2]
        mov [bx], al
        inc bx
        cmp bx, endPosition
        jne shiftLoop1
        dec dl
        pop bx         
        mov [bx], dl ;se namaluva brojot na smetki
        sub endPosition, 2d  
        jmp endFunc
        
        izbrishiZapis:
        ;ako ima edna vrednost se brishe celiot zapis
        sub bx, 3d  
        mov cl, dl ;vo cx go imame brojot na vrednosti za tekovniot datum
        mov ch, 0d
        mov dx, 4d ;vo dx ja imame goleminata na zapisot
        add dx, cx ;cx se dodava 2 pati zatoa shto vrednostite se so golemina od 2 bajti
        add dx, cx 
        
        shiftLoop2:  
        add bx, dx
        mov al, [bx]
        sub bx, dx
        mov [bx], al
        inc bx
        cmp bx, endPosition
        jne shiftLoop2 
        sub endPosition, dx 
        jmp endFunc
          
        nemaVrednost:
        pop bx ;zatoa shto prethodno ima push, a ne stignuva do soodvetniot pop  
          
        endFunc:
        ;nema zapis za toj datum
        ret        
    eraseBill endp
    
    maxBill proc
        pop dx  
        mov day, 0d      
        push dx
        call getMonthDaysNum
        pop cx                  ;brojot na denovi vo mesecot 
        pop dx
        mov day, 01d            ;denot na koj sme momentalno
        while:
            push cx             ;da se socuva uste kolku dena treba da se pominat
            push dx             ;da se socuva adresata da ne se izgubi
            call getIndex       ;da se zeme datumot od memorija
            pop bx              ;adresata na brojot na smetki za dadeniot den
            pop dx
            pop cx  
            cmp bx, 0           
            je zavrsetok        ;ako adresata e nula, znaci nemame zapis za toj den
            push cx             ;da se socuva do koj den sme deka kje ni treba za drugo
            mov cx, 0h
            mov cl, [bx]        ;da se socuva kolku vrednosti treba da proverime i da najdeme max 
            push dx             ;da se socuva adresata za vrakjanje deka kje go upotrebuvame dx za drugo
            mov dx, 0            
            mov max, 0          ;vo ovaa promenliva kje stoi max vrednosta  
            inc bx
            while2:
                mov ax, [bx]
                cmp max, ax
                jge skokni
                mov max, ax
                skokni: 
                add bx, 2
                loop while2 
            pop dx
            pop cx 
            cmp max, 0
            je zavrsetok
            ;printanje na max
            push cx 
            push dx
            call printMax 
            pop dx 
            pop cx           
            zavrsetok:
            inc day
            loop while
            
        izlez: 
        push dx
        ret                         
    maxBill endp   
    
    printMax proc 
        pop bx                 
        
            lea dx, stringPrint1  ;printanje na prviot del od stringot
            mov ah, 9h
            int 21h
            
            ;printanje na den
            mov ax, 0h 
            mov al, day
            mov cl, 10d
            div cl
            mov dx, ax
            add dl, 48d 
            mov ah, 02h
            int 21h 
            mov dl, dh 
            add dl, 48d
            mov ah, 02h
            int 21h
            
            mov dl, 46d
            mov ah, 02h
            int 21h
            ;printanje na mesec
            mov ax, 0h 
            mov al, month
            mov cl, 10d
            div cl
            mov dx, ax
            add dl, 48d 
            mov ah, 02h
            int 21h 
            mov dl, dh 
            add dl, 48d
            mov ah, 02h
            int 21h
            
            mov dl, 46d
            mov ah, 02h
            int 21h
                   
            ;printanje na godina  
            mov ax, 0h        
            mov al, year
            mov cl, 10d
            div cl
            mov dx, ax
            add dl, 48d 
            mov ah, 02h
            int 21h 
            mov dl, dh 
            add dl, 48d
            mov ah, 02h
            int 21h
            
            lea dx, stringPrint2  ;printanje na vtoriot del od stringot
            mov ah, 9h
            int 21h 
            
            ;printanje na max vrednost
            mov dx, 10d 
            mov cx, 0d
            delenje:
                cmp max, 0
                je printaj 
                inc cx
                mov ax, max
                push cx
                mov cx, dx
                mov dx, 0d
                div cx 
                mov max, ax
                mov ax, cx     
                pop cx
                push dx
                mov dx, ax
                jmp delenje
                
                
            printaj:
                pop dx
                add dl, 48d
                mov ah, 02h
                int 21h
                loop printaj 
                
            mov dl, 46d
            mov ah, 02h
            int 21h
            mov dl, 0dh
            mov ah, 02h
            int 21h 
            mov dl, 0ah
            mov ah, 02h
            int 21h
            
        push bx
        ret        
    printMax endp 
    
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
    
    checkCommand proc  
    ;procedurata vrakja:
    ;1 ako ima greshka
    ;2 ako komandata e ADD
    ;3 ako komandata e ERASE
    ;4 ako komandata e MAX
        pop dx
        pop si
        lodsb 
        cmp al, 'E'
        je e
        cmp al, 'A'
        je a
        cmp al, 'M'
        je m 
        jmp imaGreshka
        
        e:
        lodsb
        cmp al, 'R'
        jne imaGreshka 
        lodsb 
        cmp al, 'A'
        jne imaGreshka 
        lodsb
        cmp al, 'S'
        jne imaGreshka
        lodsb 
        cmp al, 'E'
        jne imaGreshka  
        lodsb 
        cmp al, ' '
        jne imaGreshka  
        push 3d 
        jmp okCommand
        
        a:
        lodsb 
        cmp al, 'D'
        jne imaGreshka 
        lodsb
        cmp al, 'D'
        jne imaGreshka 
        lodsb 
        cmp al, ' '
        jne imaGreshka   
        push 2d 
        jmp okCommand
        
        m: 
        lodsb 
        cmp al, 'A'
        jne imaGreshka 
        lodsb
        cmp al, 'X'
        jne imaGreshka 
        lodsb 
        cmp al, ' '
        jne imaGreshka  
        push 4d 
        jmp okCommand 
        
        okCommand:  
        push si
        push dx
        ret
                         
        imaGreshka:
        push 1d    
        push si
        push dx 
        ret
        
    checkCommand endp  
    
    parseAddErase proc 
        pop bx  
        pop si
        mov value, 0d
        mov ax, 0d 
        lodsb
        cmp al, 49d  
        jl greska
        cmp al, 57d
        jg greska
        sub al, 48d
        mov value, ax 
        mov cx, 10d
        mov dx, 0d   
        oformiBroj:
            mov ax, 0d
            lodsb
            cmp al, 62d 
            je oformiDatum
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d 
            mov dl, al
            cmp value, 6553d
            jg greska
            cmp value, 6553d
            jl ok
            cmp dl, 5d
            jg greska
            ok:
            mov ax, value 
            push dx
            mul cx  ;ovde bese cl
            mov value, ax 
            pop dx
            add value, dx
            jmp oformiBroj  
            
        oformiDatum:
            ;den  
            lodsb 
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d 
            mov cx, 10d
            mul cl
            mov day, al
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d
            add day, al
            lodsb 
            cmp al, 46d  
            jne greska
            ;mesec
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d 
            mov cx, 10d
            mul cl
            mov month, al
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d
            add month, al
            lodsb 
            cmp al, 46d  
            jne greska
            ;godina
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d 
            mov cx, 10d
            mul cl
            mov year, al
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl greska
            cmp al, 57d
            jg greska
            sub al, 48d
            add year, al
            lodsb 
            cmp al, 46d  
            jne greska     
        
        push 0 
        jmp ending
        
        greska:
        push 1
        
        ending:
        push bx
        ret
    parseAddErase endp 
    
    parseMax proc
        pop bx
        mov day, 0d 
        ;mesec
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl gresno
            cmp al, 57d
            jg gresno
            sub al, 48d 
            mov cx, 10d
            mul cl
            mov month, al
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl gresno
            cmp al, 57d
            jg gresno
            sub al, 48d
            add month, al
            lodsb 
            cmp al, 46d  
            jne gresno
            ;godina
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl gresno
            cmp al, 57d
            jg gresno
            sub al, 48d 
            mov cx, 10d
            mul cl
            mov year, al
            mov ax, 0d
            lodsb 
            cmp al, 48d  
            jl gresno
            cmp al, 57d
            jg gresno
            sub al, 48d
            add year, al
            lodsb 
            cmp al, 33d  
            jne gresno     
        
        push 0 
        jmp zavrsi
        
        gresno:
        push 1
        
        zavrsi:
        push bx
        ret
    parseMax endp
    
start:
; set segment registers:
    mov ax, data
    mov ds, ax                      
    mov es, ax 
      
    input:  
    mov cx, 0  
    lea di, komanda
    procitaj:
    mov ah, 01h
    int 21h 
    cmp al, 0Dh
    je izlezi 
    inc cx
    cmp cx, 21d  
    jg procitaj    
    stosb
    jmp procitaj 
    
    izlezi: 
    mov dl, 0ah
    mov ah, 02h
    int 21h
    cmp cx, 21d
    jg greshka
        
    prodolzi:  
    lea di, komanda
    push di
    call checkCommand  
    pop si
    pop cx ;vrednosta koja ja vraka procedurata checkCommand
    cmp cx, 1d
    je greshka 
    push si
    cmp cx, 4d ;dali komandata e max
    je callMax 
    cmp cx, 3d ;dali komandata e erase
    je callErase
      
    ;komandata e add  
    call parseAddErase
    pop cx ;vrednosta koja ja vraka procedurata parseAddErase
    cmp cx, 1d
    je greshka 
    call checkDate
    pop cx ;vrednosta koja ja vraka procedurata checkDate
    cmp cx, 0d
    je greshka
    call addBill
    jmp input 
    
    ;komandata e erase  
    callErase:  
    call parseAddErase
    pop cx ;vrednosta koja ja vraka procedurata parseAddErase
    cmp cx, 1d
    je greshka 
    pop cx ;vrednosta koja ja vraka procedurata checkDate
    cmp cx, 0d
    je greshka
    call eraseBill
    jmp input
      
    ;komandata e max  
    callMax: 
    call parseMax 
    pop cx ;vrednosta koja ja vraka procedurata parseMax
    cmp cx, 1d
    je greshka 
    pop cx ;vrednosta koja ja vraka procedurata checkDate
    cmp cx, 0d
    je greshka
    call maxBill
    jmp input
            
    greshka: 
    mov ah, 9
    lea dx, error
    int 21h 
    mov dl, 0dh
    mov ah, 02h
    int 21h 
    mov dl, 0ah
    mov ah, 02h
    int 21h 
    
    ;isprazni ja komandata
    mov cx, 21d
    lea di, komanda
    isprazni:
        mov al, 0d
        stosb
        loop isprazni
        
    jmp input
              
;exit to operating system    
    mov ax, 4c00h
    int 21h    
ends

end start ; set entry point and stop the assembler.
