#include "types.h"

#define MAX_HISTORY 16
#define INPUT_BUF_SIZE 128

extern struct
{
  char bufferArr[MAX_HISTORY][INPUT_BUF_SIZE];
  uint lengthArr[MAX_HISTORY];
  uint lastCommandIndex;
  int numOfCommandsInMem;
  int currentHistory;
} historyBufferArray;