extern free
extern malloc
extern printf
extern strlen

extern calloc

section .rodata
porciento_ese: db "%s", 0

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; El tipo de los `texto_cualquiera_t` que son cadenas de caracteres clásicas.
TEXTO_LITERAL       EQU 0
; El tipo de los `texto_cualquiera_t` que son concatenaciones de textos.
TEXTO_CONCATENACION EQU 1

; Un texto que puede estar compuesto de múltiples partes. Dependiendo del
; campo `tipo` debe ser interpretado como un `texto_literal_t` o un
; `texto_concatenacion_t`.
;
; Campos:
;   - tipo:    El tipo de `texto_cualquiera_t` en cuestión (literal o
;              concatenación).
;   - usos:    Cantidad de instancias de `texto_cualquiera_t` que están usando
;              a este texto.
;   - tamanio: El tamaño del texto.
;
; Struct en C:
;   ```c
;   typedef struct {
;   	uint32_t tipo;
;   	uint32_t usos;
;   	uint64_t tamanio;
;   } texto_cualquiera_t;
;   ```
TEXTO_CUALQUIERA_OFFSET_TIPO    EQU 0
TEXTO_CUALQUIERA_OFFSET_USOS    EQU 4
TEXTO_CUALQUIERA_OFFSET_TAMANIO EQU 8
TEXTO_CUALQUIERA_SIZE           EQU 16

