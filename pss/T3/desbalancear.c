#include <stdio.h>
#include <stdlib.h>
#include "desbalancear.h"

// int main() {
//   // El arbol binario del enunciado

//   // Nodo nu= { 117, 0, NULL, NULL };
//   // Nodo ns= { 115, 0, NULL, &nu };
//   // Nodo nw= { 119, 0, NULL, NULL };
//   // Nodo nx= { 120, 0, &nw, NULL };
//   // Nodo nv= { 118, 0, &ns, &nx };

//   Nodo a= {6, 6, NULL, NULL};
//   Nodo b= {7, 7, &a, NULL};
//   Nodo d= {9, 9, NULL, NULL};
//   Nodo c= {8, 8, &b, &d};
//   Nodo f= {11, 11, NULL, NULL};
//   Nodo h= {13, 13, NULL, NULL};
//   Nodo g= {12, 12, &f, &h};
//   Nodo e= {10, 10, &c, &g};


//   Nodo *arbol= &e;
//   Nodo *ult;

//   Nodo *arbol2= desbalanceado(arbol, &ult);
//   desbalancear(&arbol, &ult);
// }


void desbalancear(Nodo **pa, Nodo **pult) {
  Nodo *a = *pa;

  if (!a) {
    *pult = NULL;
    return;
  }

  // Nodo *I = a->izq;
  // Nodo *D = a->der;

  if (a->izq != NULL) {
    Nodo *UI = NULL;
    desbalancear(&(a->izq), &UI);

    UI->der = a;    // El último nodo izquierdo apunta al nodo actual
    *pa = a->izq;   // Ahora la raíz será el subárbol izquierdo ya desbalanceado
    a->izq = NULL;  // Matar el subárbol izquierdo
  }

  if (a->der != NULL) {
    desbalancear(&(a->der), pult);
  } else {
    *pult = a;      // Si no hay hijo derecho entonces la hoja actual es el último nodo
  }
}

Nodo *crearNodo(int id, int hash, Nodo *izq, Nodo *der) {
  Nodo *a = (Nodo *)malloc(sizeof(Nodo));
  a->id = id;
  a->hash = hash;
  a->izq = izq;
  a->der = der;
  return a;
}

Nodo *desbalanceado(Nodo *a, Nodo **pult) {
  if (!a) {
    *pult = NULL;
    return NULL;
  }

  Nodo *nuevo = NULL;
  // Nodo *I = a->izq;
  // Nodo *D = a->der;

  if (a->izq != NULL) {
    Nodo *UI = NULL;
    nuevo = desbalanceado(a->izq, &UI);  

    UI->der = crearNodo(a->id, a->hash, NULL, NULL);  
    *pult = UI->der;
  } else {
    nuevo = crearNodo(a->id, a->hash, NULL, NULL);  // Ya no hace falta desbalancear, solo agregar la hoja
    *pult = nuevo;
  }

  if (a->der != NULL) {
    (*pult)->der = desbalanceado(a->der, pult);
  }

  return nuevo;
}