#include "stdio.h"
#include "stdlib.h"
#include "string.h"

// Nodo a = (x ,NULL);
// Nodo b = (z, &a);

typedef struct nodo {
    int info;
    struct nodo *sgte;
} Nodo;

void printList (Nodo *n){
    if (n == NULL){ // llegamos al final de la lista.
        printf ("\n");
        return;
    }
    printf("%d ", n->info); // n->info <=> (*n).info
    printList( n->sgte );
}

Nodo *createNodeList(int *list, int size){
    Nodo *n = malloc(sizeof(Nodo)); // Creamos un nodo {  ,  }
    n->info = *list;//al nodo le asignamos su valor { list[0],   }
    if (size > 1) {
        n->sgte = createNodeList(++list, size-1);
    } else {
        n->sgte = NULL;
    }
    return n;
}

void append(Nodo **pa, Nodo *b){
    if (*pa == NULL){
        *pa = b;
    } else {
        append( &(*pa)->sgte , b);
    }
    return;
}


int main() {
    int list[] = {2, 5, 7, 5 , 2, 21, 1, 54};
    Nodo *a = createNodeList( list, 8);
    printf("lista a = ");
    printList(a);
    int listB[] = {7, 8, 4};
    Nodo *b = createNodeList( listB, 3);
    printf("lista b = ");
    printList(b);
    printf("append(&a,b) = ");
    append(&a,b);
    printList(a);
    Nodo *c = NULL;
    printf("lista c = ");
    printList(c);
    printf("append(&c,b) = ");
    append(&c,b);
    printList(c);
    return 0;
}
