
user/_top:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NELEM(x) (sizeof(x) / sizeof((x)[0]))
#define gotoxy(x, y) printf("\033[%d;%dH", (y), (x))

int main(int argc, char *argv[])
{
   0:	81010113          	addi	sp,sp,-2032
   4:	7e113423          	sd	ra,2024(sp)
   8:	7e813023          	sd	s0,2016(sp)
   c:	7c913c23          	sd	s1,2008(sp)
  10:	7d213823          	sd	s2,2000(sp)
  14:	7d313423          	sd	s3,1992(sp)
  18:	7d413023          	sd	s4,1984(sp)
  1c:	7b513c23          	sd	s5,1976(sp)
  20:	7b613823          	sd	s6,1968(sp)
  24:	7b713423          	sd	s7,1960(sp)
  28:	7b813023          	sd	s8,1952(sp)
  2c:	79913c23          	sd	s9,1944(sp)
  30:	79a13823          	sd	s10,1936(sp)
  34:	79b13423          	sd	s11,1928(sp)
  38:	7f010413          	addi	s0,sp,2032
  3c:	b3010113          	addi	sp,sp,-1232
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  while (1)
  {
    for (int i = 0; i < 31; i++)
  40:	4b01                	li	s6,0
    {
      gotoxy(1, i);
  42:	00001997          	auipc	s3,0x1
  46:	9f698993          	addi	s3,s3,-1546 # a38 <malloc+0xfa>
    }

    gotoxy(0, 0);
    char *state;
    struct top topStruct;
    top(&topStruct);
  4a:	7dfd                	lui	s11,0xfffff
  4c:	3d8d8793          	addi	a5,s11,984 # fffffffffffff3d8 <base+0xffffffffffffe3c8>
  50:	f9040713          	addi	a4,s0,-112
  54:	97ba                	add	a5,a5,a4
  56:	76fd                	lui	a3,0xfffff
  58:	35868713          	addi	a4,a3,856 # fffffffffffff358 <base+0xffffffffffffe348>
  5c:	9722                	add	a4,a4,s0
  5e:	e31c                	sd	a5,0(a4)
    for (int i = 0; i < topStruct.total_process; i++)
    {
      if (topStruct.p_list[i].state == UNUSED)
        continue;
      printf("|%s", topStruct.p_list[i].name);   
      int cpuUsage = (topStruct.p_list[i].timeElapsed * 10000 / topStruct.uptime) / 100;
  60:	6c09                	lui	s8,0x2
  62:	710c0c1b          	addiw	s8,s8,1808
      int decimalPointMemoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) - memoryUsage * 100;
      printf("|\t|%d|\t|%d|\t|%d|\t|%d|\t|%d.%d%%|\t|%d.%d%%|", topStruct.p_list[i].pid, topStruct.p_list[i].ppid > 100 ? 0 : topStruct.p_list[i].ppid, topStruct.p_list[i].time / 10, topStruct.p_list[i].timeElapsed / 10, cpuUsage, decimalPointCpuUsage,i!=0?memoryUsage:0,i!=0?decimalPointMemoryUsage:0);
      if (topStruct.p_list[i].state >= 0 && topStruct.p_list[i].state < NELEM(states) && states[topStruct.p_list[i].state])
        state = states[topStruct.p_list[i].state];
      else
        state = "???";
  66:	596837b7          	lui	a5,0x59683
  6a:	f0078793          	addi	a5,a5,-256 # 59682f00 <base+0x59681ef0>
  6e:	35068713          	addi	a4,a3,848
  72:	9722                	add	a4,a4,s0
  74:	e31c                	sd	a5,0(a4)
  76:	a0d9                	j	13c <main+0x13c>
      printf("\t|%s|\n", state);
  78:	00001517          	auipc	a0,0x1
  7c:	ad050513          	addi	a0,a0,-1328 # b48 <malloc+0x20a>
  80:	00001097          	auipc	ra,0x1
  84:	800080e7          	jalr	-2048(ra) # 880 <printf>
    for (int i = 0; i < topStruct.total_process; i++)
  88:	2905                	addiw	s2,s2,1
  8a:	03048493          	addi	s1,s1,48
  8e:	3e0aa783          	lw	a5,992(s5)
  92:	08f95e63          	bge	s2,a5,12e <main+0x12e>
      if (topStruct.p_list[i].state == UNUSED)
  96:	8a26                	mv	s4,s1
  98:	5098                	lw	a4,32(s1)
  9a:	4785                	li	a5,1
  9c:	fef706e3          	beq	a4,a5,88 <main+0x88>
      printf("|%s", topStruct.p_list[i].name);   
  a0:	85a6                	mv	a1,s1
  a2:	00001517          	auipc	a0,0x1
  a6:	a6e50513          	addi	a0,a0,-1426 # b10 <malloc+0x1d2>
  aa:	00000097          	auipc	ra,0x0
  ae:	7d6080e7          	jalr	2006(ra) # 880 <printf>
      int cpuUsage = (topStruct.p_list[i].timeElapsed * 10000 / topStruct.uptime) / 100;
  b2:	01c4a883          	lw	a7,28(s1)
  b6:	031c083b          	mulw	a6,s8,a7
  ba:	3d8ab783          	ld	a5,984(s5)
  be:	02f84833          	div	a6,a6,a5
  c2:	06400713          	li	a4,100
  c6:	02e84633          	div	a2,a6,a4
  ca:	0006079b          	sext.w	a5,a2
      int decimalPointCpuUsage = (topStruct.p_list[i].timeElapsed * 10000 / topStruct.uptime) - cpuUsage * 100;
  ce:	06400693          	li	a3,100
  d2:	02c686bb          	mulw	a3,a3,a2
  d6:	40d8083b          	subw	a6,a6,a3
      int memoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) / 100;
  da:	7488                	ld	a0,40(s1)
  dc:	f8043303          	ld	t1,-128(s0)
      printf("|\t|%d|\t|%d|\t|%d|\t|%d|\t|%d.%d%%|\t|%d.%d%%|", topStruct.p_list[i].pid, topStruct.p_list[i].ppid > 100 ? 0 : topStruct.p_list[i].ppid, topStruct.p_list[i].time / 10, topStruct.p_list[i].timeElapsed / 10, cpuUsage, decimalPointCpuUsage,i!=0?memoryUsage:0,i!=0?decimalPointMemoryUsage:0);
  e0:	488c                	lw	a1,16(s1)
  e2:	48d0                	lw	a2,20(s1)
  e4:	00c75363          	bge	a4,a2,ea <main+0xea>
  e8:	865a                	mv	a2,s6
  ea:	018a2683          	lw	a3,24(s4)
  ee:	4729                	li	a4,10
  f0:	02e6c6bb          	divw	a3,a3,a4
  f4:	02e8c73b          	divw	a4,a7,a4
  f8:	14091b63          	bnez	s2,24e <main+0x24e>
  fc:	88ca                	mv	a7,s2
  fe:	855a                	mv	a0,s6
 100:	e02a                	sd	a0,0(sp)
 102:	00001517          	auipc	a0,0x1
 106:	a1650513          	addi	a0,a0,-1514 # b18 <malloc+0x1da>
 10a:	00000097          	auipc	ra,0x0
 10e:	776080e7          	jalr	1910(ra) # 880 <printf>
      if (topStruct.p_list[i].state >= 0 && topStruct.p_list[i].state < NELEM(states) && states[topStruct.p_list[i].state])
 112:	020a2783          	lw	a5,32(s4)
 116:	4719                	li	a4,6
        state = "???";
 118:	85de                	mv	a1,s7
      if (topStruct.p_list[i].state >= 0 && topStruct.p_list[i].state < NELEM(states) && states[topStruct.p_list[i].state])
 11a:	f4f76fe3          	bltu	a4,a5,78 <main+0x78>
 11e:	1782                	slli	a5,a5,0x20
 120:	9381                	srli	a5,a5,0x20
 122:	078e                	slli	a5,a5,0x3
 124:	97ea                	add	a5,a5,s10
 126:	638c                	ld	a1,0(a5)
 128:	f9a1                	bnez	a1,78 <main+0x78>
        state = "???";
 12a:	85de                	mv	a1,s7
 12c:	b7b1                	j	78 <main+0x78>
 12e:	77fd                	lui	a5,0xfffff
 130:	35078793          	addi	a5,a5,848 # fffffffffffff350 <base+0xffffffffffffe340>
 134:	97a2                	add	a5,a5,s0
 136:	639c                	ld	a5,0(a5)
    }
    for (int i = 0; i < 1500000000; i++)
 138:	37fd                	addiw	a5,a5,-1
 13a:	fffd                	bnez	a5,138 <main+0x138>
    for (int i = 0; i < 31; i++)
 13c:	84da                	mv	s1,s6
      printf("\33[2K\r");
 13e:	00001a17          	auipc	s4,0x1
 142:	90aa0a13          	addi	s4,s4,-1782 # a48 <malloc+0x10a>
    for (int i = 0; i < 31; i++)
 146:	497d                	li	s2,31
      gotoxy(1, i);
 148:	4605                	li	a2,1
 14a:	85a6                	mv	a1,s1
 14c:	854e                	mv	a0,s3
 14e:	00000097          	auipc	ra,0x0
 152:	732080e7          	jalr	1842(ra) # 880 <printf>
      printf("\33[2K\r");
 156:	8552                	mv	a0,s4
 158:	00000097          	auipc	ra,0x0
 15c:	728080e7          	jalr	1832(ra) # 880 <printf>
    for (int i = 0; i < 31; i++)
 160:	2485                	addiw	s1,s1,1
 162:	ff2493e3          	bne	s1,s2,148 <main+0x148>
    gotoxy(0, 0);
 166:	865a                	mv	a2,s6
 168:	85da                	mv	a1,s6
 16a:	854e                	mv	a0,s3
 16c:	00000097          	auipc	ra,0x0
 170:	714080e7          	jalr	1812(ra) # 880 <printf>
    top(&topStruct);
 174:	77fd                	lui	a5,0xfffff
 176:	35878793          	addi	a5,a5,856 # fffffffffffff358 <base+0xffffffffffffe348>
 17a:	97a2                	add	a5,a5,s0
 17c:	0007b903          	ld	s2,0(a5)
 180:	854a                	mv	a0,s2
 182:	00000097          	auipc	ra,0x0
 186:	41e080e7          	jalr	1054(ra) # 5a0 <top>
    printf("Uptime= %d\n", topStruct.uptime / 10);
 18a:	f9040793          	addi	a5,s0,-112
 18e:	01b784b3          	add	s1,a5,s11
 192:	3d84b583          	ld	a1,984(s1)
 196:	47a9                	li	a5,10
 198:	02f5c5b3          	div	a1,a1,a5
 19c:	00001517          	auipc	a0,0x1
 1a0:	8b450513          	addi	a0,a0,-1868 # a50 <malloc+0x112>
 1a4:	00000097          	auipc	ra,0x0
 1a8:	6dc080e7          	jalr	1756(ra) # 880 <printf>
    printf("Total Process: %d\n", topStruct.total_process);
 1ac:	3e04a583          	lw	a1,992(s1)
 1b0:	00001517          	auipc	a0,0x1
 1b4:	8b050513          	addi	a0,a0,-1872 # a60 <malloc+0x122>
 1b8:	00000097          	auipc	ra,0x0
 1bc:	6c8080e7          	jalr	1736(ra) # 880 <printf>
    printf("Running Process: %d\n", topStruct.running_process);
 1c0:	3e44a583          	lw	a1,996(s1)
 1c4:	00001517          	auipc	a0,0x1
 1c8:	8b450513          	addi	a0,a0,-1868 # a78 <malloc+0x13a>
 1cc:	00000097          	auipc	ra,0x0
 1d0:	6b4080e7          	jalr	1716(ra) # 880 <printf>
    printf("Sleeping Process: %d\n", topStruct.sleeping_process);
 1d4:	3e84a583          	lw	a1,1000(s1)
 1d8:	00001517          	auipc	a0,0x1
 1dc:	8b850513          	addi	a0,a0,-1864 # a90 <malloc+0x152>
 1e0:	00000097          	auipc	ra,0x0
 1e4:	6a0080e7          	jalr	1696(ra) # 880 <printf>
    printf("Total Memory: %d\n",topStruct.total_mem);
 1e8:	f8043583          	ld	a1,-128(s0)
 1ec:	00001517          	auipc	a0,0x1
 1f0:	8bc50513          	addi	a0,a0,-1860 # aa8 <malloc+0x16a>
 1f4:	00000097          	auipc	ra,0x0
 1f8:	68c080e7          	jalr	1676(ra) # 880 <printf>
    printf("Free Memory: %d\n",topStruct.free_mem);
 1fc:	f8843583          	ld	a1,-120(s0)
 200:	00001517          	auipc	a0,0x1
 204:	8c050513          	addi	a0,a0,-1856 # ac0 <malloc+0x182>
 208:	00000097          	auipc	ra,0x0
 20c:	678080e7          	jalr	1656(ra) # 880 <printf>
    printf("Name\tPID\tPPID\tTime\tElapse\tCPU Usage\tMemory Usage\tState\n");
 210:	00001517          	auipc	a0,0x1
 214:	8c850513          	addi	a0,a0,-1848 # ad8 <malloc+0x19a>
 218:	00000097          	auipc	ra,0x0
 21c:	668080e7          	jalr	1640(ra) # 880 <printf>
    for (int i = 0; i < topStruct.total_process; i++)
 220:	3e04a783          	lw	a5,992(s1)
 224:	f0f055e3          	blez	a5,12e <main+0x12e>
 228:	01890493          	addi	s1,s2,24
 22c:	895a                	mv	s2,s6
      int cpuUsage = (topStruct.p_list[i].timeElapsed * 10000 / topStruct.uptime) / 100;
 22e:	f9040793          	addi	a5,s0,-112
 232:	01b78ab3          	add	s5,a5,s11
      int memoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) / 100;
 236:	6c89                	lui	s9,0x2
 238:	710c8c93          	addi	s9,s9,1808 # 2710 <base+0x1700>
        state = "???";
 23c:	00000b97          	auipc	s7,0x0
 240:	7f4b8b93          	addi	s7,s7,2036 # a30 <malloc+0xf2>
      if (topStruct.p_list[i].state >= 0 && topStruct.p_list[i].state < NELEM(states) && states[topStruct.p_list[i].state])
 244:	00001d17          	auipc	s10,0x1
 248:	93cd0d13          	addi	s10,s10,-1732 # b80 <states.0>
 24c:	b5a9                	j	96 <main+0x96>
      int memoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) / 100;
 24e:	03950533          	mul	a0,a0,s9
 252:	02655533          	divu	a0,a0,t1
 256:	06400313          	li	t1,100
 25a:	02655333          	divu	t1,a0,t1
 25e:	0003089b          	sext.w	a7,t1
      int decimalPointMemoryUsage = (topStruct.p_list[i].size * 10000 / topStruct.total_mem) - memoryUsage * 100;
 262:	06400e13          	li	t3,100
 266:	026e033b          	mulw	t1,t3,t1
 26a:	4065053b          	subw	a0,a0,t1
 26e:	bd49                	j	100 <main+0x100>

