extern malloc

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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario


global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 32
ITEM_SIZE EQU 2
;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**     inventario
	; r/m64 = uint16_t*    indice
	; r/m16 = uint16_t     tamanio
	; r/m64 = comparador_t comparador

; bool es_indice_ordenado(item_t** inventario rdi,
;                         uint16_t* indice rsi , 
;						  uint16_t tamanio rdx , 
;						  comparador_t (item_t*,item_t*) comparador rcx) ;
;
es_indice_ordenado:
	push rbp
	mov rbp, rsp
	sub rsp , 16 
	push r12
	push r13
	push r14
	push r15

	mov r12,rdi ; aca guardo el puntero del inventario
	mov r13,rsi ; aca guardo el puntero del indice
	xor r14,r14 ; uso de contador
	mov [rbp-8] , rcx

	mov r15w , dx ; guardo hasta donde tengo que ir
	sub r15 , 1
	.loop:
		cmp r14w, r15w
		je .end
		xor r8, r8 ; limpio r8 para hacer calculo temporal donde guardo cuanto tengo que mover el indice
		mov r8w, word [r13+r14*2]

		;imul r8w , ITEM_SIZE ; veo cuanto me tengo que mover
		mov rdi , qword [r12+r8*8]

		;calculo el otro
				xor r8,r8
		mov r8w, word [ 2+r13+r14*2]
		;imul r8w , ITEM_SIZE
		mov rsi , qword[r12+r8*8]

		call [rbp-8]
		cmp rax , 0
		je  .end
		mov rax , 1
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


;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**  inventario rdi
	; r/m64 = uint16_t* indice rsi
	; r/m16 = uint16_t  tamanio dx 
	push rbp
	mov rbp, rsp
	sub rsp , 16 
	push r12
	push r13
	push r14
	push r15

	mov r12,rdi ; aca guardo el puntero del inventario
	mov r13,rsi ; aca guardo el puntero del indice
	xor r14,r14 ; uso de contador	
	mov r15w , dx ; guardo hasta donde tengo que ir
	;sub r15 , 1
	xor rdi,rdi
	mov di , dx
	call malloc 
	mov rdi,rax ; guardo mi puntero en rdi
	.loop:
		cmp r14w, r15w
		je .end
		xor r8, r8 ; limpio r8 para hacer calculo temporal donde guardo cuanto tengo que mover el indice
		mov r8w, word [r13+r14*2]
		mov rsi , qword [r12+r8*8] ; uso rsi de intermediario
		;imul r8w , ITEM_SIZE ; veo cuanto me tengo que mover
		mov qword [rdi] , rsi
		add rdi , 8
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