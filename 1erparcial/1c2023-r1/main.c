#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ej1.h"

int main (void){
    /*
    pago_t pagos[] = {
        {100, "Kiosco", 0, 1},
        {200, "Supermercado", 1, 1},
        {150, "Panadería", 0, 1},
        {50,  "Farmacia", 2, 0},      // No aprobado, se ignora
        {120, "Librería", 1, 1},
        {80,  "Kiosco", 9, 1}
    };

    uint8_t cantidad = sizeof(pagos) / sizeof(pago_t);

    uint32_t* acumulado = acumuladoPorCliente(cantidad, pagos);

    printf("Montos acumulados por cliente:\n");
    for (int i = 0; i < 10; i++) {
        printf("Cliente %d: $%u\n", i, acumulado[i]);
    }

    free(acumulado);
    */
   char* pepon = "pepe";
   char* lista[] = {"pepe" , "carlos"};
   printf("el blacklist devolvio: %d ",en_blacklist("pepe",lista,2));    
    return 0;
}