0000000000000270 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  extern int main();
  main();
 278:	00000097          	auipc	ra,0x0
 27c:	d88080e7          	jalr	-632(ra) # 0 <main>
  exit(0);
 280:	4501                	li	a0,0
 282:	00000097          	auipc	ra,0x0
 286:	276080e7          	jalr	630(ra) # 4f8 <exit>

000000000000028a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 290:	87aa                	mv	a5,a0
 292:	0585                	addi	a1,a1,1
 294:	0785                	addi	a5,a5,1
 296:	fff5c703          	lbu	a4,-1(a1)
 29a:	fee78fa3          	sb	a4,-1(a5)
 29e:	fb75                	bnez	a4,292 <strcpy+0x8>
    ;
  return os;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	cb91                	beqz	a5,2c4 <strcmp+0x1e>
 2b2:	0005c703          	lbu	a4,0(a1)
 2b6:	00f71763          	bne	a4,a5,2c4 <strcmp+0x1e>
    p++, q++;
 2ba:	0505                	addi	a0,a0,1
 2bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	fbe5                	bnez	a5,2b2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2c4:	0005c503          	lbu	a0,0(a1)
}
 2c8:	40a7853b          	subw	a0,a5,a0
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <strlen>:

uint
strlen(const char *s)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	cf91                	beqz	a5,2f8 <strlen+0x26>
 2de:	0505                	addi	a0,a0,1
 2e0:	87aa                	mv	a5,a0
 2e2:	4685                	li	a3,1
 2e4:	9e89                	subw	a3,a3,a0
 2e6:	00f6853b          	addw	a0,a3,a5
 2ea:	0785                	addi	a5,a5,1
 2ec:	fff7c703          	lbu	a4,-1(a5)
 2f0:	fb7d                	bnez	a4,2e6 <strlen+0x14>
    ;
  return n;
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  for(n = 0; s[n]; n++)
 2f8:	4501                	li	a0,0
 2fa:	bfe5                	j	2f2 <strlen+0x20>

