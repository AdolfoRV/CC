#include <stdlib.h>
#include <stdio.h>


int bits1(int n);

int main(int argc, char** argv) {
    int n = atoi(argv[1]);
    printf("%d\n", bits1(n));
}

int bits1(int n) {
	// 000000000000000000000000000000000 -> 0  // 0
	// 000000000000000000000000000000001 -> 1  // 1
	// 000000000000000000000000000000010 -> 1| // 2
	// 000000000000000000000001010101010 -> 5  //682
	int total = 0;
	// 10101010100100110 >>
	// 01010101010010011
	// 00101010101001001
	// 00000000000000001
	// sizeof(int): BYTES que definen a un integer
	for (unsigned int i = 0; i < sizeof(n)*8; i++){
		if (((n>>i) & 1) == 1){
			total++;
		}
	} 
	return total;
}
