%include "../../lib/pc_io.inc"

section .data
    lencadena equ 255
    ln equ 0x0A
    bskey equ 0x7F
    longitud db 0
    msg db ln, 'Captura: ', 0
    debug_cadena db ln, 'Cadena: ', 0
    debug_direccion_actualizada db ln, 'Nueva cadena: ', 0
    debug_base db ln, 'Base: ', 0
    debug_numero db ln, 'Numero: ', 0
    debug_signo db ln, 'Signo: ', 0
    debug_entero db ln, 'Entero: ', 0
    diez db 10
    negative db 0

section .bss
    cadena resb lencadena
    dir_cadena_actualizada resd 1
    base resb 1
    numero resb 1
    entero resd 1
    sum_enteros resd 1

section .text
    global _start

_start: 
    ; edx = cadena = inicio de la cadena 
    ; ebx = numero = número entero sobre el cual operar 
    ; esi = base = base máxima del arreglo 

    mov edx, cadena
    mov esi, base
    mov eax, numero 
    call _ATOI

    ; Finalización del programa
    xor ebx, ebx
    mov eax, 1
    int 0x80

_ATOI: ; Array TO Integer
    mov dword [sum_enteros], 0
    push edx
    push ecx
    push ebx
    push esi

    ; estas solo se llaman una vez
    call _Caputar_Cadena
    mov byte [negative], 0
    call _Buscar_negativo
    mov edx, debug_signo
    call puts
    mov al, [negative]
    add al, '0'
    call putchar
    mov al, ln 
    call putchar

    call _Actualizar_direccion_cadena
    mov edx, [dir_cadena_actualizada]

    mov edx, debug_cadena
    call puts
    mov edx, cadena
    call puts
    mov edx, debug_direccion_actualizada
    call puts
    mov edx, [dir_cadena_actualizada]
    call puts

    mov al, byte [edx]
    cmp al, 0
    je .final

    .iterar:
        call _Encontrar_Base
        call _Comparar_numeros
        call _Calcular_entero
        mov edi, [entero]
        add [sum_enteros], edi

        mov edx, debug_base
        call puts
        movzx eax, byte [base]
        call _Mostrar_byte
        mov edx, debug_numero
        call puts
        movzx eax, byte [numero]
        call _Mostrar_byte
        mov edx, debug_entero
        call puts
        mov eax, [sum_enteros]
        call _Mostrar_byte
        mov al, ln 
        call putchar

        mov edx, [dir_cadena_actualizada]
        inc edx 
        mov [dir_cadena_actualizada], edx

        cmp byte [edx], '0'
        jb .final 
        cmp byte [edx], '9'
        ja .final 
        jmp .iterar

    .final:
        cmp byte [negative], 1
        jne .mostrar_positivo
        neg dword [sum_enteros] ; Solo lo negamos en memoria si realmente es negativo

        mov al, ln
        call putchar
        mov al, '-'
        call putchar
        mov eax, [sum_enteros]
        neg eax                 ; Lo pasamos a positivo en EAX para _Mostrar_byte
        jmp .mostrar_resultado

        .mostrar_positivo:
            mov al, ln
            call putchar
            mov eax, [sum_enteros]

        .mostrar_resultado:
            call _Mostrar_byte
        
        pop esi
        pop ebx
        pop ecx
        pop edx
        ret 

_Buscar_negativo:
    push edx
    push ecx
    mov cl, [negative]
    .buscar_negativo:
        cmp byte [edx], 0
        je .fin_negativo
        cmp byte [edx], '-'
        je .negativo
        inc edx
        jmp .buscar_negativo 

    .negativo:
        mov cl, 1

    .fin_negativo:
        mov byte [negative], cl
        pop ecx
        pop edx
        ret

_Actualizar_direccion_cadena:
    push edx
    mov edx, cadena
    .actualizar_direccion:
        cmp byte [edx], 0
        je .fin_actualizar_direccion
        cmp byte [edx], '0'
        jb .siguiente_caracter_direccion
        cmp byte [edx], '9'
        ja .siguiente_caracter_direccion
        jmp .fin_actualizar_direccion
    
    .siguiente_caracter_direccion:
        inc edx
        jmp .actualizar_direccion

    .fin_actualizar_direccion:
        mov [dir_cadena_actualizada], edx
        pop edx
        ret

_Calcular_entero:
    push eax ; contiene el número con el que trabajaremos 
             ; y contendrá el resultado de la multiplicacion
    push ecx ; contiene la base a utilizar 
    push esi ; contendrá 10 ^ base

    movzx eax, byte [numero]
    movzx ecx, byte [base]
    mov esi, 1

    ; primero calcular 10 ^ base
    .potencia: 
        test ecx, ecx
        jz .multiplicar
        imul esi, esi, 10
        loop .potencia 

    ; calcular numero x potencia 
    ; EAX = AX * SI
    .multiplicar:
        imul eax, esi
        mov [entero], eax

    pop esi
    pop ecx
    pop eax
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
        dec byte [esi]
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