00000000000002fc <memset>:

void*
memset(void *dst, int c, uint n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 302:	ca19                	beqz	a2,318 <memset+0x1c>
 304:	87aa                	mv	a5,a0
 306:	1602                	slli	a2,a2,0x20
 308:	9201                	srli	a2,a2,0x20
 30a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 30e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 312:	0785                	addi	a5,a5,1
 314:	fee79de3          	bne	a5,a4,30e <memset+0x12>
  }
  return dst;
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret

000000000000031e <strchr>:

char*
strchr(const char *s, char c)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  for(; *s; s++)
 324:	00054783          	lbu	a5,0(a0)
 328:	cb99                	beqz	a5,33e <strchr+0x20>
    if(*s == c)
 32a:	00f58763          	beq	a1,a5,338 <strchr+0x1a>
  for(; *s; s++)
 32e:	0505                	addi	a0,a0,1
 330:	00054783          	lbu	a5,0(a0)
 334:	fbfd                	bnez	a5,32a <strchr+0xc>
      return (char*)s;
  return 0;
 336:	4501                	li	a0,0
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
  return 0;
 33e:	4501                	li	a0,0
 340:	bfe5                	j	338 <strchr+0x1a>

0000000000000342 <gets>:

char*
gets(char *buf, int max)
{
 342:	711d                	addi	sp,sp,-96
 344:	ec86                	sd	ra,88(sp)
 346:	e8a2                	sd	s0,80(sp)
 348:	e4a6                	sd	s1,72(sp)
 34a:	e0ca                	sd	s2,64(sp)
 34c:	fc4e                	sd	s3,56(sp)
 34e:	f852                	sd	s4,48(sp)
 350:	f456                	sd	s5,40(sp)
 352:	f05a                	sd	s6,32(sp)
 354:	ec5e                	sd	s7,24(sp)
 356:	1080                	addi	s0,sp,96
 358:	8baa                	mv	s7,a0
 35a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 35c:	892a                	mv	s2,a0
 35e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 360:	4aa9                	li	s5,10
 362:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 364:	89a6                	mv	s3,s1
 366:	2485                	addiw	s1,s1,1
 368:	0344d863          	bge	s1,s4,398 <gets+0x56>
    cc = read(0, &c, 1);
 36c:	4605                	li	a2,1
 36e:	faf40593          	addi	a1,s0,-81
 372:	4501                	li	a0,0
 374:	00000097          	auipc	ra,0x0
 378:	19c080e7          	jalr	412(ra) # 510 <read>
    if(cc < 1)
 37c:	00a05e63          	blez	a0,398 <gets+0x56>
    buf[i++] = c;
 380:	faf44783          	lbu	a5,-81(s0)
 384:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 388:	01578763          	beq	a5,s5,396 <gets+0x54>
 38c:	0905                	addi	s2,s2,1
 38e:	fd679be3          	bne	a5,s6,364 <gets+0x22>
  for(i=0; i+1 < max; ){
 392:	89a6                	mv	s3,s1
 394:	a011                	j	398 <gets+0x56>
 396:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 398:	99de                	add	s3,s3,s7
 39a:	00098023          	sb	zero,0(s3)
  return buf;
}
 39e:	855e                	mv	a0,s7
 3a0:	60e6                	ld	ra,88(sp)
 3a2:	6446                	ld	s0,80(sp)
 3a4:	64a6                	ld	s1,72(sp)
 3a6:	6906                	ld	s2,64(sp)
 3a8:	79e2                	ld	s3,56(sp)
 3aa:	7a42                	ld	s4,48(sp)
 3ac:	7aa2                	ld	s5,40(sp)
 3ae:	7b02                	ld	s6,32(sp)
 3b0:	6be2                	ld	s7,24(sp)
 3b2:	6125                	addi	sp,sp,96
 3b4:	8082                	ret

00000000000003b6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	e426                	sd	s1,8(sp)
 3be:	e04a                	sd	s2,0(sp)
 3c0:	1000                	addi	s0,sp,32
 3c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c4:	4581                	li	a1,0
 3c6:	00000097          	auipc	ra,0x0
 3ca:	172080e7          	jalr	370(ra) # 538 <open>
  if(fd < 0)
 3ce:	02054563          	bltz	a0,3f8 <stat+0x42>
 3d2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3d4:	85ca                	mv	a1,s2
 3d6:	00000097          	auipc	ra,0x0
 3da:	17a080e7          	jalr	378(ra) # 550 <fstat>
 3de:	892a                	mv	s2,a0
  close(fd);
 3e0:	8526                	mv	a0,s1
 3e2:	00000097          	auipc	ra,0x0
 3e6:	13e080e7          	jalr	318(ra) # 520 <close>
  return r;
}
 3ea:	854a                	mv	a0,s2
 3ec:	60e2                	ld	ra,24(sp)
 3ee:	6442                	ld	s0,16(sp)
 3f0:	64a2                	ld	s1,8(sp)
 3f2:	6902                	ld	s2,0(sp)
 3f4:	6105                	addi	sp,sp,32
 3f6:	8082                	ret
    return -1;
 3f8:	597d                	li	s2,-1
 3fa:	bfc5                	j	3ea <stat+0x34>

