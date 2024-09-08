#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>
#include <sys/resource.h>

#include "desbalancear.h"
#include "test-util.h"

// ----------------------------------------------------
// Funcion que verifica que 2 arboles binarios son iguales

static void comparar(Nodo *a, Nodo *b) {
  if (a==NULL) {
    if (b==NULL)
      return;
    fprintf(stderr, "Arboles distintos: a es NULL, b tiene etiqueta %d\n",
                    b->id);
    exit(1);
  }
  else if (b==NULL) {
    fprintf(stderr, "Arboles distintos: b es NULL, a tiene etiqueta %d\n",
                    a->id);
    exit(1);
  }
  else {
    if (a->id!=b->id || a->hash!=b->hash) {
      fprintf(stderr, "Etiquetas de arboles son distintas: %d %d != %d %d\n",
                      a->id, a->hash, b->id, b->hash);
      exit(1);
    }
    comparar(a->izq, b->izq);
    comparar(a->der, b->der);
  }
}

// ----------------------------------------------------
// Funcion que verifica que los campos id de un arbol binario
// desbalanceado sea 1, 2, 3, etc.  Ademas la direccion del ultimo nodo
// debe ser ult

static void verificar_des(Nodo *a, int N, Nodo *ult) {
  int ref= 1;
  while (a->der!=NULL) {
    if (a->id!=ref) {
      fprintf(stderr, "Id es %d, debio ser %d\n", a->id, ref);
      exit(1);
    }
    if (a->izq!=NULL) {
      fprintf(stderr, "Subarbol izquierdo debio ser NULL en nodo %d\n", a->id);
      exit(1);
    }
    a= a->der;
    ref++;
  }
  if (a!=ult) {
    fprintf(stderr, "El ultimo nodo es incorrecto\n");
    exit(1);
  }
  if ( a->id != ref ) {
    fprintf(stderr, "Ultimo nodo tiene id %d, debio ser %d\n", a->id, ref);
    exit(1);
  }
}

// ----------------------------------------------------
// Libera un arbol binario

static void liberar(Nodo *a) {
  if (a!=NULL) {
    liberar(a->izq);
    liberar(a->der);
    free(a);
  }
}

// ----------------------------------------------------
// Libera un arbol binario desbalanceado.  Liberarlo con la
// la funcion liberar provocaria un desborde de pila.

static void liberar_des(Nodo *a) {
  while (a!=NULL) {
    Nodo *der= a->der;
    free(a);
    a= der;
  }
}

// ----------------------------------------------------
// Crea una copia de un arbol binario

static Nodo *copia(Nodo *a) {
  if (a==NULL)
    return NULL;
 
  Nodo *an= malloc(sizeof(Nodo));
  an->id= a->id;
  an->hash= a->hash;
  an->izq= copia(a->izq);
  an->der= copia(a->der);
  return an;
}

// ----------------------------------------------------
// Crea un arbol binario de busqueda bien equilibrado en donde 
// los id van de i a j

static Nodo *equilibrado(int i, int j) {
  if (i>j)
    return NULL;
  int k= (i+j+1)/2;
  Nodo *a= malloc(sizeof(Nodo));
  a->id= k;
  a->hash= (intptr_t)a;
  a->izq= equilibrado(i, k-1);
  a->der= equilibrado(k+1, j);
  return a;
}

// ----------------------------------------------------
// El arbol binario del enunciado

static Nodo nu= { 'u', 0, NULL, NULL };
static Nodo ns= { 's', 0, NULL, &nu };
static Nodo nw= { 'w', 0, NULL, NULL };
static Nodo nx= { 'x', 0, &nw, NULL };
static Nodo nv= { 'v', 0, &ns, &nx };

// ----------------------------------------------------
// El arbol binario desbalanceado del enunciado

static Nodo nxref= { 'x', 0, NULL, NULL };
static Nodo nwref= { 'w', 0, NULL, &nxref };
static Nodo nvref= { 'v', 0, NULL, &nwref };
static Nodo nuref= { 'u', 0, NULL, &nvref };
static Nodo nsref= { 's', 0, NULL, &nuref };

