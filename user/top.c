#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/top.h"

#define NELEM(x) (sizeof(x) / sizeof((x)[0]))
#define gotoxy(x, y) printf("\033[%d;%dH", (y), (x))

int main(int argc, char *argv[])
{
  static char *states[] = {
      [UNUSED] "unused",
      [USED] "used",
      [SLEEPING] "sleep ",
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  while (1)
  {
    for (int i = 0; i < 31; i++)
    {
      gotoxy(1, i);
      printf("\33[2K\r");
    }

    gotoxy(0, 0);
    char *state;
    struct top topStruct;
    top(&topStruct);
    printf("Uptime= %d\n", topStruct.uptime / 10);
    printf("Total Process: %d\n", topStruct.total_process);
    printf("Running Process: %d\n", topStruct.running_process);
    printf("Sleeping Process: %d\n", topStruct.sleeping_process);
    printf("Total Memory: %d\n",topStruct.total_mem);
    printf("Free Memory: %d\n",topStruct.free_mem);
    printf("Name\tPID\tPPID\tTime\tElapse\tCPU Usage\tMemory Usage\tState\n");
    for (int i = 0; i < topStruct.total_process; i++)
    {
      if (topStruct.p_list[i].state == UNUSED)
        continue;
      printf("|%s", topStruct.p_list[i].name);   
      int cpuUsage = (topStruct.p_list[i].timeElapsed * 10000 / topStruct.uptime) / 100;
      int decimalPointCpuUsage = (topStruct.p_list[i].timeElapsed * 10000 / topStruct.uptime) - cpuUsage * 100;
      int memoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) / 100;
      int decimalPointMemoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) - memoryUsage * 100;
      printf("|\t|%d|\t|%d|\t|%d|\t|%d|\t|%d.%d%%|\t|%d.%d%%|", topStruct.p_list[i].pid, topStruct.p_list[i].ppid > 100 ? 0 : topStruct.p_list[i].ppid, topStruct.p_list[i].time / 10, topStruct.p_list[i].timeElapsed / 10, cpuUsage, decimalPointCpuUsage,i!=0?memoryUsage:0,i!=0?decimalPointMemoryUsage:0);
      if (topStruct.p_list[i].state >= 0 && topStruct.p_list[i].state < NELEM(states) && states[topStruct.p_list[i].state])
        state = states[topStruct.p_list[i].state];
      else
        state = "???";
      printf("\t|%s|\n", state);
    }
    for (int i = 0; i < 1500000000; i++)
    {
    }
  }
  return 0;
}