00000000000003fc <atoi>:

int
atoi(const char *s)
{
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e422                	sd	s0,8(sp)
 400:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 402:	00054603          	lbu	a2,0(a0)
 406:	fd06079b          	addiw	a5,a2,-48
 40a:	0ff7f793          	andi	a5,a5,255
 40e:	4725                	li	a4,9
 410:	02f76963          	bltu	a4,a5,442 <atoi+0x46>
 414:	86aa                	mv	a3,a0
  n = 0;
 416:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 418:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 41a:	0685                	addi	a3,a3,1
 41c:	0025179b          	slliw	a5,a0,0x2
 420:	9fa9                	addw	a5,a5,a0
 422:	0017979b          	slliw	a5,a5,0x1
 426:	9fb1                	addw	a5,a5,a2
 428:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 42c:	0006c603          	lbu	a2,0(a3)
 430:	fd06071b          	addiw	a4,a2,-48
 434:	0ff77713          	andi	a4,a4,255
 438:	fee5f1e3          	bgeu	a1,a4,41a <atoi+0x1e>
  return n;
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
  n = 0;
 442:	4501                	li	a0,0
 444:	bfe5                	j	43c <atoi+0x40>

0000000000000446 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 446:	1141                	addi	sp,sp,-16
 448:	e422                	sd	s0,8(sp)
 44a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 44c:	02b57463          	bgeu	a0,a1,474 <memmove+0x2e>
    while(n-- > 0)
 450:	00c05f63          	blez	a2,46e <memmove+0x28>
 454:	1602                	slli	a2,a2,0x20
 456:	9201                	srli	a2,a2,0x20
 458:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 45c:	872a                	mv	a4,a0
      *dst++ = *src++;
 45e:	0585                	addi	a1,a1,1
 460:	0705                	addi	a4,a4,1
 462:	fff5c683          	lbu	a3,-1(a1)
 466:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 46a:	fee79ae3          	bne	a5,a4,45e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 46e:	6422                	ld	s0,8(sp)
 470:	0141                	addi	sp,sp,16
 472:	8082                	ret
    dst += n;
 474:	00c50733          	add	a4,a0,a2
    src += n;
 478:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 47a:	fec05ae3          	blez	a2,46e <memmove+0x28>
 47e:	fff6079b          	addiw	a5,a2,-1
 482:	1782                	slli	a5,a5,0x20
 484:	9381                	srli	a5,a5,0x20
 486:	fff7c793          	not	a5,a5
 48a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 48c:	15fd                	addi	a1,a1,-1
 48e:	177d                	addi	a4,a4,-1
 490:	0005c683          	lbu	a3,0(a1)
 494:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 498:	fee79ae3          	bne	a5,a4,48c <memmove+0x46>
 49c:	bfc9                	j	46e <memmove+0x28>

000000000000049e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e422                	sd	s0,8(sp)
 4a2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4a4:	ca05                	beqz	a2,4d4 <memcmp+0x36>
 4a6:	fff6069b          	addiw	a3,a2,-1
 4aa:	1682                	slli	a3,a3,0x20
 4ac:	9281                	srli	a3,a3,0x20
 4ae:	0685                	addi	a3,a3,1
 4b0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4b2:	00054783          	lbu	a5,0(a0)
 4b6:	0005c703          	lbu	a4,0(a1)
 4ba:	00e79863          	bne	a5,a4,4ca <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4be:	0505                	addi	a0,a0,1
    p2++;
 4c0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4c2:	fed518e3          	bne	a0,a3,4b2 <memcmp+0x14>
  }
  return 0;
 4c6:	4501                	li	a0,0
 4c8:	a019                	j	4ce <memcmp+0x30>
      return *p1 - *p2;
 4ca:	40e7853b          	subw	a0,a5,a4
}
 4ce:	6422                	ld	s0,8(sp)
 4d0:	0141                	addi	sp,sp,16
 4d2:	8082                	ret
  return 0;
 4d4:	4501                	li	a0,0
 4d6:	bfe5                	j	4ce <memcmp+0x30>

