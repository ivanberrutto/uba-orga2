#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "ej1.h"

/**
 * Cuenta cuántos tests corrieron exitosamente.
 */
uint64_t successful_tests = 0;
/**
 * Cuenta cuántos tests test fallaron.
 */
uint64_t failed_tests = 0;

/**
 * El mensaje [DONE] escrito en verde.
 */
#define DONE "[\033[32;1mDONE\033[0m] "

/**
 * El mensaje [FAIL] escrito en rojo.
 */
#define FAIL "[\033[31;1mFAIL\033[0m] "

/**
 * El mensaje [INFO] escrito en amarillo.
 */
#define INFO "[\033[33;1mINFO\033[0m] "

/**
 * El mensaje [SKIP] escrito en magenta.
 */
#define SKIP "[\033[95;1mSKIP\033[0m] "

/**
 * Testea que la función `texto_literal` funcione como es de esperarse.
 *
 * Parámetros:
 *   - texto: El texto a usar como parámetro de `texto_literal`.
 */
void test_crear_literal(const char* texto) {
	bool failed = false;
	uint64_t expected_size = strlen(texto);
	texto_literal_t* resultado = texto_literal(texto);

	if (resultado == NULL) {
		printf(
			FAIL "test_crear_literal(\"%s\", %ld) | Se recibió null como resultado de texto_literal\n",
			texto, expected_size
		);
		failed_tests++;
		return;
	}

	if (resultado->tipo != TEXTO_LITERAL) {
		printf(
			FAIL "test_crear_literal(\"%s\", %ld) | El resultado no es de tipo TEXTO_LITERAL\n",
			texto, expected_size
		);
		failed = true;
	}

	if (resultado->usos != 0) {
		printf(
			FAIL "test_crear_literal(\"%s\", %ld) | El resultado tiene usos pese a ser nuevo\n",
			texto, expected_size
		);
		failed = true;
	}

	if (resultado->tamanio != expected_size) {
		printf(
			FAIL "test_crear_literal(\"%s\", %ld) | El resultado no tiene el tamaño esperado (%ld) sino %ld en su lugar\n",
			texto, expected_size, expected_size, resultado->tamanio
		);
		failed = true;
	}

	if (resultado->contenido != texto) {
		printf(
			FAIL "test_crear_literal(\"%s\", %ld) | El resultado no tiene el texto esperado (no es necesario duplicar la cadena!)\n",
			texto, expected_size
		);
		failed = true;
	}

	if (failed) {
		failed_tests++;
	} else {
		printf(
			DONE "test_crear_literal(\"%s\", %ld)\n",
			texto, expected_size
		);
		successful_tests++;
	}

	texto_liberar((texto_cualquiera_t*) resultado);
}

/**
 * Testea que la función `texto_concatenar` funcione como es de esperarse.
 * Requiere que la función `texto_literal` funcione.
 *
 * Parámetros:
 *   - izquierda: El texto que va al principio de la concatenación a crear.
 *   - derecha: El texto que va final de la concatenación a crear.
 */
void test_crear_concatenacion(const char* izquierda, const char* derecha) {
	bool failed = false;
	uint64_t expected_size = strlen(izquierda) + strlen(derecha);
	texto_cualquiera_t* literal_izquierda = (texto_cualquiera_t*) texto_literal(izquierda);
	texto_cualquiera_t* literal_derecha = (texto_cualquiera_t*) texto_literal(derecha);
	texto_concatenacion_t* resultado = texto_concatenar(literal_izquierda, literal_derecha);

	if (resultado == NULL) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | Se recibió null como resultado de texto_concatenar\n",
			izquierda, derecha
		);
		failed_tests++;
		return;
	}

	if (resultado->tipo != TEXTO_CONCATENACION) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado no es de tipo TEXTO_CONCATENACION\n",
			izquierda, derecha
		);
		failed = true;
	}

	if (resultado->usos != 0) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado tiene usos pese a ser nuevo\n",
			izquierda, derecha
		);
		failed = true;
	}

	if (resultado->tamanio != expected_size) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado no tiene el tamaño esperado (%ld) sino %ld en su lugar\n",
			izquierda, derecha, expected_size, resultado->tamanio
		);
		failed = true;
	}

	if (resultado->izquierda->usos != 1) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado no incrementó la cantidad de usos del texto de la izquierda\n",
			izquierda, derecha
		);
		failed = true;
	}

	if (resultado->derecha->usos != 1) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado no incrementó la cantidad de usos del texto de la derecha\n",
			izquierda, derecha
		);
		failed = true;
	}

	if (resultado->izquierda != literal_izquierda) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado no tiene el texto esperado en la izquierda\n",
			izquierda, derecha
		);
		failed = true;
	}

	if (resultado->derecha != literal_derecha) {
		printf(
			FAIL "test_crear_concatenacion(\"%s\", \"%s\") | El resultado no tiene el texto esperado en la derecha\n",
			izquierda, derecha
		);
		failed = true;
	}

	if (failed) {
		failed_tests++;
	} else {
		printf(
			DONE "test_crear_concatenacion(\"%s\", \"%s\")\n",
			izquierda, derecha
		);
		successful_tests++;
	}

	texto_liberar((texto_cualquiera_t*) resultado);
}

