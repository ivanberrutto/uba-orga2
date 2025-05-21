global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
extern malloc  
extern calloc
extern CantEnBlacklist

section .data 
%define SIZE_UINT32_T ??
%define OFFSET_MONTO 0
%define OFFSET_COMERCIO 8
%define OFFSET_CLIENTE 16
%define OFFSET_APROBADO 17
%define SIZE_STRUCT 24
%define UINT32_SIZE ??
%define SIZE_PUNTERO_A_PAGO ??
%define SIZE_OF_PAGO 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text


acumuladoPorCliente_asm:
	push rbp 
	mov rbp, rsp
	push r15
	push r14 
	push r13
	push r12 
	sub rsp,8
	
	mov r15 , rsi ; guardo pagos  
	mov r14 , rdi ; guardo el tamaño de pagos
	mov rdi , 10
	xor r13 , r13 ; uso de contador

	mov rsi , 4
	call calloc
	.loop:
		cmp r13, r14 
		je .end
		
		mov rdi , r15
		xor r8,r8
		mov r8b , byte [r15+OFFSET_APROBADO ]
		cmp r8b , 0
		je .next
		xor r9,r9
		;
		mov r9b , byte [r15+OFFSET_CLIENTE ]
		xor r10, r10
		mov r10b, byte [r15+OFFSET_MONTO]
		add byte [rax + r9 *4] , r10b


		.next:
		add r13, 1 
		add r15, 24
		jmp .loop

	.end:
	add rsp,8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

en_blacklist_asm:
	push rbp 
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12

	mov r12, rdi ;comercio
	mov r13 , rsi ; lista de comercios
	xor r14 , r14 
	mov r14b , dl ; tamaño 
	.loop:
		mov r10, [r13] ; puntero a string nombre de comercio

		mov rdi, r12
		mov rsi, r10
		call strcmp
		cmp rax, 1 
		je .end

		add r13, 8
		dec r14
		cmp r14 , 0
		jne .loop

	.end:


	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

blacklistComercios_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx 
	sub rsp, 8

	xor r12, r12
	xor r15, r15

	mov r12b, dil ; r12 tiene cantidad de pagos
	mov r13, rsi ; r13 tiene puntero al array de pagos
	mov r14, rdx ; r14 tiene el puntero al array de comercios
	mov r15b, cl ; r15 tiene cantidad de comercios

	xor rbx, rbx ; cantidad de pagos en comercios

	mov r8, r12 ; iterador del ciclo
	mov r9, r13 ; puntero de array de pagos para avanzar durante el ciclo
	.ciclo_contador:
		mov rdi, [r9 + OFFSET_COMERCIO]
		mov rsi, r14
		mov rdx, r15

		push r8
		push r9
		call en_blacklist_asm
		pop r9
		pop r8
		
		cmp rax , 1
		jne .siguiente_pago
		
		inc rbx
		
		.siguiente_pago:
		add r9, SIZE_OF_PAGO
		dec r8
		cmp r8, 0
		jmp .ciclo_contador
	
	shl rbx, 3 ; cantidad de pagos * 8
	mov rdi, rbx
	call malloc
	mov rbx, rax ; rbx tiene el puntero al array de larespuesta

	xor r10, r10 ; offset respecto de rbx sobre el que escribir
	xor r11, r11

	mov r8,r12
	mov r9,r13

	.ciclo:

		mov rdi, [r9+ OFFSET_COMERCIO]
		mov rsi, r14
		mov rdx, r15

		push r8
		push r9
		push r10
		sub rsp,8
		call en_blacklist_asm
		add rsp,8
		pop r10
		pop r9
		pop r8
		
		cmp rax , 1
		jne .siguiente_pago2
		
		mov rdi, SIZE_OF_PAGO
		push r8
		push r9
		push r10
		sub rsp ,8
		call malloc
		add rsp,8
		pop r10
		pop r9
		pop r8

		mov r11b, byte [r9 + OFFSET_MONTO] 
		mov byte [rax + OFFSET_MONTO], r11b

		mov r11, [r9 + OFFSET_COMERCIO] 
		mov  [rax + OFFSET_COMERCIO], r11b

		mov r11b, byte [r9 + OFFSET_CLIENTE] 
		mov byte [rax + OFFSET_CLIENTE], r11b

		mov r11b, byte [r9 + OFFSET_APROBADO] 
		mov byte [rax + OFFSET_APROBADO], r11b

		mov [rbx + r10], rax
		add r10, 8 
		
		.siguiente_pago2:

		add r9, SIZE_OF_PAGO
		dec r8
		cmp r8, 0
		jmp .ciclo


	mov rax, rbx
	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp 
	ret

strcmp:
	push rbp
	mov rbp, rsp
	jmp .check

	.next:
		inc rsi
		inc rdi
	.check:
		mov al, byte[rsi]
		mov cl, byte [rdi]
		cmp al, cl
		je .equal
		jl .lower
		jg .greater

	.equal:
		cmp al, 0
		jne .next

		mov rax, 0
		jmp .end
	.greater:
		mov rax, 1
		jmp .end
	.lower:
		mov rax, -1
		jmp .end
	.end:
		mov rsp, rbp
		pop rbp
		ret