00000000000004d8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4d8:	1141                	addi	sp,sp,-16
 4da:	e406                	sd	ra,8(sp)
 4dc:	e022                	sd	s0,0(sp)
 4de:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e0:	00000097          	auipc	ra,0x0
 4e4:	f66080e7          	jalr	-154(ra) # 446 <memmove>
}
 4e8:	60a2                	ld	ra,8(sp)
 4ea:	6402                	ld	s0,0(sp)
 4ec:	0141                	addi	sp,sp,16
 4ee:	8082                	ret

00000000000004f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f0:	4885                	li	a7,1
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4f8:	4889                	li	a7,2
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <wait>:
.global wait
wait:
 li a7, SYS_wait
 500:	488d                	li	a7,3
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 508:	4891                	li	a7,4
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <read>:
.global read
read:
 li a7, SYS_read
 510:	4895                	li	a7,5
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <write>:
.global write
write:
 li a7, SYS_write
 518:	48c1                	li	a7,16
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <close>:
.global close
close:
 li a7, SYS_close
 520:	48d5                	li	a7,21
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <kill>:
.global kill
kill:
 li a7, SYS_kill
 528:	4899                	li	a7,6
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <exec>:
.global exec
exec:
 li a7, SYS_exec
 530:	489d                	li	a7,7
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <open>:
.global open
open:
 li a7, SYS_open
 538:	48bd                	li	a7,15
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 540:	48c5                	li	a7,17
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 548:	48c9                	li	a7,18
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 550:	48a1                	li	a7,8
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <link>:
.global link
link:
 li a7, SYS_link
 558:	48cd                	li	a7,19
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 560:	48d1                	li	a7,20
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 568:	48a5                	li	a7,9
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <dup>:
.global dup
dup:
 li a7, SYS_dup
 570:	48a9                	li	a7,10
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 578:	48ad                	li	a7,11
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 580:	48b1                	li	a7,12
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 588:	48b5                	li	a7,13
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 590:	48b9                	li	a7,14
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <history>:
.global history
history:
 li a7, SYS_history
 598:	48d9                	li	a7,22
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <top>:
.global top
top:
 li a7, SYS_top
 5a0:	48dd                	li	a7,23
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a8:	1101                	addi	sp,sp,-32
 5aa:	ec06                	sd	ra,24(sp)
 5ac:	e822                	sd	s0,16(sp)
 5ae:	1000                	addi	s0,sp,32
 5b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5b4:	4605                	li	a2,1
 5b6:	fef40593          	addi	a1,s0,-17
 5ba:	00000097          	auipc	ra,0x0
 5be:	f5e080e7          	jalr	-162(ra) # 518 <write>
}
 5c2:	60e2                	ld	ra,24(sp)
 5c4:	6442                	ld	s0,16(sp)
 5c6:	6105                	addi	sp,sp,32
 5c8:	8082                	ret

