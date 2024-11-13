#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "sort.h"

// El arreglo de nombres de personas

void help(int line, int i, int j) {
  printf("Para depurar use este comando para depurar sort-rv-hexamax.s:\n");
  printf("make sort-c-hexamax.ddd\n");
  printf("Para depurar sort-c-hexamax.c use este otro comando:\n");
  printf("make sort-rv-hexamax.ddd\n");
  printf("Ingrese estos comandos en el panel de comandos de ddd:\n");
  printf("break test-sort.c:%d\n", line);
  printf("cond 3 i==%d && j==%d\n", i, j);
  printf("continue\n");
  printf("Abra el panel de assembler seleccionando View -> "
         "Machine Code Window\n");
  printf("Avance con stepi hasta entrar a sort-rv-max.s\n");
  printf("Enseguida depure con stepi para avanzar lentamente\n");
  printf("El arreglo es pequenno, no va a demorarse mucho\n");
  exit(1);
}

#define N 12
int main(int argc, char *argv[]) {
  int refs[]= {
                 0x0,
                 0x1,
                 0x13,
                 0x24521,
                 0x53771628,
                 0x93648200,
                 0xa8765432,
                 0xb0334714,
                 0xc,
                 0xabcdcba,
                 0xe0000000,
                 0x00f00000,
               };

  printf("Multiples tests con arreglos de solo 2 numeros\n");

  for (int i= 0; i<N-1; i++) {
    for (int j= i+1; j<N; j++) {
      uint nums[]={refs[j], refs[i]};
      sort(nums, 2);
      if (nums[0]!=refs[j] || nums[1]!=refs[i]) {
        printf("El ordenamiento falla para el arreglo:\n");
        printf("0x%08x 0x%08x\n", refs[j], refs[i]);
        printf("El resultado fue:\n");
        printf("0x%08x 0x%08x\n", nums[0], nums[1]);
        help(48, i, j);
      }
      uint nums2[]={refs[i], refs[j]};
      sort(nums2, 2);
      if (nums2[0]!=refs[j] || nums2[1]!=refs[i]) {
        printf("El ordenamiento falla para el arreglo:\n");
        printf("0x%08x 0x%08x\n", refs[i], refs[j]);
        printf("El resultado fue:\n");
        printf("0x%08x 0x%08x\n", nums2[0], nums2[1]);
        help(57, i, j);
      }
    }
  }

  printf("Aprobado\n");

  printf("Ahora un arreglo de 12 numeros\n");
  uint nums[]= {
                 0x13,
                 0xabcdcba,
                 0x53771628,
                 0x0,
                 0xa8765432,
                 0x00f00000,
                 0x24521,
                 0x1,
                 0xb0334714,
                 0x93648200,
                 0xc,
                 0xe0000000,
               };


  printf("El arreglo desordenado es:\n");
  printf("--------------------------\n");
  for (int i= 0; i<N; i++) {
    printf("0x%08x\n", nums[i]);
  }
  sort(nums, N);
  printf("\n");
  printf("El arreglo ordenado es:\n");
  printf("-----------------------\n");
  for (int i= 0; i<N; i++) {
    printf("0x%08x\n", nums[i]);
  }
  for (int i= 0; i<N; i++) {
    if (nums[i]!=refs[N-i-1]) {
      fprintf(stderr, "El %d-esimo elemento es incorrecto\n", i);
      exit(1);
    }
  }

  printf("Felicitaciones: todos los tests aprobados\n");
  return 0;
}
