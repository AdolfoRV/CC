#include <stdio.h>
#include <string.h>

char mas_repetido(char *s);

int main(int argc, char **argv) {
  // ejemplos
  // mas_repetido("aaabbbb") = "b"
  // mas_repetido("abbcccc") = "c"
  // mas_repetido("aaabbcd") = "a"
  // mas_repetido("anitalavalatina") = "a"
  
  if (argc != 2) {
    printf("uso: %s <palabra>\n", argv[0]);
    printf("ej: %s aaabbbb\n", argv[0]);
    return -1;
  }

  char *pal = argv[1];
  printf("El caracter mas repetido en %s es '%c'\n", pal, mas_repetido(pal));
}

char mas_repetido(char *s) {
  // un char es un int de 8 bits (1 byte) por lo que podemos usar un arreglo de
  // 256 posiciones
  int chars[256] = {0};

  // guardamos la cantidad de veces que aparece cada caracter usando el char
  // como indice
  while (*s) {
    chars[(int)*s]++;
    s++;
  }

  // buscamos el caracter con mas apariciones
  int max = 0;
  char max_char = 0;
  for (int i = 0; i < 256; i++) {
    if (chars[i] > max) {
      max = chars[i];
      max_char = (char)i;
    }
  }

  return max_char;
}
