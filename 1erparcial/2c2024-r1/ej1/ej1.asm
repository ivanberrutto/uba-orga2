extern malloc
extern free
section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = mapa_t           mapa rdi EL MAPA ES 255*255
	; r/m64 = attackunit_t*    compartida rsi
	; r/m64 = uint32_t*        fun_hash(attackunit_t*) rdx
	push rbp
	mov rbp, rsp
	sub rsp , 16
	push r12
	push r13
	push r14
	push r15

	mov r12,rdi ; guardo puntero al mapa
	mov r13,rsi ; guardo eel arma
	mov r15,rdx ;la funcion hash 	
	;
	xor r14,r14 ; uso de contador

	mov rdi , r13 ; llamo la funcion para saber a que numero tengo que comparar
	;
	;
	;
	call r15 
	mov [rbp-8] , eax ; este es el hash a comparar
	
	.loop:
		cmp r14, 65025
		je .end
		mov rdi , qword [r12 + r14 * 8 ] ; voy hacia la pos del mapa actual
		cmp rdi , 0
		je .next
		
		call r15 ; llamo al hash con el valor actual
		cmp eax , dword [rbp-8] ; veo si es igual al hash que busco
		jne .next
		; voy al valor de referencias y le sumo uno
		add  byte [r13+ATTACKUNIT_REFERENCES] , 1

		mov rdi , [r12 + r14 * 8 ] ; vuelvo a la pos actual en el mapa
		sub byte [rdi+ATTACKUNIT_REFERENCES] , 1 ; le resto la referencia
		cmp  byte [rdi+ATTACKUNIT_REFERENCES] , 0 ; si es 0 tengo que liberarlo
		;je .dontFree
		;call free ; libero el puntero de lo que habia antes
		;.dontFree:
		mov [r12+r14 * 8] , r13 ; pongo en el mapa el puntero a mi attack unit 
		.next:
		add r14, 1 
		jmp .loop

	.end:
	
	pop r15
	pop r14
	pop r13
	pop r12
	add rsp,16
	pop rbp

	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; r/m64 = mapa_t           mapa
	; r/m64 = uint16_t*        fun_combustible(char*)
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = mapa_t           mapa rdi EL MAPA ES 5*5
	; r/m64 = attackunit_t*    compartida rsi
	; r/m64 = uint32_t*        fun_hash(attackunit_t*) rdx
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	mov r12,rdi ; guardo puntero al mapa
	mov r13,rsi ; guardo la funcion comparadora
	;
	xor r14,r14 ; uso de contador
	xor r15 , r15 ; el total de combustible
	
	.loop:
		cmp r14, 65025
		je .end
		mov rdi , qword [r12 + r14 * 8 ] ; voy hacia la pos del mapa actual
		cmp rdi , 0
		je .next

		add r15w, word [rdi+12]
		
		call r13
		sub r15w , ax
		

		.next:
		add r14, 1 
		jmp .loop

	.end:
	mov rax , r15	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp

	ret

global modificarUnidad
modificarUnidad:
	; r/m64 = mapa_t           mapa rdi
	; r/m8  = uint8_t          x rsi
	; r/m8  = uint8_t          y rdx
	; r/m64 = void*            fun_modificar(attackunit_t*) rcx
		push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	mov r12,rdi ; guardo puntero al mapa
	xor r13 , r13
	add r13b , sil
	imul r13 , 255 ; en r13 voy a guardar la posicion de la matriz x*y

	xor r8 , r8 ; por las dudas voy  apasar primero el rdx a un registro en 0
	mov r8b , dl
	add r13 ,  r8
	;
	mov r14,rcx ; aca guardo la funcion 

	mov rdi , [r12 + r13 *8] ; pongo en rdi el componente marcado
	cmp rdi , 0
	je .end
	cmp byte [rdi+ATTACKUNIT_REFERENCES] , 1
	je .norestar
	sub byte [rdi+ATTACKUNIT_REFERENCES] , 1 ; le resto la referencia que va a perder
	.norestar:
	xor rdi , rdi
	add rdi , 16 ; escribo en rdi lo que necesito pedir de memoria
	call malloc ; consigo el lugar donde voy a poner el lugar modificado
	mov rsi , [r12 + r13*8] ;vuelvo al lugar del mapa y lo guardo en rsi
	mov rdi , [rsi] ; accedo a donde esta el attack unit
	mov qword [rax] , rdi ; pongo en donde apunta mi nuevo puntero la mitad del attack unit
	mov rdi , [rsi+8]
	mov qword [rax+8] , rdi ; pongo la otra mitad
	mov r15, rax ; lo preparo para meterlo a la funcion
	mov rdi , r15 ; lo pongo de parametro
	call r14 ; hago que la funcion modifique a este
	imul r13, 8 
	add r12, r13 ; vuelvo a la posicion en el mapa
	mov [r12] , r15 ; pongo el puntero de mi componente cambiado en el mapa donde estaba antes
	
	.end:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp

	ret