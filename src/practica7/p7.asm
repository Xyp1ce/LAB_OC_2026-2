%include "../../lib/pc_io.inc"

section .data
    lencadena equ 255
    ln equ 0x0A
    bskey equ 0x7F
    longitud db 0
    msg db ln, 'Captura: ', 0
    debug_cadena db ln, 'Cadena: ', 0
    debug_base db ln, 'Base: ', 0
    debug_numero db ln, 'Numero: ', 0

section .bss
    cadena resb lencadena
    base resb 1
    numero resb 1
    entero resb 1

section .text
    global _start

_start: 
    ; edx = cadena = inicio de la cadena 
    ; ebx = numero = número entero sobre el cual operar 
    ; esi = base = base máxima del arreglo 

    call _ATOI

    ; Finalización del programa
    xor ebx, ebx
    mov eax, 1
    int 0x80

_ATOI: ; Array TO Integer
    push edx
    push esi
    push ebx

    mov edx, cadena
    mov esi, base

    call _Caputar_Cadena
    call _Encontrar_Base
    call _Comparar_numeros

    mov edx, debug_cadena
    call puts
    mov edx, cadena
    call puts
    mov edx, debug_base
    call puts
    mov al, [base]
    call _Mostrar_byte
    mov edx, debug_numero
    call puts
    mov al, [numero]
    call _Mostrar_byte
    mov al, ln
    call putchar

    pop ebx
    pop esi
    pop edx
    ret 

_Potencia:
    push ebx 
    push esi

    cmp esi

    pop esi
    pop ebx
    ret

_Encontrar_Base: 
    ; edx = cadena, contiene la cadena 
    ; esi = base, contendrá la base total: 1, 2, 3, 4, etc. 
    ;                      unidad, decena, centena, millar, etc.
    push esi
    push edx
    mov byte [esi], 0

    .recorrer_cadena:
        cmp byte [edx], 0
        je .finalizar_base
        cmp byte [edx], '0'
        jb .sigiuente_caracter
        cmp byte [edx], '9'
        ja .sigiuente_caracter

    .contar_numeros:
        cmp byte [edx], 0
        je .finalizar_cuenta
        cmp byte [edx], '0'
        jb .finalizar_cuenta
        cmp byte [edx], '9'
        ja .finalizar_cuenta
        inc byte [esi]

    .siguiente_caracter_cuenta:
        inc edx
        jmp .contar_numeros

    .sigiuente_caracter:
        inc edx
        jmp .recorrer_cadena

    .finalizar_cuenta:
    .finalizar_base:
        pop edx
        pop esi 
        ret

_Comparar_numeros:
    ; edx contiene la cadena
    ; El primer dígito encontrado se convierte y se guarda en numero
    push eax
    push esi
    mov esi, edx

    xor ebx, ebx

    .comparar:
        mov al, byte [esi]
        cmp al, 0
        je .fin
        cmp al, '0'
        jb .no_es_digito
        cmp al, '9'
        ja .no_es_digito
        sub al, '0'
        movzx ebx, al
        jmp .fin

    .no_es_digito:
        inc esi
        jmp .comparar

    .fin:
        mov [numero], bl
        pop esi
        pop eax
        ret

_ITOA: ; Integer TO Array

    ret

_Caputar_Cadena:
    mov edx, msg 
    call puts
    mov edx, cadena
    mov ax, lencadena

    push ecx
    push esi
    push edi
    push edx
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
        pop edx
        pop edi
        pop esi
        pop ecx
    ret

    _Mostrar_byte:
    push ebx
    push ecx
    push edx
    movzx eax, al
    xor ecx, ecx

    .convertir:
        xor edx, edx
        mov ebx, 10
        div ebx
        push edx
        inc ecx
        test eax, eax
        jnz .convertir

    .imprimir:
        pop eax
        add al, '0'
        push ecx
        call putchar
        pop ecx
        loop .imprimir

    pop edx
    pop ecx
    pop ebx
    ret
