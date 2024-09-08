#include "stdio.h"
#include "stdlib.h"
#include "string.h"

void duplicar(int *x){
    *x= *x * 2;
    printf("funcion x=%d\n", *x);
}

// este esta en el stack!
char* responderSaludo() {
  char respuesta[] = "Este es un arreglo de caracteres";
  return respuesta;
}
//este esta en el heap!
char* responderSaludo2() {
  char respuesta[] = "Este string persiste en memoria";
  char *res = malloc(strlen(respuesta) + 1);
  strcpy(res, respuesta);
  return res;
}

typedef struct p {
    int x;
    int y;
} Punto;

int main(){
    int x = 4;
    printf("main x=%d\n", x);
    duplicar(&x);
    printf("main x=%d\n", x);
    char *res = responderSaludo2();
    printf("%s\n", res);
    char str[] = "hola";
    free(res); // libera bloque memoria creado malloc.
    res = str; // res ahora apunta al mismo lugar que str.
    printf("%s\n", res);
    
    //(struct p) p1;
    Punto p1;
    p1.x = 5;
    p1.y = 10;
    printf("punto (%d, %d)\n", p1.x, p1.y);
    return 0;
}






// Nodo *a;
// Nodo *b = a->sgte
// free(a);
// liberarCola(b);




// FIFO =         LIFO
// 3                3
// 2                2
// 1                1





