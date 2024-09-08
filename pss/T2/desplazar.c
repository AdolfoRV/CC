#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "desplazar.h"

void desplazar(char *str, int from, int nbytes, int by) {
  char *s = str + from; // nos posicionamos al fondo de los nbytes (si by es positivo)
  if (by >= 0) {
    s += nbytes - 1;
  }

  int str_length = strlen(str);
  int positive_index = (from + nbytes - 1) + by;
  int negative_index = (from) + by;

  char *ptr = s + by; 
  for (int i = 0; i < nbytes; i++) {

    if (by >= 0) {
      if (positive_index - i < str_length) {
      *ptr = *s;
      }
      s--;
      ptr--;
    } else {
      if (negative_index + i >= 0) {
        *ptr = *s; 
      }
      s++;
      ptr++;
    }

  }

}

char *desplazamiento(char *str, int from, int nbytes, int by) {
  char *copy = malloc(strlen(str)+1); // since we're dealing with char, it's redundant to place a sizeof(char)
  strcpy(copy, str);
  desplazar(copy, from, nbytes, by);
  return copy;
}

// int main() {
//   char a[] = "01";
//   char b[] = "01";
//   desplazar(a, 0, 1, 0);
//   desplazar(b, 0, 1, 1);
//   printf("%s\n", a);
//   printf("%s\n", b);
// }