00000000000005ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ca:	7139                	addi	sp,sp,-64
 5cc:	fc06                	sd	ra,56(sp)
 5ce:	f822                	sd	s0,48(sp)
 5d0:	f426                	sd	s1,40(sp)
 5d2:	f04a                	sd	s2,32(sp)
 5d4:	ec4e                	sd	s3,24(sp)
 5d6:	0080                	addi	s0,sp,64
 5d8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5da:	c299                	beqz	a3,5e0 <printint+0x16>
 5dc:	0805c863          	bltz	a1,66c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5e0:	2581                	sext.w	a1,a1
  neg = 0;
 5e2:	4881                	li	a7,0
 5e4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5e8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5ea:	2601                	sext.w	a2,a2
 5ec:	00000517          	auipc	a0,0x0
 5f0:	5d450513          	addi	a0,a0,1492 # bc0 <digits>
 5f4:	883a                	mv	a6,a4
 5f6:	2705                	addiw	a4,a4,1
 5f8:	02c5f7bb          	remuw	a5,a1,a2
 5fc:	1782                	slli	a5,a5,0x20
 5fe:	9381                	srli	a5,a5,0x20
 600:	97aa                	add	a5,a5,a0
 602:	0007c783          	lbu	a5,0(a5)
 606:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 60a:	0005879b          	sext.w	a5,a1
 60e:	02c5d5bb          	divuw	a1,a1,a2
 612:	0685                	addi	a3,a3,1
 614:	fec7f0e3          	bgeu	a5,a2,5f4 <printint+0x2a>
  if(neg)
 618:	00088b63          	beqz	a7,62e <printint+0x64>
    buf[i++] = '-';
 61c:	fd040793          	addi	a5,s0,-48
 620:	973e                	add	a4,a4,a5
 622:	02d00793          	li	a5,45
 626:	fef70823          	sb	a5,-16(a4)
 62a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 62e:	02e05863          	blez	a4,65e <printint+0x94>
 632:	fc040793          	addi	a5,s0,-64
 636:	00e78933          	add	s2,a5,a4
 63a:	fff78993          	addi	s3,a5,-1
 63e:	99ba                	add	s3,s3,a4
 640:	377d                	addiw	a4,a4,-1
 642:	1702                	slli	a4,a4,0x20
 644:	9301                	srli	a4,a4,0x20
 646:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 64a:	fff94583          	lbu	a1,-1(s2)
 64e:	8526                	mv	a0,s1
 650:	00000097          	auipc	ra,0x0
 654:	f58080e7          	jalr	-168(ra) # 5a8 <putc>
  while(--i >= 0)
 658:	197d                	addi	s2,s2,-1
 65a:	ff3918e3          	bne	s2,s3,64a <printint+0x80>
}
 65e:	70e2                	ld	ra,56(sp)
 660:	7442                	ld	s0,48(sp)
 662:	74a2                	ld	s1,40(sp)
 664:	7902                	ld	s2,32(sp)
 666:	69e2                	ld	s3,24(sp)
 668:	6121                	addi	sp,sp,64
 66a:	8082                	ret
    x = -xx;
 66c:	40b005bb          	negw	a1,a1
    neg = 1;
 670:	4885                	li	a7,1
    x = -xx;
 672:	bf8d                	j	5e4 <printint+0x1a>

