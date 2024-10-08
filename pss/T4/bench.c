#define _XOPEN_SOURCE 500

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/time.h>
#include <string.h>

#define TOLERANCIA 80

// ----------------------------------------------------
// Funcion que entrega el tiempo transcurrido desde el lanzamiento del
// programa en milisegundos

static int time0= 0;

static int getTime0() {
    struct timeval Timeval;
    gettimeofday(&Timeval, NULL);
    return Timeval.tv_sec*1000+Timeval.tv_usec/1000;
}

static void resetTime() {
  time0= getTime0();
}

static int getTime() {
  return getTime0()-time0;
}

// ----------------------------------------------------
// Funciones para crear un diccionario grande

#define TAM 10
#define NTESTS 10000

int igual_llaves_alum = 0;
int igual_llaves_test = 0;

typedef struct {
  int izq, der;
  short tam_llave, tam_valor;
  char llave[TAM], valor[TAM];
} NodoArch;

void i2str(int k, char *res) {
  char buf[20];
  sprintf(buf, "%d", k);
  int len= strlen(buf);
  int i= 0;
  while (i<TAM-len) {
     res[i]= '0';
     i++;
  }
  strncpy(&res[i], buf, len);
}

// ----------------------------------------------------
// Benchmark

int bench(char *binary, char *dicc, char llaves[NTESTS][20], short *exists) {
    srandom(100);
    igual_llaves_alum = 0;
    int ini= getTime();
    for (int i= 0; i<NTESTS; i++) {
        char cmd[100], valor[20];
        int k= random()%NTESTS;
        i2str(k, valor);
        valor[TAM]=0;
        sprintf(cmd, "%s %s %s %s\n", binary, dicc, llaves[i], valor);
        int rc= system(cmd);
        if ((exists[i] != 1 && rc != 0) || (exists[i] == 1 && rc == 0)) {
            fprintf(stderr, "Codigo de retorno %d es incorrecto\n", rc);
            exit(1);
        }
        if(rc != 0) {
            igual_llaves_alum++;
        }
    }
    return getTime()-ini;
}

int main(int argc, char **argv) {
    printf("\n--------------------------------------------------\n");
    printf("Test de eficiencia\n\n");
    if (argc!=3) {
        fprintf(stderr, "uso: ./bench <bin-prof> <bin>\n");
        exit(1);
    }
    FILE *dicc_prof = fopen("big_prof.dicc", "r+");
    FILE *dicc_alum = fopen("big_alum.dicc", "r+");
    if (dicc_prof==NULL) {
        perror("big_prof.dicc");
        exit(1);
    }
    if(dicc_alum == NULL){
        perror("big_alum.dicc");
        exit(1);
    }
    printf("Construyendo diccionario de %d definiciones\n", NTESTS);

    char *bin_prof= argv[1];
    char *bin= argv[2];
    char llaves[NTESTS][20];
    short exists[NTESTS];
    for (int i= 0; i<NTESTS; i++) {
        int k1= random()%NTESTS;
        i2str(k1, llaves[i]);
        llaves[i][TAM]=0;
        exists[i] = 0;
        for (int j = 0; j<i; j++) {
          if (strcmp(llaves[j], llaves[i]) == 0) {
            exists[i] = 1;
            igual_llaves_test++;
            break;
          }
        }
    }

    int intento= 1;
    while (intento<=5) {
        printf("Intento= %d\n", intento);
        printf("Midiendo tiempo del binario del profesor con %d busquedas\n",
               NTESTS);
        int tiempo_prof= bench(bin_prof, "big_prof.dicc", llaves, exists);
        printf("Tiempo= %d milisegundos\n", tiempo_prof);
        printf("Midiendo tiempo de su solucion con %d busquedas\n", NTESTS);
        int tiempo= bench(bin, "big_alum.dicc", llaves, exists);
        printf("Tiempo= %d milisegundos\n", tiempo);
        double q= (double)tiempo/(double)tiempo_prof;
        int porciento= (q-1.)*100;
        printf("Porcentaje de sobrecosto: %d %%\n", porciento);
        if (porciento<=TOLERANCIA)
            break;
        printf("Excede en mas del %d %% la version del profesor\n", TOLERANCIA);
        if (intento<5)
            printf("Se hara un nuevo intento\n");
        intento++;
    }
    if (intento>5) {
      fprintf(stderr, "Lo siento: Despues de 5 intentos no satisface "
                      "la eficiencia requerida.\n");
      fprintf(stderr,
              "Si esta leyendo el archivo completo no aprobara este test.\n"
              "Coloque su computador en modo alto rendimiento, porque el\n"
              "economizador de bateria puede alterar los resultados.\n"
              "No ejecute este programa junto a otros programas que hagan\n"
              "un uso intensivo de la CPU.  En windows puede lanzar el\n"
              "administrador de tareas para verificar que el uso de CPU\n"
              "sea bajo.\n");
      exit(1);
    }
    
    if (igual_llaves_alum != igual_llaves_test) {
        printf("Inconsistencia en llaves existentes a agregar en diccionario. Total test: %d, total de su solucion: %d\n", igual_llaves_test, igual_llaves_alum);
        exit(1);
    }
    printf("Felicitaciones: Aprobo el test de eficiencia\n");
    
    return 0;
}
