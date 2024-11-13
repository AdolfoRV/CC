#include <stdio.h>
#include <string.h>

void comprimir(char *s) {
    int largo = strlen(s);
    int si = 0, di = 0;  // si: índice de lectura, di: índice de escritura

    while (si < largo) {
        char letra = s[si];
        int cont = 1;

        // Contar cuántas veces se repite la letra
        while (si + 1 < largo && s[si] == s[si + 1]) {
            cont++;
            si++;
        }

        // Escribir la letra en la posición de destino
        s[di++] = letra;

        // Si se repite más de una vez, escribir el número de repeticiones
        if (cont > 1) {
            di += sprintf(&s[di], "%d", cont);
        }

        si++;
    }

    // Asegurarse de que la cadena esté terminada correctamente
    s[di] = '\0';
}

int main() {
    char cadena[] = "aaabbbbcc";
    comprimir(cadena);
    printf("Cadena comprimida: %s\n", cadena);
    return 0;
}