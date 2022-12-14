#include <stdio.h>
#include <signal.h>

int main() {
    if (kill(1, SIGKILL) == SIG_ERR)
        printf("error");
}