/**
 * Consolida los contenidos de un `texto_cualquiera_t` en un buffer destino.
 *
 * Devuelve la cantidad de caracteres escritos.
 *
 * Parámetros:
 *   - destino: Dónde escribir los contenidos del texto.
 *   - tamanio: Tamanio del buffer.
 *   - texto: El texto a escribir.
 */
uint64_t texto_consolidar(char* destino, uint64_t tamanio, texto_cualquiera_t* texto) {
	uint64_t i = 0;
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		for (; i < literal->tamanio && i < tamanio; i++) {
			destino[i] = literal->contenido[i];
		}
		return i;
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		i = texto_consolidar(destino, tamanio, concatenacion->izquierda);
		i += texto_consolidar(destino + i, tamanio - i, concatenacion->derecha);
		return i;
	}
}

/**
 * Testea que la implementación del ejercicio 1 funcione incluso cuando se
 * reusan nodos en la estructura. Lo hace construyendo una estructura con la
 * siguiente pinta:
 *
 * ```
 * (+)-izq---> (+)-izq----> ... `n` veces ... (+)--izq---> (texto)
 *   `-der-´      `-der-´                        `-der-´
 * ```
 *
 * Requiere que `texto_literal` y `texto_concatenar` funcionen.
 *
 * Parámetros:
 *   - texto: El texto a repetir una cantidad exponencial de veces.
 *   - n: La cantidad de veces a repetir el texto (escrita como potencia de 2).
 *        0 significa una vez, 1 significa 2 veces, 6 significa 64 veces, etc.
 */
void test_concatenacion_exponencial(const char* texto, uint64_t n) {
	bool failed = false;
	uint64_t tamanio_texto = strlen(texto);
	uint64_t tamanio_esperado = tamanio_texto << n;
	texto_cualquiera_t* resultado = (texto_cualquiera_t*) texto_literal(texto);

	char buffer_esperado[tamanio_esperado + 1];
	char buffer_actual[tamanio_esperado + 1];

	for (int i = 0; i < (1 << n); i++) {
		uint64_t escrito_hasta_ahora = i * tamanio_texto;
		strncpy(buffer_esperado + escrito_hasta_ahora, texto, tamanio_esperado + 1 - escrito_hasta_ahora);
	}

	for (uint64_t i = 0; i < n; i++) {
		resultado = (texto_cualquiera_t*) texto_concatenar(resultado, resultado);
	}
	if (resultado->tamanio != tamanio_esperado) {
		printf(
			FAIL "test_concatenacion_exponencial(\"%s\", %ld) | La concatenación no resultó en el tamaño esperado. Se esperaba %ld pero se obtuvo %ld\n",
			texto, n, tamanio_esperado, resultado->tamanio
		);
		failed = true;
	}

	uint64_t tamanio_actual = texto_consolidar(buffer_actual, tamanio_esperado + 1, resultado);
	buffer_actual[tamanio_esperado] = '\0';

	if (tamanio_actual != tamanio_esperado) {
		printf(
			FAIL "test_concatenacion_exponencial(\"%s\", %ld) | La concatenación representa un texto más grande que el esperado. Se esperaba %ld pero se obtuvo %ld\n",
			texto, n, tamanio_esperado, tamanio_actual
		);
		failed = true;
	}

	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) | Las siguientes tres cadenas deberían ser iguales:\n",
		texto, n
	);
	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) |   - Primera cadena (esperada)\n",
		texto, n
	);
	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) |     %s\n",
		texto, n, buffer_esperado
	);
	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) |   - Segunda cadena (generada)\n",
		texto, n
	);
	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) |     %s\n",
		texto, n, buffer_actual
	);
	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) |   - Tercera cadena (generada, usando `texto_imprimir`)\n",
		texto, n
	);
	printf(
		INFO "test_concatenacion_exponencial(\"%s\", %ld) |     ",
		texto, n
	);
	texto_imprimir(resultado);
	printf("\n");

	if (strcmp(buffer_esperado, buffer_actual) != 0) {
		printf(
			FAIL "test_concatenacion_exponencial(\"%s\", %ld) | Las cadenas no son iguales\n",
			texto, n
		);
		failed = true;
	}

	if (failed) {
		failed_tests++;
	} else {
		printf(
			DONE "test_concatenacion_exponencial(\"%s\", %ld)\n",
			texto, n
		);
		successful_tests++;
	}

	texto_liberar(resultado);
}

