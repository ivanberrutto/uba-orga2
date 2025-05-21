#include "ej1.h"


uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
    uint32_t* acumulado = calloc(10,4);
    for(int i = 0; i < cantidadDePagos ; i++){
        if(arr_pagos[i].aprobado > 0){
            uint8_t clienteActual = arr_pagos[i].cliente ;
            acumulado[i] += arr_pagos[i].monto;
        }
        
    }
    return acumulado;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
    uint8_t ret = 0;
    for(int i=0; i < n ;i ++){
        if (strcmp(comercio, lista_comercios[i] )== 0){
            ret = 1;
        }
    }
    return ret;
}


uint8_t estaEnarrcomercio(char* comercio, char** arr_comercios, uint8_t size_comercios)
{
    uint8_t res = 0;
    for(int i=0; i < size_comercios ; i++){
        if(strcmp(comercio, arr_comercios[i])==0){
            return res;
        }
    }
    return res;
}


pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    int cantidad_de_pagos_en_comercios = 0;
    for (int i = 0; i < cantidad_pagos; i++)
    {
        if(en_blacklist(arr_pagos[i].comercio,arr_comercios,size_comercios)){
            cantidad_de_pagos_en_comercios++;
        }
    }
    pago_t **respuesta = malloc(cantidad_de_pagos_en_comercios *8);
    int proxima_posicion_libre = 0;
    for (int i = 0; i < cantidad_pagos; i++)
    {
        if(en_blacklist(arr_pagos[i].comercio,arr_comercios,size_comercios)){
            pago_t *copia_pago = malloc(sizeof(pago_t));

            copia_pago->monto = arr_pagos[i].monto;
            copia_pago->comercio = arr_pagos[i].comercio; // este esta mal porque estas copiando el puntero y no el string en si
            copia_pago->cliente = arr_pagos[i].cliente;
            copia_pago->aprobado = arr_pagos[i].aprobado;
            
            respuesta[proxima_posicion_libre] = copia_pago;
            proxima_posicion_libre++;
        }
    
    }
    return respuesta;
    /*
    pago_t** pagosEnBlacklist = malloc (sizeof(pago_t)*cantidad_pagos);
    int j = 0;
    for(int i ; i < cantidad_pagos; i++){
        if(estaEnarrcomercio(arr_pagos[i].comercio,arr_comercios,size_comercios)==1){
                pagosEnBlacklist[j] = &arr_pagos[i];
                j++;
        }
    }
    return pagosEnBlacklist;
    */
}


