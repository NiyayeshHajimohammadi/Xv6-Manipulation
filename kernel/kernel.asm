
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ab010113          	addi	sp,sp,-1360 # 80008ab0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	91e70713          	addi	a4,a4,-1762 # 80008970 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	44c78793          	addi	a5,a5,1100 # 800064b0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbb7b7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	02878793          	addi	a5,a5,40 # 800010d6 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
    historyBufferArray.numOfCommandsInMem++;
  }
}

int consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for (i = 0; i < n; i++)
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
  {
    char c;
    if (either_copyin(&c, user_src, src + i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	91e080e7          	jalr	-1762(ra) # 80002a4a <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00001097          	auipc	ra,0x1
    80000140:	84e080e7          	jalr	-1970(ra) # 8000098a <uartputc>
  for (i = 0; i < n; i++)
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	92650513          	addi	a0,a0,-1754 # 80010ab0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	ca2080e7          	jalr	-862(ra) # 80000e34 <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	91648493          	addi	s1,s1,-1770 # 80010ab0 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	9a690913          	addi	s2,s2,-1626 # 80010b48 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if (c == C('D'))
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if (c == '\n')
    800001ae:	4ca9                	li	s9,10
  while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	a50080e7          	jalr	-1456(ra) # 80001c10 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	6cc080e7          	jalr	1740(ra) # 80002894 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	416080e7          	jalr	1046(ra) # 800025ec <sleep>
    while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	7e2080e7          	jalr	2018(ra) # 800029f4 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	88a50513          	addi	a0,a0,-1910 # 80010ab0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	cba080e7          	jalr	-838(ra) # 80000ee8 <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	87450513          	addi	a0,a0,-1932 # 80010ab0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	ca4080e7          	jalr	-860(ra) # 80000ee8 <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	8cf72b23          	sw	a5,-1834(a4) # 80010b48 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	62c080e7          	jalr	1580(ra) # 800008b8 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	61a080e7          	jalr	1562(ra) # 800008b8 <uartputc_sync>
    uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	60e080e7          	jalr	1550(ra) # 800008b8 <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	604080e7          	jalr	1540(ra) # 800008b8 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <addToHistory>:
{
    800002be:	7139                	addi	sp,sp,-64
    800002c0:	fc06                	sd	ra,56(sp)
    800002c2:	f822                	sd	s0,48(sp)
    800002c4:	f426                	sd	s1,40(sp)
    800002c6:	f04a                	sd	s2,32(sp)
    800002c8:	ec4e                	sd	s3,24(sp)
    800002ca:	e852                	sd	s4,16(sp)
    800002cc:	e456                	sd	s5,8(sp)
    800002ce:	0080                	addi	s0,sp,64
    800002d0:	89aa                	mv	s3,a0
    800002d2:	892e                	mv	s2,a1
  if (!strncmp(command, "history", 7))
    800002d4:	461d                	li	a2,7
    800002d6:	00008597          	auipc	a1,0x8
    800002da:	d3a58593          	addi	a1,a1,-710 # 80008010 <etext+0x10>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	d22080e7          	jalr	-734(ra) # 80001000 <strncmp>
    800002e6:	e911                	bnez	a0,800002fa <addToHistory+0x3c>
}
    800002e8:	70e2                	ld	ra,56(sp)
    800002ea:	7442                	ld	s0,48(sp)
    800002ec:	74a2                	ld	s1,40(sp)
    800002ee:	7902                	ld	s2,32(sp)
    800002f0:	69e2                	ld	s3,24(sp)
    800002f2:	6a42                	ld	s4,16(sp)
    800002f4:	6aa2                	ld	s5,8(sp)
    800002f6:	6121                	addi	sp,sp,64
    800002f8:	8082                	ret
  int index = historyBufferArray.lastCommandIndex % MAX_HISTORY;
    800002fa:	00011a97          	auipc	s5,0x11
    800002fe:	85ea8a93          	addi	s5,s5,-1954 # 80010b58 <historyBufferArray>
    80000302:	00012a17          	auipc	s4,0x12
    80000306:	856a0a13          	addi	s4,s4,-1962 # 80011b58 <kref+0x738>
    8000030a:	840a2483          	lw	s1,-1984(s4)
    8000030e:	88bd                	andi	s1,s1,15
  strncpy(historyBufferArray.bufferArr[index], command, size);
    80000310:	00749513          	slli	a0,s1,0x7
    80000314:	864a                	mv	a2,s2
    80000316:	85ce                	mv	a1,s3
    80000318:	9556                	add	a0,a0,s5
    8000031a:	00001097          	auipc	ra,0x1
    8000031e:	d22080e7          	jalr	-734(ra) # 8000103c <strncpy>
  historyBufferArray.lengthArr[index] = size;
    80000322:	20048493          	addi	s1,s1,512
    80000326:	048a                	slli	s1,s1,0x2
    80000328:	94d6                	add	s1,s1,s5
    8000032a:	0124a023          	sw	s2,0(s1)
  historyBufferArray.lastCommandIndex++;
    8000032e:	840a2783          	lw	a5,-1984(s4)
    80000332:	2785                	addiw	a5,a5,1
    80000334:	84fa2023          	sw	a5,-1984(s4)
  if (historyBufferArray.numOfCommandsInMem < MAX_HISTORY)
    80000338:	844a2783          	lw	a5,-1980(s4)
    8000033c:	473d                	li	a4,15
    8000033e:	faf745e3          	blt	a4,a5,800002e8 <addToHistory+0x2a>
    historyBufferArray.numOfCommandsInMem++;
    80000342:	2785                	addiw	a5,a5,1
    80000344:	00011717          	auipc	a4,0x11
    80000348:	04f72c23          	sw	a5,88(a4) # 8001139c <historyBufferArray+0x844>
    8000034c:	bf71                	j	800002e8 <addToHistory+0x2a>

000000008000034e <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    8000034e:	1101                	addi	sp,sp,-32
    80000350:	ec06                	sd	ra,24(sp)
    80000352:	e822                	sd	s0,16(sp)
    80000354:	e426                	sd	s1,8(sp)
    80000356:	e04a                	sd	s2,0(sp)
    80000358:	1000                	addi	s0,sp,32
    8000035a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000035c:	00010517          	auipc	a0,0x10
    80000360:	75450513          	addi	a0,a0,1876 # 80010ab0 <cons>
    80000364:	00001097          	auipc	ra,0x1
    80000368:	ad0080e7          	jalr	-1328(ra) # 80000e34 <acquire>

  switch (c)
    8000036c:	47c1                	li	a5,16
    8000036e:	08f48e63          	beq	s1,a5,8000040a <consoleintr+0xbc>
    80000372:	0297ce63          	blt	a5,s1,800003ae <consoleintr+0x60>
    80000376:	478d                	li	a5,3
    80000378:	0af48b63          	beq	s1,a5,8000042e <consoleintr+0xe0>
    8000037c:	47a1                	li	a5,8
    8000037e:	0cf49263          	bne	s1,a5,80000442 <consoleintr+0xf4>
      consputc(BACKSPACE);
    }
    break;
  case C('H'): // Backspace
  case '\x7f': // Delete key
    if (cons.e != cons.w)
    80000382:	00010717          	auipc	a4,0x10
    80000386:	72e70713          	addi	a4,a4,1838 # 80010ab0 <cons>
    8000038a:	0a072783          	lw	a5,160(a4)
    8000038e:	09c72703          	lw	a4,156(a4)
    80000392:	08f70063          	beq	a4,a5,80000412 <consoleintr+0xc4>
    {
      cons.e--;
    80000396:	37fd                	addiw	a5,a5,-1
    80000398:	00010717          	auipc	a4,0x10
    8000039c:	7af72c23          	sw	a5,1976(a4) # 80010b50 <cons+0xa0>
      consputc(BACKSPACE);
    800003a0:	10000513          	li	a0,256
    800003a4:	00000097          	auipc	ra,0x0
    800003a8:	ed8080e7          	jalr	-296(ra) # 8000027c <consputc>
    800003ac:	a09d                	j	80000412 <consoleintr+0xc4>
  switch (c)
    800003ae:	47d5                	li	a5,21
    800003b0:	00f48763          	beq	s1,a5,800003be <consoleintr+0x70>
    800003b4:	07f00793          	li	a5,127
    800003b8:	fcf485e3          	beq	s1,a5,80000382 <consoleintr+0x34>
    800003bc:	a061                	j	80000444 <consoleintr+0xf6>
    while (cons.e != cons.w &&
    800003be:	00010717          	auipc	a4,0x10
    800003c2:	6f270713          	addi	a4,a4,1778 # 80010ab0 <cons>
    800003c6:	0a072783          	lw	a5,160(a4)
    800003ca:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003ce:	00010497          	auipc	s1,0x10
    800003d2:	6e248493          	addi	s1,s1,1762 # 80010ab0 <cons>
    while (cons.e != cons.w &&
    800003d6:	4929                	li	s2,10
    800003d8:	02f70d63          	beq	a4,a5,80000412 <consoleintr+0xc4>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003dc:	37fd                	addiw	a5,a5,-1
    800003de:	07f7f713          	andi	a4,a5,127
    800003e2:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    800003e4:	01874703          	lbu	a4,24(a4)
    800003e8:	03270563          	beq	a4,s2,80000412 <consoleintr+0xc4>
      cons.e--;
    800003ec:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e88080e7          	jalr	-376(ra) # 8000027c <consputc>
    while (cons.e != cons.w &&
    800003fc:	0a04a783          	lw	a5,160(s1)
    80000400:	09c4a703          	lw	a4,156(s1)
    80000404:	fcf71ce3          	bne	a4,a5,800003dc <consoleintr+0x8e>
    80000408:	a029                	j	80000412 <consoleintr+0xc4>
    procdump();
    8000040a:	00002097          	auipc	ra,0x2
    8000040e:	696080e7          	jalr	1686(ra) # 80002aa0 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    80000412:	00010517          	auipc	a0,0x10
    80000416:	69e50513          	addi	a0,a0,1694 # 80010ab0 <cons>
    8000041a:	00001097          	auipc	ra,0x1
    8000041e:	ace080e7          	jalr	-1330(ra) # 80000ee8 <release>
}
    80000422:	60e2                	ld	ra,24(sp)
    80000424:	6442                	ld	s0,16(sp)
    80000426:	64a2                	ld	s1,8(sp)
    80000428:	6902                	ld	s2,0(sp)
    8000042a:	6105                	addi	sp,sp,32
    8000042c:	8082                	ret
    kill(myproc()->pid);
    8000042e:	00001097          	auipc	ra,0x1
    80000432:	7e2080e7          	jalr	2018(ra) # 80001c10 <myproc>
    80000436:	5908                	lw	a0,48(a0)
    80000438:	00002097          	auipc	ra,0x2
    8000043c:	3be080e7          	jalr	958(ra) # 800027f6 <kill>
    break;
    80000440:	bfc9                	j	80000412 <consoleintr+0xc4>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000442:	d8e1                	beqz	s1,80000412 <consoleintr+0xc4>
    80000444:	00010717          	auipc	a4,0x10
    80000448:	66c70713          	addi	a4,a4,1644 # 80010ab0 <cons>
    8000044c:	0a072783          	lw	a5,160(a4)
    80000450:	09872703          	lw	a4,152(a4)
    80000454:	9f99                	subw	a5,a5,a4
    80000456:	07f00713          	li	a4,127
    8000045a:	faf76ce3          	bltu	a4,a5,80000412 <consoleintr+0xc4>
      c = (c == '\r') ? '\n' : c;
    8000045e:	47b5                	li	a5,13
    80000460:	04f48863          	beq	s1,a5,800004b0 <consoleintr+0x162>
      consputc(c);
    80000464:	8526                	mv	a0,s1
    80000466:	00000097          	auipc	ra,0x0
    8000046a:	e16080e7          	jalr	-490(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000046e:	00010797          	auipc	a5,0x10
    80000472:	64278793          	addi	a5,a5,1602 # 80010ab0 <cons>
    80000476:	0a07a683          	lw	a3,160(a5)
    8000047a:	0016871b          	addiw	a4,a3,1
    8000047e:	0007059b          	sext.w	a1,a4
    80000482:	0ae7a023          	sw	a4,160(a5)
    80000486:	07f6f693          	andi	a3,a3,127
    8000048a:	97b6                	add	a5,a5,a3
    8000048c:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    80000490:	47a9                	li	a5,10
    80000492:	04f48663          	beq	s1,a5,800004de <consoleintr+0x190>
    80000496:	4791                	li	a5,4
    80000498:	04f48363          	beq	s1,a5,800004de <consoleintr+0x190>
    8000049c:	00010797          	auipc	a5,0x10
    800004a0:	6ac7a783          	lw	a5,1708(a5) # 80010b48 <cons+0x98>
    800004a4:	9f1d                	subw	a4,a4,a5
    800004a6:	08000793          	li	a5,128
    800004aa:	f6f714e3          	bne	a4,a5,80000412 <consoleintr+0xc4>
    800004ae:	a805                	j	800004de <consoleintr+0x190>
      consputc(c);
    800004b0:	4529                	li	a0,10
    800004b2:	00000097          	auipc	ra,0x0
    800004b6:	dca080e7          	jalr	-566(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800004ba:	00010797          	auipc	a5,0x10
    800004be:	5f678793          	addi	a5,a5,1526 # 80010ab0 <cons>
    800004c2:	0a07a703          	lw	a4,160(a5)
    800004c6:	0017069b          	addiw	a3,a4,1
    800004ca:	0006859b          	sext.w	a1,a3
    800004ce:	0ad7a023          	sw	a3,160(a5)
    800004d2:	07f77713          	andi	a4,a4,127
    800004d6:	97ba                	add	a5,a5,a4
    800004d8:	4729                	li	a4,10
    800004da:	00e78c23          	sb	a4,24(a5)
        addToHistory(cons.buf + cons.r, cons.e - cons.r);
    800004de:	00010497          	auipc	s1,0x10
    800004e2:	5d248493          	addi	s1,s1,1490 # 80010ab0 <cons>
    800004e6:	0984a783          	lw	a5,152(s1)
    800004ea:	02079713          	slli	a4,a5,0x20
    800004ee:	9301                	srli	a4,a4,0x20
    800004f0:	9d9d                	subw	a1,a1,a5
    800004f2:	00010517          	auipc	a0,0x10
    800004f6:	5d650513          	addi	a0,a0,1494 # 80010ac8 <cons+0x18>
    800004fa:	953a                	add	a0,a0,a4
    800004fc:	00000097          	auipc	ra,0x0
    80000500:	dc2080e7          	jalr	-574(ra) # 800002be <addToHistory>
        cons.w = cons.e;
    80000504:	0a04a783          	lw	a5,160(s1)
    80000508:	08f4ae23          	sw	a5,156(s1)
        wakeup(&cons.r);
    8000050c:	00010517          	auipc	a0,0x10
    80000510:	63c50513          	addi	a0,a0,1596 # 80010b48 <cons+0x98>
    80000514:	00002097          	auipc	ra,0x2
    80000518:	13c080e7          	jalr	316(ra) # 80002650 <wakeup>
    8000051c:	bddd                	j	80000412 <consoleintr+0xc4>

000000008000051e <consoleinit>:

void consoleinit(void)
{
    8000051e:	1141                	addi	sp,sp,-16
    80000520:	e406                	sd	ra,8(sp)
    80000522:	e022                	sd	s0,0(sp)
    80000524:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000526:	00008597          	auipc	a1,0x8
    8000052a:	af258593          	addi	a1,a1,-1294 # 80008018 <etext+0x18>
    8000052e:	00010517          	auipc	a0,0x10
    80000532:	58250513          	addi	a0,a0,1410 # 80010ab0 <cons>
    80000536:	00001097          	auipc	ra,0x1
    8000053a:	86e080e7          	jalr	-1938(ra) # 80000da4 <initlock>

  uartinit();
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	32a080e7          	jalr	810(ra) # 80000868 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000546:	00042797          	auipc	a5,0x42
    8000054a:	96a78793          	addi	a5,a5,-1686 # 80041eb0 <devsw>
    8000054e:	00000717          	auipc	a4,0x0
    80000552:	c1670713          	addi	a4,a4,-1002 # 80000164 <consoleread>
    80000556:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000558:	00000717          	auipc	a4,0x0
    8000055c:	baa70713          	addi	a4,a4,-1110 # 80000102 <consolewrite>
    80000560:	ef98                	sd	a4,24(a5)
}
    80000562:	60a2                	ld	ra,8(sp)
    80000564:	6402                	ld	s0,0(sp)
    80000566:	0141                	addi	sp,sp,16
    80000568:	8082                	ret

000000008000056a <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000056a:	7179                	addi	sp,sp,-48
    8000056c:	f406                	sd	ra,40(sp)
    8000056e:	f022                	sd	s0,32(sp)
    80000570:	ec26                	sd	s1,24(sp)
    80000572:	e84a                	sd	s2,16(sp)
    80000574:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000576:	c219                	beqz	a2,8000057c <printint+0x12>
    80000578:	08054663          	bltz	a0,80000604 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000057c:	2501                	sext.w	a0,a0
    8000057e:	4881                	li	a7,0
    80000580:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000584:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80000586:	2581                	sext.w	a1,a1
    80000588:	00008617          	auipc	a2,0x8
    8000058c:	ac060613          	addi	a2,a2,-1344 # 80008048 <digits>
    80000590:	883a                	mv	a6,a4
    80000592:	2705                	addiw	a4,a4,1
    80000594:	02b577bb          	remuw	a5,a0,a1
    80000598:	1782                	slli	a5,a5,0x20
    8000059a:	9381                	srli	a5,a5,0x20
    8000059c:	97b2                	add	a5,a5,a2
    8000059e:	0007c783          	lbu	a5,0(a5)
    800005a2:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800005a6:	0005079b          	sext.w	a5,a0
    800005aa:	02b5553b          	divuw	a0,a0,a1
    800005ae:	0685                	addi	a3,a3,1
    800005b0:	feb7f0e3          	bgeu	a5,a1,80000590 <printint+0x26>

  if(sign)
    800005b4:	00088b63          	beqz	a7,800005ca <printint+0x60>
    buf[i++] = '-';
    800005b8:	fe040793          	addi	a5,s0,-32
    800005bc:	973e                	add	a4,a4,a5
    800005be:	02d00793          	li	a5,45
    800005c2:	fef70823          	sb	a5,-16(a4)
    800005c6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800005ca:	02e05763          	blez	a4,800005f8 <printint+0x8e>
    800005ce:	fd040793          	addi	a5,s0,-48
    800005d2:	00e784b3          	add	s1,a5,a4
    800005d6:	fff78913          	addi	s2,a5,-1
    800005da:	993a                	add	s2,s2,a4
    800005dc:	377d                	addiw	a4,a4,-1
    800005de:	1702                	slli	a4,a4,0x20
    800005e0:	9301                	srli	a4,a4,0x20
    800005e2:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800005e6:	fff4c503          	lbu	a0,-1(s1)
    800005ea:	00000097          	auipc	ra,0x0
    800005ee:	c92080e7          	jalr	-878(ra) # 8000027c <consputc>
  while(--i >= 0)
    800005f2:	14fd                	addi	s1,s1,-1
    800005f4:	ff2499e3          	bne	s1,s2,800005e6 <printint+0x7c>
}
    800005f8:	70a2                	ld	ra,40(sp)
    800005fa:	7402                	ld	s0,32(sp)
    800005fc:	64e2                	ld	s1,24(sp)
    800005fe:	6942                	ld	s2,16(sp)
    80000600:	6145                	addi	sp,sp,48
    80000602:	8082                	ret
    x = -xx;
    80000604:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000608:	4885                	li	a7,1
    x = -xx;
    8000060a:	bf9d                	j	80000580 <printint+0x16>

000000008000060c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000060c:	1101                	addi	sp,sp,-32
    8000060e:	ec06                	sd	ra,24(sp)
    80000610:	e822                	sd	s0,16(sp)
    80000612:	e426                	sd	s1,8(sp)
    80000614:	1000                	addi	s0,sp,32
    80000616:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000618:	00011797          	auipc	a5,0x11
    8000061c:	da07a423          	sw	zero,-600(a5) # 800113c0 <pr+0x18>
  printf("panic: ");
    80000620:	00008517          	auipc	a0,0x8
    80000624:	a0050513          	addi	a0,a0,-1536 # 80008020 <etext+0x20>
    80000628:	00000097          	auipc	ra,0x0
    8000062c:	02e080e7          	jalr	46(ra) # 80000656 <printf>
  printf(s);
    80000630:	8526                	mv	a0,s1
    80000632:	00000097          	auipc	ra,0x0
    80000636:	024080e7          	jalr	36(ra) # 80000656 <printf>
  printf("\n");
    8000063a:	00008517          	auipc	a0,0x8
    8000063e:	a9e50513          	addi	a0,a0,-1378 # 800080d8 <digits+0x90>
    80000642:	00000097          	auipc	ra,0x0
    80000646:	014080e7          	jalr	20(ra) # 80000656 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000064a:	4785                	li	a5,1
    8000064c:	00008717          	auipc	a4,0x8
    80000650:	2ef72223          	sw	a5,740(a4) # 80008930 <panicked>
  for(;;)
    80000654:	a001                	j	80000654 <panic+0x48>

0000000080000656 <printf>:
{
    80000656:	7131                	addi	sp,sp,-192
    80000658:	fc86                	sd	ra,120(sp)
    8000065a:	f8a2                	sd	s0,112(sp)
    8000065c:	f4a6                	sd	s1,104(sp)
    8000065e:	f0ca                	sd	s2,96(sp)
    80000660:	ecce                	sd	s3,88(sp)
    80000662:	e8d2                	sd	s4,80(sp)
    80000664:	e4d6                	sd	s5,72(sp)
    80000666:	e0da                	sd	s6,64(sp)
    80000668:	fc5e                	sd	s7,56(sp)
    8000066a:	f862                	sd	s8,48(sp)
    8000066c:	f466                	sd	s9,40(sp)
    8000066e:	f06a                	sd	s10,32(sp)
    80000670:	ec6e                	sd	s11,24(sp)
    80000672:	0100                	addi	s0,sp,128
    80000674:	8a2a                	mv	s4,a0
    80000676:	e40c                	sd	a1,8(s0)
    80000678:	e810                	sd	a2,16(s0)
    8000067a:	ec14                	sd	a3,24(s0)
    8000067c:	f018                	sd	a4,32(s0)
    8000067e:	f41c                	sd	a5,40(s0)
    80000680:	03043823          	sd	a6,48(s0)
    80000684:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80000688:	00011d97          	auipc	s11,0x11
    8000068c:	d38dad83          	lw	s11,-712(s11) # 800113c0 <pr+0x18>
  if(locking)
    80000690:	020d9b63          	bnez	s11,800006c6 <printf+0x70>
  if (fmt == 0)
    80000694:	040a0263          	beqz	s4,800006d8 <printf+0x82>
  va_start(ap, fmt);
    80000698:	00840793          	addi	a5,s0,8
    8000069c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006a0:	000a4503          	lbu	a0,0(s4)
    800006a4:	14050f63          	beqz	a0,80000802 <printf+0x1ac>
    800006a8:	4981                	li	s3,0
    if(c != '%'){
    800006aa:	02500a93          	li	s5,37
    switch(c){
    800006ae:	07000b93          	li	s7,112
  consputc('x');
    800006b2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006b4:	00008b17          	auipc	s6,0x8
    800006b8:	994b0b13          	addi	s6,s6,-1644 # 80008048 <digits>
    switch(c){
    800006bc:	07300c93          	li	s9,115
    800006c0:	06400c13          	li	s8,100
    800006c4:	a82d                	j	800006fe <printf+0xa8>
    acquire(&pr.lock);
    800006c6:	00011517          	auipc	a0,0x11
    800006ca:	ce250513          	addi	a0,a0,-798 # 800113a8 <pr>
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	766080e7          	jalr	1894(ra) # 80000e34 <acquire>
    800006d6:	bf7d                	j	80000694 <printf+0x3e>
    panic("null fmt");
    800006d8:	00008517          	auipc	a0,0x8
    800006dc:	95850513          	addi	a0,a0,-1704 # 80008030 <etext+0x30>
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	f2c080e7          	jalr	-212(ra) # 8000060c <panic>
      consputc(c);
    800006e8:	00000097          	auipc	ra,0x0
    800006ec:	b94080e7          	jalr	-1132(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006f0:	2985                	addiw	s3,s3,1
    800006f2:	013a07b3          	add	a5,s4,s3
    800006f6:	0007c503          	lbu	a0,0(a5)
    800006fa:	10050463          	beqz	a0,80000802 <printf+0x1ac>
    if(c != '%'){
    800006fe:	ff5515e3          	bne	a0,s5,800006e8 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000702:	2985                	addiw	s3,s3,1
    80000704:	013a07b3          	add	a5,s4,s3
    80000708:	0007c783          	lbu	a5,0(a5)
    8000070c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000710:	cbed                	beqz	a5,80000802 <printf+0x1ac>
    switch(c){
    80000712:	05778a63          	beq	a5,s7,80000766 <printf+0x110>
    80000716:	02fbf663          	bgeu	s7,a5,80000742 <printf+0xec>
    8000071a:	09978863          	beq	a5,s9,800007aa <printf+0x154>
    8000071e:	07800713          	li	a4,120
    80000722:	0ce79563          	bne	a5,a4,800007ec <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000726:	f8843783          	ld	a5,-120(s0)
    8000072a:	00878713          	addi	a4,a5,8
    8000072e:	f8e43423          	sd	a4,-120(s0)
    80000732:	4605                	li	a2,1
    80000734:	85ea                	mv	a1,s10
    80000736:	4388                	lw	a0,0(a5)
    80000738:	00000097          	auipc	ra,0x0
    8000073c:	e32080e7          	jalr	-462(ra) # 8000056a <printint>
      break;
    80000740:	bf45                	j	800006f0 <printf+0x9a>
    switch(c){
    80000742:	09578f63          	beq	a5,s5,800007e0 <printf+0x18a>
    80000746:	0b879363          	bne	a5,s8,800007ec <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4605                	li	a2,1
    80000758:	45a9                	li	a1,10
    8000075a:	4388                	lw	a0,0(a5)
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	e0e080e7          	jalr	-498(ra) # 8000056a <printint>
      break;
    80000764:	b771                	j	800006f0 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000766:	f8843783          	ld	a5,-120(s0)
    8000076a:	00878713          	addi	a4,a5,8
    8000076e:	f8e43423          	sd	a4,-120(s0)
    80000772:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000776:	03000513          	li	a0,48
    8000077a:	00000097          	auipc	ra,0x0
    8000077e:	b02080e7          	jalr	-1278(ra) # 8000027c <consputc>
  consputc('x');
    80000782:	07800513          	li	a0,120
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	af6080e7          	jalr	-1290(ra) # 8000027c <consputc>
    8000078e:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000790:	03c95793          	srli	a5,s2,0x3c
    80000794:	97da                	add	a5,a5,s6
    80000796:	0007c503          	lbu	a0,0(a5)
    8000079a:	00000097          	auipc	ra,0x0
    8000079e:	ae2080e7          	jalr	-1310(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800007a2:	0912                	slli	s2,s2,0x4
    800007a4:	34fd                	addiw	s1,s1,-1
    800007a6:	f4ed                	bnez	s1,80000790 <printf+0x13a>
    800007a8:	b7a1                	j	800006f0 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800007aa:	f8843783          	ld	a5,-120(s0)
    800007ae:	00878713          	addi	a4,a5,8
    800007b2:	f8e43423          	sd	a4,-120(s0)
    800007b6:	6384                	ld	s1,0(a5)
    800007b8:	cc89                	beqz	s1,800007d2 <printf+0x17c>
      for(; *s; s++)
    800007ba:	0004c503          	lbu	a0,0(s1)
    800007be:	d90d                	beqz	a0,800006f0 <printf+0x9a>
        consputc(*s);
    800007c0:	00000097          	auipc	ra,0x0
    800007c4:	abc080e7          	jalr	-1348(ra) # 8000027c <consputc>
      for(; *s; s++)
    800007c8:	0485                	addi	s1,s1,1
    800007ca:	0004c503          	lbu	a0,0(s1)
    800007ce:	f96d                	bnez	a0,800007c0 <printf+0x16a>
    800007d0:	b705                	j	800006f0 <printf+0x9a>
        s = "(null)";
    800007d2:	00008497          	auipc	s1,0x8
    800007d6:	85648493          	addi	s1,s1,-1962 # 80008028 <etext+0x28>
      for(; *s; s++)
    800007da:	02800513          	li	a0,40
    800007de:	b7cd                	j	800007c0 <printf+0x16a>
      consputc('%');
    800007e0:	8556                	mv	a0,s5
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	a9a080e7          	jalr	-1382(ra) # 8000027c <consputc>
      break;
    800007ea:	b719                	j	800006f0 <printf+0x9a>
      consputc('%');
    800007ec:	8556                	mv	a0,s5
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	a8e080e7          	jalr	-1394(ra) # 8000027c <consputc>
      consputc(c);
    800007f6:	8526                	mv	a0,s1
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	a84080e7          	jalr	-1404(ra) # 8000027c <consputc>
      break;
    80000800:	bdc5                	j	800006f0 <printf+0x9a>
  if(locking)
    80000802:	020d9163          	bnez	s11,80000824 <printf+0x1ce>
}
    80000806:	70e6                	ld	ra,120(sp)
    80000808:	7446                	ld	s0,112(sp)
    8000080a:	74a6                	ld	s1,104(sp)
    8000080c:	7906                	ld	s2,96(sp)
    8000080e:	69e6                	ld	s3,88(sp)
    80000810:	6a46                	ld	s4,80(sp)
    80000812:	6aa6                	ld	s5,72(sp)
    80000814:	6b06                	ld	s6,64(sp)
    80000816:	7be2                	ld	s7,56(sp)
    80000818:	7c42                	ld	s8,48(sp)
    8000081a:	7ca2                	ld	s9,40(sp)
    8000081c:	7d02                	ld	s10,32(sp)
    8000081e:	6de2                	ld	s11,24(sp)
    80000820:	6129                	addi	sp,sp,192
    80000822:	8082                	ret
    release(&pr.lock);
    80000824:	00011517          	auipc	a0,0x11
    80000828:	b8450513          	addi	a0,a0,-1148 # 800113a8 <pr>
    8000082c:	00000097          	auipc	ra,0x0
    80000830:	6bc080e7          	jalr	1724(ra) # 80000ee8 <release>
}
    80000834:	bfc9                	j	80000806 <printf+0x1b0>

0000000080000836 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000836:	1101                	addi	sp,sp,-32
    80000838:	ec06                	sd	ra,24(sp)
    8000083a:	e822                	sd	s0,16(sp)
    8000083c:	e426                	sd	s1,8(sp)
    8000083e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000840:	00011497          	auipc	s1,0x11
    80000844:	b6848493          	addi	s1,s1,-1176 # 800113a8 <pr>
    80000848:	00007597          	auipc	a1,0x7
    8000084c:	7f858593          	addi	a1,a1,2040 # 80008040 <etext+0x40>
    80000850:	8526                	mv	a0,s1
    80000852:	00000097          	auipc	ra,0x0
    80000856:	552080e7          	jalr	1362(ra) # 80000da4 <initlock>
  pr.locking = 1;
    8000085a:	4785                	li	a5,1
    8000085c:	cc9c                	sw	a5,24(s1)
}
    8000085e:	60e2                	ld	ra,24(sp)
    80000860:	6442                	ld	s0,16(sp)
    80000862:	64a2                	ld	s1,8(sp)
    80000864:	6105                	addi	sp,sp,32
    80000866:	8082                	ret

0000000080000868 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000868:	1141                	addi	sp,sp,-16
    8000086a:	e406                	sd	ra,8(sp)
    8000086c:	e022                	sd	s0,0(sp)
    8000086e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000870:	100007b7          	lui	a5,0x10000
    80000874:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000878:	f8000713          	li	a4,-128
    8000087c:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000880:	470d                	li	a4,3
    80000882:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000886:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000088a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000088e:	469d                	li	a3,7
    80000890:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000894:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000898:	00007597          	auipc	a1,0x7
    8000089c:	7c858593          	addi	a1,a1,1992 # 80008060 <digits+0x18>
    800008a0:	00011517          	auipc	a0,0x11
    800008a4:	b2850513          	addi	a0,a0,-1240 # 800113c8 <uart_tx_lock>
    800008a8:	00000097          	auipc	ra,0x0
    800008ac:	4fc080e7          	jalr	1276(ra) # 80000da4 <initlock>
}
    800008b0:	60a2                	ld	ra,8(sp)
    800008b2:	6402                	ld	s0,0(sp)
    800008b4:	0141                	addi	sp,sp,16
    800008b6:	8082                	ret

00000000800008b8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008b8:	1101                	addi	sp,sp,-32
    800008ba:	ec06                	sd	ra,24(sp)
    800008bc:	e822                	sd	s0,16(sp)
    800008be:	e426                	sd	s1,8(sp)
    800008c0:	1000                	addi	s0,sp,32
    800008c2:	84aa                	mv	s1,a0
  push_off();
    800008c4:	00000097          	auipc	ra,0x0
    800008c8:	524080e7          	jalr	1316(ra) # 80000de8 <push_off>

  if(panicked){
    800008cc:	00008797          	auipc	a5,0x8
    800008d0:	0647a783          	lw	a5,100(a5) # 80008930 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008d4:	10000737          	lui	a4,0x10000
  if(panicked){
    800008d8:	c391                	beqz	a5,800008dc <uartputc_sync+0x24>
    for(;;)
    800008da:	a001                	j	800008da <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008dc:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800008e0:	0207f793          	andi	a5,a5,32
    800008e4:	dfe5                	beqz	a5,800008dc <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    800008e6:	0ff4f513          	andi	a0,s1,255
    800008ea:	100007b7          	lui	a5,0x10000
    800008ee:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800008f2:	00000097          	auipc	ra,0x0
    800008f6:	596080e7          	jalr	1430(ra) # 80000e88 <pop_off>
}
    800008fa:	60e2                	ld	ra,24(sp)
    800008fc:	6442                	ld	s0,16(sp)
    800008fe:	64a2                	ld	s1,8(sp)
    80000900:	6105                	addi	sp,sp,32
    80000902:	8082                	ret

0000000080000904 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000904:	00008797          	auipc	a5,0x8
    80000908:	0347b783          	ld	a5,52(a5) # 80008938 <uart_tx_r>
    8000090c:	00008717          	auipc	a4,0x8
    80000910:	03473703          	ld	a4,52(a4) # 80008940 <uart_tx_w>
    80000914:	06f70a63          	beq	a4,a5,80000988 <uartstart+0x84>
{
    80000918:	7139                	addi	sp,sp,-64
    8000091a:	fc06                	sd	ra,56(sp)
    8000091c:	f822                	sd	s0,48(sp)
    8000091e:	f426                	sd	s1,40(sp)
    80000920:	f04a                	sd	s2,32(sp)
    80000922:	ec4e                	sd	s3,24(sp)
    80000924:	e852                	sd	s4,16(sp)
    80000926:	e456                	sd	s5,8(sp)
    80000928:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000092a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000092e:	00011a17          	auipc	s4,0x11
    80000932:	a9aa0a13          	addi	s4,s4,-1382 # 800113c8 <uart_tx_lock>
    uart_tx_r += 1;
    80000936:	00008497          	auipc	s1,0x8
    8000093a:	00248493          	addi	s1,s1,2 # 80008938 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000093e:	00008997          	auipc	s3,0x8
    80000942:	00298993          	addi	s3,s3,2 # 80008940 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000946:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000094a:	02077713          	andi	a4,a4,32
    8000094e:	c705                	beqz	a4,80000976 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000950:	01f7f713          	andi	a4,a5,31
    80000954:	9752                	add	a4,a4,s4
    80000956:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000095a:	0785                	addi	a5,a5,1
    8000095c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000095e:	8526                	mv	a0,s1
    80000960:	00002097          	auipc	ra,0x2
    80000964:	cf0080e7          	jalr	-784(ra) # 80002650 <wakeup>
    
    WriteReg(THR, c);
    80000968:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000096c:	609c                	ld	a5,0(s1)
    8000096e:	0009b703          	ld	a4,0(s3)
    80000972:	fcf71ae3          	bne	a4,a5,80000946 <uartstart+0x42>
  }
}
    80000976:	70e2                	ld	ra,56(sp)
    80000978:	7442                	ld	s0,48(sp)
    8000097a:	74a2                	ld	s1,40(sp)
    8000097c:	7902                	ld	s2,32(sp)
    8000097e:	69e2                	ld	s3,24(sp)
    80000980:	6a42                	ld	s4,16(sp)
    80000982:	6aa2                	ld	s5,8(sp)
    80000984:	6121                	addi	sp,sp,64
    80000986:	8082                	ret
    80000988:	8082                	ret

000000008000098a <uartputc>:
{
    8000098a:	7179                	addi	sp,sp,-48
    8000098c:	f406                	sd	ra,40(sp)
    8000098e:	f022                	sd	s0,32(sp)
    80000990:	ec26                	sd	s1,24(sp)
    80000992:	e84a                	sd	s2,16(sp)
    80000994:	e44e                	sd	s3,8(sp)
    80000996:	e052                	sd	s4,0(sp)
    80000998:	1800                	addi	s0,sp,48
    8000099a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000099c:	00011517          	auipc	a0,0x11
    800009a0:	a2c50513          	addi	a0,a0,-1492 # 800113c8 <uart_tx_lock>
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	490080e7          	jalr	1168(ra) # 80000e34 <acquire>
  if(panicked){
    800009ac:	00008797          	auipc	a5,0x8
    800009b0:	f847a783          	lw	a5,-124(a5) # 80008930 <panicked>
    800009b4:	e7c9                	bnez	a5,80000a3e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009b6:	00008717          	auipc	a4,0x8
    800009ba:	f8a73703          	ld	a4,-118(a4) # 80008940 <uart_tx_w>
    800009be:	00008797          	auipc	a5,0x8
    800009c2:	f7a7b783          	ld	a5,-134(a5) # 80008938 <uart_tx_r>
    800009c6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800009ca:	00011997          	auipc	s3,0x11
    800009ce:	9fe98993          	addi	s3,s3,-1538 # 800113c8 <uart_tx_lock>
    800009d2:	00008497          	auipc	s1,0x8
    800009d6:	f6648493          	addi	s1,s1,-154 # 80008938 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009da:	00008917          	auipc	s2,0x8
    800009de:	f6690913          	addi	s2,s2,-154 # 80008940 <uart_tx_w>
    800009e2:	00e79f63          	bne	a5,a4,80000a00 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    800009e6:	85ce                	mv	a1,s3
    800009e8:	8526                	mv	a0,s1
    800009ea:	00002097          	auipc	ra,0x2
    800009ee:	c02080e7          	jalr	-1022(ra) # 800025ec <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009f2:	00093703          	ld	a4,0(s2)
    800009f6:	609c                	ld	a5,0(s1)
    800009f8:	02078793          	addi	a5,a5,32
    800009fc:	fee785e3          	beq	a5,a4,800009e6 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000a00:	00011497          	auipc	s1,0x11
    80000a04:	9c848493          	addi	s1,s1,-1592 # 800113c8 <uart_tx_lock>
    80000a08:	01f77793          	andi	a5,a4,31
    80000a0c:	97a6                	add	a5,a5,s1
    80000a0e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000a12:	0705                	addi	a4,a4,1
    80000a14:	00008797          	auipc	a5,0x8
    80000a18:	f2e7b623          	sd	a4,-212(a5) # 80008940 <uart_tx_w>
  uartstart();
    80000a1c:	00000097          	auipc	ra,0x0
    80000a20:	ee8080e7          	jalr	-280(ra) # 80000904 <uartstart>
  release(&uart_tx_lock);
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	4c2080e7          	jalr	1218(ra) # 80000ee8 <release>
}
    80000a2e:	70a2                	ld	ra,40(sp)
    80000a30:	7402                	ld	s0,32(sp)
    80000a32:	64e2                	ld	s1,24(sp)
    80000a34:	6942                	ld	s2,16(sp)
    80000a36:	69a2                	ld	s3,8(sp)
    80000a38:	6a02                	ld	s4,0(sp)
    80000a3a:	6145                	addi	sp,sp,48
    80000a3c:	8082                	ret
    for(;;)
    80000a3e:	a001                	j	80000a3e <uartputc+0xb4>

0000000080000a40 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a40:	1141                	addi	sp,sp,-16
    80000a42:	e422                	sd	s0,8(sp)
    80000a44:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a46:	100007b7          	lui	a5,0x10000
    80000a4a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a4e:	8b85                	andi	a5,a5,1
    80000a50:	cb91                	beqz	a5,80000a64 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a52:	100007b7          	lui	a5,0x10000
    80000a56:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a5a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a5e:	6422                	ld	s0,8(sp)
    80000a60:	0141                	addi	sp,sp,16
    80000a62:	8082                	ret
    return -1;
    80000a64:	557d                	li	a0,-1
    80000a66:	bfe5                	j	80000a5e <uartgetc+0x1e>

0000000080000a68 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a68:	1101                	addi	sp,sp,-32
    80000a6a:	ec06                	sd	ra,24(sp)
    80000a6c:	e822                	sd	s0,16(sp)
    80000a6e:	e426                	sd	s1,8(sp)
    80000a70:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a72:	54fd                	li	s1,-1
    80000a74:	a029                	j	80000a7e <uartintr+0x16>
      break;
    consoleintr(c);
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	8d8080e7          	jalr	-1832(ra) # 8000034e <consoleintr>
    int c = uartgetc();
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	fc2080e7          	jalr	-62(ra) # 80000a40 <uartgetc>
    if(c == -1)
    80000a86:	fe9518e3          	bne	a0,s1,80000a76 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a8a:	00011497          	auipc	s1,0x11
    80000a8e:	93e48493          	addi	s1,s1,-1730 # 800113c8 <uart_tx_lock>
    80000a92:	8526                	mv	a0,s1
    80000a94:	00000097          	auipc	ra,0x0
    80000a98:	3a0080e7          	jalr	928(ra) # 80000e34 <acquire>
  uartstart();
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	e68080e7          	jalr	-408(ra) # 80000904 <uartstart>
  release(&uart_tx_lock);
    80000aa4:	8526                	mv	a0,s1
    80000aa6:	00000097          	auipc	ra,0x0
    80000aaa:	442080e7          	jalr	1090(ra) # 80000ee8 <release>
}
    80000aae:	60e2                	ld	ra,24(sp)
    80000ab0:	6442                	ld	s0,16(sp)
    80000ab2:	64a2                	ld	s1,8(sp)
    80000ab4:	6105                	addi	sp,sp,32
    80000ab6:	8082                	ret

0000000080000ab8 <kref_increment>:
  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}

void kref_increment(void* pa){
    80000ab8:	1101                	addi	sp,sp,-32
    80000aba:	ec06                	sd	ra,24(sp)
    80000abc:	e822                	sd	s0,16(sp)
    80000abe:	e426                	sd	s1,8(sp)
    80000ac0:	1000                	addi	s0,sp,32
    80000ac2:	84aa                	mv	s1,a0
  struct run *r = (struct run*)pa;
  acquire(&kref.lock);
    80000ac4:	00031517          	auipc	a0,0x31
    80000ac8:	95c50513          	addi	a0,a0,-1700 # 80031420 <kref+0x20000>
    80000acc:	00000097          	auipc	ra,0x0
    80000ad0:	368080e7          	jalr	872(ra) # 80000e34 <acquire>
  kref.ref[((uint64)r - KERNBASE) / PGSIZE] ++;
    80000ad4:	80000537          	lui	a0,0x80000
    80000ad8:	94aa                	add	s1,s1,a0
    80000ada:	80b1                	srli	s1,s1,0xc
    80000adc:	048a                	slli	s1,s1,0x2
    80000ade:	00011797          	auipc	a5,0x11
    80000ae2:	94278793          	addi	a5,a5,-1726 # 80011420 <kref>
    80000ae6:	94be                	add	s1,s1,a5
    80000ae8:	409c                	lw	a5,0(s1)
    80000aea:	2785                	addiw	a5,a5,1
    80000aec:	c09c                	sw	a5,0(s1)
  release(&kref.lock);
    80000aee:	00031517          	auipc	a0,0x31
    80000af2:	93250513          	addi	a0,a0,-1742 # 80031420 <kref+0x20000>
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	3f2080e7          	jalr	1010(ra) # 80000ee8 <release>
}
    80000afe:	60e2                	ld	ra,24(sp)
    80000b00:	6442                	ld	s0,16(sp)
    80000b02:	64a2                	ld	s1,8(sp)
    80000b04:	6105                	addi	sp,sp,32
    80000b06:	8082                	ret

0000000080000b08 <kalloc>:
{
    80000b08:	1101                	addi	sp,sp,-32
    80000b0a:	ec06                	sd	ra,24(sp)
    80000b0c:	e822                	sd	s0,16(sp)
    80000b0e:	e426                	sd	s1,8(sp)
    80000b10:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000b12:	00011497          	auipc	s1,0x11
    80000b16:	8ee48493          	addi	s1,s1,-1810 # 80011400 <kmem>
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	318080e7          	jalr	792(ra) # 80000e34 <acquire>
  r = kmem.freelist;
    80000b24:	6c84                	ld	s1,24(s1)
  if(r)
    80000b26:	cc8d                	beqz	s1,80000b60 <kalloc+0x58>
    kmem.freelist = r->next;
    80000b28:	609c                	ld	a5,0(s1)
    80000b2a:	00011517          	auipc	a0,0x11
    80000b2e:	8d650513          	addi	a0,a0,-1834 # 80011400 <kmem>
    80000b32:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	3b4080e7          	jalr	948(ra) # 80000ee8 <release>
    kref_increment((void*)r); // Initialize refcount to 1
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	00000097          	auipc	ra,0x0
    80000b42:	f7a080e7          	jalr	-134(ra) # 80000ab8 <kref_increment>
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b46:	6605                	lui	a2,0x1
    80000b48:	4595                	li	a1,5
    80000b4a:	8526                	mv	a0,s1
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	3e4080e7          	jalr	996(ra) # 80000f30 <memset>
}
    80000b54:	8526                	mv	a0,s1
    80000b56:	60e2                	ld	ra,24(sp)
    80000b58:	6442                	ld	s0,16(sp)
    80000b5a:	64a2                	ld	s1,8(sp)
    80000b5c:	6105                	addi	sp,sp,32
    80000b5e:	8082                	ret
  release(&kmem.lock);
    80000b60:	00011517          	auipc	a0,0x11
    80000b64:	8a050513          	addi	a0,a0,-1888 # 80011400 <kmem>
    80000b68:	00000097          	auipc	ra,0x0
    80000b6c:	380080e7          	jalr	896(ra) # 80000ee8 <release>
  if(r)
    80000b70:	b7d5                	j	80000b54 <kalloc+0x4c>

0000000080000b72 <kref_decrement>:
void kref_decrement(void* pa){
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
    80000b7c:	84aa                	mv	s1,a0
  struct run *r = (struct run*)pa;
  acquire(&kref.lock);
    80000b7e:	00031517          	auipc	a0,0x31
    80000b82:	8a250513          	addi	a0,a0,-1886 # 80031420 <kref+0x20000>
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	2ae080e7          	jalr	686(ra) # 80000e34 <acquire>
  kref.ref[((uint64)r - KERNBASE) / PGSIZE]= kref.ref[((uint64)r - KERNBASE) / PGSIZE]<=0 ? 0: kref.ref[((uint64)r - KERNBASE) / PGSIZE]-1;
    80000b8e:	80000537          	lui	a0,0x80000
    80000b92:	94aa                	add	s1,s1,a0
    80000b94:	80b1                	srli	s1,s1,0xc
    80000b96:	048a                	slli	s1,s1,0x2
    80000b98:	00011797          	auipc	a5,0x11
    80000b9c:	88878793          	addi	a5,a5,-1912 # 80011420 <kref>
    80000ba0:	94be                	add	s1,s1,a5
    80000ba2:	409c                	lw	a5,0(s1)
    80000ba4:	0007871b          	sext.w	a4,a5
    80000ba8:	02e05163          	blez	a4,80000bca <kref_decrement+0x58>
    80000bac:	37fd                	addiw	a5,a5,-1
    80000bae:	c09c                	sw	a5,0(s1)
  release(&kref.lock);
    80000bb0:	00031517          	auipc	a0,0x31
    80000bb4:	87050513          	addi	a0,a0,-1936 # 80031420 <kref+0x20000>
    80000bb8:	00000097          	auipc	ra,0x0
    80000bbc:	330080e7          	jalr	816(ra) # 80000ee8 <release>
}
    80000bc0:	60e2                	ld	ra,24(sp)
    80000bc2:	6442                	ld	s0,16(sp)
    80000bc4:	64a2                	ld	s1,8(sp)
    80000bc6:	6105                	addi	sp,sp,32
    80000bc8:	8082                	ret
  kref.ref[((uint64)r - KERNBASE) / PGSIZE]= kref.ref[((uint64)r - KERNBASE) / PGSIZE]<=0 ? 0: kref.ref[((uint64)r - KERNBASE) / PGSIZE]-1;
    80000bca:	4785                	li	a5,1
    80000bcc:	b7c5                	j	80000bac <kref_decrement+0x3a>

0000000080000bce <kfree>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	e04a                	sd	s2,0(sp)
    80000bd8:	1000                	addi	s0,sp,32
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000bda:	03451793          	slli	a5,a0,0x34
    80000bde:	e7a1                	bnez	a5,80000c26 <kfree+0x58>
    80000be0:	84aa                	mv	s1,a0
    80000be2:	00042797          	auipc	a5,0x42
    80000be6:	46678793          	addi	a5,a5,1126 # 80043048 <end>
    80000bea:	02f56e63          	bltu	a0,a5,80000c26 <kfree+0x58>
    80000bee:	47c5                	li	a5,17
    80000bf0:	07ee                	slli	a5,a5,0x1b
    80000bf2:	02f57a63          	bgeu	a0,a5,80000c26 <kfree+0x58>
  kref_decrement(pa);
    80000bf6:	00000097          	auipc	ra,0x0
    80000bfa:	f7c080e7          	jalr	-132(ra) # 80000b72 <kref_decrement>
  int ref_index = ((uint64)pa - KERNBASE) / PGSIZE;
    80000bfe:	800007b7          	lui	a5,0x80000
    80000c02:	97a6                	add	a5,a5,s1
    80000c04:	83b1                	srli	a5,a5,0xc
  if (kref.ref[ref_index] > 0) {
    80000c06:	2781                	sext.w	a5,a5
    80000c08:	078a                	slli	a5,a5,0x2
    80000c0a:	00011717          	auipc	a4,0x11
    80000c0e:	81670713          	addi	a4,a4,-2026 # 80011420 <kref>
    80000c12:	97ba                	add	a5,a5,a4
    80000c14:	439c                	lw	a5,0(a5)
    80000c16:	02f05063          	blez	a5,80000c36 <kfree+0x68>
}
    80000c1a:	60e2                	ld	ra,24(sp)
    80000c1c:	6442                	ld	s0,16(sp)
    80000c1e:	64a2                	ld	s1,8(sp)
    80000c20:	6902                	ld	s2,0(sp)
    80000c22:	6105                	addi	sp,sp,32
    80000c24:	8082                	ret
    panic("kfree");
    80000c26:	00007517          	auipc	a0,0x7
    80000c2a:	44250513          	addi	a0,a0,1090 # 80008068 <digits+0x20>
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	9de080e7          	jalr	-1570(ra) # 8000060c <panic>
  memset(pa, 1, PGSIZE);
    80000c36:	6605                	lui	a2,0x1
    80000c38:	4585                	li	a1,1
    80000c3a:	8526                	mv	a0,s1
    80000c3c:	00000097          	auipc	ra,0x0
    80000c40:	2f4080e7          	jalr	756(ra) # 80000f30 <memset>
  acquire(&kmem.lock);
    80000c44:	00010917          	auipc	s2,0x10
    80000c48:	7bc90913          	addi	s2,s2,1980 # 80011400 <kmem>
    80000c4c:	854a                	mv	a0,s2
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	1e6080e7          	jalr	486(ra) # 80000e34 <acquire>
  r->next = kmem.freelist;
    80000c56:	01893783          	ld	a5,24(s2)
    80000c5a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000c5c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000c60:	854a                	mv	a0,s2
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	286080e7          	jalr	646(ra) # 80000ee8 <release>
    80000c6a:	bf45                	j	80000c1a <kfree+0x4c>

0000000080000c6c <freerange>:
{
    80000c6c:	7179                	addi	sp,sp,-48
    80000c6e:	f406                	sd	ra,40(sp)
    80000c70:	f022                	sd	s0,32(sp)
    80000c72:	ec26                	sd	s1,24(sp)
    80000c74:	e84a                	sd	s2,16(sp)
    80000c76:	e44e                	sd	s3,8(sp)
    80000c78:	e052                	sd	s4,0(sp)
    80000c7a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000c7c:	6785                	lui	a5,0x1
    80000c7e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000c82:	94aa                	add	s1,s1,a0
    80000c84:	757d                	lui	a0,0xfffff
    80000c86:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c88:	94be                	add	s1,s1,a5
    80000c8a:	0095ee63          	bltu	a1,s1,80000ca6 <freerange+0x3a>
    80000c8e:	892e                	mv	s2,a1
    kfree(p);
    80000c90:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c92:	6985                	lui	s3,0x1
    kfree(p);
    80000c94:	01448533          	add	a0,s1,s4
    80000c98:	00000097          	auipc	ra,0x0
    80000c9c:	f36080e7          	jalr	-202(ra) # 80000bce <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ca0:	94ce                	add	s1,s1,s3
    80000ca2:	fe9979e3          	bgeu	s2,s1,80000c94 <freerange+0x28>
}
    80000ca6:	70a2                	ld	ra,40(sp)
    80000ca8:	7402                	ld	s0,32(sp)
    80000caa:	64e2                	ld	s1,24(sp)
    80000cac:	6942                	ld	s2,16(sp)
    80000cae:	69a2                	ld	s3,8(sp)
    80000cb0:	6a02                	ld	s4,0(sp)
    80000cb2:	6145                	addi	sp,sp,48
    80000cb4:	8082                	ret

0000000080000cb6 <kinit>:
{
    80000cb6:	1141                	addi	sp,sp,-16
    80000cb8:	e406                	sd	ra,8(sp)
    80000cba:	e022                	sd	s0,0(sp)
    80000cbc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000cbe:	00007597          	auipc	a1,0x7
    80000cc2:	3b258593          	addi	a1,a1,946 # 80008070 <digits+0x28>
    80000cc6:	00010517          	auipc	a0,0x10
    80000cca:	73a50513          	addi	a0,a0,1850 # 80011400 <kmem>
    80000cce:	00000097          	auipc	ra,0x0
    80000cd2:	0d6080e7          	jalr	214(ra) # 80000da4 <initlock>
  initlock(&kref.lock, "kref");
    80000cd6:	00007597          	auipc	a1,0x7
    80000cda:	3a258593          	addi	a1,a1,930 # 80008078 <digits+0x30>
    80000cde:	00030517          	auipc	a0,0x30
    80000ce2:	74250513          	addi	a0,a0,1858 # 80031420 <kref+0x20000>
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	0be080e7          	jalr	190(ra) # 80000da4 <initlock>
  memset(kref.ref, 0, sizeof(kref.ref));
    80000cee:	00020637          	lui	a2,0x20
    80000cf2:	4581                	li	a1,0
    80000cf4:	00010517          	auipc	a0,0x10
    80000cf8:	72c50513          	addi	a0,a0,1836 # 80011420 <kref>
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	234080e7          	jalr	564(ra) # 80000f30 <memset>
  freerange(end, (void*)PHYSTOP);
    80000d04:	45c5                	li	a1,17
    80000d06:	05ee                	slli	a1,a1,0x1b
    80000d08:	00042517          	auipc	a0,0x42
    80000d0c:	34050513          	addi	a0,a0,832 # 80043048 <end>
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	f5c080e7          	jalr	-164(ra) # 80000c6c <freerange>
}
    80000d18:	60a2                	ld	ra,8(sp)
    80000d1a:	6402                	ld	s0,0(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret

0000000080000d20 <kref_set>:
void kref_set(void* pa , int num){
    80000d20:	1101                	addi	sp,sp,-32
    80000d22:	ec06                	sd	ra,24(sp)
    80000d24:	e822                	sd	s0,16(sp)
    80000d26:	e426                	sd	s1,8(sp)
    80000d28:	e04a                	sd	s2,0(sp)
    80000d2a:	1000                	addi	s0,sp,32
    80000d2c:	84aa                	mv	s1,a0
    80000d2e:	892e                	mv	s2,a1
  struct run *r = (struct run*)pa;
  acquire(&kref.lock);
    80000d30:	00030517          	auipc	a0,0x30
    80000d34:	6f050513          	addi	a0,a0,1776 # 80031420 <kref+0x20000>
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	0fc080e7          	jalr	252(ra) # 80000e34 <acquire>
  kref.ref[((uint64)r - KERNBASE) / PGSIZE] = num;
    80000d40:	80000537          	lui	a0,0x80000
    80000d44:	94aa                	add	s1,s1,a0
    80000d46:	80b1                	srli	s1,s1,0xc
    80000d48:	048a                	slli	s1,s1,0x2
    80000d4a:	00010797          	auipc	a5,0x10
    80000d4e:	6d678793          	addi	a5,a5,1750 # 80011420 <kref>
    80000d52:	94be                	add	s1,s1,a5
    80000d54:	0124a023          	sw	s2,0(s1)
  release(&kref.lock);
    80000d58:	00030517          	auipc	a0,0x30
    80000d5c:	6c850513          	addi	a0,a0,1736 # 80031420 <kref+0x20000>
    80000d60:	00000097          	auipc	ra,0x0
    80000d64:	188080e7          	jalr	392(ra) # 80000ee8 <release>
}
    80000d68:	60e2                	ld	ra,24(sp)
    80000d6a:	6442                	ld	s0,16(sp)
    80000d6c:	64a2                	ld	s1,8(sp)
    80000d6e:	6902                	ld	s2,0(sp)
    80000d70:	6105                	addi	sp,sp,32
    80000d72:	8082                	ret

0000000080000d74 <free_memory>:
uint64 free_memory(){
    80000d74:	1141                	addi	sp,sp,-16
    80000d76:	e422                	sd	s0,8(sp)
    80000d78:	0800                	addi	s0,sp,16
  uint64 free=0;
  for(int i=0;i<(PHYSTOP-KERNBASE) / PGSIZE;i++){
    80000d7a:	00010797          	auipc	a5,0x10
    80000d7e:	6a678793          	addi	a5,a5,1702 # 80011420 <kref>
    80000d82:	00030697          	auipc	a3,0x30
    80000d86:	69e68693          	addi	a3,a3,1694 # 80031420 <kref+0x20000>
  uint64 free=0;
    80000d8a:	4501                	li	a0,0
    if(kref.ref[i]==0)
      free+=PGSIZE;
    80000d8c:	6605                	lui	a2,0x1
    80000d8e:	a021                	j	80000d96 <free_memory+0x22>
  for(int i=0;i<(PHYSTOP-KERNBASE) / PGSIZE;i++){
    80000d90:	0791                	addi	a5,a5,4
    80000d92:	00d78663          	beq	a5,a3,80000d9e <free_memory+0x2a>
    if(kref.ref[i]==0)
    80000d96:	4398                	lw	a4,0(a5)
    80000d98:	ff65                	bnez	a4,80000d90 <free_memory+0x1c>
      free+=PGSIZE;
    80000d9a:	9532                	add	a0,a0,a2
    80000d9c:	bfd5                	j	80000d90 <free_memory+0x1c>
  }
  return free;
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000daa:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000dac:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000db0:	00053823          	sd	zero,16(a0)
}
    80000db4:	6422                	ld	s0,8(sp)
    80000db6:	0141                	addi	sp,sp,16
    80000db8:	8082                	ret

0000000080000dba <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000dba:	411c                	lw	a5,0(a0)
    80000dbc:	e399                	bnez	a5,80000dc2 <holding+0x8>
    80000dbe:	4501                	li	a0,0
  return r;
}
    80000dc0:	8082                	ret
{
    80000dc2:	1101                	addi	sp,sp,-32
    80000dc4:	ec06                	sd	ra,24(sp)
    80000dc6:	e822                	sd	s0,16(sp)
    80000dc8:	e426                	sd	s1,8(sp)
    80000dca:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000dcc:	6904                	ld	s1,16(a0)
    80000dce:	00001097          	auipc	ra,0x1
    80000dd2:	e26080e7          	jalr	-474(ra) # 80001bf4 <mycpu>
    80000dd6:	40a48533          	sub	a0,s1,a0
    80000dda:	00153513          	seqz	a0,a0
}
    80000dde:	60e2                	ld	ra,24(sp)
    80000de0:	6442                	ld	s0,16(sp)
    80000de2:	64a2                	ld	s1,8(sp)
    80000de4:	6105                	addi	sp,sp,32
    80000de6:	8082                	ret

0000000080000de8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000de8:	1101                	addi	sp,sp,-32
    80000dea:	ec06                	sd	ra,24(sp)
    80000dec:	e822                	sd	s0,16(sp)
    80000dee:	e426                	sd	s1,8(sp)
    80000df0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000df2:	100024f3          	csrr	s1,sstatus
    80000df6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000dfa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000dfc:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000e00:	00001097          	auipc	ra,0x1
    80000e04:	df4080e7          	jalr	-524(ra) # 80001bf4 <mycpu>
    80000e08:	5d3c                	lw	a5,120(a0)
    80000e0a:	cf89                	beqz	a5,80000e24 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000e0c:	00001097          	auipc	ra,0x1
    80000e10:	de8080e7          	jalr	-536(ra) # 80001bf4 <mycpu>
    80000e14:	5d3c                	lw	a5,120(a0)
    80000e16:	2785                	addiw	a5,a5,1
    80000e18:	dd3c                	sw	a5,120(a0)
}
    80000e1a:	60e2                	ld	ra,24(sp)
    80000e1c:	6442                	ld	s0,16(sp)
    80000e1e:	64a2                	ld	s1,8(sp)
    80000e20:	6105                	addi	sp,sp,32
    80000e22:	8082                	ret
    mycpu()->intena = old;
    80000e24:	00001097          	auipc	ra,0x1
    80000e28:	dd0080e7          	jalr	-560(ra) # 80001bf4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000e2c:	8085                	srli	s1,s1,0x1
    80000e2e:	8885                	andi	s1,s1,1
    80000e30:	dd64                	sw	s1,124(a0)
    80000e32:	bfe9                	j	80000e0c <push_off+0x24>

0000000080000e34 <acquire>:
{
    80000e34:	1101                	addi	sp,sp,-32
    80000e36:	ec06                	sd	ra,24(sp)
    80000e38:	e822                	sd	s0,16(sp)
    80000e3a:	e426                	sd	s1,8(sp)
    80000e3c:	1000                	addi	s0,sp,32
    80000e3e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000e40:	00000097          	auipc	ra,0x0
    80000e44:	fa8080e7          	jalr	-88(ra) # 80000de8 <push_off>
  if(holding(lk))
    80000e48:	8526                	mv	a0,s1
    80000e4a:	00000097          	auipc	ra,0x0
    80000e4e:	f70080e7          	jalr	-144(ra) # 80000dba <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e52:	4705                	li	a4,1
  if(holding(lk))
    80000e54:	e115                	bnez	a0,80000e78 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e56:	87ba                	mv	a5,a4
    80000e58:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e5c:	2781                	sext.w	a5,a5
    80000e5e:	ffe5                	bnez	a5,80000e56 <acquire+0x22>
  __sync_synchronize();
    80000e60:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e64:	00001097          	auipc	ra,0x1
    80000e68:	d90080e7          	jalr	-624(ra) # 80001bf4 <mycpu>
    80000e6c:	e888                	sd	a0,16(s1)
}
    80000e6e:	60e2                	ld	ra,24(sp)
    80000e70:	6442                	ld	s0,16(sp)
    80000e72:	64a2                	ld	s1,8(sp)
    80000e74:	6105                	addi	sp,sp,32
    80000e76:	8082                	ret
    panic("acquire");
    80000e78:	00007517          	auipc	a0,0x7
    80000e7c:	20850513          	addi	a0,a0,520 # 80008080 <digits+0x38>
    80000e80:	fffff097          	auipc	ra,0xfffff
    80000e84:	78c080e7          	jalr	1932(ra) # 8000060c <panic>

0000000080000e88 <pop_off>:

void
pop_off(void)
{
    80000e88:	1141                	addi	sp,sp,-16
    80000e8a:	e406                	sd	ra,8(sp)
    80000e8c:	e022                	sd	s0,0(sp)
    80000e8e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	d64080e7          	jalr	-668(ra) # 80001bf4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e98:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e9c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e9e:	e78d                	bnez	a5,80000ec8 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ea0:	5d3c                	lw	a5,120(a0)
    80000ea2:	02f05b63          	blez	a5,80000ed8 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ea6:	37fd                	addiw	a5,a5,-1
    80000ea8:	0007871b          	sext.w	a4,a5
    80000eac:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000eae:	eb09                	bnez	a4,80000ec0 <pop_off+0x38>
    80000eb0:	5d7c                	lw	a5,124(a0)
    80000eb2:	c799                	beqz	a5,80000ec0 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000eb4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000eb8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ebc:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ec0:	60a2                	ld	ra,8(sp)
    80000ec2:	6402                	ld	s0,0(sp)
    80000ec4:	0141                	addi	sp,sp,16
    80000ec6:	8082                	ret
    panic("pop_off - interruptible");
    80000ec8:	00007517          	auipc	a0,0x7
    80000ecc:	1c050513          	addi	a0,a0,448 # 80008088 <digits+0x40>
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	73c080e7          	jalr	1852(ra) # 8000060c <panic>
    panic("pop_off");
    80000ed8:	00007517          	auipc	a0,0x7
    80000edc:	1c850513          	addi	a0,a0,456 # 800080a0 <digits+0x58>
    80000ee0:	fffff097          	auipc	ra,0xfffff
    80000ee4:	72c080e7          	jalr	1836(ra) # 8000060c <panic>

0000000080000ee8 <release>:
{
    80000ee8:	1101                	addi	sp,sp,-32
    80000eea:	ec06                	sd	ra,24(sp)
    80000eec:	e822                	sd	s0,16(sp)
    80000eee:	e426                	sd	s1,8(sp)
    80000ef0:	1000                	addi	s0,sp,32
    80000ef2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	ec6080e7          	jalr	-314(ra) # 80000dba <holding>
    80000efc:	c115                	beqz	a0,80000f20 <release+0x38>
  lk->cpu = 0;
    80000efe:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000f02:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000f06:	0f50000f          	fence	iorw,ow
    80000f0a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	f7a080e7          	jalr	-134(ra) # 80000e88 <pop_off>
}
    80000f16:	60e2                	ld	ra,24(sp)
    80000f18:	6442                	ld	s0,16(sp)
    80000f1a:	64a2                	ld	s1,8(sp)
    80000f1c:	6105                	addi	sp,sp,32
    80000f1e:	8082                	ret
    panic("release");
    80000f20:	00007517          	auipc	a0,0x7
    80000f24:	18850513          	addi	a0,a0,392 # 800080a8 <digits+0x60>
    80000f28:	fffff097          	auipc	ra,0xfffff
    80000f2c:	6e4080e7          	jalr	1764(ra) # 8000060c <panic>

0000000080000f30 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f30:	1141                	addi	sp,sp,-16
    80000f32:	e422                	sd	s0,8(sp)
    80000f34:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f36:	ca19                	beqz	a2,80000f4c <memset+0x1c>
    80000f38:	87aa                	mv	a5,a0
    80000f3a:	1602                	slli	a2,a2,0x20
    80000f3c:	9201                	srli	a2,a2,0x20
    80000f3e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f42:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f46:	0785                	addi	a5,a5,1
    80000f48:	fee79de3          	bne	a5,a4,80000f42 <memset+0x12>
  }
  return dst;
}
    80000f4c:	6422                	ld	s0,8(sp)
    80000f4e:	0141                	addi	sp,sp,16
    80000f50:	8082                	ret

0000000080000f52 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f52:	1141                	addi	sp,sp,-16
    80000f54:	e422                	sd	s0,8(sp)
    80000f56:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f58:	ca05                	beqz	a2,80000f88 <memcmp+0x36>
    80000f5a:	fff6069b          	addiw	a3,a2,-1
    80000f5e:	1682                	slli	a3,a3,0x20
    80000f60:	9281                	srli	a3,a3,0x20
    80000f62:	0685                	addi	a3,a3,1
    80000f64:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f66:	00054783          	lbu	a5,0(a0)
    80000f6a:	0005c703          	lbu	a4,0(a1)
    80000f6e:	00e79863          	bne	a5,a4,80000f7e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f72:	0505                	addi	a0,a0,1
    80000f74:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f76:	fed518e3          	bne	a0,a3,80000f66 <memcmp+0x14>
  }

  return 0;
    80000f7a:	4501                	li	a0,0
    80000f7c:	a019                	j	80000f82 <memcmp+0x30>
      return *s1 - *s2;
    80000f7e:	40e7853b          	subw	a0,a5,a4
}
    80000f82:	6422                	ld	s0,8(sp)
    80000f84:	0141                	addi	sp,sp,16
    80000f86:	8082                	ret
  return 0;
    80000f88:	4501                	li	a0,0
    80000f8a:	bfe5                	j	80000f82 <memcmp+0x30>

0000000080000f8c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f8c:	1141                	addi	sp,sp,-16
    80000f8e:	e422                	sd	s0,8(sp)
    80000f90:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f92:	c205                	beqz	a2,80000fb2 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f94:	02a5e263          	bltu	a1,a0,80000fb8 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f98:	1602                	slli	a2,a2,0x20
    80000f9a:	9201                	srli	a2,a2,0x20
    80000f9c:	00c587b3          	add	a5,a1,a2
{
    80000fa0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000fa2:	0585                	addi	a1,a1,1
    80000fa4:	0705                	addi	a4,a4,1
    80000fa6:	fff5c683          	lbu	a3,-1(a1)
    80000faa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000fae:	fef59ae3          	bne	a1,a5,80000fa2 <memmove+0x16>

  return dst;
}
    80000fb2:	6422                	ld	s0,8(sp)
    80000fb4:	0141                	addi	sp,sp,16
    80000fb6:	8082                	ret
  if(s < d && s + n > d){
    80000fb8:	02061693          	slli	a3,a2,0x20
    80000fbc:	9281                	srli	a3,a3,0x20
    80000fbe:	00d58733          	add	a4,a1,a3
    80000fc2:	fce57be3          	bgeu	a0,a4,80000f98 <memmove+0xc>
    d += n;
    80000fc6:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000fc8:	fff6079b          	addiw	a5,a2,-1
    80000fcc:	1782                	slli	a5,a5,0x20
    80000fce:	9381                	srli	a5,a5,0x20
    80000fd0:	fff7c793          	not	a5,a5
    80000fd4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000fd6:	177d                	addi	a4,a4,-1
    80000fd8:	16fd                	addi	a3,a3,-1
    80000fda:	00074603          	lbu	a2,0(a4)
    80000fde:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000fe2:	fee79ae3          	bne	a5,a4,80000fd6 <memmove+0x4a>
    80000fe6:	b7f1                	j	80000fb2 <memmove+0x26>

0000000080000fe8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e406                	sd	ra,8(sp)
    80000fec:	e022                	sd	s0,0(sp)
    80000fee:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	f9c080e7          	jalr	-100(ra) # 80000f8c <memmove>
}
    80000ff8:	60a2                	ld	ra,8(sp)
    80000ffa:	6402                	ld	s0,0(sp)
    80000ffc:	0141                	addi	sp,sp,16
    80000ffe:	8082                	ret

0000000080001000 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001000:	1141                	addi	sp,sp,-16
    80001002:	e422                	sd	s0,8(sp)
    80001004:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001006:	ce11                	beqz	a2,80001022 <strncmp+0x22>
    80001008:	00054783          	lbu	a5,0(a0)
    8000100c:	cf89                	beqz	a5,80001026 <strncmp+0x26>
    8000100e:	0005c703          	lbu	a4,0(a1)
    80001012:	00f71a63          	bne	a4,a5,80001026 <strncmp+0x26>
    n--, p++, q++;
    80001016:	367d                	addiw	a2,a2,-1
    80001018:	0505                	addi	a0,a0,1
    8000101a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000101c:	f675                	bnez	a2,80001008 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000101e:	4501                	li	a0,0
    80001020:	a809                	j	80001032 <strncmp+0x32>
    80001022:	4501                	li	a0,0
    80001024:	a039                	j	80001032 <strncmp+0x32>
  if(n == 0)
    80001026:	ca09                	beqz	a2,80001038 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001028:	00054503          	lbu	a0,0(a0)
    8000102c:	0005c783          	lbu	a5,0(a1)
    80001030:	9d1d                	subw	a0,a0,a5
}
    80001032:	6422                	ld	s0,8(sp)
    80001034:	0141                	addi	sp,sp,16
    80001036:	8082                	ret
    return 0;
    80001038:	4501                	li	a0,0
    8000103a:	bfe5                	j	80001032 <strncmp+0x32>

000000008000103c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000103c:	1141                	addi	sp,sp,-16
    8000103e:	e422                	sd	s0,8(sp)
    80001040:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001042:	872a                	mv	a4,a0
    80001044:	8832                	mv	a6,a2
    80001046:	367d                	addiw	a2,a2,-1
    80001048:	01005963          	blez	a6,8000105a <strncpy+0x1e>
    8000104c:	0705                	addi	a4,a4,1
    8000104e:	0005c783          	lbu	a5,0(a1)
    80001052:	fef70fa3          	sb	a5,-1(a4)
    80001056:	0585                	addi	a1,a1,1
    80001058:	f7f5                	bnez	a5,80001044 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000105a:	86ba                	mv	a3,a4
    8000105c:	00c05c63          	blez	a2,80001074 <strncpy+0x38>
    *s++ = 0;
    80001060:	0685                	addi	a3,a3,1
    80001062:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001066:	fff6c793          	not	a5,a3
    8000106a:	9fb9                	addw	a5,a5,a4
    8000106c:	010787bb          	addw	a5,a5,a6
    80001070:	fef048e3          	bgtz	a5,80001060 <strncpy+0x24>
  return os;
}
    80001074:	6422                	ld	s0,8(sp)
    80001076:	0141                	addi	sp,sp,16
    80001078:	8082                	ret

000000008000107a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e422                	sd	s0,8(sp)
    8000107e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001080:	02c05363          	blez	a2,800010a6 <safestrcpy+0x2c>
    80001084:	fff6069b          	addiw	a3,a2,-1
    80001088:	1682                	slli	a3,a3,0x20
    8000108a:	9281                	srli	a3,a3,0x20
    8000108c:	96ae                	add	a3,a3,a1
    8000108e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001090:	00d58963          	beq	a1,a3,800010a2 <safestrcpy+0x28>
    80001094:	0585                	addi	a1,a1,1
    80001096:	0785                	addi	a5,a5,1
    80001098:	fff5c703          	lbu	a4,-1(a1)
    8000109c:	fee78fa3          	sb	a4,-1(a5)
    800010a0:	fb65                	bnez	a4,80001090 <safestrcpy+0x16>
    ;
  *s = 0;
    800010a2:	00078023          	sb	zero,0(a5)
  return os;
}
    800010a6:	6422                	ld	s0,8(sp)
    800010a8:	0141                	addi	sp,sp,16
    800010aa:	8082                	ret

00000000800010ac <strlen>:

int
strlen(const char *s)
{
    800010ac:	1141                	addi	sp,sp,-16
    800010ae:	e422                	sd	s0,8(sp)
    800010b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800010b2:	00054783          	lbu	a5,0(a0)
    800010b6:	cf91                	beqz	a5,800010d2 <strlen+0x26>
    800010b8:	0505                	addi	a0,a0,1
    800010ba:	87aa                	mv	a5,a0
    800010bc:	4685                	li	a3,1
    800010be:	9e89                	subw	a3,a3,a0
    800010c0:	00f6853b          	addw	a0,a3,a5
    800010c4:	0785                	addi	a5,a5,1
    800010c6:	fff7c703          	lbu	a4,-1(a5)
    800010ca:	fb7d                	bnez	a4,800010c0 <strlen+0x14>
    ;
  return n;
}
    800010cc:	6422                	ld	s0,8(sp)
    800010ce:	0141                	addi	sp,sp,16
    800010d0:	8082                	ret
  for(n = 0; s[n]; n++)
    800010d2:	4501                	li	a0,0
    800010d4:	bfe5                	j	800010cc <strlen+0x20>

00000000800010d6 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800010d6:	1141                	addi	sp,sp,-16
    800010d8:	e406                	sd	ra,8(sp)
    800010da:	e022                	sd	s0,0(sp)
    800010dc:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800010de:	00001097          	auipc	ra,0x1
    800010e2:	b06080e7          	jalr	-1274(ra) # 80001be4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800010e6:	00008717          	auipc	a4,0x8
    800010ea:	86270713          	addi	a4,a4,-1950 # 80008948 <started>
  if(cpuid() == 0){
    800010ee:	c139                	beqz	a0,80001134 <main+0x5e>
    while(started == 0)
    800010f0:	431c                	lw	a5,0(a4)
    800010f2:	2781                	sext.w	a5,a5
    800010f4:	dff5                	beqz	a5,800010f0 <main+0x1a>
      ;
    __sync_synchronize();
    800010f6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800010fa:	00001097          	auipc	ra,0x1
    800010fe:	aea080e7          	jalr	-1302(ra) # 80001be4 <cpuid>
    80001102:	85aa                	mv	a1,a0
    80001104:	00007517          	auipc	a0,0x7
    80001108:	fc450513          	addi	a0,a0,-60 # 800080c8 <digits+0x80>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	54a080e7          	jalr	1354(ra) # 80000656 <printf>
    kvminithart();    // turn on paging
    80001114:	00000097          	auipc	ra,0x0
    80001118:	0d8080e7          	jalr	216(ra) # 800011ec <kvminithart>
    trapinithart();   // install kernel trap vector
    8000111c:	00002097          	auipc	ra,0x2
    80001120:	c84080e7          	jalr	-892(ra) # 80002da0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001124:	00005097          	auipc	ra,0x5
    80001128:	3cc080e7          	jalr	972(ra) # 800064f0 <plicinithart>
  }

  scheduler();        
    8000112c:	00001097          	auipc	ra,0x1
    80001130:	0f6080e7          	jalr	246(ra) # 80002222 <scheduler>
    consoleinit();
    80001134:	fffff097          	auipc	ra,0xfffff
    80001138:	3ea080e7          	jalr	1002(ra) # 8000051e <consoleinit>
    printfinit();
    8000113c:	fffff097          	auipc	ra,0xfffff
    80001140:	6fa080e7          	jalr	1786(ra) # 80000836 <printfinit>
    printf("\n");
    80001144:	00007517          	auipc	a0,0x7
    80001148:	f9450513          	addi	a0,a0,-108 # 800080d8 <digits+0x90>
    8000114c:	fffff097          	auipc	ra,0xfffff
    80001150:	50a080e7          	jalr	1290(ra) # 80000656 <printf>
    printf("xv6 kernel is booting\n");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	f5c50513          	addi	a0,a0,-164 # 800080b0 <digits+0x68>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	4fa080e7          	jalr	1274(ra) # 80000656 <printf>
    printf("\n");
    80001164:	00007517          	auipc	a0,0x7
    80001168:	f7450513          	addi	a0,a0,-140 # 800080d8 <digits+0x90>
    8000116c:	fffff097          	auipc	ra,0xfffff
    80001170:	4ea080e7          	jalr	1258(ra) # 80000656 <printf>
    kinit();         // physical page allocator
    80001174:	00000097          	auipc	ra,0x0
    80001178:	b42080e7          	jalr	-1214(ra) # 80000cb6 <kinit>
    kvminit();       // create kernel page table
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	326080e7          	jalr	806(ra) # 800014a2 <kvminit>
    kvminithart();   // turn on paging
    80001184:	00000097          	auipc	ra,0x0
    80001188:	068080e7          	jalr	104(ra) # 800011ec <kvminithart>
    procinit();      // process table
    8000118c:	00001097          	auipc	ra,0x1
    80001190:	99e080e7          	jalr	-1634(ra) # 80001b2a <procinit>
    trapinit();      // trap vectors
    80001194:	00002097          	auipc	ra,0x2
    80001198:	be4080e7          	jalr	-1052(ra) # 80002d78 <trapinit>
    trapinithart();  // install kernel trap vector
    8000119c:	00002097          	auipc	ra,0x2
    800011a0:	c04080e7          	jalr	-1020(ra) # 80002da0 <trapinithart>
    plicinit();      // set up interrupt controller
    800011a4:	00005097          	auipc	ra,0x5
    800011a8:	336080e7          	jalr	822(ra) # 800064da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800011ac:	00005097          	auipc	ra,0x5
    800011b0:	344080e7          	jalr	836(ra) # 800064f0 <plicinithart>
    binit();         // buffer cache
    800011b4:	00002097          	auipc	ra,0x2
    800011b8:	4e8080e7          	jalr	1256(ra) # 8000369c <binit>
    iinit();         // inode table
    800011bc:	00003097          	auipc	ra,0x3
    800011c0:	b8c080e7          	jalr	-1140(ra) # 80003d48 <iinit>
    fileinit();      // file table
    800011c4:	00004097          	auipc	ra,0x4
    800011c8:	b2a080e7          	jalr	-1238(ra) # 80004cee <fileinit>
    virtio_disk_init(); // emulated hard disk
    800011cc:	00005097          	auipc	ra,0x5
    800011d0:	42c080e7          	jalr	1068(ra) # 800065f8 <virtio_disk_init>
    userinit();      // first user process
    800011d4:	00001097          	auipc	ra,0x1
    800011d8:	d4e080e7          	jalr	-690(ra) # 80001f22 <userinit>
    __sync_synchronize();
    800011dc:	0ff0000f          	fence
    started = 1;
    800011e0:	4785                	li	a5,1
    800011e2:	00007717          	auipc	a4,0x7
    800011e6:	76f72323          	sw	a5,1894(a4) # 80008948 <started>
    800011ea:	b789                	j	8000112c <main+0x56>

00000000800011ec <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e422                	sd	s0,8(sp)
    800011f0:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800011f2:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800011f6:	00007797          	auipc	a5,0x7
    800011fa:	75a7b783          	ld	a5,1882(a5) # 80008950 <kernel_pagetable>
    800011fe:	83b1                	srli	a5,a5,0xc
    80001200:	577d                	li	a4,-1
    80001202:	177e                	slli	a4,a4,0x3f
    80001204:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001206:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000120a:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000120e:	6422                	ld	s0,8(sp)
    80001210:	0141                	addi	sp,sp,16
    80001212:	8082                	ret

0000000080001214 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001214:	7139                	addi	sp,sp,-64
    80001216:	fc06                	sd	ra,56(sp)
    80001218:	f822                	sd	s0,48(sp)
    8000121a:	f426                	sd	s1,40(sp)
    8000121c:	f04a                	sd	s2,32(sp)
    8000121e:	ec4e                	sd	s3,24(sp)
    80001220:	e852                	sd	s4,16(sp)
    80001222:	e456                	sd	s5,8(sp)
    80001224:	e05a                	sd	s6,0(sp)
    80001226:	0080                	addi	s0,sp,64
    80001228:	84aa                	mv	s1,a0
    8000122a:	89ae                	mv	s3,a1
    8000122c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000122e:	57fd                	li	a5,-1
    80001230:	83e9                	srli	a5,a5,0x1a
    80001232:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001234:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001236:	04b7f263          	bgeu	a5,a1,8000127a <walk+0x66>
    panic("walk");
    8000123a:	00007517          	auipc	a0,0x7
    8000123e:	ea650513          	addi	a0,a0,-346 # 800080e0 <digits+0x98>
    80001242:	fffff097          	auipc	ra,0xfffff
    80001246:	3ca080e7          	jalr	970(ra) # 8000060c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000124a:	060a8663          	beqz	s5,800012b6 <walk+0xa2>
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	8ba080e7          	jalr	-1862(ra) # 80000b08 <kalloc>
    80001256:	84aa                	mv	s1,a0
    80001258:	c529                	beqz	a0,800012a2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000125a:	6605                	lui	a2,0x1
    8000125c:	4581                	li	a1,0
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	cd2080e7          	jalr	-814(ra) # 80000f30 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001266:	00c4d793          	srli	a5,s1,0xc
    8000126a:	07aa                	slli	a5,a5,0xa
    8000126c:	0017e793          	ori	a5,a5,1
    80001270:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001274:	3a5d                	addiw	s4,s4,-9
    80001276:	036a0063          	beq	s4,s6,80001296 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000127a:	0149d933          	srl	s2,s3,s4
    8000127e:	1ff97913          	andi	s2,s2,511
    80001282:	090e                	slli	s2,s2,0x3
    80001284:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001286:	00093483          	ld	s1,0(s2)
    8000128a:	0014f793          	andi	a5,s1,1
    8000128e:	dfd5                	beqz	a5,8000124a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001290:	80a9                	srli	s1,s1,0xa
    80001292:	04b2                	slli	s1,s1,0xc
    80001294:	b7c5                	j	80001274 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001296:	00c9d513          	srli	a0,s3,0xc
    8000129a:	1ff57513          	andi	a0,a0,511
    8000129e:	050e                	slli	a0,a0,0x3
    800012a0:	9526                	add	a0,a0,s1
}
    800012a2:	70e2                	ld	ra,56(sp)
    800012a4:	7442                	ld	s0,48(sp)
    800012a6:	74a2                	ld	s1,40(sp)
    800012a8:	7902                	ld	s2,32(sp)
    800012aa:	69e2                	ld	s3,24(sp)
    800012ac:	6a42                	ld	s4,16(sp)
    800012ae:	6aa2                	ld	s5,8(sp)
    800012b0:	6b02                	ld	s6,0(sp)
    800012b2:	6121                	addi	sp,sp,64
    800012b4:	8082                	ret
        return 0;
    800012b6:	4501                	li	a0,0
    800012b8:	b7ed                	j	800012a2 <walk+0x8e>

00000000800012ba <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800012ba:	57fd                	li	a5,-1
    800012bc:	83e9                	srli	a5,a5,0x1a
    800012be:	00b7f463          	bgeu	a5,a1,800012c6 <walkaddr+0xc>
    return 0;
    800012c2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800012c4:	8082                	ret
{
    800012c6:	1141                	addi	sp,sp,-16
    800012c8:	e406                	sd	ra,8(sp)
    800012ca:	e022                	sd	s0,0(sp)
    800012cc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012ce:	4601                	li	a2,0
    800012d0:	00000097          	auipc	ra,0x0
    800012d4:	f44080e7          	jalr	-188(ra) # 80001214 <walk>
  if(pte == 0)
    800012d8:	c105                	beqz	a0,800012f8 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012da:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012dc:	0117f693          	andi	a3,a5,17
    800012e0:	4745                	li	a4,17
    return 0;
    800012e2:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012e4:	00e68663          	beq	a3,a4,800012f0 <walkaddr+0x36>
}
    800012e8:	60a2                	ld	ra,8(sp)
    800012ea:	6402                	ld	s0,0(sp)
    800012ec:	0141                	addi	sp,sp,16
    800012ee:	8082                	ret
  pa = PTE2PA(*pte);
    800012f0:	00a7d513          	srli	a0,a5,0xa
    800012f4:	0532                	slli	a0,a0,0xc
  return pa;
    800012f6:	bfcd                	j	800012e8 <walkaddr+0x2e>
    return 0;
    800012f8:	4501                	li	a0,0
    800012fa:	b7fd                	j	800012e8 <walkaddr+0x2e>

00000000800012fc <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012fc:	715d                	addi	sp,sp,-80
    800012fe:	e486                	sd	ra,72(sp)
    80001300:	e0a2                	sd	s0,64(sp)
    80001302:	fc26                	sd	s1,56(sp)
    80001304:	f84a                	sd	s2,48(sp)
    80001306:	f44e                	sd	s3,40(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e85a                	sd	s6,16(sp)
    8000130e:	e45e                	sd	s7,8(sp)
    80001310:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001312:	c639                	beqz	a2,80001360 <mappages+0x64>
    80001314:	8aaa                	mv	s5,a0
    80001316:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001318:	77fd                	lui	a5,0xfffff
    8000131a:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000131e:	15fd                	addi	a1,a1,-1
    80001320:	00c589b3          	add	s3,a1,a2
    80001324:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001328:	8952                	mv	s2,s4
    8000132a:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000132e:	6b85                	lui	s7,0x1
    80001330:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001334:	4605                	li	a2,1
    80001336:	85ca                	mv	a1,s2
    80001338:	8556                	mv	a0,s5
    8000133a:	00000097          	auipc	ra,0x0
    8000133e:	eda080e7          	jalr	-294(ra) # 80001214 <walk>
    80001342:	cd1d                	beqz	a0,80001380 <mappages+0x84>
    if(*pte & PTE_V)
    80001344:	611c                	ld	a5,0(a0)
    80001346:	8b85                	andi	a5,a5,1
    80001348:	e785                	bnez	a5,80001370 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000134a:	80b1                	srli	s1,s1,0xc
    8000134c:	04aa                	slli	s1,s1,0xa
    8000134e:	0164e4b3          	or	s1,s1,s6
    80001352:	0014e493          	ori	s1,s1,1
    80001356:	e104                	sd	s1,0(a0)
    if(a == last)
    80001358:	05390063          	beq	s2,s3,80001398 <mappages+0x9c>
    a += PGSIZE;
    8000135c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000135e:	bfc9                	j	80001330 <mappages+0x34>
    panic("mappages: size");
    80001360:	00007517          	auipc	a0,0x7
    80001364:	d8850513          	addi	a0,a0,-632 # 800080e8 <digits+0xa0>
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	2a4080e7          	jalr	676(ra) # 8000060c <panic>
      panic("mappages: remap");
    80001370:	00007517          	auipc	a0,0x7
    80001374:	d8850513          	addi	a0,a0,-632 # 800080f8 <digits+0xb0>
    80001378:	fffff097          	auipc	ra,0xfffff
    8000137c:	294080e7          	jalr	660(ra) # 8000060c <panic>
      return -1;
    80001380:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001382:	60a6                	ld	ra,72(sp)
    80001384:	6406                	ld	s0,64(sp)
    80001386:	74e2                	ld	s1,56(sp)
    80001388:	7942                	ld	s2,48(sp)
    8000138a:	79a2                	ld	s3,40(sp)
    8000138c:	7a02                	ld	s4,32(sp)
    8000138e:	6ae2                	ld	s5,24(sp)
    80001390:	6b42                	ld	s6,16(sp)
    80001392:	6ba2                	ld	s7,8(sp)
    80001394:	6161                	addi	sp,sp,80
    80001396:	8082                	ret
  return 0;
    80001398:	4501                	li	a0,0
    8000139a:	b7e5                	j	80001382 <mappages+0x86>

000000008000139c <kvmmap>:
{
    8000139c:	1141                	addi	sp,sp,-16
    8000139e:	e406                	sd	ra,8(sp)
    800013a0:	e022                	sd	s0,0(sp)
    800013a2:	0800                	addi	s0,sp,16
    800013a4:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800013a6:	86b2                	mv	a3,a2
    800013a8:	863e                	mv	a2,a5
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	f52080e7          	jalr	-174(ra) # 800012fc <mappages>
    800013b2:	e509                	bnez	a0,800013bc <kvmmap+0x20>
}
    800013b4:	60a2                	ld	ra,8(sp)
    800013b6:	6402                	ld	s0,0(sp)
    800013b8:	0141                	addi	sp,sp,16
    800013ba:	8082                	ret
    panic("kvmmap");
    800013bc:	00007517          	auipc	a0,0x7
    800013c0:	d4c50513          	addi	a0,a0,-692 # 80008108 <digits+0xc0>
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	248080e7          	jalr	584(ra) # 8000060c <panic>

00000000800013cc <kvmmake>:
{
    800013cc:	1101                	addi	sp,sp,-32
    800013ce:	ec06                	sd	ra,24(sp)
    800013d0:	e822                	sd	s0,16(sp)
    800013d2:	e426                	sd	s1,8(sp)
    800013d4:	e04a                	sd	s2,0(sp)
    800013d6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800013d8:	fffff097          	auipc	ra,0xfffff
    800013dc:	730080e7          	jalr	1840(ra) # 80000b08 <kalloc>
    800013e0:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800013e2:	6605                	lui	a2,0x1
    800013e4:	4581                	li	a1,0
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	b4a080e7          	jalr	-1206(ra) # 80000f30 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013ee:	4719                	li	a4,6
    800013f0:	6685                	lui	a3,0x1
    800013f2:	10000637          	lui	a2,0x10000
    800013f6:	100005b7          	lui	a1,0x10000
    800013fa:	8526                	mv	a0,s1
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	fa0080e7          	jalr	-96(ra) # 8000139c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001404:	4719                	li	a4,6
    80001406:	6685                	lui	a3,0x1
    80001408:	10001637          	lui	a2,0x10001
    8000140c:	100015b7          	lui	a1,0x10001
    80001410:	8526                	mv	a0,s1
    80001412:	00000097          	auipc	ra,0x0
    80001416:	f8a080e7          	jalr	-118(ra) # 8000139c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000141a:	4719                	li	a4,6
    8000141c:	004006b7          	lui	a3,0x400
    80001420:	0c000637          	lui	a2,0xc000
    80001424:	0c0005b7          	lui	a1,0xc000
    80001428:	8526                	mv	a0,s1
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	f72080e7          	jalr	-142(ra) # 8000139c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001432:	00007917          	auipc	s2,0x7
    80001436:	bce90913          	addi	s2,s2,-1074 # 80008000 <etext>
    8000143a:	4729                	li	a4,10
    8000143c:	80007697          	auipc	a3,0x80007
    80001440:	bc468693          	addi	a3,a3,-1084 # 8000 <_entry-0x7fff8000>
    80001444:	4605                	li	a2,1
    80001446:	067e                	slli	a2,a2,0x1f
    80001448:	85b2                	mv	a1,a2
    8000144a:	8526                	mv	a0,s1
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	f50080e7          	jalr	-176(ra) # 8000139c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001454:	4719                	li	a4,6
    80001456:	46c5                	li	a3,17
    80001458:	06ee                	slli	a3,a3,0x1b
    8000145a:	412686b3          	sub	a3,a3,s2
    8000145e:	864a                	mv	a2,s2
    80001460:	85ca                	mv	a1,s2
    80001462:	8526                	mv	a0,s1
    80001464:	00000097          	auipc	ra,0x0
    80001468:	f38080e7          	jalr	-200(ra) # 8000139c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000146c:	4729                	li	a4,10
    8000146e:	6685                	lui	a3,0x1
    80001470:	00006617          	auipc	a2,0x6
    80001474:	b9060613          	addi	a2,a2,-1136 # 80007000 <_trampoline>
    80001478:	040005b7          	lui	a1,0x4000
    8000147c:	15fd                	addi	a1,a1,-1
    8000147e:	05b2                	slli	a1,a1,0xc
    80001480:	8526                	mv	a0,s1
    80001482:	00000097          	auipc	ra,0x0
    80001486:	f1a080e7          	jalr	-230(ra) # 8000139c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000148a:	8526                	mv	a0,s1
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	608080e7          	jalr	1544(ra) # 80001a94 <proc_mapstacks>
}
    80001494:	8526                	mv	a0,s1
    80001496:	60e2                	ld	ra,24(sp)
    80001498:	6442                	ld	s0,16(sp)
    8000149a:	64a2                	ld	s1,8(sp)
    8000149c:	6902                	ld	s2,0(sp)
    8000149e:	6105                	addi	sp,sp,32
    800014a0:	8082                	ret

00000000800014a2 <kvminit>:
{
    800014a2:	1141                	addi	sp,sp,-16
    800014a4:	e406                	sd	ra,8(sp)
    800014a6:	e022                	sd	s0,0(sp)
    800014a8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800014aa:	00000097          	auipc	ra,0x0
    800014ae:	f22080e7          	jalr	-222(ra) # 800013cc <kvmmake>
    800014b2:	00007797          	auipc	a5,0x7
    800014b6:	48a7bf23          	sd	a0,1182(a5) # 80008950 <kernel_pagetable>
}
    800014ba:	60a2                	ld	ra,8(sp)
    800014bc:	6402                	ld	s0,0(sp)
    800014be:	0141                	addi	sp,sp,16
    800014c0:	8082                	ret

00000000800014c2 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800014c2:	715d                	addi	sp,sp,-80
    800014c4:	e486                	sd	ra,72(sp)
    800014c6:	e0a2                	sd	s0,64(sp)
    800014c8:	fc26                	sd	s1,56(sp)
    800014ca:	f84a                	sd	s2,48(sp)
    800014cc:	f44e                	sd	s3,40(sp)
    800014ce:	f052                	sd	s4,32(sp)
    800014d0:	ec56                	sd	s5,24(sp)
    800014d2:	e85a                	sd	s6,16(sp)
    800014d4:	e45e                	sd	s7,8(sp)
    800014d6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800014d8:	03459793          	slli	a5,a1,0x34
    800014dc:	e795                	bnez	a5,80001508 <uvmunmap+0x46>
    800014de:	8a2a                	mv	s4,a0
    800014e0:	892e                	mv	s2,a1
    800014e2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014e4:	0632                	slli	a2,a2,0xc
    800014e6:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800014ea:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014ec:	6b05                	lui	s6,0x1
    800014ee:	0735e263          	bltu	a1,s3,80001552 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800014f2:	60a6                	ld	ra,72(sp)
    800014f4:	6406                	ld	s0,64(sp)
    800014f6:	74e2                	ld	s1,56(sp)
    800014f8:	7942                	ld	s2,48(sp)
    800014fa:	79a2                	ld	s3,40(sp)
    800014fc:	7a02                	ld	s4,32(sp)
    800014fe:	6ae2                	ld	s5,24(sp)
    80001500:	6b42                	ld	s6,16(sp)
    80001502:	6ba2                	ld	s7,8(sp)
    80001504:	6161                	addi	sp,sp,80
    80001506:	8082                	ret
    panic("uvmunmap: not aligned");
    80001508:	00007517          	auipc	a0,0x7
    8000150c:	c0850513          	addi	a0,a0,-1016 # 80008110 <digits+0xc8>
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	0fc080e7          	jalr	252(ra) # 8000060c <panic>
      panic("uvmunmap: walk");
    80001518:	00007517          	auipc	a0,0x7
    8000151c:	c1050513          	addi	a0,a0,-1008 # 80008128 <digits+0xe0>
    80001520:	fffff097          	auipc	ra,0xfffff
    80001524:	0ec080e7          	jalr	236(ra) # 8000060c <panic>
      panic("uvmunmap: not mapped");
    80001528:	00007517          	auipc	a0,0x7
    8000152c:	c1050513          	addi	a0,a0,-1008 # 80008138 <digits+0xf0>
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	0dc080e7          	jalr	220(ra) # 8000060c <panic>
      panic("uvmunmap: not a leaf");
    80001538:	00007517          	auipc	a0,0x7
    8000153c:	c1850513          	addi	a0,a0,-1000 # 80008150 <digits+0x108>
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	0cc080e7          	jalr	204(ra) # 8000060c <panic>
    *pte = 0;
    80001548:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000154c:	995a                	add	s2,s2,s6
    8000154e:	fb3972e3          	bgeu	s2,s3,800014f2 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001552:	4601                	li	a2,0
    80001554:	85ca                	mv	a1,s2
    80001556:	8552                	mv	a0,s4
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	cbc080e7          	jalr	-836(ra) # 80001214 <walk>
    80001560:	84aa                	mv	s1,a0
    80001562:	d95d                	beqz	a0,80001518 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001564:	6108                	ld	a0,0(a0)
    80001566:	00157793          	andi	a5,a0,1
    8000156a:	dfdd                	beqz	a5,80001528 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000156c:	3ff57793          	andi	a5,a0,1023
    80001570:	fd7784e3          	beq	a5,s7,80001538 <uvmunmap+0x76>
    if(do_free){
    80001574:	fc0a8ae3          	beqz	s5,80001548 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001578:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000157a:	0532                	slli	a0,a0,0xc
    8000157c:	fffff097          	auipc	ra,0xfffff
    80001580:	652080e7          	jalr	1618(ra) # 80000bce <kfree>
    80001584:	b7d1                	j	80001548 <uvmunmap+0x86>

0000000080001586 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001586:	1101                	addi	sp,sp,-32
    80001588:	ec06                	sd	ra,24(sp)
    8000158a:	e822                	sd	s0,16(sp)
    8000158c:	e426                	sd	s1,8(sp)
    8000158e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001590:	fffff097          	auipc	ra,0xfffff
    80001594:	578080e7          	jalr	1400(ra) # 80000b08 <kalloc>
    80001598:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000159a:	c519                	beqz	a0,800015a8 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000159c:	6605                	lui	a2,0x1
    8000159e:	4581                	li	a1,0
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	990080e7          	jalr	-1648(ra) # 80000f30 <memset>
  return pagetable;
}
    800015a8:	8526                	mv	a0,s1
    800015aa:	60e2                	ld	ra,24(sp)
    800015ac:	6442                	ld	s0,16(sp)
    800015ae:	64a2                	ld	s1,8(sp)
    800015b0:	6105                	addi	sp,sp,32
    800015b2:	8082                	ret

00000000800015b4 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800015b4:	7179                	addi	sp,sp,-48
    800015b6:	f406                	sd	ra,40(sp)
    800015b8:	f022                	sd	s0,32(sp)
    800015ba:	ec26                	sd	s1,24(sp)
    800015bc:	e84a                	sd	s2,16(sp)
    800015be:	e44e                	sd	s3,8(sp)
    800015c0:	e052                	sd	s4,0(sp)
    800015c2:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800015c4:	6785                	lui	a5,0x1
    800015c6:	04f67863          	bgeu	a2,a5,80001616 <uvmfirst+0x62>
    800015ca:	8a2a                	mv	s4,a0
    800015cc:	89ae                	mv	s3,a1
    800015ce:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800015d0:	fffff097          	auipc	ra,0xfffff
    800015d4:	538080e7          	jalr	1336(ra) # 80000b08 <kalloc>
    800015d8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015da:	6605                	lui	a2,0x1
    800015dc:	4581                	li	a1,0
    800015de:	00000097          	auipc	ra,0x0
    800015e2:	952080e7          	jalr	-1710(ra) # 80000f30 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015e6:	4779                	li	a4,30
    800015e8:	86ca                	mv	a3,s2
    800015ea:	6605                	lui	a2,0x1
    800015ec:	4581                	li	a1,0
    800015ee:	8552                	mv	a0,s4
    800015f0:	00000097          	auipc	ra,0x0
    800015f4:	d0c080e7          	jalr	-756(ra) # 800012fc <mappages>
  memmove(mem, src, sz);
    800015f8:	8626                	mv	a2,s1
    800015fa:	85ce                	mv	a1,s3
    800015fc:	854a                	mv	a0,s2
    800015fe:	00000097          	auipc	ra,0x0
    80001602:	98e080e7          	jalr	-1650(ra) # 80000f8c <memmove>
}
    80001606:	70a2                	ld	ra,40(sp)
    80001608:	7402                	ld	s0,32(sp)
    8000160a:	64e2                	ld	s1,24(sp)
    8000160c:	6942                	ld	s2,16(sp)
    8000160e:	69a2                	ld	s3,8(sp)
    80001610:	6a02                	ld	s4,0(sp)
    80001612:	6145                	addi	sp,sp,48
    80001614:	8082                	ret
    panic("uvmfirst: more than a page");
    80001616:	00007517          	auipc	a0,0x7
    8000161a:	b5250513          	addi	a0,a0,-1198 # 80008168 <digits+0x120>
    8000161e:	fffff097          	auipc	ra,0xfffff
    80001622:	fee080e7          	jalr	-18(ra) # 8000060c <panic>

0000000080001626 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001626:	1101                	addi	sp,sp,-32
    80001628:	ec06                	sd	ra,24(sp)
    8000162a:	e822                	sd	s0,16(sp)
    8000162c:	e426                	sd	s1,8(sp)
    8000162e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001630:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001632:	00b67d63          	bgeu	a2,a1,8000164c <uvmdealloc+0x26>
    80001636:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001638:	6785                	lui	a5,0x1
    8000163a:	17fd                	addi	a5,a5,-1
    8000163c:	00f60733          	add	a4,a2,a5
    80001640:	767d                	lui	a2,0xfffff
    80001642:	8f71                	and	a4,a4,a2
    80001644:	97ae                	add	a5,a5,a1
    80001646:	8ff1                	and	a5,a5,a2
    80001648:	00f76863          	bltu	a4,a5,80001658 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000164c:	8526                	mv	a0,s1
    8000164e:	60e2                	ld	ra,24(sp)
    80001650:	6442                	ld	s0,16(sp)
    80001652:	64a2                	ld	s1,8(sp)
    80001654:	6105                	addi	sp,sp,32
    80001656:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001658:	8f99                	sub	a5,a5,a4
    8000165a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000165c:	4685                	li	a3,1
    8000165e:	0007861b          	sext.w	a2,a5
    80001662:	85ba                	mv	a1,a4
    80001664:	00000097          	auipc	ra,0x0
    80001668:	e5e080e7          	jalr	-418(ra) # 800014c2 <uvmunmap>
    8000166c:	b7c5                	j	8000164c <uvmdealloc+0x26>

000000008000166e <uvmalloc>:
  if(newsz < oldsz)
    8000166e:	0ab66563          	bltu	a2,a1,80001718 <uvmalloc+0xaa>
{
    80001672:	7139                	addi	sp,sp,-64
    80001674:	fc06                	sd	ra,56(sp)
    80001676:	f822                	sd	s0,48(sp)
    80001678:	f426                	sd	s1,40(sp)
    8000167a:	f04a                	sd	s2,32(sp)
    8000167c:	ec4e                	sd	s3,24(sp)
    8000167e:	e852                	sd	s4,16(sp)
    80001680:	e456                	sd	s5,8(sp)
    80001682:	e05a                	sd	s6,0(sp)
    80001684:	0080                	addi	s0,sp,64
    80001686:	8aaa                	mv	s5,a0
    80001688:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000168a:	6985                	lui	s3,0x1
    8000168c:	19fd                	addi	s3,s3,-1
    8000168e:	95ce                	add	a1,a1,s3
    80001690:	79fd                	lui	s3,0xfffff
    80001692:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001696:	08c9f363          	bgeu	s3,a2,8000171c <uvmalloc+0xae>
    8000169a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000169c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	468080e7          	jalr	1128(ra) # 80000b08 <kalloc>
    800016a8:	84aa                	mv	s1,a0
    if(mem == 0){
    800016aa:	c51d                	beqz	a0,800016d8 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800016ac:	6605                	lui	a2,0x1
    800016ae:	4581                	li	a1,0
    800016b0:	00000097          	auipc	ra,0x0
    800016b4:	880080e7          	jalr	-1920(ra) # 80000f30 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800016b8:	875a                	mv	a4,s6
    800016ba:	86a6                	mv	a3,s1
    800016bc:	6605                	lui	a2,0x1
    800016be:	85ca                	mv	a1,s2
    800016c0:	8556                	mv	a0,s5
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	c3a080e7          	jalr	-966(ra) # 800012fc <mappages>
    800016ca:	e90d                	bnez	a0,800016fc <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016cc:	6785                	lui	a5,0x1
    800016ce:	993e                	add	s2,s2,a5
    800016d0:	fd4968e3          	bltu	s2,s4,800016a0 <uvmalloc+0x32>
  return newsz;
    800016d4:	8552                	mv	a0,s4
    800016d6:	a809                	j	800016e8 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800016d8:	864e                	mv	a2,s3
    800016da:	85ca                	mv	a1,s2
    800016dc:	8556                	mv	a0,s5
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	f48080e7          	jalr	-184(ra) # 80001626 <uvmdealloc>
      return 0;
    800016e6:	4501                	li	a0,0
}
    800016e8:	70e2                	ld	ra,56(sp)
    800016ea:	7442                	ld	s0,48(sp)
    800016ec:	74a2                	ld	s1,40(sp)
    800016ee:	7902                	ld	s2,32(sp)
    800016f0:	69e2                	ld	s3,24(sp)
    800016f2:	6a42                	ld	s4,16(sp)
    800016f4:	6aa2                	ld	s5,8(sp)
    800016f6:	6b02                	ld	s6,0(sp)
    800016f8:	6121                	addi	sp,sp,64
    800016fa:	8082                	ret
      kfree(mem);
    800016fc:	8526                	mv	a0,s1
    800016fe:	fffff097          	auipc	ra,0xfffff
    80001702:	4d0080e7          	jalr	1232(ra) # 80000bce <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001706:	864e                	mv	a2,s3
    80001708:	85ca                	mv	a1,s2
    8000170a:	8556                	mv	a0,s5
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	f1a080e7          	jalr	-230(ra) # 80001626 <uvmdealloc>
      return 0;
    80001714:	4501                	li	a0,0
    80001716:	bfc9                	j	800016e8 <uvmalloc+0x7a>
    return oldsz;
    80001718:	852e                	mv	a0,a1
}
    8000171a:	8082                	ret
  return newsz;
    8000171c:	8532                	mv	a0,a2
    8000171e:	b7e9                	j	800016e8 <uvmalloc+0x7a>

0000000080001720 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001720:	7179                	addi	sp,sp,-48
    80001722:	f406                	sd	ra,40(sp)
    80001724:	f022                	sd	s0,32(sp)
    80001726:	ec26                	sd	s1,24(sp)
    80001728:	e84a                	sd	s2,16(sp)
    8000172a:	e44e                	sd	s3,8(sp)
    8000172c:	e052                	sd	s4,0(sp)
    8000172e:	1800                	addi	s0,sp,48
    80001730:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001732:	84aa                	mv	s1,a0
    80001734:	6905                	lui	s2,0x1
    80001736:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001738:	4985                	li	s3,1
    8000173a:	a821                	j	80001752 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000173c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000173e:	0532                	slli	a0,a0,0xc
    80001740:	00000097          	auipc	ra,0x0
    80001744:	fe0080e7          	jalr	-32(ra) # 80001720 <freewalk>
      pagetable[i] = 0;
    80001748:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000174c:	04a1                	addi	s1,s1,8
    8000174e:	03248163          	beq	s1,s2,80001770 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001752:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001754:	00f57793          	andi	a5,a0,15
    80001758:	ff3782e3          	beq	a5,s3,8000173c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000175c:	8905                	andi	a0,a0,1
    8000175e:	d57d                	beqz	a0,8000174c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001760:	00007517          	auipc	a0,0x7
    80001764:	a2850513          	addi	a0,a0,-1496 # 80008188 <digits+0x140>
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	ea4080e7          	jalr	-348(ra) # 8000060c <panic>
    }
  }
  kfree((void*)pagetable);
    80001770:	8552                	mv	a0,s4
    80001772:	fffff097          	auipc	ra,0xfffff
    80001776:	45c080e7          	jalr	1116(ra) # 80000bce <kfree>
}
    8000177a:	70a2                	ld	ra,40(sp)
    8000177c:	7402                	ld	s0,32(sp)
    8000177e:	64e2                	ld	s1,24(sp)
    80001780:	6942                	ld	s2,16(sp)
    80001782:	69a2                	ld	s3,8(sp)
    80001784:	6a02                	ld	s4,0(sp)
    80001786:	6145                	addi	sp,sp,48
    80001788:	8082                	ret

000000008000178a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000178a:	1101                	addi	sp,sp,-32
    8000178c:	ec06                	sd	ra,24(sp)
    8000178e:	e822                	sd	s0,16(sp)
    80001790:	e426                	sd	s1,8(sp)
    80001792:	1000                	addi	s0,sp,32
    80001794:	84aa                	mv	s1,a0
  if(sz > 0)
    80001796:	e999                	bnez	a1,800017ac <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001798:	8526                	mv	a0,s1
    8000179a:	00000097          	auipc	ra,0x0
    8000179e:	f86080e7          	jalr	-122(ra) # 80001720 <freewalk>
}
    800017a2:	60e2                	ld	ra,24(sp)
    800017a4:	6442                	ld	s0,16(sp)
    800017a6:	64a2                	ld	s1,8(sp)
    800017a8:	6105                	addi	sp,sp,32
    800017aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800017ac:	6605                	lui	a2,0x1
    800017ae:	167d                	addi	a2,a2,-1
    800017b0:	962e                	add	a2,a2,a1
    800017b2:	4685                	li	a3,1
    800017b4:	8231                	srli	a2,a2,0xc
    800017b6:	4581                	li	a1,0
    800017b8:	00000097          	auipc	ra,0x0
    800017bc:	d0a080e7          	jalr	-758(ra) # 800014c2 <uvmunmap>
    800017c0:	bfe1                	j	80001798 <uvmfree+0xe>

00000000800017c2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800017c2:	c679                	beqz	a2,80001890 <uvmcopy+0xce>
{
    800017c4:	715d                	addi	sp,sp,-80
    800017c6:	e486                	sd	ra,72(sp)
    800017c8:	e0a2                	sd	s0,64(sp)
    800017ca:	fc26                	sd	s1,56(sp)
    800017cc:	f84a                	sd	s2,48(sp)
    800017ce:	f44e                	sd	s3,40(sp)
    800017d0:	f052                	sd	s4,32(sp)
    800017d2:	ec56                	sd	s5,24(sp)
    800017d4:	e85a                	sd	s6,16(sp)
    800017d6:	e45e                	sd	s7,8(sp)
    800017d8:	0880                	addi	s0,sp,80
    800017da:	8b2a                	mv	s6,a0
    800017dc:	8aae                	mv	s5,a1
    800017de:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800017e0:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800017e2:	4601                	li	a2,0
    800017e4:	85ce                	mv	a1,s3
    800017e6:	855a                	mv	a0,s6
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	a2c080e7          	jalr	-1492(ra) # 80001214 <walk>
    800017f0:	c531                	beqz	a0,8000183c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800017f2:	6118                	ld	a4,0(a0)
    800017f4:	00177793          	andi	a5,a4,1
    800017f8:	cbb1                	beqz	a5,8000184c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800017fa:	00a75593          	srli	a1,a4,0xa
    800017fe:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001802:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001806:	fffff097          	auipc	ra,0xfffff
    8000180a:	302080e7          	jalr	770(ra) # 80000b08 <kalloc>
    8000180e:	892a                	mv	s2,a0
    80001810:	c939                	beqz	a0,80001866 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001812:	6605                	lui	a2,0x1
    80001814:	85de                	mv	a1,s7
    80001816:	fffff097          	auipc	ra,0xfffff
    8000181a:	776080e7          	jalr	1910(ra) # 80000f8c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000181e:	8726                	mv	a4,s1
    80001820:	86ca                	mv	a3,s2
    80001822:	6605                	lui	a2,0x1
    80001824:	85ce                	mv	a1,s3
    80001826:	8556                	mv	a0,s5
    80001828:	00000097          	auipc	ra,0x0
    8000182c:	ad4080e7          	jalr	-1324(ra) # 800012fc <mappages>
    80001830:	e515                	bnez	a0,8000185c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001832:	6785                	lui	a5,0x1
    80001834:	99be                	add	s3,s3,a5
    80001836:	fb49e6e3          	bltu	s3,s4,800017e2 <uvmcopy+0x20>
    8000183a:	a081                	j	8000187a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000183c:	00007517          	auipc	a0,0x7
    80001840:	95c50513          	addi	a0,a0,-1700 # 80008198 <digits+0x150>
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	dc8080e7          	jalr	-568(ra) # 8000060c <panic>
      panic("uvmcopy: page not present");
    8000184c:	00007517          	auipc	a0,0x7
    80001850:	96c50513          	addi	a0,a0,-1684 # 800081b8 <digits+0x170>
    80001854:	fffff097          	auipc	ra,0xfffff
    80001858:	db8080e7          	jalr	-584(ra) # 8000060c <panic>
      kfree(mem);
    8000185c:	854a                	mv	a0,s2
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	370080e7          	jalr	880(ra) # 80000bce <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001866:	4685                	li	a3,1
    80001868:	00c9d613          	srli	a2,s3,0xc
    8000186c:	4581                	li	a1,0
    8000186e:	8556                	mv	a0,s5
    80001870:	00000097          	auipc	ra,0x0
    80001874:	c52080e7          	jalr	-942(ra) # 800014c2 <uvmunmap>
  return -1;
    80001878:	557d                	li	a0,-1
}
    8000187a:	60a6                	ld	ra,72(sp)
    8000187c:	6406                	ld	s0,64(sp)
    8000187e:	74e2                	ld	s1,56(sp)
    80001880:	7942                	ld	s2,48(sp)
    80001882:	79a2                	ld	s3,40(sp)
    80001884:	7a02                	ld	s4,32(sp)
    80001886:	6ae2                	ld	s5,24(sp)
    80001888:	6b42                	ld	s6,16(sp)
    8000188a:	6ba2                	ld	s7,8(sp)
    8000188c:	6161                	addi	sp,sp,80
    8000188e:	8082                	ret
  return 0;
    80001890:	4501                	li	a0,0
}
    80001892:	8082                	ret

0000000080001894 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001894:	1141                	addi	sp,sp,-16
    80001896:	e406                	sd	ra,8(sp)
    80001898:	e022                	sd	s0,0(sp)
    8000189a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000189c:	4601                	li	a2,0
    8000189e:	00000097          	auipc	ra,0x0
    800018a2:	976080e7          	jalr	-1674(ra) # 80001214 <walk>
  if(pte == 0)
    800018a6:	c901                	beqz	a0,800018b6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800018a8:	611c                	ld	a5,0(a0)
    800018aa:	9bbd                	andi	a5,a5,-17
    800018ac:	e11c                	sd	a5,0(a0)
}
    800018ae:	60a2                	ld	ra,8(sp)
    800018b0:	6402                	ld	s0,0(sp)
    800018b2:	0141                	addi	sp,sp,16
    800018b4:	8082                	ret
    panic("uvmclear");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	addi	a0,a0,-1758 # 800081d8 <digits+0x190>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	d4e080e7          	jalr	-690(ra) # 8000060c <panic>

00000000800018c6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018c6:	c6bd                	beqz	a3,80001934 <copyout+0x6e>
{
    800018c8:	715d                	addi	sp,sp,-80
    800018ca:	e486                	sd	ra,72(sp)
    800018cc:	e0a2                	sd	s0,64(sp)
    800018ce:	fc26                	sd	s1,56(sp)
    800018d0:	f84a                	sd	s2,48(sp)
    800018d2:	f44e                	sd	s3,40(sp)
    800018d4:	f052                	sd	s4,32(sp)
    800018d6:	ec56                	sd	s5,24(sp)
    800018d8:	e85a                	sd	s6,16(sp)
    800018da:	e45e                	sd	s7,8(sp)
    800018dc:	e062                	sd	s8,0(sp)
    800018de:	0880                	addi	s0,sp,80
    800018e0:	8b2a                	mv	s6,a0
    800018e2:	8c2e                	mv	s8,a1
    800018e4:	8a32                	mv	s4,a2
    800018e6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800018e8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800018ea:	6a85                	lui	s5,0x1
    800018ec:	a015                	j	80001910 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018ee:	9562                	add	a0,a0,s8
    800018f0:	0004861b          	sext.w	a2,s1
    800018f4:	85d2                	mv	a1,s4
    800018f6:	41250533          	sub	a0,a0,s2
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	692080e7          	jalr	1682(ra) # 80000f8c <memmove>

    len -= n;
    80001902:	409989b3          	sub	s3,s3,s1
    src += n;
    80001906:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001908:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000190c:	02098263          	beqz	s3,80001930 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001910:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001914:	85ca                	mv	a1,s2
    80001916:	855a                	mv	a0,s6
    80001918:	00000097          	auipc	ra,0x0
    8000191c:	9a2080e7          	jalr	-1630(ra) # 800012ba <walkaddr>
    if(pa0 == 0)
    80001920:	cd01                	beqz	a0,80001938 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001922:	418904b3          	sub	s1,s2,s8
    80001926:	94d6                	add	s1,s1,s5
    if(n > len)
    80001928:	fc99f3e3          	bgeu	s3,s1,800018ee <copyout+0x28>
    8000192c:	84ce                	mv	s1,s3
    8000192e:	b7c1                	j	800018ee <copyout+0x28>
  }
  return 0;
    80001930:	4501                	li	a0,0
    80001932:	a021                	j	8000193a <copyout+0x74>
    80001934:	4501                	li	a0,0
}
    80001936:	8082                	ret
      return -1;
    80001938:	557d                	li	a0,-1
}
    8000193a:	60a6                	ld	ra,72(sp)
    8000193c:	6406                	ld	s0,64(sp)
    8000193e:	74e2                	ld	s1,56(sp)
    80001940:	7942                	ld	s2,48(sp)
    80001942:	79a2                	ld	s3,40(sp)
    80001944:	7a02                	ld	s4,32(sp)
    80001946:	6ae2                	ld	s5,24(sp)
    80001948:	6b42                	ld	s6,16(sp)
    8000194a:	6ba2                	ld	s7,8(sp)
    8000194c:	6c02                	ld	s8,0(sp)
    8000194e:	6161                	addi	sp,sp,80
    80001950:	8082                	ret

0000000080001952 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001952:	caa5                	beqz	a3,800019c2 <copyin+0x70>
{
    80001954:	715d                	addi	sp,sp,-80
    80001956:	e486                	sd	ra,72(sp)
    80001958:	e0a2                	sd	s0,64(sp)
    8000195a:	fc26                	sd	s1,56(sp)
    8000195c:	f84a                	sd	s2,48(sp)
    8000195e:	f44e                	sd	s3,40(sp)
    80001960:	f052                	sd	s4,32(sp)
    80001962:	ec56                	sd	s5,24(sp)
    80001964:	e85a                	sd	s6,16(sp)
    80001966:	e45e                	sd	s7,8(sp)
    80001968:	e062                	sd	s8,0(sp)
    8000196a:	0880                	addi	s0,sp,80
    8000196c:	8b2a                	mv	s6,a0
    8000196e:	8a2e                	mv	s4,a1
    80001970:	8c32                	mv	s8,a2
    80001972:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001974:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001976:	6a85                	lui	s5,0x1
    80001978:	a01d                	j	8000199e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000197a:	018505b3          	add	a1,a0,s8
    8000197e:	0004861b          	sext.w	a2,s1
    80001982:	412585b3          	sub	a1,a1,s2
    80001986:	8552                	mv	a0,s4
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	604080e7          	jalr	1540(ra) # 80000f8c <memmove>

    len -= n;
    80001990:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001994:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001996:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000199a:	02098263          	beqz	s3,800019be <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000199e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019a2:	85ca                	mv	a1,s2
    800019a4:	855a                	mv	a0,s6
    800019a6:	00000097          	auipc	ra,0x0
    800019aa:	914080e7          	jalr	-1772(ra) # 800012ba <walkaddr>
    if(pa0 == 0)
    800019ae:	cd01                	beqz	a0,800019c6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800019b0:	418904b3          	sub	s1,s2,s8
    800019b4:	94d6                	add	s1,s1,s5
    if(n > len)
    800019b6:	fc99f2e3          	bgeu	s3,s1,8000197a <copyin+0x28>
    800019ba:	84ce                	mv	s1,s3
    800019bc:	bf7d                	j	8000197a <copyin+0x28>
  }
  return 0;
    800019be:	4501                	li	a0,0
    800019c0:	a021                	j	800019c8 <copyin+0x76>
    800019c2:	4501                	li	a0,0
}
    800019c4:	8082                	ret
      return -1;
    800019c6:	557d                	li	a0,-1
}
    800019c8:	60a6                	ld	ra,72(sp)
    800019ca:	6406                	ld	s0,64(sp)
    800019cc:	74e2                	ld	s1,56(sp)
    800019ce:	7942                	ld	s2,48(sp)
    800019d0:	79a2                	ld	s3,40(sp)
    800019d2:	7a02                	ld	s4,32(sp)
    800019d4:	6ae2                	ld	s5,24(sp)
    800019d6:	6b42                	ld	s6,16(sp)
    800019d8:	6ba2                	ld	s7,8(sp)
    800019da:	6c02                	ld	s8,0(sp)
    800019dc:	6161                	addi	sp,sp,80
    800019de:	8082                	ret

00000000800019e0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800019e0:	c6c5                	beqz	a3,80001a88 <copyinstr+0xa8>
{
    800019e2:	715d                	addi	sp,sp,-80
    800019e4:	e486                	sd	ra,72(sp)
    800019e6:	e0a2                	sd	s0,64(sp)
    800019e8:	fc26                	sd	s1,56(sp)
    800019ea:	f84a                	sd	s2,48(sp)
    800019ec:	f44e                	sd	s3,40(sp)
    800019ee:	f052                	sd	s4,32(sp)
    800019f0:	ec56                	sd	s5,24(sp)
    800019f2:	e85a                	sd	s6,16(sp)
    800019f4:	e45e                	sd	s7,8(sp)
    800019f6:	0880                	addi	s0,sp,80
    800019f8:	8a2a                	mv	s4,a0
    800019fa:	8b2e                	mv	s6,a1
    800019fc:	8bb2                	mv	s7,a2
    800019fe:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001a00:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a02:	6985                	lui	s3,0x1
    80001a04:	a035                	j	80001a30 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a06:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001a0a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a0c:	0017b793          	seqz	a5,a5
    80001a10:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a14:	60a6                	ld	ra,72(sp)
    80001a16:	6406                	ld	s0,64(sp)
    80001a18:	74e2                	ld	s1,56(sp)
    80001a1a:	7942                	ld	s2,48(sp)
    80001a1c:	79a2                	ld	s3,40(sp)
    80001a1e:	7a02                	ld	s4,32(sp)
    80001a20:	6ae2                	ld	s5,24(sp)
    80001a22:	6b42                	ld	s6,16(sp)
    80001a24:	6ba2                	ld	s7,8(sp)
    80001a26:	6161                	addi	sp,sp,80
    80001a28:	8082                	ret
    srcva = va0 + PGSIZE;
    80001a2a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001a2e:	c8a9                	beqz	s1,80001a80 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001a30:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001a34:	85ca                	mv	a1,s2
    80001a36:	8552                	mv	a0,s4
    80001a38:	00000097          	auipc	ra,0x0
    80001a3c:	882080e7          	jalr	-1918(ra) # 800012ba <walkaddr>
    if(pa0 == 0)
    80001a40:	c131                	beqz	a0,80001a84 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001a42:	41790833          	sub	a6,s2,s7
    80001a46:	984e                	add	a6,a6,s3
    if(n > max)
    80001a48:	0104f363          	bgeu	s1,a6,80001a4e <copyinstr+0x6e>
    80001a4c:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001a4e:	955e                	add	a0,a0,s7
    80001a50:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001a54:	fc080be3          	beqz	a6,80001a2a <copyinstr+0x4a>
    80001a58:	985a                	add	a6,a6,s6
    80001a5a:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001a5c:	41650633          	sub	a2,a0,s6
    80001a60:	14fd                	addi	s1,s1,-1
    80001a62:	9b26                	add	s6,s6,s1
    80001a64:	00f60733          	add	a4,a2,a5
    80001a68:	00074703          	lbu	a4,0(a4)
    80001a6c:	df49                	beqz	a4,80001a06 <copyinstr+0x26>
        *dst = *p;
    80001a6e:	00e78023          	sb	a4,0(a5)
      --max;
    80001a72:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001a76:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a78:	ff0796e3          	bne	a5,a6,80001a64 <copyinstr+0x84>
      dst++;
    80001a7c:	8b42                	mv	s6,a6
    80001a7e:	b775                	j	80001a2a <copyinstr+0x4a>
    80001a80:	4781                	li	a5,0
    80001a82:	b769                	j	80001a0c <copyinstr+0x2c>
      return -1;
    80001a84:	557d                	li	a0,-1
    80001a86:	b779                	j	80001a14 <copyinstr+0x34>
  int got_null = 0;
    80001a88:	4781                	li	a5,0
  if(got_null){
    80001a8a:	0017b793          	seqz	a5,a5
    80001a8e:	40f00533          	neg	a0,a5
}
    80001a92:	8082                	ret

0000000080001a94 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001a94:	7139                	addi	sp,sp,-64
    80001a96:	fc06                	sd	ra,56(sp)
    80001a98:	f822                	sd	s0,48(sp)
    80001a9a:	f426                	sd	s1,40(sp)
    80001a9c:	f04a                	sd	s2,32(sp)
    80001a9e:	ec4e                	sd	s3,24(sp)
    80001aa0:	e852                	sd	s4,16(sp)
    80001aa2:	e456                	sd	s5,8(sp)
    80001aa4:	e05a                	sd	s6,0(sp)
    80001aa6:	0080                	addi	s0,sp,64
    80001aa8:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001aaa:	00030497          	auipc	s1,0x30
    80001aae:	dbe48493          	addi	s1,s1,-578 # 80031868 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001ab2:	8b26                	mv	s6,s1
    80001ab4:	00006a97          	auipc	s5,0x6
    80001ab8:	54ca8a93          	addi	s5,s5,1356 # 80008000 <etext>
    80001abc:	04000937          	lui	s2,0x4000
    80001ac0:	197d                	addi	s2,s2,-1
    80001ac2:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ac4:	00036a17          	auipc	s4,0x36
    80001ac8:	1a4a0a13          	addi	s4,s4,420 # 80037c68 <tickslock>
    char *pa = kalloc();
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	03c080e7          	jalr	60(ra) # 80000b08 <kalloc>
    80001ad4:	862a                	mv	a2,a0
    if (pa == 0)
    80001ad6:	c131                	beqz	a0,80001b1a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001ad8:	416485b3          	sub	a1,s1,s6
    80001adc:	8591                	srai	a1,a1,0x4
    80001ade:	000ab783          	ld	a5,0(s5)
    80001ae2:	02f585b3          	mul	a1,a1,a5
    80001ae6:	2585                	addiw	a1,a1,1
    80001ae8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001aec:	4719                	li	a4,6
    80001aee:	6685                	lui	a3,0x1
    80001af0:	40b905b3          	sub	a1,s2,a1
    80001af4:	854e                	mv	a0,s3
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	8a6080e7          	jalr	-1882(ra) # 8000139c <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001afe:	19048493          	addi	s1,s1,400
    80001b02:	fd4495e3          	bne	s1,s4,80001acc <proc_mapstacks+0x38>
  }
}
    80001b06:	70e2                	ld	ra,56(sp)
    80001b08:	7442                	ld	s0,48(sp)
    80001b0a:	74a2                	ld	s1,40(sp)
    80001b0c:	7902                	ld	s2,32(sp)
    80001b0e:	69e2                	ld	s3,24(sp)
    80001b10:	6a42                	ld	s4,16(sp)
    80001b12:	6aa2                	ld	s5,8(sp)
    80001b14:	6b02                	ld	s6,0(sp)
    80001b16:	6121                	addi	sp,sp,64
    80001b18:	8082                	ret
      panic("kalloc");
    80001b1a:	00006517          	auipc	a0,0x6
    80001b1e:	6ce50513          	addi	a0,a0,1742 # 800081e8 <digits+0x1a0>
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	aea080e7          	jalr	-1302(ra) # 8000060c <panic>

0000000080001b2a <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001b2a:	715d                	addi	sp,sp,-80
    80001b2c:	e486                	sd	ra,72(sp)
    80001b2e:	e0a2                	sd	s0,64(sp)
    80001b30:	fc26                	sd	s1,56(sp)
    80001b32:	f84a                	sd	s2,48(sp)
    80001b34:	f44e                	sd	s3,40(sp)
    80001b36:	f052                	sd	s4,32(sp)
    80001b38:	ec56                	sd	s5,24(sp)
    80001b3a:	e85a                	sd	s6,16(sp)
    80001b3c:	e45e                	sd	s7,8(sp)
    80001b3e:	0880                	addi	s0,sp,80
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001b40:	00006597          	auipc	a1,0x6
    80001b44:	6b058593          	addi	a1,a1,1712 # 800081f0 <digits+0x1a8>
    80001b48:	00030517          	auipc	a0,0x30
    80001b4c:	8f050513          	addi	a0,a0,-1808 # 80031438 <pid_lock>
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	254080e7          	jalr	596(ra) # 80000da4 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b58:	00006597          	auipc	a1,0x6
    80001b5c:	6a058593          	addi	a1,a1,1696 # 800081f8 <digits+0x1b0>
    80001b60:	00030517          	auipc	a0,0x30
    80001b64:	8f050513          	addi	a0,a0,-1808 # 80031450 <wait_lock>
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	23c080e7          	jalr	572(ra) # 80000da4 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001b70:	00030497          	auipc	s1,0x30
    80001b74:	cf848493          	addi	s1,s1,-776 # 80031868 <proc>
  {
    initlock(&p->lock, "proc");
    80001b78:	00006b97          	auipc	s7,0x6
    80001b7c:	690b8b93          	addi	s7,s7,1680 # 80008208 <digits+0x1c0>
    p->state = UNUSED;
    80001b80:	4b05                	li	s6,1
    p->kstack = KSTACK((int)(p - proc));
    80001b82:	8aa6                	mv	s5,s1
    80001b84:	00006a17          	auipc	s4,0x6
    80001b88:	47ca0a13          	addi	s4,s4,1148 # 80008000 <etext>
    80001b8c:	04000937          	lui	s2,0x4000
    80001b90:	197d                	addi	s2,s2,-1
    80001b92:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001b94:	00036997          	auipc	s3,0x36
    80001b98:	0d498993          	addi	s3,s3,212 # 80037c68 <tickslock>
    initlock(&p->lock, "proc");
    80001b9c:	85de                	mv	a1,s7
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	204080e7          	jalr	516(ra) # 80000da4 <initlock>
    p->state = UNUSED;
    80001ba8:	0164ac23          	sw	s6,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001bac:	415487b3          	sub	a5,s1,s5
    80001bb0:	8791                	srai	a5,a5,0x4
    80001bb2:	000a3703          	ld	a4,0(s4)
    80001bb6:	02e787b3          	mul	a5,a5,a4
    80001bba:	2785                	addiw	a5,a5,1
    80001bbc:	00d7979b          	slliw	a5,a5,0xd
    80001bc0:	40f907b3          	sub	a5,s2,a5
    80001bc4:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc6:	19048493          	addi	s1,s1,400
    80001bca:	fd3499e3          	bne	s1,s3,80001b9c <procinit+0x72>
  }
}
    80001bce:	60a6                	ld	ra,72(sp)
    80001bd0:	6406                	ld	s0,64(sp)
    80001bd2:	74e2                	ld	s1,56(sp)
    80001bd4:	7942                	ld	s2,48(sp)
    80001bd6:	79a2                	ld	s3,40(sp)
    80001bd8:	7a02                	ld	s4,32(sp)
    80001bda:	6ae2                	ld	s5,24(sp)
    80001bdc:	6b42                	ld	s6,16(sp)
    80001bde:	6ba2                	ld	s7,8(sp)
    80001be0:	6161                	addi	sp,sp,80
    80001be2:	8082                	ret

0000000080001be4 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001be4:	1141                	addi	sp,sp,-16
    80001be6:	e422                	sd	s0,8(sp)
    80001be8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bea:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001bec:	2501                	sext.w	a0,a0
    80001bee:	6422                	ld	s0,8(sp)
    80001bf0:	0141                	addi	sp,sp,16
    80001bf2:	8082                	ret

0000000080001bf4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001bf4:	1141                	addi	sp,sp,-16
    80001bf6:	e422                	sd	s0,8(sp)
    80001bf8:	0800                	addi	s0,sp,16
    80001bfa:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001bfc:	2781                	sext.w	a5,a5
    80001bfe:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c00:	00030517          	auipc	a0,0x30
    80001c04:	86850513          	addi	a0,a0,-1944 # 80031468 <cpus>
    80001c08:	953e                	add	a0,a0,a5
    80001c0a:	6422                	ld	s0,8(sp)
    80001c0c:	0141                	addi	sp,sp,16
    80001c0e:	8082                	ret

0000000080001c10 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001c10:	1101                	addi	sp,sp,-32
    80001c12:	ec06                	sd	ra,24(sp)
    80001c14:	e822                	sd	s0,16(sp)
    80001c16:	e426                	sd	s1,8(sp)
    80001c18:	1000                	addi	s0,sp,32
  push_off();
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	1ce080e7          	jalr	462(ra) # 80000de8 <push_off>
    80001c22:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c24:	2781                	sext.w	a5,a5
    80001c26:	079e                	slli	a5,a5,0x7
    80001c28:	00030717          	auipc	a4,0x30
    80001c2c:	81070713          	addi	a4,a4,-2032 # 80031438 <pid_lock>
    80001c30:	97ba                	add	a5,a5,a4
    80001c32:	7b84                	ld	s1,48(a5)
  pop_off();
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	254080e7          	jalr	596(ra) # 80000e88 <pop_off>
  return p;
}
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6105                	addi	sp,sp,32
    80001c46:	8082                	ret

0000000080001c48 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c48:	1141                	addi	sp,sp,-16
    80001c4a:	e406                	sd	ra,8(sp)
    80001c4c:	e022                	sd	s0,0(sp)
    80001c4e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	fc0080e7          	jalr	-64(ra) # 80001c10 <myproc>
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	290080e7          	jalr	656(ra) # 80000ee8 <release>

  if (first)
    80001c60:	00007797          	auipc	a5,0x7
    80001c64:	c807a783          	lw	a5,-896(a5) # 800088e0 <first.1>
    80001c68:	eb89                	bnez	a5,80001c7a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001c6a:	00001097          	auipc	ra,0x1
    80001c6e:	14e080e7          	jalr	334(ra) # 80002db8 <usertrapret>
}
    80001c72:	60a2                	ld	ra,8(sp)
    80001c74:	6402                	ld	s0,0(sp)
    80001c76:	0141                	addi	sp,sp,16
    80001c78:	8082                	ret
    first = 0;
    80001c7a:	00007797          	auipc	a5,0x7
    80001c7e:	c607a323          	sw	zero,-922(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80001c82:	4505                	li	a0,1
    80001c84:	00002097          	auipc	ra,0x2
    80001c88:	044080e7          	jalr	68(ra) # 80003cc8 <fsinit>
    80001c8c:	bff9                	j	80001c6a <forkret+0x22>

0000000080001c8e <allocpid>:
{
    80001c8e:	1101                	addi	sp,sp,-32
    80001c90:	ec06                	sd	ra,24(sp)
    80001c92:	e822                	sd	s0,16(sp)
    80001c94:	e426                	sd	s1,8(sp)
    80001c96:	e04a                	sd	s2,0(sp)
    80001c98:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c9a:	0002f917          	auipc	s2,0x2f
    80001c9e:	79e90913          	addi	s2,s2,1950 # 80031438 <pid_lock>
    80001ca2:	854a                	mv	a0,s2
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	190080e7          	jalr	400(ra) # 80000e34 <acquire>
  pid = nextpid;
    80001cac:	00007797          	auipc	a5,0x7
    80001cb0:	c3878793          	addi	a5,a5,-968 # 800088e4 <nextpid>
    80001cb4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001cb6:	0014871b          	addiw	a4,s1,1
    80001cba:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001cbc:	854a                	mv	a0,s2
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	22a080e7          	jalr	554(ra) # 80000ee8 <release>
}
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	60e2                	ld	ra,24(sp)
    80001cca:	6442                	ld	s0,16(sp)
    80001ccc:	64a2                	ld	s1,8(sp)
    80001cce:	6902                	ld	s2,0(sp)
    80001cd0:	6105                	addi	sp,sp,32
    80001cd2:	8082                	ret

0000000080001cd4 <proc_pagetable>:
{
    80001cd4:	1101                	addi	sp,sp,-32
    80001cd6:	ec06                	sd	ra,24(sp)
    80001cd8:	e822                	sd	s0,16(sp)
    80001cda:	e426                	sd	s1,8(sp)
    80001cdc:	e04a                	sd	s2,0(sp)
    80001cde:	1000                	addi	s0,sp,32
    80001ce0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	8a4080e7          	jalr	-1884(ra) # 80001586 <uvmcreate>
    80001cea:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001cec:	c121                	beqz	a0,80001d2c <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cee:	4729                	li	a4,10
    80001cf0:	00005697          	auipc	a3,0x5
    80001cf4:	31068693          	addi	a3,a3,784 # 80007000 <_trampoline>
    80001cf8:	6605                	lui	a2,0x1
    80001cfa:	040005b7          	lui	a1,0x4000
    80001cfe:	15fd                	addi	a1,a1,-1
    80001d00:	05b2                	slli	a1,a1,0xc
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	5fa080e7          	jalr	1530(ra) # 800012fc <mappages>
    80001d0a:	02054863          	bltz	a0,80001d3a <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d0e:	4719                	li	a4,6
    80001d10:	05893683          	ld	a3,88(s2)
    80001d14:	6605                	lui	a2,0x1
    80001d16:	020005b7          	lui	a1,0x2000
    80001d1a:	15fd                	addi	a1,a1,-1
    80001d1c:	05b6                	slli	a1,a1,0xd
    80001d1e:	8526                	mv	a0,s1
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	5dc080e7          	jalr	1500(ra) # 800012fc <mappages>
    80001d28:	02054163          	bltz	a0,80001d4a <proc_pagetable+0x76>
}
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret
    uvmfree(pagetable, 0);
    80001d3a:	4581                	li	a1,0
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	00000097          	auipc	ra,0x0
    80001d42:	a4c080e7          	jalr	-1460(ra) # 8000178a <uvmfree>
    return 0;
    80001d46:	4481                	li	s1,0
    80001d48:	b7d5                	j	80001d2c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d4a:	4681                	li	a3,0
    80001d4c:	4605                	li	a2,1
    80001d4e:	040005b7          	lui	a1,0x4000
    80001d52:	15fd                	addi	a1,a1,-1
    80001d54:	05b2                	slli	a1,a1,0xc
    80001d56:	8526                	mv	a0,s1
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	76a080e7          	jalr	1898(ra) # 800014c2 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d60:	4581                	li	a1,0
    80001d62:	8526                	mv	a0,s1
    80001d64:	00000097          	auipc	ra,0x0
    80001d68:	a26080e7          	jalr	-1498(ra) # 8000178a <uvmfree>
    return 0;
    80001d6c:	4481                	li	s1,0
    80001d6e:	bf7d                	j	80001d2c <proc_pagetable+0x58>

0000000080001d70 <proc_freepagetable>:
{
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	e04a                	sd	s2,0(sp)
    80001d7a:	1000                	addi	s0,sp,32
    80001d7c:	84aa                	mv	s1,a0
    80001d7e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d80:	4681                	li	a3,0
    80001d82:	4605                	li	a2,1
    80001d84:	040005b7          	lui	a1,0x4000
    80001d88:	15fd                	addi	a1,a1,-1
    80001d8a:	05b2                	slli	a1,a1,0xc
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	736080e7          	jalr	1846(ra) # 800014c2 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d94:	4681                	li	a3,0
    80001d96:	4605                	li	a2,1
    80001d98:	020005b7          	lui	a1,0x2000
    80001d9c:	15fd                	addi	a1,a1,-1
    80001d9e:	05b6                	slli	a1,a1,0xd
    80001da0:	8526                	mv	a0,s1
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	720080e7          	jalr	1824(ra) # 800014c2 <uvmunmap>
  uvmfree(pagetable, sz);
    80001daa:	85ca                	mv	a1,s2
    80001dac:	8526                	mv	a0,s1
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	9dc080e7          	jalr	-1572(ra) # 8000178a <uvmfree>
}
    80001db6:	60e2                	ld	ra,24(sp)
    80001db8:	6442                	ld	s0,16(sp)
    80001dba:	64a2                	ld	s1,8(sp)
    80001dbc:	6902                	ld	s2,0(sp)
    80001dbe:	6105                	addi	sp,sp,32
    80001dc0:	8082                	ret

0000000080001dc2 <freeproc>:
{
    80001dc2:	1101                	addi	sp,sp,-32
    80001dc4:	ec06                	sd	ra,24(sp)
    80001dc6:	e822                	sd	s0,16(sp)
    80001dc8:	e426                	sd	s1,8(sp)
    80001dca:	1000                	addi	s0,sp,32
    80001dcc:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001dce:	6d28                	ld	a0,88(a0)
    80001dd0:	c509                	beqz	a0,80001dda <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	dfc080e7          	jalr	-516(ra) # 80000bce <kfree>
  p->trapframe = 0;
    80001dda:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001dde:	68a8                	ld	a0,80(s1)
    80001de0:	c511                	beqz	a0,80001dec <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001de2:	64ac                	ld	a1,72(s1)
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	f8c080e7          	jalr	-116(ra) # 80001d70 <proc_freepagetable>
  p->pagetable = 0;
    80001dec:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001df0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001df4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001df8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001dfc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e00:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e04:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e08:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e0c:	4785                	li	a5,1
    80001e0e:	cc9c                	sw	a5,24(s1)
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret

0000000080001e1a <allocproc>:
{
    80001e1a:	7179                	addi	sp,sp,-48
    80001e1c:	f406                	sd	ra,40(sp)
    80001e1e:	f022                	sd	s0,32(sp)
    80001e20:	ec26                	sd	s1,24(sp)
    80001e22:	e84a                	sd	s2,16(sp)
    80001e24:	e44e                	sd	s3,8(sp)
    80001e26:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    80001e28:	00030497          	auipc	s1,0x30
    80001e2c:	a4048493          	addi	s1,s1,-1472 # 80031868 <proc>
    if (p->state == UNUSED)
    80001e30:	4905                	li	s2,1
  for (p = proc; p < &proc[NPROC]; p++)
    80001e32:	00036997          	auipc	s3,0x36
    80001e36:	e3698993          	addi	s3,s3,-458 # 80037c68 <tickslock>
    acquire(&p->lock);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	ff8080e7          	jalr	-8(ra) # 80000e34 <acquire>
    if (p->state == UNUSED)
    80001e44:	4c9c                	lw	a5,24(s1)
    80001e46:	01278d63          	beq	a5,s2,80001e60 <allocproc+0x46>
      release(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	09c080e7          	jalr	156(ra) # 80000ee8 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001e54:	19048493          	addi	s1,s1,400
    80001e58:	ff3491e3          	bne	s1,s3,80001e3a <allocproc+0x20>
  return 0;
    80001e5c:	4481                	li	s1,0
    80001e5e:	a051                	j	80001ee2 <allocproc+0xc8>
  p->pid = allocpid();
    80001e60:	00000097          	auipc	ra,0x0
    80001e64:	e2e080e7          	jalr	-466(ra) # 80001c8e <allocpid>
    80001e68:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e6a:	4789                	li	a5,2
    80001e6c:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	c9a080e7          	jalr	-870(ra) # 80000b08 <kalloc>
    80001e76:	892a                	mv	s2,a0
    80001e78:	eca8                	sd	a0,88(s1)
    80001e7a:	cd25                	beqz	a0,80001ef2 <allocproc+0xd8>
  p->pagetable = proc_pagetable(p);
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	00000097          	auipc	ra,0x0
    80001e82:	e56080e7          	jalr	-426(ra) # 80001cd4 <proc_pagetable>
    80001e86:	892a                	mv	s2,a0
    80001e88:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e8a:	c141                	beqz	a0,80001f0a <allocproc+0xf0>
  memset(&p->context, 0, sizeof(p->context));
    80001e8c:	07000613          	li	a2,112
    80001e90:	4581                	li	a1,0
    80001e92:	06048513          	addi	a0,s1,96
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	09a080e7          	jalr	154(ra) # 80000f30 <memset>
  p->context.ra = (uint64)forkret;
    80001e9e:	00000797          	auipc	a5,0x0
    80001ea2:	daa78793          	addi	a5,a5,-598 # 80001c48 <forkret>
    80001ea6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ea8:	60bc                	ld	a5,64(s1)
    80001eaa:	6705                	lui	a4,0x1
    80001eac:	97ba                	add	a5,a5,a4
    80001eae:	f4bc                	sd	a5,104(s1)
  p->start_ticks = ticks;
    80001eb0:	00007797          	auipc	a5,0x7
    80001eb4:	ab07a783          	lw	a5,-1360(a5) # 80008960 <ticks>
    80001eb8:	16f4a423          	sw	a5,360(s1)
  p->cpu_ticks_total = 0;
    80001ebc:	1604a823          	sw	zero,368(s1)
  p->cpu_ticks_in = 0;
    80001ec0:	1604aa23          	sw	zero,372(s1)
  p->elapsed = 0;
    80001ec4:	1604a623          	sw	zero,364(s1)
  p->priority = 1;
    80001ec8:	4785                	li	a5,1
    80001eca:	18f4a623          	sw	a5,396(s1)
  p->ticks[0] = p->ticks[1] = p->ticks[2] = p->ticks[3] = 0;
    80001ece:	1804a223          	sw	zero,388(s1)
    80001ed2:	1804a023          	sw	zero,384(s1)
    80001ed6:	1604ae23          	sw	zero,380(s1)
    80001eda:	1604ac23          	sw	zero,376(s1)
  p->lastScheduledOnTick = 0;
    80001ede:	1804a423          	sw	zero,392(s1)
}
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	70a2                	ld	ra,40(sp)
    80001ee6:	7402                	ld	s0,32(sp)
    80001ee8:	64e2                	ld	s1,24(sp)
    80001eea:	6942                	ld	s2,16(sp)
    80001eec:	69a2                	ld	s3,8(sp)
    80001eee:	6145                	addi	sp,sp,48
    80001ef0:	8082                	ret
    freeproc(p);
    80001ef2:	8526                	mv	a0,s1
    80001ef4:	00000097          	auipc	ra,0x0
    80001ef8:	ece080e7          	jalr	-306(ra) # 80001dc2 <freeproc>
    release(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	fea080e7          	jalr	-22(ra) # 80000ee8 <release>
    return 0;
    80001f06:	84ca                	mv	s1,s2
    80001f08:	bfe9                	j	80001ee2 <allocproc+0xc8>
    freeproc(p);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	00000097          	auipc	ra,0x0
    80001f10:	eb6080e7          	jalr	-330(ra) # 80001dc2 <freeproc>
    release(&p->lock);
    80001f14:	8526                	mv	a0,s1
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	fd2080e7          	jalr	-46(ra) # 80000ee8 <release>
    return 0;
    80001f1e:	84ca                	mv	s1,s2
    80001f20:	b7c9                	j	80001ee2 <allocproc+0xc8>

0000000080001f22 <userinit>:
{
    80001f22:	1101                	addi	sp,sp,-32
    80001f24:	ec06                	sd	ra,24(sp)
    80001f26:	e822                	sd	s0,16(sp)
    80001f28:	e426                	sd	s1,8(sp)
    80001f2a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f2c:	00000097          	auipc	ra,0x0
    80001f30:	eee080e7          	jalr	-274(ra) # 80001e1a <allocproc>
    80001f34:	84aa                	mv	s1,a0
  initproc = p;
    80001f36:	00007797          	auipc	a5,0x7
    80001f3a:	a2a7b123          	sd	a0,-1502(a5) # 80008958 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f3e:	03400613          	li	a2,52
    80001f42:	00007597          	auipc	a1,0x7
    80001f46:	9ae58593          	addi	a1,a1,-1618 # 800088f0 <initcode>
    80001f4a:	6928                	ld	a0,80(a0)
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	668080e7          	jalr	1640(ra) # 800015b4 <uvmfirst>
  p->sz = PGSIZE;
    80001f54:	6785                	lui	a5,0x1
    80001f56:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001f58:	6cb8                	ld	a4,88(s1)
    80001f5a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001f5e:	6cb8                	ld	a4,88(s1)
    80001f60:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f62:	4641                	li	a2,16
    80001f64:	00006597          	auipc	a1,0x6
    80001f68:	2ac58593          	addi	a1,a1,684 # 80008210 <digits+0x1c8>
    80001f6c:	15848513          	addi	a0,s1,344
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	10a080e7          	jalr	266(ra) # 8000107a <safestrcpy>
  p->cwd = namei("/");
    80001f78:	00006517          	auipc	a0,0x6
    80001f7c:	2a850513          	addi	a0,a0,680 # 80008220 <digits+0x1d8>
    80001f80:	00002097          	auipc	ra,0x2
    80001f84:	76a080e7          	jalr	1898(ra) # 800046ea <namei>
    80001f88:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f8c:	4791                	li	a5,4
    80001f8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f90:	8526                	mv	a0,s1
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	f56080e7          	jalr	-170(ra) # 80000ee8 <release>
}
    80001f9a:	60e2                	ld	ra,24(sp)
    80001f9c:	6442                	ld	s0,16(sp)
    80001f9e:	64a2                	ld	s1,8(sp)
    80001fa0:	6105                	addi	sp,sp,32
    80001fa2:	8082                	ret

0000000080001fa4 <growproc>:
{
    80001fa4:	1101                	addi	sp,sp,-32
    80001fa6:	ec06                	sd	ra,24(sp)
    80001fa8:	e822                	sd	s0,16(sp)
    80001faa:	e426                	sd	s1,8(sp)
    80001fac:	e04a                	sd	s2,0(sp)
    80001fae:	1000                	addi	s0,sp,32
    80001fb0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	c5e080e7          	jalr	-930(ra) # 80001c10 <myproc>
    80001fba:	84aa                	mv	s1,a0
  sz = p->sz;
    80001fbc:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001fbe:	01204c63          	bgtz	s2,80001fd6 <growproc+0x32>
  else if (n < 0)
    80001fc2:	02094663          	bltz	s2,80001fee <growproc+0x4a>
  p->sz = sz;
    80001fc6:	e4ac                	sd	a1,72(s1)
  return 0;
    80001fc8:	4501                	li	a0,0
}
    80001fca:	60e2                	ld	ra,24(sp)
    80001fcc:	6442                	ld	s0,16(sp)
    80001fce:	64a2                	ld	s1,8(sp)
    80001fd0:	6902                	ld	s2,0(sp)
    80001fd2:	6105                	addi	sp,sp,32
    80001fd4:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fd6:	4691                	li	a3,4
    80001fd8:	00b90633          	add	a2,s2,a1
    80001fdc:	6928                	ld	a0,80(a0)
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	690080e7          	jalr	1680(ra) # 8000166e <uvmalloc>
    80001fe6:	85aa                	mv	a1,a0
    80001fe8:	fd79                	bnez	a0,80001fc6 <growproc+0x22>
      return -1;
    80001fea:	557d                	li	a0,-1
    80001fec:	bff9                	j	80001fca <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fee:	00b90633          	add	a2,s2,a1
    80001ff2:	6928                	ld	a0,80(a0)
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	632080e7          	jalr	1586(ra) # 80001626 <uvmdealloc>
    80001ffc:	85aa                	mv	a1,a0
    80001ffe:	b7e1                	j	80001fc6 <growproc+0x22>

0000000080002000 <uvmcopy_cow>:
{
    80002000:	7139                	addi	sp,sp,-64
    80002002:	fc06                	sd	ra,56(sp)
    80002004:	f822                	sd	s0,48(sp)
    80002006:	f426                	sd	s1,40(sp)
    80002008:	f04a                	sd	s2,32(sp)
    8000200a:	ec4e                	sd	s3,24(sp)
    8000200c:	e852                	sd	s4,16(sp)
    8000200e:	e456                	sd	s5,8(sp)
    80002010:	e05a                	sd	s6,0(sp)
    80002012:	0080                	addi	s0,sp,64
  for (i = 0; i < sz; i += PGSIZE) {
    80002014:	c669                	beqz	a2,800020de <uvmcopy_cow+0xde>
    80002016:	8a2a                	mv	s4,a0
    80002018:	892e                	mv	s2,a1
    8000201a:	89b2                	mv	s3,a2
    8000201c:	4481                	li	s1,0
    8000201e:	a881                	j	8000206e <uvmcopy_cow+0x6e>
      panic("uvmcopy: pte should exist");
    80002020:	00006517          	auipc	a0,0x6
    80002024:	17850513          	addi	a0,a0,376 # 80008198 <digits+0x150>
    80002028:	ffffe097          	auipc	ra,0xffffe
    8000202c:	5e4080e7          	jalr	1508(ra) # 8000060c <panic>
      panic("uvmcopy: page not present");
    80002030:	00006517          	auipc	a0,0x6
    80002034:	18850513          	addi	a0,a0,392 # 800081b8 <digits+0x170>
    80002038:	ffffe097          	auipc	ra,0xffffe
    8000203c:	5d4080e7          	jalr	1492(ra) # 8000060c <panic>
      flags &= ~PTE_W;
    80002040:	3fb77713          	andi	a4,a4,1019
      flags |= PTE_COW;
    80002044:	20076713          	ori	a4,a4,512
    if (mappages(new, i, PGSIZE, pa, flags) != 0)
    80002048:	86d6                	mv	a3,s5
    8000204a:	6605                	lui	a2,0x1
    8000204c:	85a6                	mv	a1,s1
    8000204e:	854a                	mv	a0,s2
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	2ac080e7          	jalr	684(ra) # 800012fc <mappages>
    80002058:	8b2a                	mv	s6,a0
    8000205a:	e121                	bnez	a0,8000209a <uvmcopy_cow+0x9a>
    kref_increment((void*)pa); // Increment ref count for shared page
    8000205c:	8556                	mv	a0,s5
    8000205e:	fffff097          	auipc	ra,0xfffff
    80002062:	a5a080e7          	jalr	-1446(ra) # 80000ab8 <kref_increment>
  for (i = 0; i < sz; i += PGSIZE) {
    80002066:	6785                	lui	a5,0x1
    80002068:	94be                	add	s1,s1,a5
    8000206a:	0534ff63          	bgeu	s1,s3,800020c8 <uvmcopy_cow+0xc8>
    if ((pte = walk(old, i, 0)) == 0)
    8000206e:	4601                	li	a2,0
    80002070:	85a6                	mv	a1,s1
    80002072:	8552                	mv	a0,s4
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	1a0080e7          	jalr	416(ra) # 80001214 <walk>
    8000207c:	d155                	beqz	a0,80002020 <uvmcopy_cow+0x20>
    if ((*pte & PTE_V) == 0)
    8000207e:	611c                	ld	a5,0(a0)
    80002080:	0017f713          	andi	a4,a5,1
    80002084:	d755                	beqz	a4,80002030 <uvmcopy_cow+0x30>
    pa = PTE2PA(*pte);
    80002086:	00a7da93          	srli	s5,a5,0xa
    8000208a:	0ab2                	slli	s5,s5,0xc
    flags = PTE_FLAGS(*pte);
    8000208c:	0007871b          	sext.w	a4,a5
    if (flags & PTE_W) {
    80002090:	8b91                	andi	a5,a5,4
    80002092:	f7dd                	bnez	a5,80002040 <uvmcopy_cow+0x40>
    flags = PTE_FLAGS(*pte);
    80002094:	3ff77713          	andi	a4,a4,1023
    80002098:	bf45                	j	80002048 <uvmcopy_cow+0x48>
    i -= PGSIZE;
    8000209a:	7a7d                	lui	s4,0xfffff
  return -1;
    8000209c:	5b7d                	li	s6,-1
  while (i > 0) {
    8000209e:	c48d                	beqz	s1,800020c8 <uvmcopy_cow+0xc8>
    i -= PGSIZE;
    800020a0:	94d2                	add	s1,s1,s4
    pte = walk(new, i, 0);
    800020a2:	4601                	li	a2,0
    800020a4:	85a6                	mv	a1,s1
    800020a6:	854a                	mv	a0,s2
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	16c080e7          	jalr	364(ra) # 80001214 <walk>
    800020b0:	89aa                	mv	s3,a0
    pa = PTE2PA(*pte);
    800020b2:	6108                	ld	a0,0(a0)
    800020b4:	8129                	srli	a0,a0,0xa
    kfree((void*)pa);
    800020b6:	0532                	slli	a0,a0,0xc
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	b16080e7          	jalr	-1258(ra) # 80000bce <kfree>
    *pte = 0;
    800020c0:	0009b023          	sd	zero,0(s3)
  while (i > 0) {
    800020c4:	fcf1                	bnez	s1,800020a0 <uvmcopy_cow+0xa0>
  return -1;
    800020c6:	5b7d                	li	s6,-1
}
    800020c8:	855a                	mv	a0,s6
    800020ca:	70e2                	ld	ra,56(sp)
    800020cc:	7442                	ld	s0,48(sp)
    800020ce:	74a2                	ld	s1,40(sp)
    800020d0:	7902                	ld	s2,32(sp)
    800020d2:	69e2                	ld	s3,24(sp)
    800020d4:	6a42                	ld	s4,16(sp)
    800020d6:	6aa2                	ld	s5,8(sp)
    800020d8:	6b02                	ld	s6,0(sp)
    800020da:	6121                	addi	sp,sp,64
    800020dc:	8082                	ret
  return 0;
    800020de:	4b01                	li	s6,0
    800020e0:	b7e5                	j	800020c8 <uvmcopy_cow+0xc8>

00000000800020e2 <fork>:
{
    800020e2:	7139                	addi	sp,sp,-64
    800020e4:	fc06                	sd	ra,56(sp)
    800020e6:	f822                	sd	s0,48(sp)
    800020e8:	f426                	sd	s1,40(sp)
    800020ea:	f04a                	sd	s2,32(sp)
    800020ec:	ec4e                	sd	s3,24(sp)
    800020ee:	e852                	sd	s4,16(sp)
    800020f0:	e456                	sd	s5,8(sp)
    800020f2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	b1c080e7          	jalr	-1252(ra) # 80001c10 <myproc>
    800020fc:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	d1c080e7          	jalr	-740(ra) # 80001e1a <allocproc>
    80002106:	10050c63          	beqz	a0,8000221e <fork+0x13c>
    8000210a:	8a2a                	mv	s4,a0
  if (uvmcopy_cow(p->pagetable, np->pagetable, p->sz) < 0) {
    8000210c:	048ab603          	ld	a2,72(s5)
    80002110:	692c                	ld	a1,80(a0)
    80002112:	050ab503          	ld	a0,80(s5)
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	eea080e7          	jalr	-278(ra) # 80002000 <uvmcopy_cow>
    8000211e:	04054863          	bltz	a0,8000216e <fork+0x8c>
  np->sz = p->sz;
    80002122:	048ab783          	ld	a5,72(s5)
    80002126:	04fa3423          	sd	a5,72(s4) # fffffffffffff048 <end+0xffffffff7ffbc000>
  *(np->trapframe) = *(p->trapframe);
    8000212a:	058ab683          	ld	a3,88(s5)
    8000212e:	87b6                	mv	a5,a3
    80002130:	058a3703          	ld	a4,88(s4)
    80002134:	12068693          	addi	a3,a3,288
    80002138:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000213c:	6788                	ld	a0,8(a5)
    8000213e:	6b8c                	ld	a1,16(a5)
    80002140:	6f90                	ld	a2,24(a5)
    80002142:	01073023          	sd	a6,0(a4)
    80002146:	e708                	sd	a0,8(a4)
    80002148:	eb0c                	sd	a1,16(a4)
    8000214a:	ef10                	sd	a2,24(a4)
    8000214c:	02078793          	addi	a5,a5,32
    80002150:	02070713          	addi	a4,a4,32
    80002154:	fed792e3          	bne	a5,a3,80002138 <fork+0x56>
  np->trapframe->a0 = 0;
    80002158:	058a3783          	ld	a5,88(s4)
    8000215c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002160:	0d0a8493          	addi	s1,s5,208
    80002164:	0d0a0913          	addi	s2,s4,208
    80002168:	150a8993          	addi	s3,s5,336
    8000216c:	a00d                	j	8000218e <fork+0xac>
    freeproc(np);
    8000216e:	8552                	mv	a0,s4
    80002170:	00000097          	auipc	ra,0x0
    80002174:	c52080e7          	jalr	-942(ra) # 80001dc2 <freeproc>
    release(&np->lock);
    80002178:	8552                	mv	a0,s4
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	d6e080e7          	jalr	-658(ra) # 80000ee8 <release>
    return -1;
    80002182:	597d                	li	s2,-1
    80002184:	a059                	j	8000220a <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80002186:	04a1                	addi	s1,s1,8
    80002188:	0921                	addi	s2,s2,8
    8000218a:	01348b63          	beq	s1,s3,800021a0 <fork+0xbe>
    if (p->ofile[i])
    8000218e:	6088                	ld	a0,0(s1)
    80002190:	d97d                	beqz	a0,80002186 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002192:	00003097          	auipc	ra,0x3
    80002196:	bee080e7          	jalr	-1042(ra) # 80004d80 <filedup>
    8000219a:	00a93023          	sd	a0,0(s2)
    8000219e:	b7e5                	j	80002186 <fork+0xa4>
  np->cwd = idup(p->cwd);
    800021a0:	150ab503          	ld	a0,336(s5)
    800021a4:	00002097          	auipc	ra,0x2
    800021a8:	d62080e7          	jalr	-670(ra) # 80003f06 <idup>
    800021ac:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800021b0:	4641                	li	a2,16
    800021b2:	158a8593          	addi	a1,s5,344
    800021b6:	158a0513          	addi	a0,s4,344
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	ec0080e7          	jalr	-320(ra) # 8000107a <safestrcpy>
  pid = np->pid;
    800021c2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800021c6:	8552                	mv	a0,s4
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	d20080e7          	jalr	-736(ra) # 80000ee8 <release>
  acquire(&wait_lock);
    800021d0:	0002f497          	auipc	s1,0x2f
    800021d4:	28048493          	addi	s1,s1,640 # 80031450 <wait_lock>
    800021d8:	8526                	mv	a0,s1
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	c5a080e7          	jalr	-934(ra) # 80000e34 <acquire>
  np->parent = p;
    800021e2:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	d00080e7          	jalr	-768(ra) # 80000ee8 <release>
  acquire(&np->lock);
    800021f0:	8552                	mv	a0,s4
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	c42080e7          	jalr	-958(ra) # 80000e34 <acquire>
  np->state = RUNNABLE;
    800021fa:	4791                	li	a5,4
    800021fc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002200:	8552                	mv	a0,s4
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	ce6080e7          	jalr	-794(ra) # 80000ee8 <release>
}
    8000220a:	854a                	mv	a0,s2
    8000220c:	70e2                	ld	ra,56(sp)
    8000220e:	7442                	ld	s0,48(sp)
    80002210:	74a2                	ld	s1,40(sp)
    80002212:	7902                	ld	s2,32(sp)
    80002214:	69e2                	ld	s3,24(sp)
    80002216:	6a42                	ld	s4,16(sp)
    80002218:	6aa2                	ld	s5,8(sp)
    8000221a:	6121                	addi	sp,sp,64
    8000221c:	8082                	ret
    return -1;
    8000221e:	597d                	li	s2,-1
    80002220:	b7ed                	j	8000220a <fork+0x128>

0000000080002222 <scheduler>:
{
    80002222:	7175                	addi	sp,sp,-144
    80002224:	e506                	sd	ra,136(sp)
    80002226:	e122                	sd	s0,128(sp)
    80002228:	fca6                	sd	s1,120(sp)
    8000222a:	f8ca                	sd	s2,112(sp)
    8000222c:	f4ce                	sd	s3,104(sp)
    8000222e:	f0d2                	sd	s4,96(sp)
    80002230:	ecd6                	sd	s5,88(sp)
    80002232:	e8da                	sd	s6,80(sp)
    80002234:	e4de                	sd	s7,72(sp)
    80002236:	e0e2                	sd	s8,64(sp)
    80002238:	fc66                	sd	s9,56(sp)
    8000223a:	f86a                	sd	s10,48(sp)
    8000223c:	f46e                	sd	s11,40(sp)
    8000223e:	0900                	addi	s0,sp,144
    80002240:	8792                	mv	a5,tp
  int id = r_tp();
    80002242:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002244:	00779b93          	slli	s7,a5,0x7
    80002248:	0002f717          	auipc	a4,0x2f
    8000224c:	1f070713          	addi	a4,a4,496 # 80031438 <pid_lock>
    80002250:	975e                	add	a4,a4,s7
    80002252:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    80002256:	0002f717          	auipc	a4,0x2f
    8000225a:	21a70713          	addi	a4,a4,538 # 80031470 <cpus+0x8>
    8000225e:	9bba                	add	s7,s7,a4
  int lastScheduled = -1;
    80002260:	54fd                	li	s1,-1
    acquire(&tickslock);
    80002262:	00036a97          	auipc	s5,0x36
    80002266:	a06a8a93          	addi	s5,s5,-1530 # 80037c68 <tickslock>
    xticks = ticks;
    8000226a:	00006c17          	auipc	s8,0x6
    8000226e:	6f6c0c13          	addi	s8,s8,1782 # 80008960 <ticks>
      if (proc[i].state == RUNNABLE)
    80002272:	0002f917          	auipc	s2,0x2f
    80002276:	5f690913          	addi	s2,s2,1526 # 80031868 <proc>
    8000227a:	4991                	li	s3,4
      c->proc = p;
    8000227c:	079e                	slli	a5,a5,0x7
    8000227e:	0002fa17          	auipc	s4,0x2f
    80002282:	1baa0a13          	addi	s4,s4,442 # 80031438 <pid_lock>
    80002286:	9a3e                	add	s4,s4,a5
    80002288:	aa8d                	j	800023fa <scheduler+0x1d8>
    for (i = (lastScheduled + 1) % NPROC, j = 0; i != lastScheduled && j < NPROC; i = (i + 1) % NPROC, ++j)
    8000228a:	2785                	addiw	a5,a5,1
    8000228c:	41f7d71b          	sraiw	a4,a5,0x1f
    80002290:	01a7571b          	srliw	a4,a4,0x1a
    80002294:	9fb9                	addw	a5,a5,a4
    80002296:	03f7f793          	andi	a5,a5,63
    8000229a:	9f99                	subw	a5,a5,a4
    8000229c:	02f48f63          	beq	s1,a5,800022da <scheduler+0xb8>
    800022a0:	36fd                	addiw	a3,a3,-1
    800022a2:	ce85                	beqz	a3,800022da <scheduler+0xb8>
      if (proc[i].state == RUNNABLE)
    800022a4:	02c78733          	mul	a4,a5,a2
    800022a8:	974a                	add	a4,a4,s2
    800022aa:	4f18                	lw	a4,24(a4)
    800022ac:	fd371fe3          	bne	a4,s3,8000228a <scheduler+0x68>
        if (!procToSchedForPriority[proc[i].priority])
    800022b0:	02c78733          	mul	a4,a5,a2
    800022b4:	974a                	add	a4,a4,s2
    800022b6:	18c72583          	lw	a1,396(a4)
    800022ba:	00359713          	slli	a4,a1,0x3
    800022be:	f9040513          	addi	a0,s0,-112
    800022c2:	972a                	add	a4,a4,a0
    800022c4:	fe073703          	ld	a4,-32(a4)
    800022c8:	f369                	bnez	a4,8000228a <scheduler+0x68>
          procToSchedForPriority[proc[i].priority] = &proc[i];
    800022ca:	058e                	slli	a1,a1,0x3
    800022cc:	95aa                	add	a1,a1,a0
    800022ce:	02c78733          	mul	a4,a5,a2
    800022d2:	974a                	add	a4,a4,s2
    800022d4:	fee5b023          	sd	a4,-32(a1)
    800022d8:	bf4d                	j	8000228a <scheduler+0x68>
    int lowestPriorityToSearch = lastScheduled == -1 ? 4 : proc[i].priority;
    800022da:	56fd                	li	a3,-1
    800022dc:	874e                	mv	a4,s3
    800022de:	00d48b63          	beq	s1,a3,800022f4 <scheduler+0xd2>
    800022e2:	19000713          	li	a4,400
    800022e6:	02e787b3          	mul	a5,a5,a4
    800022ea:	97ca                	add	a5,a5,s2
    800022ec:	18c7a703          	lw	a4,396(a5)
    for (priority = 0; priority < lowestPriorityToSearch; ++priority)
    800022f0:	18e05463          	blez	a4,80002478 <scheduler+0x256>
    800022f4:	f7040793          	addi	a5,s0,-144
    int lowestPriorityToSearch = lastScheduled == -1 ? 4 : proc[i].priority;
    800022f8:	4c81                	li	s9,0
      if (procToSchedForPriority[priority])
    800022fa:	0007bd03          	ld	s10,0(a5)
    800022fe:	0a0d1b63          	bnez	s10,800023b4 <scheduler+0x192>
    for (priority = 0; priority < lowestPriorityToSearch; ++priority)
    80002302:	2c85                	addiw	s9,s9,1
    80002304:	07a1                	addi	a5,a5,8
    80002306:	feeccae3          	blt	s9,a4,800022fa <scheduler+0xd8>
      int pticks = proc[lastScheduled].ticks[proc[lastScheduled].priority];
    8000230a:	19000793          	li	a5,400
    8000230e:	02f487b3          	mul	a5,s1,a5
    80002312:	97ca                	add	a5,a5,s2
    80002314:	18c7a703          	lw	a4,396(a5)
    80002318:	06400793          	li	a5,100
    8000231c:	02f487b3          	mul	a5,s1,a5
    80002320:	97ba                	add	a5,a5,a4
    80002322:	05c78793          	addi	a5,a5,92
    80002326:	078a                	slli	a5,a5,0x2
    80002328:	97ca                	add	a5,a5,s2
    8000232a:	0087ad03          	lw	s10,8(a5)
      switch (proc[lastScheduled].priority)
    8000232e:	4789                	li	a5,2
    80002330:	02f70063          	beq	a4,a5,80002350 <scheduler+0x12e>
    80002334:	14e7c463          	blt	a5,a4,8000247c <scheduler+0x25a>
    80002338:	2701                	sext.w	a4,a4
    8000233a:	4785                	li	a5,1
    8000233c:	02e7e663          	bltu	a5,a4,80002368 <scheduler+0x146>
        timeSliceComplete = (pticks % 5 == 0 && pticks != 0);
    80002340:	4795                	li	a5,5
    80002342:	02fd67bb          	remw	a5,s10,a5
    80002346:	ef89                	bnez	a5,80002360 <scheduler+0x13e>
    80002348:	020d0163          	beqz	s10,8000236a <scheduler+0x148>
    8000234c:	4d05                	li	s10,1
    8000234e:	a831                	j	8000236a <scheduler+0x148>
        timeSliceComplete = (pticks % 10 == 0 && pticks != 0);
    80002350:	47a9                	li	a5,10
    80002352:	02fd67bb          	remw	a5,s10,a5
    80002356:	e799                	bnez	a5,80002364 <scheduler+0x142>
    80002358:	000d0963          	beqz	s10,8000236a <scheduler+0x148>
    8000235c:	4d05                	li	s10,1
    8000235e:	a031                	j	8000236a <scheduler+0x148>
    80002360:	4d01                	li	s10,0
    80002362:	a021                	j	8000236a <scheduler+0x148>
    80002364:	4d01                	li	s10,0
    80002366:	a011                	j	8000236a <scheduler+0x148>
    int timeSliceComplete = 0;
    80002368:	4d01                	li	s10,0
        acquire(&proc[lastScheduled].lock);
    8000236a:	19000d93          	li	s11,400
    8000236e:	03b48db3          	mul	s11,s1,s11
    80002372:	9dca                	add	s11,s11,s2
    80002374:	856e                	mv	a0,s11
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	abe080e7          	jalr	-1346(ra) # 80000e34 <acquire>
        proc[lastScheduled].priority += timeSliceComplete;
    8000237e:	18cda783          	lw	a5,396(s11)
    80002382:	01a787bb          	addw	a5,a5,s10
    80002386:	18fda623          	sw	a5,396(s11)
        release(&proc[lastScheduled].lock);
    8000238a:	856e                	mv	a0,s11
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	b5c080e7          	jalr	-1188(ra) # 80000ee8 <release>
      if (!timeSliceComplete && proc[lastScheduled].state == RUNNABLE)
    80002394:	0e0d1d63          	bnez	s10,8000248e <scheduler+0x26c>
    80002398:	19000793          	li	a5,400
    8000239c:	02f487b3          	mul	a5,s1,a5
    800023a0:	97ca                	add	a5,a5,s2
    800023a2:	4f9c                	lw	a5,24(a5)
    800023a4:	11379463          	bne	a5,s3,800024ac <scheduler+0x28a>
        p = &proc[lastScheduled];
    800023a8:	19000d13          	li	s10,400
    800023ac:	03a484b3          	mul	s1,s1,s10
    800023b0:	01248d33          	add	s10,s1,s2
      acquire(&p->lock);
    800023b4:	856a                	mv	a0,s10
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	a7e080e7          	jalr	-1410(ra) # 80000e34 <acquire>
      p->lastScheduledOnTick = xticks;
    800023be:	196d2423          	sw	s6,392(s10)
      lastScheduled = p - proc;
    800023c2:	412d04b3          	sub	s1,s10,s2
    800023c6:	8491                	srai	s1,s1,0x4
    800023c8:	00006797          	auipc	a5,0x6
    800023cc:	c387b783          	ld	a5,-968(a5) # 80008000 <etext>
    800023d0:	02f484bb          	mulw	s1,s1,a5
      p->state = RUNNING;
    800023d4:	4795                	li	a5,5
    800023d6:	00fd2c23          	sw	a5,24(s10)
      c->proc = p;
    800023da:	03aa3823          	sd	s10,48(s4)
      swtch(&c->context, &p->context);
    800023de:	060d0593          	addi	a1,s10,96
    800023e2:	855e                	mv	a0,s7
    800023e4:	00001097          	auipc	ra,0x1
    800023e8:	92a080e7          	jalr	-1750(ra) # 80002d0e <swtch>
      release(&p->lock);
    800023ec:	856a                	mv	a0,s10
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	afa080e7          	jalr	-1286(ra) # 80000ee8 <release>
    c->proc = 0;
    800023f6:	020a3823          	sd	zero,48(s4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002402:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80002406:	8556                	mv	a0,s5
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	a2c080e7          	jalr	-1492(ra) # 80000e34 <acquire>
    xticks = ticks;
    80002410:	000c2b03          	lw	s6,0(s8)
    release(&tickslock);
    80002414:	8556                	mv	a0,s5
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	ad2080e7          	jalr	-1326(ra) # 80000ee8 <release>
    struct proc *procToSchedForPriority[4] = {0};
    8000241e:	f6043823          	sd	zero,-144(s0)
    80002422:	f6043c23          	sd	zero,-136(s0)
    80002426:	f8043023          	sd	zero,-128(s0)
    8000242a:	f8043423          	sd	zero,-120(s0)
    for (i = (lastScheduled + 1) % NPROC, j = 0; i != lastScheduled && j < NPROC; i = (i + 1) % NPROC, ++j)
    8000242e:	0014871b          	addiw	a4,s1,1
    80002432:	41f7579b          	sraiw	a5,a4,0x1f
    80002436:	01a7d69b          	srliw	a3,a5,0x1a
    8000243a:	00d707bb          	addw	a5,a4,a3
    8000243e:	03f7f793          	andi	a5,a5,63
    80002442:	9f95                	subw	a5,a5,a3
    80002444:	e8f48be3          	beq	s1,a5,800022da <scheduler+0xb8>
    80002448:	04000693          	li	a3,64
      if (proc[i].state == RUNNABLE)
    8000244c:	19000613          	li	a2,400
    80002450:	bd91                	j	800022a4 <scheduler+0x82>
        if (!procToSchedForPriority[proc[lastScheduled].priority] && proc[lastScheduled].state == RUNNABLE)
    80002452:	19000793          	li	a5,400
    80002456:	02f487b3          	mul	a5,s1,a5
    8000245a:	97ca                	add	a5,a5,s2
    8000245c:	4f9c                	lw	a5,24(a5)
    8000245e:	05379763          	bne	a5,s3,800024ac <scheduler+0x28a>
          procToSchedForPriority[proc[lastScheduled].priority] = &proc[lastScheduled];
    80002462:	00371793          	slli	a5,a4,0x3
    80002466:	97b6                	add	a5,a5,a3
    80002468:	19000713          	li	a4,400
    8000246c:	02e48733          	mul	a4,s1,a4
    80002470:	974a                	add	a4,a4,s2
    80002472:	fee7b023          	sd	a4,-32(a5)
    80002476:	a81d                	j	800024ac <scheduler+0x28a>
    for (priority = 0; priority < lowestPriorityToSearch; ++priority)
    80002478:	4c81                	li	s9,0
    8000247a:	bd41                	j	8000230a <scheduler+0xe8>
      switch (proc[lastScheduled].priority)
    8000247c:	478d                	li	a5,3
    8000247e:	f0f71de3          	bne	a4,a5,80002398 <scheduler+0x176>
        timeSliceComplete = (pticks % 20 == 0 && pticks != 0);
    80002482:	47d1                	li	a5,20
    80002484:	02fd67bb          	remw	a5,s10,a5
    80002488:	fb81                	bnez	a5,80002398 <scheduler+0x176>
    8000248a:	f00d07e3          	beqz	s10,80002398 <scheduler+0x176>
        if (!procToSchedForPriority[proc[lastScheduled].priority] && proc[lastScheduled].state == RUNNABLE)
    8000248e:	19000793          	li	a5,400
    80002492:	02f487b3          	mul	a5,s1,a5
    80002496:	97ca                	add	a5,a5,s2
    80002498:	18c7a703          	lw	a4,396(a5)
    8000249c:	00371793          	slli	a5,a4,0x3
    800024a0:	f9040693          	addi	a3,s0,-112
    800024a4:	97b6                	add	a5,a5,a3
    800024a6:	fe07b783          	ld	a5,-32(a5)
    800024aa:	d7c5                	beqz	a5,80002452 <scheduler+0x230>
        for (; priority < 4; ++priority)
    800024ac:	478d                	li	a5,3
    800024ae:	0197cf63          	blt	a5,s9,800024cc <scheduler+0x2aa>
    800024b2:	003c9793          	slli	a5,s9,0x3
    800024b6:	f7040713          	addi	a4,s0,-144
    800024ba:	97ba                	add	a5,a5,a4
          if (procToSchedForPriority[priority])
    800024bc:	0007bd03          	ld	s10,0(a5)
    800024c0:	ee0d1ae3          	bnez	s10,800023b4 <scheduler+0x192>
        for (; priority < 4; ++priority)
    800024c4:	2c85                	addiw	s9,s9,1
    800024c6:	07a1                	addi	a5,a5,8
    800024c8:	ff3c9ae3          	bne	s9,s3,800024bc <scheduler+0x29a>
        p = &proc[lastScheduled];
    800024cc:	19000d13          	li	s10,400
    800024d0:	03a484b3          	mul	s1,s1,s10
    800024d4:	01248d33          	add	s10,s1,s2
    800024d8:	bdf1                	j	800023b4 <scheduler+0x192>

00000000800024da <sched>:
{
    800024da:	7179                	addi	sp,sp,-48
    800024dc:	f406                	sd	ra,40(sp)
    800024de:	f022                	sd	s0,32(sp)
    800024e0:	ec26                	sd	s1,24(sp)
    800024e2:	e84a                	sd	s2,16(sp)
    800024e4:	e44e                	sd	s3,8(sp)
    800024e6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	728080e7          	jalr	1832(ra) # 80001c10 <myproc>
    800024f0:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	8c8080e7          	jalr	-1848(ra) # 80000dba <holding>
    800024fa:	c93d                	beqz	a0,80002570 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800024fc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800024fe:	2781                	sext.w	a5,a5
    80002500:	079e                	slli	a5,a5,0x7
    80002502:	0002f717          	auipc	a4,0x2f
    80002506:	f3670713          	addi	a4,a4,-202 # 80031438 <pid_lock>
    8000250a:	97ba                	add	a5,a5,a4
    8000250c:	0a87a703          	lw	a4,168(a5)
    80002510:	4785                	li	a5,1
    80002512:	06f71763          	bne	a4,a5,80002580 <sched+0xa6>
  if (p->state == RUNNING)
    80002516:	4c98                	lw	a4,24(s1)
    80002518:	4795                	li	a5,5
    8000251a:	06f70b63          	beq	a4,a5,80002590 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000251e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002522:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002524:	efb5                	bnez	a5,800025a0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002526:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002528:	0002f917          	auipc	s2,0x2f
    8000252c:	f1090913          	addi	s2,s2,-240 # 80031438 <pid_lock>
    80002530:	2781                	sext.w	a5,a5
    80002532:	079e                	slli	a5,a5,0x7
    80002534:	97ca                	add	a5,a5,s2
    80002536:	0ac7a983          	lw	s3,172(a5)
    8000253a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000253c:	2781                	sext.w	a5,a5
    8000253e:	079e                	slli	a5,a5,0x7
    80002540:	0002f597          	auipc	a1,0x2f
    80002544:	f3058593          	addi	a1,a1,-208 # 80031470 <cpus+0x8>
    80002548:	95be                	add	a1,a1,a5
    8000254a:	06048513          	addi	a0,s1,96
    8000254e:	00000097          	auipc	ra,0x0
    80002552:	7c0080e7          	jalr	1984(ra) # 80002d0e <swtch>
    80002556:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002558:	2781                	sext.w	a5,a5
    8000255a:	079e                	slli	a5,a5,0x7
    8000255c:	97ca                	add	a5,a5,s2
    8000255e:	0b37a623          	sw	s3,172(a5)
}
    80002562:	70a2                	ld	ra,40(sp)
    80002564:	7402                	ld	s0,32(sp)
    80002566:	64e2                	ld	s1,24(sp)
    80002568:	6942                	ld	s2,16(sp)
    8000256a:	69a2                	ld	s3,8(sp)
    8000256c:	6145                	addi	sp,sp,48
    8000256e:	8082                	ret
    panic("sched p->lock");
    80002570:	00006517          	auipc	a0,0x6
    80002574:	cb850513          	addi	a0,a0,-840 # 80008228 <digits+0x1e0>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	094080e7          	jalr	148(ra) # 8000060c <panic>
    panic("sched locks");
    80002580:	00006517          	auipc	a0,0x6
    80002584:	cb850513          	addi	a0,a0,-840 # 80008238 <digits+0x1f0>
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	084080e7          	jalr	132(ra) # 8000060c <panic>
    panic("sched running");
    80002590:	00006517          	auipc	a0,0x6
    80002594:	cb850513          	addi	a0,a0,-840 # 80008248 <digits+0x200>
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	074080e7          	jalr	116(ra) # 8000060c <panic>
    panic("sched interruptible");
    800025a0:	00006517          	auipc	a0,0x6
    800025a4:	cb850513          	addi	a0,a0,-840 # 80008258 <digits+0x210>
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	064080e7          	jalr	100(ra) # 8000060c <panic>

00000000800025b0 <yield>:
{
    800025b0:	1101                	addi	sp,sp,-32
    800025b2:	ec06                	sd	ra,24(sp)
    800025b4:	e822                	sd	s0,16(sp)
    800025b6:	e426                	sd	s1,8(sp)
    800025b8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	656080e7          	jalr	1622(ra) # 80001c10 <myproc>
    800025c2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025c4:	fffff097          	auipc	ra,0xfffff
    800025c8:	870080e7          	jalr	-1936(ra) # 80000e34 <acquire>
  p->state = RUNNABLE;
    800025cc:	4791                	li	a5,4
    800025ce:	cc9c                	sw	a5,24(s1)
  sched();
    800025d0:	00000097          	auipc	ra,0x0
    800025d4:	f0a080e7          	jalr	-246(ra) # 800024da <sched>
  release(&p->lock);
    800025d8:	8526                	mv	a0,s1
    800025da:	fffff097          	auipc	ra,0xfffff
    800025de:	90e080e7          	jalr	-1778(ra) # 80000ee8 <release>
}
    800025e2:	60e2                	ld	ra,24(sp)
    800025e4:	6442                	ld	s0,16(sp)
    800025e6:	64a2                	ld	s1,8(sp)
    800025e8:	6105                	addi	sp,sp,32
    800025ea:	8082                	ret

00000000800025ec <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800025ec:	7179                	addi	sp,sp,-48
    800025ee:	f406                	sd	ra,40(sp)
    800025f0:	f022                	sd	s0,32(sp)
    800025f2:	ec26                	sd	s1,24(sp)
    800025f4:	e84a                	sd	s2,16(sp)
    800025f6:	e44e                	sd	s3,8(sp)
    800025f8:	1800                	addi	s0,sp,48
    800025fa:	89aa                	mv	s3,a0
    800025fc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800025fe:	fffff097          	auipc	ra,0xfffff
    80002602:	612080e7          	jalr	1554(ra) # 80001c10 <myproc>
    80002606:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002608:	fffff097          	auipc	ra,0xfffff
    8000260c:	82c080e7          	jalr	-2004(ra) # 80000e34 <acquire>
  release(lk);
    80002610:	854a                	mv	a0,s2
    80002612:	fffff097          	auipc	ra,0xfffff
    80002616:	8d6080e7          	jalr	-1834(ra) # 80000ee8 <release>

  // Go to sleep.
  p->chan = chan;
    8000261a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000261e:	478d                	li	a5,3
    80002620:	cc9c                	sw	a5,24(s1)

  sched();
    80002622:	00000097          	auipc	ra,0x0
    80002626:	eb8080e7          	jalr	-328(ra) # 800024da <sched>

  // Tidy up.
  p->chan = 0;
    8000262a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000262e:	8526                	mv	a0,s1
    80002630:	fffff097          	auipc	ra,0xfffff
    80002634:	8b8080e7          	jalr	-1864(ra) # 80000ee8 <release>
  acquire(lk);
    80002638:	854a                	mv	a0,s2
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	7fa080e7          	jalr	2042(ra) # 80000e34 <acquire>
}
    80002642:	70a2                	ld	ra,40(sp)
    80002644:	7402                	ld	s0,32(sp)
    80002646:	64e2                	ld	s1,24(sp)
    80002648:	6942                	ld	s2,16(sp)
    8000264a:	69a2                	ld	s3,8(sp)
    8000264c:	6145                	addi	sp,sp,48
    8000264e:	8082                	ret

0000000080002650 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002650:	7139                	addi	sp,sp,-64
    80002652:	fc06                	sd	ra,56(sp)
    80002654:	f822                	sd	s0,48(sp)
    80002656:	f426                	sd	s1,40(sp)
    80002658:	f04a                	sd	s2,32(sp)
    8000265a:	ec4e                	sd	s3,24(sp)
    8000265c:	e852                	sd	s4,16(sp)
    8000265e:	e456                	sd	s5,8(sp)
    80002660:	0080                	addi	s0,sp,64
    80002662:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002664:	0002f497          	auipc	s1,0x2f
    80002668:	20448493          	addi	s1,s1,516 # 80031868 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000266c:	498d                	li	s3,3
      {
        p->state = RUNNABLE;
    8000266e:	4a91                	li	s5,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002670:	00035917          	auipc	s2,0x35
    80002674:	5f890913          	addi	s2,s2,1528 # 80037c68 <tickslock>
    80002678:	a811                	j	8000268c <wakeup+0x3c>
      }
      release(&p->lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	fffff097          	auipc	ra,0xfffff
    80002680:	86c080e7          	jalr	-1940(ra) # 80000ee8 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002684:	19048493          	addi	s1,s1,400
    80002688:	03248663          	beq	s1,s2,800026b4 <wakeup+0x64>
    if (p != myproc())
    8000268c:	fffff097          	auipc	ra,0xfffff
    80002690:	584080e7          	jalr	1412(ra) # 80001c10 <myproc>
    80002694:	fea488e3          	beq	s1,a0,80002684 <wakeup+0x34>
      acquire(&p->lock);
    80002698:	8526                	mv	a0,s1
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	79a080e7          	jalr	1946(ra) # 80000e34 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800026a2:	4c9c                	lw	a5,24(s1)
    800026a4:	fd379be3          	bne	a5,s3,8000267a <wakeup+0x2a>
    800026a8:	709c                	ld	a5,32(s1)
    800026aa:	fd4798e3          	bne	a5,s4,8000267a <wakeup+0x2a>
        p->state = RUNNABLE;
    800026ae:	0154ac23          	sw	s5,24(s1)
    800026b2:	b7e1                	j	8000267a <wakeup+0x2a>
    }
  }
}
    800026b4:	70e2                	ld	ra,56(sp)
    800026b6:	7442                	ld	s0,48(sp)
    800026b8:	74a2                	ld	s1,40(sp)
    800026ba:	7902                	ld	s2,32(sp)
    800026bc:	69e2                	ld	s3,24(sp)
    800026be:	6a42                	ld	s4,16(sp)
    800026c0:	6aa2                	ld	s5,8(sp)
    800026c2:	6121                	addi	sp,sp,64
    800026c4:	8082                	ret

00000000800026c6 <reparent>:
{
    800026c6:	7179                	addi	sp,sp,-48
    800026c8:	f406                	sd	ra,40(sp)
    800026ca:	f022                	sd	s0,32(sp)
    800026cc:	ec26                	sd	s1,24(sp)
    800026ce:	e84a                	sd	s2,16(sp)
    800026d0:	e44e                	sd	s3,8(sp)
    800026d2:	e052                	sd	s4,0(sp)
    800026d4:	1800                	addi	s0,sp,48
    800026d6:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800026d8:	0002f497          	auipc	s1,0x2f
    800026dc:	19048493          	addi	s1,s1,400 # 80031868 <proc>
      pp->parent = initproc;
    800026e0:	00006a17          	auipc	s4,0x6
    800026e4:	278a0a13          	addi	s4,s4,632 # 80008958 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800026e8:	00035997          	auipc	s3,0x35
    800026ec:	58098993          	addi	s3,s3,1408 # 80037c68 <tickslock>
    800026f0:	a029                	j	800026fa <reparent+0x34>
    800026f2:	19048493          	addi	s1,s1,400
    800026f6:	01348d63          	beq	s1,s3,80002710 <reparent+0x4a>
    if (pp->parent == p)
    800026fa:	7c9c                	ld	a5,56(s1)
    800026fc:	ff279be3          	bne	a5,s2,800026f2 <reparent+0x2c>
      pp->parent = initproc;
    80002700:	000a3503          	ld	a0,0(s4)
    80002704:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002706:	00000097          	auipc	ra,0x0
    8000270a:	f4a080e7          	jalr	-182(ra) # 80002650 <wakeup>
    8000270e:	b7d5                	j	800026f2 <reparent+0x2c>
}
    80002710:	70a2                	ld	ra,40(sp)
    80002712:	7402                	ld	s0,32(sp)
    80002714:	64e2                	ld	s1,24(sp)
    80002716:	6942                	ld	s2,16(sp)
    80002718:	69a2                	ld	s3,8(sp)
    8000271a:	6a02                	ld	s4,0(sp)
    8000271c:	6145                	addi	sp,sp,48
    8000271e:	8082                	ret

0000000080002720 <exit>:
{
    80002720:	7179                	addi	sp,sp,-48
    80002722:	f406                	sd	ra,40(sp)
    80002724:	f022                	sd	s0,32(sp)
    80002726:	ec26                	sd	s1,24(sp)
    80002728:	e84a                	sd	s2,16(sp)
    8000272a:	e44e                	sd	s3,8(sp)
    8000272c:	e052                	sd	s4,0(sp)
    8000272e:	1800                	addi	s0,sp,48
    80002730:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002732:	fffff097          	auipc	ra,0xfffff
    80002736:	4de080e7          	jalr	1246(ra) # 80001c10 <myproc>
    8000273a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000273c:	00006797          	auipc	a5,0x6
    80002740:	21c7b783          	ld	a5,540(a5) # 80008958 <initproc>
    80002744:	0d050493          	addi	s1,a0,208
    80002748:	15050913          	addi	s2,a0,336
    8000274c:	02a79363          	bne	a5,a0,80002772 <exit+0x52>
    panic("init exiting");
    80002750:	00006517          	auipc	a0,0x6
    80002754:	b2050513          	addi	a0,a0,-1248 # 80008270 <digits+0x228>
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	eb4080e7          	jalr	-332(ra) # 8000060c <panic>
      fileclose(f);
    80002760:	00002097          	auipc	ra,0x2
    80002764:	672080e7          	jalr	1650(ra) # 80004dd2 <fileclose>
      p->ofile[fd] = 0;
    80002768:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    8000276c:	04a1                	addi	s1,s1,8
    8000276e:	01248563          	beq	s1,s2,80002778 <exit+0x58>
    if (p->ofile[fd])
    80002772:	6088                	ld	a0,0(s1)
    80002774:	f575                	bnez	a0,80002760 <exit+0x40>
    80002776:	bfdd                	j	8000276c <exit+0x4c>
  begin_op();
    80002778:	00002097          	auipc	ra,0x2
    8000277c:	18e080e7          	jalr	398(ra) # 80004906 <begin_op>
  iput(p->cwd);
    80002780:	1509b503          	ld	a0,336(s3)
    80002784:	00002097          	auipc	ra,0x2
    80002788:	97a080e7          	jalr	-1670(ra) # 800040fe <iput>
  end_op();
    8000278c:	00002097          	auipc	ra,0x2
    80002790:	1fa080e7          	jalr	506(ra) # 80004986 <end_op>
  p->cwd = 0;
    80002794:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002798:	0002f497          	auipc	s1,0x2f
    8000279c:	cb848493          	addi	s1,s1,-840 # 80031450 <wait_lock>
    800027a0:	8526                	mv	a0,s1
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	692080e7          	jalr	1682(ra) # 80000e34 <acquire>
  reparent(p);
    800027aa:	854e                	mv	a0,s3
    800027ac:	00000097          	auipc	ra,0x0
    800027b0:	f1a080e7          	jalr	-230(ra) # 800026c6 <reparent>
  wakeup(p->parent);
    800027b4:	0389b503          	ld	a0,56(s3)
    800027b8:	00000097          	auipc	ra,0x0
    800027bc:	e98080e7          	jalr	-360(ra) # 80002650 <wakeup>
  acquire(&p->lock);
    800027c0:	854e                	mv	a0,s3
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	672080e7          	jalr	1650(ra) # 80000e34 <acquire>
  p->xstate = status;
    800027ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800027ce:	4799                	li	a5,6
    800027d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800027d4:	8526                	mv	a0,s1
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	712080e7          	jalr	1810(ra) # 80000ee8 <release>
  sched();
    800027de:	00000097          	auipc	ra,0x0
    800027e2:	cfc080e7          	jalr	-772(ra) # 800024da <sched>
  panic("zombie exit");
    800027e6:	00006517          	auipc	a0,0x6
    800027ea:	a9a50513          	addi	a0,a0,-1382 # 80008280 <digits+0x238>
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	e1e080e7          	jalr	-482(ra) # 8000060c <panic>

00000000800027f6 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800027f6:	7179                	addi	sp,sp,-48
    800027f8:	f406                	sd	ra,40(sp)
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	ec26                	sd	s1,24(sp)
    800027fe:	e84a                	sd	s2,16(sp)
    80002800:	e44e                	sd	s3,8(sp)
    80002802:	1800                	addi	s0,sp,48
    80002804:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002806:	0002f497          	auipc	s1,0x2f
    8000280a:	06248493          	addi	s1,s1,98 # 80031868 <proc>
    8000280e:	00035997          	auipc	s3,0x35
    80002812:	45a98993          	addi	s3,s3,1114 # 80037c68 <tickslock>
  {
    acquire(&p->lock);
    80002816:	8526                	mv	a0,s1
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	61c080e7          	jalr	1564(ra) # 80000e34 <acquire>
    if (p->pid == pid)
    80002820:	589c                	lw	a5,48(s1)
    80002822:	01278d63          	beq	a5,s2,8000283c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002826:	8526                	mv	a0,s1
    80002828:	ffffe097          	auipc	ra,0xffffe
    8000282c:	6c0080e7          	jalr	1728(ra) # 80000ee8 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002830:	19048493          	addi	s1,s1,400
    80002834:	ff3491e3          	bne	s1,s3,80002816 <kill+0x20>
  }
  return -1;
    80002838:	557d                	li	a0,-1
    8000283a:	a829                	j	80002854 <kill+0x5e>
      p->killed = 1;
    8000283c:	4785                	li	a5,1
    8000283e:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002840:	4c98                	lw	a4,24(s1)
    80002842:	478d                	li	a5,3
    80002844:	00f70f63          	beq	a4,a5,80002862 <kill+0x6c>
      release(&p->lock);
    80002848:	8526                	mv	a0,s1
    8000284a:	ffffe097          	auipc	ra,0xffffe
    8000284e:	69e080e7          	jalr	1694(ra) # 80000ee8 <release>
      return 0;
    80002852:	4501                	li	a0,0
}
    80002854:	70a2                	ld	ra,40(sp)
    80002856:	7402                	ld	s0,32(sp)
    80002858:	64e2                	ld	s1,24(sp)
    8000285a:	6942                	ld	s2,16(sp)
    8000285c:	69a2                	ld	s3,8(sp)
    8000285e:	6145                	addi	sp,sp,48
    80002860:	8082                	ret
        p->state = RUNNABLE;
    80002862:	4791                	li	a5,4
    80002864:	cc9c                	sw	a5,24(s1)
    80002866:	b7cd                	j	80002848 <kill+0x52>

0000000080002868 <setkilled>:

void setkilled(struct proc *p)
{
    80002868:	1101                	addi	sp,sp,-32
    8000286a:	ec06                	sd	ra,24(sp)
    8000286c:	e822                	sd	s0,16(sp)
    8000286e:	e426                	sd	s1,8(sp)
    80002870:	1000                	addi	s0,sp,32
    80002872:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	5c0080e7          	jalr	1472(ra) # 80000e34 <acquire>
  p->killed = 1;
    8000287c:	4785                	li	a5,1
    8000287e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002880:	8526                	mv	a0,s1
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	666080e7          	jalr	1638(ra) # 80000ee8 <release>
}
    8000288a:	60e2                	ld	ra,24(sp)
    8000288c:	6442                	ld	s0,16(sp)
    8000288e:	64a2                	ld	s1,8(sp)
    80002890:	6105                	addi	sp,sp,32
    80002892:	8082                	ret

0000000080002894 <killed>:

int killed(struct proc *p)
{
    80002894:	1101                	addi	sp,sp,-32
    80002896:	ec06                	sd	ra,24(sp)
    80002898:	e822                	sd	s0,16(sp)
    8000289a:	e426                	sd	s1,8(sp)
    8000289c:	e04a                	sd	s2,0(sp)
    8000289e:	1000                	addi	s0,sp,32
    800028a0:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	592080e7          	jalr	1426(ra) # 80000e34 <acquire>
  k = p->killed;
    800028aa:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800028ae:	8526                	mv	a0,s1
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	638080e7          	jalr	1592(ra) # 80000ee8 <release>
  return k;
}
    800028b8:	854a                	mv	a0,s2
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6902                	ld	s2,0(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret

00000000800028c6 <wait>:
{
    800028c6:	715d                	addi	sp,sp,-80
    800028c8:	e486                	sd	ra,72(sp)
    800028ca:	e0a2                	sd	s0,64(sp)
    800028cc:	fc26                	sd	s1,56(sp)
    800028ce:	f84a                	sd	s2,48(sp)
    800028d0:	f44e                	sd	s3,40(sp)
    800028d2:	f052                	sd	s4,32(sp)
    800028d4:	ec56                	sd	s5,24(sp)
    800028d6:	e85a                	sd	s6,16(sp)
    800028d8:	e45e                	sd	s7,8(sp)
    800028da:	e062                	sd	s8,0(sp)
    800028dc:	0880                	addi	s0,sp,80
    800028de:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800028e0:	fffff097          	auipc	ra,0xfffff
    800028e4:	330080e7          	jalr	816(ra) # 80001c10 <myproc>
    800028e8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800028ea:	0002f517          	auipc	a0,0x2f
    800028ee:	b6650513          	addi	a0,a0,-1178 # 80031450 <wait_lock>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	542080e7          	jalr	1346(ra) # 80000e34 <acquire>
    havekids = 0;
    800028fa:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800028fc:	4a19                	li	s4,6
        havekids = 1;
    800028fe:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002900:	00035997          	auipc	s3,0x35
    80002904:	36898993          	addi	s3,s3,872 # 80037c68 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002908:	0002fc17          	auipc	s8,0x2f
    8000290c:	b48c0c13          	addi	s8,s8,-1208 # 80031450 <wait_lock>
    havekids = 0;
    80002910:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002912:	0002f497          	auipc	s1,0x2f
    80002916:	f5648493          	addi	s1,s1,-170 # 80031868 <proc>
    8000291a:	a0bd                	j	80002988 <wait+0xc2>
          pid = pp->pid;
    8000291c:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002920:	000b0e63          	beqz	s6,8000293c <wait+0x76>
    80002924:	4691                	li	a3,4
    80002926:	02c48613          	addi	a2,s1,44
    8000292a:	85da                	mv	a1,s6
    8000292c:	05093503          	ld	a0,80(s2)
    80002930:	fffff097          	auipc	ra,0xfffff
    80002934:	f96080e7          	jalr	-106(ra) # 800018c6 <copyout>
    80002938:	02054563          	bltz	a0,80002962 <wait+0x9c>
          freeproc(pp);
    8000293c:	8526                	mv	a0,s1
    8000293e:	fffff097          	auipc	ra,0xfffff
    80002942:	484080e7          	jalr	1156(ra) # 80001dc2 <freeproc>
          release(&pp->lock);
    80002946:	8526                	mv	a0,s1
    80002948:	ffffe097          	auipc	ra,0xffffe
    8000294c:	5a0080e7          	jalr	1440(ra) # 80000ee8 <release>
          release(&wait_lock);
    80002950:	0002f517          	auipc	a0,0x2f
    80002954:	b0050513          	addi	a0,a0,-1280 # 80031450 <wait_lock>
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	590080e7          	jalr	1424(ra) # 80000ee8 <release>
          return pid;
    80002960:	a0b5                	j	800029cc <wait+0x106>
            release(&pp->lock);
    80002962:	8526                	mv	a0,s1
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	584080e7          	jalr	1412(ra) # 80000ee8 <release>
            release(&wait_lock);
    8000296c:	0002f517          	auipc	a0,0x2f
    80002970:	ae450513          	addi	a0,a0,-1308 # 80031450 <wait_lock>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	574080e7          	jalr	1396(ra) # 80000ee8 <release>
            return -1;
    8000297c:	59fd                	li	s3,-1
    8000297e:	a0b9                	j	800029cc <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002980:	19048493          	addi	s1,s1,400
    80002984:	03348463          	beq	s1,s3,800029ac <wait+0xe6>
      if (pp->parent == p)
    80002988:	7c9c                	ld	a5,56(s1)
    8000298a:	ff279be3          	bne	a5,s2,80002980 <wait+0xba>
        acquire(&pp->lock);
    8000298e:	8526                	mv	a0,s1
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	4a4080e7          	jalr	1188(ra) # 80000e34 <acquire>
        if (pp->state == ZOMBIE)
    80002998:	4c9c                	lw	a5,24(s1)
    8000299a:	f94781e3          	beq	a5,s4,8000291c <wait+0x56>
        release(&pp->lock);
    8000299e:	8526                	mv	a0,s1
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	548080e7          	jalr	1352(ra) # 80000ee8 <release>
        havekids = 1;
    800029a8:	8756                	mv	a4,s5
    800029aa:	bfd9                	j	80002980 <wait+0xba>
    if (!havekids || killed(p))
    800029ac:	c719                	beqz	a4,800029ba <wait+0xf4>
    800029ae:	854a                	mv	a0,s2
    800029b0:	00000097          	auipc	ra,0x0
    800029b4:	ee4080e7          	jalr	-284(ra) # 80002894 <killed>
    800029b8:	c51d                	beqz	a0,800029e6 <wait+0x120>
      release(&wait_lock);
    800029ba:	0002f517          	auipc	a0,0x2f
    800029be:	a9650513          	addi	a0,a0,-1386 # 80031450 <wait_lock>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	526080e7          	jalr	1318(ra) # 80000ee8 <release>
      return -1;
    800029ca:	59fd                	li	s3,-1
}
    800029cc:	854e                	mv	a0,s3
    800029ce:	60a6                	ld	ra,72(sp)
    800029d0:	6406                	ld	s0,64(sp)
    800029d2:	74e2                	ld	s1,56(sp)
    800029d4:	7942                	ld	s2,48(sp)
    800029d6:	79a2                	ld	s3,40(sp)
    800029d8:	7a02                	ld	s4,32(sp)
    800029da:	6ae2                	ld	s5,24(sp)
    800029dc:	6b42                	ld	s6,16(sp)
    800029de:	6ba2                	ld	s7,8(sp)
    800029e0:	6c02                	ld	s8,0(sp)
    800029e2:	6161                	addi	sp,sp,80
    800029e4:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800029e6:	85e2                	mv	a1,s8
    800029e8:	854a                	mv	a0,s2
    800029ea:	00000097          	auipc	ra,0x0
    800029ee:	c02080e7          	jalr	-1022(ra) # 800025ec <sleep>
    havekids = 0;
    800029f2:	bf39                	j	80002910 <wait+0x4a>

00000000800029f4 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800029f4:	7179                	addi	sp,sp,-48
    800029f6:	f406                	sd	ra,40(sp)
    800029f8:	f022                	sd	s0,32(sp)
    800029fa:	ec26                	sd	s1,24(sp)
    800029fc:	e84a                	sd	s2,16(sp)
    800029fe:	e44e                	sd	s3,8(sp)
    80002a00:	e052                	sd	s4,0(sp)
    80002a02:	1800                	addi	s0,sp,48
    80002a04:	84aa                	mv	s1,a0
    80002a06:	892e                	mv	s2,a1
    80002a08:	89b2                	mv	s3,a2
    80002a0a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	204080e7          	jalr	516(ra) # 80001c10 <myproc>
  if (user_dst)
    80002a14:	c08d                	beqz	s1,80002a36 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002a16:	86d2                	mv	a3,s4
    80002a18:	864e                	mv	a2,s3
    80002a1a:	85ca                	mv	a1,s2
    80002a1c:	6928                	ld	a0,80(a0)
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	ea8080e7          	jalr	-344(ra) # 800018c6 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a26:	70a2                	ld	ra,40(sp)
    80002a28:	7402                	ld	s0,32(sp)
    80002a2a:	64e2                	ld	s1,24(sp)
    80002a2c:	6942                	ld	s2,16(sp)
    80002a2e:	69a2                	ld	s3,8(sp)
    80002a30:	6a02                	ld	s4,0(sp)
    80002a32:	6145                	addi	sp,sp,48
    80002a34:	8082                	ret
    memmove((char *)dst, src, len);
    80002a36:	000a061b          	sext.w	a2,s4
    80002a3a:	85ce                	mv	a1,s3
    80002a3c:	854a                	mv	a0,s2
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	54e080e7          	jalr	1358(ra) # 80000f8c <memmove>
    return 0;
    80002a46:	8526                	mv	a0,s1
    80002a48:	bff9                	j	80002a26 <either_copyout+0x32>

0000000080002a4a <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a4a:	7179                	addi	sp,sp,-48
    80002a4c:	f406                	sd	ra,40(sp)
    80002a4e:	f022                	sd	s0,32(sp)
    80002a50:	ec26                	sd	s1,24(sp)
    80002a52:	e84a                	sd	s2,16(sp)
    80002a54:	e44e                	sd	s3,8(sp)
    80002a56:	e052                	sd	s4,0(sp)
    80002a58:	1800                	addi	s0,sp,48
    80002a5a:	892a                	mv	s2,a0
    80002a5c:	84ae                	mv	s1,a1
    80002a5e:	89b2                	mv	s3,a2
    80002a60:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	1ae080e7          	jalr	430(ra) # 80001c10 <myproc>
  if (user_src)
    80002a6a:	c08d                	beqz	s1,80002a8c <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002a6c:	86d2                	mv	a3,s4
    80002a6e:	864e                	mv	a2,s3
    80002a70:	85ca                	mv	a1,s2
    80002a72:	6928                	ld	a0,80(a0)
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	ede080e7          	jalr	-290(ra) # 80001952 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002a7c:	70a2                	ld	ra,40(sp)
    80002a7e:	7402                	ld	s0,32(sp)
    80002a80:	64e2                	ld	s1,24(sp)
    80002a82:	6942                	ld	s2,16(sp)
    80002a84:	69a2                	ld	s3,8(sp)
    80002a86:	6a02                	ld	s4,0(sp)
    80002a88:	6145                	addi	sp,sp,48
    80002a8a:	8082                	ret
    memmove(dst, (char *)src, len);
    80002a8c:	000a061b          	sext.w	a2,s4
    80002a90:	85ce                	mv	a1,s3
    80002a92:	854a                	mv	a0,s2
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	4f8080e7          	jalr	1272(ra) # 80000f8c <memmove>
    return 0;
    80002a9c:	8526                	mv	a0,s1
    80002a9e:	bff9                	j	80002a7c <either_copyin+0x32>

0000000080002aa0 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002aa0:	715d                	addi	sp,sp,-80
    80002aa2:	e486                	sd	ra,72(sp)
    80002aa4:	e0a2                	sd	s0,64(sp)
    80002aa6:	fc26                	sd	s1,56(sp)
    80002aa8:	f84a                	sd	s2,48(sp)
    80002aaa:	f44e                	sd	s3,40(sp)
    80002aac:	f052                	sd	s4,32(sp)
    80002aae:	ec56                	sd	s5,24(sp)
    80002ab0:	e85a                	sd	s6,16(sp)
    80002ab2:	e45e                	sd	s7,8(sp)
    80002ab4:	e062                	sd	s8,0(sp)
    80002ab6:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002ab8:	00005517          	auipc	a0,0x5
    80002abc:	62050513          	addi	a0,a0,1568 # 800080d8 <digits+0x90>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	b96080e7          	jalr	-1130(ra) # 80000656 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002ac8:	0002f497          	auipc	s1,0x2f
    80002acc:	ef848493          	addi	s1,s1,-264 # 800319c0 <proc+0x158>
    80002ad0:	00035997          	auipc	s3,0x35
    80002ad4:	2f098993          	addi	s3,s3,752 # 80037dc0 <bcache+0x140>
  {
    if (p->state == UNUSED)
    80002ad8:	4905                	li	s2,1
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ada:	4b99                	li	s7,6
      state = states[p->state];
    else
      state = "???";
    80002adc:	00005a17          	auipc	s4,0x5
    80002ae0:	7b4a0a13          	addi	s4,s4,1972 # 80008290 <digits+0x248>
    printf("%d %s %s", p->pid, state, p->name);
    80002ae4:	00005b17          	auipc	s6,0x5
    80002ae8:	7b4b0b13          	addi	s6,s6,1972 # 80008298 <digits+0x250>
    printf("\n");
    80002aec:	00005a97          	auipc	s5,0x5
    80002af0:	5eca8a93          	addi	s5,s5,1516 # 800080d8 <digits+0x90>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002af4:	00006c17          	auipc	s8,0x6
    80002af8:	81cc0c13          	addi	s8,s8,-2020 # 80008310 <states.0>
    80002afc:	a00d                	j	80002b1e <procdump+0x7e>
    printf("%d %s %s", p->pid, state, p->name);
    80002afe:	ed86a583          	lw	a1,-296(a3)
    80002b02:	855a                	mv	a0,s6
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	b52080e7          	jalr	-1198(ra) # 80000656 <printf>
    printf("\n");
    80002b0c:	8556                	mv	a0,s5
    80002b0e:	ffffe097          	auipc	ra,0xffffe
    80002b12:	b48080e7          	jalr	-1208(ra) # 80000656 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b16:	19048493          	addi	s1,s1,400
    80002b1a:	03348263          	beq	s1,s3,80002b3e <procdump+0x9e>
    if (p->state == UNUSED)
    80002b1e:	86a6                	mv	a3,s1
    80002b20:	ec04a783          	lw	a5,-320(s1)
    80002b24:	ff2789e3          	beq	a5,s2,80002b16 <procdump+0x76>
      state = "???";
    80002b28:	8652                	mv	a2,s4
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b2a:	fcfbeae3          	bltu	s7,a5,80002afe <procdump+0x5e>
    80002b2e:	1782                	slli	a5,a5,0x20
    80002b30:	9381                	srli	a5,a5,0x20
    80002b32:	078e                	slli	a5,a5,0x3
    80002b34:	97e2                	add	a5,a5,s8
    80002b36:	6390                	ld	a2,0(a5)
    80002b38:	f279                	bnez	a2,80002afe <procdump+0x5e>
      state = "???";
    80002b3a:	8652                	mv	a2,s4
    80002b3c:	b7c9                	j	80002afe <procdump+0x5e>
  }
}
    80002b3e:	60a6                	ld	ra,72(sp)
    80002b40:	6406                	ld	s0,64(sp)
    80002b42:	74e2                	ld	s1,56(sp)
    80002b44:	7942                	ld	s2,48(sp)
    80002b46:	79a2                	ld	s3,40(sp)
    80002b48:	7a02                	ld	s4,32(sp)
    80002b4a:	6ae2                	ld	s5,24(sp)
    80002b4c:	6b42                	ld	s6,16(sp)
    80002b4e:	6ba2                	ld	s7,8(sp)
    80002b50:	6c02                	ld	s8,0(sp)
    80002b52:	6161                	addi	sp,sp,80
    80002b54:	8082                	ret

0000000080002b56 <history>:

int history(int historyId)
{
    80002b56:	7139                	addi	sp,sp,-64
    80002b58:	fc06                	sd	ra,56(sp)
    80002b5a:	f822                	sd	s0,48(sp)
    80002b5c:	f426                	sd	s1,40(sp)
    80002b5e:	f04a                	sd	s2,32(sp)
    80002b60:	ec4e                	sd	s3,24(sp)
    80002b62:	e852                	sd	s4,16(sp)
    80002b64:	e456                	sd	s5,8(sp)
    80002b66:	0080                	addi	s0,sp,64
    80002b68:	8aaa                	mv	s5,a0
  uint i = 0;
  for (i = 0; i <= historyBufferArray.lastCommandIndex; i++)
    80002b6a:	4481                	li	s1,0
  {
    printf("%s", historyBufferArray.bufferArr[i]);
    80002b6c:	0000ea17          	auipc	s4,0xe
    80002b70:	feca0a13          	addi	s4,s4,-20 # 80010b58 <historyBufferArray>
    80002b74:	00005997          	auipc	s3,0x5
    80002b78:	73498993          	addi	s3,s3,1844 # 800082a8 <digits+0x260>
  for (i = 0; i <= historyBufferArray.lastCommandIndex; i++)
    80002b7c:	0000f917          	auipc	s2,0xf
    80002b80:	fdc90913          	addi	s2,s2,-36 # 80011b58 <kref+0x738>
    printf("%s", historyBufferArray.bufferArr[i]);
    80002b84:	02049593          	slli	a1,s1,0x20
    80002b88:	9181                	srli	a1,a1,0x20
    80002b8a:	059e                	slli	a1,a1,0x7
    80002b8c:	95d2                	add	a1,a1,s4
    80002b8e:	854e                	mv	a0,s3
    80002b90:	ffffe097          	auipc	ra,0xffffe
    80002b94:	ac6080e7          	jalr	-1338(ra) # 80000656 <printf>
  for (i = 0; i <= historyBufferArray.lastCommandIndex; i++)
    80002b98:	2485                	addiw	s1,s1,1
    80002b9a:	84092783          	lw	a5,-1984(s2)
    80002b9e:	fe97f3e3          	bgeu	a5,s1,80002b84 <history+0x2e>
  }
  if (historyBufferArray.numOfCommandsInMem <= historyId)
    80002ba2:	0000e797          	auipc	a5,0xe
    80002ba6:	7fa7a783          	lw	a5,2042(a5) # 8001139c <historyBufferArray+0x844>
    80002baa:	02fada63          	bge	s5,a5,80002bde <history+0x88>
  {
    printf("Invalid HistoryId\n");
    return 1;
  }
  printf("Requested command: %s", historyBufferArray.bufferArr[historyId]);
    80002bae:	0a9e                	slli	s5,s5,0x7
    80002bb0:	0000e597          	auipc	a1,0xe
    80002bb4:	fa858593          	addi	a1,a1,-88 # 80010b58 <historyBufferArray>
    80002bb8:	95d6                	add	a1,a1,s5
    80002bba:	00005517          	auipc	a0,0x5
    80002bbe:	70e50513          	addi	a0,a0,1806 # 800082c8 <digits+0x280>
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	a94080e7          	jalr	-1388(ra) # 80000656 <printf>
  return 0;
    80002bca:	4501                	li	a0,0
}
    80002bcc:	70e2                	ld	ra,56(sp)
    80002bce:	7442                	ld	s0,48(sp)
    80002bd0:	74a2                	ld	s1,40(sp)
    80002bd2:	7902                	ld	s2,32(sp)
    80002bd4:	69e2                	ld	s3,24(sp)
    80002bd6:	6a42                	ld	s4,16(sp)
    80002bd8:	6aa2                	ld	s5,8(sp)
    80002bda:	6121                	addi	sp,sp,64
    80002bdc:	8082                	ret
    printf("Invalid HistoryId\n");
    80002bde:	00005517          	auipc	a0,0x5
    80002be2:	6d250513          	addi	a0,a0,1746 # 800082b0 <digits+0x268>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	a70080e7          	jalr	-1424(ra) # 80000656 <printf>
    return 1;
    80002bee:	4505                	li	a0,1
    80002bf0:	bff1                	j	80002bcc <history+0x76>

0000000080002bf2 <top>:

int top(struct top *inputTop)
{
    80002bf2:	7159                	addi	sp,sp,-112
    80002bf4:	f486                	sd	ra,104(sp)
    80002bf6:	f0a2                	sd	s0,96(sp)
    80002bf8:	eca6                	sd	s1,88(sp)
    80002bfa:	e8ca                	sd	s2,80(sp)
    80002bfc:	e4ce                	sd	s3,72(sp)
    80002bfe:	e0d2                	sd	s4,64(sp)
    80002c00:	fc56                	sd	s5,56(sp)
    80002c02:	f85a                	sd	s6,48(sp)
    80002c04:	f45e                	sd	s7,40(sp)
    80002c06:	f062                	sd	s8,32(sp)
    80002c08:	ec66                	sd	s9,24(sp)
    80002c0a:	e86a                	sd	s10,16(sp)
    80002c0c:	e46e                	sd	s11,8(sp)
    80002c0e:	1880                	addi	s0,sp,112
    80002c10:	8aaa                	mv	s5,a0
  struct proc *p;
  uint64 total = 0, runningProcess = 0, sleepingProcess = 0;
  for (p = proc; p < &proc[NPROC]; p++)
    80002c12:	0002f997          	auipc	s3,0x2f
    80002c16:	dae98993          	addi	s3,s3,-594 # 800319c0 <proc+0x158>
    80002c1a:	00035b17          	auipc	s6,0x35
    80002c1e:	1a6b0b13          	addi	s6,s6,422 # 80037dc0 <bcache+0x140>
  uint64 total = 0, runningProcess = 0, sleepingProcess = 0;
    80002c22:	4b81                	li	s7,0
    80002c24:	4c81                	li	s9,0
    80002c26:	4a01                	li	s4,0
    inputTop->p_list[total].state = p->state;
    inputTop->p_list[total].time = p->start_ticks;
    inputTop->p_list[total].timeElapsed = p->elapsed;
    total++;
    inputTop->p_list[total].size=p->sz;
    if (p->state == RUNNING)
    80002c28:	4c15                	li	s8,5
    {
      runningProcess++;
    }
    if (p->state == SLEEPING)
    80002c2a:	4d0d                	li	s10,3
    80002c2c:	a031                	j	80002c38 <top+0x46>
      runningProcess++;
    80002c2e:	0c85                	addi	s9,s9,1
  for (p = proc; p < &proc[NPROC]; p++)
    80002c30:	19098993          	addi	s3,s3,400
    80002c34:	09698563          	beq	s3,s6,80002cbe <top+0xcc>
    if (strlen(p->name) == 0)
    80002c38:	894e                	mv	s2,s3
    80002c3a:	854e                	mv	a0,s3
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	470080e7          	jalr	1136(ra) # 800010ac <strlen>
    80002c44:	d575                	beqz	a0,80002c30 <top+0x3e>
    if (p->parent)
    80002c46:	ee09b783          	ld	a5,-288(s3)
    80002c4a:	cb81                	beqz	a5,80002c5a <top+0x68>
      inputTop->p_list[total].ppid = p->parent->pid;
    80002c4c:	5b98                	lw	a4,48(a5)
    80002c4e:	001a1793          	slli	a5,s4,0x1
    80002c52:	97d2                	add	a5,a5,s4
    80002c54:	0792                	slli	a5,a5,0x4
    80002c56:	97d6                	add	a5,a5,s5
    80002c58:	d7d8                	sw	a4,44(a5)
    inputTop->p_list[total].pid = p->pid;
    80002c5a:	ed892703          	lw	a4,-296(s2)
    80002c5e:	001a1793          	slli	a5,s4,0x1
    80002c62:	014784b3          	add	s1,a5,s4
    80002c66:	0492                	slli	s1,s1,0x4
    80002c68:	94d6                	add	s1,s1,s5
    80002c6a:	d498                	sw	a4,40(s1)
    strncpy(inputTop->p_list[total].name, p->name, strlen(p->name) + 1);
    80002c6c:	01478db3          	add	s11,a5,s4
    80002c70:	0d92                	slli	s11,s11,0x4
    80002c72:	0de1                	addi	s11,s11,24
    80002c74:	9dd6                	add	s11,s11,s5
    80002c76:	854a                	mv	a0,s2
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	434080e7          	jalr	1076(ra) # 800010ac <strlen>
    80002c80:	0015061b          	addiw	a2,a0,1
    80002c84:	85ca                	mv	a1,s2
    80002c86:	856e                	mv	a0,s11
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	3b4080e7          	jalr	948(ra) # 8000103c <strncpy>
    inputTop->p_list[total].state = p->state;
    80002c90:	ec092783          	lw	a5,-320(s2)
    80002c94:	dc9c                	sw	a5,56(s1)
    inputTop->p_list[total].time = p->start_ticks;
    80002c96:	01092783          	lw	a5,16(s2)
    80002c9a:	d89c                	sw	a5,48(s1)
    inputTop->p_list[total].timeElapsed = p->elapsed;
    80002c9c:	01492783          	lw	a5,20(s2)
    80002ca0:	d8dc                	sw	a5,52(s1)
    total++;
    80002ca2:	0a05                	addi	s4,s4,1
    inputTop->p_list[total].size=p->sz;
    80002ca4:	ef093783          	ld	a5,-272(s2)
    80002ca8:	f8bc                	sd	a5,112(s1)
    if (p->state == RUNNING)
    80002caa:	ec092783          	lw	a5,-320(s2)
    80002cae:	f98780e3          	beq	a5,s8,80002c2e <top+0x3c>
    {
      sleepingProcess++;
    80002cb2:	41a787b3          	sub	a5,a5,s10
    80002cb6:	0017b793          	seqz	a5,a5
    80002cba:	9bbe                	add	s7,s7,a5
    80002cbc:	bf95                	j	80002c30 <top+0x3e>
    }
  }
  inputTop->total_mem= PHYSTOP-KERNBASE;
    80002cbe:	6485                	lui	s1,0x1
    80002cc0:	94d6                	add	s1,s1,s5
    80002cc2:	080007b7          	lui	a5,0x8000
    80002cc6:	c0f4bc23          	sd	a5,-1000(s1) # c18 <_entry-0x7ffff3e8>
  inputTop->free_mem=free_memory();
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	0aa080e7          	jalr	170(ra) # 80000d74 <free_memory>
    80002cd2:	c2a4b023          	sd	a0,-992(s1)
  inputTop->running_process = runningProcess;
    80002cd6:	019aa623          	sw	s9,12(s5)
  inputTop->sleeping_process = sleepingProcess;
    80002cda:	017aa823          	sw	s7,16(s5)
  inputTop->total_process = total;
    80002cde:	014aa423          	sw	s4,8(s5)
  inputTop->uptime = ticks;
    80002ce2:	00006797          	auipc	a5,0x6
    80002ce6:	c7e7e783          	lwu	a5,-898(a5) # 80008960 <ticks>
    80002cea:	00fab023          	sd	a5,0(s5)
  return 0;
}
    80002cee:	4501                	li	a0,0
    80002cf0:	70a6                	ld	ra,104(sp)
    80002cf2:	7406                	ld	s0,96(sp)
    80002cf4:	64e6                	ld	s1,88(sp)
    80002cf6:	6946                	ld	s2,80(sp)
    80002cf8:	69a6                	ld	s3,72(sp)
    80002cfa:	6a06                	ld	s4,64(sp)
    80002cfc:	7ae2                	ld	s5,56(sp)
    80002cfe:	7b42                	ld	s6,48(sp)
    80002d00:	7ba2                	ld	s7,40(sp)
    80002d02:	7c02                	ld	s8,32(sp)
    80002d04:	6ce2                	ld	s9,24(sp)
    80002d06:	6d42                	ld	s10,16(sp)
    80002d08:	6da2                	ld	s11,8(sp)
    80002d0a:	6165                	addi	sp,sp,112
    80002d0c:	8082                	ret

0000000080002d0e <swtch>:
    80002d0e:	00153023          	sd	ra,0(a0)
    80002d12:	00253423          	sd	sp,8(a0)
    80002d16:	e900                	sd	s0,16(a0)
    80002d18:	ed04                	sd	s1,24(a0)
    80002d1a:	03253023          	sd	s2,32(a0)
    80002d1e:	03353423          	sd	s3,40(a0)
    80002d22:	03453823          	sd	s4,48(a0)
    80002d26:	03553c23          	sd	s5,56(a0)
    80002d2a:	05653023          	sd	s6,64(a0)
    80002d2e:	05753423          	sd	s7,72(a0)
    80002d32:	05853823          	sd	s8,80(a0)
    80002d36:	05953c23          	sd	s9,88(a0)
    80002d3a:	07a53023          	sd	s10,96(a0)
    80002d3e:	07b53423          	sd	s11,104(a0)
    80002d42:	0005b083          	ld	ra,0(a1)
    80002d46:	0085b103          	ld	sp,8(a1)
    80002d4a:	6980                	ld	s0,16(a1)
    80002d4c:	6d84                	ld	s1,24(a1)
    80002d4e:	0205b903          	ld	s2,32(a1)
    80002d52:	0285b983          	ld	s3,40(a1)
    80002d56:	0305ba03          	ld	s4,48(a1)
    80002d5a:	0385ba83          	ld	s5,56(a1)
    80002d5e:	0405bb03          	ld	s6,64(a1)
    80002d62:	0485bb83          	ld	s7,72(a1)
    80002d66:	0505bc03          	ld	s8,80(a1)
    80002d6a:	0585bc83          	ld	s9,88(a1)
    80002d6e:	0605bd03          	ld	s10,96(a1)
    80002d72:	0685bd83          	ld	s11,104(a1)
    80002d76:	8082                	ret

0000000080002d78 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002d78:	1141                	addi	sp,sp,-16
    80002d7a:	e406                	sd	ra,8(sp)
    80002d7c:	e022                	sd	s0,0(sp)
    80002d7e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002d80:	00005597          	auipc	a1,0x5
    80002d84:	5c858593          	addi	a1,a1,1480 # 80008348 <states.0+0x38>
    80002d88:	00035517          	auipc	a0,0x35
    80002d8c:	ee050513          	addi	a0,a0,-288 # 80037c68 <tickslock>
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	014080e7          	jalr	20(ra) # 80000da4 <initlock>
}
    80002d98:	60a2                	ld	ra,8(sp)
    80002d9a:	6402                	ld	s0,0(sp)
    80002d9c:	0141                	addi	sp,sp,16
    80002d9e:	8082                	ret

0000000080002da0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002da0:	1141                	addi	sp,sp,-16
    80002da2:	e422                	sd	s0,8(sp)
    80002da4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002da6:	00003797          	auipc	a5,0x3
    80002daa:	67a78793          	addi	a5,a5,1658 # 80006420 <kernelvec>
    80002dae:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002db2:	6422                	ld	s0,8(sp)
    80002db4:	0141                	addi	sp,sp,16
    80002db6:	8082                	ret

0000000080002db8 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002db8:	1141                	addi	sp,sp,-16
    80002dba:	e406                	sd	ra,8(sp)
    80002dbc:	e022                	sd	s0,0(sp)
    80002dbe:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	e50080e7          	jalr	-432(ra) # 80001c10 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002dcc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dce:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002dd2:	00004617          	auipc	a2,0x4
    80002dd6:	22e60613          	addi	a2,a2,558 # 80007000 <_trampoline>
    80002dda:	00004697          	auipc	a3,0x4
    80002dde:	22668693          	addi	a3,a3,550 # 80007000 <_trampoline>
    80002de2:	8e91                	sub	a3,a3,a2
    80002de4:	040007b7          	lui	a5,0x4000
    80002de8:	17fd                	addi	a5,a5,-1
    80002dea:	07b2                	slli	a5,a5,0xc
    80002dec:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002dee:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002df2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002df4:	180026f3          	csrr	a3,satp
    80002df8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002dfa:	6d38                	ld	a4,88(a0)
    80002dfc:	6134                	ld	a3,64(a0)
    80002dfe:	6585                	lui	a1,0x1
    80002e00:	96ae                	add	a3,a3,a1
    80002e02:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002e04:	6d38                	ld	a4,88(a0)
    80002e06:	00000697          	auipc	a3,0x0
    80002e0a:	15668693          	addi	a3,a3,342 # 80002f5c <usertrap>
    80002e0e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002e10:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e12:	8692                	mv	a3,tp
    80002e14:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e16:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e1a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e1e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e22:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002e26:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e28:	6f18                	ld	a4,24(a4)
    80002e2a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e2e:	6928                	ld	a0,80(a0)
    80002e30:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002e32:	00004717          	auipc	a4,0x4
    80002e36:	26a70713          	addi	a4,a4,618 # 8000709c <userret>
    80002e3a:	8f11                	sub	a4,a4,a2
    80002e3c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002e3e:	577d                	li	a4,-1
    80002e40:	177e                	slli	a4,a4,0x3f
    80002e42:	8d59                	or	a0,a0,a4
    80002e44:	9782                	jalr	a5
}
    80002e46:	60a2                	ld	ra,8(sp)
    80002e48:	6402                	ld	s0,0(sp)
    80002e4a:	0141                	addi	sp,sp,16
    80002e4c:	8082                	ret

0000000080002e4e <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002e4e:	1141                	addi	sp,sp,-16
    80002e50:	e406                	sd	ra,8(sp)
    80002e52:	e022                	sd	s0,0(sp)
    80002e54:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002e56:	00035517          	auipc	a0,0x35
    80002e5a:	e1250513          	addi	a0,a0,-494 # 80037c68 <tickslock>
    80002e5e:	ffffe097          	auipc	ra,0xffffe
    80002e62:	fd6080e7          	jalr	-42(ra) # 80000e34 <acquire>

  struct proc *p = myproc();
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	daa080e7          	jalr	-598(ra) # 80001c10 <myproc>
  if (p)
    80002e6e:	cd19                	beqz	a0,80002e8c <clockintr+0x3e>
  {
    p->ticks[p->priority]++;
    80002e70:	18c52783          	lw	a5,396(a0)
    80002e74:	078a                	slli	a5,a5,0x2
    80002e76:	97aa                	add	a5,a5,a0
    80002e78:	1787a703          	lw	a4,376(a5) # 4000178 <_entry-0x7bfffe88>
    80002e7c:	2705                	addiw	a4,a4,1
    80002e7e:	16e7ac23          	sw	a4,376(a5)
    p->elapsed++;
    80002e82:	16c52783          	lw	a5,364(a0)
    80002e86:	2785                	addiw	a5,a5,1
    80002e88:	16f52623          	sw	a5,364(a0)
  }
  ticks++;
    80002e8c:	00006517          	auipc	a0,0x6
    80002e90:	ad450513          	addi	a0,a0,-1324 # 80008960 <ticks>
    80002e94:	411c                	lw	a5,0(a0)
    80002e96:	2785                	addiw	a5,a5,1
    80002e98:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	7b6080e7          	jalr	1974(ra) # 80002650 <wakeup>
  release(&tickslock);
    80002ea2:	00035517          	auipc	a0,0x35
    80002ea6:	dc650513          	addi	a0,a0,-570 # 80037c68 <tickslock>
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	03e080e7          	jalr	62(ra) # 80000ee8 <release>
}
    80002eb2:	60a2                	ld	ra,8(sp)
    80002eb4:	6402                	ld	s0,0(sp)
    80002eb6:	0141                	addi	sp,sp,16
    80002eb8:	8082                	ret

0000000080002eba <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002eba:	1101                	addi	sp,sp,-32
    80002ebc:	ec06                	sd	ra,24(sp)
    80002ebe:	e822                	sd	s0,16(sp)
    80002ec0:	e426                	sd	s1,8(sp)
    80002ec2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ec4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002ec8:	00074d63          	bltz	a4,80002ee2 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002ecc:	57fd                	li	a5,-1
    80002ece:	17fe                	slli	a5,a5,0x3f
    80002ed0:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002ed2:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002ed4:	06f70363          	beq	a4,a5,80002f3a <devintr+0x80>
  }
}
    80002ed8:	60e2                	ld	ra,24(sp)
    80002eda:	6442                	ld	s0,16(sp)
    80002edc:	64a2                	ld	s1,8(sp)
    80002ede:	6105                	addi	sp,sp,32
    80002ee0:	8082                	ret
      (scause & 0xff) == 9)
    80002ee2:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002ee6:	46a5                	li	a3,9
    80002ee8:	fed792e3          	bne	a5,a3,80002ecc <devintr+0x12>
    int irq = plic_claim();
    80002eec:	00003097          	auipc	ra,0x3
    80002ef0:	63c080e7          	jalr	1596(ra) # 80006528 <plic_claim>
    80002ef4:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002ef6:	47a9                	li	a5,10
    80002ef8:	02f50763          	beq	a0,a5,80002f26 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002efc:	4785                	li	a5,1
    80002efe:	02f50963          	beq	a0,a5,80002f30 <devintr+0x76>
    return 1;
    80002f02:	4505                	li	a0,1
    else if (irq)
    80002f04:	d8f1                	beqz	s1,80002ed8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002f06:	85a6                	mv	a1,s1
    80002f08:	00005517          	auipc	a0,0x5
    80002f0c:	44850513          	addi	a0,a0,1096 # 80008350 <states.0+0x40>
    80002f10:	ffffd097          	auipc	ra,0xffffd
    80002f14:	746080e7          	jalr	1862(ra) # 80000656 <printf>
      plic_complete(irq);
    80002f18:	8526                	mv	a0,s1
    80002f1a:	00003097          	auipc	ra,0x3
    80002f1e:	632080e7          	jalr	1586(ra) # 8000654c <plic_complete>
    return 1;
    80002f22:	4505                	li	a0,1
    80002f24:	bf55                	j	80002ed8 <devintr+0x1e>
      uartintr();
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	b42080e7          	jalr	-1214(ra) # 80000a68 <uartintr>
    80002f2e:	b7ed                	j	80002f18 <devintr+0x5e>
      virtio_disk_intr();
    80002f30:	00004097          	auipc	ra,0x4
    80002f34:	ae8080e7          	jalr	-1304(ra) # 80006a18 <virtio_disk_intr>
    80002f38:	b7c5                	j	80002f18 <devintr+0x5e>
    if (cpuid() == 0)
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	caa080e7          	jalr	-854(ra) # 80001be4 <cpuid>
    80002f42:	c901                	beqz	a0,80002f52 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f44:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f48:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f4a:	14479073          	csrw	sip,a5
    return 2;
    80002f4e:	4509                	li	a0,2
    80002f50:	b761                	j	80002ed8 <devintr+0x1e>
      clockintr();
    80002f52:	00000097          	auipc	ra,0x0
    80002f56:	efc080e7          	jalr	-260(ra) # 80002e4e <clockintr>
    80002f5a:	b7ed                	j	80002f44 <devintr+0x8a>

0000000080002f5c <usertrap>:
{
    80002f5c:	7179                	addi	sp,sp,-48
    80002f5e:	f406                	sd	ra,40(sp)
    80002f60:	f022                	sd	s0,32(sp)
    80002f62:	ec26                	sd	s1,24(sp)
    80002f64:	e84a                	sd	s2,16(sp)
    80002f66:	e44e                	sd	s3,8(sp)
    80002f68:	e052                	sd	s4,0(sp)
    80002f6a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f6c:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002f70:	1007f793          	andi	a5,a5,256
    80002f74:	eba9                	bnez	a5,80002fc6 <usertrap+0x6a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f76:	00003797          	auipc	a5,0x3
    80002f7a:	4aa78793          	addi	a5,a5,1194 # 80006420 <kernelvec>
    80002f7e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002f82:	fffff097          	auipc	ra,0xfffff
    80002f86:	c8e080e7          	jalr	-882(ra) # 80001c10 <myproc>
    80002f8a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002f8c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f8e:	14102773          	csrr	a4,sepc
    80002f92:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f94:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002f98:	47a1                	li	a5,8
    80002f9a:	02f70e63          	beq	a4,a5,80002fd6 <usertrap+0x7a>
    80002f9e:	14202773          	csrr	a4,scause
  else if (r_scause() == 15) // Page fault
    80002fa2:	47bd                	li	a5,15
    80002fa4:	08f70563          	beq	a4,a5,8000302e <usertrap+0xd2>
  else if ((which_dev = devintr()) != 0)
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	f12080e7          	jalr	-238(ra) # 80002eba <devintr>
    80002fb0:	892a                	mv	s2,a0
    80002fb2:	10050f63          	beqz	a0,800030d0 <usertrap+0x174>
  if (killed(p))
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	8dc080e7          	jalr	-1828(ra) # 80002894 <killed>
    80002fc0:	16050463          	beqz	a0,80003128 <usertrap+0x1cc>
    80002fc4:	aaa9                	j	8000311e <usertrap+0x1c2>
    panic("usertrap: not from user mode");
    80002fc6:	00005517          	auipc	a0,0x5
    80002fca:	3aa50513          	addi	a0,a0,938 # 80008370 <states.0+0x60>
    80002fce:	ffffd097          	auipc	ra,0xffffd
    80002fd2:	63e080e7          	jalr	1598(ra) # 8000060c <panic>
    if (killed(p))
    80002fd6:	00000097          	auipc	ra,0x0
    80002fda:	8be080e7          	jalr	-1858(ra) # 80002894 <killed>
    80002fde:	e131                	bnez	a0,80003022 <usertrap+0xc6>
    p->trapframe->epc += 4;
    80002fe0:	6cb8                	ld	a4,88(s1)
    80002fe2:	6f1c                	ld	a5,24(a4)
    80002fe4:	0791                	addi	a5,a5,4
    80002fe6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fe8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002fec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ff0:	10079073          	csrw	sstatus,a5
    syscall();
    80002ff4:	00000097          	auipc	ra,0x0
    80002ff8:	38e080e7          	jalr	910(ra) # 80003382 <syscall>
  if (killed(p))
    80002ffc:	8526                	mv	a0,s1
    80002ffe:	00000097          	auipc	ra,0x0
    80003002:	896080e7          	jalr	-1898(ra) # 80002894 <killed>
    80003006:	10051b63          	bnez	a0,8000311c <usertrap+0x1c0>
  usertrapret();
    8000300a:	00000097          	auipc	ra,0x0
    8000300e:	dae080e7          	jalr	-594(ra) # 80002db8 <usertrapret>
}
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6942                	ld	s2,16(sp)
    8000301a:	69a2                	ld	s3,8(sp)
    8000301c:	6a02                	ld	s4,0(sp)
    8000301e:	6145                	addi	sp,sp,48
    80003020:	8082                	ret
      exit(-1);
    80003022:	557d                	li	a0,-1
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	6fc080e7          	jalr	1788(ra) # 80002720 <exit>
    8000302c:	bf55                	j	80002fe0 <usertrap+0x84>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000302e:	14302a73          	csrr	s4,stval
    pte_t *pte = walk(p->pagetable, va, 0);
    80003032:	4601                	li	a2,0
    80003034:	85d2                	mv	a1,s4
    80003036:	6928                	ld	a0,80(a0)
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	1dc080e7          	jalr	476(ra) # 80001214 <walk>
    80003040:	892a                	mv	s2,a0
    if (pte && (*pte & PTE_COW)) {
    80003042:	c511                	beqz	a0,8000304e <usertrap+0xf2>
    80003044:	00053983          	ld	s3,0(a0)
    80003048:	2009f793          	andi	a5,s3,512
    8000304c:	ef8d                	bnez	a5,80003086 <usertrap+0x12a>
      printf("usertrap(): unexpected page fault at %p pid=%d\n", va, p->pid);
    8000304e:	5890                	lw	a2,48(s1)
    80003050:	85d2                	mv	a1,s4
    80003052:	00005517          	auipc	a0,0x5
    80003056:	33e50513          	addi	a0,a0,830 # 80008390 <states.0+0x80>
    8000305a:	ffffd097          	auipc	ra,0xffffd
    8000305e:	5fc080e7          	jalr	1532(ra) # 80000656 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003062:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003066:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000306a:	00005517          	auipc	a0,0x5
    8000306e:	35650513          	addi	a0,a0,854 # 800083c0 <states.0+0xb0>
    80003072:	ffffd097          	auipc	ra,0xffffd
    80003076:	5e4080e7          	jalr	1508(ra) # 80000656 <printf>
      setkilled(p);
    8000307a:	8526                	mv	a0,s1
    8000307c:	fffff097          	auipc	ra,0xfffff
    80003080:	7ec080e7          	jalr	2028(ra) # 80002868 <setkilled>
    80003084:	bfa5                	j	80002ffc <usertrap+0xa0>
      char *mem = kalloc();
    80003086:	ffffe097          	auipc	ra,0xffffe
    8000308a:	a82080e7          	jalr	-1406(ra) # 80000b08 <kalloc>
    8000308e:	8a2a                	mv	s4,a0
      if (mem == 0) {
    80003090:	cd0d                	beqz	a0,800030ca <usertrap+0x16e>
      uint64 pa = PTE2PA(*pte);
    80003092:	00a9d993          	srli	s3,s3,0xa
    80003096:	09b2                	slli	s3,s3,0xc
      memmove(mem, (char*)pa, PGSIZE);
    80003098:	6605                	lui	a2,0x1
    8000309a:	85ce                	mv	a1,s3
    8000309c:	ffffe097          	auipc	ra,0xffffe
    800030a0:	ef0080e7          	jalr	-272(ra) # 80000f8c <memmove>
      *pte = PA2PTE(mem) | PTE_FLAGS(*pte) | PTE_W;
    800030a4:	00ca5a13          	srli	s4,s4,0xc
    800030a8:	0a2a                	slli	s4,s4,0xa
    800030aa:	00093783          	ld	a5,0(s2)
    800030ae:	1ff7f793          	andi	a5,a5,511
      *pte &= ~PTE_COW; // Clear the COW flag
    800030b2:	0147ea33          	or	s4,a5,s4
    800030b6:	004a6a13          	ori	s4,s4,4
    800030ba:	01493023          	sd	s4,0(s2)
      kfree((void*)pa);
    800030be:	854e                	mv	a0,s3
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	b0e080e7          	jalr	-1266(ra) # 80000bce <kfree>
    if (pte && (*pte & PTE_COW)) {
    800030c8:	bf15                	j	80002ffc <usertrap+0xa0>
        p->killed = 1;
    800030ca:	4785                	li	a5,1
    800030cc:	d49c                	sw	a5,40(s1)
        return;
    800030ce:	b791                	j	80003012 <usertrap+0xb6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030d0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800030d4:	5890                	lw	a2,48(s1)
    800030d6:	00005517          	auipc	a0,0x5
    800030da:	30a50513          	addi	a0,a0,778 # 800083e0 <states.0+0xd0>
    800030de:	ffffd097          	auipc	ra,0xffffd
    800030e2:	578080e7          	jalr	1400(ra) # 80000656 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030e6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030ea:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030ee:	00005517          	auipc	a0,0x5
    800030f2:	2d250513          	addi	a0,a0,722 # 800083c0 <states.0+0xb0>
    800030f6:	ffffd097          	auipc	ra,0xffffd
    800030fa:	560080e7          	jalr	1376(ra) # 80000656 <printf>
    printf("which_dev= %d",which_dev);
    800030fe:	4581                	li	a1,0
    80003100:	00005517          	auipc	a0,0x5
    80003104:	31050513          	addi	a0,a0,784 # 80008410 <states.0+0x100>
    80003108:	ffffd097          	auipc	ra,0xffffd
    8000310c:	54e080e7          	jalr	1358(ra) # 80000656 <printf>
    setkilled(p);
    80003110:	8526                	mv	a0,s1
    80003112:	fffff097          	auipc	ra,0xfffff
    80003116:	756080e7          	jalr	1878(ra) # 80002868 <setkilled>
    8000311a:	b5cd                	j	80002ffc <usertrap+0xa0>
  if (killed(p))
    8000311c:	4901                	li	s2,0
    exit(-1);
    8000311e:	557d                	li	a0,-1
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	600080e7          	jalr	1536(ra) # 80002720 <exit>
  if (which_dev == 2)
    80003128:	4789                	li	a5,2
    8000312a:	eef910e3          	bne	s2,a5,8000300a <usertrap+0xae>
    yield();
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	482080e7          	jalr	1154(ra) # 800025b0 <yield>
    80003136:	bdd1                	j	8000300a <usertrap+0xae>

0000000080003138 <kerneltrap>:
{
    80003138:	7179                	addi	sp,sp,-48
    8000313a:	f406                	sd	ra,40(sp)
    8000313c:	f022                	sd	s0,32(sp)
    8000313e:	ec26                	sd	s1,24(sp)
    80003140:	e84a                	sd	s2,16(sp)
    80003142:	e44e                	sd	s3,8(sp)
    80003144:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003146:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000314a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000314e:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80003152:	1004f793          	andi	a5,s1,256
    80003156:	cb85                	beqz	a5,80003186 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003158:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000315c:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000315e:	ef85                	bnez	a5,80003196 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003160:	00000097          	auipc	ra,0x0
    80003164:	d5a080e7          	jalr	-678(ra) # 80002eba <devintr>
    80003168:	cd1d                	beqz	a0,800031a6 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000316a:	4789                	li	a5,2
    8000316c:	06f50a63          	beq	a0,a5,800031e0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003170:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003174:	10049073          	csrw	sstatus,s1
}
    80003178:	70a2                	ld	ra,40(sp)
    8000317a:	7402                	ld	s0,32(sp)
    8000317c:	64e2                	ld	s1,24(sp)
    8000317e:	6942                	ld	s2,16(sp)
    80003180:	69a2                	ld	s3,8(sp)
    80003182:	6145                	addi	sp,sp,48
    80003184:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	29a50513          	addi	a0,a0,666 # 80008420 <states.0+0x110>
    8000318e:	ffffd097          	auipc	ra,0xffffd
    80003192:	47e080e7          	jalr	1150(ra) # 8000060c <panic>
    panic("kerneltrap: interrupts enabled");
    80003196:	00005517          	auipc	a0,0x5
    8000319a:	2b250513          	addi	a0,a0,690 # 80008448 <states.0+0x138>
    8000319e:	ffffd097          	auipc	ra,0xffffd
    800031a2:	46e080e7          	jalr	1134(ra) # 8000060c <panic>
    printf("scause %p\n", scause);
    800031a6:	85ce                	mv	a1,s3
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	2c050513          	addi	a0,a0,704 # 80008468 <states.0+0x158>
    800031b0:	ffffd097          	auipc	ra,0xffffd
    800031b4:	4a6080e7          	jalr	1190(ra) # 80000656 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031b8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800031bc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031c0:	00005517          	auipc	a0,0x5
    800031c4:	2b850513          	addi	a0,a0,696 # 80008478 <states.0+0x168>
    800031c8:	ffffd097          	auipc	ra,0xffffd
    800031cc:	48e080e7          	jalr	1166(ra) # 80000656 <printf>
    panic("kerneltrap");
    800031d0:	00005517          	auipc	a0,0x5
    800031d4:	2c050513          	addi	a0,a0,704 # 80008490 <states.0+0x180>
    800031d8:	ffffd097          	auipc	ra,0xffffd
    800031dc:	434080e7          	jalr	1076(ra) # 8000060c <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800031e0:	fffff097          	auipc	ra,0xfffff
    800031e4:	a30080e7          	jalr	-1488(ra) # 80001c10 <myproc>
    800031e8:	d541                	beqz	a0,80003170 <kerneltrap+0x38>
    800031ea:	fffff097          	auipc	ra,0xfffff
    800031ee:	a26080e7          	jalr	-1498(ra) # 80001c10 <myproc>
    800031f2:	4d18                	lw	a4,24(a0)
    800031f4:	4795                	li	a5,5
    800031f6:	f6f71de3          	bne	a4,a5,80003170 <kerneltrap+0x38>
    yield();
    800031fa:	fffff097          	auipc	ra,0xfffff
    800031fe:	3b6080e7          	jalr	950(ra) # 800025b0 <yield>
    80003202:	b7bd                	j	80003170 <kerneltrap+0x38>

0000000080003204 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003204:	1101                	addi	sp,sp,-32
    80003206:	ec06                	sd	ra,24(sp)
    80003208:	e822                	sd	s0,16(sp)
    8000320a:	e426                	sd	s1,8(sp)
    8000320c:	1000                	addi	s0,sp,32
    8000320e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003210:	fffff097          	auipc	ra,0xfffff
    80003214:	a00080e7          	jalr	-1536(ra) # 80001c10 <myproc>
  switch (n)
    80003218:	4795                	li	a5,5
    8000321a:	0497e163          	bltu	a5,s1,8000325c <argraw+0x58>
    8000321e:	048a                	slli	s1,s1,0x2
    80003220:	00005717          	auipc	a4,0x5
    80003224:	2a870713          	addi	a4,a4,680 # 800084c8 <states.0+0x1b8>
    80003228:	94ba                	add	s1,s1,a4
    8000322a:	409c                	lw	a5,0(s1)
    8000322c:	97ba                	add	a5,a5,a4
    8000322e:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80003230:	6d3c                	ld	a5,88(a0)
    80003232:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	64a2                	ld	s1,8(sp)
    8000323a:	6105                	addi	sp,sp,32
    8000323c:	8082                	ret
    return p->trapframe->a1;
    8000323e:	6d3c                	ld	a5,88(a0)
    80003240:	7fa8                	ld	a0,120(a5)
    80003242:	bfcd                	j	80003234 <argraw+0x30>
    return p->trapframe->a2;
    80003244:	6d3c                	ld	a5,88(a0)
    80003246:	63c8                	ld	a0,128(a5)
    80003248:	b7f5                	j	80003234 <argraw+0x30>
    return p->trapframe->a3;
    8000324a:	6d3c                	ld	a5,88(a0)
    8000324c:	67c8                	ld	a0,136(a5)
    8000324e:	b7dd                	j	80003234 <argraw+0x30>
    return p->trapframe->a4;
    80003250:	6d3c                	ld	a5,88(a0)
    80003252:	6bc8                	ld	a0,144(a5)
    80003254:	b7c5                	j	80003234 <argraw+0x30>
    return p->trapframe->a5;
    80003256:	6d3c                	ld	a5,88(a0)
    80003258:	6fc8                	ld	a0,152(a5)
    8000325a:	bfe9                	j	80003234 <argraw+0x30>
  panic("argraw");
    8000325c:	00005517          	auipc	a0,0x5
    80003260:	24450513          	addi	a0,a0,580 # 800084a0 <states.0+0x190>
    80003264:	ffffd097          	auipc	ra,0xffffd
    80003268:	3a8080e7          	jalr	936(ra) # 8000060c <panic>

000000008000326c <fetchaddr>:
{
    8000326c:	1101                	addi	sp,sp,-32
    8000326e:	ec06                	sd	ra,24(sp)
    80003270:	e822                	sd	s0,16(sp)
    80003272:	e426                	sd	s1,8(sp)
    80003274:	e04a                	sd	s2,0(sp)
    80003276:	1000                	addi	s0,sp,32
    80003278:	84aa                	mv	s1,a0
    8000327a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000327c:	fffff097          	auipc	ra,0xfffff
    80003280:	994080e7          	jalr	-1644(ra) # 80001c10 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003284:	653c                	ld	a5,72(a0)
    80003286:	02f4f863          	bgeu	s1,a5,800032b6 <fetchaddr+0x4a>
    8000328a:	00848713          	addi	a4,s1,8
    8000328e:	02e7e663          	bltu	a5,a4,800032ba <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003292:	46a1                	li	a3,8
    80003294:	8626                	mv	a2,s1
    80003296:	85ca                	mv	a1,s2
    80003298:	6928                	ld	a0,80(a0)
    8000329a:	ffffe097          	auipc	ra,0xffffe
    8000329e:	6b8080e7          	jalr	1720(ra) # 80001952 <copyin>
    800032a2:	00a03533          	snez	a0,a0
    800032a6:	40a00533          	neg	a0,a0
}
    800032aa:	60e2                	ld	ra,24(sp)
    800032ac:	6442                	ld	s0,16(sp)
    800032ae:	64a2                	ld	s1,8(sp)
    800032b0:	6902                	ld	s2,0(sp)
    800032b2:	6105                	addi	sp,sp,32
    800032b4:	8082                	ret
    return -1;
    800032b6:	557d                	li	a0,-1
    800032b8:	bfcd                	j	800032aa <fetchaddr+0x3e>
    800032ba:	557d                	li	a0,-1
    800032bc:	b7fd                	j	800032aa <fetchaddr+0x3e>

00000000800032be <fetchstr>:
{
    800032be:	7179                	addi	sp,sp,-48
    800032c0:	f406                	sd	ra,40(sp)
    800032c2:	f022                	sd	s0,32(sp)
    800032c4:	ec26                	sd	s1,24(sp)
    800032c6:	e84a                	sd	s2,16(sp)
    800032c8:	e44e                	sd	s3,8(sp)
    800032ca:	1800                	addi	s0,sp,48
    800032cc:	892a                	mv	s2,a0
    800032ce:	84ae                	mv	s1,a1
    800032d0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800032d2:	fffff097          	auipc	ra,0xfffff
    800032d6:	93e080e7          	jalr	-1730(ra) # 80001c10 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800032da:	86ce                	mv	a3,s3
    800032dc:	864a                	mv	a2,s2
    800032de:	85a6                	mv	a1,s1
    800032e0:	6928                	ld	a0,80(a0)
    800032e2:	ffffe097          	auipc	ra,0xffffe
    800032e6:	6fe080e7          	jalr	1790(ra) # 800019e0 <copyinstr>
    800032ea:	00054e63          	bltz	a0,80003306 <fetchstr+0x48>
  return strlen(buf);
    800032ee:	8526                	mv	a0,s1
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	dbc080e7          	jalr	-580(ra) # 800010ac <strlen>
}
    800032f8:	70a2                	ld	ra,40(sp)
    800032fa:	7402                	ld	s0,32(sp)
    800032fc:	64e2                	ld	s1,24(sp)
    800032fe:	6942                	ld	s2,16(sp)
    80003300:	69a2                	ld	s3,8(sp)
    80003302:	6145                	addi	sp,sp,48
    80003304:	8082                	ret
    return -1;
    80003306:	557d                	li	a0,-1
    80003308:	bfc5                	j	800032f8 <fetchstr+0x3a>

000000008000330a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    8000330a:	1101                	addi	sp,sp,-32
    8000330c:	ec06                	sd	ra,24(sp)
    8000330e:	e822                	sd	s0,16(sp)
    80003310:	e426                	sd	s1,8(sp)
    80003312:	1000                	addi	s0,sp,32
    80003314:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	eee080e7          	jalr	-274(ra) # 80003204 <argraw>
    8000331e:	c088                	sw	a0,0(s1)
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	64a2                	ld	s1,8(sp)
    80003326:	6105                	addi	sp,sp,32
    80003328:	8082                	ret

000000008000332a <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    8000332a:	1101                	addi	sp,sp,-32
    8000332c:	ec06                	sd	ra,24(sp)
    8000332e:	e822                	sd	s0,16(sp)
    80003330:	e426                	sd	s1,8(sp)
    80003332:	1000                	addi	s0,sp,32
    80003334:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003336:	00000097          	auipc	ra,0x0
    8000333a:	ece080e7          	jalr	-306(ra) # 80003204 <argraw>
    8000333e:	e088                	sd	a0,0(s1)
}
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	64a2                	ld	s1,8(sp)
    80003346:	6105                	addi	sp,sp,32
    80003348:	8082                	ret

000000008000334a <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    8000334a:	7179                	addi	sp,sp,-48
    8000334c:	f406                	sd	ra,40(sp)
    8000334e:	f022                	sd	s0,32(sp)
    80003350:	ec26                	sd	s1,24(sp)
    80003352:	e84a                	sd	s2,16(sp)
    80003354:	1800                	addi	s0,sp,48
    80003356:	84ae                	mv	s1,a1
    80003358:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000335a:	fd840593          	addi	a1,s0,-40
    8000335e:	00000097          	auipc	ra,0x0
    80003362:	fcc080e7          	jalr	-52(ra) # 8000332a <argaddr>
  return fetchstr(addr, buf, max);
    80003366:	864a                	mv	a2,s2
    80003368:	85a6                	mv	a1,s1
    8000336a:	fd843503          	ld	a0,-40(s0)
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	f50080e7          	jalr	-176(ra) # 800032be <fetchstr>
}
    80003376:	70a2                	ld	ra,40(sp)
    80003378:	7402                	ld	s0,32(sp)
    8000337a:	64e2                	ld	s1,24(sp)
    8000337c:	6942                	ld	s2,16(sp)
    8000337e:	6145                	addi	sp,sp,48
    80003380:	8082                	ret

0000000080003382 <syscall>:
    [SYS_history] sys_history,
    [SYS_top] sys_top,
};

void syscall(void)
{
    80003382:	1101                	addi	sp,sp,-32
    80003384:	ec06                	sd	ra,24(sp)
    80003386:	e822                	sd	s0,16(sp)
    80003388:	e426                	sd	s1,8(sp)
    8000338a:	e04a                	sd	s2,0(sp)
    8000338c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000338e:	fffff097          	auipc	ra,0xfffff
    80003392:	882080e7          	jalr	-1918(ra) # 80001c10 <myproc>
    80003396:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003398:	05853903          	ld	s2,88(a0)
    8000339c:	0a893783          	ld	a5,168(s2)
    800033a0:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800033a4:	37fd                	addiw	a5,a5,-1
    800033a6:	4759                	li	a4,22
    800033a8:	00f76f63          	bltu	a4,a5,800033c6 <syscall+0x44>
    800033ac:	00369713          	slli	a4,a3,0x3
    800033b0:	00005797          	auipc	a5,0x5
    800033b4:	13078793          	addi	a5,a5,304 # 800084e0 <syscalls>
    800033b8:	97ba                	add	a5,a5,a4
    800033ba:	639c                	ld	a5,0(a5)
    800033bc:	c789                	beqz	a5,800033c6 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800033be:	9782                	jalr	a5
    800033c0:	06a93823          	sd	a0,112(s2)
    800033c4:	a839                	j	800033e2 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    800033c6:	15848613          	addi	a2,s1,344
    800033ca:	588c                	lw	a1,48(s1)
    800033cc:	00005517          	auipc	a0,0x5
    800033d0:	0dc50513          	addi	a0,a0,220 # 800084a8 <states.0+0x198>
    800033d4:	ffffd097          	auipc	ra,0xffffd
    800033d8:	282080e7          	jalr	642(ra) # 80000656 <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800033dc:	6cbc                	ld	a5,88(s1)
    800033de:	577d                	li	a4,-1
    800033e0:	fbb8                	sd	a4,112(a5)
  }
}
    800033e2:	60e2                	ld	ra,24(sp)
    800033e4:	6442                	ld	s0,16(sp)
    800033e6:	64a2                	ld	s1,8(sp)
    800033e8:	6902                	ld	s2,0(sp)
    800033ea:	6105                	addi	sp,sp,32
    800033ec:	8082                	ret

00000000800033ee <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800033f6:	fec40593          	addi	a1,s0,-20
    800033fa:	4501                	li	a0,0
    800033fc:	00000097          	auipc	ra,0x0
    80003400:	f0e080e7          	jalr	-242(ra) # 8000330a <argint>
  exit(n);
    80003404:	fec42503          	lw	a0,-20(s0)
    80003408:	fffff097          	auipc	ra,0xfffff
    8000340c:	318080e7          	jalr	792(ra) # 80002720 <exit>
  return 0; // not reached
}
    80003410:	4501                	li	a0,0
    80003412:	60e2                	ld	ra,24(sp)
    80003414:	6442                	ld	s0,16(sp)
    80003416:	6105                	addi	sp,sp,32
    80003418:	8082                	ret

000000008000341a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000341a:	1141                	addi	sp,sp,-16
    8000341c:	e406                	sd	ra,8(sp)
    8000341e:	e022                	sd	s0,0(sp)
    80003420:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003422:	ffffe097          	auipc	ra,0xffffe
    80003426:	7ee080e7          	jalr	2030(ra) # 80001c10 <myproc>
}
    8000342a:	5908                	lw	a0,48(a0)
    8000342c:	60a2                	ld	ra,8(sp)
    8000342e:	6402                	ld	s0,0(sp)
    80003430:	0141                	addi	sp,sp,16
    80003432:	8082                	ret

0000000080003434 <sys_fork>:

uint64
sys_fork(void)
{
    80003434:	1141                	addi	sp,sp,-16
    80003436:	e406                	sd	ra,8(sp)
    80003438:	e022                	sd	s0,0(sp)
    8000343a:	0800                	addi	s0,sp,16
  return fork();
    8000343c:	fffff097          	auipc	ra,0xfffff
    80003440:	ca6080e7          	jalr	-858(ra) # 800020e2 <fork>
}
    80003444:	60a2                	ld	ra,8(sp)
    80003446:	6402                	ld	s0,0(sp)
    80003448:	0141                	addi	sp,sp,16
    8000344a:	8082                	ret

000000008000344c <sys_wait>:

uint64
sys_wait(void)
{
    8000344c:	1101                	addi	sp,sp,-32
    8000344e:	ec06                	sd	ra,24(sp)
    80003450:	e822                	sd	s0,16(sp)
    80003452:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003454:	fe840593          	addi	a1,s0,-24
    80003458:	4501                	li	a0,0
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	ed0080e7          	jalr	-304(ra) # 8000332a <argaddr>
  return wait(p);
    80003462:	fe843503          	ld	a0,-24(s0)
    80003466:	fffff097          	auipc	ra,0xfffff
    8000346a:	460080e7          	jalr	1120(ra) # 800028c6 <wait>
}
    8000346e:	60e2                	ld	ra,24(sp)
    80003470:	6442                	ld	s0,16(sp)
    80003472:	6105                	addi	sp,sp,32
    80003474:	8082                	ret

0000000080003476 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003476:	7179                	addi	sp,sp,-48
    80003478:	f406                	sd	ra,40(sp)
    8000347a:	f022                	sd	s0,32(sp)
    8000347c:	ec26                	sd	s1,24(sp)
    8000347e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003480:	fdc40593          	addi	a1,s0,-36
    80003484:	4501                	li	a0,0
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	e84080e7          	jalr	-380(ra) # 8000330a <argint>
  addr = myproc()->sz;
    8000348e:	ffffe097          	auipc	ra,0xffffe
    80003492:	782080e7          	jalr	1922(ra) # 80001c10 <myproc>
    80003496:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80003498:	fdc42503          	lw	a0,-36(s0)
    8000349c:	fffff097          	auipc	ra,0xfffff
    800034a0:	b08080e7          	jalr	-1272(ra) # 80001fa4 <growproc>
    800034a4:	00054863          	bltz	a0,800034b4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800034a8:	8526                	mv	a0,s1
    800034aa:	70a2                	ld	ra,40(sp)
    800034ac:	7402                	ld	s0,32(sp)
    800034ae:	64e2                	ld	s1,24(sp)
    800034b0:	6145                	addi	sp,sp,48
    800034b2:	8082                	ret
    return -1;
    800034b4:	54fd                	li	s1,-1
    800034b6:	bfcd                	j	800034a8 <sys_sbrk+0x32>

00000000800034b8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800034b8:	7139                	addi	sp,sp,-64
    800034ba:	fc06                	sd	ra,56(sp)
    800034bc:	f822                	sd	s0,48(sp)
    800034be:	f426                	sd	s1,40(sp)
    800034c0:	f04a                	sd	s2,32(sp)
    800034c2:	ec4e                	sd	s3,24(sp)
    800034c4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800034c6:	fcc40593          	addi	a1,s0,-52
    800034ca:	4501                	li	a0,0
    800034cc:	00000097          	auipc	ra,0x0
    800034d0:	e3e080e7          	jalr	-450(ra) # 8000330a <argint>
  acquire(&tickslock);
    800034d4:	00034517          	auipc	a0,0x34
    800034d8:	79450513          	addi	a0,a0,1940 # 80037c68 <tickslock>
    800034dc:	ffffe097          	auipc	ra,0xffffe
    800034e0:	958080e7          	jalr	-1704(ra) # 80000e34 <acquire>
  ticks0 = ticks;
    800034e4:	00005917          	auipc	s2,0x5
    800034e8:	47c92903          	lw	s2,1148(s2) # 80008960 <ticks>
  while (ticks - ticks0 < n)
    800034ec:	fcc42783          	lw	a5,-52(s0)
    800034f0:	cf9d                	beqz	a5,8000352e <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800034f2:	00034997          	auipc	s3,0x34
    800034f6:	77698993          	addi	s3,s3,1910 # 80037c68 <tickslock>
    800034fa:	00005497          	auipc	s1,0x5
    800034fe:	46648493          	addi	s1,s1,1126 # 80008960 <ticks>
    if (killed(myproc()))
    80003502:	ffffe097          	auipc	ra,0xffffe
    80003506:	70e080e7          	jalr	1806(ra) # 80001c10 <myproc>
    8000350a:	fffff097          	auipc	ra,0xfffff
    8000350e:	38a080e7          	jalr	906(ra) # 80002894 <killed>
    80003512:	ed15                	bnez	a0,8000354e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003514:	85ce                	mv	a1,s3
    80003516:	8526                	mv	a0,s1
    80003518:	fffff097          	auipc	ra,0xfffff
    8000351c:	0d4080e7          	jalr	212(ra) # 800025ec <sleep>
  while (ticks - ticks0 < n)
    80003520:	409c                	lw	a5,0(s1)
    80003522:	412787bb          	subw	a5,a5,s2
    80003526:	fcc42703          	lw	a4,-52(s0)
    8000352a:	fce7ece3          	bltu	a5,a4,80003502 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000352e:	00034517          	auipc	a0,0x34
    80003532:	73a50513          	addi	a0,a0,1850 # 80037c68 <tickslock>
    80003536:	ffffe097          	auipc	ra,0xffffe
    8000353a:	9b2080e7          	jalr	-1614(ra) # 80000ee8 <release>
  return 0;
    8000353e:	4501                	li	a0,0
}
    80003540:	70e2                	ld	ra,56(sp)
    80003542:	7442                	ld	s0,48(sp)
    80003544:	74a2                	ld	s1,40(sp)
    80003546:	7902                	ld	s2,32(sp)
    80003548:	69e2                	ld	s3,24(sp)
    8000354a:	6121                	addi	sp,sp,64
    8000354c:	8082                	ret
      release(&tickslock);
    8000354e:	00034517          	auipc	a0,0x34
    80003552:	71a50513          	addi	a0,a0,1818 # 80037c68 <tickslock>
    80003556:	ffffe097          	auipc	ra,0xffffe
    8000355a:	992080e7          	jalr	-1646(ra) # 80000ee8 <release>
      return -1;
    8000355e:	557d                	li	a0,-1
    80003560:	b7c5                	j	80003540 <sys_sleep+0x88>

0000000080003562 <sys_kill>:

uint64
sys_kill(void)
{
    80003562:	1101                	addi	sp,sp,-32
    80003564:	ec06                	sd	ra,24(sp)
    80003566:	e822                	sd	s0,16(sp)
    80003568:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000356a:	fec40593          	addi	a1,s0,-20
    8000356e:	4501                	li	a0,0
    80003570:	00000097          	auipc	ra,0x0
    80003574:	d9a080e7          	jalr	-614(ra) # 8000330a <argint>
  return kill(pid);
    80003578:	fec42503          	lw	a0,-20(s0)
    8000357c:	fffff097          	auipc	ra,0xfffff
    80003580:	27a080e7          	jalr	634(ra) # 800027f6 <kill>
}
    80003584:	60e2                	ld	ra,24(sp)
    80003586:	6442                	ld	s0,16(sp)
    80003588:	6105                	addi	sp,sp,32
    8000358a:	8082                	ret

000000008000358c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000358c:	1101                	addi	sp,sp,-32
    8000358e:	ec06                	sd	ra,24(sp)
    80003590:	e822                	sd	s0,16(sp)
    80003592:	e426                	sd	s1,8(sp)
    80003594:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003596:	00034517          	auipc	a0,0x34
    8000359a:	6d250513          	addi	a0,a0,1746 # 80037c68 <tickslock>
    8000359e:	ffffe097          	auipc	ra,0xffffe
    800035a2:	896080e7          	jalr	-1898(ra) # 80000e34 <acquire>
  xticks = ticks;
    800035a6:	00005497          	auipc	s1,0x5
    800035aa:	3ba4a483          	lw	s1,954(s1) # 80008960 <ticks>
  release(&tickslock);
    800035ae:	00034517          	auipc	a0,0x34
    800035b2:	6ba50513          	addi	a0,a0,1722 # 80037c68 <tickslock>
    800035b6:	ffffe097          	auipc	ra,0xffffe
    800035ba:	932080e7          	jalr	-1742(ra) # 80000ee8 <release>
  return xticks;
}
    800035be:	02049513          	slli	a0,s1,0x20
    800035c2:	9101                	srli	a0,a0,0x20
    800035c4:	60e2                	ld	ra,24(sp)
    800035c6:	6442                	ld	s0,16(sp)
    800035c8:	64a2                	ld	s1,8(sp)
    800035ca:	6105                	addi	sp,sp,32
    800035cc:	8082                	ret

00000000800035ce <sys_history>:

uint64 sys_history(void)
{
    800035ce:	1101                	addi	sp,sp,-32
    800035d0:	ec06                	sd	ra,24(sp)
    800035d2:	e822                	sd	s0,16(sp)
    800035d4:	1000                	addi	s0,sp,32
  int historyId;
  argint(0, &historyId);
    800035d6:	fec40593          	addi	a1,s0,-20
    800035da:	4501                	li	a0,0
    800035dc:	00000097          	auipc	ra,0x0
    800035e0:	d2e080e7          	jalr	-722(ra) # 8000330a <argint>
  return history(historyId);
    800035e4:	fec42503          	lw	a0,-20(s0)
    800035e8:	fffff097          	auipc	ra,0xfffff
    800035ec:	56e080e7          	jalr	1390(ra) # 80002b56 <history>
}
    800035f0:	60e2                	ld	ra,24(sp)
    800035f2:	6442                	ld	s0,16(sp)
    800035f4:	6105                	addi	sp,sp,32
    800035f6:	8082                	ret

00000000800035f8 <sys_top>:

uint64 sys_top(void)
{
    800035f8:	81010113          	addi	sp,sp,-2032
    800035fc:	7e113423          	sd	ra,2024(sp)
    80003600:	7e813023          	sd	s0,2016(sp)
    80003604:	7c913c23          	sd	s1,2008(sp)
    80003608:	7d213823          	sd	s2,2000(sp)
    8000360c:	7d313423          	sd	s3,1992(sp)
    80003610:	7d413023          	sd	s4,1984(sp)
    80003614:	7f010413          	addi	s0,sp,2032
    80003618:	b9010113          	addi	sp,sp,-1136
  struct top *topInput;
  struct top kernelTop;
  argaddr(0, (uint64 *)(&topInput));
    8000361c:	fc840593          	addi	a1,s0,-56
    80003620:	4501                	li	a0,0
    80003622:	00000097          	auipc	ra,0x0
    80003626:	d08080e7          	jalr	-760(ra) # 8000332a <argaddr>
  struct proc *p = myproc();
    8000362a:	ffffe097          	auipc	ra,0xffffe
    8000362e:	5e6080e7          	jalr	1510(ra) # 80001c10 <myproc>
    80003632:	892a                	mv	s2,a0
  copyin(p->pagetable, (char *)topInput, (uint64)&kernelTop, sizeof(kernelTop));
    80003634:	74fd                	lui	s1,0xfffff
    80003636:	3d048493          	addi	s1,s1,976 # fffffffffffff3d0 <end+0xffffffff7ffbc388>
    8000363a:	fd040793          	addi	a5,s0,-48
    8000363e:	94be                	add	s1,s1,a5
    80003640:	6a05                	lui	s4,0x1
    80003642:	c28a0693          	addi	a3,s4,-984 # c28 <_entry-0x7ffff3d8>
    80003646:	8626                	mv	a2,s1
    80003648:	fc843583          	ld	a1,-56(s0)
    8000364c:	6928                	ld	a0,80(a0)
    8000364e:	ffffe097          	auipc	ra,0xffffe
    80003652:	304080e7          	jalr	772(ra) # 80001952 <copyin>
  int result = top(&kernelTop);
    80003656:	8526                	mv	a0,s1
    80003658:	fffff097          	auipc	ra,0xfffff
    8000365c:	59a080e7          	jalr	1434(ra) # 80002bf2 <top>
    80003660:	89aa                	mv	s3,a0
  copyout(p->pagetable, (uint64)topInput, (char *)&kernelTop, sizeof(kernelTop));
    80003662:	c28a0693          	addi	a3,s4,-984
    80003666:	8626                	mv	a2,s1
    80003668:	fc843583          	ld	a1,-56(s0)
    8000366c:	05093503          	ld	a0,80(s2)
    80003670:	ffffe097          	auipc	ra,0xffffe
    80003674:	256080e7          	jalr	598(ra) # 800018c6 <copyout>
  return result;
    80003678:	854e                	mv	a0,s3
    8000367a:	47010113          	addi	sp,sp,1136
    8000367e:	7e813083          	ld	ra,2024(sp)
    80003682:	7e013403          	ld	s0,2016(sp)
    80003686:	7d813483          	ld	s1,2008(sp)
    8000368a:	7d013903          	ld	s2,2000(sp)
    8000368e:	7c813983          	ld	s3,1992(sp)
    80003692:	7c013a03          	ld	s4,1984(sp)
    80003696:	7f010113          	addi	sp,sp,2032
    8000369a:	8082                	ret

000000008000369c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000369c:	7179                	addi	sp,sp,-48
    8000369e:	f406                	sd	ra,40(sp)
    800036a0:	f022                	sd	s0,32(sp)
    800036a2:	ec26                	sd	s1,24(sp)
    800036a4:	e84a                	sd	s2,16(sp)
    800036a6:	e44e                	sd	s3,8(sp)
    800036a8:	e052                	sd	s4,0(sp)
    800036aa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036ac:	00005597          	auipc	a1,0x5
    800036b0:	ef458593          	addi	a1,a1,-268 # 800085a0 <syscalls+0xc0>
    800036b4:	00034517          	auipc	a0,0x34
    800036b8:	5cc50513          	addi	a0,a0,1484 # 80037c80 <bcache>
    800036bc:	ffffd097          	auipc	ra,0xffffd
    800036c0:	6e8080e7          	jalr	1768(ra) # 80000da4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036c4:	0003c797          	auipc	a5,0x3c
    800036c8:	5bc78793          	addi	a5,a5,1468 # 8003fc80 <bcache+0x8000>
    800036cc:	0003d717          	auipc	a4,0x3d
    800036d0:	81c70713          	addi	a4,a4,-2020 # 8003fee8 <bcache+0x8268>
    800036d4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036d8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036dc:	00034497          	auipc	s1,0x34
    800036e0:	5bc48493          	addi	s1,s1,1468 # 80037c98 <bcache+0x18>
    b->next = bcache.head.next;
    800036e4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036e6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036e8:	00005a17          	auipc	s4,0x5
    800036ec:	ec0a0a13          	addi	s4,s4,-320 # 800085a8 <syscalls+0xc8>
    b->next = bcache.head.next;
    800036f0:	2b893783          	ld	a5,696(s2)
    800036f4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800036f6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036fa:	85d2                	mv	a1,s4
    800036fc:	01048513          	addi	a0,s1,16
    80003700:	00001097          	auipc	ra,0x1
    80003704:	4c4080e7          	jalr	1220(ra) # 80004bc4 <initsleeplock>
    bcache.head.next->prev = b;
    80003708:	2b893783          	ld	a5,696(s2)
    8000370c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000370e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003712:	45848493          	addi	s1,s1,1112
    80003716:	fd349de3          	bne	s1,s3,800036f0 <binit+0x54>
  }
}
    8000371a:	70a2                	ld	ra,40(sp)
    8000371c:	7402                	ld	s0,32(sp)
    8000371e:	64e2                	ld	s1,24(sp)
    80003720:	6942                	ld	s2,16(sp)
    80003722:	69a2                	ld	s3,8(sp)
    80003724:	6a02                	ld	s4,0(sp)
    80003726:	6145                	addi	sp,sp,48
    80003728:	8082                	ret

000000008000372a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000372a:	7179                	addi	sp,sp,-48
    8000372c:	f406                	sd	ra,40(sp)
    8000372e:	f022                	sd	s0,32(sp)
    80003730:	ec26                	sd	s1,24(sp)
    80003732:	e84a                	sd	s2,16(sp)
    80003734:	e44e                	sd	s3,8(sp)
    80003736:	1800                	addi	s0,sp,48
    80003738:	892a                	mv	s2,a0
    8000373a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000373c:	00034517          	auipc	a0,0x34
    80003740:	54450513          	addi	a0,a0,1348 # 80037c80 <bcache>
    80003744:	ffffd097          	auipc	ra,0xffffd
    80003748:	6f0080e7          	jalr	1776(ra) # 80000e34 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000374c:	0003c497          	auipc	s1,0x3c
    80003750:	7ec4b483          	ld	s1,2028(s1) # 8003ff38 <bcache+0x82b8>
    80003754:	0003c797          	auipc	a5,0x3c
    80003758:	79478793          	addi	a5,a5,1940 # 8003fee8 <bcache+0x8268>
    8000375c:	02f48f63          	beq	s1,a5,8000379a <bread+0x70>
    80003760:	873e                	mv	a4,a5
    80003762:	a021                	j	8000376a <bread+0x40>
    80003764:	68a4                	ld	s1,80(s1)
    80003766:	02e48a63          	beq	s1,a4,8000379a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000376a:	449c                	lw	a5,8(s1)
    8000376c:	ff279ce3          	bne	a5,s2,80003764 <bread+0x3a>
    80003770:	44dc                	lw	a5,12(s1)
    80003772:	ff3799e3          	bne	a5,s3,80003764 <bread+0x3a>
      b->refcnt++;
    80003776:	40bc                	lw	a5,64(s1)
    80003778:	2785                	addiw	a5,a5,1
    8000377a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000377c:	00034517          	auipc	a0,0x34
    80003780:	50450513          	addi	a0,a0,1284 # 80037c80 <bcache>
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	764080e7          	jalr	1892(ra) # 80000ee8 <release>
      acquiresleep(&b->lock);
    8000378c:	01048513          	addi	a0,s1,16
    80003790:	00001097          	auipc	ra,0x1
    80003794:	46e080e7          	jalr	1134(ra) # 80004bfe <acquiresleep>
      return b;
    80003798:	a8b9                	j	800037f6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000379a:	0003c497          	auipc	s1,0x3c
    8000379e:	7964b483          	ld	s1,1942(s1) # 8003ff30 <bcache+0x82b0>
    800037a2:	0003c797          	auipc	a5,0x3c
    800037a6:	74678793          	addi	a5,a5,1862 # 8003fee8 <bcache+0x8268>
    800037aa:	00f48863          	beq	s1,a5,800037ba <bread+0x90>
    800037ae:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037b0:	40bc                	lw	a5,64(s1)
    800037b2:	cf81                	beqz	a5,800037ca <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037b4:	64a4                	ld	s1,72(s1)
    800037b6:	fee49de3          	bne	s1,a4,800037b0 <bread+0x86>
  panic("bget: no buffers");
    800037ba:	00005517          	auipc	a0,0x5
    800037be:	df650513          	addi	a0,a0,-522 # 800085b0 <syscalls+0xd0>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	e4a080e7          	jalr	-438(ra) # 8000060c <panic>
      b->dev = dev;
    800037ca:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800037ce:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800037d2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037d6:	4785                	li	a5,1
    800037d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037da:	00034517          	auipc	a0,0x34
    800037de:	4a650513          	addi	a0,a0,1190 # 80037c80 <bcache>
    800037e2:	ffffd097          	auipc	ra,0xffffd
    800037e6:	706080e7          	jalr	1798(ra) # 80000ee8 <release>
      acquiresleep(&b->lock);
    800037ea:	01048513          	addi	a0,s1,16
    800037ee:	00001097          	auipc	ra,0x1
    800037f2:	410080e7          	jalr	1040(ra) # 80004bfe <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037f6:	409c                	lw	a5,0(s1)
    800037f8:	cb89                	beqz	a5,8000380a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037fa:	8526                	mv	a0,s1
    800037fc:	70a2                	ld	ra,40(sp)
    800037fe:	7402                	ld	s0,32(sp)
    80003800:	64e2                	ld	s1,24(sp)
    80003802:	6942                	ld	s2,16(sp)
    80003804:	69a2                	ld	s3,8(sp)
    80003806:	6145                	addi	sp,sp,48
    80003808:	8082                	ret
    virtio_disk_rw(b, 0);
    8000380a:	4581                	li	a1,0
    8000380c:	8526                	mv	a0,s1
    8000380e:	00003097          	auipc	ra,0x3
    80003812:	fd6080e7          	jalr	-42(ra) # 800067e4 <virtio_disk_rw>
    b->valid = 1;
    80003816:	4785                	li	a5,1
    80003818:	c09c                	sw	a5,0(s1)
  return b;
    8000381a:	b7c5                	j	800037fa <bread+0xd0>

000000008000381c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000381c:	1101                	addi	sp,sp,-32
    8000381e:	ec06                	sd	ra,24(sp)
    80003820:	e822                	sd	s0,16(sp)
    80003822:	e426                	sd	s1,8(sp)
    80003824:	1000                	addi	s0,sp,32
    80003826:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003828:	0541                	addi	a0,a0,16
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	46e080e7          	jalr	1134(ra) # 80004c98 <holdingsleep>
    80003832:	cd01                	beqz	a0,8000384a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003834:	4585                	li	a1,1
    80003836:	8526                	mv	a0,s1
    80003838:	00003097          	auipc	ra,0x3
    8000383c:	fac080e7          	jalr	-84(ra) # 800067e4 <virtio_disk_rw>
}
    80003840:	60e2                	ld	ra,24(sp)
    80003842:	6442                	ld	s0,16(sp)
    80003844:	64a2                	ld	s1,8(sp)
    80003846:	6105                	addi	sp,sp,32
    80003848:	8082                	ret
    panic("bwrite");
    8000384a:	00005517          	auipc	a0,0x5
    8000384e:	d7e50513          	addi	a0,a0,-642 # 800085c8 <syscalls+0xe8>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	dba080e7          	jalr	-582(ra) # 8000060c <panic>

000000008000385a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	e04a                	sd	s2,0(sp)
    80003864:	1000                	addi	s0,sp,32
    80003866:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003868:	01050913          	addi	s2,a0,16
    8000386c:	854a                	mv	a0,s2
    8000386e:	00001097          	auipc	ra,0x1
    80003872:	42a080e7          	jalr	1066(ra) # 80004c98 <holdingsleep>
    80003876:	c92d                	beqz	a0,800038e8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003878:	854a                	mv	a0,s2
    8000387a:	00001097          	auipc	ra,0x1
    8000387e:	3da080e7          	jalr	986(ra) # 80004c54 <releasesleep>

  acquire(&bcache.lock);
    80003882:	00034517          	auipc	a0,0x34
    80003886:	3fe50513          	addi	a0,a0,1022 # 80037c80 <bcache>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	5aa080e7          	jalr	1450(ra) # 80000e34 <acquire>
  b->refcnt--;
    80003892:	40bc                	lw	a5,64(s1)
    80003894:	37fd                	addiw	a5,a5,-1
    80003896:	0007871b          	sext.w	a4,a5
    8000389a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000389c:	eb05                	bnez	a4,800038cc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000389e:	68bc                	ld	a5,80(s1)
    800038a0:	64b8                	ld	a4,72(s1)
    800038a2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800038a4:	64bc                	ld	a5,72(s1)
    800038a6:	68b8                	ld	a4,80(s1)
    800038a8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800038aa:	0003c797          	auipc	a5,0x3c
    800038ae:	3d678793          	addi	a5,a5,982 # 8003fc80 <bcache+0x8000>
    800038b2:	2b87b703          	ld	a4,696(a5)
    800038b6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038b8:	0003c717          	auipc	a4,0x3c
    800038bc:	63070713          	addi	a4,a4,1584 # 8003fee8 <bcache+0x8268>
    800038c0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800038c2:	2b87b703          	ld	a4,696(a5)
    800038c6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038c8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038cc:	00034517          	auipc	a0,0x34
    800038d0:	3b450513          	addi	a0,a0,948 # 80037c80 <bcache>
    800038d4:	ffffd097          	auipc	ra,0xffffd
    800038d8:	614080e7          	jalr	1556(ra) # 80000ee8 <release>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6902                	ld	s2,0(sp)
    800038e4:	6105                	addi	sp,sp,32
    800038e6:	8082                	ret
    panic("brelse");
    800038e8:	00005517          	auipc	a0,0x5
    800038ec:	ce850513          	addi	a0,a0,-792 # 800085d0 <syscalls+0xf0>
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	d1c080e7          	jalr	-740(ra) # 8000060c <panic>

00000000800038f8 <bpin>:

void
bpin(struct buf *b) {
    800038f8:	1101                	addi	sp,sp,-32
    800038fa:	ec06                	sd	ra,24(sp)
    800038fc:	e822                	sd	s0,16(sp)
    800038fe:	e426                	sd	s1,8(sp)
    80003900:	1000                	addi	s0,sp,32
    80003902:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003904:	00034517          	auipc	a0,0x34
    80003908:	37c50513          	addi	a0,a0,892 # 80037c80 <bcache>
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	528080e7          	jalr	1320(ra) # 80000e34 <acquire>
  b->refcnt++;
    80003914:	40bc                	lw	a5,64(s1)
    80003916:	2785                	addiw	a5,a5,1
    80003918:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000391a:	00034517          	auipc	a0,0x34
    8000391e:	36650513          	addi	a0,a0,870 # 80037c80 <bcache>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	5c6080e7          	jalr	1478(ra) # 80000ee8 <release>
}
    8000392a:	60e2                	ld	ra,24(sp)
    8000392c:	6442                	ld	s0,16(sp)
    8000392e:	64a2                	ld	s1,8(sp)
    80003930:	6105                	addi	sp,sp,32
    80003932:	8082                	ret

0000000080003934 <bunpin>:

void
bunpin(struct buf *b) {
    80003934:	1101                	addi	sp,sp,-32
    80003936:	ec06                	sd	ra,24(sp)
    80003938:	e822                	sd	s0,16(sp)
    8000393a:	e426                	sd	s1,8(sp)
    8000393c:	1000                	addi	s0,sp,32
    8000393e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003940:	00034517          	auipc	a0,0x34
    80003944:	34050513          	addi	a0,a0,832 # 80037c80 <bcache>
    80003948:	ffffd097          	auipc	ra,0xffffd
    8000394c:	4ec080e7          	jalr	1260(ra) # 80000e34 <acquire>
  b->refcnt--;
    80003950:	40bc                	lw	a5,64(s1)
    80003952:	37fd                	addiw	a5,a5,-1
    80003954:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003956:	00034517          	auipc	a0,0x34
    8000395a:	32a50513          	addi	a0,a0,810 # 80037c80 <bcache>
    8000395e:	ffffd097          	auipc	ra,0xffffd
    80003962:	58a080e7          	jalr	1418(ra) # 80000ee8 <release>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6105                	addi	sp,sp,32
    8000396e:	8082                	ret

0000000080003970 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003970:	1101                	addi	sp,sp,-32
    80003972:	ec06                	sd	ra,24(sp)
    80003974:	e822                	sd	s0,16(sp)
    80003976:	e426                	sd	s1,8(sp)
    80003978:	e04a                	sd	s2,0(sp)
    8000397a:	1000                	addi	s0,sp,32
    8000397c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000397e:	00d5d59b          	srliw	a1,a1,0xd
    80003982:	0003d797          	auipc	a5,0x3d
    80003986:	9da7a783          	lw	a5,-1574(a5) # 8004035c <sb+0x1c>
    8000398a:	9dbd                	addw	a1,a1,a5
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	d9e080e7          	jalr	-610(ra) # 8000372a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003994:	0074f713          	andi	a4,s1,7
    80003998:	4785                	li	a5,1
    8000399a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000399e:	14ce                	slli	s1,s1,0x33
    800039a0:	90d9                	srli	s1,s1,0x36
    800039a2:	00950733          	add	a4,a0,s1
    800039a6:	05874703          	lbu	a4,88(a4)
    800039aa:	00e7f6b3          	and	a3,a5,a4
    800039ae:	c69d                	beqz	a3,800039dc <bfree+0x6c>
    800039b0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039b2:	94aa                	add	s1,s1,a0
    800039b4:	fff7c793          	not	a5,a5
    800039b8:	8ff9                	and	a5,a5,a4
    800039ba:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800039be:	00001097          	auipc	ra,0x1
    800039c2:	120080e7          	jalr	288(ra) # 80004ade <log_write>
  brelse(bp);
    800039c6:	854a                	mv	a0,s2
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	e92080e7          	jalr	-366(ra) # 8000385a <brelse>
}
    800039d0:	60e2                	ld	ra,24(sp)
    800039d2:	6442                	ld	s0,16(sp)
    800039d4:	64a2                	ld	s1,8(sp)
    800039d6:	6902                	ld	s2,0(sp)
    800039d8:	6105                	addi	sp,sp,32
    800039da:	8082                	ret
    panic("freeing free block");
    800039dc:	00005517          	auipc	a0,0x5
    800039e0:	bfc50513          	addi	a0,a0,-1028 # 800085d8 <syscalls+0xf8>
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	c28080e7          	jalr	-984(ra) # 8000060c <panic>

00000000800039ec <balloc>:
{
    800039ec:	711d                	addi	sp,sp,-96
    800039ee:	ec86                	sd	ra,88(sp)
    800039f0:	e8a2                	sd	s0,80(sp)
    800039f2:	e4a6                	sd	s1,72(sp)
    800039f4:	e0ca                	sd	s2,64(sp)
    800039f6:	fc4e                	sd	s3,56(sp)
    800039f8:	f852                	sd	s4,48(sp)
    800039fa:	f456                	sd	s5,40(sp)
    800039fc:	f05a                	sd	s6,32(sp)
    800039fe:	ec5e                	sd	s7,24(sp)
    80003a00:	e862                	sd	s8,16(sp)
    80003a02:	e466                	sd	s9,8(sp)
    80003a04:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a06:	0003d797          	auipc	a5,0x3d
    80003a0a:	93e7a783          	lw	a5,-1730(a5) # 80040344 <sb+0x4>
    80003a0e:	10078163          	beqz	a5,80003b10 <balloc+0x124>
    80003a12:	8baa                	mv	s7,a0
    80003a14:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a16:	0003db17          	auipc	s6,0x3d
    80003a1a:	92ab0b13          	addi	s6,s6,-1750 # 80040340 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a1e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a20:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a22:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a24:	6c89                	lui	s9,0x2
    80003a26:	a061                	j	80003aae <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a28:	974a                	add	a4,a4,s2
    80003a2a:	8fd5                	or	a5,a5,a3
    80003a2c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a30:	854a                	mv	a0,s2
    80003a32:	00001097          	auipc	ra,0x1
    80003a36:	0ac080e7          	jalr	172(ra) # 80004ade <log_write>
        brelse(bp);
    80003a3a:	854a                	mv	a0,s2
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	e1e080e7          	jalr	-482(ra) # 8000385a <brelse>
  bp = bread(dev, bno);
    80003a44:	85a6                	mv	a1,s1
    80003a46:	855e                	mv	a0,s7
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	ce2080e7          	jalr	-798(ra) # 8000372a <bread>
    80003a50:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a52:	40000613          	li	a2,1024
    80003a56:	4581                	li	a1,0
    80003a58:	05850513          	addi	a0,a0,88
    80003a5c:	ffffd097          	auipc	ra,0xffffd
    80003a60:	4d4080e7          	jalr	1236(ra) # 80000f30 <memset>
  log_write(bp);
    80003a64:	854a                	mv	a0,s2
    80003a66:	00001097          	auipc	ra,0x1
    80003a6a:	078080e7          	jalr	120(ra) # 80004ade <log_write>
  brelse(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	dea080e7          	jalr	-534(ra) # 8000385a <brelse>
}
    80003a78:	8526                	mv	a0,s1
    80003a7a:	60e6                	ld	ra,88(sp)
    80003a7c:	6446                	ld	s0,80(sp)
    80003a7e:	64a6                	ld	s1,72(sp)
    80003a80:	6906                	ld	s2,64(sp)
    80003a82:	79e2                	ld	s3,56(sp)
    80003a84:	7a42                	ld	s4,48(sp)
    80003a86:	7aa2                	ld	s5,40(sp)
    80003a88:	7b02                	ld	s6,32(sp)
    80003a8a:	6be2                	ld	s7,24(sp)
    80003a8c:	6c42                	ld	s8,16(sp)
    80003a8e:	6ca2                	ld	s9,8(sp)
    80003a90:	6125                	addi	sp,sp,96
    80003a92:	8082                	ret
    brelse(bp);
    80003a94:	854a                	mv	a0,s2
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	dc4080e7          	jalr	-572(ra) # 8000385a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a9e:	015c87bb          	addw	a5,s9,s5
    80003aa2:	00078a9b          	sext.w	s5,a5
    80003aa6:	004b2703          	lw	a4,4(s6)
    80003aaa:	06eaf363          	bgeu	s5,a4,80003b10 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003aae:	41fad79b          	sraiw	a5,s5,0x1f
    80003ab2:	0137d79b          	srliw	a5,a5,0x13
    80003ab6:	015787bb          	addw	a5,a5,s5
    80003aba:	40d7d79b          	sraiw	a5,a5,0xd
    80003abe:	01cb2583          	lw	a1,28(s6)
    80003ac2:	9dbd                	addw	a1,a1,a5
    80003ac4:	855e                	mv	a0,s7
    80003ac6:	00000097          	auipc	ra,0x0
    80003aca:	c64080e7          	jalr	-924(ra) # 8000372a <bread>
    80003ace:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ad0:	004b2503          	lw	a0,4(s6)
    80003ad4:	000a849b          	sext.w	s1,s5
    80003ad8:	8662                	mv	a2,s8
    80003ada:	faa4fde3          	bgeu	s1,a0,80003a94 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003ade:	41f6579b          	sraiw	a5,a2,0x1f
    80003ae2:	01d7d69b          	srliw	a3,a5,0x1d
    80003ae6:	00c6873b          	addw	a4,a3,a2
    80003aea:	00777793          	andi	a5,a4,7
    80003aee:	9f95                	subw	a5,a5,a3
    80003af0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003af4:	4037571b          	sraiw	a4,a4,0x3
    80003af8:	00e906b3          	add	a3,s2,a4
    80003afc:	0586c683          	lbu	a3,88(a3)
    80003b00:	00d7f5b3          	and	a1,a5,a3
    80003b04:	d195                	beqz	a1,80003a28 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b06:	2605                	addiw	a2,a2,1
    80003b08:	2485                	addiw	s1,s1,1
    80003b0a:	fd4618e3          	bne	a2,s4,80003ada <balloc+0xee>
    80003b0e:	b759                	j	80003a94 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003b10:	00005517          	auipc	a0,0x5
    80003b14:	ae050513          	addi	a0,a0,-1312 # 800085f0 <syscalls+0x110>
    80003b18:	ffffd097          	auipc	ra,0xffffd
    80003b1c:	b3e080e7          	jalr	-1218(ra) # 80000656 <printf>
  return 0;
    80003b20:	4481                	li	s1,0
    80003b22:	bf99                	j	80003a78 <balloc+0x8c>

0000000080003b24 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b24:	7179                	addi	sp,sp,-48
    80003b26:	f406                	sd	ra,40(sp)
    80003b28:	f022                	sd	s0,32(sp)
    80003b2a:	ec26                	sd	s1,24(sp)
    80003b2c:	e84a                	sd	s2,16(sp)
    80003b2e:	e44e                	sd	s3,8(sp)
    80003b30:	e052                	sd	s4,0(sp)
    80003b32:	1800                	addi	s0,sp,48
    80003b34:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b36:	47ad                	li	a5,11
    80003b38:	02b7e763          	bltu	a5,a1,80003b66 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b3c:	02059493          	slli	s1,a1,0x20
    80003b40:	9081                	srli	s1,s1,0x20
    80003b42:	048a                	slli	s1,s1,0x2
    80003b44:	94aa                	add	s1,s1,a0
    80003b46:	0504a903          	lw	s2,80(s1)
    80003b4a:	06091e63          	bnez	s2,80003bc6 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003b4e:	4108                	lw	a0,0(a0)
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	e9c080e7          	jalr	-356(ra) # 800039ec <balloc>
    80003b58:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b5c:	06090563          	beqz	s2,80003bc6 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003b60:	0524a823          	sw	s2,80(s1)
    80003b64:	a08d                	j	80003bc6 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b66:	ff45849b          	addiw	s1,a1,-12
    80003b6a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b6e:	0ff00793          	li	a5,255
    80003b72:	08e7e563          	bltu	a5,a4,80003bfc <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b76:	08052903          	lw	s2,128(a0)
    80003b7a:	00091d63          	bnez	s2,80003b94 <bmap+0x70>
      addr = balloc(ip->dev);
    80003b7e:	4108                	lw	a0,0(a0)
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	e6c080e7          	jalr	-404(ra) # 800039ec <balloc>
    80003b88:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b8c:	02090d63          	beqz	s2,80003bc6 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b90:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b94:	85ca                	mv	a1,s2
    80003b96:	0009a503          	lw	a0,0(s3)
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	b90080e7          	jalr	-1136(ra) # 8000372a <bread>
    80003ba2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003ba4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003ba8:	02049593          	slli	a1,s1,0x20
    80003bac:	9181                	srli	a1,a1,0x20
    80003bae:	058a                	slli	a1,a1,0x2
    80003bb0:	00b784b3          	add	s1,a5,a1
    80003bb4:	0004a903          	lw	s2,0(s1)
    80003bb8:	02090063          	beqz	s2,80003bd8 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003bbc:	8552                	mv	a0,s4
    80003bbe:	00000097          	auipc	ra,0x0
    80003bc2:	c9c080e7          	jalr	-868(ra) # 8000385a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003bc6:	854a                	mv	a0,s2
    80003bc8:	70a2                	ld	ra,40(sp)
    80003bca:	7402                	ld	s0,32(sp)
    80003bcc:	64e2                	ld	s1,24(sp)
    80003bce:	6942                	ld	s2,16(sp)
    80003bd0:	69a2                	ld	s3,8(sp)
    80003bd2:	6a02                	ld	s4,0(sp)
    80003bd4:	6145                	addi	sp,sp,48
    80003bd6:	8082                	ret
      addr = balloc(ip->dev);
    80003bd8:	0009a503          	lw	a0,0(s3)
    80003bdc:	00000097          	auipc	ra,0x0
    80003be0:	e10080e7          	jalr	-496(ra) # 800039ec <balloc>
    80003be4:	0005091b          	sext.w	s2,a0
      if(addr){
    80003be8:	fc090ae3          	beqz	s2,80003bbc <bmap+0x98>
        a[bn] = addr;
    80003bec:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003bf0:	8552                	mv	a0,s4
    80003bf2:	00001097          	auipc	ra,0x1
    80003bf6:	eec080e7          	jalr	-276(ra) # 80004ade <log_write>
    80003bfa:	b7c9                	j	80003bbc <bmap+0x98>
  panic("bmap: out of range");
    80003bfc:	00005517          	auipc	a0,0x5
    80003c00:	a0c50513          	addi	a0,a0,-1524 # 80008608 <syscalls+0x128>
    80003c04:	ffffd097          	auipc	ra,0xffffd
    80003c08:	a08080e7          	jalr	-1528(ra) # 8000060c <panic>

0000000080003c0c <iget>:
{
    80003c0c:	7179                	addi	sp,sp,-48
    80003c0e:	f406                	sd	ra,40(sp)
    80003c10:	f022                	sd	s0,32(sp)
    80003c12:	ec26                	sd	s1,24(sp)
    80003c14:	e84a                	sd	s2,16(sp)
    80003c16:	e44e                	sd	s3,8(sp)
    80003c18:	e052                	sd	s4,0(sp)
    80003c1a:	1800                	addi	s0,sp,48
    80003c1c:	89aa                	mv	s3,a0
    80003c1e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c20:	0003c517          	auipc	a0,0x3c
    80003c24:	74050513          	addi	a0,a0,1856 # 80040360 <itable>
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	20c080e7          	jalr	524(ra) # 80000e34 <acquire>
  empty = 0;
    80003c30:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c32:	0003c497          	auipc	s1,0x3c
    80003c36:	74648493          	addi	s1,s1,1862 # 80040378 <itable+0x18>
    80003c3a:	0003e697          	auipc	a3,0x3e
    80003c3e:	1ce68693          	addi	a3,a3,462 # 80041e08 <log>
    80003c42:	a039                	j	80003c50 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c44:	02090b63          	beqz	s2,80003c7a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c48:	08848493          	addi	s1,s1,136
    80003c4c:	02d48a63          	beq	s1,a3,80003c80 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c50:	449c                	lw	a5,8(s1)
    80003c52:	fef059e3          	blez	a5,80003c44 <iget+0x38>
    80003c56:	4098                	lw	a4,0(s1)
    80003c58:	ff3716e3          	bne	a4,s3,80003c44 <iget+0x38>
    80003c5c:	40d8                	lw	a4,4(s1)
    80003c5e:	ff4713e3          	bne	a4,s4,80003c44 <iget+0x38>
      ip->ref++;
    80003c62:	2785                	addiw	a5,a5,1
    80003c64:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c66:	0003c517          	auipc	a0,0x3c
    80003c6a:	6fa50513          	addi	a0,a0,1786 # 80040360 <itable>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	27a080e7          	jalr	634(ra) # 80000ee8 <release>
      return ip;
    80003c76:	8926                	mv	s2,s1
    80003c78:	a03d                	j	80003ca6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c7a:	f7f9                	bnez	a5,80003c48 <iget+0x3c>
    80003c7c:	8926                	mv	s2,s1
    80003c7e:	b7e9                	j	80003c48 <iget+0x3c>
  if(empty == 0)
    80003c80:	02090c63          	beqz	s2,80003cb8 <iget+0xac>
  ip->dev = dev;
    80003c84:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c88:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c8c:	4785                	li	a5,1
    80003c8e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c92:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c96:	0003c517          	auipc	a0,0x3c
    80003c9a:	6ca50513          	addi	a0,a0,1738 # 80040360 <itable>
    80003c9e:	ffffd097          	auipc	ra,0xffffd
    80003ca2:	24a080e7          	jalr	586(ra) # 80000ee8 <release>
}
    80003ca6:	854a                	mv	a0,s2
    80003ca8:	70a2                	ld	ra,40(sp)
    80003caa:	7402                	ld	s0,32(sp)
    80003cac:	64e2                	ld	s1,24(sp)
    80003cae:	6942                	ld	s2,16(sp)
    80003cb0:	69a2                	ld	s3,8(sp)
    80003cb2:	6a02                	ld	s4,0(sp)
    80003cb4:	6145                	addi	sp,sp,48
    80003cb6:	8082                	ret
    panic("iget: no inodes");
    80003cb8:	00005517          	auipc	a0,0x5
    80003cbc:	96850513          	addi	a0,a0,-1688 # 80008620 <syscalls+0x140>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	94c080e7          	jalr	-1716(ra) # 8000060c <panic>

0000000080003cc8 <fsinit>:
fsinit(int dev) {
    80003cc8:	7179                	addi	sp,sp,-48
    80003cca:	f406                	sd	ra,40(sp)
    80003ccc:	f022                	sd	s0,32(sp)
    80003cce:	ec26                	sd	s1,24(sp)
    80003cd0:	e84a                	sd	s2,16(sp)
    80003cd2:	e44e                	sd	s3,8(sp)
    80003cd4:	1800                	addi	s0,sp,48
    80003cd6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003cd8:	4585                	li	a1,1
    80003cda:	00000097          	auipc	ra,0x0
    80003cde:	a50080e7          	jalr	-1456(ra) # 8000372a <bread>
    80003ce2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ce4:	0003c997          	auipc	s3,0x3c
    80003ce8:	65c98993          	addi	s3,s3,1628 # 80040340 <sb>
    80003cec:	02000613          	li	a2,32
    80003cf0:	05850593          	addi	a1,a0,88
    80003cf4:	854e                	mv	a0,s3
    80003cf6:	ffffd097          	auipc	ra,0xffffd
    80003cfa:	296080e7          	jalr	662(ra) # 80000f8c <memmove>
  brelse(bp);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	b5a080e7          	jalr	-1190(ra) # 8000385a <brelse>
  if(sb.magic != FSMAGIC)
    80003d08:	0009a703          	lw	a4,0(s3)
    80003d0c:	102037b7          	lui	a5,0x10203
    80003d10:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d14:	02f71263          	bne	a4,a5,80003d38 <fsinit+0x70>
  initlog(dev, &sb);
    80003d18:	0003c597          	auipc	a1,0x3c
    80003d1c:	62858593          	addi	a1,a1,1576 # 80040340 <sb>
    80003d20:	854a                	mv	a0,s2
    80003d22:	00001097          	auipc	ra,0x1
    80003d26:	b40080e7          	jalr	-1216(ra) # 80004862 <initlog>
}
    80003d2a:	70a2                	ld	ra,40(sp)
    80003d2c:	7402                	ld	s0,32(sp)
    80003d2e:	64e2                	ld	s1,24(sp)
    80003d30:	6942                	ld	s2,16(sp)
    80003d32:	69a2                	ld	s3,8(sp)
    80003d34:	6145                	addi	sp,sp,48
    80003d36:	8082                	ret
    panic("invalid file system");
    80003d38:	00005517          	auipc	a0,0x5
    80003d3c:	8f850513          	addi	a0,a0,-1800 # 80008630 <syscalls+0x150>
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	8cc080e7          	jalr	-1844(ra) # 8000060c <panic>

0000000080003d48 <iinit>:
{
    80003d48:	7179                	addi	sp,sp,-48
    80003d4a:	f406                	sd	ra,40(sp)
    80003d4c:	f022                	sd	s0,32(sp)
    80003d4e:	ec26                	sd	s1,24(sp)
    80003d50:	e84a                	sd	s2,16(sp)
    80003d52:	e44e                	sd	s3,8(sp)
    80003d54:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d56:	00005597          	auipc	a1,0x5
    80003d5a:	8f258593          	addi	a1,a1,-1806 # 80008648 <syscalls+0x168>
    80003d5e:	0003c517          	auipc	a0,0x3c
    80003d62:	60250513          	addi	a0,a0,1538 # 80040360 <itable>
    80003d66:	ffffd097          	auipc	ra,0xffffd
    80003d6a:	03e080e7          	jalr	62(ra) # 80000da4 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d6e:	0003c497          	auipc	s1,0x3c
    80003d72:	61a48493          	addi	s1,s1,1562 # 80040388 <itable+0x28>
    80003d76:	0003e997          	auipc	s3,0x3e
    80003d7a:	0a298993          	addi	s3,s3,162 # 80041e18 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d7e:	00005917          	auipc	s2,0x5
    80003d82:	8d290913          	addi	s2,s2,-1838 # 80008650 <syscalls+0x170>
    80003d86:	85ca                	mv	a1,s2
    80003d88:	8526                	mv	a0,s1
    80003d8a:	00001097          	auipc	ra,0x1
    80003d8e:	e3a080e7          	jalr	-454(ra) # 80004bc4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d92:	08848493          	addi	s1,s1,136
    80003d96:	ff3498e3          	bne	s1,s3,80003d86 <iinit+0x3e>
}
    80003d9a:	70a2                	ld	ra,40(sp)
    80003d9c:	7402                	ld	s0,32(sp)
    80003d9e:	64e2                	ld	s1,24(sp)
    80003da0:	6942                	ld	s2,16(sp)
    80003da2:	69a2                	ld	s3,8(sp)
    80003da4:	6145                	addi	sp,sp,48
    80003da6:	8082                	ret

0000000080003da8 <ialloc>:
{
    80003da8:	715d                	addi	sp,sp,-80
    80003daa:	e486                	sd	ra,72(sp)
    80003dac:	e0a2                	sd	s0,64(sp)
    80003dae:	fc26                	sd	s1,56(sp)
    80003db0:	f84a                	sd	s2,48(sp)
    80003db2:	f44e                	sd	s3,40(sp)
    80003db4:	f052                	sd	s4,32(sp)
    80003db6:	ec56                	sd	s5,24(sp)
    80003db8:	e85a                	sd	s6,16(sp)
    80003dba:	e45e                	sd	s7,8(sp)
    80003dbc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dbe:	0003c717          	auipc	a4,0x3c
    80003dc2:	58e72703          	lw	a4,1422(a4) # 8004034c <sb+0xc>
    80003dc6:	4785                	li	a5,1
    80003dc8:	04e7fa63          	bgeu	a5,a4,80003e1c <ialloc+0x74>
    80003dcc:	8aaa                	mv	s5,a0
    80003dce:	8bae                	mv	s7,a1
    80003dd0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003dd2:	0003ca17          	auipc	s4,0x3c
    80003dd6:	56ea0a13          	addi	s4,s4,1390 # 80040340 <sb>
    80003dda:	00048b1b          	sext.w	s6,s1
    80003dde:	0044d793          	srli	a5,s1,0x4
    80003de2:	018a2583          	lw	a1,24(s4)
    80003de6:	9dbd                	addw	a1,a1,a5
    80003de8:	8556                	mv	a0,s5
    80003dea:	00000097          	auipc	ra,0x0
    80003dee:	940080e7          	jalr	-1728(ra) # 8000372a <bread>
    80003df2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003df4:	05850993          	addi	s3,a0,88
    80003df8:	00f4f793          	andi	a5,s1,15
    80003dfc:	079a                	slli	a5,a5,0x6
    80003dfe:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e00:	00099783          	lh	a5,0(s3)
    80003e04:	c3a1                	beqz	a5,80003e44 <ialloc+0x9c>
    brelse(bp);
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	a54080e7          	jalr	-1452(ra) # 8000385a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e0e:	0485                	addi	s1,s1,1
    80003e10:	00ca2703          	lw	a4,12(s4)
    80003e14:	0004879b          	sext.w	a5,s1
    80003e18:	fce7e1e3          	bltu	a5,a4,80003dda <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003e1c:	00005517          	auipc	a0,0x5
    80003e20:	83c50513          	addi	a0,a0,-1988 # 80008658 <syscalls+0x178>
    80003e24:	ffffd097          	auipc	ra,0xffffd
    80003e28:	832080e7          	jalr	-1998(ra) # 80000656 <printf>
  return 0;
    80003e2c:	4501                	li	a0,0
}
    80003e2e:	60a6                	ld	ra,72(sp)
    80003e30:	6406                	ld	s0,64(sp)
    80003e32:	74e2                	ld	s1,56(sp)
    80003e34:	7942                	ld	s2,48(sp)
    80003e36:	79a2                	ld	s3,40(sp)
    80003e38:	7a02                	ld	s4,32(sp)
    80003e3a:	6ae2                	ld	s5,24(sp)
    80003e3c:	6b42                	ld	s6,16(sp)
    80003e3e:	6ba2                	ld	s7,8(sp)
    80003e40:	6161                	addi	sp,sp,80
    80003e42:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e44:	04000613          	li	a2,64
    80003e48:	4581                	li	a1,0
    80003e4a:	854e                	mv	a0,s3
    80003e4c:	ffffd097          	auipc	ra,0xffffd
    80003e50:	0e4080e7          	jalr	228(ra) # 80000f30 <memset>
      dip->type = type;
    80003e54:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e58:	854a                	mv	a0,s2
    80003e5a:	00001097          	auipc	ra,0x1
    80003e5e:	c84080e7          	jalr	-892(ra) # 80004ade <log_write>
      brelse(bp);
    80003e62:	854a                	mv	a0,s2
    80003e64:	00000097          	auipc	ra,0x0
    80003e68:	9f6080e7          	jalr	-1546(ra) # 8000385a <brelse>
      return iget(dev, inum);
    80003e6c:	85da                	mv	a1,s6
    80003e6e:	8556                	mv	a0,s5
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	d9c080e7          	jalr	-612(ra) # 80003c0c <iget>
    80003e78:	bf5d                	j	80003e2e <ialloc+0x86>

0000000080003e7a <iupdate>:
{
    80003e7a:	1101                	addi	sp,sp,-32
    80003e7c:	ec06                	sd	ra,24(sp)
    80003e7e:	e822                	sd	s0,16(sp)
    80003e80:	e426                	sd	s1,8(sp)
    80003e82:	e04a                	sd	s2,0(sp)
    80003e84:	1000                	addi	s0,sp,32
    80003e86:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e88:	415c                	lw	a5,4(a0)
    80003e8a:	0047d79b          	srliw	a5,a5,0x4
    80003e8e:	0003c597          	auipc	a1,0x3c
    80003e92:	4ca5a583          	lw	a1,1226(a1) # 80040358 <sb+0x18>
    80003e96:	9dbd                	addw	a1,a1,a5
    80003e98:	4108                	lw	a0,0(a0)
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	890080e7          	jalr	-1904(ra) # 8000372a <bread>
    80003ea2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ea4:	05850793          	addi	a5,a0,88
    80003ea8:	40c8                	lw	a0,4(s1)
    80003eaa:	893d                	andi	a0,a0,15
    80003eac:	051a                	slli	a0,a0,0x6
    80003eae:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003eb0:	04449703          	lh	a4,68(s1)
    80003eb4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003eb8:	04649703          	lh	a4,70(s1)
    80003ebc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ec0:	04849703          	lh	a4,72(s1)
    80003ec4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003ec8:	04a49703          	lh	a4,74(s1)
    80003ecc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ed0:	44f8                	lw	a4,76(s1)
    80003ed2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ed4:	03400613          	li	a2,52
    80003ed8:	05048593          	addi	a1,s1,80
    80003edc:	0531                	addi	a0,a0,12
    80003ede:	ffffd097          	auipc	ra,0xffffd
    80003ee2:	0ae080e7          	jalr	174(ra) # 80000f8c <memmove>
  log_write(bp);
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	00001097          	auipc	ra,0x1
    80003eec:	bf6080e7          	jalr	-1034(ra) # 80004ade <log_write>
  brelse(bp);
    80003ef0:	854a                	mv	a0,s2
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	968080e7          	jalr	-1688(ra) # 8000385a <brelse>
}
    80003efa:	60e2                	ld	ra,24(sp)
    80003efc:	6442                	ld	s0,16(sp)
    80003efe:	64a2                	ld	s1,8(sp)
    80003f00:	6902                	ld	s2,0(sp)
    80003f02:	6105                	addi	sp,sp,32
    80003f04:	8082                	ret

0000000080003f06 <idup>:
{
    80003f06:	1101                	addi	sp,sp,-32
    80003f08:	ec06                	sd	ra,24(sp)
    80003f0a:	e822                	sd	s0,16(sp)
    80003f0c:	e426                	sd	s1,8(sp)
    80003f0e:	1000                	addi	s0,sp,32
    80003f10:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f12:	0003c517          	auipc	a0,0x3c
    80003f16:	44e50513          	addi	a0,a0,1102 # 80040360 <itable>
    80003f1a:	ffffd097          	auipc	ra,0xffffd
    80003f1e:	f1a080e7          	jalr	-230(ra) # 80000e34 <acquire>
  ip->ref++;
    80003f22:	449c                	lw	a5,8(s1)
    80003f24:	2785                	addiw	a5,a5,1
    80003f26:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f28:	0003c517          	auipc	a0,0x3c
    80003f2c:	43850513          	addi	a0,a0,1080 # 80040360 <itable>
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	fb8080e7          	jalr	-72(ra) # 80000ee8 <release>
}
    80003f38:	8526                	mv	a0,s1
    80003f3a:	60e2                	ld	ra,24(sp)
    80003f3c:	6442                	ld	s0,16(sp)
    80003f3e:	64a2                	ld	s1,8(sp)
    80003f40:	6105                	addi	sp,sp,32
    80003f42:	8082                	ret

0000000080003f44 <ilock>:
{
    80003f44:	1101                	addi	sp,sp,-32
    80003f46:	ec06                	sd	ra,24(sp)
    80003f48:	e822                	sd	s0,16(sp)
    80003f4a:	e426                	sd	s1,8(sp)
    80003f4c:	e04a                	sd	s2,0(sp)
    80003f4e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f50:	c115                	beqz	a0,80003f74 <ilock+0x30>
    80003f52:	84aa                	mv	s1,a0
    80003f54:	451c                	lw	a5,8(a0)
    80003f56:	00f05f63          	blez	a5,80003f74 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f5a:	0541                	addi	a0,a0,16
    80003f5c:	00001097          	auipc	ra,0x1
    80003f60:	ca2080e7          	jalr	-862(ra) # 80004bfe <acquiresleep>
  if(ip->valid == 0){
    80003f64:	40bc                	lw	a5,64(s1)
    80003f66:	cf99                	beqz	a5,80003f84 <ilock+0x40>
}
    80003f68:	60e2                	ld	ra,24(sp)
    80003f6a:	6442                	ld	s0,16(sp)
    80003f6c:	64a2                	ld	s1,8(sp)
    80003f6e:	6902                	ld	s2,0(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret
    panic("ilock");
    80003f74:	00004517          	auipc	a0,0x4
    80003f78:	6fc50513          	addi	a0,a0,1788 # 80008670 <syscalls+0x190>
    80003f7c:	ffffc097          	auipc	ra,0xffffc
    80003f80:	690080e7          	jalr	1680(ra) # 8000060c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f84:	40dc                	lw	a5,4(s1)
    80003f86:	0047d79b          	srliw	a5,a5,0x4
    80003f8a:	0003c597          	auipc	a1,0x3c
    80003f8e:	3ce5a583          	lw	a1,974(a1) # 80040358 <sb+0x18>
    80003f92:	9dbd                	addw	a1,a1,a5
    80003f94:	4088                	lw	a0,0(s1)
    80003f96:	fffff097          	auipc	ra,0xfffff
    80003f9a:	794080e7          	jalr	1940(ra) # 8000372a <bread>
    80003f9e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fa0:	05850593          	addi	a1,a0,88
    80003fa4:	40dc                	lw	a5,4(s1)
    80003fa6:	8bbd                	andi	a5,a5,15
    80003fa8:	079a                	slli	a5,a5,0x6
    80003faa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003fac:	00059783          	lh	a5,0(a1)
    80003fb0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003fb4:	00259783          	lh	a5,2(a1)
    80003fb8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003fbc:	00459783          	lh	a5,4(a1)
    80003fc0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003fc4:	00659783          	lh	a5,6(a1)
    80003fc8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fcc:	459c                	lw	a5,8(a1)
    80003fce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fd0:	03400613          	li	a2,52
    80003fd4:	05b1                	addi	a1,a1,12
    80003fd6:	05048513          	addi	a0,s1,80
    80003fda:	ffffd097          	auipc	ra,0xffffd
    80003fde:	fb2080e7          	jalr	-78(ra) # 80000f8c <memmove>
    brelse(bp);
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	00000097          	auipc	ra,0x0
    80003fe8:	876080e7          	jalr	-1930(ra) # 8000385a <brelse>
    ip->valid = 1;
    80003fec:	4785                	li	a5,1
    80003fee:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ff0:	04449783          	lh	a5,68(s1)
    80003ff4:	fbb5                	bnez	a5,80003f68 <ilock+0x24>
      panic("ilock: no type");
    80003ff6:	00004517          	auipc	a0,0x4
    80003ffa:	68250513          	addi	a0,a0,1666 # 80008678 <syscalls+0x198>
    80003ffe:	ffffc097          	auipc	ra,0xffffc
    80004002:	60e080e7          	jalr	1550(ra) # 8000060c <panic>

0000000080004006 <iunlock>:
{
    80004006:	1101                	addi	sp,sp,-32
    80004008:	ec06                	sd	ra,24(sp)
    8000400a:	e822                	sd	s0,16(sp)
    8000400c:	e426                	sd	s1,8(sp)
    8000400e:	e04a                	sd	s2,0(sp)
    80004010:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004012:	c905                	beqz	a0,80004042 <iunlock+0x3c>
    80004014:	84aa                	mv	s1,a0
    80004016:	01050913          	addi	s2,a0,16
    8000401a:	854a                	mv	a0,s2
    8000401c:	00001097          	auipc	ra,0x1
    80004020:	c7c080e7          	jalr	-900(ra) # 80004c98 <holdingsleep>
    80004024:	cd19                	beqz	a0,80004042 <iunlock+0x3c>
    80004026:	449c                	lw	a5,8(s1)
    80004028:	00f05d63          	blez	a5,80004042 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000402c:	854a                	mv	a0,s2
    8000402e:	00001097          	auipc	ra,0x1
    80004032:	c26080e7          	jalr	-986(ra) # 80004c54 <releasesleep>
}
    80004036:	60e2                	ld	ra,24(sp)
    80004038:	6442                	ld	s0,16(sp)
    8000403a:	64a2                	ld	s1,8(sp)
    8000403c:	6902                	ld	s2,0(sp)
    8000403e:	6105                	addi	sp,sp,32
    80004040:	8082                	ret
    panic("iunlock");
    80004042:	00004517          	auipc	a0,0x4
    80004046:	64650513          	addi	a0,a0,1606 # 80008688 <syscalls+0x1a8>
    8000404a:	ffffc097          	auipc	ra,0xffffc
    8000404e:	5c2080e7          	jalr	1474(ra) # 8000060c <panic>

0000000080004052 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004052:	7179                	addi	sp,sp,-48
    80004054:	f406                	sd	ra,40(sp)
    80004056:	f022                	sd	s0,32(sp)
    80004058:	ec26                	sd	s1,24(sp)
    8000405a:	e84a                	sd	s2,16(sp)
    8000405c:	e44e                	sd	s3,8(sp)
    8000405e:	e052                	sd	s4,0(sp)
    80004060:	1800                	addi	s0,sp,48
    80004062:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004064:	05050493          	addi	s1,a0,80
    80004068:	08050913          	addi	s2,a0,128
    8000406c:	a021                	j	80004074 <itrunc+0x22>
    8000406e:	0491                	addi	s1,s1,4
    80004070:	01248d63          	beq	s1,s2,8000408a <itrunc+0x38>
    if(ip->addrs[i]){
    80004074:	408c                	lw	a1,0(s1)
    80004076:	dde5                	beqz	a1,8000406e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004078:	0009a503          	lw	a0,0(s3)
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	8f4080e7          	jalr	-1804(ra) # 80003970 <bfree>
      ip->addrs[i] = 0;
    80004084:	0004a023          	sw	zero,0(s1)
    80004088:	b7dd                	j	8000406e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000408a:	0809a583          	lw	a1,128(s3)
    8000408e:	e185                	bnez	a1,800040ae <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004090:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004094:	854e                	mv	a0,s3
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	de4080e7          	jalr	-540(ra) # 80003e7a <iupdate>
}
    8000409e:	70a2                	ld	ra,40(sp)
    800040a0:	7402                	ld	s0,32(sp)
    800040a2:	64e2                	ld	s1,24(sp)
    800040a4:	6942                	ld	s2,16(sp)
    800040a6:	69a2                	ld	s3,8(sp)
    800040a8:	6a02                	ld	s4,0(sp)
    800040aa:	6145                	addi	sp,sp,48
    800040ac:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800040ae:	0009a503          	lw	a0,0(s3)
    800040b2:	fffff097          	auipc	ra,0xfffff
    800040b6:	678080e7          	jalr	1656(ra) # 8000372a <bread>
    800040ba:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800040bc:	05850493          	addi	s1,a0,88
    800040c0:	45850913          	addi	s2,a0,1112
    800040c4:	a021                	j	800040cc <itrunc+0x7a>
    800040c6:	0491                	addi	s1,s1,4
    800040c8:	01248b63          	beq	s1,s2,800040de <itrunc+0x8c>
      if(a[j])
    800040cc:	408c                	lw	a1,0(s1)
    800040ce:	dde5                	beqz	a1,800040c6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800040d0:	0009a503          	lw	a0,0(s3)
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	89c080e7          	jalr	-1892(ra) # 80003970 <bfree>
    800040dc:	b7ed                	j	800040c6 <itrunc+0x74>
    brelse(bp);
    800040de:	8552                	mv	a0,s4
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	77a080e7          	jalr	1914(ra) # 8000385a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040e8:	0809a583          	lw	a1,128(s3)
    800040ec:	0009a503          	lw	a0,0(s3)
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	880080e7          	jalr	-1920(ra) # 80003970 <bfree>
    ip->addrs[NDIRECT] = 0;
    800040f8:	0809a023          	sw	zero,128(s3)
    800040fc:	bf51                	j	80004090 <itrunc+0x3e>

00000000800040fe <iput>:
{
    800040fe:	1101                	addi	sp,sp,-32
    80004100:	ec06                	sd	ra,24(sp)
    80004102:	e822                	sd	s0,16(sp)
    80004104:	e426                	sd	s1,8(sp)
    80004106:	e04a                	sd	s2,0(sp)
    80004108:	1000                	addi	s0,sp,32
    8000410a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000410c:	0003c517          	auipc	a0,0x3c
    80004110:	25450513          	addi	a0,a0,596 # 80040360 <itable>
    80004114:	ffffd097          	auipc	ra,0xffffd
    80004118:	d20080e7          	jalr	-736(ra) # 80000e34 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000411c:	4498                	lw	a4,8(s1)
    8000411e:	4785                	li	a5,1
    80004120:	02f70363          	beq	a4,a5,80004146 <iput+0x48>
  ip->ref--;
    80004124:	449c                	lw	a5,8(s1)
    80004126:	37fd                	addiw	a5,a5,-1
    80004128:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000412a:	0003c517          	auipc	a0,0x3c
    8000412e:	23650513          	addi	a0,a0,566 # 80040360 <itable>
    80004132:	ffffd097          	auipc	ra,0xffffd
    80004136:	db6080e7          	jalr	-586(ra) # 80000ee8 <release>
}
    8000413a:	60e2                	ld	ra,24(sp)
    8000413c:	6442                	ld	s0,16(sp)
    8000413e:	64a2                	ld	s1,8(sp)
    80004140:	6902                	ld	s2,0(sp)
    80004142:	6105                	addi	sp,sp,32
    80004144:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004146:	40bc                	lw	a5,64(s1)
    80004148:	dff1                	beqz	a5,80004124 <iput+0x26>
    8000414a:	04a49783          	lh	a5,74(s1)
    8000414e:	fbf9                	bnez	a5,80004124 <iput+0x26>
    acquiresleep(&ip->lock);
    80004150:	01048913          	addi	s2,s1,16
    80004154:	854a                	mv	a0,s2
    80004156:	00001097          	auipc	ra,0x1
    8000415a:	aa8080e7          	jalr	-1368(ra) # 80004bfe <acquiresleep>
    release(&itable.lock);
    8000415e:	0003c517          	auipc	a0,0x3c
    80004162:	20250513          	addi	a0,a0,514 # 80040360 <itable>
    80004166:	ffffd097          	auipc	ra,0xffffd
    8000416a:	d82080e7          	jalr	-638(ra) # 80000ee8 <release>
    itrunc(ip);
    8000416e:	8526                	mv	a0,s1
    80004170:	00000097          	auipc	ra,0x0
    80004174:	ee2080e7          	jalr	-286(ra) # 80004052 <itrunc>
    ip->type = 0;
    80004178:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000417c:	8526                	mv	a0,s1
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	cfc080e7          	jalr	-772(ra) # 80003e7a <iupdate>
    ip->valid = 0;
    80004186:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000418a:	854a                	mv	a0,s2
    8000418c:	00001097          	auipc	ra,0x1
    80004190:	ac8080e7          	jalr	-1336(ra) # 80004c54 <releasesleep>
    acquire(&itable.lock);
    80004194:	0003c517          	auipc	a0,0x3c
    80004198:	1cc50513          	addi	a0,a0,460 # 80040360 <itable>
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	c98080e7          	jalr	-872(ra) # 80000e34 <acquire>
    800041a4:	b741                	j	80004124 <iput+0x26>

00000000800041a6 <iunlockput>:
{
    800041a6:	1101                	addi	sp,sp,-32
    800041a8:	ec06                	sd	ra,24(sp)
    800041aa:	e822                	sd	s0,16(sp)
    800041ac:	e426                	sd	s1,8(sp)
    800041ae:	1000                	addi	s0,sp,32
    800041b0:	84aa                	mv	s1,a0
  iunlock(ip);
    800041b2:	00000097          	auipc	ra,0x0
    800041b6:	e54080e7          	jalr	-428(ra) # 80004006 <iunlock>
  iput(ip);
    800041ba:	8526                	mv	a0,s1
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	f42080e7          	jalr	-190(ra) # 800040fe <iput>
}
    800041c4:	60e2                	ld	ra,24(sp)
    800041c6:	6442                	ld	s0,16(sp)
    800041c8:	64a2                	ld	s1,8(sp)
    800041ca:	6105                	addi	sp,sp,32
    800041cc:	8082                	ret

00000000800041ce <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041ce:	1141                	addi	sp,sp,-16
    800041d0:	e422                	sd	s0,8(sp)
    800041d2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041d4:	411c                	lw	a5,0(a0)
    800041d6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041d8:	415c                	lw	a5,4(a0)
    800041da:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041dc:	04451783          	lh	a5,68(a0)
    800041e0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041e4:	04a51783          	lh	a5,74(a0)
    800041e8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041ec:	04c56783          	lwu	a5,76(a0)
    800041f0:	e99c                	sd	a5,16(a1)
}
    800041f2:	6422                	ld	s0,8(sp)
    800041f4:	0141                	addi	sp,sp,16
    800041f6:	8082                	ret

00000000800041f8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041f8:	457c                	lw	a5,76(a0)
    800041fa:	0ed7e963          	bltu	a5,a3,800042ec <readi+0xf4>
{
    800041fe:	7159                	addi	sp,sp,-112
    80004200:	f486                	sd	ra,104(sp)
    80004202:	f0a2                	sd	s0,96(sp)
    80004204:	eca6                	sd	s1,88(sp)
    80004206:	e8ca                	sd	s2,80(sp)
    80004208:	e4ce                	sd	s3,72(sp)
    8000420a:	e0d2                	sd	s4,64(sp)
    8000420c:	fc56                	sd	s5,56(sp)
    8000420e:	f85a                	sd	s6,48(sp)
    80004210:	f45e                	sd	s7,40(sp)
    80004212:	f062                	sd	s8,32(sp)
    80004214:	ec66                	sd	s9,24(sp)
    80004216:	e86a                	sd	s10,16(sp)
    80004218:	e46e                	sd	s11,8(sp)
    8000421a:	1880                	addi	s0,sp,112
    8000421c:	8b2a                	mv	s6,a0
    8000421e:	8bae                	mv	s7,a1
    80004220:	8a32                	mv	s4,a2
    80004222:	84b6                	mv	s1,a3
    80004224:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004226:	9f35                	addw	a4,a4,a3
    return 0;
    80004228:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000422a:	0ad76063          	bltu	a4,a3,800042ca <readi+0xd2>
  if(off + n > ip->size)
    8000422e:	00e7f463          	bgeu	a5,a4,80004236 <readi+0x3e>
    n = ip->size - off;
    80004232:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004236:	0a0a8963          	beqz	s5,800042e8 <readi+0xf0>
    8000423a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000423c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004240:	5c7d                	li	s8,-1
    80004242:	a82d                	j	8000427c <readi+0x84>
    80004244:	020d1d93          	slli	s11,s10,0x20
    80004248:	020ddd93          	srli	s11,s11,0x20
    8000424c:	05890793          	addi	a5,s2,88
    80004250:	86ee                	mv	a3,s11
    80004252:	963e                	add	a2,a2,a5
    80004254:	85d2                	mv	a1,s4
    80004256:	855e                	mv	a0,s7
    80004258:	ffffe097          	auipc	ra,0xffffe
    8000425c:	79c080e7          	jalr	1948(ra) # 800029f4 <either_copyout>
    80004260:	05850d63          	beq	a0,s8,800042ba <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004264:	854a                	mv	a0,s2
    80004266:	fffff097          	auipc	ra,0xfffff
    8000426a:	5f4080e7          	jalr	1524(ra) # 8000385a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000426e:	013d09bb          	addw	s3,s10,s3
    80004272:	009d04bb          	addw	s1,s10,s1
    80004276:	9a6e                	add	s4,s4,s11
    80004278:	0559f763          	bgeu	s3,s5,800042c6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000427c:	00a4d59b          	srliw	a1,s1,0xa
    80004280:	855a                	mv	a0,s6
    80004282:	00000097          	auipc	ra,0x0
    80004286:	8a2080e7          	jalr	-1886(ra) # 80003b24 <bmap>
    8000428a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000428e:	cd85                	beqz	a1,800042c6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004290:	000b2503          	lw	a0,0(s6)
    80004294:	fffff097          	auipc	ra,0xfffff
    80004298:	496080e7          	jalr	1174(ra) # 8000372a <bread>
    8000429c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000429e:	3ff4f613          	andi	a2,s1,1023
    800042a2:	40cc87bb          	subw	a5,s9,a2
    800042a6:	413a873b          	subw	a4,s5,s3
    800042aa:	8d3e                	mv	s10,a5
    800042ac:	2781                	sext.w	a5,a5
    800042ae:	0007069b          	sext.w	a3,a4
    800042b2:	f8f6f9e3          	bgeu	a3,a5,80004244 <readi+0x4c>
    800042b6:	8d3a                	mv	s10,a4
    800042b8:	b771                	j	80004244 <readi+0x4c>
      brelse(bp);
    800042ba:	854a                	mv	a0,s2
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	59e080e7          	jalr	1438(ra) # 8000385a <brelse>
      tot = -1;
    800042c4:	59fd                	li	s3,-1
  }
  return tot;
    800042c6:	0009851b          	sext.w	a0,s3
}
    800042ca:	70a6                	ld	ra,104(sp)
    800042cc:	7406                	ld	s0,96(sp)
    800042ce:	64e6                	ld	s1,88(sp)
    800042d0:	6946                	ld	s2,80(sp)
    800042d2:	69a6                	ld	s3,72(sp)
    800042d4:	6a06                	ld	s4,64(sp)
    800042d6:	7ae2                	ld	s5,56(sp)
    800042d8:	7b42                	ld	s6,48(sp)
    800042da:	7ba2                	ld	s7,40(sp)
    800042dc:	7c02                	ld	s8,32(sp)
    800042de:	6ce2                	ld	s9,24(sp)
    800042e0:	6d42                	ld	s10,16(sp)
    800042e2:	6da2                	ld	s11,8(sp)
    800042e4:	6165                	addi	sp,sp,112
    800042e6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042e8:	89d6                	mv	s3,s5
    800042ea:	bff1                	j	800042c6 <readi+0xce>
    return 0;
    800042ec:	4501                	li	a0,0
}
    800042ee:	8082                	ret

00000000800042f0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042f0:	457c                	lw	a5,76(a0)
    800042f2:	10d7e863          	bltu	a5,a3,80004402 <writei+0x112>
{
    800042f6:	7159                	addi	sp,sp,-112
    800042f8:	f486                	sd	ra,104(sp)
    800042fa:	f0a2                	sd	s0,96(sp)
    800042fc:	eca6                	sd	s1,88(sp)
    800042fe:	e8ca                	sd	s2,80(sp)
    80004300:	e4ce                	sd	s3,72(sp)
    80004302:	e0d2                	sd	s4,64(sp)
    80004304:	fc56                	sd	s5,56(sp)
    80004306:	f85a                	sd	s6,48(sp)
    80004308:	f45e                	sd	s7,40(sp)
    8000430a:	f062                	sd	s8,32(sp)
    8000430c:	ec66                	sd	s9,24(sp)
    8000430e:	e86a                	sd	s10,16(sp)
    80004310:	e46e                	sd	s11,8(sp)
    80004312:	1880                	addi	s0,sp,112
    80004314:	8aaa                	mv	s5,a0
    80004316:	8bae                	mv	s7,a1
    80004318:	8a32                	mv	s4,a2
    8000431a:	8936                	mv	s2,a3
    8000431c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000431e:	00e687bb          	addw	a5,a3,a4
    80004322:	0ed7e263          	bltu	a5,a3,80004406 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004326:	00043737          	lui	a4,0x43
    8000432a:	0ef76063          	bltu	a4,a5,8000440a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000432e:	0c0b0863          	beqz	s6,800043fe <writei+0x10e>
    80004332:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004334:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004338:	5c7d                	li	s8,-1
    8000433a:	a091                	j	8000437e <writei+0x8e>
    8000433c:	020d1d93          	slli	s11,s10,0x20
    80004340:	020ddd93          	srli	s11,s11,0x20
    80004344:	05848793          	addi	a5,s1,88
    80004348:	86ee                	mv	a3,s11
    8000434a:	8652                	mv	a2,s4
    8000434c:	85de                	mv	a1,s7
    8000434e:	953e                	add	a0,a0,a5
    80004350:	ffffe097          	auipc	ra,0xffffe
    80004354:	6fa080e7          	jalr	1786(ra) # 80002a4a <either_copyin>
    80004358:	07850263          	beq	a0,s8,800043bc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000435c:	8526                	mv	a0,s1
    8000435e:	00000097          	auipc	ra,0x0
    80004362:	780080e7          	jalr	1920(ra) # 80004ade <log_write>
    brelse(bp);
    80004366:	8526                	mv	a0,s1
    80004368:	fffff097          	auipc	ra,0xfffff
    8000436c:	4f2080e7          	jalr	1266(ra) # 8000385a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004370:	013d09bb          	addw	s3,s10,s3
    80004374:	012d093b          	addw	s2,s10,s2
    80004378:	9a6e                	add	s4,s4,s11
    8000437a:	0569f663          	bgeu	s3,s6,800043c6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000437e:	00a9559b          	srliw	a1,s2,0xa
    80004382:	8556                	mv	a0,s5
    80004384:	fffff097          	auipc	ra,0xfffff
    80004388:	7a0080e7          	jalr	1952(ra) # 80003b24 <bmap>
    8000438c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004390:	c99d                	beqz	a1,800043c6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004392:	000aa503          	lw	a0,0(s5)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	394080e7          	jalr	916(ra) # 8000372a <bread>
    8000439e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043a0:	3ff97513          	andi	a0,s2,1023
    800043a4:	40ac87bb          	subw	a5,s9,a0
    800043a8:	413b073b          	subw	a4,s6,s3
    800043ac:	8d3e                	mv	s10,a5
    800043ae:	2781                	sext.w	a5,a5
    800043b0:	0007069b          	sext.w	a3,a4
    800043b4:	f8f6f4e3          	bgeu	a3,a5,8000433c <writei+0x4c>
    800043b8:	8d3a                	mv	s10,a4
    800043ba:	b749                	j	8000433c <writei+0x4c>
      brelse(bp);
    800043bc:	8526                	mv	a0,s1
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	49c080e7          	jalr	1180(ra) # 8000385a <brelse>
  }

  if(off > ip->size)
    800043c6:	04caa783          	lw	a5,76(s5)
    800043ca:	0127f463          	bgeu	a5,s2,800043d2 <writei+0xe2>
    ip->size = off;
    800043ce:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043d2:	8556                	mv	a0,s5
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	aa6080e7          	jalr	-1370(ra) # 80003e7a <iupdate>

  return tot;
    800043dc:	0009851b          	sext.w	a0,s3
}
    800043e0:	70a6                	ld	ra,104(sp)
    800043e2:	7406                	ld	s0,96(sp)
    800043e4:	64e6                	ld	s1,88(sp)
    800043e6:	6946                	ld	s2,80(sp)
    800043e8:	69a6                	ld	s3,72(sp)
    800043ea:	6a06                	ld	s4,64(sp)
    800043ec:	7ae2                	ld	s5,56(sp)
    800043ee:	7b42                	ld	s6,48(sp)
    800043f0:	7ba2                	ld	s7,40(sp)
    800043f2:	7c02                	ld	s8,32(sp)
    800043f4:	6ce2                	ld	s9,24(sp)
    800043f6:	6d42                	ld	s10,16(sp)
    800043f8:	6da2                	ld	s11,8(sp)
    800043fa:	6165                	addi	sp,sp,112
    800043fc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043fe:	89da                	mv	s3,s6
    80004400:	bfc9                	j	800043d2 <writei+0xe2>
    return -1;
    80004402:	557d                	li	a0,-1
}
    80004404:	8082                	ret
    return -1;
    80004406:	557d                	li	a0,-1
    80004408:	bfe1                	j	800043e0 <writei+0xf0>
    return -1;
    8000440a:	557d                	li	a0,-1
    8000440c:	bfd1                	j	800043e0 <writei+0xf0>

000000008000440e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000440e:	1141                	addi	sp,sp,-16
    80004410:	e406                	sd	ra,8(sp)
    80004412:	e022                	sd	s0,0(sp)
    80004414:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004416:	4639                	li	a2,14
    80004418:	ffffd097          	auipc	ra,0xffffd
    8000441c:	be8080e7          	jalr	-1048(ra) # 80001000 <strncmp>
}
    80004420:	60a2                	ld	ra,8(sp)
    80004422:	6402                	ld	s0,0(sp)
    80004424:	0141                	addi	sp,sp,16
    80004426:	8082                	ret

0000000080004428 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004428:	7139                	addi	sp,sp,-64
    8000442a:	fc06                	sd	ra,56(sp)
    8000442c:	f822                	sd	s0,48(sp)
    8000442e:	f426                	sd	s1,40(sp)
    80004430:	f04a                	sd	s2,32(sp)
    80004432:	ec4e                	sd	s3,24(sp)
    80004434:	e852                	sd	s4,16(sp)
    80004436:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004438:	04451703          	lh	a4,68(a0)
    8000443c:	4785                	li	a5,1
    8000443e:	00f71a63          	bne	a4,a5,80004452 <dirlookup+0x2a>
    80004442:	892a                	mv	s2,a0
    80004444:	89ae                	mv	s3,a1
    80004446:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004448:	457c                	lw	a5,76(a0)
    8000444a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000444c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000444e:	e79d                	bnez	a5,8000447c <dirlookup+0x54>
    80004450:	a8a5                	j	800044c8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004452:	00004517          	auipc	a0,0x4
    80004456:	23e50513          	addi	a0,a0,574 # 80008690 <syscalls+0x1b0>
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	1b2080e7          	jalr	434(ra) # 8000060c <panic>
      panic("dirlookup read");
    80004462:	00004517          	auipc	a0,0x4
    80004466:	24650513          	addi	a0,a0,582 # 800086a8 <syscalls+0x1c8>
    8000446a:	ffffc097          	auipc	ra,0xffffc
    8000446e:	1a2080e7          	jalr	418(ra) # 8000060c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004472:	24c1                	addiw	s1,s1,16
    80004474:	04c92783          	lw	a5,76(s2)
    80004478:	04f4f763          	bgeu	s1,a5,800044c6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000447c:	4741                	li	a4,16
    8000447e:	86a6                	mv	a3,s1
    80004480:	fc040613          	addi	a2,s0,-64
    80004484:	4581                	li	a1,0
    80004486:	854a                	mv	a0,s2
    80004488:	00000097          	auipc	ra,0x0
    8000448c:	d70080e7          	jalr	-656(ra) # 800041f8 <readi>
    80004490:	47c1                	li	a5,16
    80004492:	fcf518e3          	bne	a0,a5,80004462 <dirlookup+0x3a>
    if(de.inum == 0)
    80004496:	fc045783          	lhu	a5,-64(s0)
    8000449a:	dfe1                	beqz	a5,80004472 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000449c:	fc240593          	addi	a1,s0,-62
    800044a0:	854e                	mv	a0,s3
    800044a2:	00000097          	auipc	ra,0x0
    800044a6:	f6c080e7          	jalr	-148(ra) # 8000440e <namecmp>
    800044aa:	f561                	bnez	a0,80004472 <dirlookup+0x4a>
      if(poff)
    800044ac:	000a0463          	beqz	s4,800044b4 <dirlookup+0x8c>
        *poff = off;
    800044b0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800044b4:	fc045583          	lhu	a1,-64(s0)
    800044b8:	00092503          	lw	a0,0(s2)
    800044bc:	fffff097          	auipc	ra,0xfffff
    800044c0:	750080e7          	jalr	1872(ra) # 80003c0c <iget>
    800044c4:	a011                	j	800044c8 <dirlookup+0xa0>
  return 0;
    800044c6:	4501                	li	a0,0
}
    800044c8:	70e2                	ld	ra,56(sp)
    800044ca:	7442                	ld	s0,48(sp)
    800044cc:	74a2                	ld	s1,40(sp)
    800044ce:	7902                	ld	s2,32(sp)
    800044d0:	69e2                	ld	s3,24(sp)
    800044d2:	6a42                	ld	s4,16(sp)
    800044d4:	6121                	addi	sp,sp,64
    800044d6:	8082                	ret

00000000800044d8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044d8:	711d                	addi	sp,sp,-96
    800044da:	ec86                	sd	ra,88(sp)
    800044dc:	e8a2                	sd	s0,80(sp)
    800044de:	e4a6                	sd	s1,72(sp)
    800044e0:	e0ca                	sd	s2,64(sp)
    800044e2:	fc4e                	sd	s3,56(sp)
    800044e4:	f852                	sd	s4,48(sp)
    800044e6:	f456                	sd	s5,40(sp)
    800044e8:	f05a                	sd	s6,32(sp)
    800044ea:	ec5e                	sd	s7,24(sp)
    800044ec:	e862                	sd	s8,16(sp)
    800044ee:	e466                	sd	s9,8(sp)
    800044f0:	1080                	addi	s0,sp,96
    800044f2:	84aa                	mv	s1,a0
    800044f4:	8aae                	mv	s5,a1
    800044f6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044f8:	00054703          	lbu	a4,0(a0)
    800044fc:	02f00793          	li	a5,47
    80004500:	02f70363          	beq	a4,a5,80004526 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004504:	ffffd097          	auipc	ra,0xffffd
    80004508:	70c080e7          	jalr	1804(ra) # 80001c10 <myproc>
    8000450c:	15053503          	ld	a0,336(a0)
    80004510:	00000097          	auipc	ra,0x0
    80004514:	9f6080e7          	jalr	-1546(ra) # 80003f06 <idup>
    80004518:	89aa                	mv	s3,a0
  while(*path == '/')
    8000451a:	02f00913          	li	s2,47
  len = path - s;
    8000451e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004520:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004522:	4b85                	li	s7,1
    80004524:	a865                	j	800045dc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004526:	4585                	li	a1,1
    80004528:	4505                	li	a0,1
    8000452a:	fffff097          	auipc	ra,0xfffff
    8000452e:	6e2080e7          	jalr	1762(ra) # 80003c0c <iget>
    80004532:	89aa                	mv	s3,a0
    80004534:	b7dd                	j	8000451a <namex+0x42>
      iunlockput(ip);
    80004536:	854e                	mv	a0,s3
    80004538:	00000097          	auipc	ra,0x0
    8000453c:	c6e080e7          	jalr	-914(ra) # 800041a6 <iunlockput>
      return 0;
    80004540:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004542:	854e                	mv	a0,s3
    80004544:	60e6                	ld	ra,88(sp)
    80004546:	6446                	ld	s0,80(sp)
    80004548:	64a6                	ld	s1,72(sp)
    8000454a:	6906                	ld	s2,64(sp)
    8000454c:	79e2                	ld	s3,56(sp)
    8000454e:	7a42                	ld	s4,48(sp)
    80004550:	7aa2                	ld	s5,40(sp)
    80004552:	7b02                	ld	s6,32(sp)
    80004554:	6be2                	ld	s7,24(sp)
    80004556:	6c42                	ld	s8,16(sp)
    80004558:	6ca2                	ld	s9,8(sp)
    8000455a:	6125                	addi	sp,sp,96
    8000455c:	8082                	ret
      iunlock(ip);
    8000455e:	854e                	mv	a0,s3
    80004560:	00000097          	auipc	ra,0x0
    80004564:	aa6080e7          	jalr	-1370(ra) # 80004006 <iunlock>
      return ip;
    80004568:	bfe9                	j	80004542 <namex+0x6a>
      iunlockput(ip);
    8000456a:	854e                	mv	a0,s3
    8000456c:	00000097          	auipc	ra,0x0
    80004570:	c3a080e7          	jalr	-966(ra) # 800041a6 <iunlockput>
      return 0;
    80004574:	89e6                	mv	s3,s9
    80004576:	b7f1                	j	80004542 <namex+0x6a>
  len = path - s;
    80004578:	40b48633          	sub	a2,s1,a1
    8000457c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004580:	099c5463          	bge	s8,s9,80004608 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004584:	4639                	li	a2,14
    80004586:	8552                	mv	a0,s4
    80004588:	ffffd097          	auipc	ra,0xffffd
    8000458c:	a04080e7          	jalr	-1532(ra) # 80000f8c <memmove>
  while(*path == '/')
    80004590:	0004c783          	lbu	a5,0(s1)
    80004594:	01279763          	bne	a5,s2,800045a2 <namex+0xca>
    path++;
    80004598:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000459a:	0004c783          	lbu	a5,0(s1)
    8000459e:	ff278de3          	beq	a5,s2,80004598 <namex+0xc0>
    ilock(ip);
    800045a2:	854e                	mv	a0,s3
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	9a0080e7          	jalr	-1632(ra) # 80003f44 <ilock>
    if(ip->type != T_DIR){
    800045ac:	04499783          	lh	a5,68(s3)
    800045b0:	f97793e3          	bne	a5,s7,80004536 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800045b4:	000a8563          	beqz	s5,800045be <namex+0xe6>
    800045b8:	0004c783          	lbu	a5,0(s1)
    800045bc:	d3cd                	beqz	a5,8000455e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045be:	865a                	mv	a2,s6
    800045c0:	85d2                	mv	a1,s4
    800045c2:	854e                	mv	a0,s3
    800045c4:	00000097          	auipc	ra,0x0
    800045c8:	e64080e7          	jalr	-412(ra) # 80004428 <dirlookup>
    800045cc:	8caa                	mv	s9,a0
    800045ce:	dd51                	beqz	a0,8000456a <namex+0x92>
    iunlockput(ip);
    800045d0:	854e                	mv	a0,s3
    800045d2:	00000097          	auipc	ra,0x0
    800045d6:	bd4080e7          	jalr	-1068(ra) # 800041a6 <iunlockput>
    ip = next;
    800045da:	89e6                	mv	s3,s9
  while(*path == '/')
    800045dc:	0004c783          	lbu	a5,0(s1)
    800045e0:	05279763          	bne	a5,s2,8000462e <namex+0x156>
    path++;
    800045e4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045e6:	0004c783          	lbu	a5,0(s1)
    800045ea:	ff278de3          	beq	a5,s2,800045e4 <namex+0x10c>
  if(*path == 0)
    800045ee:	c79d                	beqz	a5,8000461c <namex+0x144>
    path++;
    800045f0:	85a6                	mv	a1,s1
  len = path - s;
    800045f2:	8cda                	mv	s9,s6
    800045f4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800045f6:	01278963          	beq	a5,s2,80004608 <namex+0x130>
    800045fa:	dfbd                	beqz	a5,80004578 <namex+0xa0>
    path++;
    800045fc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800045fe:	0004c783          	lbu	a5,0(s1)
    80004602:	ff279ce3          	bne	a5,s2,800045fa <namex+0x122>
    80004606:	bf8d                	j	80004578 <namex+0xa0>
    memmove(name, s, len);
    80004608:	2601                	sext.w	a2,a2
    8000460a:	8552                	mv	a0,s4
    8000460c:	ffffd097          	auipc	ra,0xffffd
    80004610:	980080e7          	jalr	-1664(ra) # 80000f8c <memmove>
    name[len] = 0;
    80004614:	9cd2                	add	s9,s9,s4
    80004616:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000461a:	bf9d                	j	80004590 <namex+0xb8>
  if(nameiparent){
    8000461c:	f20a83e3          	beqz	s5,80004542 <namex+0x6a>
    iput(ip);
    80004620:	854e                	mv	a0,s3
    80004622:	00000097          	auipc	ra,0x0
    80004626:	adc080e7          	jalr	-1316(ra) # 800040fe <iput>
    return 0;
    8000462a:	4981                	li	s3,0
    8000462c:	bf19                	j	80004542 <namex+0x6a>
  if(*path == 0)
    8000462e:	d7fd                	beqz	a5,8000461c <namex+0x144>
  while(*path != '/' && *path != 0)
    80004630:	0004c783          	lbu	a5,0(s1)
    80004634:	85a6                	mv	a1,s1
    80004636:	b7d1                	j	800045fa <namex+0x122>

0000000080004638 <dirlink>:
{
    80004638:	7139                	addi	sp,sp,-64
    8000463a:	fc06                	sd	ra,56(sp)
    8000463c:	f822                	sd	s0,48(sp)
    8000463e:	f426                	sd	s1,40(sp)
    80004640:	f04a                	sd	s2,32(sp)
    80004642:	ec4e                	sd	s3,24(sp)
    80004644:	e852                	sd	s4,16(sp)
    80004646:	0080                	addi	s0,sp,64
    80004648:	892a                	mv	s2,a0
    8000464a:	8a2e                	mv	s4,a1
    8000464c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000464e:	4601                	li	a2,0
    80004650:	00000097          	auipc	ra,0x0
    80004654:	dd8080e7          	jalr	-552(ra) # 80004428 <dirlookup>
    80004658:	e93d                	bnez	a0,800046ce <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000465a:	04c92483          	lw	s1,76(s2)
    8000465e:	c49d                	beqz	s1,8000468c <dirlink+0x54>
    80004660:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004662:	4741                	li	a4,16
    80004664:	86a6                	mv	a3,s1
    80004666:	fc040613          	addi	a2,s0,-64
    8000466a:	4581                	li	a1,0
    8000466c:	854a                	mv	a0,s2
    8000466e:	00000097          	auipc	ra,0x0
    80004672:	b8a080e7          	jalr	-1142(ra) # 800041f8 <readi>
    80004676:	47c1                	li	a5,16
    80004678:	06f51163          	bne	a0,a5,800046da <dirlink+0xa2>
    if(de.inum == 0)
    8000467c:	fc045783          	lhu	a5,-64(s0)
    80004680:	c791                	beqz	a5,8000468c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004682:	24c1                	addiw	s1,s1,16
    80004684:	04c92783          	lw	a5,76(s2)
    80004688:	fcf4ede3          	bltu	s1,a5,80004662 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000468c:	4639                	li	a2,14
    8000468e:	85d2                	mv	a1,s4
    80004690:	fc240513          	addi	a0,s0,-62
    80004694:	ffffd097          	auipc	ra,0xffffd
    80004698:	9a8080e7          	jalr	-1624(ra) # 8000103c <strncpy>
  de.inum = inum;
    8000469c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046a0:	4741                	li	a4,16
    800046a2:	86a6                	mv	a3,s1
    800046a4:	fc040613          	addi	a2,s0,-64
    800046a8:	4581                	li	a1,0
    800046aa:	854a                	mv	a0,s2
    800046ac:	00000097          	auipc	ra,0x0
    800046b0:	c44080e7          	jalr	-956(ra) # 800042f0 <writei>
    800046b4:	1541                	addi	a0,a0,-16
    800046b6:	00a03533          	snez	a0,a0
    800046ba:	40a00533          	neg	a0,a0
}
    800046be:	70e2                	ld	ra,56(sp)
    800046c0:	7442                	ld	s0,48(sp)
    800046c2:	74a2                	ld	s1,40(sp)
    800046c4:	7902                	ld	s2,32(sp)
    800046c6:	69e2                	ld	s3,24(sp)
    800046c8:	6a42                	ld	s4,16(sp)
    800046ca:	6121                	addi	sp,sp,64
    800046cc:	8082                	ret
    iput(ip);
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	a30080e7          	jalr	-1488(ra) # 800040fe <iput>
    return -1;
    800046d6:	557d                	li	a0,-1
    800046d8:	b7dd                	j	800046be <dirlink+0x86>
      panic("dirlink read");
    800046da:	00004517          	auipc	a0,0x4
    800046de:	fde50513          	addi	a0,a0,-34 # 800086b8 <syscalls+0x1d8>
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	f2a080e7          	jalr	-214(ra) # 8000060c <panic>

00000000800046ea <namei>:

struct inode*
namei(char *path)
{
    800046ea:	1101                	addi	sp,sp,-32
    800046ec:	ec06                	sd	ra,24(sp)
    800046ee:	e822                	sd	s0,16(sp)
    800046f0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800046f2:	fe040613          	addi	a2,s0,-32
    800046f6:	4581                	li	a1,0
    800046f8:	00000097          	auipc	ra,0x0
    800046fc:	de0080e7          	jalr	-544(ra) # 800044d8 <namex>
}
    80004700:	60e2                	ld	ra,24(sp)
    80004702:	6442                	ld	s0,16(sp)
    80004704:	6105                	addi	sp,sp,32
    80004706:	8082                	ret

0000000080004708 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004708:	1141                	addi	sp,sp,-16
    8000470a:	e406                	sd	ra,8(sp)
    8000470c:	e022                	sd	s0,0(sp)
    8000470e:	0800                	addi	s0,sp,16
    80004710:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004712:	4585                	li	a1,1
    80004714:	00000097          	auipc	ra,0x0
    80004718:	dc4080e7          	jalr	-572(ra) # 800044d8 <namex>
}
    8000471c:	60a2                	ld	ra,8(sp)
    8000471e:	6402                	ld	s0,0(sp)
    80004720:	0141                	addi	sp,sp,16
    80004722:	8082                	ret

0000000080004724 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004724:	1101                	addi	sp,sp,-32
    80004726:	ec06                	sd	ra,24(sp)
    80004728:	e822                	sd	s0,16(sp)
    8000472a:	e426                	sd	s1,8(sp)
    8000472c:	e04a                	sd	s2,0(sp)
    8000472e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004730:	0003d917          	auipc	s2,0x3d
    80004734:	6d890913          	addi	s2,s2,1752 # 80041e08 <log>
    80004738:	01892583          	lw	a1,24(s2)
    8000473c:	02892503          	lw	a0,40(s2)
    80004740:	fffff097          	auipc	ra,0xfffff
    80004744:	fea080e7          	jalr	-22(ra) # 8000372a <bread>
    80004748:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000474a:	02c92683          	lw	a3,44(s2)
    8000474e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004750:	02d05763          	blez	a3,8000477e <write_head+0x5a>
    80004754:	0003d797          	auipc	a5,0x3d
    80004758:	6e478793          	addi	a5,a5,1764 # 80041e38 <log+0x30>
    8000475c:	05c50713          	addi	a4,a0,92
    80004760:	36fd                	addiw	a3,a3,-1
    80004762:	1682                	slli	a3,a3,0x20
    80004764:	9281                	srli	a3,a3,0x20
    80004766:	068a                	slli	a3,a3,0x2
    80004768:	0003d617          	auipc	a2,0x3d
    8000476c:	6d460613          	addi	a2,a2,1748 # 80041e3c <log+0x34>
    80004770:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004772:	4390                	lw	a2,0(a5)
    80004774:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004776:	0791                	addi	a5,a5,4
    80004778:	0711                	addi	a4,a4,4
    8000477a:	fed79ce3          	bne	a5,a3,80004772 <write_head+0x4e>
  }
  bwrite(buf);
    8000477e:	8526                	mv	a0,s1
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	09c080e7          	jalr	156(ra) # 8000381c <bwrite>
  brelse(buf);
    80004788:	8526                	mv	a0,s1
    8000478a:	fffff097          	auipc	ra,0xfffff
    8000478e:	0d0080e7          	jalr	208(ra) # 8000385a <brelse>
}
    80004792:	60e2                	ld	ra,24(sp)
    80004794:	6442                	ld	s0,16(sp)
    80004796:	64a2                	ld	s1,8(sp)
    80004798:	6902                	ld	s2,0(sp)
    8000479a:	6105                	addi	sp,sp,32
    8000479c:	8082                	ret

000000008000479e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000479e:	0003d797          	auipc	a5,0x3d
    800047a2:	6967a783          	lw	a5,1686(a5) # 80041e34 <log+0x2c>
    800047a6:	0af05d63          	blez	a5,80004860 <install_trans+0xc2>
{
    800047aa:	7139                	addi	sp,sp,-64
    800047ac:	fc06                	sd	ra,56(sp)
    800047ae:	f822                	sd	s0,48(sp)
    800047b0:	f426                	sd	s1,40(sp)
    800047b2:	f04a                	sd	s2,32(sp)
    800047b4:	ec4e                	sd	s3,24(sp)
    800047b6:	e852                	sd	s4,16(sp)
    800047b8:	e456                	sd	s5,8(sp)
    800047ba:	e05a                	sd	s6,0(sp)
    800047bc:	0080                	addi	s0,sp,64
    800047be:	8b2a                	mv	s6,a0
    800047c0:	0003da97          	auipc	s5,0x3d
    800047c4:	678a8a93          	addi	s5,s5,1656 # 80041e38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047c8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047ca:	0003d997          	auipc	s3,0x3d
    800047ce:	63e98993          	addi	s3,s3,1598 # 80041e08 <log>
    800047d2:	a00d                	j	800047f4 <install_trans+0x56>
    brelse(lbuf);
    800047d4:	854a                	mv	a0,s2
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	084080e7          	jalr	132(ra) # 8000385a <brelse>
    brelse(dbuf);
    800047de:	8526                	mv	a0,s1
    800047e0:	fffff097          	auipc	ra,0xfffff
    800047e4:	07a080e7          	jalr	122(ra) # 8000385a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047e8:	2a05                	addiw	s4,s4,1
    800047ea:	0a91                	addi	s5,s5,4
    800047ec:	02c9a783          	lw	a5,44(s3)
    800047f0:	04fa5e63          	bge	s4,a5,8000484c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047f4:	0189a583          	lw	a1,24(s3)
    800047f8:	014585bb          	addw	a1,a1,s4
    800047fc:	2585                	addiw	a1,a1,1
    800047fe:	0289a503          	lw	a0,40(s3)
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	f28080e7          	jalr	-216(ra) # 8000372a <bread>
    8000480a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000480c:	000aa583          	lw	a1,0(s5)
    80004810:	0289a503          	lw	a0,40(s3)
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	f16080e7          	jalr	-234(ra) # 8000372a <bread>
    8000481c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000481e:	40000613          	li	a2,1024
    80004822:	05890593          	addi	a1,s2,88
    80004826:	05850513          	addi	a0,a0,88
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	762080e7          	jalr	1890(ra) # 80000f8c <memmove>
    bwrite(dbuf);  // write dst to disk
    80004832:	8526                	mv	a0,s1
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	fe8080e7          	jalr	-24(ra) # 8000381c <bwrite>
    if(recovering == 0)
    8000483c:	f80b1ce3          	bnez	s6,800047d4 <install_trans+0x36>
      bunpin(dbuf);
    80004840:	8526                	mv	a0,s1
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	0f2080e7          	jalr	242(ra) # 80003934 <bunpin>
    8000484a:	b769                	j	800047d4 <install_trans+0x36>
}
    8000484c:	70e2                	ld	ra,56(sp)
    8000484e:	7442                	ld	s0,48(sp)
    80004850:	74a2                	ld	s1,40(sp)
    80004852:	7902                	ld	s2,32(sp)
    80004854:	69e2                	ld	s3,24(sp)
    80004856:	6a42                	ld	s4,16(sp)
    80004858:	6aa2                	ld	s5,8(sp)
    8000485a:	6b02                	ld	s6,0(sp)
    8000485c:	6121                	addi	sp,sp,64
    8000485e:	8082                	ret
    80004860:	8082                	ret

0000000080004862 <initlog>:
{
    80004862:	7179                	addi	sp,sp,-48
    80004864:	f406                	sd	ra,40(sp)
    80004866:	f022                	sd	s0,32(sp)
    80004868:	ec26                	sd	s1,24(sp)
    8000486a:	e84a                	sd	s2,16(sp)
    8000486c:	e44e                	sd	s3,8(sp)
    8000486e:	1800                	addi	s0,sp,48
    80004870:	892a                	mv	s2,a0
    80004872:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004874:	0003d497          	auipc	s1,0x3d
    80004878:	59448493          	addi	s1,s1,1428 # 80041e08 <log>
    8000487c:	00004597          	auipc	a1,0x4
    80004880:	e4c58593          	addi	a1,a1,-436 # 800086c8 <syscalls+0x1e8>
    80004884:	8526                	mv	a0,s1
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	51e080e7          	jalr	1310(ra) # 80000da4 <initlock>
  log.start = sb->logstart;
    8000488e:	0149a583          	lw	a1,20(s3)
    80004892:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004894:	0109a783          	lw	a5,16(s3)
    80004898:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000489a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000489e:	854a                	mv	a0,s2
    800048a0:	fffff097          	auipc	ra,0xfffff
    800048a4:	e8a080e7          	jalr	-374(ra) # 8000372a <bread>
  log.lh.n = lh->n;
    800048a8:	4d34                	lw	a3,88(a0)
    800048aa:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048ac:	02d05563          	blez	a3,800048d6 <initlog+0x74>
    800048b0:	05c50793          	addi	a5,a0,92
    800048b4:	0003d717          	auipc	a4,0x3d
    800048b8:	58470713          	addi	a4,a4,1412 # 80041e38 <log+0x30>
    800048bc:	36fd                	addiw	a3,a3,-1
    800048be:	1682                	slli	a3,a3,0x20
    800048c0:	9281                	srli	a3,a3,0x20
    800048c2:	068a                	slli	a3,a3,0x2
    800048c4:	06050613          	addi	a2,a0,96
    800048c8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800048ca:	4390                	lw	a2,0(a5)
    800048cc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048ce:	0791                	addi	a5,a5,4
    800048d0:	0711                	addi	a4,a4,4
    800048d2:	fed79ce3          	bne	a5,a3,800048ca <initlog+0x68>
  brelse(buf);
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	f84080e7          	jalr	-124(ra) # 8000385a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800048de:	4505                	li	a0,1
    800048e0:	00000097          	auipc	ra,0x0
    800048e4:	ebe080e7          	jalr	-322(ra) # 8000479e <install_trans>
  log.lh.n = 0;
    800048e8:	0003d797          	auipc	a5,0x3d
    800048ec:	5407a623          	sw	zero,1356(a5) # 80041e34 <log+0x2c>
  write_head(); // clear the log
    800048f0:	00000097          	auipc	ra,0x0
    800048f4:	e34080e7          	jalr	-460(ra) # 80004724 <write_head>
}
    800048f8:	70a2                	ld	ra,40(sp)
    800048fa:	7402                	ld	s0,32(sp)
    800048fc:	64e2                	ld	s1,24(sp)
    800048fe:	6942                	ld	s2,16(sp)
    80004900:	69a2                	ld	s3,8(sp)
    80004902:	6145                	addi	sp,sp,48
    80004904:	8082                	ret

0000000080004906 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004906:	1101                	addi	sp,sp,-32
    80004908:	ec06                	sd	ra,24(sp)
    8000490a:	e822                	sd	s0,16(sp)
    8000490c:	e426                	sd	s1,8(sp)
    8000490e:	e04a                	sd	s2,0(sp)
    80004910:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004912:	0003d517          	auipc	a0,0x3d
    80004916:	4f650513          	addi	a0,a0,1270 # 80041e08 <log>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	51a080e7          	jalr	1306(ra) # 80000e34 <acquire>
  while(1){
    if(log.committing){
    80004922:	0003d497          	auipc	s1,0x3d
    80004926:	4e648493          	addi	s1,s1,1254 # 80041e08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000492a:	4979                	li	s2,30
    8000492c:	a039                	j	8000493a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000492e:	85a6                	mv	a1,s1
    80004930:	8526                	mv	a0,s1
    80004932:	ffffe097          	auipc	ra,0xffffe
    80004936:	cba080e7          	jalr	-838(ra) # 800025ec <sleep>
    if(log.committing){
    8000493a:	50dc                	lw	a5,36(s1)
    8000493c:	fbed                	bnez	a5,8000492e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000493e:	509c                	lw	a5,32(s1)
    80004940:	0017871b          	addiw	a4,a5,1
    80004944:	0007069b          	sext.w	a3,a4
    80004948:	0027179b          	slliw	a5,a4,0x2
    8000494c:	9fb9                	addw	a5,a5,a4
    8000494e:	0017979b          	slliw	a5,a5,0x1
    80004952:	54d8                	lw	a4,44(s1)
    80004954:	9fb9                	addw	a5,a5,a4
    80004956:	00f95963          	bge	s2,a5,80004968 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000495a:	85a6                	mv	a1,s1
    8000495c:	8526                	mv	a0,s1
    8000495e:	ffffe097          	auipc	ra,0xffffe
    80004962:	c8e080e7          	jalr	-882(ra) # 800025ec <sleep>
    80004966:	bfd1                	j	8000493a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004968:	0003d517          	auipc	a0,0x3d
    8000496c:	4a050513          	addi	a0,a0,1184 # 80041e08 <log>
    80004970:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004972:	ffffc097          	auipc	ra,0xffffc
    80004976:	576080e7          	jalr	1398(ra) # 80000ee8 <release>
      break;
    }
  }
}
    8000497a:	60e2                	ld	ra,24(sp)
    8000497c:	6442                	ld	s0,16(sp)
    8000497e:	64a2                	ld	s1,8(sp)
    80004980:	6902                	ld	s2,0(sp)
    80004982:	6105                	addi	sp,sp,32
    80004984:	8082                	ret

0000000080004986 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004986:	7139                	addi	sp,sp,-64
    80004988:	fc06                	sd	ra,56(sp)
    8000498a:	f822                	sd	s0,48(sp)
    8000498c:	f426                	sd	s1,40(sp)
    8000498e:	f04a                	sd	s2,32(sp)
    80004990:	ec4e                	sd	s3,24(sp)
    80004992:	e852                	sd	s4,16(sp)
    80004994:	e456                	sd	s5,8(sp)
    80004996:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004998:	0003d497          	auipc	s1,0x3d
    8000499c:	47048493          	addi	s1,s1,1136 # 80041e08 <log>
    800049a0:	8526                	mv	a0,s1
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	492080e7          	jalr	1170(ra) # 80000e34 <acquire>
  log.outstanding -= 1;
    800049aa:	509c                	lw	a5,32(s1)
    800049ac:	37fd                	addiw	a5,a5,-1
    800049ae:	0007891b          	sext.w	s2,a5
    800049b2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049b4:	50dc                	lw	a5,36(s1)
    800049b6:	e7b9                	bnez	a5,80004a04 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800049b8:	04091e63          	bnez	s2,80004a14 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800049bc:	0003d497          	auipc	s1,0x3d
    800049c0:	44c48493          	addi	s1,s1,1100 # 80041e08 <log>
    800049c4:	4785                	li	a5,1
    800049c6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	51e080e7          	jalr	1310(ra) # 80000ee8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049d2:	54dc                	lw	a5,44(s1)
    800049d4:	06f04763          	bgtz	a5,80004a42 <end_op+0xbc>
    acquire(&log.lock);
    800049d8:	0003d497          	auipc	s1,0x3d
    800049dc:	43048493          	addi	s1,s1,1072 # 80041e08 <log>
    800049e0:	8526                	mv	a0,s1
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	452080e7          	jalr	1106(ra) # 80000e34 <acquire>
    log.committing = 0;
    800049ea:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffe097          	auipc	ra,0xffffe
    800049f4:	c60080e7          	jalr	-928(ra) # 80002650 <wakeup>
    release(&log.lock);
    800049f8:	8526                	mv	a0,s1
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	4ee080e7          	jalr	1262(ra) # 80000ee8 <release>
}
    80004a02:	a03d                	j	80004a30 <end_op+0xaa>
    panic("log.committing");
    80004a04:	00004517          	auipc	a0,0x4
    80004a08:	ccc50513          	addi	a0,a0,-820 # 800086d0 <syscalls+0x1f0>
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	c00080e7          	jalr	-1024(ra) # 8000060c <panic>
    wakeup(&log);
    80004a14:	0003d497          	auipc	s1,0x3d
    80004a18:	3f448493          	addi	s1,s1,1012 # 80041e08 <log>
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffe097          	auipc	ra,0xffffe
    80004a22:	c32080e7          	jalr	-974(ra) # 80002650 <wakeup>
  release(&log.lock);
    80004a26:	8526                	mv	a0,s1
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	4c0080e7          	jalr	1216(ra) # 80000ee8 <release>
}
    80004a30:	70e2                	ld	ra,56(sp)
    80004a32:	7442                	ld	s0,48(sp)
    80004a34:	74a2                	ld	s1,40(sp)
    80004a36:	7902                	ld	s2,32(sp)
    80004a38:	69e2                	ld	s3,24(sp)
    80004a3a:	6a42                	ld	s4,16(sp)
    80004a3c:	6aa2                	ld	s5,8(sp)
    80004a3e:	6121                	addi	sp,sp,64
    80004a40:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a42:	0003da97          	auipc	s5,0x3d
    80004a46:	3f6a8a93          	addi	s5,s5,1014 # 80041e38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a4a:	0003da17          	auipc	s4,0x3d
    80004a4e:	3bea0a13          	addi	s4,s4,958 # 80041e08 <log>
    80004a52:	018a2583          	lw	a1,24(s4)
    80004a56:	012585bb          	addw	a1,a1,s2
    80004a5a:	2585                	addiw	a1,a1,1
    80004a5c:	028a2503          	lw	a0,40(s4)
    80004a60:	fffff097          	auipc	ra,0xfffff
    80004a64:	cca080e7          	jalr	-822(ra) # 8000372a <bread>
    80004a68:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a6a:	000aa583          	lw	a1,0(s5)
    80004a6e:	028a2503          	lw	a0,40(s4)
    80004a72:	fffff097          	auipc	ra,0xfffff
    80004a76:	cb8080e7          	jalr	-840(ra) # 8000372a <bread>
    80004a7a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a7c:	40000613          	li	a2,1024
    80004a80:	05850593          	addi	a1,a0,88
    80004a84:	05848513          	addi	a0,s1,88
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	504080e7          	jalr	1284(ra) # 80000f8c <memmove>
    bwrite(to);  // write the log
    80004a90:	8526                	mv	a0,s1
    80004a92:	fffff097          	auipc	ra,0xfffff
    80004a96:	d8a080e7          	jalr	-630(ra) # 8000381c <bwrite>
    brelse(from);
    80004a9a:	854e                	mv	a0,s3
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	dbe080e7          	jalr	-578(ra) # 8000385a <brelse>
    brelse(to);
    80004aa4:	8526                	mv	a0,s1
    80004aa6:	fffff097          	auipc	ra,0xfffff
    80004aaa:	db4080e7          	jalr	-588(ra) # 8000385a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004aae:	2905                	addiw	s2,s2,1
    80004ab0:	0a91                	addi	s5,s5,4
    80004ab2:	02ca2783          	lw	a5,44(s4)
    80004ab6:	f8f94ee3          	blt	s2,a5,80004a52 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004aba:	00000097          	auipc	ra,0x0
    80004abe:	c6a080e7          	jalr	-918(ra) # 80004724 <write_head>
    install_trans(0); // Now install writes to home locations
    80004ac2:	4501                	li	a0,0
    80004ac4:	00000097          	auipc	ra,0x0
    80004ac8:	cda080e7          	jalr	-806(ra) # 8000479e <install_trans>
    log.lh.n = 0;
    80004acc:	0003d797          	auipc	a5,0x3d
    80004ad0:	3607a423          	sw	zero,872(a5) # 80041e34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	c50080e7          	jalr	-944(ra) # 80004724 <write_head>
    80004adc:	bdf5                	j	800049d8 <end_op+0x52>

0000000080004ade <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ade:	1101                	addi	sp,sp,-32
    80004ae0:	ec06                	sd	ra,24(sp)
    80004ae2:	e822                	sd	s0,16(sp)
    80004ae4:	e426                	sd	s1,8(sp)
    80004ae6:	e04a                	sd	s2,0(sp)
    80004ae8:	1000                	addi	s0,sp,32
    80004aea:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004aec:	0003d917          	auipc	s2,0x3d
    80004af0:	31c90913          	addi	s2,s2,796 # 80041e08 <log>
    80004af4:	854a                	mv	a0,s2
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	33e080e7          	jalr	830(ra) # 80000e34 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004afe:	02c92603          	lw	a2,44(s2)
    80004b02:	47f5                	li	a5,29
    80004b04:	06c7c563          	blt	a5,a2,80004b6e <log_write+0x90>
    80004b08:	0003d797          	auipc	a5,0x3d
    80004b0c:	31c7a783          	lw	a5,796(a5) # 80041e24 <log+0x1c>
    80004b10:	37fd                	addiw	a5,a5,-1
    80004b12:	04f65e63          	bge	a2,a5,80004b6e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b16:	0003d797          	auipc	a5,0x3d
    80004b1a:	3127a783          	lw	a5,786(a5) # 80041e28 <log+0x20>
    80004b1e:	06f05063          	blez	a5,80004b7e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b22:	4781                	li	a5,0
    80004b24:	06c05563          	blez	a2,80004b8e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b28:	44cc                	lw	a1,12(s1)
    80004b2a:	0003d717          	auipc	a4,0x3d
    80004b2e:	30e70713          	addi	a4,a4,782 # 80041e38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b32:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b34:	4314                	lw	a3,0(a4)
    80004b36:	04b68c63          	beq	a3,a1,80004b8e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b3a:	2785                	addiw	a5,a5,1
    80004b3c:	0711                	addi	a4,a4,4
    80004b3e:	fef61be3          	bne	a2,a5,80004b34 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b42:	0621                	addi	a2,a2,8
    80004b44:	060a                	slli	a2,a2,0x2
    80004b46:	0003d797          	auipc	a5,0x3d
    80004b4a:	2c278793          	addi	a5,a5,706 # 80041e08 <log>
    80004b4e:	963e                	add	a2,a2,a5
    80004b50:	44dc                	lw	a5,12(s1)
    80004b52:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b54:	8526                	mv	a0,s1
    80004b56:	fffff097          	auipc	ra,0xfffff
    80004b5a:	da2080e7          	jalr	-606(ra) # 800038f8 <bpin>
    log.lh.n++;
    80004b5e:	0003d717          	auipc	a4,0x3d
    80004b62:	2aa70713          	addi	a4,a4,682 # 80041e08 <log>
    80004b66:	575c                	lw	a5,44(a4)
    80004b68:	2785                	addiw	a5,a5,1
    80004b6a:	d75c                	sw	a5,44(a4)
    80004b6c:	a835                	j	80004ba8 <log_write+0xca>
    panic("too big a transaction");
    80004b6e:	00004517          	auipc	a0,0x4
    80004b72:	b7250513          	addi	a0,a0,-1166 # 800086e0 <syscalls+0x200>
    80004b76:	ffffc097          	auipc	ra,0xffffc
    80004b7a:	a96080e7          	jalr	-1386(ra) # 8000060c <panic>
    panic("log_write outside of trans");
    80004b7e:	00004517          	auipc	a0,0x4
    80004b82:	b7a50513          	addi	a0,a0,-1158 # 800086f8 <syscalls+0x218>
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	a86080e7          	jalr	-1402(ra) # 8000060c <panic>
  log.lh.block[i] = b->blockno;
    80004b8e:	00878713          	addi	a4,a5,8
    80004b92:	00271693          	slli	a3,a4,0x2
    80004b96:	0003d717          	auipc	a4,0x3d
    80004b9a:	27270713          	addi	a4,a4,626 # 80041e08 <log>
    80004b9e:	9736                	add	a4,a4,a3
    80004ba0:	44d4                	lw	a3,12(s1)
    80004ba2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004ba4:	faf608e3          	beq	a2,a5,80004b54 <log_write+0x76>
  }
  release(&log.lock);
    80004ba8:	0003d517          	auipc	a0,0x3d
    80004bac:	26050513          	addi	a0,a0,608 # 80041e08 <log>
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	338080e7          	jalr	824(ra) # 80000ee8 <release>
}
    80004bb8:	60e2                	ld	ra,24(sp)
    80004bba:	6442                	ld	s0,16(sp)
    80004bbc:	64a2                	ld	s1,8(sp)
    80004bbe:	6902                	ld	s2,0(sp)
    80004bc0:	6105                	addi	sp,sp,32
    80004bc2:	8082                	ret

0000000080004bc4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bc4:	1101                	addi	sp,sp,-32
    80004bc6:	ec06                	sd	ra,24(sp)
    80004bc8:	e822                	sd	s0,16(sp)
    80004bca:	e426                	sd	s1,8(sp)
    80004bcc:	e04a                	sd	s2,0(sp)
    80004bce:	1000                	addi	s0,sp,32
    80004bd0:	84aa                	mv	s1,a0
    80004bd2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004bd4:	00004597          	auipc	a1,0x4
    80004bd8:	b4458593          	addi	a1,a1,-1212 # 80008718 <syscalls+0x238>
    80004bdc:	0521                	addi	a0,a0,8
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	1c6080e7          	jalr	454(ra) # 80000da4 <initlock>
  lk->name = name;
    80004be6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004bea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bee:	0204a423          	sw	zero,40(s1)
}
    80004bf2:	60e2                	ld	ra,24(sp)
    80004bf4:	6442                	ld	s0,16(sp)
    80004bf6:	64a2                	ld	s1,8(sp)
    80004bf8:	6902                	ld	s2,0(sp)
    80004bfa:	6105                	addi	sp,sp,32
    80004bfc:	8082                	ret

0000000080004bfe <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004bfe:	1101                	addi	sp,sp,-32
    80004c00:	ec06                	sd	ra,24(sp)
    80004c02:	e822                	sd	s0,16(sp)
    80004c04:	e426                	sd	s1,8(sp)
    80004c06:	e04a                	sd	s2,0(sp)
    80004c08:	1000                	addi	s0,sp,32
    80004c0a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c0c:	00850913          	addi	s2,a0,8
    80004c10:	854a                	mv	a0,s2
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	222080e7          	jalr	546(ra) # 80000e34 <acquire>
  while (lk->locked) {
    80004c1a:	409c                	lw	a5,0(s1)
    80004c1c:	cb89                	beqz	a5,80004c2e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c1e:	85ca                	mv	a1,s2
    80004c20:	8526                	mv	a0,s1
    80004c22:	ffffe097          	auipc	ra,0xffffe
    80004c26:	9ca080e7          	jalr	-1590(ra) # 800025ec <sleep>
  while (lk->locked) {
    80004c2a:	409c                	lw	a5,0(s1)
    80004c2c:	fbed                	bnez	a5,80004c1e <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c2e:	4785                	li	a5,1
    80004c30:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c32:	ffffd097          	auipc	ra,0xffffd
    80004c36:	fde080e7          	jalr	-34(ra) # 80001c10 <myproc>
    80004c3a:	591c                	lw	a5,48(a0)
    80004c3c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c3e:	854a                	mv	a0,s2
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	2a8080e7          	jalr	680(ra) # 80000ee8 <release>
}
    80004c48:	60e2                	ld	ra,24(sp)
    80004c4a:	6442                	ld	s0,16(sp)
    80004c4c:	64a2                	ld	s1,8(sp)
    80004c4e:	6902                	ld	s2,0(sp)
    80004c50:	6105                	addi	sp,sp,32
    80004c52:	8082                	ret

0000000080004c54 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c54:	1101                	addi	sp,sp,-32
    80004c56:	ec06                	sd	ra,24(sp)
    80004c58:	e822                	sd	s0,16(sp)
    80004c5a:	e426                	sd	s1,8(sp)
    80004c5c:	e04a                	sd	s2,0(sp)
    80004c5e:	1000                	addi	s0,sp,32
    80004c60:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c62:	00850913          	addi	s2,a0,8
    80004c66:	854a                	mv	a0,s2
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	1cc080e7          	jalr	460(ra) # 80000e34 <acquire>
  lk->locked = 0;
    80004c70:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c74:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	ffffe097          	auipc	ra,0xffffe
    80004c7e:	9d6080e7          	jalr	-1578(ra) # 80002650 <wakeup>
  release(&lk->lk);
    80004c82:	854a                	mv	a0,s2
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	264080e7          	jalr	612(ra) # 80000ee8 <release>
}
    80004c8c:	60e2                	ld	ra,24(sp)
    80004c8e:	6442                	ld	s0,16(sp)
    80004c90:	64a2                	ld	s1,8(sp)
    80004c92:	6902                	ld	s2,0(sp)
    80004c94:	6105                	addi	sp,sp,32
    80004c96:	8082                	ret

0000000080004c98 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c98:	7179                	addi	sp,sp,-48
    80004c9a:	f406                	sd	ra,40(sp)
    80004c9c:	f022                	sd	s0,32(sp)
    80004c9e:	ec26                	sd	s1,24(sp)
    80004ca0:	e84a                	sd	s2,16(sp)
    80004ca2:	e44e                	sd	s3,8(sp)
    80004ca4:	1800                	addi	s0,sp,48
    80004ca6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004ca8:	00850913          	addi	s2,a0,8
    80004cac:	854a                	mv	a0,s2
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	186080e7          	jalr	390(ra) # 80000e34 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cb6:	409c                	lw	a5,0(s1)
    80004cb8:	ef99                	bnez	a5,80004cd6 <holdingsleep+0x3e>
    80004cba:	4481                	li	s1,0
  release(&lk->lk);
    80004cbc:	854a                	mv	a0,s2
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	22a080e7          	jalr	554(ra) # 80000ee8 <release>
  return r;
}
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	70a2                	ld	ra,40(sp)
    80004cca:	7402                	ld	s0,32(sp)
    80004ccc:	64e2                	ld	s1,24(sp)
    80004cce:	6942                	ld	s2,16(sp)
    80004cd0:	69a2                	ld	s3,8(sp)
    80004cd2:	6145                	addi	sp,sp,48
    80004cd4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cd6:	0284a983          	lw	s3,40(s1)
    80004cda:	ffffd097          	auipc	ra,0xffffd
    80004cde:	f36080e7          	jalr	-202(ra) # 80001c10 <myproc>
    80004ce2:	5904                	lw	s1,48(a0)
    80004ce4:	413484b3          	sub	s1,s1,s3
    80004ce8:	0014b493          	seqz	s1,s1
    80004cec:	bfc1                	j	80004cbc <holdingsleep+0x24>

0000000080004cee <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004cee:	1141                	addi	sp,sp,-16
    80004cf0:	e406                	sd	ra,8(sp)
    80004cf2:	e022                	sd	s0,0(sp)
    80004cf4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004cf6:	00004597          	auipc	a1,0x4
    80004cfa:	a3258593          	addi	a1,a1,-1486 # 80008728 <syscalls+0x248>
    80004cfe:	0003d517          	auipc	a0,0x3d
    80004d02:	25250513          	addi	a0,a0,594 # 80041f50 <ftable>
    80004d06:	ffffc097          	auipc	ra,0xffffc
    80004d0a:	09e080e7          	jalr	158(ra) # 80000da4 <initlock>
}
    80004d0e:	60a2                	ld	ra,8(sp)
    80004d10:	6402                	ld	s0,0(sp)
    80004d12:	0141                	addi	sp,sp,16
    80004d14:	8082                	ret

0000000080004d16 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d16:	1101                	addi	sp,sp,-32
    80004d18:	ec06                	sd	ra,24(sp)
    80004d1a:	e822                	sd	s0,16(sp)
    80004d1c:	e426                	sd	s1,8(sp)
    80004d1e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d20:	0003d517          	auipc	a0,0x3d
    80004d24:	23050513          	addi	a0,a0,560 # 80041f50 <ftable>
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	10c080e7          	jalr	268(ra) # 80000e34 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d30:	0003d497          	auipc	s1,0x3d
    80004d34:	23848493          	addi	s1,s1,568 # 80041f68 <ftable+0x18>
    80004d38:	0003e717          	auipc	a4,0x3e
    80004d3c:	1d070713          	addi	a4,a4,464 # 80042f08 <disk>
    if(f->ref == 0){
    80004d40:	40dc                	lw	a5,4(s1)
    80004d42:	cf99                	beqz	a5,80004d60 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d44:	02848493          	addi	s1,s1,40
    80004d48:	fee49ce3          	bne	s1,a4,80004d40 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d4c:	0003d517          	auipc	a0,0x3d
    80004d50:	20450513          	addi	a0,a0,516 # 80041f50 <ftable>
    80004d54:	ffffc097          	auipc	ra,0xffffc
    80004d58:	194080e7          	jalr	404(ra) # 80000ee8 <release>
  return 0;
    80004d5c:	4481                	li	s1,0
    80004d5e:	a819                	j	80004d74 <filealloc+0x5e>
      f->ref = 1;
    80004d60:	4785                	li	a5,1
    80004d62:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d64:	0003d517          	auipc	a0,0x3d
    80004d68:	1ec50513          	addi	a0,a0,492 # 80041f50 <ftable>
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	17c080e7          	jalr	380(ra) # 80000ee8 <release>
}
    80004d74:	8526                	mv	a0,s1
    80004d76:	60e2                	ld	ra,24(sp)
    80004d78:	6442                	ld	s0,16(sp)
    80004d7a:	64a2                	ld	s1,8(sp)
    80004d7c:	6105                	addi	sp,sp,32
    80004d7e:	8082                	ret

0000000080004d80 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d80:	1101                	addi	sp,sp,-32
    80004d82:	ec06                	sd	ra,24(sp)
    80004d84:	e822                	sd	s0,16(sp)
    80004d86:	e426                	sd	s1,8(sp)
    80004d88:	1000                	addi	s0,sp,32
    80004d8a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d8c:	0003d517          	auipc	a0,0x3d
    80004d90:	1c450513          	addi	a0,a0,452 # 80041f50 <ftable>
    80004d94:	ffffc097          	auipc	ra,0xffffc
    80004d98:	0a0080e7          	jalr	160(ra) # 80000e34 <acquire>
  if(f->ref < 1)
    80004d9c:	40dc                	lw	a5,4(s1)
    80004d9e:	02f05263          	blez	a5,80004dc2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004da2:	2785                	addiw	a5,a5,1
    80004da4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004da6:	0003d517          	auipc	a0,0x3d
    80004daa:	1aa50513          	addi	a0,a0,426 # 80041f50 <ftable>
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	13a080e7          	jalr	314(ra) # 80000ee8 <release>
  return f;
}
    80004db6:	8526                	mv	a0,s1
    80004db8:	60e2                	ld	ra,24(sp)
    80004dba:	6442                	ld	s0,16(sp)
    80004dbc:	64a2                	ld	s1,8(sp)
    80004dbe:	6105                	addi	sp,sp,32
    80004dc0:	8082                	ret
    panic("filedup");
    80004dc2:	00004517          	auipc	a0,0x4
    80004dc6:	96e50513          	addi	a0,a0,-1682 # 80008730 <syscalls+0x250>
    80004dca:	ffffc097          	auipc	ra,0xffffc
    80004dce:	842080e7          	jalr	-1982(ra) # 8000060c <panic>

0000000080004dd2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004dd2:	7139                	addi	sp,sp,-64
    80004dd4:	fc06                	sd	ra,56(sp)
    80004dd6:	f822                	sd	s0,48(sp)
    80004dd8:	f426                	sd	s1,40(sp)
    80004dda:	f04a                	sd	s2,32(sp)
    80004ddc:	ec4e                	sd	s3,24(sp)
    80004dde:	e852                	sd	s4,16(sp)
    80004de0:	e456                	sd	s5,8(sp)
    80004de2:	0080                	addi	s0,sp,64
    80004de4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004de6:	0003d517          	auipc	a0,0x3d
    80004dea:	16a50513          	addi	a0,a0,362 # 80041f50 <ftable>
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	046080e7          	jalr	70(ra) # 80000e34 <acquire>
  if(f->ref < 1)
    80004df6:	40dc                	lw	a5,4(s1)
    80004df8:	06f05163          	blez	a5,80004e5a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004dfc:	37fd                	addiw	a5,a5,-1
    80004dfe:	0007871b          	sext.w	a4,a5
    80004e02:	c0dc                	sw	a5,4(s1)
    80004e04:	06e04363          	bgtz	a4,80004e6a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e08:	0004a903          	lw	s2,0(s1)
    80004e0c:	0094ca83          	lbu	s5,9(s1)
    80004e10:	0104ba03          	ld	s4,16(s1)
    80004e14:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e18:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e1c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e20:	0003d517          	auipc	a0,0x3d
    80004e24:	13050513          	addi	a0,a0,304 # 80041f50 <ftable>
    80004e28:	ffffc097          	auipc	ra,0xffffc
    80004e2c:	0c0080e7          	jalr	192(ra) # 80000ee8 <release>

  if(ff.type == FD_PIPE){
    80004e30:	4785                	li	a5,1
    80004e32:	04f90d63          	beq	s2,a5,80004e8c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e36:	3979                	addiw	s2,s2,-2
    80004e38:	4785                	li	a5,1
    80004e3a:	0527e063          	bltu	a5,s2,80004e7a <fileclose+0xa8>
    begin_op();
    80004e3e:	00000097          	auipc	ra,0x0
    80004e42:	ac8080e7          	jalr	-1336(ra) # 80004906 <begin_op>
    iput(ff.ip);
    80004e46:	854e                	mv	a0,s3
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	2b6080e7          	jalr	694(ra) # 800040fe <iput>
    end_op();
    80004e50:	00000097          	auipc	ra,0x0
    80004e54:	b36080e7          	jalr	-1226(ra) # 80004986 <end_op>
    80004e58:	a00d                	j	80004e7a <fileclose+0xa8>
    panic("fileclose");
    80004e5a:	00004517          	auipc	a0,0x4
    80004e5e:	8de50513          	addi	a0,a0,-1826 # 80008738 <syscalls+0x258>
    80004e62:	ffffb097          	auipc	ra,0xffffb
    80004e66:	7aa080e7          	jalr	1962(ra) # 8000060c <panic>
    release(&ftable.lock);
    80004e6a:	0003d517          	auipc	a0,0x3d
    80004e6e:	0e650513          	addi	a0,a0,230 # 80041f50 <ftable>
    80004e72:	ffffc097          	auipc	ra,0xffffc
    80004e76:	076080e7          	jalr	118(ra) # 80000ee8 <release>
  }
}
    80004e7a:	70e2                	ld	ra,56(sp)
    80004e7c:	7442                	ld	s0,48(sp)
    80004e7e:	74a2                	ld	s1,40(sp)
    80004e80:	7902                	ld	s2,32(sp)
    80004e82:	69e2                	ld	s3,24(sp)
    80004e84:	6a42                	ld	s4,16(sp)
    80004e86:	6aa2                	ld	s5,8(sp)
    80004e88:	6121                	addi	sp,sp,64
    80004e8a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e8c:	85d6                	mv	a1,s5
    80004e8e:	8552                	mv	a0,s4
    80004e90:	00000097          	auipc	ra,0x0
    80004e94:	34c080e7          	jalr	844(ra) # 800051dc <pipeclose>
    80004e98:	b7cd                	j	80004e7a <fileclose+0xa8>

0000000080004e9a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e9a:	715d                	addi	sp,sp,-80
    80004e9c:	e486                	sd	ra,72(sp)
    80004e9e:	e0a2                	sd	s0,64(sp)
    80004ea0:	fc26                	sd	s1,56(sp)
    80004ea2:	f84a                	sd	s2,48(sp)
    80004ea4:	f44e                	sd	s3,40(sp)
    80004ea6:	0880                	addi	s0,sp,80
    80004ea8:	84aa                	mv	s1,a0
    80004eaa:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	d64080e7          	jalr	-668(ra) # 80001c10 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004eb4:	409c                	lw	a5,0(s1)
    80004eb6:	37f9                	addiw	a5,a5,-2
    80004eb8:	4705                	li	a4,1
    80004eba:	04f76763          	bltu	a4,a5,80004f08 <filestat+0x6e>
    80004ebe:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ec0:	6c88                	ld	a0,24(s1)
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	082080e7          	jalr	130(ra) # 80003f44 <ilock>
    stati(f->ip, &st);
    80004eca:	fb840593          	addi	a1,s0,-72
    80004ece:	6c88                	ld	a0,24(s1)
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	2fe080e7          	jalr	766(ra) # 800041ce <stati>
    iunlock(f->ip);
    80004ed8:	6c88                	ld	a0,24(s1)
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	12c080e7          	jalr	300(ra) # 80004006 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ee2:	46e1                	li	a3,24
    80004ee4:	fb840613          	addi	a2,s0,-72
    80004ee8:	85ce                	mv	a1,s3
    80004eea:	05093503          	ld	a0,80(s2)
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	9d8080e7          	jalr	-1576(ra) # 800018c6 <copyout>
    80004ef6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004efa:	60a6                	ld	ra,72(sp)
    80004efc:	6406                	ld	s0,64(sp)
    80004efe:	74e2                	ld	s1,56(sp)
    80004f00:	7942                	ld	s2,48(sp)
    80004f02:	79a2                	ld	s3,40(sp)
    80004f04:	6161                	addi	sp,sp,80
    80004f06:	8082                	ret
  return -1;
    80004f08:	557d                	li	a0,-1
    80004f0a:	bfc5                	j	80004efa <filestat+0x60>

0000000080004f0c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f0c:	7179                	addi	sp,sp,-48
    80004f0e:	f406                	sd	ra,40(sp)
    80004f10:	f022                	sd	s0,32(sp)
    80004f12:	ec26                	sd	s1,24(sp)
    80004f14:	e84a                	sd	s2,16(sp)
    80004f16:	e44e                	sd	s3,8(sp)
    80004f18:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f1a:	00854783          	lbu	a5,8(a0)
    80004f1e:	c3d5                	beqz	a5,80004fc2 <fileread+0xb6>
    80004f20:	84aa                	mv	s1,a0
    80004f22:	89ae                	mv	s3,a1
    80004f24:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f26:	411c                	lw	a5,0(a0)
    80004f28:	4705                	li	a4,1
    80004f2a:	04e78963          	beq	a5,a4,80004f7c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f2e:	470d                	li	a4,3
    80004f30:	04e78d63          	beq	a5,a4,80004f8a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f34:	4709                	li	a4,2
    80004f36:	06e79e63          	bne	a5,a4,80004fb2 <fileread+0xa6>
    ilock(f->ip);
    80004f3a:	6d08                	ld	a0,24(a0)
    80004f3c:	fffff097          	auipc	ra,0xfffff
    80004f40:	008080e7          	jalr	8(ra) # 80003f44 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f44:	874a                	mv	a4,s2
    80004f46:	5094                	lw	a3,32(s1)
    80004f48:	864e                	mv	a2,s3
    80004f4a:	4585                	li	a1,1
    80004f4c:	6c88                	ld	a0,24(s1)
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	2aa080e7          	jalr	682(ra) # 800041f8 <readi>
    80004f56:	892a                	mv	s2,a0
    80004f58:	00a05563          	blez	a0,80004f62 <fileread+0x56>
      f->off += r;
    80004f5c:	509c                	lw	a5,32(s1)
    80004f5e:	9fa9                	addw	a5,a5,a0
    80004f60:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f62:	6c88                	ld	a0,24(s1)
    80004f64:	fffff097          	auipc	ra,0xfffff
    80004f68:	0a2080e7          	jalr	162(ra) # 80004006 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004f6c:	854a                	mv	a0,s2
    80004f6e:	70a2                	ld	ra,40(sp)
    80004f70:	7402                	ld	s0,32(sp)
    80004f72:	64e2                	ld	s1,24(sp)
    80004f74:	6942                	ld	s2,16(sp)
    80004f76:	69a2                	ld	s3,8(sp)
    80004f78:	6145                	addi	sp,sp,48
    80004f7a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004f7c:	6908                	ld	a0,16(a0)
    80004f7e:	00000097          	auipc	ra,0x0
    80004f82:	3c6080e7          	jalr	966(ra) # 80005344 <piperead>
    80004f86:	892a                	mv	s2,a0
    80004f88:	b7d5                	j	80004f6c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f8a:	02451783          	lh	a5,36(a0)
    80004f8e:	03079693          	slli	a3,a5,0x30
    80004f92:	92c1                	srli	a3,a3,0x30
    80004f94:	4725                	li	a4,9
    80004f96:	02d76863          	bltu	a4,a3,80004fc6 <fileread+0xba>
    80004f9a:	0792                	slli	a5,a5,0x4
    80004f9c:	0003d717          	auipc	a4,0x3d
    80004fa0:	f1470713          	addi	a4,a4,-236 # 80041eb0 <devsw>
    80004fa4:	97ba                	add	a5,a5,a4
    80004fa6:	639c                	ld	a5,0(a5)
    80004fa8:	c38d                	beqz	a5,80004fca <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004faa:	4505                	li	a0,1
    80004fac:	9782                	jalr	a5
    80004fae:	892a                	mv	s2,a0
    80004fb0:	bf75                	j	80004f6c <fileread+0x60>
    panic("fileread");
    80004fb2:	00003517          	auipc	a0,0x3
    80004fb6:	79650513          	addi	a0,a0,1942 # 80008748 <syscalls+0x268>
    80004fba:	ffffb097          	auipc	ra,0xffffb
    80004fbe:	652080e7          	jalr	1618(ra) # 8000060c <panic>
    return -1;
    80004fc2:	597d                	li	s2,-1
    80004fc4:	b765                	j	80004f6c <fileread+0x60>
      return -1;
    80004fc6:	597d                	li	s2,-1
    80004fc8:	b755                	j	80004f6c <fileread+0x60>
    80004fca:	597d                	li	s2,-1
    80004fcc:	b745                	j	80004f6c <fileread+0x60>

0000000080004fce <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004fce:	715d                	addi	sp,sp,-80
    80004fd0:	e486                	sd	ra,72(sp)
    80004fd2:	e0a2                	sd	s0,64(sp)
    80004fd4:	fc26                	sd	s1,56(sp)
    80004fd6:	f84a                	sd	s2,48(sp)
    80004fd8:	f44e                	sd	s3,40(sp)
    80004fda:	f052                	sd	s4,32(sp)
    80004fdc:	ec56                	sd	s5,24(sp)
    80004fde:	e85a                	sd	s6,16(sp)
    80004fe0:	e45e                	sd	s7,8(sp)
    80004fe2:	e062                	sd	s8,0(sp)
    80004fe4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004fe6:	00954783          	lbu	a5,9(a0)
    80004fea:	10078663          	beqz	a5,800050f6 <filewrite+0x128>
    80004fee:	892a                	mv	s2,a0
    80004ff0:	8aae                	mv	s5,a1
    80004ff2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ff4:	411c                	lw	a5,0(a0)
    80004ff6:	4705                	li	a4,1
    80004ff8:	02e78263          	beq	a5,a4,8000501c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ffc:	470d                	li	a4,3
    80004ffe:	02e78663          	beq	a5,a4,8000502a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005002:	4709                	li	a4,2
    80005004:	0ee79163          	bne	a5,a4,800050e6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005008:	0ac05d63          	blez	a2,800050c2 <filewrite+0xf4>
    int i = 0;
    8000500c:	4981                	li	s3,0
    8000500e:	6b05                	lui	s6,0x1
    80005010:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005014:	6b85                	lui	s7,0x1
    80005016:	c00b8b9b          	addiw	s7,s7,-1024
    8000501a:	a861                	j	800050b2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000501c:	6908                	ld	a0,16(a0)
    8000501e:	00000097          	auipc	ra,0x0
    80005022:	22e080e7          	jalr	558(ra) # 8000524c <pipewrite>
    80005026:	8a2a                	mv	s4,a0
    80005028:	a045                	j	800050c8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000502a:	02451783          	lh	a5,36(a0)
    8000502e:	03079693          	slli	a3,a5,0x30
    80005032:	92c1                	srli	a3,a3,0x30
    80005034:	4725                	li	a4,9
    80005036:	0cd76263          	bltu	a4,a3,800050fa <filewrite+0x12c>
    8000503a:	0792                	slli	a5,a5,0x4
    8000503c:	0003d717          	auipc	a4,0x3d
    80005040:	e7470713          	addi	a4,a4,-396 # 80041eb0 <devsw>
    80005044:	97ba                	add	a5,a5,a4
    80005046:	679c                	ld	a5,8(a5)
    80005048:	cbdd                	beqz	a5,800050fe <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000504a:	4505                	li	a0,1
    8000504c:	9782                	jalr	a5
    8000504e:	8a2a                	mv	s4,a0
    80005050:	a8a5                	j	800050c8 <filewrite+0xfa>
    80005052:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005056:	00000097          	auipc	ra,0x0
    8000505a:	8b0080e7          	jalr	-1872(ra) # 80004906 <begin_op>
      ilock(f->ip);
    8000505e:	01893503          	ld	a0,24(s2)
    80005062:	fffff097          	auipc	ra,0xfffff
    80005066:	ee2080e7          	jalr	-286(ra) # 80003f44 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000506a:	8762                	mv	a4,s8
    8000506c:	02092683          	lw	a3,32(s2)
    80005070:	01598633          	add	a2,s3,s5
    80005074:	4585                	li	a1,1
    80005076:	01893503          	ld	a0,24(s2)
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	276080e7          	jalr	630(ra) # 800042f0 <writei>
    80005082:	84aa                	mv	s1,a0
    80005084:	00a05763          	blez	a0,80005092 <filewrite+0xc4>
        f->off += r;
    80005088:	02092783          	lw	a5,32(s2)
    8000508c:	9fa9                	addw	a5,a5,a0
    8000508e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005092:	01893503          	ld	a0,24(s2)
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	f70080e7          	jalr	-144(ra) # 80004006 <iunlock>
      end_op();
    8000509e:	00000097          	auipc	ra,0x0
    800050a2:	8e8080e7          	jalr	-1816(ra) # 80004986 <end_op>

      if(r != n1){
    800050a6:	009c1f63          	bne	s8,s1,800050c4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800050aa:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800050ae:	0149db63          	bge	s3,s4,800050c4 <filewrite+0xf6>
      int n1 = n - i;
    800050b2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800050b6:	84be                	mv	s1,a5
    800050b8:	2781                	sext.w	a5,a5
    800050ba:	f8fb5ce3          	bge	s6,a5,80005052 <filewrite+0x84>
    800050be:	84de                	mv	s1,s7
    800050c0:	bf49                	j	80005052 <filewrite+0x84>
    int i = 0;
    800050c2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800050c4:	013a1f63          	bne	s4,s3,800050e2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800050c8:	8552                	mv	a0,s4
    800050ca:	60a6                	ld	ra,72(sp)
    800050cc:	6406                	ld	s0,64(sp)
    800050ce:	74e2                	ld	s1,56(sp)
    800050d0:	7942                	ld	s2,48(sp)
    800050d2:	79a2                	ld	s3,40(sp)
    800050d4:	7a02                	ld	s4,32(sp)
    800050d6:	6ae2                	ld	s5,24(sp)
    800050d8:	6b42                	ld	s6,16(sp)
    800050da:	6ba2                	ld	s7,8(sp)
    800050dc:	6c02                	ld	s8,0(sp)
    800050de:	6161                	addi	sp,sp,80
    800050e0:	8082                	ret
    ret = (i == n ? n : -1);
    800050e2:	5a7d                	li	s4,-1
    800050e4:	b7d5                	j	800050c8 <filewrite+0xfa>
    panic("filewrite");
    800050e6:	00003517          	auipc	a0,0x3
    800050ea:	67250513          	addi	a0,a0,1650 # 80008758 <syscalls+0x278>
    800050ee:	ffffb097          	auipc	ra,0xffffb
    800050f2:	51e080e7          	jalr	1310(ra) # 8000060c <panic>
    return -1;
    800050f6:	5a7d                	li	s4,-1
    800050f8:	bfc1                	j	800050c8 <filewrite+0xfa>
      return -1;
    800050fa:	5a7d                	li	s4,-1
    800050fc:	b7f1                	j	800050c8 <filewrite+0xfa>
    800050fe:	5a7d                	li	s4,-1
    80005100:	b7e1                	j	800050c8 <filewrite+0xfa>

0000000080005102 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005102:	7179                	addi	sp,sp,-48
    80005104:	f406                	sd	ra,40(sp)
    80005106:	f022                	sd	s0,32(sp)
    80005108:	ec26                	sd	s1,24(sp)
    8000510a:	e84a                	sd	s2,16(sp)
    8000510c:	e44e                	sd	s3,8(sp)
    8000510e:	e052                	sd	s4,0(sp)
    80005110:	1800                	addi	s0,sp,48
    80005112:	84aa                	mv	s1,a0
    80005114:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005116:	0005b023          	sd	zero,0(a1)
    8000511a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000511e:	00000097          	auipc	ra,0x0
    80005122:	bf8080e7          	jalr	-1032(ra) # 80004d16 <filealloc>
    80005126:	e088                	sd	a0,0(s1)
    80005128:	c551                	beqz	a0,800051b4 <pipealloc+0xb2>
    8000512a:	00000097          	auipc	ra,0x0
    8000512e:	bec080e7          	jalr	-1044(ra) # 80004d16 <filealloc>
    80005132:	00aa3023          	sd	a0,0(s4)
    80005136:	c92d                	beqz	a0,800051a8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005138:	ffffc097          	auipc	ra,0xffffc
    8000513c:	9d0080e7          	jalr	-1584(ra) # 80000b08 <kalloc>
    80005140:	892a                	mv	s2,a0
    80005142:	c125                	beqz	a0,800051a2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005144:	4985                	li	s3,1
    80005146:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000514a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000514e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005152:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005156:	00003597          	auipc	a1,0x3
    8000515a:	61258593          	addi	a1,a1,1554 # 80008768 <syscalls+0x288>
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	c46080e7          	jalr	-954(ra) # 80000da4 <initlock>
  (*f0)->type = FD_PIPE;
    80005166:	609c                	ld	a5,0(s1)
    80005168:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000516c:	609c                	ld	a5,0(s1)
    8000516e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005172:	609c                	ld	a5,0(s1)
    80005174:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005178:	609c                	ld	a5,0(s1)
    8000517a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000517e:	000a3783          	ld	a5,0(s4)
    80005182:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005186:	000a3783          	ld	a5,0(s4)
    8000518a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000518e:	000a3783          	ld	a5,0(s4)
    80005192:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005196:	000a3783          	ld	a5,0(s4)
    8000519a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000519e:	4501                	li	a0,0
    800051a0:	a025                	j	800051c8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800051a2:	6088                	ld	a0,0(s1)
    800051a4:	e501                	bnez	a0,800051ac <pipealloc+0xaa>
    800051a6:	a039                	j	800051b4 <pipealloc+0xb2>
    800051a8:	6088                	ld	a0,0(s1)
    800051aa:	c51d                	beqz	a0,800051d8 <pipealloc+0xd6>
    fileclose(*f0);
    800051ac:	00000097          	auipc	ra,0x0
    800051b0:	c26080e7          	jalr	-986(ra) # 80004dd2 <fileclose>
  if(*f1)
    800051b4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800051b8:	557d                	li	a0,-1
  if(*f1)
    800051ba:	c799                	beqz	a5,800051c8 <pipealloc+0xc6>
    fileclose(*f1);
    800051bc:	853e                	mv	a0,a5
    800051be:	00000097          	auipc	ra,0x0
    800051c2:	c14080e7          	jalr	-1004(ra) # 80004dd2 <fileclose>
  return -1;
    800051c6:	557d                	li	a0,-1
}
    800051c8:	70a2                	ld	ra,40(sp)
    800051ca:	7402                	ld	s0,32(sp)
    800051cc:	64e2                	ld	s1,24(sp)
    800051ce:	6942                	ld	s2,16(sp)
    800051d0:	69a2                	ld	s3,8(sp)
    800051d2:	6a02                	ld	s4,0(sp)
    800051d4:	6145                	addi	sp,sp,48
    800051d6:	8082                	ret
  return -1;
    800051d8:	557d                	li	a0,-1
    800051da:	b7fd                	j	800051c8 <pipealloc+0xc6>

00000000800051dc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800051dc:	1101                	addi	sp,sp,-32
    800051de:	ec06                	sd	ra,24(sp)
    800051e0:	e822                	sd	s0,16(sp)
    800051e2:	e426                	sd	s1,8(sp)
    800051e4:	e04a                	sd	s2,0(sp)
    800051e6:	1000                	addi	s0,sp,32
    800051e8:	84aa                	mv	s1,a0
    800051ea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800051ec:	ffffc097          	auipc	ra,0xffffc
    800051f0:	c48080e7          	jalr	-952(ra) # 80000e34 <acquire>
  if(writable){
    800051f4:	02090d63          	beqz	s2,8000522e <pipeclose+0x52>
    pi->writeopen = 0;
    800051f8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800051fc:	21848513          	addi	a0,s1,536
    80005200:	ffffd097          	auipc	ra,0xffffd
    80005204:	450080e7          	jalr	1104(ra) # 80002650 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005208:	2204b783          	ld	a5,544(s1)
    8000520c:	eb95                	bnez	a5,80005240 <pipeclose+0x64>
    release(&pi->lock);
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffc097          	auipc	ra,0xffffc
    80005214:	cd8080e7          	jalr	-808(ra) # 80000ee8 <release>
    kfree((char*)pi);
    80005218:	8526                	mv	a0,s1
    8000521a:	ffffc097          	auipc	ra,0xffffc
    8000521e:	9b4080e7          	jalr	-1612(ra) # 80000bce <kfree>
  } else
    release(&pi->lock);
}
    80005222:	60e2                	ld	ra,24(sp)
    80005224:	6442                	ld	s0,16(sp)
    80005226:	64a2                	ld	s1,8(sp)
    80005228:	6902                	ld	s2,0(sp)
    8000522a:	6105                	addi	sp,sp,32
    8000522c:	8082                	ret
    pi->readopen = 0;
    8000522e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005232:	21c48513          	addi	a0,s1,540
    80005236:	ffffd097          	auipc	ra,0xffffd
    8000523a:	41a080e7          	jalr	1050(ra) # 80002650 <wakeup>
    8000523e:	b7e9                	j	80005208 <pipeclose+0x2c>
    release(&pi->lock);
    80005240:	8526                	mv	a0,s1
    80005242:	ffffc097          	auipc	ra,0xffffc
    80005246:	ca6080e7          	jalr	-858(ra) # 80000ee8 <release>
}
    8000524a:	bfe1                	j	80005222 <pipeclose+0x46>

000000008000524c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000524c:	711d                	addi	sp,sp,-96
    8000524e:	ec86                	sd	ra,88(sp)
    80005250:	e8a2                	sd	s0,80(sp)
    80005252:	e4a6                	sd	s1,72(sp)
    80005254:	e0ca                	sd	s2,64(sp)
    80005256:	fc4e                	sd	s3,56(sp)
    80005258:	f852                	sd	s4,48(sp)
    8000525a:	f456                	sd	s5,40(sp)
    8000525c:	f05a                	sd	s6,32(sp)
    8000525e:	ec5e                	sd	s7,24(sp)
    80005260:	e862                	sd	s8,16(sp)
    80005262:	1080                	addi	s0,sp,96
    80005264:	84aa                	mv	s1,a0
    80005266:	8aae                	mv	s5,a1
    80005268:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000526a:	ffffd097          	auipc	ra,0xffffd
    8000526e:	9a6080e7          	jalr	-1626(ra) # 80001c10 <myproc>
    80005272:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005274:	8526                	mv	a0,s1
    80005276:	ffffc097          	auipc	ra,0xffffc
    8000527a:	bbe080e7          	jalr	-1090(ra) # 80000e34 <acquire>
  while(i < n){
    8000527e:	0b405663          	blez	s4,8000532a <pipewrite+0xde>
  int i = 0;
    80005282:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005284:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005286:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000528a:	21c48b93          	addi	s7,s1,540
    8000528e:	a089                	j	800052d0 <pipewrite+0x84>
      release(&pi->lock);
    80005290:	8526                	mv	a0,s1
    80005292:	ffffc097          	auipc	ra,0xffffc
    80005296:	c56080e7          	jalr	-938(ra) # 80000ee8 <release>
      return -1;
    8000529a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000529c:	854a                	mv	a0,s2
    8000529e:	60e6                	ld	ra,88(sp)
    800052a0:	6446                	ld	s0,80(sp)
    800052a2:	64a6                	ld	s1,72(sp)
    800052a4:	6906                	ld	s2,64(sp)
    800052a6:	79e2                	ld	s3,56(sp)
    800052a8:	7a42                	ld	s4,48(sp)
    800052aa:	7aa2                	ld	s5,40(sp)
    800052ac:	7b02                	ld	s6,32(sp)
    800052ae:	6be2                	ld	s7,24(sp)
    800052b0:	6c42                	ld	s8,16(sp)
    800052b2:	6125                	addi	sp,sp,96
    800052b4:	8082                	ret
      wakeup(&pi->nread);
    800052b6:	8562                	mv	a0,s8
    800052b8:	ffffd097          	auipc	ra,0xffffd
    800052bc:	398080e7          	jalr	920(ra) # 80002650 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800052c0:	85a6                	mv	a1,s1
    800052c2:	855e                	mv	a0,s7
    800052c4:	ffffd097          	auipc	ra,0xffffd
    800052c8:	328080e7          	jalr	808(ra) # 800025ec <sleep>
  while(i < n){
    800052cc:	07495063          	bge	s2,s4,8000532c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800052d0:	2204a783          	lw	a5,544(s1)
    800052d4:	dfd5                	beqz	a5,80005290 <pipewrite+0x44>
    800052d6:	854e                	mv	a0,s3
    800052d8:	ffffd097          	auipc	ra,0xffffd
    800052dc:	5bc080e7          	jalr	1468(ra) # 80002894 <killed>
    800052e0:	f945                	bnez	a0,80005290 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800052e2:	2184a783          	lw	a5,536(s1)
    800052e6:	21c4a703          	lw	a4,540(s1)
    800052ea:	2007879b          	addiw	a5,a5,512
    800052ee:	fcf704e3          	beq	a4,a5,800052b6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052f2:	4685                	li	a3,1
    800052f4:	01590633          	add	a2,s2,s5
    800052f8:	faf40593          	addi	a1,s0,-81
    800052fc:	0509b503          	ld	a0,80(s3)
    80005300:	ffffc097          	auipc	ra,0xffffc
    80005304:	652080e7          	jalr	1618(ra) # 80001952 <copyin>
    80005308:	03650263          	beq	a0,s6,8000532c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000530c:	21c4a783          	lw	a5,540(s1)
    80005310:	0017871b          	addiw	a4,a5,1
    80005314:	20e4ae23          	sw	a4,540(s1)
    80005318:	1ff7f793          	andi	a5,a5,511
    8000531c:	97a6                	add	a5,a5,s1
    8000531e:	faf44703          	lbu	a4,-81(s0)
    80005322:	00e78c23          	sb	a4,24(a5)
      i++;
    80005326:	2905                	addiw	s2,s2,1
    80005328:	b755                	j	800052cc <pipewrite+0x80>
  int i = 0;
    8000532a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000532c:	21848513          	addi	a0,s1,536
    80005330:	ffffd097          	auipc	ra,0xffffd
    80005334:	320080e7          	jalr	800(ra) # 80002650 <wakeup>
  release(&pi->lock);
    80005338:	8526                	mv	a0,s1
    8000533a:	ffffc097          	auipc	ra,0xffffc
    8000533e:	bae080e7          	jalr	-1106(ra) # 80000ee8 <release>
  return i;
    80005342:	bfa9                	j	8000529c <pipewrite+0x50>

0000000080005344 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005344:	715d                	addi	sp,sp,-80
    80005346:	e486                	sd	ra,72(sp)
    80005348:	e0a2                	sd	s0,64(sp)
    8000534a:	fc26                	sd	s1,56(sp)
    8000534c:	f84a                	sd	s2,48(sp)
    8000534e:	f44e                	sd	s3,40(sp)
    80005350:	f052                	sd	s4,32(sp)
    80005352:	ec56                	sd	s5,24(sp)
    80005354:	e85a                	sd	s6,16(sp)
    80005356:	0880                	addi	s0,sp,80
    80005358:	84aa                	mv	s1,a0
    8000535a:	892e                	mv	s2,a1
    8000535c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000535e:	ffffd097          	auipc	ra,0xffffd
    80005362:	8b2080e7          	jalr	-1870(ra) # 80001c10 <myproc>
    80005366:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005368:	8526                	mv	a0,s1
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	aca080e7          	jalr	-1334(ra) # 80000e34 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005372:	2184a703          	lw	a4,536(s1)
    80005376:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000537a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000537e:	02f71763          	bne	a4,a5,800053ac <piperead+0x68>
    80005382:	2244a783          	lw	a5,548(s1)
    80005386:	c39d                	beqz	a5,800053ac <piperead+0x68>
    if(killed(pr)){
    80005388:	8552                	mv	a0,s4
    8000538a:	ffffd097          	auipc	ra,0xffffd
    8000538e:	50a080e7          	jalr	1290(ra) # 80002894 <killed>
    80005392:	e941                	bnez	a0,80005422 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005394:	85a6                	mv	a1,s1
    80005396:	854e                	mv	a0,s3
    80005398:	ffffd097          	auipc	ra,0xffffd
    8000539c:	254080e7          	jalr	596(ra) # 800025ec <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053a0:	2184a703          	lw	a4,536(s1)
    800053a4:	21c4a783          	lw	a5,540(s1)
    800053a8:	fcf70de3          	beq	a4,a5,80005382 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053ac:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053ae:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053b0:	05505363          	blez	s5,800053f6 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800053b4:	2184a783          	lw	a5,536(s1)
    800053b8:	21c4a703          	lw	a4,540(s1)
    800053bc:	02f70d63          	beq	a4,a5,800053f6 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800053c0:	0017871b          	addiw	a4,a5,1
    800053c4:	20e4ac23          	sw	a4,536(s1)
    800053c8:	1ff7f793          	andi	a5,a5,511
    800053cc:	97a6                	add	a5,a5,s1
    800053ce:	0187c783          	lbu	a5,24(a5)
    800053d2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053d6:	4685                	li	a3,1
    800053d8:	fbf40613          	addi	a2,s0,-65
    800053dc:	85ca                	mv	a1,s2
    800053de:	050a3503          	ld	a0,80(s4)
    800053e2:	ffffc097          	auipc	ra,0xffffc
    800053e6:	4e4080e7          	jalr	1252(ra) # 800018c6 <copyout>
    800053ea:	01650663          	beq	a0,s6,800053f6 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053ee:	2985                	addiw	s3,s3,1
    800053f0:	0905                	addi	s2,s2,1
    800053f2:	fd3a91e3          	bne	s5,s3,800053b4 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800053f6:	21c48513          	addi	a0,s1,540
    800053fa:	ffffd097          	auipc	ra,0xffffd
    800053fe:	256080e7          	jalr	598(ra) # 80002650 <wakeup>
  release(&pi->lock);
    80005402:	8526                	mv	a0,s1
    80005404:	ffffc097          	auipc	ra,0xffffc
    80005408:	ae4080e7          	jalr	-1308(ra) # 80000ee8 <release>
  return i;
}
    8000540c:	854e                	mv	a0,s3
    8000540e:	60a6                	ld	ra,72(sp)
    80005410:	6406                	ld	s0,64(sp)
    80005412:	74e2                	ld	s1,56(sp)
    80005414:	7942                	ld	s2,48(sp)
    80005416:	79a2                	ld	s3,40(sp)
    80005418:	7a02                	ld	s4,32(sp)
    8000541a:	6ae2                	ld	s5,24(sp)
    8000541c:	6b42                	ld	s6,16(sp)
    8000541e:	6161                	addi	sp,sp,80
    80005420:	8082                	ret
      release(&pi->lock);
    80005422:	8526                	mv	a0,s1
    80005424:	ffffc097          	auipc	ra,0xffffc
    80005428:	ac4080e7          	jalr	-1340(ra) # 80000ee8 <release>
      return -1;
    8000542c:	59fd                	li	s3,-1
    8000542e:	bff9                	j	8000540c <piperead+0xc8>

0000000080005430 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005430:	1141                	addi	sp,sp,-16
    80005432:	e422                	sd	s0,8(sp)
    80005434:	0800                	addi	s0,sp,16
    80005436:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005438:	8905                	andi	a0,a0,1
    8000543a:	c111                	beqz	a0,8000543e <flags2perm+0xe>
      perm = PTE_X;
    8000543c:	4521                	li	a0,8
    if(flags & 0x2)
    8000543e:	8b89                	andi	a5,a5,2
    80005440:	c399                	beqz	a5,80005446 <flags2perm+0x16>
      perm |= PTE_W;
    80005442:	00456513          	ori	a0,a0,4
    return perm;
}
    80005446:	6422                	ld	s0,8(sp)
    80005448:	0141                	addi	sp,sp,16
    8000544a:	8082                	ret

000000008000544c <exec>:

int
exec(char *path, char **argv)
{
    8000544c:	de010113          	addi	sp,sp,-544
    80005450:	20113c23          	sd	ra,536(sp)
    80005454:	20813823          	sd	s0,528(sp)
    80005458:	20913423          	sd	s1,520(sp)
    8000545c:	21213023          	sd	s2,512(sp)
    80005460:	ffce                	sd	s3,504(sp)
    80005462:	fbd2                	sd	s4,496(sp)
    80005464:	f7d6                	sd	s5,488(sp)
    80005466:	f3da                	sd	s6,480(sp)
    80005468:	efde                	sd	s7,472(sp)
    8000546a:	ebe2                	sd	s8,464(sp)
    8000546c:	e7e6                	sd	s9,456(sp)
    8000546e:	e3ea                	sd	s10,448(sp)
    80005470:	ff6e                	sd	s11,440(sp)
    80005472:	1400                	addi	s0,sp,544
    80005474:	892a                	mv	s2,a0
    80005476:	dea43423          	sd	a0,-536(s0)
    8000547a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000547e:	ffffc097          	auipc	ra,0xffffc
    80005482:	792080e7          	jalr	1938(ra) # 80001c10 <myproc>
    80005486:	84aa                	mv	s1,a0

  begin_op();
    80005488:	fffff097          	auipc	ra,0xfffff
    8000548c:	47e080e7          	jalr	1150(ra) # 80004906 <begin_op>

  if((ip = namei(path)) == 0){
    80005490:	854a                	mv	a0,s2
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	258080e7          	jalr	600(ra) # 800046ea <namei>
    8000549a:	c93d                	beqz	a0,80005510 <exec+0xc4>
    8000549c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	aa6080e7          	jalr	-1370(ra) # 80003f44 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054a6:	04000713          	li	a4,64
    800054aa:	4681                	li	a3,0
    800054ac:	e5040613          	addi	a2,s0,-432
    800054b0:	4581                	li	a1,0
    800054b2:	8556                	mv	a0,s5
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	d44080e7          	jalr	-700(ra) # 800041f8 <readi>
    800054bc:	04000793          	li	a5,64
    800054c0:	00f51a63          	bne	a0,a5,800054d4 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800054c4:	e5042703          	lw	a4,-432(s0)
    800054c8:	464c47b7          	lui	a5,0x464c4
    800054cc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054d0:	04f70663          	beq	a4,a5,8000551c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054d4:	8556                	mv	a0,s5
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	cd0080e7          	jalr	-816(ra) # 800041a6 <iunlockput>
    end_op();
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	4a8080e7          	jalr	1192(ra) # 80004986 <end_op>
  }
  return -1;
    800054e6:	557d                	li	a0,-1
}
    800054e8:	21813083          	ld	ra,536(sp)
    800054ec:	21013403          	ld	s0,528(sp)
    800054f0:	20813483          	ld	s1,520(sp)
    800054f4:	20013903          	ld	s2,512(sp)
    800054f8:	79fe                	ld	s3,504(sp)
    800054fa:	7a5e                	ld	s4,496(sp)
    800054fc:	7abe                	ld	s5,488(sp)
    800054fe:	7b1e                	ld	s6,480(sp)
    80005500:	6bfe                	ld	s7,472(sp)
    80005502:	6c5e                	ld	s8,464(sp)
    80005504:	6cbe                	ld	s9,456(sp)
    80005506:	6d1e                	ld	s10,448(sp)
    80005508:	7dfa                	ld	s11,440(sp)
    8000550a:	22010113          	addi	sp,sp,544
    8000550e:	8082                	ret
    end_op();
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	476080e7          	jalr	1142(ra) # 80004986 <end_op>
    return -1;
    80005518:	557d                	li	a0,-1
    8000551a:	b7f9                	j	800054e8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000551c:	8526                	mv	a0,s1
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	7b6080e7          	jalr	1974(ra) # 80001cd4 <proc_pagetable>
    80005526:	8b2a                	mv	s6,a0
    80005528:	d555                	beqz	a0,800054d4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000552a:	e7042783          	lw	a5,-400(s0)
    8000552e:	e8845703          	lhu	a4,-376(s0)
    80005532:	c735                	beqz	a4,8000559e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005534:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005536:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000553a:	6a05                	lui	s4,0x1
    8000553c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005540:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005544:	6d85                	lui	s11,0x1
    80005546:	7d7d                	lui	s10,0xfffff
    80005548:	a481                	j	80005788 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000554a:	00003517          	auipc	a0,0x3
    8000554e:	22650513          	addi	a0,a0,550 # 80008770 <syscalls+0x290>
    80005552:	ffffb097          	auipc	ra,0xffffb
    80005556:	0ba080e7          	jalr	186(ra) # 8000060c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000555a:	874a                	mv	a4,s2
    8000555c:	009c86bb          	addw	a3,s9,s1
    80005560:	4581                	li	a1,0
    80005562:	8556                	mv	a0,s5
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	c94080e7          	jalr	-876(ra) # 800041f8 <readi>
    8000556c:	2501                	sext.w	a0,a0
    8000556e:	1aa91a63          	bne	s2,a0,80005722 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80005572:	009d84bb          	addw	s1,s11,s1
    80005576:	013d09bb          	addw	s3,s10,s3
    8000557a:	1f74f763          	bgeu	s1,s7,80005768 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    8000557e:	02049593          	slli	a1,s1,0x20
    80005582:	9181                	srli	a1,a1,0x20
    80005584:	95e2                	add	a1,a1,s8
    80005586:	855a                	mv	a0,s6
    80005588:	ffffc097          	auipc	ra,0xffffc
    8000558c:	d32080e7          	jalr	-718(ra) # 800012ba <walkaddr>
    80005590:	862a                	mv	a2,a0
    if(pa == 0)
    80005592:	dd45                	beqz	a0,8000554a <exec+0xfe>
      n = PGSIZE;
    80005594:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005596:	fd49f2e3          	bgeu	s3,s4,8000555a <exec+0x10e>
      n = sz - i;
    8000559a:	894e                	mv	s2,s3
    8000559c:	bf7d                	j	8000555a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000559e:	4901                	li	s2,0
  iunlockput(ip);
    800055a0:	8556                	mv	a0,s5
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	c04080e7          	jalr	-1020(ra) # 800041a6 <iunlockput>
  end_op();
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	3dc080e7          	jalr	988(ra) # 80004986 <end_op>
  p = myproc();
    800055b2:	ffffc097          	auipc	ra,0xffffc
    800055b6:	65e080e7          	jalr	1630(ra) # 80001c10 <myproc>
    800055ba:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800055bc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800055c0:	6785                	lui	a5,0x1
    800055c2:	17fd                	addi	a5,a5,-1
    800055c4:	993e                	add	s2,s2,a5
    800055c6:	77fd                	lui	a5,0xfffff
    800055c8:	00f977b3          	and	a5,s2,a5
    800055cc:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055d0:	4691                	li	a3,4
    800055d2:	6609                	lui	a2,0x2
    800055d4:	963e                	add	a2,a2,a5
    800055d6:	85be                	mv	a1,a5
    800055d8:	855a                	mv	a0,s6
    800055da:	ffffc097          	auipc	ra,0xffffc
    800055de:	094080e7          	jalr	148(ra) # 8000166e <uvmalloc>
    800055e2:	8c2a                	mv	s8,a0
  ip = 0;
    800055e4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055e6:	12050e63          	beqz	a0,80005722 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800055ea:	75f9                	lui	a1,0xffffe
    800055ec:	95aa                	add	a1,a1,a0
    800055ee:	855a                	mv	a0,s6
    800055f0:	ffffc097          	auipc	ra,0xffffc
    800055f4:	2a4080e7          	jalr	676(ra) # 80001894 <uvmclear>
  stackbase = sp - PGSIZE;
    800055f8:	7afd                	lui	s5,0xfffff
    800055fa:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800055fc:	df043783          	ld	a5,-528(s0)
    80005600:	6388                	ld	a0,0(a5)
    80005602:	c925                	beqz	a0,80005672 <exec+0x226>
    80005604:	e9040993          	addi	s3,s0,-368
    80005608:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000560c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000560e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005610:	ffffc097          	auipc	ra,0xffffc
    80005614:	a9c080e7          	jalr	-1380(ra) # 800010ac <strlen>
    80005618:	0015079b          	addiw	a5,a0,1
    8000561c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005620:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005624:	13596663          	bltu	s2,s5,80005750 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005628:	df043d83          	ld	s11,-528(s0)
    8000562c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005630:	8552                	mv	a0,s4
    80005632:	ffffc097          	auipc	ra,0xffffc
    80005636:	a7a080e7          	jalr	-1414(ra) # 800010ac <strlen>
    8000563a:	0015069b          	addiw	a3,a0,1
    8000563e:	8652                	mv	a2,s4
    80005640:	85ca                	mv	a1,s2
    80005642:	855a                	mv	a0,s6
    80005644:	ffffc097          	auipc	ra,0xffffc
    80005648:	282080e7          	jalr	642(ra) # 800018c6 <copyout>
    8000564c:	10054663          	bltz	a0,80005758 <exec+0x30c>
    ustack[argc] = sp;
    80005650:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005654:	0485                	addi	s1,s1,1
    80005656:	008d8793          	addi	a5,s11,8
    8000565a:	def43823          	sd	a5,-528(s0)
    8000565e:	008db503          	ld	a0,8(s11)
    80005662:	c911                	beqz	a0,80005676 <exec+0x22a>
    if(argc >= MAXARG)
    80005664:	09a1                	addi	s3,s3,8
    80005666:	fb3c95e3          	bne	s9,s3,80005610 <exec+0x1c4>
  sz = sz1;
    8000566a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000566e:	4a81                	li	s5,0
    80005670:	a84d                	j	80005722 <exec+0x2d6>
  sp = sz;
    80005672:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005674:	4481                	li	s1,0
  ustack[argc] = 0;
    80005676:	00349793          	slli	a5,s1,0x3
    8000567a:	f9040713          	addi	a4,s0,-112
    8000567e:	97ba                	add	a5,a5,a4
    80005680:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffbbeb8>
  sp -= (argc+1) * sizeof(uint64);
    80005684:	00148693          	addi	a3,s1,1
    80005688:	068e                	slli	a3,a3,0x3
    8000568a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000568e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005692:	01597663          	bgeu	s2,s5,8000569e <exec+0x252>
  sz = sz1;
    80005696:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000569a:	4a81                	li	s5,0
    8000569c:	a059                	j	80005722 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000569e:	e9040613          	addi	a2,s0,-368
    800056a2:	85ca                	mv	a1,s2
    800056a4:	855a                	mv	a0,s6
    800056a6:	ffffc097          	auipc	ra,0xffffc
    800056aa:	220080e7          	jalr	544(ra) # 800018c6 <copyout>
    800056ae:	0a054963          	bltz	a0,80005760 <exec+0x314>
  p->trapframe->a1 = sp;
    800056b2:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800056b6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800056ba:	de843783          	ld	a5,-536(s0)
    800056be:	0007c703          	lbu	a4,0(a5)
    800056c2:	cf11                	beqz	a4,800056de <exec+0x292>
    800056c4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800056c6:	02f00693          	li	a3,47
    800056ca:	a039                	j	800056d8 <exec+0x28c>
      last = s+1;
    800056cc:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800056d0:	0785                	addi	a5,a5,1
    800056d2:	fff7c703          	lbu	a4,-1(a5)
    800056d6:	c701                	beqz	a4,800056de <exec+0x292>
    if(*s == '/')
    800056d8:	fed71ce3          	bne	a4,a3,800056d0 <exec+0x284>
    800056dc:	bfc5                	j	800056cc <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800056de:	4641                	li	a2,16
    800056e0:	de843583          	ld	a1,-536(s0)
    800056e4:	158b8513          	addi	a0,s7,344
    800056e8:	ffffc097          	auipc	ra,0xffffc
    800056ec:	992080e7          	jalr	-1646(ra) # 8000107a <safestrcpy>
  oldpagetable = p->pagetable;
    800056f0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800056f4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800056f8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800056fc:	058bb783          	ld	a5,88(s7)
    80005700:	e6843703          	ld	a4,-408(s0)
    80005704:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005706:	058bb783          	ld	a5,88(s7)
    8000570a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000570e:	85ea                	mv	a1,s10
    80005710:	ffffc097          	auipc	ra,0xffffc
    80005714:	660080e7          	jalr	1632(ra) # 80001d70 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005718:	0004851b          	sext.w	a0,s1
    8000571c:	b3f1                	j	800054e8 <exec+0x9c>
    8000571e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005722:	df843583          	ld	a1,-520(s0)
    80005726:	855a                	mv	a0,s6
    80005728:	ffffc097          	auipc	ra,0xffffc
    8000572c:	648080e7          	jalr	1608(ra) # 80001d70 <proc_freepagetable>
  if(ip){
    80005730:	da0a92e3          	bnez	s5,800054d4 <exec+0x88>
  return -1;
    80005734:	557d                	li	a0,-1
    80005736:	bb4d                	j	800054e8 <exec+0x9c>
    80005738:	df243c23          	sd	s2,-520(s0)
    8000573c:	b7dd                	j	80005722 <exec+0x2d6>
    8000573e:	df243c23          	sd	s2,-520(s0)
    80005742:	b7c5                	j	80005722 <exec+0x2d6>
    80005744:	df243c23          	sd	s2,-520(s0)
    80005748:	bfe9                	j	80005722 <exec+0x2d6>
    8000574a:	df243c23          	sd	s2,-520(s0)
    8000574e:	bfd1                	j	80005722 <exec+0x2d6>
  sz = sz1;
    80005750:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005754:	4a81                	li	s5,0
    80005756:	b7f1                	j	80005722 <exec+0x2d6>
  sz = sz1;
    80005758:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000575c:	4a81                	li	s5,0
    8000575e:	b7d1                	j	80005722 <exec+0x2d6>
  sz = sz1;
    80005760:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005764:	4a81                	li	s5,0
    80005766:	bf75                	j	80005722 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005768:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000576c:	e0843783          	ld	a5,-504(s0)
    80005770:	0017869b          	addiw	a3,a5,1
    80005774:	e0d43423          	sd	a3,-504(s0)
    80005778:	e0043783          	ld	a5,-512(s0)
    8000577c:	0387879b          	addiw	a5,a5,56
    80005780:	e8845703          	lhu	a4,-376(s0)
    80005784:	e0e6dee3          	bge	a3,a4,800055a0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005788:	2781                	sext.w	a5,a5
    8000578a:	e0f43023          	sd	a5,-512(s0)
    8000578e:	03800713          	li	a4,56
    80005792:	86be                	mv	a3,a5
    80005794:	e1840613          	addi	a2,s0,-488
    80005798:	4581                	li	a1,0
    8000579a:	8556                	mv	a0,s5
    8000579c:	fffff097          	auipc	ra,0xfffff
    800057a0:	a5c080e7          	jalr	-1444(ra) # 800041f8 <readi>
    800057a4:	03800793          	li	a5,56
    800057a8:	f6f51be3          	bne	a0,a5,8000571e <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800057ac:	e1842783          	lw	a5,-488(s0)
    800057b0:	4705                	li	a4,1
    800057b2:	fae79de3          	bne	a5,a4,8000576c <exec+0x320>
    if(ph.memsz < ph.filesz)
    800057b6:	e4043483          	ld	s1,-448(s0)
    800057ba:	e3843783          	ld	a5,-456(s0)
    800057be:	f6f4ede3          	bltu	s1,a5,80005738 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800057c2:	e2843783          	ld	a5,-472(s0)
    800057c6:	94be                	add	s1,s1,a5
    800057c8:	f6f4ebe3          	bltu	s1,a5,8000573e <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800057cc:	de043703          	ld	a4,-544(s0)
    800057d0:	8ff9                	and	a5,a5,a4
    800057d2:	fbad                	bnez	a5,80005744 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800057d4:	e1c42503          	lw	a0,-484(s0)
    800057d8:	00000097          	auipc	ra,0x0
    800057dc:	c58080e7          	jalr	-936(ra) # 80005430 <flags2perm>
    800057e0:	86aa                	mv	a3,a0
    800057e2:	8626                	mv	a2,s1
    800057e4:	85ca                	mv	a1,s2
    800057e6:	855a                	mv	a0,s6
    800057e8:	ffffc097          	auipc	ra,0xffffc
    800057ec:	e86080e7          	jalr	-378(ra) # 8000166e <uvmalloc>
    800057f0:	dea43c23          	sd	a0,-520(s0)
    800057f4:	d939                	beqz	a0,8000574a <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800057f6:	e2843c03          	ld	s8,-472(s0)
    800057fa:	e2042c83          	lw	s9,-480(s0)
    800057fe:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005802:	f60b83e3          	beqz	s7,80005768 <exec+0x31c>
    80005806:	89de                	mv	s3,s7
    80005808:	4481                	li	s1,0
    8000580a:	bb95                	j	8000557e <exec+0x132>

000000008000580c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000580c:	7179                	addi	sp,sp,-48
    8000580e:	f406                	sd	ra,40(sp)
    80005810:	f022                	sd	s0,32(sp)
    80005812:	ec26                	sd	s1,24(sp)
    80005814:	e84a                	sd	s2,16(sp)
    80005816:	1800                	addi	s0,sp,48
    80005818:	892e                	mv	s2,a1
    8000581a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000581c:	fdc40593          	addi	a1,s0,-36
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	aea080e7          	jalr	-1302(ra) # 8000330a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005828:	fdc42703          	lw	a4,-36(s0)
    8000582c:	47bd                	li	a5,15
    8000582e:	02e7eb63          	bltu	a5,a4,80005864 <argfd+0x58>
    80005832:	ffffc097          	auipc	ra,0xffffc
    80005836:	3de080e7          	jalr	990(ra) # 80001c10 <myproc>
    8000583a:	fdc42703          	lw	a4,-36(s0)
    8000583e:	01a70793          	addi	a5,a4,26
    80005842:	078e                	slli	a5,a5,0x3
    80005844:	953e                	add	a0,a0,a5
    80005846:	611c                	ld	a5,0(a0)
    80005848:	c385                	beqz	a5,80005868 <argfd+0x5c>
    return -1;
  if(pfd)
    8000584a:	00090463          	beqz	s2,80005852 <argfd+0x46>
    *pfd = fd;
    8000584e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005852:	4501                	li	a0,0
  if(pf)
    80005854:	c091                	beqz	s1,80005858 <argfd+0x4c>
    *pf = f;
    80005856:	e09c                	sd	a5,0(s1)
}
    80005858:	70a2                	ld	ra,40(sp)
    8000585a:	7402                	ld	s0,32(sp)
    8000585c:	64e2                	ld	s1,24(sp)
    8000585e:	6942                	ld	s2,16(sp)
    80005860:	6145                	addi	sp,sp,48
    80005862:	8082                	ret
    return -1;
    80005864:	557d                	li	a0,-1
    80005866:	bfcd                	j	80005858 <argfd+0x4c>
    80005868:	557d                	li	a0,-1
    8000586a:	b7fd                	j	80005858 <argfd+0x4c>

000000008000586c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000586c:	1101                	addi	sp,sp,-32
    8000586e:	ec06                	sd	ra,24(sp)
    80005870:	e822                	sd	s0,16(sp)
    80005872:	e426                	sd	s1,8(sp)
    80005874:	1000                	addi	s0,sp,32
    80005876:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005878:	ffffc097          	auipc	ra,0xffffc
    8000587c:	398080e7          	jalr	920(ra) # 80001c10 <myproc>
    80005880:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005882:	0d050793          	addi	a5,a0,208
    80005886:	4501                	li	a0,0
    80005888:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000588a:	6398                	ld	a4,0(a5)
    8000588c:	cb19                	beqz	a4,800058a2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000588e:	2505                	addiw	a0,a0,1
    80005890:	07a1                	addi	a5,a5,8
    80005892:	fed51ce3          	bne	a0,a3,8000588a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005896:	557d                	li	a0,-1
}
    80005898:	60e2                	ld	ra,24(sp)
    8000589a:	6442                	ld	s0,16(sp)
    8000589c:	64a2                	ld	s1,8(sp)
    8000589e:	6105                	addi	sp,sp,32
    800058a0:	8082                	ret
      p->ofile[fd] = f;
    800058a2:	01a50793          	addi	a5,a0,26
    800058a6:	078e                	slli	a5,a5,0x3
    800058a8:	963e                	add	a2,a2,a5
    800058aa:	e204                	sd	s1,0(a2)
      return fd;
    800058ac:	b7f5                	j	80005898 <fdalloc+0x2c>

00000000800058ae <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800058ae:	715d                	addi	sp,sp,-80
    800058b0:	e486                	sd	ra,72(sp)
    800058b2:	e0a2                	sd	s0,64(sp)
    800058b4:	fc26                	sd	s1,56(sp)
    800058b6:	f84a                	sd	s2,48(sp)
    800058b8:	f44e                	sd	s3,40(sp)
    800058ba:	f052                	sd	s4,32(sp)
    800058bc:	ec56                	sd	s5,24(sp)
    800058be:	e85a                	sd	s6,16(sp)
    800058c0:	0880                	addi	s0,sp,80
    800058c2:	8b2e                	mv	s6,a1
    800058c4:	89b2                	mv	s3,a2
    800058c6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800058c8:	fb040593          	addi	a1,s0,-80
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	e3c080e7          	jalr	-452(ra) # 80004708 <nameiparent>
    800058d4:	84aa                	mv	s1,a0
    800058d6:	14050f63          	beqz	a0,80005a34 <create+0x186>
    return 0;

  ilock(dp);
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	66a080e7          	jalr	1642(ra) # 80003f44 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800058e2:	4601                	li	a2,0
    800058e4:	fb040593          	addi	a1,s0,-80
    800058e8:	8526                	mv	a0,s1
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	b3e080e7          	jalr	-1218(ra) # 80004428 <dirlookup>
    800058f2:	8aaa                	mv	s5,a0
    800058f4:	c931                	beqz	a0,80005948 <create+0x9a>
    iunlockput(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	8ae080e7          	jalr	-1874(ra) # 800041a6 <iunlockput>
    ilock(ip);
    80005900:	8556                	mv	a0,s5
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	642080e7          	jalr	1602(ra) # 80003f44 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000590a:	000b059b          	sext.w	a1,s6
    8000590e:	4789                	li	a5,2
    80005910:	02f59563          	bne	a1,a5,8000593a <create+0x8c>
    80005914:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffbbffc>
    80005918:	37f9                	addiw	a5,a5,-2
    8000591a:	17c2                	slli	a5,a5,0x30
    8000591c:	93c1                	srli	a5,a5,0x30
    8000591e:	4705                	li	a4,1
    80005920:	00f76d63          	bltu	a4,a5,8000593a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005924:	8556                	mv	a0,s5
    80005926:	60a6                	ld	ra,72(sp)
    80005928:	6406                	ld	s0,64(sp)
    8000592a:	74e2                	ld	s1,56(sp)
    8000592c:	7942                	ld	s2,48(sp)
    8000592e:	79a2                	ld	s3,40(sp)
    80005930:	7a02                	ld	s4,32(sp)
    80005932:	6ae2                	ld	s5,24(sp)
    80005934:	6b42                	ld	s6,16(sp)
    80005936:	6161                	addi	sp,sp,80
    80005938:	8082                	ret
    iunlockput(ip);
    8000593a:	8556                	mv	a0,s5
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	86a080e7          	jalr	-1942(ra) # 800041a6 <iunlockput>
    return 0;
    80005944:	4a81                	li	s5,0
    80005946:	bff9                	j	80005924 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005948:	85da                	mv	a1,s6
    8000594a:	4088                	lw	a0,0(s1)
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	45c080e7          	jalr	1116(ra) # 80003da8 <ialloc>
    80005954:	8a2a                	mv	s4,a0
    80005956:	c539                	beqz	a0,800059a4 <create+0xf6>
  ilock(ip);
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	5ec080e7          	jalr	1516(ra) # 80003f44 <ilock>
  ip->major = major;
    80005960:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005964:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005968:	4905                	li	s2,1
    8000596a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000596e:	8552                	mv	a0,s4
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	50a080e7          	jalr	1290(ra) # 80003e7a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005978:	000b059b          	sext.w	a1,s6
    8000597c:	03258b63          	beq	a1,s2,800059b2 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005980:	004a2603          	lw	a2,4(s4)
    80005984:	fb040593          	addi	a1,s0,-80
    80005988:	8526                	mv	a0,s1
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	cae080e7          	jalr	-850(ra) # 80004638 <dirlink>
    80005992:	06054f63          	bltz	a0,80005a10 <create+0x162>
  iunlockput(dp);
    80005996:	8526                	mv	a0,s1
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	80e080e7          	jalr	-2034(ra) # 800041a6 <iunlockput>
  return ip;
    800059a0:	8ad2                	mv	s5,s4
    800059a2:	b749                	j	80005924 <create+0x76>
    iunlockput(dp);
    800059a4:	8526                	mv	a0,s1
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	800080e7          	jalr	-2048(ra) # 800041a6 <iunlockput>
    return 0;
    800059ae:	8ad2                	mv	s5,s4
    800059b0:	bf95                	j	80005924 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800059b2:	004a2603          	lw	a2,4(s4)
    800059b6:	00003597          	auipc	a1,0x3
    800059ba:	dda58593          	addi	a1,a1,-550 # 80008790 <syscalls+0x2b0>
    800059be:	8552                	mv	a0,s4
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	c78080e7          	jalr	-904(ra) # 80004638 <dirlink>
    800059c8:	04054463          	bltz	a0,80005a10 <create+0x162>
    800059cc:	40d0                	lw	a2,4(s1)
    800059ce:	00003597          	auipc	a1,0x3
    800059d2:	dca58593          	addi	a1,a1,-566 # 80008798 <syscalls+0x2b8>
    800059d6:	8552                	mv	a0,s4
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	c60080e7          	jalr	-928(ra) # 80004638 <dirlink>
    800059e0:	02054863          	bltz	a0,80005a10 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800059e4:	004a2603          	lw	a2,4(s4)
    800059e8:	fb040593          	addi	a1,s0,-80
    800059ec:	8526                	mv	a0,s1
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	c4a080e7          	jalr	-950(ra) # 80004638 <dirlink>
    800059f6:	00054d63          	bltz	a0,80005a10 <create+0x162>
    dp->nlink++;  // for ".."
    800059fa:	04a4d783          	lhu	a5,74(s1)
    800059fe:	2785                	addiw	a5,a5,1
    80005a00:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a04:	8526                	mv	a0,s1
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	474080e7          	jalr	1140(ra) # 80003e7a <iupdate>
    80005a0e:	b761                	j	80005996 <create+0xe8>
  ip->nlink = 0;
    80005a10:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005a14:	8552                	mv	a0,s4
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	464080e7          	jalr	1124(ra) # 80003e7a <iupdate>
  iunlockput(ip);
    80005a1e:	8552                	mv	a0,s4
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	786080e7          	jalr	1926(ra) # 800041a6 <iunlockput>
  iunlockput(dp);
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	77c080e7          	jalr	1916(ra) # 800041a6 <iunlockput>
  return 0;
    80005a32:	bdcd                	j	80005924 <create+0x76>
    return 0;
    80005a34:	8aaa                	mv	s5,a0
    80005a36:	b5fd                	j	80005924 <create+0x76>

0000000080005a38 <sys_dup>:
{
    80005a38:	7179                	addi	sp,sp,-48
    80005a3a:	f406                	sd	ra,40(sp)
    80005a3c:	f022                	sd	s0,32(sp)
    80005a3e:	ec26                	sd	s1,24(sp)
    80005a40:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a42:	fd840613          	addi	a2,s0,-40
    80005a46:	4581                	li	a1,0
    80005a48:	4501                	li	a0,0
    80005a4a:	00000097          	auipc	ra,0x0
    80005a4e:	dc2080e7          	jalr	-574(ra) # 8000580c <argfd>
    return -1;
    80005a52:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a54:	02054363          	bltz	a0,80005a7a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005a58:	fd843503          	ld	a0,-40(s0)
    80005a5c:	00000097          	auipc	ra,0x0
    80005a60:	e10080e7          	jalr	-496(ra) # 8000586c <fdalloc>
    80005a64:	84aa                	mv	s1,a0
    return -1;
    80005a66:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a68:	00054963          	bltz	a0,80005a7a <sys_dup+0x42>
  filedup(f);
    80005a6c:	fd843503          	ld	a0,-40(s0)
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	310080e7          	jalr	784(ra) # 80004d80 <filedup>
  return fd;
    80005a78:	87a6                	mv	a5,s1
}
    80005a7a:	853e                	mv	a0,a5
    80005a7c:	70a2                	ld	ra,40(sp)
    80005a7e:	7402                	ld	s0,32(sp)
    80005a80:	64e2                	ld	s1,24(sp)
    80005a82:	6145                	addi	sp,sp,48
    80005a84:	8082                	ret

0000000080005a86 <sys_read>:
{
    80005a86:	7179                	addi	sp,sp,-48
    80005a88:	f406                	sd	ra,40(sp)
    80005a8a:	f022                	sd	s0,32(sp)
    80005a8c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a8e:	fd840593          	addi	a1,s0,-40
    80005a92:	4505                	li	a0,1
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	896080e7          	jalr	-1898(ra) # 8000332a <argaddr>
  argint(2, &n);
    80005a9c:	fe440593          	addi	a1,s0,-28
    80005aa0:	4509                	li	a0,2
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	868080e7          	jalr	-1944(ra) # 8000330a <argint>
  if(argfd(0, 0, &f) < 0)
    80005aaa:	fe840613          	addi	a2,s0,-24
    80005aae:	4581                	li	a1,0
    80005ab0:	4501                	li	a0,0
    80005ab2:	00000097          	auipc	ra,0x0
    80005ab6:	d5a080e7          	jalr	-678(ra) # 8000580c <argfd>
    80005aba:	87aa                	mv	a5,a0
    return -1;
    80005abc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005abe:	0007cc63          	bltz	a5,80005ad6 <sys_read+0x50>
  return fileread(f, p, n);
    80005ac2:	fe442603          	lw	a2,-28(s0)
    80005ac6:	fd843583          	ld	a1,-40(s0)
    80005aca:	fe843503          	ld	a0,-24(s0)
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	43e080e7          	jalr	1086(ra) # 80004f0c <fileread>
}
    80005ad6:	70a2                	ld	ra,40(sp)
    80005ad8:	7402                	ld	s0,32(sp)
    80005ada:	6145                	addi	sp,sp,48
    80005adc:	8082                	ret

0000000080005ade <sys_write>:
{
    80005ade:	7179                	addi	sp,sp,-48
    80005ae0:	f406                	sd	ra,40(sp)
    80005ae2:	f022                	sd	s0,32(sp)
    80005ae4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005ae6:	fd840593          	addi	a1,s0,-40
    80005aea:	4505                	li	a0,1
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	83e080e7          	jalr	-1986(ra) # 8000332a <argaddr>
  argint(2, &n);
    80005af4:	fe440593          	addi	a1,s0,-28
    80005af8:	4509                	li	a0,2
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	810080e7          	jalr	-2032(ra) # 8000330a <argint>
  if(argfd(0, 0, &f) < 0)
    80005b02:	fe840613          	addi	a2,s0,-24
    80005b06:	4581                	li	a1,0
    80005b08:	4501                	li	a0,0
    80005b0a:	00000097          	auipc	ra,0x0
    80005b0e:	d02080e7          	jalr	-766(ra) # 8000580c <argfd>
    80005b12:	87aa                	mv	a5,a0
    return -1;
    80005b14:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b16:	0007cc63          	bltz	a5,80005b2e <sys_write+0x50>
  return filewrite(f, p, n);
    80005b1a:	fe442603          	lw	a2,-28(s0)
    80005b1e:	fd843583          	ld	a1,-40(s0)
    80005b22:	fe843503          	ld	a0,-24(s0)
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	4a8080e7          	jalr	1192(ra) # 80004fce <filewrite>
}
    80005b2e:	70a2                	ld	ra,40(sp)
    80005b30:	7402                	ld	s0,32(sp)
    80005b32:	6145                	addi	sp,sp,48
    80005b34:	8082                	ret

0000000080005b36 <sys_close>:
{
    80005b36:	1101                	addi	sp,sp,-32
    80005b38:	ec06                	sd	ra,24(sp)
    80005b3a:	e822                	sd	s0,16(sp)
    80005b3c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b3e:	fe040613          	addi	a2,s0,-32
    80005b42:	fec40593          	addi	a1,s0,-20
    80005b46:	4501                	li	a0,0
    80005b48:	00000097          	auipc	ra,0x0
    80005b4c:	cc4080e7          	jalr	-828(ra) # 8000580c <argfd>
    return -1;
    80005b50:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005b52:	02054463          	bltz	a0,80005b7a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b56:	ffffc097          	auipc	ra,0xffffc
    80005b5a:	0ba080e7          	jalr	186(ra) # 80001c10 <myproc>
    80005b5e:	fec42783          	lw	a5,-20(s0)
    80005b62:	07e9                	addi	a5,a5,26
    80005b64:	078e                	slli	a5,a5,0x3
    80005b66:	97aa                	add	a5,a5,a0
    80005b68:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005b6c:	fe043503          	ld	a0,-32(s0)
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	262080e7          	jalr	610(ra) # 80004dd2 <fileclose>
  return 0;
    80005b78:	4781                	li	a5,0
}
    80005b7a:	853e                	mv	a0,a5
    80005b7c:	60e2                	ld	ra,24(sp)
    80005b7e:	6442                	ld	s0,16(sp)
    80005b80:	6105                	addi	sp,sp,32
    80005b82:	8082                	ret

0000000080005b84 <sys_fstat>:
{
    80005b84:	1101                	addi	sp,sp,-32
    80005b86:	ec06                	sd	ra,24(sp)
    80005b88:	e822                	sd	s0,16(sp)
    80005b8a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b8c:	fe040593          	addi	a1,s0,-32
    80005b90:	4505                	li	a0,1
    80005b92:	ffffd097          	auipc	ra,0xffffd
    80005b96:	798080e7          	jalr	1944(ra) # 8000332a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b9a:	fe840613          	addi	a2,s0,-24
    80005b9e:	4581                	li	a1,0
    80005ba0:	4501                	li	a0,0
    80005ba2:	00000097          	auipc	ra,0x0
    80005ba6:	c6a080e7          	jalr	-918(ra) # 8000580c <argfd>
    80005baa:	87aa                	mv	a5,a0
    return -1;
    80005bac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bae:	0007ca63          	bltz	a5,80005bc2 <sys_fstat+0x3e>
  return filestat(f, st);
    80005bb2:	fe043583          	ld	a1,-32(s0)
    80005bb6:	fe843503          	ld	a0,-24(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	2e0080e7          	jalr	736(ra) # 80004e9a <filestat>
}
    80005bc2:	60e2                	ld	ra,24(sp)
    80005bc4:	6442                	ld	s0,16(sp)
    80005bc6:	6105                	addi	sp,sp,32
    80005bc8:	8082                	ret

0000000080005bca <sys_link>:
{
    80005bca:	7169                	addi	sp,sp,-304
    80005bcc:	f606                	sd	ra,296(sp)
    80005bce:	f222                	sd	s0,288(sp)
    80005bd0:	ee26                	sd	s1,280(sp)
    80005bd2:	ea4a                	sd	s2,272(sp)
    80005bd4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bd6:	08000613          	li	a2,128
    80005bda:	ed040593          	addi	a1,s0,-304
    80005bde:	4501                	li	a0,0
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	76a080e7          	jalr	1898(ra) # 8000334a <argstr>
    return -1;
    80005be8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bea:	10054e63          	bltz	a0,80005d06 <sys_link+0x13c>
    80005bee:	08000613          	li	a2,128
    80005bf2:	f5040593          	addi	a1,s0,-176
    80005bf6:	4505                	li	a0,1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	752080e7          	jalr	1874(ra) # 8000334a <argstr>
    return -1;
    80005c00:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c02:	10054263          	bltz	a0,80005d06 <sys_link+0x13c>
  begin_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	d00080e7          	jalr	-768(ra) # 80004906 <begin_op>
  if((ip = namei(old)) == 0){
    80005c0e:	ed040513          	addi	a0,s0,-304
    80005c12:	fffff097          	auipc	ra,0xfffff
    80005c16:	ad8080e7          	jalr	-1320(ra) # 800046ea <namei>
    80005c1a:	84aa                	mv	s1,a0
    80005c1c:	c551                	beqz	a0,80005ca8 <sys_link+0xde>
  ilock(ip);
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	326080e7          	jalr	806(ra) # 80003f44 <ilock>
  if(ip->type == T_DIR){
    80005c26:	04449703          	lh	a4,68(s1)
    80005c2a:	4785                	li	a5,1
    80005c2c:	08f70463          	beq	a4,a5,80005cb4 <sys_link+0xea>
  ip->nlink++;
    80005c30:	04a4d783          	lhu	a5,74(s1)
    80005c34:	2785                	addiw	a5,a5,1
    80005c36:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	23e080e7          	jalr	574(ra) # 80003e7a <iupdate>
  iunlock(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	3c0080e7          	jalr	960(ra) # 80004006 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005c4e:	fd040593          	addi	a1,s0,-48
    80005c52:	f5040513          	addi	a0,s0,-176
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	ab2080e7          	jalr	-1358(ra) # 80004708 <nameiparent>
    80005c5e:	892a                	mv	s2,a0
    80005c60:	c935                	beqz	a0,80005cd4 <sys_link+0x10a>
  ilock(dp);
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	2e2080e7          	jalr	738(ra) # 80003f44 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005c6a:	00092703          	lw	a4,0(s2)
    80005c6e:	409c                	lw	a5,0(s1)
    80005c70:	04f71d63          	bne	a4,a5,80005cca <sys_link+0x100>
    80005c74:	40d0                	lw	a2,4(s1)
    80005c76:	fd040593          	addi	a1,s0,-48
    80005c7a:	854a                	mv	a0,s2
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	9bc080e7          	jalr	-1604(ra) # 80004638 <dirlink>
    80005c84:	04054363          	bltz	a0,80005cca <sys_link+0x100>
  iunlockput(dp);
    80005c88:	854a                	mv	a0,s2
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	51c080e7          	jalr	1308(ra) # 800041a6 <iunlockput>
  iput(ip);
    80005c92:	8526                	mv	a0,s1
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	46a080e7          	jalr	1130(ra) # 800040fe <iput>
  end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	cea080e7          	jalr	-790(ra) # 80004986 <end_op>
  return 0;
    80005ca4:	4781                	li	a5,0
    80005ca6:	a085                	j	80005d06 <sys_link+0x13c>
    end_op();
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	cde080e7          	jalr	-802(ra) # 80004986 <end_op>
    return -1;
    80005cb0:	57fd                	li	a5,-1
    80005cb2:	a891                	j	80005d06 <sys_link+0x13c>
    iunlockput(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	ffffe097          	auipc	ra,0xffffe
    80005cba:	4f0080e7          	jalr	1264(ra) # 800041a6 <iunlockput>
    end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	cc8080e7          	jalr	-824(ra) # 80004986 <end_op>
    return -1;
    80005cc6:	57fd                	li	a5,-1
    80005cc8:	a83d                	j	80005d06 <sys_link+0x13c>
    iunlockput(dp);
    80005cca:	854a                	mv	a0,s2
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	4da080e7          	jalr	1242(ra) # 800041a6 <iunlockput>
  ilock(ip);
    80005cd4:	8526                	mv	a0,s1
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	26e080e7          	jalr	622(ra) # 80003f44 <ilock>
  ip->nlink--;
    80005cde:	04a4d783          	lhu	a5,74(s1)
    80005ce2:	37fd                	addiw	a5,a5,-1
    80005ce4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ce8:	8526                	mv	a0,s1
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	190080e7          	jalr	400(ra) # 80003e7a <iupdate>
  iunlockput(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	4b2080e7          	jalr	1202(ra) # 800041a6 <iunlockput>
  end_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	c8a080e7          	jalr	-886(ra) # 80004986 <end_op>
  return -1;
    80005d04:	57fd                	li	a5,-1
}
    80005d06:	853e                	mv	a0,a5
    80005d08:	70b2                	ld	ra,296(sp)
    80005d0a:	7412                	ld	s0,288(sp)
    80005d0c:	64f2                	ld	s1,280(sp)
    80005d0e:	6952                	ld	s2,272(sp)
    80005d10:	6155                	addi	sp,sp,304
    80005d12:	8082                	ret

0000000080005d14 <sys_unlink>:
{
    80005d14:	7151                	addi	sp,sp,-240
    80005d16:	f586                	sd	ra,232(sp)
    80005d18:	f1a2                	sd	s0,224(sp)
    80005d1a:	eda6                	sd	s1,216(sp)
    80005d1c:	e9ca                	sd	s2,208(sp)
    80005d1e:	e5ce                	sd	s3,200(sp)
    80005d20:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d22:	08000613          	li	a2,128
    80005d26:	f3040593          	addi	a1,s0,-208
    80005d2a:	4501                	li	a0,0
    80005d2c:	ffffd097          	auipc	ra,0xffffd
    80005d30:	61e080e7          	jalr	1566(ra) # 8000334a <argstr>
    80005d34:	18054163          	bltz	a0,80005eb6 <sys_unlink+0x1a2>
  begin_op();
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	bce080e7          	jalr	-1074(ra) # 80004906 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d40:	fb040593          	addi	a1,s0,-80
    80005d44:	f3040513          	addi	a0,s0,-208
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	9c0080e7          	jalr	-1600(ra) # 80004708 <nameiparent>
    80005d50:	84aa                	mv	s1,a0
    80005d52:	c979                	beqz	a0,80005e28 <sys_unlink+0x114>
  ilock(dp);
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	1f0080e7          	jalr	496(ra) # 80003f44 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d5c:	00003597          	auipc	a1,0x3
    80005d60:	a3458593          	addi	a1,a1,-1484 # 80008790 <syscalls+0x2b0>
    80005d64:	fb040513          	addi	a0,s0,-80
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	6a6080e7          	jalr	1702(ra) # 8000440e <namecmp>
    80005d70:	14050a63          	beqz	a0,80005ec4 <sys_unlink+0x1b0>
    80005d74:	00003597          	auipc	a1,0x3
    80005d78:	a2458593          	addi	a1,a1,-1500 # 80008798 <syscalls+0x2b8>
    80005d7c:	fb040513          	addi	a0,s0,-80
    80005d80:	ffffe097          	auipc	ra,0xffffe
    80005d84:	68e080e7          	jalr	1678(ra) # 8000440e <namecmp>
    80005d88:	12050e63          	beqz	a0,80005ec4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d8c:	f2c40613          	addi	a2,s0,-212
    80005d90:	fb040593          	addi	a1,s0,-80
    80005d94:	8526                	mv	a0,s1
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	692080e7          	jalr	1682(ra) # 80004428 <dirlookup>
    80005d9e:	892a                	mv	s2,a0
    80005da0:	12050263          	beqz	a0,80005ec4 <sys_unlink+0x1b0>
  ilock(ip);
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	1a0080e7          	jalr	416(ra) # 80003f44 <ilock>
  if(ip->nlink < 1)
    80005dac:	04a91783          	lh	a5,74(s2)
    80005db0:	08f05263          	blez	a5,80005e34 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005db4:	04491703          	lh	a4,68(s2)
    80005db8:	4785                	li	a5,1
    80005dba:	08f70563          	beq	a4,a5,80005e44 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005dbe:	4641                	li	a2,16
    80005dc0:	4581                	li	a1,0
    80005dc2:	fc040513          	addi	a0,s0,-64
    80005dc6:	ffffb097          	auipc	ra,0xffffb
    80005dca:	16a080e7          	jalr	362(ra) # 80000f30 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dce:	4741                	li	a4,16
    80005dd0:	f2c42683          	lw	a3,-212(s0)
    80005dd4:	fc040613          	addi	a2,s0,-64
    80005dd8:	4581                	li	a1,0
    80005dda:	8526                	mv	a0,s1
    80005ddc:	ffffe097          	auipc	ra,0xffffe
    80005de0:	514080e7          	jalr	1300(ra) # 800042f0 <writei>
    80005de4:	47c1                	li	a5,16
    80005de6:	0af51563          	bne	a0,a5,80005e90 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005dea:	04491703          	lh	a4,68(s2)
    80005dee:	4785                	li	a5,1
    80005df0:	0af70863          	beq	a4,a5,80005ea0 <sys_unlink+0x18c>
  iunlockput(dp);
    80005df4:	8526                	mv	a0,s1
    80005df6:	ffffe097          	auipc	ra,0xffffe
    80005dfa:	3b0080e7          	jalr	944(ra) # 800041a6 <iunlockput>
  ip->nlink--;
    80005dfe:	04a95783          	lhu	a5,74(s2)
    80005e02:	37fd                	addiw	a5,a5,-1
    80005e04:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e08:	854a                	mv	a0,s2
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	070080e7          	jalr	112(ra) # 80003e7a <iupdate>
  iunlockput(ip);
    80005e12:	854a                	mv	a0,s2
    80005e14:	ffffe097          	auipc	ra,0xffffe
    80005e18:	392080e7          	jalr	914(ra) # 800041a6 <iunlockput>
  end_op();
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	b6a080e7          	jalr	-1174(ra) # 80004986 <end_op>
  return 0;
    80005e24:	4501                	li	a0,0
    80005e26:	a84d                	j	80005ed8 <sys_unlink+0x1c4>
    end_op();
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	b5e080e7          	jalr	-1186(ra) # 80004986 <end_op>
    return -1;
    80005e30:	557d                	li	a0,-1
    80005e32:	a05d                	j	80005ed8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005e34:	00003517          	auipc	a0,0x3
    80005e38:	96c50513          	addi	a0,a0,-1684 # 800087a0 <syscalls+0x2c0>
    80005e3c:	ffffa097          	auipc	ra,0xffffa
    80005e40:	7d0080e7          	jalr	2000(ra) # 8000060c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e44:	04c92703          	lw	a4,76(s2)
    80005e48:	02000793          	li	a5,32
    80005e4c:	f6e7f9e3          	bgeu	a5,a4,80005dbe <sys_unlink+0xaa>
    80005e50:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e54:	4741                	li	a4,16
    80005e56:	86ce                	mv	a3,s3
    80005e58:	f1840613          	addi	a2,s0,-232
    80005e5c:	4581                	li	a1,0
    80005e5e:	854a                	mv	a0,s2
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	398080e7          	jalr	920(ra) # 800041f8 <readi>
    80005e68:	47c1                	li	a5,16
    80005e6a:	00f51b63          	bne	a0,a5,80005e80 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005e6e:	f1845783          	lhu	a5,-232(s0)
    80005e72:	e7a1                	bnez	a5,80005eba <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e74:	29c1                	addiw	s3,s3,16
    80005e76:	04c92783          	lw	a5,76(s2)
    80005e7a:	fcf9ede3          	bltu	s3,a5,80005e54 <sys_unlink+0x140>
    80005e7e:	b781                	j	80005dbe <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005e80:	00003517          	auipc	a0,0x3
    80005e84:	93850513          	addi	a0,a0,-1736 # 800087b8 <syscalls+0x2d8>
    80005e88:	ffffa097          	auipc	ra,0xffffa
    80005e8c:	784080e7          	jalr	1924(ra) # 8000060c <panic>
    panic("unlink: writei");
    80005e90:	00003517          	auipc	a0,0x3
    80005e94:	94050513          	addi	a0,a0,-1728 # 800087d0 <syscalls+0x2f0>
    80005e98:	ffffa097          	auipc	ra,0xffffa
    80005e9c:	774080e7          	jalr	1908(ra) # 8000060c <panic>
    dp->nlink--;
    80005ea0:	04a4d783          	lhu	a5,74(s1)
    80005ea4:	37fd                	addiw	a5,a5,-1
    80005ea6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005eaa:	8526                	mv	a0,s1
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	fce080e7          	jalr	-50(ra) # 80003e7a <iupdate>
    80005eb4:	b781                	j	80005df4 <sys_unlink+0xe0>
    return -1;
    80005eb6:	557d                	li	a0,-1
    80005eb8:	a005                	j	80005ed8 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005eba:	854a                	mv	a0,s2
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	2ea080e7          	jalr	746(ra) # 800041a6 <iunlockput>
  iunlockput(dp);
    80005ec4:	8526                	mv	a0,s1
    80005ec6:	ffffe097          	auipc	ra,0xffffe
    80005eca:	2e0080e7          	jalr	736(ra) # 800041a6 <iunlockput>
  end_op();
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	ab8080e7          	jalr	-1352(ra) # 80004986 <end_op>
  return -1;
    80005ed6:	557d                	li	a0,-1
}
    80005ed8:	70ae                	ld	ra,232(sp)
    80005eda:	740e                	ld	s0,224(sp)
    80005edc:	64ee                	ld	s1,216(sp)
    80005ede:	694e                	ld	s2,208(sp)
    80005ee0:	69ae                	ld	s3,200(sp)
    80005ee2:	616d                	addi	sp,sp,240
    80005ee4:	8082                	ret

0000000080005ee6 <sys_open>:

uint64
sys_open(void)
{
    80005ee6:	7131                	addi	sp,sp,-192
    80005ee8:	fd06                	sd	ra,184(sp)
    80005eea:	f922                	sd	s0,176(sp)
    80005eec:	f526                	sd	s1,168(sp)
    80005eee:	f14a                	sd	s2,160(sp)
    80005ef0:	ed4e                	sd	s3,152(sp)
    80005ef2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ef4:	f4c40593          	addi	a1,s0,-180
    80005ef8:	4505                	li	a0,1
    80005efa:	ffffd097          	auipc	ra,0xffffd
    80005efe:	410080e7          	jalr	1040(ra) # 8000330a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f02:	08000613          	li	a2,128
    80005f06:	f5040593          	addi	a1,s0,-176
    80005f0a:	4501                	li	a0,0
    80005f0c:	ffffd097          	auipc	ra,0xffffd
    80005f10:	43e080e7          	jalr	1086(ra) # 8000334a <argstr>
    80005f14:	87aa                	mv	a5,a0
    return -1;
    80005f16:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f18:	0a07c963          	bltz	a5,80005fca <sys_open+0xe4>

  begin_op();
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	9ea080e7          	jalr	-1558(ra) # 80004906 <begin_op>

  if(omode & O_CREATE){
    80005f24:	f4c42783          	lw	a5,-180(s0)
    80005f28:	2007f793          	andi	a5,a5,512
    80005f2c:	cfc5                	beqz	a5,80005fe4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005f2e:	4681                	li	a3,0
    80005f30:	4601                	li	a2,0
    80005f32:	4589                	li	a1,2
    80005f34:	f5040513          	addi	a0,s0,-176
    80005f38:	00000097          	auipc	ra,0x0
    80005f3c:	976080e7          	jalr	-1674(ra) # 800058ae <create>
    80005f40:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f42:	c959                	beqz	a0,80005fd8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f44:	04449703          	lh	a4,68(s1)
    80005f48:	478d                	li	a5,3
    80005f4a:	00f71763          	bne	a4,a5,80005f58 <sys_open+0x72>
    80005f4e:	0464d703          	lhu	a4,70(s1)
    80005f52:	47a5                	li	a5,9
    80005f54:	0ce7ed63          	bltu	a5,a4,8000602e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	dbe080e7          	jalr	-578(ra) # 80004d16 <filealloc>
    80005f60:	89aa                	mv	s3,a0
    80005f62:	10050363          	beqz	a0,80006068 <sys_open+0x182>
    80005f66:	00000097          	auipc	ra,0x0
    80005f6a:	906080e7          	jalr	-1786(ra) # 8000586c <fdalloc>
    80005f6e:	892a                	mv	s2,a0
    80005f70:	0e054763          	bltz	a0,8000605e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f74:	04449703          	lh	a4,68(s1)
    80005f78:	478d                	li	a5,3
    80005f7a:	0cf70563          	beq	a4,a5,80006044 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005f7e:	4789                	li	a5,2
    80005f80:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005f84:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005f88:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005f8c:	f4c42783          	lw	a5,-180(s0)
    80005f90:	0017c713          	xori	a4,a5,1
    80005f94:	8b05                	andi	a4,a4,1
    80005f96:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f9a:	0037f713          	andi	a4,a5,3
    80005f9e:	00e03733          	snez	a4,a4
    80005fa2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005fa6:	4007f793          	andi	a5,a5,1024
    80005faa:	c791                	beqz	a5,80005fb6 <sys_open+0xd0>
    80005fac:	04449703          	lh	a4,68(s1)
    80005fb0:	4789                	li	a5,2
    80005fb2:	0af70063          	beq	a4,a5,80006052 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005fb6:	8526                	mv	a0,s1
    80005fb8:	ffffe097          	auipc	ra,0xffffe
    80005fbc:	04e080e7          	jalr	78(ra) # 80004006 <iunlock>
  end_op();
    80005fc0:	fffff097          	auipc	ra,0xfffff
    80005fc4:	9c6080e7          	jalr	-1594(ra) # 80004986 <end_op>

  return fd;
    80005fc8:	854a                	mv	a0,s2
}
    80005fca:	70ea                	ld	ra,184(sp)
    80005fcc:	744a                	ld	s0,176(sp)
    80005fce:	74aa                	ld	s1,168(sp)
    80005fd0:	790a                	ld	s2,160(sp)
    80005fd2:	69ea                	ld	s3,152(sp)
    80005fd4:	6129                	addi	sp,sp,192
    80005fd6:	8082                	ret
      end_op();
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	9ae080e7          	jalr	-1618(ra) # 80004986 <end_op>
      return -1;
    80005fe0:	557d                	li	a0,-1
    80005fe2:	b7e5                	j	80005fca <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005fe4:	f5040513          	addi	a0,s0,-176
    80005fe8:	ffffe097          	auipc	ra,0xffffe
    80005fec:	702080e7          	jalr	1794(ra) # 800046ea <namei>
    80005ff0:	84aa                	mv	s1,a0
    80005ff2:	c905                	beqz	a0,80006022 <sys_open+0x13c>
    ilock(ip);
    80005ff4:	ffffe097          	auipc	ra,0xffffe
    80005ff8:	f50080e7          	jalr	-176(ra) # 80003f44 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ffc:	04449703          	lh	a4,68(s1)
    80006000:	4785                	li	a5,1
    80006002:	f4f711e3          	bne	a4,a5,80005f44 <sys_open+0x5e>
    80006006:	f4c42783          	lw	a5,-180(s0)
    8000600a:	d7b9                	beqz	a5,80005f58 <sys_open+0x72>
      iunlockput(ip);
    8000600c:	8526                	mv	a0,s1
    8000600e:	ffffe097          	auipc	ra,0xffffe
    80006012:	198080e7          	jalr	408(ra) # 800041a6 <iunlockput>
      end_op();
    80006016:	fffff097          	auipc	ra,0xfffff
    8000601a:	970080e7          	jalr	-1680(ra) # 80004986 <end_op>
      return -1;
    8000601e:	557d                	li	a0,-1
    80006020:	b76d                	j	80005fca <sys_open+0xe4>
      end_op();
    80006022:	fffff097          	auipc	ra,0xfffff
    80006026:	964080e7          	jalr	-1692(ra) # 80004986 <end_op>
      return -1;
    8000602a:	557d                	li	a0,-1
    8000602c:	bf79                	j	80005fca <sys_open+0xe4>
    iunlockput(ip);
    8000602e:	8526                	mv	a0,s1
    80006030:	ffffe097          	auipc	ra,0xffffe
    80006034:	176080e7          	jalr	374(ra) # 800041a6 <iunlockput>
    end_op();
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	94e080e7          	jalr	-1714(ra) # 80004986 <end_op>
    return -1;
    80006040:	557d                	li	a0,-1
    80006042:	b761                	j	80005fca <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006044:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006048:	04649783          	lh	a5,70(s1)
    8000604c:	02f99223          	sh	a5,36(s3)
    80006050:	bf25                	j	80005f88 <sys_open+0xa2>
    itrunc(ip);
    80006052:	8526                	mv	a0,s1
    80006054:	ffffe097          	auipc	ra,0xffffe
    80006058:	ffe080e7          	jalr	-2(ra) # 80004052 <itrunc>
    8000605c:	bfa9                	j	80005fb6 <sys_open+0xd0>
      fileclose(f);
    8000605e:	854e                	mv	a0,s3
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	d72080e7          	jalr	-654(ra) # 80004dd2 <fileclose>
    iunlockput(ip);
    80006068:	8526                	mv	a0,s1
    8000606a:	ffffe097          	auipc	ra,0xffffe
    8000606e:	13c080e7          	jalr	316(ra) # 800041a6 <iunlockput>
    end_op();
    80006072:	fffff097          	auipc	ra,0xfffff
    80006076:	914080e7          	jalr	-1772(ra) # 80004986 <end_op>
    return -1;
    8000607a:	557d                	li	a0,-1
    8000607c:	b7b9                	j	80005fca <sys_open+0xe4>

000000008000607e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000607e:	7175                	addi	sp,sp,-144
    80006080:	e506                	sd	ra,136(sp)
    80006082:	e122                	sd	s0,128(sp)
    80006084:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006086:	fffff097          	auipc	ra,0xfffff
    8000608a:	880080e7          	jalr	-1920(ra) # 80004906 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000608e:	08000613          	li	a2,128
    80006092:	f7040593          	addi	a1,s0,-144
    80006096:	4501                	li	a0,0
    80006098:	ffffd097          	auipc	ra,0xffffd
    8000609c:	2b2080e7          	jalr	690(ra) # 8000334a <argstr>
    800060a0:	02054963          	bltz	a0,800060d2 <sys_mkdir+0x54>
    800060a4:	4681                	li	a3,0
    800060a6:	4601                	li	a2,0
    800060a8:	4585                	li	a1,1
    800060aa:	f7040513          	addi	a0,s0,-144
    800060ae:	00000097          	auipc	ra,0x0
    800060b2:	800080e7          	jalr	-2048(ra) # 800058ae <create>
    800060b6:	cd11                	beqz	a0,800060d2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060b8:	ffffe097          	auipc	ra,0xffffe
    800060bc:	0ee080e7          	jalr	238(ra) # 800041a6 <iunlockput>
  end_op();
    800060c0:	fffff097          	auipc	ra,0xfffff
    800060c4:	8c6080e7          	jalr	-1850(ra) # 80004986 <end_op>
  return 0;
    800060c8:	4501                	li	a0,0
}
    800060ca:	60aa                	ld	ra,136(sp)
    800060cc:	640a                	ld	s0,128(sp)
    800060ce:	6149                	addi	sp,sp,144
    800060d0:	8082                	ret
    end_op();
    800060d2:	fffff097          	auipc	ra,0xfffff
    800060d6:	8b4080e7          	jalr	-1868(ra) # 80004986 <end_op>
    return -1;
    800060da:	557d                	li	a0,-1
    800060dc:	b7fd                	j	800060ca <sys_mkdir+0x4c>

00000000800060de <sys_mknod>:

uint64
sys_mknod(void)
{
    800060de:	7135                	addi	sp,sp,-160
    800060e0:	ed06                	sd	ra,152(sp)
    800060e2:	e922                	sd	s0,144(sp)
    800060e4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	820080e7          	jalr	-2016(ra) # 80004906 <begin_op>
  argint(1, &major);
    800060ee:	f6c40593          	addi	a1,s0,-148
    800060f2:	4505                	li	a0,1
    800060f4:	ffffd097          	auipc	ra,0xffffd
    800060f8:	216080e7          	jalr	534(ra) # 8000330a <argint>
  argint(2, &minor);
    800060fc:	f6840593          	addi	a1,s0,-152
    80006100:	4509                	li	a0,2
    80006102:	ffffd097          	auipc	ra,0xffffd
    80006106:	208080e7          	jalr	520(ra) # 8000330a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000610a:	08000613          	li	a2,128
    8000610e:	f7040593          	addi	a1,s0,-144
    80006112:	4501                	li	a0,0
    80006114:	ffffd097          	auipc	ra,0xffffd
    80006118:	236080e7          	jalr	566(ra) # 8000334a <argstr>
    8000611c:	02054b63          	bltz	a0,80006152 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006120:	f6841683          	lh	a3,-152(s0)
    80006124:	f6c41603          	lh	a2,-148(s0)
    80006128:	458d                	li	a1,3
    8000612a:	f7040513          	addi	a0,s0,-144
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	780080e7          	jalr	1920(ra) # 800058ae <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006136:	cd11                	beqz	a0,80006152 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006138:	ffffe097          	auipc	ra,0xffffe
    8000613c:	06e080e7          	jalr	110(ra) # 800041a6 <iunlockput>
  end_op();
    80006140:	fffff097          	auipc	ra,0xfffff
    80006144:	846080e7          	jalr	-1978(ra) # 80004986 <end_op>
  return 0;
    80006148:	4501                	li	a0,0
}
    8000614a:	60ea                	ld	ra,152(sp)
    8000614c:	644a                	ld	s0,144(sp)
    8000614e:	610d                	addi	sp,sp,160
    80006150:	8082                	ret
    end_op();
    80006152:	fffff097          	auipc	ra,0xfffff
    80006156:	834080e7          	jalr	-1996(ra) # 80004986 <end_op>
    return -1;
    8000615a:	557d                	li	a0,-1
    8000615c:	b7fd                	j	8000614a <sys_mknod+0x6c>

000000008000615e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000615e:	7135                	addi	sp,sp,-160
    80006160:	ed06                	sd	ra,152(sp)
    80006162:	e922                	sd	s0,144(sp)
    80006164:	e526                	sd	s1,136(sp)
    80006166:	e14a                	sd	s2,128(sp)
    80006168:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000616a:	ffffc097          	auipc	ra,0xffffc
    8000616e:	aa6080e7          	jalr	-1370(ra) # 80001c10 <myproc>
    80006172:	892a                	mv	s2,a0
  
  begin_op();
    80006174:	ffffe097          	auipc	ra,0xffffe
    80006178:	792080e7          	jalr	1938(ra) # 80004906 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000617c:	08000613          	li	a2,128
    80006180:	f6040593          	addi	a1,s0,-160
    80006184:	4501                	li	a0,0
    80006186:	ffffd097          	auipc	ra,0xffffd
    8000618a:	1c4080e7          	jalr	452(ra) # 8000334a <argstr>
    8000618e:	04054b63          	bltz	a0,800061e4 <sys_chdir+0x86>
    80006192:	f6040513          	addi	a0,s0,-160
    80006196:	ffffe097          	auipc	ra,0xffffe
    8000619a:	554080e7          	jalr	1364(ra) # 800046ea <namei>
    8000619e:	84aa                	mv	s1,a0
    800061a0:	c131                	beqz	a0,800061e4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800061a2:	ffffe097          	auipc	ra,0xffffe
    800061a6:	da2080e7          	jalr	-606(ra) # 80003f44 <ilock>
  if(ip->type != T_DIR){
    800061aa:	04449703          	lh	a4,68(s1)
    800061ae:	4785                	li	a5,1
    800061b0:	04f71063          	bne	a4,a5,800061f0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800061b4:	8526                	mv	a0,s1
    800061b6:	ffffe097          	auipc	ra,0xffffe
    800061ba:	e50080e7          	jalr	-432(ra) # 80004006 <iunlock>
  iput(p->cwd);
    800061be:	15093503          	ld	a0,336(s2)
    800061c2:	ffffe097          	auipc	ra,0xffffe
    800061c6:	f3c080e7          	jalr	-196(ra) # 800040fe <iput>
  end_op();
    800061ca:	ffffe097          	auipc	ra,0xffffe
    800061ce:	7bc080e7          	jalr	1980(ra) # 80004986 <end_op>
  p->cwd = ip;
    800061d2:	14993823          	sd	s1,336(s2)
  return 0;
    800061d6:	4501                	li	a0,0
}
    800061d8:	60ea                	ld	ra,152(sp)
    800061da:	644a                	ld	s0,144(sp)
    800061dc:	64aa                	ld	s1,136(sp)
    800061de:	690a                	ld	s2,128(sp)
    800061e0:	610d                	addi	sp,sp,160
    800061e2:	8082                	ret
    end_op();
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	7a2080e7          	jalr	1954(ra) # 80004986 <end_op>
    return -1;
    800061ec:	557d                	li	a0,-1
    800061ee:	b7ed                	j	800061d8 <sys_chdir+0x7a>
    iunlockput(ip);
    800061f0:	8526                	mv	a0,s1
    800061f2:	ffffe097          	auipc	ra,0xffffe
    800061f6:	fb4080e7          	jalr	-76(ra) # 800041a6 <iunlockput>
    end_op();
    800061fa:	ffffe097          	auipc	ra,0xffffe
    800061fe:	78c080e7          	jalr	1932(ra) # 80004986 <end_op>
    return -1;
    80006202:	557d                	li	a0,-1
    80006204:	bfd1                	j	800061d8 <sys_chdir+0x7a>

0000000080006206 <sys_exec>:

uint64
sys_exec(void)
{
    80006206:	7145                	addi	sp,sp,-464
    80006208:	e786                	sd	ra,456(sp)
    8000620a:	e3a2                	sd	s0,448(sp)
    8000620c:	ff26                	sd	s1,440(sp)
    8000620e:	fb4a                	sd	s2,432(sp)
    80006210:	f74e                	sd	s3,424(sp)
    80006212:	f352                	sd	s4,416(sp)
    80006214:	ef56                	sd	s5,408(sp)
    80006216:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006218:	e3840593          	addi	a1,s0,-456
    8000621c:	4505                	li	a0,1
    8000621e:	ffffd097          	auipc	ra,0xffffd
    80006222:	10c080e7          	jalr	268(ra) # 8000332a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006226:	08000613          	li	a2,128
    8000622a:	f4040593          	addi	a1,s0,-192
    8000622e:	4501                	li	a0,0
    80006230:	ffffd097          	auipc	ra,0xffffd
    80006234:	11a080e7          	jalr	282(ra) # 8000334a <argstr>
    80006238:	87aa                	mv	a5,a0
    return -1;
    8000623a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000623c:	0c07c263          	bltz	a5,80006300 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006240:	10000613          	li	a2,256
    80006244:	4581                	li	a1,0
    80006246:	e4040513          	addi	a0,s0,-448
    8000624a:	ffffb097          	auipc	ra,0xffffb
    8000624e:	ce6080e7          	jalr	-794(ra) # 80000f30 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006252:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006256:	89a6                	mv	s3,s1
    80006258:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000625a:	02000a13          	li	s4,32
    8000625e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006262:	00391793          	slli	a5,s2,0x3
    80006266:	e3040593          	addi	a1,s0,-464
    8000626a:	e3843503          	ld	a0,-456(s0)
    8000626e:	953e                	add	a0,a0,a5
    80006270:	ffffd097          	auipc	ra,0xffffd
    80006274:	ffc080e7          	jalr	-4(ra) # 8000326c <fetchaddr>
    80006278:	02054a63          	bltz	a0,800062ac <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000627c:	e3043783          	ld	a5,-464(s0)
    80006280:	c3b9                	beqz	a5,800062c6 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006282:	ffffb097          	auipc	ra,0xffffb
    80006286:	886080e7          	jalr	-1914(ra) # 80000b08 <kalloc>
    8000628a:	85aa                	mv	a1,a0
    8000628c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006290:	cd11                	beqz	a0,800062ac <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006292:	6605                	lui	a2,0x1
    80006294:	e3043503          	ld	a0,-464(s0)
    80006298:	ffffd097          	auipc	ra,0xffffd
    8000629c:	026080e7          	jalr	38(ra) # 800032be <fetchstr>
    800062a0:	00054663          	bltz	a0,800062ac <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800062a4:	0905                	addi	s2,s2,1
    800062a6:	09a1                	addi	s3,s3,8
    800062a8:	fb491be3          	bne	s2,s4,8000625e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062ac:	10048913          	addi	s2,s1,256
    800062b0:	6088                	ld	a0,0(s1)
    800062b2:	c531                	beqz	a0,800062fe <sys_exec+0xf8>
    kfree(argv[i]);
    800062b4:	ffffb097          	auipc	ra,0xffffb
    800062b8:	91a080e7          	jalr	-1766(ra) # 80000bce <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062bc:	04a1                	addi	s1,s1,8
    800062be:	ff2499e3          	bne	s1,s2,800062b0 <sys_exec+0xaa>
  return -1;
    800062c2:	557d                	li	a0,-1
    800062c4:	a835                	j	80006300 <sys_exec+0xfa>
      argv[i] = 0;
    800062c6:	0a8e                	slli	s5,s5,0x3
    800062c8:	fc040793          	addi	a5,s0,-64
    800062cc:	9abe                	add	s5,s5,a5
    800062ce:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800062d2:	e4040593          	addi	a1,s0,-448
    800062d6:	f4040513          	addi	a0,s0,-192
    800062da:	fffff097          	auipc	ra,0xfffff
    800062de:	172080e7          	jalr	370(ra) # 8000544c <exec>
    800062e2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062e4:	10048993          	addi	s3,s1,256
    800062e8:	6088                	ld	a0,0(s1)
    800062ea:	c901                	beqz	a0,800062fa <sys_exec+0xf4>
    kfree(argv[i]);
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	8e2080e7          	jalr	-1822(ra) # 80000bce <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062f4:	04a1                	addi	s1,s1,8
    800062f6:	ff3499e3          	bne	s1,s3,800062e8 <sys_exec+0xe2>
  return ret;
    800062fa:	854a                	mv	a0,s2
    800062fc:	a011                	j	80006300 <sys_exec+0xfa>
  return -1;
    800062fe:	557d                	li	a0,-1
}
    80006300:	60be                	ld	ra,456(sp)
    80006302:	641e                	ld	s0,448(sp)
    80006304:	74fa                	ld	s1,440(sp)
    80006306:	795a                	ld	s2,432(sp)
    80006308:	79ba                	ld	s3,424(sp)
    8000630a:	7a1a                	ld	s4,416(sp)
    8000630c:	6afa                	ld	s5,408(sp)
    8000630e:	6179                	addi	sp,sp,464
    80006310:	8082                	ret

0000000080006312 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006312:	7139                	addi	sp,sp,-64
    80006314:	fc06                	sd	ra,56(sp)
    80006316:	f822                	sd	s0,48(sp)
    80006318:	f426                	sd	s1,40(sp)
    8000631a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000631c:	ffffc097          	auipc	ra,0xffffc
    80006320:	8f4080e7          	jalr	-1804(ra) # 80001c10 <myproc>
    80006324:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006326:	fd840593          	addi	a1,s0,-40
    8000632a:	4501                	li	a0,0
    8000632c:	ffffd097          	auipc	ra,0xffffd
    80006330:	ffe080e7          	jalr	-2(ra) # 8000332a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006334:	fc840593          	addi	a1,s0,-56
    80006338:	fd040513          	addi	a0,s0,-48
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	dc6080e7          	jalr	-570(ra) # 80005102 <pipealloc>
    return -1;
    80006344:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006346:	0c054463          	bltz	a0,8000640e <sys_pipe+0xfc>
  fd0 = -1;
    8000634a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000634e:	fd043503          	ld	a0,-48(s0)
    80006352:	fffff097          	auipc	ra,0xfffff
    80006356:	51a080e7          	jalr	1306(ra) # 8000586c <fdalloc>
    8000635a:	fca42223          	sw	a0,-60(s0)
    8000635e:	08054b63          	bltz	a0,800063f4 <sys_pipe+0xe2>
    80006362:	fc843503          	ld	a0,-56(s0)
    80006366:	fffff097          	auipc	ra,0xfffff
    8000636a:	506080e7          	jalr	1286(ra) # 8000586c <fdalloc>
    8000636e:	fca42023          	sw	a0,-64(s0)
    80006372:	06054863          	bltz	a0,800063e2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006376:	4691                	li	a3,4
    80006378:	fc440613          	addi	a2,s0,-60
    8000637c:	fd843583          	ld	a1,-40(s0)
    80006380:	68a8                	ld	a0,80(s1)
    80006382:	ffffb097          	auipc	ra,0xffffb
    80006386:	544080e7          	jalr	1348(ra) # 800018c6 <copyout>
    8000638a:	02054063          	bltz	a0,800063aa <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000638e:	4691                	li	a3,4
    80006390:	fc040613          	addi	a2,s0,-64
    80006394:	fd843583          	ld	a1,-40(s0)
    80006398:	0591                	addi	a1,a1,4
    8000639a:	68a8                	ld	a0,80(s1)
    8000639c:	ffffb097          	auipc	ra,0xffffb
    800063a0:	52a080e7          	jalr	1322(ra) # 800018c6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063a4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063a6:	06055463          	bgez	a0,8000640e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800063aa:	fc442783          	lw	a5,-60(s0)
    800063ae:	07e9                	addi	a5,a5,26
    800063b0:	078e                	slli	a5,a5,0x3
    800063b2:	97a6                	add	a5,a5,s1
    800063b4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800063b8:	fc042503          	lw	a0,-64(s0)
    800063bc:	0569                	addi	a0,a0,26
    800063be:	050e                	slli	a0,a0,0x3
    800063c0:	94aa                	add	s1,s1,a0
    800063c2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800063c6:	fd043503          	ld	a0,-48(s0)
    800063ca:	fffff097          	auipc	ra,0xfffff
    800063ce:	a08080e7          	jalr	-1528(ra) # 80004dd2 <fileclose>
    fileclose(wf);
    800063d2:	fc843503          	ld	a0,-56(s0)
    800063d6:	fffff097          	auipc	ra,0xfffff
    800063da:	9fc080e7          	jalr	-1540(ra) # 80004dd2 <fileclose>
    return -1;
    800063de:	57fd                	li	a5,-1
    800063e0:	a03d                	j	8000640e <sys_pipe+0xfc>
    if(fd0 >= 0)
    800063e2:	fc442783          	lw	a5,-60(s0)
    800063e6:	0007c763          	bltz	a5,800063f4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800063ea:	07e9                	addi	a5,a5,26
    800063ec:	078e                	slli	a5,a5,0x3
    800063ee:	94be                	add	s1,s1,a5
    800063f0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800063f4:	fd043503          	ld	a0,-48(s0)
    800063f8:	fffff097          	auipc	ra,0xfffff
    800063fc:	9da080e7          	jalr	-1574(ra) # 80004dd2 <fileclose>
    fileclose(wf);
    80006400:	fc843503          	ld	a0,-56(s0)
    80006404:	fffff097          	auipc	ra,0xfffff
    80006408:	9ce080e7          	jalr	-1586(ra) # 80004dd2 <fileclose>
    return -1;
    8000640c:	57fd                	li	a5,-1
}
    8000640e:	853e                	mv	a0,a5
    80006410:	70e2                	ld	ra,56(sp)
    80006412:	7442                	ld	s0,48(sp)
    80006414:	74a2                	ld	s1,40(sp)
    80006416:	6121                	addi	sp,sp,64
    80006418:	8082                	ret
    8000641a:	0000                	unimp
    8000641c:	0000                	unimp
	...

0000000080006420 <kernelvec>:
    80006420:	7111                	addi	sp,sp,-256
    80006422:	e006                	sd	ra,0(sp)
    80006424:	e40a                	sd	sp,8(sp)
    80006426:	e80e                	sd	gp,16(sp)
    80006428:	ec12                	sd	tp,24(sp)
    8000642a:	f016                	sd	t0,32(sp)
    8000642c:	f41a                	sd	t1,40(sp)
    8000642e:	f81e                	sd	t2,48(sp)
    80006430:	fc22                	sd	s0,56(sp)
    80006432:	e0a6                	sd	s1,64(sp)
    80006434:	e4aa                	sd	a0,72(sp)
    80006436:	e8ae                	sd	a1,80(sp)
    80006438:	ecb2                	sd	a2,88(sp)
    8000643a:	f0b6                	sd	a3,96(sp)
    8000643c:	f4ba                	sd	a4,104(sp)
    8000643e:	f8be                	sd	a5,112(sp)
    80006440:	fcc2                	sd	a6,120(sp)
    80006442:	e146                	sd	a7,128(sp)
    80006444:	e54a                	sd	s2,136(sp)
    80006446:	e94e                	sd	s3,144(sp)
    80006448:	ed52                	sd	s4,152(sp)
    8000644a:	f156                	sd	s5,160(sp)
    8000644c:	f55a                	sd	s6,168(sp)
    8000644e:	f95e                	sd	s7,176(sp)
    80006450:	fd62                	sd	s8,184(sp)
    80006452:	e1e6                	sd	s9,192(sp)
    80006454:	e5ea                	sd	s10,200(sp)
    80006456:	e9ee                	sd	s11,208(sp)
    80006458:	edf2                	sd	t3,216(sp)
    8000645a:	f1f6                	sd	t4,224(sp)
    8000645c:	f5fa                	sd	t5,232(sp)
    8000645e:	f9fe                	sd	t6,240(sp)
    80006460:	cd9fc0ef          	jal	ra,80003138 <kerneltrap>
    80006464:	6082                	ld	ra,0(sp)
    80006466:	6122                	ld	sp,8(sp)
    80006468:	61c2                	ld	gp,16(sp)
    8000646a:	7282                	ld	t0,32(sp)
    8000646c:	7322                	ld	t1,40(sp)
    8000646e:	73c2                	ld	t2,48(sp)
    80006470:	7462                	ld	s0,56(sp)
    80006472:	6486                	ld	s1,64(sp)
    80006474:	6526                	ld	a0,72(sp)
    80006476:	65c6                	ld	a1,80(sp)
    80006478:	6666                	ld	a2,88(sp)
    8000647a:	7686                	ld	a3,96(sp)
    8000647c:	7726                	ld	a4,104(sp)
    8000647e:	77c6                	ld	a5,112(sp)
    80006480:	7866                	ld	a6,120(sp)
    80006482:	688a                	ld	a7,128(sp)
    80006484:	692a                	ld	s2,136(sp)
    80006486:	69ca                	ld	s3,144(sp)
    80006488:	6a6a                	ld	s4,152(sp)
    8000648a:	7a8a                	ld	s5,160(sp)
    8000648c:	7b2a                	ld	s6,168(sp)
    8000648e:	7bca                	ld	s7,176(sp)
    80006490:	7c6a                	ld	s8,184(sp)
    80006492:	6c8e                	ld	s9,192(sp)
    80006494:	6d2e                	ld	s10,200(sp)
    80006496:	6dce                	ld	s11,208(sp)
    80006498:	6e6e                	ld	t3,216(sp)
    8000649a:	7e8e                	ld	t4,224(sp)
    8000649c:	7f2e                	ld	t5,232(sp)
    8000649e:	7fce                	ld	t6,240(sp)
    800064a0:	6111                	addi	sp,sp,256
    800064a2:	10200073          	sret
    800064a6:	00000013          	nop
    800064aa:	00000013          	nop
    800064ae:	0001                	nop

00000000800064b0 <timervec>:
    800064b0:	34051573          	csrrw	a0,mscratch,a0
    800064b4:	e10c                	sd	a1,0(a0)
    800064b6:	e510                	sd	a2,8(a0)
    800064b8:	e914                	sd	a3,16(a0)
    800064ba:	6d0c                	ld	a1,24(a0)
    800064bc:	7110                	ld	a2,32(a0)
    800064be:	6194                	ld	a3,0(a1)
    800064c0:	96b2                	add	a3,a3,a2
    800064c2:	e194                	sd	a3,0(a1)
    800064c4:	4589                	li	a1,2
    800064c6:	14459073          	csrw	sip,a1
    800064ca:	6914                	ld	a3,16(a0)
    800064cc:	6510                	ld	a2,8(a0)
    800064ce:	610c                	ld	a1,0(a0)
    800064d0:	34051573          	csrrw	a0,mscratch,a0
    800064d4:	30200073          	mret
	...

00000000800064da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800064da:	1141                	addi	sp,sp,-16
    800064dc:	e422                	sd	s0,8(sp)
    800064de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800064e0:	0c0007b7          	lui	a5,0xc000
    800064e4:	4705                	li	a4,1
    800064e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800064e8:	c3d8                	sw	a4,4(a5)
}
    800064ea:	6422                	ld	s0,8(sp)
    800064ec:	0141                	addi	sp,sp,16
    800064ee:	8082                	ret

00000000800064f0 <plicinithart>:

void
plicinithart(void)
{
    800064f0:	1141                	addi	sp,sp,-16
    800064f2:	e406                	sd	ra,8(sp)
    800064f4:	e022                	sd	s0,0(sp)
    800064f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064f8:	ffffb097          	auipc	ra,0xffffb
    800064fc:	6ec080e7          	jalr	1772(ra) # 80001be4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006500:	0085171b          	slliw	a4,a0,0x8
    80006504:	0c0027b7          	lui	a5,0xc002
    80006508:	97ba                	add	a5,a5,a4
    8000650a:	40200713          	li	a4,1026
    8000650e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006512:	00d5151b          	slliw	a0,a0,0xd
    80006516:	0c2017b7          	lui	a5,0xc201
    8000651a:	953e                	add	a0,a0,a5
    8000651c:	00052023          	sw	zero,0(a0)
}
    80006520:	60a2                	ld	ra,8(sp)
    80006522:	6402                	ld	s0,0(sp)
    80006524:	0141                	addi	sp,sp,16
    80006526:	8082                	ret

0000000080006528 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006528:	1141                	addi	sp,sp,-16
    8000652a:	e406                	sd	ra,8(sp)
    8000652c:	e022                	sd	s0,0(sp)
    8000652e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006530:	ffffb097          	auipc	ra,0xffffb
    80006534:	6b4080e7          	jalr	1716(ra) # 80001be4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006538:	00d5179b          	slliw	a5,a0,0xd
    8000653c:	0c201537          	lui	a0,0xc201
    80006540:	953e                	add	a0,a0,a5
  return irq;
}
    80006542:	4148                	lw	a0,4(a0)
    80006544:	60a2                	ld	ra,8(sp)
    80006546:	6402                	ld	s0,0(sp)
    80006548:	0141                	addi	sp,sp,16
    8000654a:	8082                	ret

000000008000654c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000654c:	1101                	addi	sp,sp,-32
    8000654e:	ec06                	sd	ra,24(sp)
    80006550:	e822                	sd	s0,16(sp)
    80006552:	e426                	sd	s1,8(sp)
    80006554:	1000                	addi	s0,sp,32
    80006556:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006558:	ffffb097          	auipc	ra,0xffffb
    8000655c:	68c080e7          	jalr	1676(ra) # 80001be4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006560:	00d5151b          	slliw	a0,a0,0xd
    80006564:	0c2017b7          	lui	a5,0xc201
    80006568:	97aa                	add	a5,a5,a0
    8000656a:	c3c4                	sw	s1,4(a5)
}
    8000656c:	60e2                	ld	ra,24(sp)
    8000656e:	6442                	ld	s0,16(sp)
    80006570:	64a2                	ld	s1,8(sp)
    80006572:	6105                	addi	sp,sp,32
    80006574:	8082                	ret

0000000080006576 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006576:	1141                	addi	sp,sp,-16
    80006578:	e406                	sd	ra,8(sp)
    8000657a:	e022                	sd	s0,0(sp)
    8000657c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000657e:	479d                	li	a5,7
    80006580:	04a7cc63          	blt	a5,a0,800065d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006584:	0003d797          	auipc	a5,0x3d
    80006588:	98478793          	addi	a5,a5,-1660 # 80042f08 <disk>
    8000658c:	97aa                	add	a5,a5,a0
    8000658e:	0187c783          	lbu	a5,24(a5)
    80006592:	ebb9                	bnez	a5,800065e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006594:	00451613          	slli	a2,a0,0x4
    80006598:	0003d797          	auipc	a5,0x3d
    8000659c:	97078793          	addi	a5,a5,-1680 # 80042f08 <disk>
    800065a0:	6394                	ld	a3,0(a5)
    800065a2:	96b2                	add	a3,a3,a2
    800065a4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800065a8:	6398                	ld	a4,0(a5)
    800065aa:	9732                	add	a4,a4,a2
    800065ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800065b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800065b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800065b8:	953e                	add	a0,a0,a5
    800065ba:	4785                	li	a5,1
    800065bc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800065c0:	0003d517          	auipc	a0,0x3d
    800065c4:	96050513          	addi	a0,a0,-1696 # 80042f20 <disk+0x18>
    800065c8:	ffffc097          	auipc	ra,0xffffc
    800065cc:	088080e7          	jalr	136(ra) # 80002650 <wakeup>
}
    800065d0:	60a2                	ld	ra,8(sp)
    800065d2:	6402                	ld	s0,0(sp)
    800065d4:	0141                	addi	sp,sp,16
    800065d6:	8082                	ret
    panic("free_desc 1");
    800065d8:	00002517          	auipc	a0,0x2
    800065dc:	20850513          	addi	a0,a0,520 # 800087e0 <syscalls+0x300>
    800065e0:	ffffa097          	auipc	ra,0xffffa
    800065e4:	02c080e7          	jalr	44(ra) # 8000060c <panic>
    panic("free_desc 2");
    800065e8:	00002517          	auipc	a0,0x2
    800065ec:	20850513          	addi	a0,a0,520 # 800087f0 <syscalls+0x310>
    800065f0:	ffffa097          	auipc	ra,0xffffa
    800065f4:	01c080e7          	jalr	28(ra) # 8000060c <panic>

00000000800065f8 <virtio_disk_init>:
{
    800065f8:	1101                	addi	sp,sp,-32
    800065fa:	ec06                	sd	ra,24(sp)
    800065fc:	e822                	sd	s0,16(sp)
    800065fe:	e426                	sd	s1,8(sp)
    80006600:	e04a                	sd	s2,0(sp)
    80006602:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006604:	00002597          	auipc	a1,0x2
    80006608:	1fc58593          	addi	a1,a1,508 # 80008800 <syscalls+0x320>
    8000660c:	0003d517          	auipc	a0,0x3d
    80006610:	a2450513          	addi	a0,a0,-1500 # 80043030 <disk+0x128>
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	790080e7          	jalr	1936(ra) # 80000da4 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000661c:	100017b7          	lui	a5,0x10001
    80006620:	4398                	lw	a4,0(a5)
    80006622:	2701                	sext.w	a4,a4
    80006624:	747277b7          	lui	a5,0x74727
    80006628:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000662c:	14f71c63          	bne	a4,a5,80006784 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006630:	100017b7          	lui	a5,0x10001
    80006634:	43dc                	lw	a5,4(a5)
    80006636:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006638:	4709                	li	a4,2
    8000663a:	14e79563          	bne	a5,a4,80006784 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000663e:	100017b7          	lui	a5,0x10001
    80006642:	479c                	lw	a5,8(a5)
    80006644:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006646:	12e79f63          	bne	a5,a4,80006784 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000664a:	100017b7          	lui	a5,0x10001
    8000664e:	47d8                	lw	a4,12(a5)
    80006650:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006652:	554d47b7          	lui	a5,0x554d4
    80006656:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000665a:	12f71563          	bne	a4,a5,80006784 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000665e:	100017b7          	lui	a5,0x10001
    80006662:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006666:	4705                	li	a4,1
    80006668:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000666a:	470d                	li	a4,3
    8000666c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000666e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006670:	c7ffe737          	lui	a4,0xc7ffe
    80006674:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbb717>
    80006678:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000667a:	2701                	sext.w	a4,a4
    8000667c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000667e:	472d                	li	a4,11
    80006680:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006682:	5bbc                	lw	a5,112(a5)
    80006684:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006688:	8ba1                	andi	a5,a5,8
    8000668a:	10078563          	beqz	a5,80006794 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000668e:	100017b7          	lui	a5,0x10001
    80006692:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006696:	43fc                	lw	a5,68(a5)
    80006698:	2781                	sext.w	a5,a5
    8000669a:	10079563          	bnez	a5,800067a4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000669e:	100017b7          	lui	a5,0x10001
    800066a2:	5bdc                	lw	a5,52(a5)
    800066a4:	2781                	sext.w	a5,a5
  if(max == 0)
    800066a6:	10078763          	beqz	a5,800067b4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800066aa:	471d                	li	a4,7
    800066ac:	10f77c63          	bgeu	a4,a5,800067c4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800066b0:	ffffa097          	auipc	ra,0xffffa
    800066b4:	458080e7          	jalr	1112(ra) # 80000b08 <kalloc>
    800066b8:	0003d497          	auipc	s1,0x3d
    800066bc:	85048493          	addi	s1,s1,-1968 # 80042f08 <disk>
    800066c0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800066c2:	ffffa097          	auipc	ra,0xffffa
    800066c6:	446080e7          	jalr	1094(ra) # 80000b08 <kalloc>
    800066ca:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800066cc:	ffffa097          	auipc	ra,0xffffa
    800066d0:	43c080e7          	jalr	1084(ra) # 80000b08 <kalloc>
    800066d4:	87aa                	mv	a5,a0
    800066d6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800066d8:	6088                	ld	a0,0(s1)
    800066da:	cd6d                	beqz	a0,800067d4 <virtio_disk_init+0x1dc>
    800066dc:	0003d717          	auipc	a4,0x3d
    800066e0:	83473703          	ld	a4,-1996(a4) # 80042f10 <disk+0x8>
    800066e4:	cb65                	beqz	a4,800067d4 <virtio_disk_init+0x1dc>
    800066e6:	c7fd                	beqz	a5,800067d4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800066e8:	6605                	lui	a2,0x1
    800066ea:	4581                	li	a1,0
    800066ec:	ffffb097          	auipc	ra,0xffffb
    800066f0:	844080e7          	jalr	-1980(ra) # 80000f30 <memset>
  memset(disk.avail, 0, PGSIZE);
    800066f4:	0003d497          	auipc	s1,0x3d
    800066f8:	81448493          	addi	s1,s1,-2028 # 80042f08 <disk>
    800066fc:	6605                	lui	a2,0x1
    800066fe:	4581                	li	a1,0
    80006700:	6488                	ld	a0,8(s1)
    80006702:	ffffb097          	auipc	ra,0xffffb
    80006706:	82e080e7          	jalr	-2002(ra) # 80000f30 <memset>
  memset(disk.used, 0, PGSIZE);
    8000670a:	6605                	lui	a2,0x1
    8000670c:	4581                	li	a1,0
    8000670e:	6888                	ld	a0,16(s1)
    80006710:	ffffb097          	auipc	ra,0xffffb
    80006714:	820080e7          	jalr	-2016(ra) # 80000f30 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006718:	100017b7          	lui	a5,0x10001
    8000671c:	4721                	li	a4,8
    8000671e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006720:	4098                	lw	a4,0(s1)
    80006722:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006726:	40d8                	lw	a4,4(s1)
    80006728:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000672c:	6498                	ld	a4,8(s1)
    8000672e:	0007069b          	sext.w	a3,a4
    80006732:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006736:	9701                	srai	a4,a4,0x20
    80006738:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000673c:	6898                	ld	a4,16(s1)
    8000673e:	0007069b          	sext.w	a3,a4
    80006742:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006746:	9701                	srai	a4,a4,0x20
    80006748:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000674c:	4705                	li	a4,1
    8000674e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006750:	00e48c23          	sb	a4,24(s1)
    80006754:	00e48ca3          	sb	a4,25(s1)
    80006758:	00e48d23          	sb	a4,26(s1)
    8000675c:	00e48da3          	sb	a4,27(s1)
    80006760:	00e48e23          	sb	a4,28(s1)
    80006764:	00e48ea3          	sb	a4,29(s1)
    80006768:	00e48f23          	sb	a4,30(s1)
    8000676c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006770:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006774:	0727a823          	sw	s2,112(a5)
}
    80006778:	60e2                	ld	ra,24(sp)
    8000677a:	6442                	ld	s0,16(sp)
    8000677c:	64a2                	ld	s1,8(sp)
    8000677e:	6902                	ld	s2,0(sp)
    80006780:	6105                	addi	sp,sp,32
    80006782:	8082                	ret
    panic("could not find virtio disk");
    80006784:	00002517          	auipc	a0,0x2
    80006788:	08c50513          	addi	a0,a0,140 # 80008810 <syscalls+0x330>
    8000678c:	ffffa097          	auipc	ra,0xffffa
    80006790:	e80080e7          	jalr	-384(ra) # 8000060c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006794:	00002517          	auipc	a0,0x2
    80006798:	09c50513          	addi	a0,a0,156 # 80008830 <syscalls+0x350>
    8000679c:	ffffa097          	auipc	ra,0xffffa
    800067a0:	e70080e7          	jalr	-400(ra) # 8000060c <panic>
    panic("virtio disk should not be ready");
    800067a4:	00002517          	auipc	a0,0x2
    800067a8:	0ac50513          	addi	a0,a0,172 # 80008850 <syscalls+0x370>
    800067ac:	ffffa097          	auipc	ra,0xffffa
    800067b0:	e60080e7          	jalr	-416(ra) # 8000060c <panic>
    panic("virtio disk has no queue 0");
    800067b4:	00002517          	auipc	a0,0x2
    800067b8:	0bc50513          	addi	a0,a0,188 # 80008870 <syscalls+0x390>
    800067bc:	ffffa097          	auipc	ra,0xffffa
    800067c0:	e50080e7          	jalr	-432(ra) # 8000060c <panic>
    panic("virtio disk max queue too short");
    800067c4:	00002517          	auipc	a0,0x2
    800067c8:	0cc50513          	addi	a0,a0,204 # 80008890 <syscalls+0x3b0>
    800067cc:	ffffa097          	auipc	ra,0xffffa
    800067d0:	e40080e7          	jalr	-448(ra) # 8000060c <panic>
    panic("virtio disk kalloc");
    800067d4:	00002517          	auipc	a0,0x2
    800067d8:	0dc50513          	addi	a0,a0,220 # 800088b0 <syscalls+0x3d0>
    800067dc:	ffffa097          	auipc	ra,0xffffa
    800067e0:	e30080e7          	jalr	-464(ra) # 8000060c <panic>

00000000800067e4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800067e4:	7119                	addi	sp,sp,-128
    800067e6:	fc86                	sd	ra,120(sp)
    800067e8:	f8a2                	sd	s0,112(sp)
    800067ea:	f4a6                	sd	s1,104(sp)
    800067ec:	f0ca                	sd	s2,96(sp)
    800067ee:	ecce                	sd	s3,88(sp)
    800067f0:	e8d2                	sd	s4,80(sp)
    800067f2:	e4d6                	sd	s5,72(sp)
    800067f4:	e0da                	sd	s6,64(sp)
    800067f6:	fc5e                	sd	s7,56(sp)
    800067f8:	f862                	sd	s8,48(sp)
    800067fa:	f466                	sd	s9,40(sp)
    800067fc:	f06a                	sd	s10,32(sp)
    800067fe:	ec6e                	sd	s11,24(sp)
    80006800:	0100                	addi	s0,sp,128
    80006802:	8aaa                	mv	s5,a0
    80006804:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006806:	00c52d03          	lw	s10,12(a0)
    8000680a:	001d1d1b          	slliw	s10,s10,0x1
    8000680e:	1d02                	slli	s10,s10,0x20
    80006810:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006814:	0003d517          	auipc	a0,0x3d
    80006818:	81c50513          	addi	a0,a0,-2020 # 80043030 <disk+0x128>
    8000681c:	ffffa097          	auipc	ra,0xffffa
    80006820:	618080e7          	jalr	1560(ra) # 80000e34 <acquire>
  for(int i = 0; i < 3; i++){
    80006824:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006826:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006828:	0003cb97          	auipc	s7,0x3c
    8000682c:	6e0b8b93          	addi	s7,s7,1760 # 80042f08 <disk>
  for(int i = 0; i < 3; i++){
    80006830:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006832:	0003cc97          	auipc	s9,0x3c
    80006836:	7fec8c93          	addi	s9,s9,2046 # 80043030 <disk+0x128>
    8000683a:	a08d                	j	8000689c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000683c:	00fb8733          	add	a4,s7,a5
    80006840:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006844:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006846:	0207c563          	bltz	a5,80006870 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000684a:	2905                	addiw	s2,s2,1
    8000684c:	0611                	addi	a2,a2,4
    8000684e:	05690c63          	beq	s2,s6,800068a6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006852:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006854:	0003c717          	auipc	a4,0x3c
    80006858:	6b470713          	addi	a4,a4,1716 # 80042f08 <disk>
    8000685c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000685e:	01874683          	lbu	a3,24(a4)
    80006862:	fee9                	bnez	a3,8000683c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006864:	2785                	addiw	a5,a5,1
    80006866:	0705                	addi	a4,a4,1
    80006868:	fe979be3          	bne	a5,s1,8000685e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000686c:	57fd                	li	a5,-1
    8000686e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006870:	01205d63          	blez	s2,8000688a <virtio_disk_rw+0xa6>
    80006874:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006876:	000a2503          	lw	a0,0(s4)
    8000687a:	00000097          	auipc	ra,0x0
    8000687e:	cfc080e7          	jalr	-772(ra) # 80006576 <free_desc>
      for(int j = 0; j < i; j++)
    80006882:	2d85                	addiw	s11,s11,1
    80006884:	0a11                	addi	s4,s4,4
    80006886:	ffb918e3          	bne	s2,s11,80006876 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000688a:	85e6                	mv	a1,s9
    8000688c:	0003c517          	auipc	a0,0x3c
    80006890:	69450513          	addi	a0,a0,1684 # 80042f20 <disk+0x18>
    80006894:	ffffc097          	auipc	ra,0xffffc
    80006898:	d58080e7          	jalr	-680(ra) # 800025ec <sleep>
  for(int i = 0; i < 3; i++){
    8000689c:	f8040a13          	addi	s4,s0,-128
{
    800068a0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800068a2:	894e                	mv	s2,s3
    800068a4:	b77d                	j	80006852 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068a6:	f8042583          	lw	a1,-128(s0)
    800068aa:	00a58793          	addi	a5,a1,10
    800068ae:	0792                	slli	a5,a5,0x4

  if(write)
    800068b0:	0003c617          	auipc	a2,0x3c
    800068b4:	65860613          	addi	a2,a2,1624 # 80042f08 <disk>
    800068b8:	00f60733          	add	a4,a2,a5
    800068bc:	018036b3          	snez	a3,s8
    800068c0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800068c2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800068c6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800068ca:	f6078693          	addi	a3,a5,-160
    800068ce:	6218                	ld	a4,0(a2)
    800068d0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068d2:	00878513          	addi	a0,a5,8
    800068d6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800068d8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800068da:	6208                	ld	a0,0(a2)
    800068dc:	96aa                	add	a3,a3,a0
    800068de:	4741                	li	a4,16
    800068e0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800068e2:	4705                	li	a4,1
    800068e4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800068e8:	f8442703          	lw	a4,-124(s0)
    800068ec:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800068f0:	0712                	slli	a4,a4,0x4
    800068f2:	953a                	add	a0,a0,a4
    800068f4:	058a8693          	addi	a3,s5,88
    800068f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800068fa:	6208                	ld	a0,0(a2)
    800068fc:	972a                	add	a4,a4,a0
    800068fe:	40000693          	li	a3,1024
    80006902:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006904:	001c3c13          	seqz	s8,s8
    80006908:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000690a:	001c6c13          	ori	s8,s8,1
    8000690e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006912:	f8842603          	lw	a2,-120(s0)
    80006916:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000691a:	0003c697          	auipc	a3,0x3c
    8000691e:	5ee68693          	addi	a3,a3,1518 # 80042f08 <disk>
    80006922:	00258713          	addi	a4,a1,2
    80006926:	0712                	slli	a4,a4,0x4
    80006928:	9736                	add	a4,a4,a3
    8000692a:	587d                	li	a6,-1
    8000692c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006930:	0612                	slli	a2,a2,0x4
    80006932:	9532                	add	a0,a0,a2
    80006934:	f9078793          	addi	a5,a5,-112
    80006938:	97b6                	add	a5,a5,a3
    8000693a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000693c:	629c                	ld	a5,0(a3)
    8000693e:	97b2                	add	a5,a5,a2
    80006940:	4605                	li	a2,1
    80006942:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006944:	4509                	li	a0,2
    80006946:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000694a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000694e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006952:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006956:	6698                	ld	a4,8(a3)
    80006958:	00275783          	lhu	a5,2(a4)
    8000695c:	8b9d                	andi	a5,a5,7
    8000695e:	0786                	slli	a5,a5,0x1
    80006960:	97ba                	add	a5,a5,a4
    80006962:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006966:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000696a:	6698                	ld	a4,8(a3)
    8000696c:	00275783          	lhu	a5,2(a4)
    80006970:	2785                	addiw	a5,a5,1
    80006972:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006976:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000697a:	100017b7          	lui	a5,0x10001
    8000697e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006982:	004aa783          	lw	a5,4(s5)
    80006986:	02c79163          	bne	a5,a2,800069a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000698a:	0003c917          	auipc	s2,0x3c
    8000698e:	6a690913          	addi	s2,s2,1702 # 80043030 <disk+0x128>
  while(b->disk == 1) {
    80006992:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006994:	85ca                	mv	a1,s2
    80006996:	8556                	mv	a0,s5
    80006998:	ffffc097          	auipc	ra,0xffffc
    8000699c:	c54080e7          	jalr	-940(ra) # 800025ec <sleep>
  while(b->disk == 1) {
    800069a0:	004aa783          	lw	a5,4(s5)
    800069a4:	fe9788e3          	beq	a5,s1,80006994 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800069a8:	f8042903          	lw	s2,-128(s0)
    800069ac:	00290793          	addi	a5,s2,2
    800069b0:	00479713          	slli	a4,a5,0x4
    800069b4:	0003c797          	auipc	a5,0x3c
    800069b8:	55478793          	addi	a5,a5,1364 # 80042f08 <disk>
    800069bc:	97ba                	add	a5,a5,a4
    800069be:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800069c2:	0003c997          	auipc	s3,0x3c
    800069c6:	54698993          	addi	s3,s3,1350 # 80042f08 <disk>
    800069ca:	00491713          	slli	a4,s2,0x4
    800069ce:	0009b783          	ld	a5,0(s3)
    800069d2:	97ba                	add	a5,a5,a4
    800069d4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800069d8:	854a                	mv	a0,s2
    800069da:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800069de:	00000097          	auipc	ra,0x0
    800069e2:	b98080e7          	jalr	-1128(ra) # 80006576 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800069e6:	8885                	andi	s1,s1,1
    800069e8:	f0ed                	bnez	s1,800069ca <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800069ea:	0003c517          	auipc	a0,0x3c
    800069ee:	64650513          	addi	a0,a0,1606 # 80043030 <disk+0x128>
    800069f2:	ffffa097          	auipc	ra,0xffffa
    800069f6:	4f6080e7          	jalr	1270(ra) # 80000ee8 <release>
}
    800069fa:	70e6                	ld	ra,120(sp)
    800069fc:	7446                	ld	s0,112(sp)
    800069fe:	74a6                	ld	s1,104(sp)
    80006a00:	7906                	ld	s2,96(sp)
    80006a02:	69e6                	ld	s3,88(sp)
    80006a04:	6a46                	ld	s4,80(sp)
    80006a06:	6aa6                	ld	s5,72(sp)
    80006a08:	6b06                	ld	s6,64(sp)
    80006a0a:	7be2                	ld	s7,56(sp)
    80006a0c:	7c42                	ld	s8,48(sp)
    80006a0e:	7ca2                	ld	s9,40(sp)
    80006a10:	7d02                	ld	s10,32(sp)
    80006a12:	6de2                	ld	s11,24(sp)
    80006a14:	6109                	addi	sp,sp,128
    80006a16:	8082                	ret

0000000080006a18 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a18:	1101                	addi	sp,sp,-32
    80006a1a:	ec06                	sd	ra,24(sp)
    80006a1c:	e822                	sd	s0,16(sp)
    80006a1e:	e426                	sd	s1,8(sp)
    80006a20:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a22:	0003c497          	auipc	s1,0x3c
    80006a26:	4e648493          	addi	s1,s1,1254 # 80042f08 <disk>
    80006a2a:	0003c517          	auipc	a0,0x3c
    80006a2e:	60650513          	addi	a0,a0,1542 # 80043030 <disk+0x128>
    80006a32:	ffffa097          	auipc	ra,0xffffa
    80006a36:	402080e7          	jalr	1026(ra) # 80000e34 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006a3a:	10001737          	lui	a4,0x10001
    80006a3e:	533c                	lw	a5,96(a4)
    80006a40:	8b8d                	andi	a5,a5,3
    80006a42:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006a44:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006a48:	689c                	ld	a5,16(s1)
    80006a4a:	0204d703          	lhu	a4,32(s1)
    80006a4e:	0027d783          	lhu	a5,2(a5)
    80006a52:	04f70863          	beq	a4,a5,80006aa2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006a56:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a5a:	6898                	ld	a4,16(s1)
    80006a5c:	0204d783          	lhu	a5,32(s1)
    80006a60:	8b9d                	andi	a5,a5,7
    80006a62:	078e                	slli	a5,a5,0x3
    80006a64:	97ba                	add	a5,a5,a4
    80006a66:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a68:	00278713          	addi	a4,a5,2
    80006a6c:	0712                	slli	a4,a4,0x4
    80006a6e:	9726                	add	a4,a4,s1
    80006a70:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006a74:	e721                	bnez	a4,80006abc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a76:	0789                	addi	a5,a5,2
    80006a78:	0792                	slli	a5,a5,0x4
    80006a7a:	97a6                	add	a5,a5,s1
    80006a7c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a7e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a82:	ffffc097          	auipc	ra,0xffffc
    80006a86:	bce080e7          	jalr	-1074(ra) # 80002650 <wakeup>

    disk.used_idx += 1;
    80006a8a:	0204d783          	lhu	a5,32(s1)
    80006a8e:	2785                	addiw	a5,a5,1
    80006a90:	17c2                	slli	a5,a5,0x30
    80006a92:	93c1                	srli	a5,a5,0x30
    80006a94:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a98:	6898                	ld	a4,16(s1)
    80006a9a:	00275703          	lhu	a4,2(a4)
    80006a9e:	faf71ce3          	bne	a4,a5,80006a56 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006aa2:	0003c517          	auipc	a0,0x3c
    80006aa6:	58e50513          	addi	a0,a0,1422 # 80043030 <disk+0x128>
    80006aaa:	ffffa097          	auipc	ra,0xffffa
    80006aae:	43e080e7          	jalr	1086(ra) # 80000ee8 <release>
}
    80006ab2:	60e2                	ld	ra,24(sp)
    80006ab4:	6442                	ld	s0,16(sp)
    80006ab6:	64a2                	ld	s1,8(sp)
    80006ab8:	6105                	addi	sp,sp,32
    80006aba:	8082                	ret
      panic("virtio_disk_intr status");
    80006abc:	00002517          	auipc	a0,0x2
    80006ac0:	e0c50513          	addi	a0,a0,-500 # 800088c8 <syscalls+0x3e8>
    80006ac4:	ffffa097          	auipc	ra,0xffffa
    80006ac8:	b48080e7          	jalr	-1208(ra) # 8000060c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
