%include "../../lib/pc_canon.inc"

section .data
    lencadena equ 255
    ln equ 0x0A
    msg db ln, "Captura: ", 0 
    msg_getch db 0
    msg_getche db 0

section .bss 

section .text 
    global _start

_start:
    mov edx, msg
    call puts
    call getch
    push eax
    mov al, ln
    call putchar
    pop eax
    call putchar
    
    xor ebx, ebx
    mov eax, 1
    int 0x80

getch:
    push ebx
    push ecx
    push edx
    push eax
    call canonical_off ; Desactivar visualización en pantalla
    mov eax, 3 ; Código para leer datos
    mov ebx, 0 ; Dirección del teclado
    mov ecx, esp ; Asignar a ecx la dirección de eax ubicada en la pila
    mov edx, 1 ; Cantidad de carácteres a capturar
    int 0x80 ; Interrupción del sistema
    call canonical_on ; Habilitar visualización en pantalla
    pop eax
    pop edx
    pop ecx
    pop ebx
    ret

getche:
    push ebx
    push ecx
    push edx
    push eax
    mov eax, 3 ; Código para leer datos
    mov ebx, 0 ; Dirección del teclado
    mov ecx, esp ; Asignar a ecx la dirección de eax ubicada en la pila
    mov edx, 1 ; Cantidad de carácteres a capturar
    int 0x80 ; Interrupción del sistema
    pop eax
    pop edx
    pop ecx
    pop ebx
    ret

puts:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4 ; Código para sys_write
    mov ebx, 1 ; Dirección de la pantalla
    mov ecx, edx ; edx contiene la dirección de la cadena
    mov edx, 255 ; Mostrar máximo 255 bytes o 255 carácteres
    .imprimir:
        cmp byte [ecx], 0
        jz .fin_puts
        int 0x80
        inc ecx
        jmp .imprimir

    .fin_puts:
        pop edx
        pop ecx
        pop ebx
        pop eax
        ret

putchar: 
    push ebx
    push ecx
    push edx
    push eax
    mov eax, 4 ; Código sys_write
    mov ebx, 1
    mov ecx, esp
    mov edx, 1
    int 0x80
    pop eax
    pop edx
    pop ecx
    pop ebx
    ret