; Un texto que tiene una única parte la cual es una cadena de caracteres
; clásica.
;
; Campos:
;   - tipo:      El tipo del texto. Siempre `TEXTO_LITERAL`.
;   - usos:      Cantidad de instancias de `texto_cualquiera_t` que están
;                usando a este texto.
;   - tamanio:   El tamaño del texto.
;   - contenido: El texto en cuestión como un array de caracteres.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       uint64_t tamanio;
;       const char* contenido;
;   } texto_literal_t;
;   ```
TEXTO_LITERAL_OFFSET_TIPO      EQU 0
TEXTO_LITERAL_OFFSET_USOS      EQU 4
TEXTO_LITERAL_OFFSET_TAMANIO   EQU 8
TEXTO_LITERAL_OFFSET_CONTENIDO EQU 16
TEXTO_LITERAL_SIZE             EQU 24

; Un texto que es el resultado de concatenar otros dos `texto_cualquiera_t`.
;
; Campos:
;   - tipo:      El tipo del texto. Siempre `TEXTO_CONCATENACION`.
;   - usos:      Cantidad de instancias de `texto_cualquiera_t` que están
;                usando a este texto.
;   - tamanio:   El tamaño del texto.
;   - izquierda: El sub-texto con el que empieza este texto.
;   - derecha:   El sub-texto con el que termina este texto.
;
; Struct en C:
;   ```c
;   typedef struct {
;   	uint32_t tipo;
;   	uint32_t usos;
;   	uint64_t tamanio;
;   	texto_cualquiera_t* izquierda;
;   	texto_cualquiera_t* derecha;
;   } texto_concatenacion_t;
;   ```
TEXTO_CONCATENACION_OFFSET_TIPO      EQU 0
TEXTO_CONCATENACION_OFFSET_USOS      EQU 4
TEXTO_CONCATENACION_OFFSET_TAMANIO   EQU 8
TEXTO_CONCATENACION_OFFSET_IZQUIERDA EQU 16
TEXTO_CONCATENACION_OFFSET_DERECHA   EQU 24
TEXTO_CONCATENACION_SIZE             EQU 32

; Muestra un `texto_cualquiera_t` en la pantalla.
;
; Parámetros:
;   - texto: El texto a imprimir.
global texto_imprimir
texto_imprimir:
	; Armo stackframe
	push rbp
	mov rbp, rsp

	; Guardo rdi
	sub rsp, 16
	mov [rbp - 8], rdi

	; Este texto: ¿Literal o concatenacion?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	je .literal
.concatenacion:
	; texto_imprimir(texto->izquierda)
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	call texto_imprimir

	; texto_imprimir(texto->derecha)
	mov rdi, [rbp - 8]
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_DERECHA]
	call texto_imprimir

	; Terminamos
	jmp .fin

.literal:
	; printf("%s", texto->contenido)
	mov rsi, [rdi + TEXTO_LITERAL_OFFSET_CONTENIDO]
	mov rdi, porciento_ese
	mov al, 0
	call printf

.fin:
	; Desarmo stackframe
	mov rsp, rbp
	pop rbp
	ret

; Libera un `texto_cualquiera_t` pasado por parámetro. Esto hace que toda la
; memoria usada por ese texto (y las partes que lo componen) sean devueltas al
; sistema operativo.
;
; Si una cadena está siendo usada por otra entonces ésta no se puede liberar.
; `texto_liberar` notifica al usuario de esto devolviendo `false`. Es decir:
; `texto_liberar` devuelve un booleando que representa si la acción pudo
; llevarse a cabo o no.
;
; Parámetros:
;   - texto: El texto a liberar.
global texto_liberar
texto_liberar:
	; Armo stackframe
	push rbp
	mov rbp, rsp

	; Guardo rdi
	sub rsp, 16
	mov [rbp - 8], rdi

	; ¿Nos usa alguien?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS], 0
	; Si la rta es sí no podemos liberar memoria aún
	jne .fin_sin_liberar

	; Este texto: ¿Es concatenacion?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	; Si no es concatenación podemos liberarlo directamente
	je .fin
.concatenacion:
	; texto->izquierda->usos--
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	dec DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS]
	; texto_liberar(texto->izquierda)
	call texto_liberar

	; texto->derecha->usos--
	mov rdi, [rbp - 8]
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_DERECHA]
	dec DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS]
	; texto_liberar(texto->derecha)
	call texto_liberar

	; Terminamos
	jmp .fin

.fin:
	; Liberamos el texto que nos pasaron por parámetro
	mov rdi, [rbp - 8]
	call free

.fin_sin_liberar:
	; Desarmo stackframe
	mov rsp, rbp
	pop rbp
	ret

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_literal
;   - texto_concatenar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Crea un `texto_literal_t` que representa la cadena pasada por parámetro.
;
; Debe calcular la longitud de esa cadena.
;
; El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
;
; Parámetros:
;   - texto: El texto que debería ser representado por el literal a crear.
global texto_literal
texto_literal:
	; rdi const char* texto

	push rbp 
	mov rbp, rsp
	push r15
	push r14
	push r13
	mov r15 , rdi
	
	xor rdi, rdi
	mov rdi, TEXTO_LITERAL_SIZE
	call malloc

	xor r8,r8
	mov r8d , TEXTO_LITERAL

	mov dword [rax + TEXTO_LITERAL_OFFSET_TIPO] , r8d

	xor r8,r8
	mov dword [rax + TEXTO_LITERAL_OFFSET_USOS] , r8d

	xor r9,r9 ; uso r9 de contador

	.loop:
		cmp byte [r15+r9] , 0
		je .end
		
		inc r9
		jmp .loop
	.end:
	mov qword [rax+ TEXTO_LITERAL_OFFSET_TAMANIO] , r9

	mov [rax + TEXTO_LITERAL_OFFSET_CONTENIDO ] , r15
	
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

; Crea un `texto_concatenacion_t` que representa la concatenación de ambos
; parámetros.
;
; Los textos `izquierda` y `derecha` serán usadas por el resultado, por lo que
; sus contadores de usos incrementarán.
;
; Parámetros:
;   - izquierda: El texto que debería ir a la izquierda.
;   - derecha:   El texto que debería ir a la derecha.
global texto_concatenar
texto_concatenar:
	; rdi texto_cualquiera_t* izquierda
	; rsi texto_cualquiera_t* derecha

	push rbp 
	mov rbp, rsp
	push r15
	push r14
	push r13
	mov r15 , rdi
	mov r14 , rsi
	
	xor rdi, rdi
	mov rdi, TEXTO_CONCATENACION_SIZE
	call malloc

	xor r8,r8
	mov r8d , TEXTO_CONCATENACION
	mov dword [rax + TEXTO_CONCATENACION_OFFSET_TIPO] , r8d
	xor r8,r8
	mov dword [rax + TEXTO_CONCATENACION_OFFSET_USOS] , r8d

	mov [rax + TEXTO_CONCATENACION_OFFSET_IZQUIERDA] ,r15
	mov [rax + TEXTO_CONCATENACION_OFFSET_DERECHA] , r14

	xor r8,r8
	mov r8 , qword [r15 + TEXTO_CUALQUIERA_OFFSET_TAMANIO]

	xor r9,r9
	mov r9 , qword [r14 + TEXTO_CUALQUIERA_OFFSET_TAMANIO]

	add r8, r9
	mov [rax + TEXTO_CONCATENACION_OFFSET_TAMANIO] , r8

	;inc cantidad de usos
	inc dword[r15+TEXTO_CUALQUIERA_OFFSET_USOS]
	inc dword[r14+TEXTO_CUALQUIERA_OFFSET_USOS]
	
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_calcular_tamanios
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Calcula el tamaño total de un `texto_cualquiera_t` y todos sus nodos
; internos. Actualiza el campo `tamanio` del texto pasado como parámetro.
;
; Parámetros:
;   - texto: El texto en cuestión.
global texto_calcular_tamanios
texto_calcular_tamanios:

	;rdi : texto_cualquiera_t* texto

	push rbp 
	mov rbp, rsp
	push r15
	push r14
	push r13

	mov r15, rdi

	xor r8,r8
	mov r8d, dword [r15+TEXTO_CUALQUIERA_OFFSET_TIPO]
	cmp r8d , TEXTO_LITERAL
	je .casoLiteral
	jne .casoConcatenacion

	.casoLiteral:
	mov rdi , [r15+TEXTO_LITERAL_OFFSET_CONTENIDO]
	call strlen
	mov qword [r15+TEXTO_CUALQUIERA_OFFSET_TAMANIO] , rax
	jmp .end

	.casoConcatenacion:
	mov rdi , [r15+TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	call texto_calcular_tamanios
	mov rdi , [r15+TEXTO_CONCATENACION_OFFSET_DERECHA]
	call texto_calcular_tamanios
	xor r8,r8
	mov r8 , qword [r15 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	mov r8 , qword [r8 + TEXTO_CUALQUIERA_OFFSET_TAMANIO]

	xor r9,r9
	mov r9 , qword [r15 + TEXTO_CONCATENACION_OFFSET_DERECHA]
	mov r9 , qword [r9 + TEXTO_CUALQUIERA_OFFSET_TAMANIO]

	add r8, r9
	mov [r15 + TEXTO_CONCATENACION_OFFSET_TAMANIO] , r8
	jmp .end

	.end:
	pop r13
	pop r14
	pop r15
	pop rbp
	ret


; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_chequear_tamanio
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Chequea si los tamaños de todos los nodos internos al parámetro corresponden
; al tamaño del texto representado.
;
; Es decir: si los campos `tamanio` están bien calculados.
;
; Parámetros:
;   - texto: El texto a verificar.
global texto_chequear_tamanio
texto_chequear_tamanio:
	;rdi : texto_cualquiera_t* texto

	push rbp 
	mov rbp, rsp
	push r15
	push r14
	push r13

	mov r15, rdi

	xor r8,r8
	mov r8d, dword [r15+TEXTO_CUALQUIERA_OFFSET_TIPO]
	cmp r8d , TEXTO_LITERAL
	je .casoLiteral
	jne .casoConcatenacion

	.casoLiteral:
	mov rdi , [r15+TEXTO_LITERAL_OFFSET_CONTENIDO]
	call strlen
	cmp [r15+TEXTO_CUALQUIERA_OFFSET_TAMANIO] , rax
	je .devolverVerdadero
	jne .devolverFalso

	.casoConcatenacion:
	xor r8,r8
	mov r8, [r15+TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	mov r8, [r8+TEXTO_CUALQUIERA_OFFSET_TAMANIO]

	xor r9,r9
	mov r9, [r15+TEXTO_CONCATENACION_OFFSET_DERECHA]
	mov r9, [r9+TEXTO_CUALQUIERA_OFFSET_TAMANIO]

	add r8,r9
	cmp [r15+TEXTO_CUALQUIERA_OFFSET_TAMANIO] , r8
	jne .devolverFalso

	mov rdi , [r15+TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	call texto_chequear_tamanio
	cmp rax , 1
	jne .devolverFalso

	mov rdi , [r15+TEXTO_CONCATENACION_OFFSET_DERECHA]
	call texto_chequear_tamanio
	cmp rax , 1
	je .devolverVerdadero
	jne .devolverFalso




	.devolverVerdadero:
	xor rax , rax
	mov rax , 1
	jmp .end

	.devolverFalso:
	xor rax , rax
	jmp .end


	.end:
	pop r13
	pop r14
	pop r15
	pop rbp
	ret
