#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

int cnt = 0; 

void receive(int numer) {
  cnt++;
  printf("Received signal %i\n", cnt);
}

int main() {
    int status;
    signal(SIGUSR1, receive);
    if (fork() == 0) {
        for (int i = 1; i <= 100; i++) {
            kill(getppid(), SIGUSR1);
            printf("Sent signal %i\n", i);
        }
        exit(1);
    }
    else {
        wait(&status);
    }
}