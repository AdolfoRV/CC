#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#include "test-util.h"
#include "palin.h"

#ifdef OPT
#define REPS 20000
#else
#define REPS 10
#endif

#define TAM 10000
#define NINTENTOS 5
#define TOLERANCIA 80

void test_unitario(void) {
  CHECK_I32(palindrome(0x00000000), 1);
  CHECK_I32(palindrome(0x00000001), 0);
  CHECK_I32(palindrome(0x10000000), 0);
  CHECK_I32(palindrome(0x12344321), 1);
  CHECK_I32(palindrome(0x02344321), 0);
  CHECK_I32(palindrome(0x10344321), 0);
  CHECK_I32(palindrome(0x12044321), 0);
  CHECK_I32(palindrome(0x12304321), 0);
  CHECK_I32(palindrome(0x3a0ff0a3), 1);
  CHECK_I32(palindrome(0x3a0ff0a4), 0);
  CHECK_I32(palindrome(0x3a0fe0b3), 0);
  CHECK_I32(palindrome(0x11), 0);
}

static void bench_palin(void *ptr) {
  uint32_t *nums= ptr;
  for (int k= 0; k<REPS; k++) {
    int cnt= 0;
    for (int i= 0; i<TAM; i++)
      cnt += palindrome(nums[i]);
    check_i32(cnt, TAM, "Contador de palindromes");
    cnt= 0;
    for (int i= 0; i<TAM; i++)
      cnt += palindrome(nums[i]+2);
    check_i32(cnt, 0, "Contador 1 de no palindromes");
    cnt= 0;
    for (int i= 0; i<TAM; i++)
      cnt += palindrome(nums[i]+0x2000);
    check_i32(cnt, 0, "Contador 2 de no palindromes");
  }
}

void benchmark(int refs[], int n) {
  if (refs!=NULL && n!=1) {
    fprintf(stderr, "El numero de tests debe ser 1\n");
    exit(1);
  }

  uint32_t *nums= malloc(TAM*sizeof(uint32_t));
  int i= 0;
  while (i<TAM) {
    uint32_t pal= randNum()&0xffff;
    pal+= ((pal&0xf)<<28)+((pal&0xf0)<<20)+((pal&0xf00)<<12)+((pal&0xf000)<<4);
    CHECK_I32(palindrome(pal), 1);
    CHECK_I32(palindrome(pal+2), 0);
    CHECK_I32(palindrome(pal+0x2000), 0);
    nums[i++]= pal;
  }
  //        fun,         ptr,  tiempo_ref,                tolerancia, nintentos
  run_bench(bench_palin, nums, refs!=NULL ? refs[0] : -1, 80,         5);
  free(nums);
}
