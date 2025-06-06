#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "prod.h"

BigNum *parArrayProd(int a[], int i, int j, int p) {
    if (p == 1) {
        return seqArrayProd(a, i, j);
    }

    if (i == j) {
        return smallNum(a[i]);
    }

    int h = (i + j) / 2;
    int fds[2];

    if (pipe(fds) == -1) {
        perror("Error al crear el pipe");
        exit(EXIT_FAILURE);
    }

    pid_t pid = fork();

    if (pid == -1) {
        perror("Error al crear el proceso");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) { // Proceso hijo
        close(fds[0]);

        BigNum *left = parArrayProd(a, i, h, p / 2);

        if (write(fds[1], &left->n, sizeof(int)) != sizeof(int)) {
            perror("Error al escribir tamaño del BigNum");
            exit(EXIT_FAILURE);
        }

        if (write(fds[1], left->bits, left->n * sizeof(BigInt_t)) != left->n * sizeof(BigInt_t)) {
            perror("Error al escribir datos del BigNum");
            exit(EXIT_FAILURE);
        }

        freeBigNum(left);
        close(fds[1]);
        exit(EXIT_SUCCESS);
    } else { // Proceso padre
        close(fds[1]);

        BigNum *right = parArrayProd(a, h + 1, j, p - p / 2);

        BigNum *left = malloc(sizeof(BigNum));
        if (leer(fds[0], &left->n, sizeof(int)) != 0) {
            perror("Error al leer tamaño del BigNum");
            exit(EXIT_FAILURE);
        }

        left->bits = malloc(left->n * sizeof(BigInt_t));
        if (leer(fds[0], left->bits, left->n * sizeof(BigInt_t)) != 0) {
            perror("Error al leer datos del BigNum");
            exit(EXIT_FAILURE);
        }

        close(fds[0]);
        wait(NULL);

        BigNum *prod = bigMul(left, right);

        freeBigNum(left);
        freeBigNum(right);

        return prod;
    }
}


//BigNum *parArrayProd(int a[], int i, int j, int p) {
  // Programe aca una version paralela del producto de los enteros
  // de un arreglo desde los indices i al j, usando p procesos pesados.

  // Este es un problema similar al quicksort paralelo visto en catedra
  // y en los apuntes: https://wiki.dcc.uchile.cl/cc3301/procesos#pipes

  // La solucion es trivial si i==j

  // Para el caso en que p es 1, debe llamar a la funcion seqArrayProd
  // implementada en test-prod.c (es obligatorio)

  // Si no, paralelice el problema creando un proceso pesado que se encargue
  // de calcular en paralelo el producto de i hasta h usando p/2 procesos
  // pesados.  El padre calcula recursivamente el producto
  // de h+1 hasta j usando p-p/2 procesos pesados (recuerda la pregunta
  // 5 del control?).

  // El hijo necesitara enviar su resultado en formato binario al padre
  // a traves de un pipe.  Si en el hijo b es de tipo BigNum*, envielo
  // al padre a traves fds[1] con:
  //     write(fds[1], &b->n, sizeof(int));
  //     write(fds[1], b->bits, b->n*sizeof(BigInt_t));
  // y recibalo en el padre del pipe fds[0] con:
  //     BigNum *b= malloc(sizeof(BigNum));
  //     leer(fds[0], &b->n, sizeof(int));
  //     b->bits= malloc(b->n*sizeof(BigInt_t));
  //     leer(fds[0], b->bits, b->n*sizeof(BigInt_t));

  // Esto compila y pasa make run-valgrind, pero no pasa run-O ni run-g
  //return seqArrayProd(a, i, j);
//}

