#include <stdio.h>
#include <string.h> // en este header estan las principales funciones para trabajar con strings

int palindromo(char *s);

int main(int argc, char **argv) {
  // ejemplos
  // palindromo("anitalavalatina") = 1
  // palindromo("abcba") = 1
  // palindromo("abc") = 0
  if (argc != 2) {
    printf("uso: %s <palabra>\n", argv[0]);
    printf("ej: %s anitalavalatina\n", argv[0]);
    return -1;
  }

  char *pal = argv[1];
  int ans = palindromo(pal);
  if (ans)
    printf("%s es palindromo\n", pal);
  else
    printf("%s no es palindromo\n", pal);
}

int palindromo(char *s) {
  char *final =
      s + strlen(s) - 1; // usamos strlen para obtener el largo del string y con
                         // eso podemos obtener un puntero al ultimo caracter
  while (s < final) {    // mientras no nos pasemos del medio del string
    if (*s != *final)    // si los caracteres son distintos, no es palindromo
      return 0;
    s++;
    final--;
  }
  return 1; // si llegamos hasta aca, es palindromo
}