/**
 * Evalúa los tests del ejercicio 1A. Este ejercicio requiere implementar
 * `texto_literal` y `texto_concatenar`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_1A_HECHO`.
 */
void test_ej1a(void) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_1A_HECHO) {
		printf(SKIP "El ejercicio 1A no está hecho aún.\n");
		return;
	}

	test_crear_literal("prueba");
	test_crear_literal("prueba\0texto que no cuenta");
	test_crear_literal("");

	test_crear_concatenacion("izquierda", "derecha");
	test_crear_concatenacion("achered", "adreiuqzi");

	test_concatenacion_exponencial("orga2", 0);
	test_concatenacion_exponencial("orga2", 1);
	test_concatenacion_exponencial("orga2", 2);
	test_concatenacion_exponencial("orga2", 3);
	test_concatenacion_exponencial("orga2", 4);
	test_concatenacion_exponencial("orga2", 5);

	if (failed_at_start < failed_tests) {
		printf(FAIL "El ejercicio 1A tuvo tests que fallaron.\n");
	}
}

/**
 * Crea un `texto_literal_t` en la pila. Devuelve su puntero como si fuera un
 * `texto_cualquiera_t*`.
 *
 * Es preferible usar `LIT(texto)` siempre que sea posible, dado que ese macro
 * calcula el tamaño del texto en lugar de recibirlo como parámetro.
 *
 * Parámetros:
 *   - texto: El texto a poner en el literal.
 *   - sz: El tamaño del texto. Puede estar equivocado (para evaluar el
 *         ejercicio 1C)
 */
#define LIT_SZ(texto, sz) ((texto_cualquiera_t*) &(texto_literal_t) { \
	.tipo = TEXTO_LITERAL,                                        \
	.tamanio = (sz),                                              \
	.contenido = (texto)                                          \
})

/**
 * Crea un `texto_concatenacion_t` en la pila. Devuelve su puntero como si
 * fuera un `texto_cualquiera_t`.
 *
 * Es preferible usar `ADD(texto)` siempre que sea posible, dado que ese macro
 * calcula el tamaño del texto en lugar de recibirlo como parámetro.
 *
 * Parámetros:
 *   - texto_izquierda: El texto que va al principio del resultado.
 *   - texto_derecha: El texto que va al final del resultado.
 *   - sz: El tamaño del texto. Puede estar equivocado (para evaluar el
 *         ejercicio 1C)
 */
#define ADD_SZ(texto_izquierda, texto_derecha, sz) ((texto_cualquiera_t*) &(texto_concatenacion_t) { \
	.tipo = TEXTO_CONCATENACION,                                                                 \
	.tamanio = (sz),                                                                             \
	.izquierda = (texto_izquierda),                                                              \
	.derecha = (texto_derecha)                                                                   \
})

/**
 * Crea un `texto_literal_t` en la pila. Devuelve su puntero como si fuera un
 * `texto_cualquiera_t*`. Calcula el tamaño del texto automáticamente.
 *
 * En lugar de calcular su tamaño (como hace `LIT` pone un 0).
 *
 * Parámetros:
 *   - texto: El texto a poner en el literal.
 */
#define LIT0(texto) LIT_SZ(texto, 0)

/**
 * Crea un `texto_literal_t` en la pila. Devuelve su puntero como si fuera un
 * `texto_cualquiera_t*`. Calcula el tamaño del texto automáticamente.
 *
 * Parámetros:
 *   - texto: El texto a poner en el literal.
 */
#define LIT(texto) LIT_SZ(texto, strlen(texto))

