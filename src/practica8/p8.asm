%include "../../lib/pc_canon.inc"

section .data
    bskey equ 0x7F
    lencadena equ 255
    ln equ 0x0A
    msg1 db ln,'Captura: ', 0
    msg2 db ln,'Minusculas: ', 0
    msg3 db ln,'Mayusculas: ', 0

section .bss 
    char_tmp resb 1            ; Variable temporal para almacenar el byte leído
    cadena resb lencadena

section .text 
    global _start

_start:
   mov edx, msg1
   call puts
   mov edx, cadena
   mov ax, lencadena
   call captura
    
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

        mov al, ln
        call putchar

        mov eax, 1            ; Llamada sys_exit
	    xor ebx, ebx          ; return 0
        int 0x80              ; Fin de programa

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
    call _limpiar_buffer
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
    mov ecx, edx
    xor edx, edx
    .calcular_longitud:
        cmp byte [ecx + edx], 0
        je .imprimir
        inc edx
        jmp .calcular_longitud

    .imprimir:
        mov eax, 4 ; Código para sys_write
        mov ebx, 1 ; Salida estándar
        int 0x80

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

_limpiar_buffer:
    push eax
    push ebx
    push ecx
    push edx
    ; Llamada a sys_read (syscall 3)
    .limpiar_buffer:
        mov eax, 3                 ; número de syscall para sys_read
        mov ebx, 0                 ; descriptor de archivo: 0 = stdin (entrada estándar)
        mov ecx, char_tmp          ; puntero a la memoria donde guardar el byte
        mov edx, 1                 ; leer exactamente 1 byte
        int 0x80                   ; Interrupción de Linux

        ; Comprobar si el carácter leído es un salto de línea (\n)
        mov al, [char_tmp]
        cmp al, 10                 ; 10 es el valor ASCII de '\n' (Line Feed)
        jne .limpiar_buffer         ; Si NO es '\n', sigue leyendo para vaciar el buffer
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

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