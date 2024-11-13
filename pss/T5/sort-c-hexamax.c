#include <string.h>
#include <stdio.h>

void sort(unsigned int *nums, int n) {
  unsigned int *ult= &nums[n-1];
  unsigned int *p= nums;
  while (p<ult) {
    // No modifique nada arriba de esta linea
    // Inicio de la parte que debe cambiar
    unsigned int a0 = p[0];                     // num actual
    unsigned int a1 = p[1];                     // num siguiente al actual
    unsigned int t2 = 0;                        // la cifra max del num actual
    unsigned int t3 = 0;                        // la cifra max del num siguiente al actual
    unsigned int cifra = 0;
    
    do {
      cifra = a0 & 15;
      a0 = a0 >> 4;
      if (cifra >= t2) {
        t2 = cifra;
      }
    } while (a0 != 0);

    do {
      cifra = a1 & 15;
      a1 = a1 >> 4;
      if (cifra >= t3) {
        t3 = cifra;
      }
    } while (a1 != 0);

    int t1 = t2>=t3 ? 0 : 1;

    // Fin de la parte que debe cambiar
    // No Cambie nada mas a partir de aca
    if (t1 <= 0)
      p++;
    else {
      unsigned int tmp= p[0];
      p[0]= p[1];
      p[1]= tmp;
      p= nums;
    }
  }
}

// int main() {
//     unsigned int nums[]= {
//                  0x13,
//                  0xabcdcba,
//                  0x53771628,
//                  0x0,
//                  0xa8765432,
//                  0x00f00000,
//                  0x24521,
//                  0x1,
//                  0xb0334714,
//                  0x93648200,
//                  0xc,
//                  0xe0000000,
//                };
//   sort(nums, 12);
//   for (int i= 0; i<12; i++) {
//     printf("0x%08x\n", nums[i]);
//   }
//   return 0;
// }