/**
 * Crea un `texto_concatenacion_t` en la pila. Devuelve su puntero como si
 * fuera un `texto_cualquiera_t`.
 *
 * Parámetros:
 *   - texto_izquierda: El texto que va al principio del resultado.
 *   - texto_derecha: El texto que va al final del resultado.
 */
#define ADD(texto_izquierda, texto_derecha) \
	ADD_SZ(texto_izquierda, texto_derecha, (texto_izquierda)->tamanio + (texto_derecha)->tamanio)

/**
 * Testea que la función `texto_calcular_tamanios` funcione como es de esperarse.
 *
 * Lo hace avanzando sobre la tabla `tamanios_esperados`.
 *
 * Parámetros:
 *   - texto: El texto a usar como parámetro de `texto_tamanio_total`.
 *   - tamanio_esperado: El tamaño a esperarse para ese texto.
 */
static bool test_longitud__buscar_errores(texto_cualquiera_t* texto_inicial, texto_cualquiera_t* texto, uint64_t** tamanios_esperados) {
	if (**tamanios_esperados == 0xFFFFFFFFFFFFFFFF) {
		printf(FAIL "test_longitud(%p /* ", (void*) texto_inicial);
		texto_imprimir(texto_inicial);
		printf(" */) | Se modificó el texto de una forma inesperada\n");
		return false;
	}
	uint64_t tamanio_esperado = *((*tamanios_esperados)++);
	uint64_t tamanio_calculado = texto->tamanio;
	bool todo_ok = true;
	if (texto->tipo == TEXTO_CONCATENACION) {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		todo_ok = test_longitud__buscar_errores(texto_inicial, concatenacion->izquierda, tamanios_esperados)
			&& test_longitud__buscar_errores(texto_inicial, concatenacion->derecha, tamanios_esperados);
	}
	if (tamanio_esperado != tamanio_calculado) {
		printf(FAIL "test_longitud(%p /* ", (void*) texto_inicial);
		texto_imprimir(texto_inicial);
		printf(" */) | El tamaño calculado para la subcadena \"");
		texto_imprimir(texto);
		printf("\" (%ld) es incorrecto. Se esperaba (%ld)\n", tamanio_calculado, tamanio_esperado);
		todo_ok = false;
	}
	return todo_ok;
}

/**
 * Testea que la función `texto_calcular_tamanios` funcione como es de esperarse.
 *
 * Parámetros:
 *   - texto: El texto a usar como parámetro de `texto_tamanio_total`.
 *   - tamanio_esperado: El tamaño a esperarse para ese texto.
 */
void test_longitud(texto_cualquiera_t* texto, uint64_t* tamanios_esperados) {
	texto_calcular_tamanios(texto);
	if (test_longitud__buscar_errores(texto, texto, &tamanios_esperados)) {
		if (*tamanios_esperados != 0xFFFFFFFFFFFFFFFF) {
			printf(FAIL "test_longitud(%p /* ", (void*) texto);
			texto_imprimir(texto);
			printf(" */) | Se modificó el texto de una forma inesperada\n");
		}
		printf(DONE "test_longitud(%p /* ", (void*) texto);
		texto_imprimir(texto);
		printf(" */)\n");
		successful_tests++;
	} else {
		failed_tests++;
	}
}

/**
 * Evalúa los tests del ejercicio 1B. Este ejercicio requiere implementar
 * `texto_tamanio_total`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_1B_HECHO`.
 */
