%include "../../lib/pc_io.inc"   ; incluir declaraciones de procedimiento externos

section .data
    bskey equ 0x7F
    lencadena equ 255
    ln equ 0x0A
    nline db ln,0
    msg1 db ln,'Captura: ', 0
    msg2 db ln,'Cadena: ', 0
    longitud db 0
    
section .bss

section .text
    global _start         ; referencia para inicio de programa
    
_start:   
   
    ; --- IMPRIMIR CADENA  ---
    mov edx, msg1        
    call puts   
    call captura    
    jmp .fin_programa  
    
    ; --- FIN DE PROGRAMA ---
    .fin_programa: 
        mov edx, nline    
        call puts     
        call puts     
        mov eax, 1            ; Llamada sys_exit
	    xor ebx, ebx          ; return 0
        int 0x80              ; Fin de programa

    captura:
            push ax
    .cont   call getch 
            cmp al, bskey 
            jne .nl
            call borrar 
            jmp .cont 
    .nl     cmp al, ln 
            jne .sig
            mov al, 0
            call putchar
            pop ax
            ret
    .sig:   call putchar
            jmp .cont

    borrar:
            push ax 
            mov al, [longitud]
            cmp al, 1 ; si intentamos hacer backspace al inicio de la cadena entonces nos retornamos
            jbe .fin 
            mov al,0x8
            call putchar    
            mov al,' '
            call putchar
            mov al,0x8
            call putchar   
    .fin:   pop ax
            ret 