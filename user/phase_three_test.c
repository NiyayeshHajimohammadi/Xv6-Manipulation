#include "kernel/types.h"
#include "user/user.h"

#define PHYSTOP (128*1024*1024)
#define PAGESIZE 4096

int main(void) {
  int i;
  int pages = (PHYSTOP/PAGESIZE)*2/3;
  char *mem;

  printf("Allocating %d pages of memory\n", pages);

  // Allocate memory using sbrk
  mem = sbrk(pages * PAGESIZE);
  if (mem == (char *)-1) {
    printf("sbrk failed\n");
    exit(1);
  }

  // Initialize allocated memory to make sure it's mapped
  for (i = 0; i < pages * PAGESIZE; i += PAGESIZE) {
    mem[i] = 1;
  }

  printf("Memory allocated and initialized, forking...\n");

  int pid = fork();
  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  } else if (pid == 0) {
    // Child process
    printf("Child process\n");
    // Verify that the memory is accessible
    for (i = 0; i < pages * PAGESIZE; i += PAGESIZE) {
      if (mem[i] != 1) {
        printf("Memory verification failed at page %d\n", i / PAGESIZE);
        exit(1);
      }
    }
    printf("Memory verification succeeded in child process\n");
    exit(0);
  } else {
    // Parent process
    wait(0);
    printf("Parent process\n");
    printf("fork succeeded\n");
  }

  exit(0);
}