void test_ej1b(void) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_1B_HECHO) {
		printf(SKIP "El ejercicio 1B no está hecho aún.\n");
		return;
	}

	test_longitud(LIT0("x86_64"), (uint64_t[]) {
		6, /* x86_64 */
		0xFFFFFFFFFFFFFFFF /* End-of-Input */
	});
	test_longitud(LIT0("Organizacion del Computador 2"), (uint64_t[]){
		29, /* Organizacion del Computador 2 */
		0xFFFFFFFFFFFFFFFF /* End-of-Input */
	});

	test_longitud(ADD(LIT0("x86"), LIT0("_64")), (uint64_t[]){
		6, /* x86_64 */
		3, /* x86 */
		3, /* _64 */
		0xFFFFFFFFFFFFFFFF /* End-of-Input */
	});
	test_longitud(ADD(ADD(LIT0("Organizacion"), LIT0("del")), ADD(LIT0("Computador"), LIT0("2"))), (uint64_t[]){
		26, /* OrganizaciondelComputador2 */
		15, /* Organizaciondel */
		12, /* Organizacion */
		 3, /* del */
		11, /* Computador2 */
		10, /* Computador */
		 1, /* 2 */
		0xFFFFFFFFFFFFFFFF /* End-of-Input */
	});

	/* Texto que crece exponencialmente */ {
		texto_cualquiera_t* texto;
		texto = LIT0("x86");
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		test_longitud(texto, (uint64_t[]){
			3 << 4, /* x86x86x86x86x86x86x86x86x86x86x86x86x86x86x86x86  */
			3 << 3, /* x86x86x86x86x86x86x86x86 */
			3 << 2, /* x86x86x86x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 2, /* x86x86x86x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 3, /* x86x86x86x86x86x86x86x86 */
			3 << 2, /* x86x86x86x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 2, /* x86x86x86x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0, /* x86 */
			3 << 1, /* x86x86 */
			3 << 0, /* x86 */
			3 << 0,  /* x86 */
			0xFFFFFFFFFFFFFFFF /* End-of-Input */
		});
	}

	/* Texto que reusa partes */ {
		texto_cualquiera_t* materia = LIT0("Orga2");
		texto_cualquiera_t* setup = LIT0("Hoy voy a ");
		texto_cualquiera_t* entre_oraciones = LIT0(". ");
		texto_cualquiera_t* oracion_1 = ADD(setup, ADD(LIT0("rendir "), materia));
		texto_cualquiera_t* oracion_2 = ADD(setup, ADD(LIT0("programar para "), materia));
		texto_cualquiera_t* texto = ADD(oracion_1, ADD(entre_oraciones, oracion_2));
		test_longitud(texto, (uint64_t[]) {
			strlen("Hoy voy a rendir Orga2. Hoy voy a programar para Orga2"),
			strlen("Hoy voy a rendir Orga2"),
			strlen("Hoy voy a "),
			strlen("rendir Orga2"),
			strlen("rendir "),
			strlen("Orga2"),
			strlen(". Hoy voy a programar para Orga2"),
			strlen(". "),
			strlen("Hoy voy a programar para Orga2"),
			strlen("Hoy voy a "),
			strlen("programar para Orga2"),
			strlen("programar para "),
			strlen("Orga2"),
			0xFFFFFFFFFFFFFFFF /* End-of-Input */
		});
	}

	if (failed_at_start < failed_tests) {
		printf(FAIL "El ejercicio 1B tuvo tests que fallaron.\n");
	}
}

/**
 * Testea que la función `texto_chequear_tamanio` funcione como es de
 * esperarse.
 *
 * Parámetros:
 *   - texto: El texto a usar como parámetro de `texto_chequear_tamanio`.
 *   - tamanio_esperado: La salida esperada (si los tamaños están bien
 *                       calculados o no).
 */
void test_chequear_tamanio(texto_cualquiera_t* texto, bool validez_esperada) {
	bool validez_actual = texto_chequear_tamanio(texto);
	const char* validez_esperada_texto = validez_esperada ? "true" : "false";
	const char* validez_actual_texto = validez_actual ? "true" : "false";
	if (validez_actual != validez_esperada) {
		printf(FAIL "test_chequear_tamanio(%p /* ", (void*) texto);
		texto_imprimir(texto);
		printf(
			" */, %s) | El chequeo de validez de tamaños dió (%s) pero se esperaba (%s)\n",
			validez_esperada_texto, validez_actual_texto, validez_esperada_texto
		);
		failed_tests++;
	} else {
		printf(DONE "test_chequear_tamanio(%p /* ", (void*) texto);
		texto_imprimir(texto);
		printf(" */, %s)\n", validez_esperada_texto);
		successful_tests++;
	}
}

/**
 * Evalúa los tests del ejercicio 1C. Este ejercicio requiere implementar
 * `texto_chequear_tamanio`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_1C_HECHO`.
 */
