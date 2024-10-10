#include "stdio.h"  //printf
#include "string.h"

int main() {
  printf("Hola mundo\n");
  FILE *f = fopen("dict ej.txt", "r+");
  char c = (char )fgetc(f);
  printf("%c", c);
  c = (char )fgetc(f);
  printf("%c", c);
  c = (char )fgetc(f);
  printf("%c", c);
  c = (char )fgetc(f);
  printf("%c\n", c);
  char s[128];
  fgets(s, 128, f);
  printf("%s\n", s);
  fgets(s, 128, f);
  printf("%s\n", s);
  char buffer[49];
  printf("bytes leidos: %ld\n", fread(buffer, 1, 48, f));
  buffer[48] = '\0';
  printf("%s\n", buffer);
  char buffer2[] = "antidoto proteccion para el veneno         :";
  printf("bytes escritos: %ld\n", fwrite(buffer2, 1, strlen(buffer2), f));
  printf("feof: %d\n", feof(f));
  printf("bytes leidos: %ld\n", fread(buffer, 1, 24, f));
  buffer[48] = '\0';
  printf("%s\n", buffer);
  printf("feof: %d\n", feof(f));
  fclose(f);
  //FILE *out = fopen("out.txt", "w");
  fprintf(stdout, "el buffer leyo %s\n", buffer);
  return 0;
}