void test_unitario(void) {
  printf("Primero se verifica desbalanceado porque es mas facil\n");
  printf("-----------------------------------------------------\n\n");

  {
    printf("Verificando el arbol vacio\n");
    Nodo *a= NULL;
    Nodo *ult;
    Nodo *des= desbalanceado(a, &ult);
    comparar(des, NULL);
    comparar(ult, NULL);
  }

  {
    printf("Verificando arbol de un solo nodo\n");
    Nodo *a= copia(&nxref);
    Nodo *ult;
    Nodo *des= desbalanceado(a, &ult);
    comparar(des, &nxref);
    comparar(ult, &nxref);
    liberar(a); liberar(des);
  }

  {
    printf("Verificando arbol con un nodo raiz y un nodo derecho\n");
    Nodo *a= copia(&nwref);
    Nodo *ult;
    Nodo *des= desbalanceado(a, &ult);
    comparar(des, &nwref);
    comparar(ult, &nxref);
    liberar(a); liberar(des);
  }

  {
    printf("Verificando arbol con un nodo raiz y un nodo izquierdo\n");
    Nodo *a= copia(&nx);
    Nodo *ult;
    Nodo *des= desbalanceado(a, &ult);
    comparar(des, &nwref);
    comparar(ult, &nxref);
    liberar(a); liberar(des);
  }

  {
    printf("Verificando ejemplo del enunciado\n");
    Nodo *a= copia(&nv);
    Nodo *ult;
    Nodo *des= desbalanceado(a, &ult);
    comparar(des, &nsref);
    comparar(ult, &nxref);
    comparar(a, &nv);
    liberar(a); liberar(des);
  }

  printf("\nAhora se verifica desbalancear\n");
  printf(  "------------------------------\n\n");

  {
    printf("Verificando el arbol vacio\n");
    Nodo *a= NULL;
    Nodo *ult;
    desbalancear(&a, &ult);
    comparar(a, NULL);
    comparar(ult, NULL);
  }

  {
    printf("Verificando arbol de un solo nodo\n");
    Nodo *a= copia(&nxref);
    Nodo *ult;
    desbalancear(&a, &ult);
    comparar(a, &nxref);
    comparar(ult, &nxref);
    liberar(a);
  }

  {
    printf("Verificando arbol con un nodo raiz y un nodo derecho\n");
    Nodo *a= copia(&nwref);
    Nodo *ult;
    desbalancear(&a, &ult);
    comparar(a, &nwref);
    comparar(ult, &nxref);
    liberar(a);
  }

  {
    printf("Verificando arbol con un nodo raiz y u nodo izquierdo\n");
    Nodo *a= copia(&nx);
    Nodo *ult;
    desbalancear(&a, &ult);
    comparar(a, &nwref);
    comparar(ult, &nxref);
    liberar(a);
  }

  {
    printf("Verificando ejemplo del enunciado\n");
    Nodo *a= copia(&nv);
    Nodo *ult;
    desbalancear(&a, &ult);
    comparar(a, &nsref);
    comparar(ult, &nxref);
    liberar(a);
  }

  printf("\nTests aprobados\n\n");

  {
    int n= 100000;
    printf("Verificando un arbol de 100 mil nodos\n");
    printf("-------------------------------------\n\n");
    Nodo *a= equilibrado(1, n);
    Nodo *ref= copia(a);
    Nodo *ult;
    Nodo *des= desbalanceado(a, &ult);
    verificar_des(des, n, ult);
    liberar_des(des);
    comparar(a, ref);
    liberar(ref);

    desbalancear(&a, &ult);
    verificar_des(a, n, ult);
    Nodo *b= a;
    while (b!=NULL) {
      int hash= (intptr_t)b;
      if (hash!=b->hash) {
        fprintf(stderr, "La direccion %p cambio\n", (void*)b);
        exit(1);
      }
      b= b->der;
    }
    liberar_des(a);
    printf("Aprobado\n");
  }
}

#ifdef OPT
#define N 20000000
#else
#define N 500000
#endif

typedef struct {
  Nodo *a;
  Nodo *des, *ult;
} Param;

static void init_desbalancear(void *ptr) {
  Param *p= ptr;
  p->a= equilibrado(1, N);
}

static void clean_desbalancear(void *ptr) {
  Param *p= ptr;
  verificar_des(p->des, N, p->ult);
  liberar_des(p->des);
  if (p->a!=NULL)
    liberar(p->a);
}

static void bench_desbalancear(void *ptr) {
  Param *p= ptr;
  desbalancear(&p->a, &p->ult);
  p->des= p->a;
  p->a= NULL;
}

static void bench_desbalanceado(void *ptr) {
  Param *p= ptr;
  p->des= desbalanceado(p->a, &p->ult);
}
  

void benchmark(int refs[], int n) {
  Param p;
  printf("\n");
  printf("=========================\n");
  printf("Benchmark de desbalancear\n");
  printf("=========================\n");
  //        prologo            benchmark           clean up
  run_bench(init_desbalancear, bench_desbalancear, clean_desbalancear,
  //        ptr, tiempo_ref,    tolerancia, nintentos
            &p ,  refs[0]  ,        80    ,    5 );

  printf("\n");
  printf("==========================\n");
  printf("Benchmark de desbalanceado\n");
  printf("==========================\n");
  //        prologo            benchmark            clean up
  run_bench(init_desbalancear, bench_desbalanceado, clean_desbalancear,
  //        ptr, tiempo_ref,    tolerancia, nintentos
            &p ,  refs[1]  ,        80    ,    5 );

}