0000000000000674 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 674:	7119                	addi	sp,sp,-128
 676:	fc86                	sd	ra,120(sp)
 678:	f8a2                	sd	s0,112(sp)
 67a:	f4a6                	sd	s1,104(sp)
 67c:	f0ca                	sd	s2,96(sp)
 67e:	ecce                	sd	s3,88(sp)
 680:	e8d2                	sd	s4,80(sp)
 682:	e4d6                	sd	s5,72(sp)
 684:	e0da                	sd	s6,64(sp)
 686:	fc5e                	sd	s7,56(sp)
 688:	f862                	sd	s8,48(sp)
 68a:	f466                	sd	s9,40(sp)
 68c:	f06a                	sd	s10,32(sp)
 68e:	ec6e                	sd	s11,24(sp)
 690:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 692:	0005c903          	lbu	s2,0(a1)
 696:	18090f63          	beqz	s2,834 <vprintf+0x1c0>
 69a:	8aaa                	mv	s5,a0
 69c:	8b32                	mv	s6,a2
 69e:	00158493          	addi	s1,a1,1
  state = 0;
 6a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6a4:	02500a13          	li	s4,37
      if(c == 'd'){
 6a8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6ac:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6b0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6b4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b8:	00000b97          	auipc	s7,0x0
 6bc:	508b8b93          	addi	s7,s7,1288 # bc0 <digits>
 6c0:	a839                	j	6de <vprintf+0x6a>
        putc(fd, c);
 6c2:	85ca                	mv	a1,s2
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	ee2080e7          	jalr	-286(ra) # 5a8 <putc>
 6ce:	a019                	j	6d4 <vprintf+0x60>
    } else if(state == '%'){
 6d0:	01498f63          	beq	s3,s4,6ee <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6d4:	0485                	addi	s1,s1,1
 6d6:	fff4c903          	lbu	s2,-1(s1)
 6da:	14090d63          	beqz	s2,834 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6e2:	fe0997e3          	bnez	s3,6d0 <vprintf+0x5c>
      if(c == '%'){
 6e6:	fd479ee3          	bne	a5,s4,6c2 <vprintf+0x4e>
        state = '%';
 6ea:	89be                	mv	s3,a5
 6ec:	b7e5                	j	6d4 <vprintf+0x60>
      if(c == 'd'){
 6ee:	05878063          	beq	a5,s8,72e <vprintf+0xba>
      } else if(c == 'l') {
 6f2:	05978c63          	beq	a5,s9,74a <vprintf+0xd6>
      } else if(c == 'x') {
 6f6:	07a78863          	beq	a5,s10,766 <vprintf+0xf2>
      } else if(c == 'p') {
 6fa:	09b78463          	beq	a5,s11,782 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6fe:	07300713          	li	a4,115
 702:	0ce78663          	beq	a5,a4,7ce <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 706:	06300713          	li	a4,99
 70a:	0ee78e63          	beq	a5,a4,806 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 70e:	11478863          	beq	a5,s4,81e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 712:	85d2                	mv	a1,s4
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	e92080e7          	jalr	-366(ra) # 5a8 <putc>
        putc(fd, c);
 71e:	85ca                	mv	a1,s2
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e86080e7          	jalr	-378(ra) # 5a8 <putc>
      }
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b765                	j	6d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 72e:	008b0913          	addi	s2,s6,8
 732:	4685                	li	a3,1
 734:	4629                	li	a2,10
 736:	000b2583          	lw	a1,0(s6)
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	e8e080e7          	jalr	-370(ra) # 5ca <printint>
 744:	8b4a                	mv	s6,s2
      state = 0;
 746:	4981                	li	s3,0
 748:	b771                	j	6d4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 74a:	008b0913          	addi	s2,s6,8
 74e:	4681                	li	a3,0
 750:	4629                	li	a2,10
 752:	000b2583          	lw	a1,0(s6)
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	e72080e7          	jalr	-398(ra) # 5ca <printint>
 760:	8b4a                	mv	s6,s2
      state = 0;
 762:	4981                	li	s3,0
 764:	bf85                	j	6d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 766:	008b0913          	addi	s2,s6,8
 76a:	4681                	li	a3,0
 76c:	4641                	li	a2,16
 76e:	000b2583          	lw	a1,0(s6)
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	e56080e7          	jalr	-426(ra) # 5ca <printint>
 77c:	8b4a                	mv	s6,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	bf91                	j	6d4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 782:	008b0793          	addi	a5,s6,8
 786:	f8f43423          	sd	a5,-120(s0)
 78a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 78e:	03000593          	li	a1,48
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	e14080e7          	jalr	-492(ra) # 5a8 <putc>
  putc(fd, 'x');
 79c:	85ea                	mv	a1,s10
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e08080e7          	jalr	-504(ra) # 5a8 <putc>
 7a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7aa:	03c9d793          	srli	a5,s3,0x3c
 7ae:	97de                	add	a5,a5,s7
 7b0:	0007c583          	lbu	a1,0(a5)
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	df2080e7          	jalr	-526(ra) # 5a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7be:	0992                	slli	s3,s3,0x4
 7c0:	397d                	addiw	s2,s2,-1
 7c2:	fe0914e3          	bnez	s2,7aa <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7c6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b721                	j	6d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ce:	008b0993          	addi	s3,s6,8
 7d2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7d6:	02090163          	beqz	s2,7f8 <vprintf+0x184>
        while(*s != 0){
 7da:	00094583          	lbu	a1,0(s2)
 7de:	c9a1                	beqz	a1,82e <vprintf+0x1ba>
          putc(fd, *s);
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	dc6080e7          	jalr	-570(ra) # 5a8 <putc>
          s++;
 7ea:	0905                	addi	s2,s2,1
        while(*s != 0){
 7ec:	00094583          	lbu	a1,0(s2)
 7f0:	f9e5                	bnez	a1,7e0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7f2:	8b4e                	mv	s6,s3
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bdf9                	j	6d4 <vprintf+0x60>
          s = "(null)";
 7f8:	00000917          	auipc	s2,0x0
 7fc:	3c090913          	addi	s2,s2,960 # bb8 <states.0+0x38>
        while(*s != 0){
 800:	02800593          	li	a1,40
 804:	bff1                	j	7e0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 806:	008b0913          	addi	s2,s6,8
 80a:	000b4583          	lbu	a1,0(s6)
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	d98080e7          	jalr	-616(ra) # 5a8 <putc>
 818:	8b4a                	mv	s6,s2
      state = 0;
 81a:	4981                	li	s3,0
 81c:	bd65                	j	6d4 <vprintf+0x60>
        putc(fd, c);
 81e:	85d2                	mv	a1,s4
 820:	8556                	mv	a0,s5
 822:	00000097          	auipc	ra,0x0
 826:	d86080e7          	jalr	-634(ra) # 5a8 <putc>
      state = 0;
 82a:	4981                	li	s3,0
 82c:	b565                	j	6d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 82e:	8b4e                	mv	s6,s3
      state = 0;
 830:	4981                	li	s3,0
 832:	b54d                	j	6d4 <vprintf+0x60>
    }
  }
}
 834:	70e6                	ld	ra,120(sp)
 836:	7446                	ld	s0,112(sp)
 838:	74a6                	ld	s1,104(sp)
 83a:	7906                	ld	s2,96(sp)
 83c:	69e6                	ld	s3,88(sp)
 83e:	6a46                	ld	s4,80(sp)
 840:	6aa6                	ld	s5,72(sp)
 842:	6b06                	ld	s6,64(sp)
 844:	7be2                	ld	s7,56(sp)
 846:	7c42                	ld	s8,48(sp)
 848:	7ca2                	ld	s9,40(sp)
 84a:	7d02                	ld	s10,32(sp)
 84c:	6de2                	ld	s11,24(sp)
 84e:	6109                	addi	sp,sp,128
 850:	8082                	ret

0000000000000852 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 852:	715d                	addi	sp,sp,-80
 854:	ec06                	sd	ra,24(sp)
 856:	e822                	sd	s0,16(sp)
 858:	1000                	addi	s0,sp,32
 85a:	e010                	sd	a2,0(s0)
 85c:	e414                	sd	a3,8(s0)
 85e:	e818                	sd	a4,16(s0)
 860:	ec1c                	sd	a5,24(s0)
 862:	03043023          	sd	a6,32(s0)
 866:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 86a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 86e:	8622                	mv	a2,s0
 870:	00000097          	auipc	ra,0x0
 874:	e04080e7          	jalr	-508(ra) # 674 <vprintf>
}
 878:	60e2                	ld	ra,24(sp)
 87a:	6442                	ld	s0,16(sp)
 87c:	6161                	addi	sp,sp,80
 87e:	8082                	ret

0000000000000880 <printf>:

void
printf(const char *fmt, ...)
{
 880:	711d                	addi	sp,sp,-96
 882:	ec06                	sd	ra,24(sp)
 884:	e822                	sd	s0,16(sp)
 886:	1000                	addi	s0,sp,32
 888:	e40c                	sd	a1,8(s0)
 88a:	e810                	sd	a2,16(s0)
 88c:	ec14                	sd	a3,24(s0)
 88e:	f018                	sd	a4,32(s0)
 890:	f41c                	sd	a5,40(s0)
 892:	03043823          	sd	a6,48(s0)
 896:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 89a:	00840613          	addi	a2,s0,8
 89e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8a2:	85aa                	mv	a1,a0
 8a4:	4505                	li	a0,1
 8a6:	00000097          	auipc	ra,0x0
 8aa:	dce080e7          	jalr	-562(ra) # 674 <vprintf>
}
 8ae:	60e2                	ld	ra,24(sp)
 8b0:	6442                	ld	s0,16(sp)
 8b2:	6125                	addi	sp,sp,96
 8b4:	8082                	ret

00000000000008b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b6:	1141                	addi	sp,sp,-16
 8b8:	e422                	sd	s0,8(sp)
 8ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c0:	00000797          	auipc	a5,0x0
 8c4:	7407b783          	ld	a5,1856(a5) # 1000 <freep>
 8c8:	a805                	j	8f8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ca:	4618                	lw	a4,8(a2)
 8cc:	9db9                	addw	a1,a1,a4
 8ce:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d2:	6398                	ld	a4,0(a5)
 8d4:	6318                	ld	a4,0(a4)
 8d6:	fee53823          	sd	a4,-16(a0)
 8da:	a091                	j	91e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8dc:	ff852703          	lw	a4,-8(a0)
 8e0:	9e39                	addw	a2,a2,a4
 8e2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8e4:	ff053703          	ld	a4,-16(a0)
 8e8:	e398                	sd	a4,0(a5)
 8ea:	a099                	j	930 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ec:	6398                	ld	a4,0(a5)
 8ee:	00e7e463          	bltu	a5,a4,8f6 <free+0x40>
 8f2:	00e6ea63          	bltu	a3,a4,906 <free+0x50>
{
 8f6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f8:	fed7fae3          	bgeu	a5,a3,8ec <free+0x36>
 8fc:	6398                	ld	a4,0(a5)
 8fe:	00e6e463          	bltu	a3,a4,906 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 902:	fee7eae3          	bltu	a5,a4,8f6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 906:	ff852583          	lw	a1,-8(a0)
 90a:	6390                	ld	a2,0(a5)
 90c:	02059713          	slli	a4,a1,0x20
 910:	9301                	srli	a4,a4,0x20
 912:	0712                	slli	a4,a4,0x4
 914:	9736                	add	a4,a4,a3
 916:	fae60ae3          	beq	a2,a4,8ca <free+0x14>
    bp->s.ptr = p->s.ptr;
 91a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 91e:	4790                	lw	a2,8(a5)
 920:	02061713          	slli	a4,a2,0x20
 924:	9301                	srli	a4,a4,0x20
 926:	0712                	slli	a4,a4,0x4
 928:	973e                	add	a4,a4,a5
 92a:	fae689e3          	beq	a3,a4,8dc <free+0x26>
  } else
    p->s.ptr = bp;
 92e:	e394                	sd	a3,0(a5)
  freep = p;
 930:	00000717          	auipc	a4,0x0
 934:	6cf73823          	sd	a5,1744(a4) # 1000 <freep>
}
 938:	6422                	ld	s0,8(sp)
 93a:	0141                	addi	sp,sp,16
 93c:	8082                	ret

