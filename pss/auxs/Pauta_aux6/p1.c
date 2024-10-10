#include "stdio.h"
#include "string.h"

void modificar(char *nom_dic, char *palabra, char *def, int n_lin, int ancho) {
    FILE *f = fopen(nom_dic, "r+"); //abrimos el archivo en lectura y escritura
    char buf[ancho+1];
    while(fread(buf, 1, ancho, f) > 0 && n_lin){ // leemos una linea de ancho definido y lo guardamos en buf
        char *c = buf;
        n_lin--;
        while (*c != ':'){ // modificamos el buf para destacar la palabra de la línea.
            c++;
        }
        *c = '\0';
        if (strcmp(palabra, buf) == 0) { // comparamos palabras
            // si son iguales, entonces cambiamos la definición.
            fseek(f, -ancho+strlen(palabra)+1, SEEK_CUR); // movemos el cursor al inicio de la definición.
            fputs(def, f);
            while(fgetc(f) != ':'){ // limpiamos el resto de la definición.
                fseek(f, -1, SEEK_CUR);
                fputc(' ', f);
            }
        }
    }
}

int main() {
    modificar("dict.txt", "tranquilo", "contrario a inquieto", 10, 48);
    return 0;
}
