#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Muestra un `texto_cualquiera_t` en la pantalla.
 *
 * Parámetros:
 *   - texto: El texto a imprimir.
 */
void texto_imprimir(texto_cualquiera_t* texto) {
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		printf("%s", literal->contenido);
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		texto_imprimir(concatenacion->izquierda);
		texto_imprimir(concatenacion->derecha);
	}
}

/**
 * Libera un `texto_cualquiera_t` pasado por parámetro. Esto hace que toda la
 * memoria usada por ese texto (y las partes que lo componen) sean devueltas al
 * sistema operativo.
 *
 * Si una cadena está siendo usada por otra entonces ésta no se puede liberar.
 * `texto_liberar` notifica al usuario de esto devolviendo `false`. Es decir:
 * `texto_liberar` devuelve un booleano que representa si la acción pudo
 * llevarse a cabo o no.
 *
 * Parámetros:
 *   - texto: El texto a liberar.
 */
bool texto_liberar(texto_cualquiera_t* texto) {
	if (texto->usos != 0) {
		// Alguien está usando a este texto, aún no lo podemos liberar
		return false;
	}

	if (texto->tipo == TEXTO_CONCATENACION) {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		// Vamos a dejar de usar la cadena de la izquierda
		concatenacion->izquierda->usos--;
		texto_liberar(concatenacion->izquierda);

		// Y vamos a dejar de usar la cadena de la derecha
		concatenacion->derecha->usos--;
		texto_liberar(concatenacion->derecha);
	}
	free(texto);
	return true;
}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - texto_literal
 *   - texto_concatenar
 */
bool EJERCICIO_1A_HECHO = false;

/**
 * Crea un `texto_literal_t` que representa la cadena pasada por parámetro.
 *
 * Debe calcular la longitud de esa cadena.
 *
 * El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
 *
 * Parámetros:
 *   - texto: El texto que debería ser representado por el literal a crear.
 */
texto_literal_t* texto_literal(const char* texto) {
	texto_literal_t* resultado = malloc(sizeof(texto_literal_t));
	resultado->tipo = TEXTO_LITERAL;
	resultado->tamanio = strlen(texto);
	resultado->usos = 0;
	resultado->contenido = texto;
	return resultado;
}

/**
 * Crea un `texto_concatenacion_t` que representa la concatenación de ambos
 * parámetros.
 *
 * Los textos `izquierda` y `derecha` serán usadas por el resultado, por lo
 * que sus contadores de usos incrementarán.
 *
 * El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
 *
 * Parámetros:
 *   - izquierda: El texto que debería ir a la izquierda.
 *   - derecha:   El texto que debería ir a la derecha.
 */
texto_concatenacion_t* texto_concatenar(texto_cualquiera_t* izquierda, texto_cualquiera_t* derecha) {
	texto_concatenacion_t* resultado = malloc(sizeof(texto_concatenacion_t));
	resultado->tipo= TEXTO_CONCATENACION;
	resultado->usos = 0;
	izquierda->usos +=1;
	derecha->usos +=1;
	resultado->tamanio= (izquierda->tamanio) + (derecha->tamanio); 
	resultado->izquierda = izquierda;
	resultado->derecha =derecha;
	return resultado;
}

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - texto_tamanio_total
 */
bool EJERCICIO_1B_HECHO = false;

/**
 * Calcula el tamaño total de un `texto_cualquiera_t` y todos sus nodos
 * internos. Actualiza el campo `tamanio` del texto pasado como parámetro.
 *
 * Parámetros:
 *   - texto: El texto en cuestión.
 */
void texto_calcular_tamanios(texto_cualquiera_t* texto) {
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		// ¿Cómo calculo el tamaño del texto que representa un literal?
		texto->tamanio = strlen(literal->contenido);
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		// ¿Cómo calculo el tamaño del texto que representa una concatenación?
		texto_calcular_tamanios(concatenacion->izquierda);
		texto_calcular_tamanios(concatenacion->derecha);
		texto->tamanio = (concatenacion->izquierda->tamanio) + (concatenacion->derecha->tamanio);
	}
}

/**
 * Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - texto_chequear_tamanio
 */
bool EJERCICIO_1C_HECHO = true;

/**
 * Chequea si los tamaños de todos los nodos internos al parámetro corresponden
 * al tamaño del texto representado.
 *
 * Es decir: si los campos `tamanio` están bien calculados.
 *
 * Parámetros:
 *   - texto: El texto a verificar.
 */
bool texto_chequear_tamanio(texto_cualquiera_t* texto) {
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		if(texto->tamanio == strlen(literal->contenido)){
			return true;
		}
		// ¿Cómo chequeo si un literal tiene el tamaño bien calculado?
		return false;
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		// ¿Cómo chequeo si una concatenación tiene el tamaño de sus literales
		//  bien calculado?
		if((texto->tamanio == ((concatenacion->izquierda->tamanio)+(concatenacion->derecha->tamanio))) && texto_chequear_tamanio(concatenacion->derecha) && texto_chequear_tamanio(concatenacion->izquierda)){
			return true;
		}
		return false;
	}
}

