#include <stdio.h>
#include <string.h>

void reverse(char *s);

int main(int argc, char **argv) {
  // ejemplos
  // reverse("anitalavalatina") = "anitalavalatina"
  // reverse("abcba") = "abcba"
  // reverse("Hola mundo!") = "!odnum aloH"
  // reverse("a") = "a"
  if (argc != 2) {
    printf("uso: %s <palabra>\n", argv[0]);
    printf("ej: %s abcba\n", argv[0]);
    return -1;
  }
  char *pal = argv[1];
  printf("%s al reves es ", pal);
  reverse(pal);
  printf("%s\n", pal);
}

void reverse(char *s) {
  // similar a palindromo
  char *final = s + strlen(s) - 1; // puntero al final del string
  while (s < final) { // mientras no nos pasemos del medio del string
    // hacemos swap de los caracteres del principio y del final
    char temp = *s; // guardamos el caracter del principio
    *s = *final;    // ponemos el caracter del final en el principio
    *final = temp;  // ponemos el caracter del principio en el final
    s++;
    final--;
  }
}
