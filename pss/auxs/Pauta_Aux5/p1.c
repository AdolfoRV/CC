#include <stdio.h>
#include <stdlib.h>
#include "utils.h"

void podar(Nodo **pa, int y);

int main(void){
  Nodo *arbol = 
    createNodo(4, 
        createNodo(2,
          createNodo(1, NULL, NULL),
          createNodo(3, NULL, NULL)),
        createNodo(6,
          createNodo(5, NULL, NULL),
          NULL));
  printiArbol(arbol);
  printf("\n");
  podar(&arbol, 5);
  printiArbol(arbol);
  printf("\n");
  return 0;
}

void podar(Nodo **pa, int y){
  Nodo *a = *pa;
  if(a == NULL){
    return;
  }
  if(a->x <= y){
    podar(&a->der, y);
  }
  else{
    podar(&a->izq, y);
    *pa = a->izq;
  }
}

Nodo* createNodo(int x, Nodo *izq, Nodo *der) {
  Nodo *a = (Nodo*)malloc(sizeof(Nodo));
  a->x = x;
  a->izq = izq;
  a->der = der;
  return a;
}

void printcArbol(Nodo *a) {
  if(a == NULL) return;
  printcArbol(a->izq);
  printf("%c ", a->x);
  printcArbol(a->der);
}

void printiArbol(Nodo *a) {
  if(a == NULL) return;
  printiArbol(a->izq);
  printf("%i ", a->x);
  printiArbol(a->der);
}