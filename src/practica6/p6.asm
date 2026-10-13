%include "../../lib/pc_io.inc"   ; incluir declaraciones de procedimiento externos

section .data
    bskey equ 0x7F
    lencadena equ 255
    ln equ 0x0A
    ;nline db ln,0
    msg1 db ln,'Captura: ', 0
    msg2 db ln,'Cadena: ', 0
    longitud db 0
    
section .bss
    new_line resb 1 ; reservamos 1 byte (255 espacios de carácteres) para nuestra nueva cadena

section .text
    global _start         ; referencia para inicio de programa
    
_start:   
    mov byte [new_line], ln
    ; --- IMPRIMIR CADENA  ---
    mov edx, msg1        
    call puts   
    call captura    
    jmp .fin_programa  
    
    ; --- FIN DE PROGRAMA ---
    .fin_programa: 
        mov edx, msg2
        call puts    
        mov edx, new_line
        call puts     

        mov eax, 1            ; Llamada sys_exit
	xor ebx, ebx          ; return 0
        int 0x80              ; Fin de programa

    captura:
        push ax

    .leer_tecla:   
        call getch 
        cmp al, bskey 
        jne .cantidad_max
        call borrar 
        jmp .leer_tecla

    .cantidad_max:
        cmp byte [longitud], lencadena
        jne .enter
        mov al, 0
        call putchar
        jmp .fin_captura

    .enter:     
        cmp al, ln 
        jne .sig
        call putchar
        mov al, 0
        call putchar
        jmp .fin_captura

    .sig:   
        call putchar
        inc byte [longitud]
        jmp .leer_tecla

    .fin_captura:
        pop ax
        ret

    borrar: 
        push ax 
        cmp byte [longitud], 1
        jb .fin_borrar
        dec byte [longitud]
        mov al,0x8
        call putchar    
        mov al,' '
        call putchar
        mov al,0x8
        call putchar

    .fin_borrar:   
        pop ax
        ret 