section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free

ORDERING_TABLE_TABLE_SIZE_OFFSET EQU 0

ORDERING_TABLE_TABLE_OFFSET EQU 8

ORDERING_TABLE_SIZE EQU 16

NODO_OT_SIZE EQU 16

NODO_DISPLAY_LIST_PRIMITIVA_OFFSET EQU 0
NODO_DISPLAY_LIST_X_OFFSET EQU 8
NODO_DISPLAY_LIST_Y_OFFSET EQU 9
NODO_DISPLAY_LIST_Z_OFFSET EQU 10
NODO_DISPLAY_LIST_SIGUIENTE_OFFSET EQU 16
NODO_DISPLAY_LIST_SIZE EQU 24

;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
inicializar_OT_asm:
    ; dil uint8_t table size

	push rbp 
	mov rbp, rsp
	push r15
    push r14
    push r13

    xor r15,r15
    mov r15b , dil

    xor rdi , rdi
    mov rdi, ORDERING_TABLE_SIZE
    call malloc

    mov byte [rax + ORDERING_TABLE_TABLE_SIZE_OFFSET] , r15b

    cmp r15b ,0
    je .end
    imul r15 , NODO_OT_SIZE
    mov rdi, r15

    mov r14, rax

    call malloc

    mov [r14 + ORDERING_TABLE_TABLE_OFFSET] , rax

    mov rax , r14
    .end:


    pop r13
    pop r14
	pop r15
	pop rbp
	ret



; void* calcular_z(nodo_display_list_t* display_list) ;
calcular_z_asm:
    ; rdi nodo_display_list_t*
    ; sil z_size

	push rbp 
	mov rbp, rsp
	push r15
    push r14
    push r13

    mov r15 , rdi
    xor r14,r14
    mov r14, rsi

    xor rdi, rdi
    xor rsi, rsi 
    xor rdx , rdx 

    mov dil , byte [r15 + NODO_DISPLAY_LIST_X_OFFSET]
    mov sil , byte [r15 + NODO_DISPLAY_LIST_Y_OFFSET]
    mov dl , r14b

    xor r8,r8
    mov r8 , [r15 + NODO_DISPLAY_LIST_PRIMITIVA_OFFSET]
    call r8
    mov byte [r15+ NODO_DISPLAY_LIST_Z_OFFSET] , al

    .end:


    pop r13
    pop r14
	pop r15
	pop rbp
	ret
; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
ordenar_display_list_asm:

