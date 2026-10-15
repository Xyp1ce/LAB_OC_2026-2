%include "../../lib/pc_io.inc"   ; incluir declaraciones de procedimiento externos

section .data
    bskey equ 0x7F
    lencadena equ 255
    ln equ 0x0A
    msg1 db ln,'Captura: ', 0
    msg2 db ln,'Minusculas: ', 0
    msg3 db ln,'Mayusculas: ', 0
    
section .bss
    cadena resb lencadena

section .text
    global _start         ; referencia para inicio de programa
    
_start:   
    mov edx, msg1
    call puts   
    mov edx, cadena
    mov ax, lencadena
    call captura

    ;jmp .fin_programa  
    
    ; --- FIN DE PROGRAMA ---
    .fin_programa: 
        mov edx, msg2
        call puts
        mov edx, cadena
        call minusculas
        mov edx, cadena
        call puts

        mov edx, msg3
        call puts
        mov edx, cadena
        call mayusculas
        mov edx, cadena
        call puts

        mov eax, 1            ; Llamada sys_exit
	xor ebx, ebx          ; return 0
        int 0x80              ; Fin de programa

    captura:
        push ecx
        push esi
        push edi
        mov esi, edx
        mov di, ax
        cmp di, 1
        jb .fin_captura
        dec di
        xor ecx, ecx

    .leer_tecla:
        call getch
        cmp al, ln
        je .fin_linea
        cmp al, bskey
        je .borrar
        cmp cx, di
        jae .leer_tecla
        mov [esi + ecx], al
        inc ecx
        call putchar
        jmp .leer_tecla

    .borrar:
        test ecx, ecx
        jz .leer_tecla
        dec ecx
        mov byte [esi + ecx], 0
        mov al, 0x08
        call putchar
        mov al, ' '
        call putchar
        mov al, 0x08
        call putchar
        jmp .leer_tecla

    .fin_linea:
        mov byte [esi + ecx], 0
        mov al, ln
        call putchar

    .fin_captura:
        pop edi
        pop esi
        pop ecx
        ret

    mayusculas:
        push esi
        mov esi, edx

    .recorrer_mayusculas:
        cmp byte [esi], 0
        je .fin_mayusculas
        cmp byte [esi], 'a'
        jb .siguiente_mayuscula
        cmp byte [esi], 'z'
        ja .siguiente_mayuscula
        sub byte [esi], 32

    .siguiente_mayuscula:
        inc esi
        jmp .recorrer_mayusculas

    .fin_mayusculas:
        pop esi
        ret

    minusculas:
        push esi
        mov esi, edx

    .recorrer_minusculas:
        cmp byte [esi], 0
        je .fin_minusculas
        cmp byte [esi], 'A'
        jb .siguiente_minuscula
        cmp byte [esi], 'Z'
        ja .siguiente_minuscula
        add byte [esi], 32

    .siguiente_minuscula:
        inc esi
        jmp .recorrer_minusculas

    .fin_minusculas:
        pop esi
        ret