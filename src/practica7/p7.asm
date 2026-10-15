%include "../../lib/pc_io.inc"

section .data
    lencadena equ 255
    ln equ 0x0A
    bskey equ 0x7F
    longitud db 0
    msg db ln, 'Caputura: ', 0

section .bss
    cadena resb lencadena
    base resb 1

section .text
    global _start

_start: 
    call _Caputar_Cadena

    ; Finalización del programa
    xor ebx, ebx
    mov eax, 1
    int 0x80

_ATOI: ; Array TO Integer
    push edx
    push esi

    mov edx, cadena
    mov esi, base
    call _Encontrar_Base

    pop esi
    pop edx
    ret 

_Encontrar_Base: 
    ; edx contiene la cadena 
    ; esi contendrá la base total: 1, 2, 3, 4, etc. 
    ;                      unidad, decena, centena, millar
    .recorrer_cadena:
        cmp byte [edx], 0
        je .finalizar_base
        cmp byte [edx], '0'
        jb .sigiuente_caracter
        cmp byte [edx], '9'
        ja .sigiuente_caracter

    .contar_numeros:
        cmp byte [edx], 0
        je .finalizar_base
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
    .finalizar_base;
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
