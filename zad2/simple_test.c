//
// Created by Andrzej on 13.04.2023.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

#define N 2

uint64_t core(uint64_t n, char const *p);

uint64_t get_value(uint64_t n) {
//    assert(n < N);
    return n + 1;
}

// Tę funkcję woła rdzeń.
void put_value(uint64_t n, uint64_t v) {
    assert(n + v == 12);
 //   assert(v == n + 4);
}

int main() {
    char p[] = {"12"};

    int res = core(0, p);

    printf("res: %d\n", res);

    char p1[] = {"48+9+"};

    int res1 = core(0, p1);

    printf("res1: %d\n", res1);

    char p2[] = {"68*"};

    int res2 = core(0, p2);

    printf("res2: %d\n", res2);

    char p3[] = {"9-"};

    int res3 = core(0, p3);

    printf("res3: %d\n", res3);


    char p4[] = {"n"};

    int res4 = core(13, p4);

    printf("res4: %d\n", res4);


    char p5[] = {"89DC"};

    int res5 = core(13, p5);

    printf("res5: %d\n", res5);

    char p6[] = {"12E"};

    int res6 = core(13, p6);

    printf("res6: %d\n", res6);

    char p7[] = {"122+B1234+"};

    int res7 = core(13, p7);

    printf("res7: %d\n", res7);

    char p8[] = {"6G"};

    int res8 = core(7, p8);

    printf("res8: %d\n", res8);

    return 0;
}
