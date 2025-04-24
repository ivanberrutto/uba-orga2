extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	push rbp
	mov rbp, rsp
	jmp .check

	.next:
		inc rsi
		inc rdi
	.check:
		mov al, [rsi]
		mov cl, [rdi]
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

; char* strClone(char* a)
strClone:
	; epilogo
	push rbp
	mov rbp, rsp

	push r12
	push r13

	mov r12, rdi ; Guardo el puntero en stack
	call strLen
	mov rdi, rax ;en rdi guardo el largo para pasarselo al malloc
	inc rdi
	call malloc
	mov rsi, rax
	mov rdx, rax ; guardo el puntero en rdx pq rsi lo vamos a ir incrementando en el loop
	mov rdi, r12 ; Vuelvo a poner el puntero inicial en rdi

	.loop_clone:
		mov al, [rdi]
		cmp al, 0
		je .end_clone
		mov [rsi], al
		inc rdi
		inc rsi
		jmp .loop_clone
	.end_clone:
		mov byte [rsi], 0
		mov rax, rdx

		pop r13
		pop r12
		mov rsp, rbp
		pop rbp
		ret

; void strDelete(char* a)
strDelete:
	jmp free
	;! jmp free solamente funciona, ¿por qué? 
	;  Porque el rip ya esta escrito en el stack para que en el momento
	;  En que "free" haga "ret", vuela al caller de esta funcion

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp, rsp
	; fprintf tiene (FILE*, char*) como argumentos, los doy vuelta.

	mov rdx, rsi ;temporalmente muevo el FILE* a rdx
	mov rsi, rdi ;muevo el char* a rsi
	mov rdi, rdx ;muevo el FILE* a rdi para que se posicione bien
	call fprintf

	mov rsp, rbp
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp

	xor r8,r8
	.loop_len:
		mov al, [rdi]
		cmp al, 0
		je .end_len
		inc rdi
		inc r8
		jmp .loop_len
	.end_len:
		mov rax, r8

		mov rsp, rbp 
		pop rbp
		ret

