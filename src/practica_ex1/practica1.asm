; Contador de digitos 
; Este programa regresará en EAX la cantidad de digitos encontrados en una cadena
; Los digitos son aquellos caracteres entre '0' y '9'

section .data

section .bss

section .text
    global _start

_start:
    mov ebx, 119
    call _primo
    call putchar
    mov al, 0x0A
    call putchar

    mov eax, 1
    xor ebx, ebx
    int 0x80

_primo:
    push edx
    push ecx
    push esi
    cmp ebx, 1
    jle .no_es_primo
    cmp ebx, 2
    je .es_primo 
    mov eax, ebx
    mov esi, 2
    xor edx, edx
    div esi
    mov esi, eax ; salvamos el cociencte el cual es la mitad de nuestro número
    mov ecx, 2
    .buscar_primo:
        cmp ecx, esi
        jg .es_primo
        mov eax, ebx
        xor edx, edx
        div ecx
        cmp edx, 0
        je .no_es_primo
        inc ecx
        jmp .buscar_primo
    .no_es_primo:
        mov al, '0'
        jmp .fin 
    .es_primo: 
        mov al, '1'
    .fin:
        pop esi
        pop ecx
        pop edx
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