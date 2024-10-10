#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define TAM_MAX 255

typedef struct {
  int izq, der;
  short tam_llave, tam_valor;
} NodoArch;

// para no ser tan redundantes y ahorrar un poco de code
void escribir_nuevo_nodo(const char *llave, const char *valor, FILE *dicc) {
  NodoArch nuevo_nodo;
  size_t largo_llave = strlen(llave);
  size_t largo_valor = strlen(valor);
  
  nuevo_nodo.izq = -1;
  nuevo_nodo.der = -1;
  nuevo_nodo.tam_llave = largo_llave;
  nuevo_nodo.tam_valor = largo_valor;

  fwrite(&nuevo_nodo, sizeof(nuevo_nodo), 1, dicc);
  fwrite(llave, largo_llave, 1, dicc);
  fwrite(valor, largo_valor, 1, dicc);
}

// lo hice de manera recursiva porque todo en el main con un while(1) era tedioso
void insertar(FILE *dicc, const char *llave, const char *valor, long int pos) {
  NodoArch nodoa;
  fseek(dicc, pos, SEEK_SET);
  int rc = fread(&nodoa, sizeof(NodoArch), 1, dicc);

  if (rc <= 0) {
    // Caso base: no hay nada y toca insertar
    fseek(dicc, 0, SEEK_END);
    escribir_nuevo_nodo(llave, valor, dicc);
    return;
  }

  char *llave_actual = malloc(nodoa.tam_llave + 1);
  rc = fread(llave_actual, nodoa.tam_llave, 1, dicc);
  if (rc <= 0) {
    fprintf(stderr, "No se puede leer llave de nodo en posicion %ld\n", pos);
    exit(1);
  }
  llave_actual[nodoa.tam_llave] = '\0';

  if (strcmp(llave, llave_actual) == 0) {
    fprintf(stderr, "Llave existente: no se puede modificar la llave %s\n", llave);
    free(llave_actual);
    exit(1);
  }

  long int pos_nodo = pos;

  if (strcmp(llave, llave_actual) < 0) {
    if (nodoa.izq == -1) {
      // insertamos en la hoja izquierda del nodo actual
      fseek(dicc, 0, SEEK_END);
      long int nueva_pos = ftell(dicc);
      escribir_nuevo_nodo(llave, valor, dicc);
      nodoa.izq = nueva_pos;
      
      // volvemos para escribir la redirección de a dónde apunta el nodo actual pero en el archivo
      fseek(dicc, pos_nodo, SEEK_SET);
      fwrite(&nodoa, sizeof(NodoArch), 1, dicc);
    } else {
      insertar(dicc, llave, valor, nodoa.izq);
    }
  } else {
    if (nodoa.der == -1) {
      fseek(dicc, 0, SEEK_END);
      long int nueva_pos = ftell(dicc);
      escribir_nuevo_nodo(llave, valor, dicc);
      nodoa.der = nueva_pos;
      fseek(dicc, pos_nodo, SEEK_SET);
      fwrite(&nodoa, sizeof(NodoArch), 1, dicc);
    } else {
      insertar(dicc, llave, valor, nodoa.der);
    }
  }
  free(llave_actual);
}

int main(int argc, char **argv) {
  if (argc != 4) {
    fprintf(stderr, "uso: ./definir <archivo> <llave> <definicion>\n");
    return 1;
  }

  const char *archivo = argv[1];
  const char *llave = argv[2];
  const char *valor = argv[3];

  FILE *dicc = fopen(archivo, "r+");
  if (!dicc) {
    perror(archivo);
    exit(1);
  }
  insertar(dicc, llave, valor, 0);

  fclose(dicc);
  return 0;
}