// El valor del producto puede exceder el limite de representacion
// de los enteros y reales de C.  Asi es que se usan enteros de tamano
// ilimitado representados por el tipo BigNum.  Las operaciones que Ud.
// puede realizar con un BigNum aparecen en prod.h.
// Este es el codigo de seqArrayProd:
//
// BigNum *seqArrayProd(int a[], int i, int j) {
//   if (i>j) {
//     fprintf(stderr, "Asercion fallida: i > j\n");
//     exit(1);
//   }
//   if (i==j) {
//     return smallNum(a[i]); // Convierte un entero de C a BigNum
//   }
//   else {
//     int h= (i+j)/2;
//     BigNum *left= seqArrayProd(a, i, h);
//     BigNum *right= seqArrayProd(a, h+1, j);
//     BigNum *prod= bigMul(left, right); // Multiplicacion de BigNum's
//     freeBigNum(left); // Hay que liberar la memoria ocupada por los BigNum's
//     freeBigNum(right);
//     return prod;
//   }
// }

// Preguntas que Ud. podria formular:

// + Por que se usa divide y conquista en vez de programar la version iterativa
//   tipica?
//   Porque esta version resulta mas eficiente.  Compile con make -B test-prod
//   y ejecute con time ./test-prod 3000.  Muestra el tiempo que demora
//   calcular el factorial de 3000.
//   Luego experimente cambiando el #if 1 de la funcion main en test-prod.c
//   por #if 0 para usar la version iterativa usual.
//   Recompile y rejecute.  Vera que se demora bastante mas.

// + Por que en la funcion fastBigFact se permutan los elementos del arreglo
//   suministrado a parArrayProd?
//   Porque esto hace que el tamano de los resultados de las multiplicaciones
//   que se hacen al mismo nivel de recursividad sea balanceado,
//   es decir sean similares en tamaño.  Si el arreglo fuese 1, 2, 3, etc.,
//   El resultado de la multiplicacion de la primera mitad del arreglo seria
//   mucho mucho menor que el de la segunda mitad.  De hecho sin
//   esta permutacion, el algoritmo recursivo que realiza la multiplicacion
//   se cae por stack overflow con el factorial de 100000
//   Experimente cambiando el #if 1 de fastBigFact por #if 0 para suprimir
//   la permutacion.  Ejecute: time test-prod 20000 > res.txt
//   para cada opcion y compare.

// + Por que se usa el algoritmo de Karatsuba para multiplicar?
//   Ver: https://en.wikipedia.org/wiki/Karatsuba_algorithm
//   Tambien inclui el algoritmo clasico en test-prod.c.
//   Karatsuba es mas rapido con numeros muy muy grandes, pero con numeros
//   pequenos, el algoritmo clasico puede ganar.  En todo caso Karatsuba
//   es mas rapido para calcular el factorial de 700000 que se usa como
//   benchmark en esta tarea.
//   Experimente cambiando el #if 1 cercano  a la funcion bigMul
//   en test-prod.c por #if 0 para usar el algoritmo clasico.
//   Inclui el calculo del factorial escrito en java.  Ejecute:
//   java fact 700000 > res.txt
//   Es terriblemente rapido.  Claramente usa un mejor algoritmo.
//   Pero para efectos de la paralelizacion de esta tarea, el algoritmo
//   especifico que se use para la multiplicacion es irrelevante.

//   La implementacion de Karatsuba la baje de:
//     https://github.com/ilia3101/Big-Integer-C
//   No garantizo que sea una buena implementacion de Karatsuba
//   De hecho tuve que resolver un bug en BigInt_truncate para que
//   funcionara correctamente.

// + Por que el speed up es solo ~ 1.4 y no se acerca a 4 cuando se usan
//   4 cores?
//   No todos los algoritmos se paralelizan bien.  El problema es el mismo
//   de quicksort: despues de calcular en paralelo el producto de las
//   2 mitades del intervalo, todavia queda multiplicar ambos resultados.
//   Esa multiplicacion se hace secuencialmente y produce un resultado que
//   es el doble en tamano que cualquier otro resultado hasta ese momento.
//   Especulo que se podria obtener un mejor speed up si se paraleliza
//   la multiplicacion de 2 numeros, en vez del producto del arreglo completo.
