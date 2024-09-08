#include <stdio.h>
#include <string.h>

void to_lower(char *s);
void to_upper(char *s);

int main(int argc, char **argv) {
  if (argc != 2) {
    printf("uso: %s <palabra>\n", argv[0]);
    printf("ej: %s 'Hola Mundo!'\n", argv[0]);
    return -1;
  }
  char *test = argv[1];
  to_lower(test);
  printf("to lower: %s\n", test);
  to_upper(test);
  printf("to upper: %s\n", test);
}

void to_lower(char *s) {
  while (*s) { // lo mismo que s != '\0', es decir, mientras no se termine el
               // string
    if (*s >= 'A' &&
        *s <=
            'Z') // nos aprovechamos que en ASCII el abecedario esta todo junto
      *s += 'a' - 'A'; // 'A' - 'a' seria el offset o la distancia entre las
                       // minus y las mayus en ASCII
    s++;
  }
}

void to_upper(char *s) {
  // igual a la anterior pero cambiamos la condiciones y restamos el offset
  while (*s) {
    if (*s >= 'a' && *s <= 'z')
      *s -= 'a' - 'A';
    s++;
  }
}
