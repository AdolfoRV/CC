#include <stdio.h>
#include <stdint.h>

#include "palin.h"

int palindrome(uint32_t x) {
  // uint32_t x = 438583969;
  // printf("Su número es 0x%08x\n", x);
  for (int i = 0; i < 4; i++) {
    uint32_t izq = x>>(4*(7-i));
    uint32_t der = x>>(i*4);
    izq = (izq & 0xf);  // el equivalente binario 0b1111 funciona usando debuggiando pero no con make
    der = (der & 0xf);  // Utilizamos el neutro del & en 4-bits porque al tratarse de un digito hexadecimal este para ser representado necesita 4 bits (2^4=16), así el resto de digitos se ven absorbidos por los 0
    
    if (izq != der) {
      return 0;
    }
  }
  return 1;
}