#include "types.h"

#define NPROC 64 // maximum number of processes

enum procstate
{
  UNUSED = 1,
  USED,
  SLEEPING,
  RUNNABLE,
  RUNNING,
  ZOMBIE
};

struct proc_info
{
  char name[16];
  int pid;
  int ppid;
  int time;
  int timeElapsed;
  enum procstate state;
  uint64 size;
};

struct top
{
  long uptime;
  int total_process;
  int running_process;
  int sleeping_process;
  struct proc_info p_list[NPROC];
  uint64 total_mem;
  uint64 free_mem;
};