000000000000093e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 93e:	7139                	addi	sp,sp,-64
 940:	fc06                	sd	ra,56(sp)
 942:	f822                	sd	s0,48(sp)
 944:	f426                	sd	s1,40(sp)
 946:	f04a                	sd	s2,32(sp)
 948:	ec4e                	sd	s3,24(sp)
 94a:	e852                	sd	s4,16(sp)
 94c:	e456                	sd	s5,8(sp)
 94e:	e05a                	sd	s6,0(sp)
 950:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 952:	02051493          	slli	s1,a0,0x20
 956:	9081                	srli	s1,s1,0x20
 958:	04bd                	addi	s1,s1,15
 95a:	8091                	srli	s1,s1,0x4
 95c:	0014899b          	addiw	s3,s1,1
 960:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 962:	00000517          	auipc	a0,0x0
 966:	69e53503          	ld	a0,1694(a0) # 1000 <freep>
 96a:	c515                	beqz	a0,996 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96e:	4798                	lw	a4,8(a5)
 970:	02977f63          	bgeu	a4,s1,9ae <malloc+0x70>
 974:	8a4e                	mv	s4,s3
 976:	0009871b          	sext.w	a4,s3
 97a:	6685                	lui	a3,0x1
 97c:	00d77363          	bgeu	a4,a3,982 <malloc+0x44>
 980:	6a05                	lui	s4,0x1
 982:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 986:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 98a:	00000917          	auipc	s2,0x0
 98e:	67690913          	addi	s2,s2,1654 # 1000 <freep>
  if(p == (char*)-1)
 992:	5afd                	li	s5,-1
 994:	a88d                	j	a06 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 996:	00000797          	auipc	a5,0x0
 99a:	67a78793          	addi	a5,a5,1658 # 1010 <base>
 99e:	00000717          	auipc	a4,0x0
 9a2:	66f73123          	sd	a5,1634(a4) # 1000 <freep>
 9a6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9a8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ac:	b7e1                	j	974 <malloc+0x36>
      if(p->s.size == nunits)
 9ae:	02e48b63          	beq	s1,a4,9e4 <malloc+0xa6>
        p->s.size -= nunits;
 9b2:	4137073b          	subw	a4,a4,s3
 9b6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b8:	1702                	slli	a4,a4,0x20
 9ba:	9301                	srli	a4,a4,0x20
 9bc:	0712                	slli	a4,a4,0x4
 9be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c4:	00000717          	auipc	a4,0x0
 9c8:	62a73e23          	sd	a0,1596(a4) # 1000 <freep>
      return (void*)(p + 1);
 9cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9d0:	70e2                	ld	ra,56(sp)
 9d2:	7442                	ld	s0,48(sp)
 9d4:	74a2                	ld	s1,40(sp)
 9d6:	7902                	ld	s2,32(sp)
 9d8:	69e2                	ld	s3,24(sp)
 9da:	6a42                	ld	s4,16(sp)
 9dc:	6aa2                	ld	s5,8(sp)
 9de:	6b02                	ld	s6,0(sp)
 9e0:	6121                	addi	sp,sp,64
 9e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9e4:	6398                	ld	a4,0(a5)
 9e6:	e118                	sd	a4,0(a0)
 9e8:	bff1                	j	9c4 <malloc+0x86>
  hp->s.size = nu;
 9ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ee:	0541                	addi	a0,a0,16
 9f0:	00000097          	auipc	ra,0x0
 9f4:	ec6080e7          	jalr	-314(ra) # 8b6 <free>
  return freep;
 9f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9fc:	d971                	beqz	a0,9d0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a00:	4798                	lw	a4,8(a5)
 a02:	fa9776e3          	bgeu	a4,s1,9ae <malloc+0x70>
    if(p == freep)
 a06:	00093703          	ld	a4,0(s2)
 a0a:	853e                	mv	a0,a5
 a0c:	fef719e3          	bne	a4,a5,9fe <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a10:	8552                	mv	a0,s4
 a12:	00000097          	auipc	ra,0x0
 a16:	b6e080e7          	jalr	-1170(ra) # 580 <sbrk>
  if(p == (char*)-1)
 a1a:	fd5518e3          	bne	a0,s5,9ea <malloc+0xac>
        return 0;
 a1e:	4501                	li	a0,0
 a20:	bf45                	j	9d0 <malloc+0x92>
