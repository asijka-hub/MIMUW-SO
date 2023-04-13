//
// Created by Andrzej on 13.04.2023.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint64_t core(uint64_t n, char const *p);

int main() {
    char p[] = {"123459"};

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

    return 0;
}