void test_ej1c(void) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_1C_HECHO) {
		printf(SKIP "El ejercicio 1C no está hecho aún.\n");
		return;
	}

	test_chequear_tamanio(LIT_SZ("x86_64", 6), true);
	test_chequear_tamanio(LIT_SZ("x86_64", 9), false);
	test_chequear_tamanio(LIT_SZ("x86_64", 3), false);
	test_chequear_tamanio(LIT_SZ("Organizacion del Computador 2", 29), true);
	test_chequear_tamanio(LIT_SZ("Organizacion del Computador 2", 2), false);

	test_chequear_tamanio(ADD(LIT("x86"), LIT("_64")), true);
	test_chequear_tamanio(ADD(LIT("x86"), LIT_SZ("_64", 2)), false);
	test_chequear_tamanio(ADD_SZ(LIT("x86"), LIT("_64"), 4), false);
	test_chequear_tamanio(ADD(ADD(LIT("Organizacion"), LIT("del")), ADD(LIT("Computador"), LIT("2"))), true);
	test_chequear_tamanio(ADD(ADD(LIT("Organizacion"), LIT_SZ("del", 4)), ADD(LIT("Computador"), LIT("2"))), false);
	test_chequear_tamanio(ADD(ADD(LIT("Organizacion"), LIT("del")), ADD_SZ(LIT("Computador"), LIT("2"), 90)), false);

	/* Texto que crece exponencialmente */ {
		texto_cualquiera_t* texto;
		texto = LIT_SZ("x86", 3);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		test_chequear_tamanio(texto, true);

		texto = LIT_SZ("x86", 0);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		test_chequear_tamanio(texto, false);

		texto = LIT_SZ("x86", 3);
		texto = ADD(texto, texto);
		texto = ADD(texto, texto);
		texto = ADD_SZ(texto, texto, 6);
		texto = ADD(texto, texto);
		test_chequear_tamanio(texto, false);
	}

	/* Texto que reusa partes */ {
		texto_cualquiera_t* materia = LIT("Orga2");
		texto_cualquiera_t* setup = LIT("Hoy voy a ");
		texto_cualquiera_t* entre_oraciones = LIT(". ");
		texto_cualquiera_t* oracion_1 = ADD(setup, ADD(LIT("rendir "), materia));
		texto_cualquiera_t* oracion_2 = ADD(setup, ADD(LIT_SZ("programar para ", 90), materia));
		texto_cualquiera_t* oracion_3 = ADD(setup, ADD_SZ(LIT("programar para "), materia, 90));
		test_chequear_tamanio(oracion_1, true);
		test_chequear_tamanio(oracion_2, false);
		test_chequear_tamanio(oracion_3, false);
	}

	/* Texto que dan las sumas pero está mal calculado */ {
		texto_cualquiera_t* esta = LIT_SZ("Esta", 5);
		texto_cualquiera_t* es_una = LIT_SZ(" es una ", 15);
		texto_cualquiera_t* prueba = LIT_SZ("prueba", 22);
		texto_cualquiera_t* esta_es_una = ADD_SZ(esta, es_una, 20);
		texto_cualquiera_t* esta_es_una_prueba = ADD_SZ(esta_es_una, prueba, 42);
		test_chequear_tamanio(esta_es_una_prueba, false);
	}

	/* Texto que todos los nodos internos están mal pero el externo está bien */ {
		texto_cualquiera_t* esta = LIT_SZ("Esta", 5);
		texto_cualquiera_t* es_una = LIT_SZ(" es una ", 15);
		texto_cualquiera_t* prueba = LIT_SZ("prueba", 22);
		texto_cualquiera_t* esta_es_una = ADD_SZ(esta, es_una, 20);
		texto_cualquiera_t* esta_es_una_prueba = ADD_SZ(esta_es_una, prueba, 18);
		test_chequear_tamanio(esta_es_una_prueba, false);
	}

	if (failed_at_start < failed_tests) {
		printf(FAIL "El ejercicio 1C tuvo tests que fallaron.\n");
	}
}

/**
 * Corre los tests de este ejercicio.
 *
 * Las variables `EJERCICIO_1A_HECHO`, `EJERCICIO_1B_HECHO` y
 * `EJERCICIO_1C_HECHO` controlan qué testsuites se van a correr. Ponerlas como
 * `false` indica que el ejercicio no está implementado y por lo tanto no
 * querés que se corran los tests asociados a él.
 *
 * Recordá que los tres ejercicios pueden implementarse independientemente uno
 * del otro.
 *
 * Si algún test falla el programa va a terminar con un código de error.
 */
int main(int argc, char* argv[]) {
	// 1A
	test_ej1a();
	// 1B
	test_ej1b();
	// 1C
	test_ej1c();

	printf(
		"\nSe corrieron %ld tests. %ld corrieron exitosamente. %ld fallaron.\n",
		failed_tests + successful_tests, successful_tests, failed_tests
	);

	if (failed_tests) {
		return 1;
	} else {
		return 0;
	}
}
