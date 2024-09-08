#include <stdlib.h>
#include <stdio.h>

int posicionBits(int x, int p, int n);

int main(){
    unsigned int x = 0b0001110;
    unsigned int p = 0b111;
    printf("El patron ocurre primero en la posicion 1 y obtenemos que ocurren en la posicion: %d\n",posicionBits(x,p,3));

    p = 0b0;
    printf("El patron ocurre primero en la posicion 0 y obtenemos que ocurren en la posicion: %d\n",posicionBits(x,p,1));

    p = 0b1111;
    printf("El patron ocurre no ocurre y obtenemos que: %d\n",posicionBits(x,p,4));

    unsigned int a = 0b011;
    printf("El patron ocurre primero en la posicion 2 y obtenemos que ocurren en la posicion: %d\n",posicionBits(x,a,3));
}

int posicionBits(int x, int p, int n) {
	// x: 11001010 &
	// p: 0001
	// n: 4
	// ex: 10000000000000000000000000000000000000000000
	// 000000000000000000000000000000000000000000000001
	// m: 00000110 : 6
	// res:0000010 
	unsigned m = -1;
	int mask = ~(m << n);
	for(unsigned long i = 0; i < sizeof(x)*8 - n + 1;i++){
		if (((x >> i) & mask) == p){
			return i; 
		}
	}
	return -1;
	// x: 00000000000000000000011001010 &
	// x: 00000000000000000000000100100 &
	// 00000000000000000000000000001111
	// 00000000000000000000000000001001
}
