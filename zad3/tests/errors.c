#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <assert.h>

int main() {

    int A_pid = getpid();

    int wrong_pid = getpid() + 20; // prob will be unactive

    errno = 0;
    assert(transfermoney(wrong_pid, 1) == -1);
    assert(errno == ESRCH);

    errno = 0;
    assert(transfermoney(A_pid, -69) == -1);
    assert(errno == EINVAL);

    int B_pid = fork();

    if (B_pid == 0) {
        // B

    } else {
        // father
        errno = 0;
        assert(transfermoney(B_pid, 69) == -1);
        assert(errno == EPERM);

        int C_pid = fork();

        if (C_pid == 0) {
            // C
            errno = 0;
            assert(transfermoney(B_pid, 101) == -1);
            assert(errno == EPERM);

            errno = 0;
            assert(transfermoney(B_pid, 901) == -1);
            assert(errno == EPERM);

            errno = 0;
            assert(transfermoney(B_pid), 10) == 90);
            assert(errno == 0);

            printf("errors test OK\n");
        } else {
            // father
        }
    }
}

