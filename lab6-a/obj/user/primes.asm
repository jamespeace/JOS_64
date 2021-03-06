
obj/user/primes.debug:     file format elf64-x86-64


Disassembly of section .text:

0000000000800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	movabs $USTACKTOP, %rax
  800020:	48 b8 00 e0 7f ef 00 	movabs $0xef7fe000,%rax
  800027:	00 00 00 
	cmpq %rax,%rsp
  80002a:	48 39 c4             	cmp    %rax,%rsp
	jne args_exist
  80002d:	75 04                	jne    800033 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushq $0
  80002f:	6a 00                	pushq  $0x0
	pushq $0
  800031:	6a 00                	pushq  $0x0

0000000000800033 <args_exist>:

args_exist:
	movq 8(%rsp), %rsi
  800033:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
	movq (%rsp), %rdi
  800038:	48 8b 3c 24          	mov    (%rsp),%rdi
	call libmain
  80003c:	e8 8d 01 00 00       	callq  8001ce <libmain>
1:	jmp 1b
  800041:	eb fe                	jmp    800041 <args_exist+0xe>

0000000000800043 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800043:	55                   	push   %rbp
  800044:	48 89 e5             	mov    %rsp,%rbp
  800047:	48 83 ec 10          	sub    $0x10,%rsp
	int i, id, p;
	envid_t envid;
	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80004b:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  80004f:	ba 00 00 00 00       	mov    $0x0,%edx
  800054:	be 00 00 00 00       	mov    $0x0,%esi
  800059:	48 89 c7             	mov    %rax,%rdi
  80005c:	48 b8 6c 23 80 00 00 	movabs $0x80236c,%rax
  800063:	00 00 00 
  800066:	ff d0                	callq  *%rax
  800068:	89 45 fc             	mov    %eax,-0x4(%rbp)
	cprintf("CPU %d: %d", thisenv->env_cpunum, p);
  80006b:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  800072:	00 00 00 
  800075:	48 8b 00             	mov    (%rax),%rax
  800078:	8b 80 dc 00 00 00    	mov    0xdc(%rax),%eax
  80007e:	8b 55 fc             	mov    -0x4(%rbp),%edx
  800081:	89 c6                	mov    %eax,%esi
  800083:	48 bf c0 47 80 00 00 	movabs $0x8047c0,%rdi
  80008a:	00 00 00 
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
  800092:	48 b9 b5 04 80 00 00 	movabs $0x8004b5,%rcx
  800099:	00 00 00 
  80009c:	ff d1                	callq  *%rcx

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80009e:	48 b8 bb 20 80 00 00 	movabs $0x8020bb,%rax
  8000a5:	00 00 00 
  8000a8:	ff d0                	callq  *%rax
  8000aa:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8000ad:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8000b1:	79 30                	jns    8000e3 <primeproc+0xa0>
		panic("fork: %e", id);
  8000b3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8000b6:	89 c1                	mov    %eax,%ecx
  8000b8:	48 ba cb 47 80 00 00 	movabs $0x8047cb,%rdx
  8000bf:	00 00 00 
  8000c2:	be 19 00 00 00       	mov    $0x19,%esi
  8000c7:	48 bf d4 47 80 00 00 	movabs $0x8047d4,%rdi
  8000ce:	00 00 00 
  8000d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d6:	49 b8 7c 02 80 00 00 	movabs $0x80027c,%r8
  8000dd:	00 00 00 
  8000e0:	41 ff d0             	callq  *%r8
	if (id == 0)
  8000e3:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8000e7:	75 05                	jne    8000ee <primeproc+0xab>
		goto top;
  8000e9:	e9 5d ff ff ff       	jmpq   80004b <primeproc+0x8>

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000ee:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	be 00 00 00 00       	mov    $0x0,%esi
  8000fc:	48 89 c7             	mov    %rax,%rdi
  8000ff:	48 b8 6c 23 80 00 00 	movabs $0x80236c,%rax
  800106:	00 00 00 
  800109:	ff d0                	callq  *%rax
  80010b:	89 45 f4             	mov    %eax,-0xc(%rbp)
		if (i % p)
  80010e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800111:	99                   	cltd   
  800112:	f7 7d fc             	idivl  -0x4(%rbp)
  800115:	89 d0                	mov    %edx,%eax
  800117:	85 c0                	test   %eax,%eax
  800119:	74 20                	je     80013b <primeproc+0xf8>
			ipc_send(id, i, 0, 0);
  80011b:	8b 75 f4             	mov    -0xc(%rbp),%esi
  80011e:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800121:	b9 00 00 00 00       	mov    $0x0,%ecx
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	89 c7                	mov    %eax,%edi
  80012d:	48 b8 72 24 80 00 00 	movabs $0x802472,%rax
  800134:	00 00 00 
  800137:	ff d0                	callq  *%rax
	}
  800139:	eb b3                	jmp    8000ee <primeproc+0xab>
  80013b:	eb b1                	jmp    8000ee <primeproc+0xab>

000000000080013d <umain>:
}

void
umain(int argc, char **argv)
{
  80013d:	55                   	push   %rbp
  80013e:	48 89 e5             	mov    %rsp,%rbp
  800141:	48 83 ec 20          	sub    $0x20,%rsp
  800145:	89 7d ec             	mov    %edi,-0x14(%rbp)
  800148:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  80014c:	48 b8 bb 20 80 00 00 	movabs $0x8020bb,%rax
  800153:	00 00 00 
  800156:	ff d0                	callq  *%rax
  800158:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80015b:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  80015f:	79 30                	jns    800191 <umain+0x54>
		panic("fork: %e", id);
  800161:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800164:	89 c1                	mov    %eax,%ecx
  800166:	48 ba cb 47 80 00 00 	movabs $0x8047cb,%rdx
  80016d:	00 00 00 
  800170:	be 2c 00 00 00       	mov    $0x2c,%esi
  800175:	48 bf d4 47 80 00 00 	movabs $0x8047d4,%rdi
  80017c:	00 00 00 
  80017f:	b8 00 00 00 00       	mov    $0x0,%eax
  800184:	49 b8 7c 02 80 00 00 	movabs $0x80027c,%r8
  80018b:	00 00 00 
  80018e:	41 ff d0             	callq  *%r8
	if (id == 0)
  800191:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  800195:	75 0c                	jne    8001a3 <umain+0x66>
		primeproc();
  800197:	48 b8 43 00 80 00 00 	movabs $0x800043,%rax
  80019e:	00 00 00 
  8001a1:	ff d0                	callq  *%rax

	// feed all the integers through
	for (i = 2; ; i++)
  8001a3:	c7 45 fc 02 00 00 00 	movl   $0x2,-0x4(%rbp)
		ipc_send(id, i, 0, 0);
  8001aa:	8b 75 fc             	mov    -0x4(%rbp),%esi
  8001ad:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8001b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ba:	89 c7                	mov    %eax,%edi
  8001bc:	48 b8 72 24 80 00 00 	movabs $0x802472,%rax
  8001c3:	00 00 00 
  8001c6:	ff d0                	callq  *%rax
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8001c8:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
		ipc_send(id, i, 0, 0);
  8001cc:	eb dc                	jmp    8001aa <umain+0x6d>

00000000008001ce <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ce:	55                   	push   %rbp
  8001cf:	48 89 e5             	mov    %rsp,%rbp
  8001d2:	48 83 ec 10          	sub    $0x10,%rsp
  8001d6:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8001d9:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001dd:	48 b8 1d 19 80 00 00 	movabs $0x80191d,%rax
  8001e4:	00 00 00 
  8001e7:	ff d0                	callq  *%rax
  8001e9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ee:	48 63 d0             	movslq %eax,%rdx
  8001f1:	48 89 d0             	mov    %rdx,%rax
  8001f4:	48 c1 e0 03          	shl    $0x3,%rax
  8001f8:	48 01 d0             	add    %rdx,%rax
  8001fb:	48 c1 e0 05          	shl    $0x5,%rax
  8001ff:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  800206:	00 00 00 
  800209:	48 01 c2             	add    %rax,%rdx
  80020c:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  800213:	00 00 00 
  800216:	48 89 10             	mov    %rdx,(%rax)
	//cprintf("I am entering libmain\n");
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800219:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80021d:	7e 14                	jle    800233 <libmain+0x65>
		binaryname = argv[0];
  80021f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800223:	48 8b 10             	mov    (%rax),%rdx
  800226:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  80022d:	00 00 00 
  800230:	48 89 10             	mov    %rdx,(%rax)

	// call user main routine
	umain(argc, argv);
  800233:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800237:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80023a:	48 89 d6             	mov    %rdx,%rsi
  80023d:	89 c7                	mov    %eax,%edi
  80023f:	48 b8 3d 01 80 00 00 	movabs $0x80013d,%rax
  800246:	00 00 00 
  800249:	ff d0                	callq  *%rax
	// exit gracefully
	exit();
  80024b:	48 b8 59 02 80 00 00 	movabs $0x800259,%rax
  800252:	00 00 00 
  800255:	ff d0                	callq  *%rax
}
  800257:	c9                   	leaveq 
  800258:	c3                   	retq   

0000000000800259 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800259:	55                   	push   %rbp
  80025a:	48 89 e5             	mov    %rsp,%rbp
	close_all();
  80025d:	48 b8 97 28 80 00 00 	movabs $0x802897,%rax
  800264:	00 00 00 
  800267:	ff d0                	callq  *%rax
	sys_env_destroy(0);
  800269:	bf 00 00 00 00       	mov    $0x0,%edi
  80026e:	48 b8 d9 18 80 00 00 	movabs $0x8018d9,%rax
  800275:	00 00 00 
  800278:	ff d0                	callq  *%rax

}
  80027a:	5d                   	pop    %rbp
  80027b:	c3                   	retq   

000000000080027c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80027c:	55                   	push   %rbp
  80027d:	48 89 e5             	mov    %rsp,%rbp
  800280:	53                   	push   %rbx
  800281:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  800288:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
  80028f:	89 b5 14 ff ff ff    	mov    %esi,-0xec(%rbp)
  800295:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  80029c:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8002a3:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8002aa:	84 c0                	test   %al,%al
  8002ac:	74 23                	je     8002d1 <_panic+0x55>
  8002ae:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  8002b5:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  8002b9:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8002bd:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8002c1:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  8002c5:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  8002c9:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  8002cd:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  8002d1:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
	va_list ap;

	va_start(ap, fmt);
  8002d8:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  8002df:	00 00 00 
  8002e2:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8002e9:	00 00 00 
  8002ec:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8002f0:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8002f7:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  8002fe:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  80030c:	00 00 00 
  80030f:	48 8b 18             	mov    (%rax),%rbx
  800312:	48 b8 1d 19 80 00 00 	movabs $0x80191d,%rax
  800319:	00 00 00 
  80031c:	ff d0                	callq  *%rax
  80031e:	8b 8d 14 ff ff ff    	mov    -0xec(%rbp),%ecx
  800324:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  80032b:	41 89 c8             	mov    %ecx,%r8d
  80032e:	48 89 d1             	mov    %rdx,%rcx
  800331:	48 89 da             	mov    %rbx,%rdx
  800334:	89 c6                	mov    %eax,%esi
  800336:	48 bf f0 47 80 00 00 	movabs $0x8047f0,%rdi
  80033d:	00 00 00 
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	49 b9 b5 04 80 00 00 	movabs $0x8004b5,%r9
  80034c:	00 00 00 
  80034f:	41 ff d1             	callq  *%r9
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800352:	48 8d 95 28 ff ff ff 	lea    -0xd8(%rbp),%rdx
  800359:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800360:	48 89 d6             	mov    %rdx,%rsi
  800363:	48 89 c7             	mov    %rax,%rdi
  800366:	48 b8 09 04 80 00 00 	movabs $0x800409,%rax
  80036d:	00 00 00 
  800370:	ff d0                	callq  *%rax
	cprintf("\n");
  800372:	48 bf 13 48 80 00 00 	movabs $0x804813,%rdi
  800379:	00 00 00 
  80037c:	b8 00 00 00 00       	mov    $0x0,%eax
  800381:	48 ba b5 04 80 00 00 	movabs $0x8004b5,%rdx
  800388:	00 00 00 
  80038b:	ff d2                	callq  *%rdx

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038d:	cc                   	int3   
  80038e:	eb fd                	jmp    80038d <_panic+0x111>

0000000000800390 <putch>:
};


    static void
putch(int ch, struct printbuf *b)
{
  800390:	55                   	push   %rbp
  800391:	48 89 e5             	mov    %rsp,%rbp
  800394:	48 83 ec 10          	sub    $0x10,%rsp
  800398:	89 7d fc             	mov    %edi,-0x4(%rbp)
  80039b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    b->buf[b->idx++] = ch;
  80039f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8003a3:	8b 00                	mov    (%rax),%eax
  8003a5:	8d 48 01             	lea    0x1(%rax),%ecx
  8003a8:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8003ac:	89 0a                	mov    %ecx,(%rdx)
  8003ae:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8003b1:	89 d1                	mov    %edx,%ecx
  8003b3:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8003b7:	48 98                	cltq   
  8003b9:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
    if (b->idx == 256-1) {
  8003bd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8003c1:	8b 00                	mov    (%rax),%eax
  8003c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c8:	75 2c                	jne    8003f6 <putch+0x66>
        sys_cputs(b->buf, b->idx);
  8003ca:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8003ce:	8b 00                	mov    (%rax),%eax
  8003d0:	48 98                	cltq   
  8003d2:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8003d6:	48 83 c2 08          	add    $0x8,%rdx
  8003da:	48 89 c6             	mov    %rax,%rsi
  8003dd:	48 89 d7             	mov    %rdx,%rdi
  8003e0:	48 b8 51 18 80 00 00 	movabs $0x801851,%rax
  8003e7:	00 00 00 
  8003ea:	ff d0                	callq  *%rax
        b->idx = 0;
  8003ec:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8003f0:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    }
    b->cnt++;
  8003f6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8003fa:	8b 40 04             	mov    0x4(%rax),%eax
  8003fd:	8d 50 01             	lea    0x1(%rax),%edx
  800400:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800404:	89 50 04             	mov    %edx,0x4(%rax)
}
  800407:	c9                   	leaveq 
  800408:	c3                   	retq   

0000000000800409 <vcprintf>:

    int
vcprintf(const char *fmt, va_list ap)
{
  800409:	55                   	push   %rbp
  80040a:	48 89 e5             	mov    %rsp,%rbp
  80040d:	48 81 ec 40 01 00 00 	sub    $0x140,%rsp
  800414:	48 89 bd c8 fe ff ff 	mov    %rdi,-0x138(%rbp)
  80041b:	48 89 b5 c0 fe ff ff 	mov    %rsi,-0x140(%rbp)
    struct printbuf b;
    va_list aq;
    va_copy(aq,ap);
  800422:	48 8d 85 d8 fe ff ff 	lea    -0x128(%rbp),%rax
  800429:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  800430:	48 8b 0a             	mov    (%rdx),%rcx
  800433:	48 89 08             	mov    %rcx,(%rax)
  800436:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80043a:	48 89 48 08          	mov    %rcx,0x8(%rax)
  80043e:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800442:	48 89 50 10          	mov    %rdx,0x10(%rax)
    b.idx = 0;
  800446:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80044d:	00 00 00 
    b.cnt = 0;
  800450:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800457:	00 00 00 
    vprintfmt((void*)putch, &b, fmt, aq);
  80045a:	48 8d 8d d8 fe ff ff 	lea    -0x128(%rbp),%rcx
  800461:	48 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%rdx
  800468:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  80046f:	48 89 c6             	mov    %rax,%rsi
  800472:	48 bf 90 03 80 00 00 	movabs $0x800390,%rdi
  800479:	00 00 00 
  80047c:	48 b8 68 08 80 00 00 	movabs $0x800868,%rax
  800483:	00 00 00 
  800486:	ff d0                	callq  *%rax
    sys_cputs(b.buf, b.idx);
  800488:	8b 85 f0 fe ff ff    	mov    -0x110(%rbp),%eax
  80048e:	48 98                	cltq   
  800490:	48 8d 95 f0 fe ff ff 	lea    -0x110(%rbp),%rdx
  800497:	48 83 c2 08          	add    $0x8,%rdx
  80049b:	48 89 c6             	mov    %rax,%rsi
  80049e:	48 89 d7             	mov    %rdx,%rdi
  8004a1:	48 b8 51 18 80 00 00 	movabs $0x801851,%rax
  8004a8:	00 00 00 
  8004ab:	ff d0                	callq  *%rax
    va_end(aq);

    return b.cnt;
  8004ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
}
  8004b3:	c9                   	leaveq 
  8004b4:	c3                   	retq   

00000000008004b5 <cprintf>:

    int
cprintf(const char *fmt, ...)
{
  8004b5:	55                   	push   %rbp
  8004b6:	48 89 e5             	mov    %rsp,%rbp
  8004b9:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
  8004c0:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8004c7:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8004ce:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004d5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004dc:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004e3:	84 c0                	test   %al,%al
  8004e5:	74 20                	je     800507 <cprintf+0x52>
  8004e7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004eb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004ef:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004f3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004f7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004fb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004ff:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800503:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  800507:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
    va_list ap;
    int cnt;
    va_list aq;
    va_start(ap, fmt);
  80050e:	c7 85 30 ff ff ff 08 	movl   $0x8,-0xd0(%rbp)
  800515:	00 00 00 
  800518:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  80051f:	00 00 00 
  800522:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800526:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  80052d:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800534:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
    va_copy(aq,ap);
  80053b:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  800542:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  800549:	48 8b 0a             	mov    (%rdx),%rcx
  80054c:	48 89 08             	mov    %rcx,(%rax)
  80054f:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800553:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800557:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  80055b:	48 89 50 10          	mov    %rdx,0x10(%rax)
    cnt = vcprintf(fmt, aq);
  80055f:	48 8d 95 18 ff ff ff 	lea    -0xe8(%rbp),%rdx
  800566:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  80056d:	48 89 d6             	mov    %rdx,%rsi
  800570:	48 89 c7             	mov    %rax,%rdi
  800573:	48 b8 09 04 80 00 00 	movabs $0x800409,%rax
  80057a:	00 00 00 
  80057d:	ff d0                	callq  *%rax
  80057f:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
    va_end(aq);

    return cnt;
  800585:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
}
  80058b:	c9                   	leaveq 
  80058c:	c3                   	retq   

000000000080058d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80058d:	55                   	push   %rbp
  80058e:	48 89 e5             	mov    %rsp,%rbp
  800591:	53                   	push   %rbx
  800592:	48 83 ec 38          	sub    $0x38,%rsp
  800596:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80059a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80059e:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8005a2:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
  8005a5:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  8005a9:	44 89 4d cc          	mov    %r9d,-0x34(%rbp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ad:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  8005b0:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8005b4:	77 3b                	ja     8005f1 <printnum+0x64>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b6:	8b 45 d0             	mov    -0x30(%rbp),%eax
  8005b9:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
  8005bd:	8b 5d d4             	mov    -0x2c(%rbp),%ebx
  8005c0:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8005c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c9:	48 f7 f3             	div    %rbx
  8005cc:	48 89 c2             	mov    %rax,%rdx
  8005cf:	8b 7d cc             	mov    -0x34(%rbp),%edi
  8005d2:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  8005d5:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  8005d9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8005dd:	41 89 f9             	mov    %edi,%r9d
  8005e0:	48 89 c7             	mov    %rax,%rdi
  8005e3:	48 b8 8d 05 80 00 00 	movabs $0x80058d,%rax
  8005ea:	00 00 00 
  8005ed:	ff d0                	callq  *%rax
  8005ef:	eb 1e                	jmp    80060f <printnum+0x82>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f1:	eb 12                	jmp    800605 <printnum+0x78>
			putch(padc, putdat);
  8005f3:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8005f7:	8b 55 cc             	mov    -0x34(%rbp),%edx
  8005fa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8005fe:	48 89 ce             	mov    %rcx,%rsi
  800601:	89 d7                	mov    %edx,%edi
  800603:	ff d0                	callq  *%rax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800605:	83 6d d0 01          	subl   $0x1,-0x30(%rbp)
  800609:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
  80060d:	7f e4                	jg     8005f3 <printnum+0x66>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80060f:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  800612:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800616:	ba 00 00 00 00       	mov    $0x0,%edx
  80061b:	48 f7 f1             	div    %rcx
  80061e:	48 89 d0             	mov    %rdx,%rax
  800621:	48 ba 10 4a 80 00 00 	movabs $0x804a10,%rdx
  800628:	00 00 00 
  80062b:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  80062f:	0f be d0             	movsbl %al,%edx
  800632:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  800636:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80063a:	48 89 ce             	mov    %rcx,%rsi
  80063d:	89 d7                	mov    %edx,%edi
  80063f:	ff d0                	callq  *%rax
}
  800641:	48 83 c4 38          	add    $0x38,%rsp
  800645:	5b                   	pop    %rbx
  800646:	5d                   	pop    %rbp
  800647:	c3                   	retq   

0000000000800648 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800648:	55                   	push   %rbp
  800649:	48 89 e5             	mov    %rsp,%rbp
  80064c:	48 83 ec 1c          	sub    $0x1c,%rsp
  800650:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800654:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	unsigned long long x;    
	if (lflag >= 2)
  800657:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  80065b:	7e 52                	jle    8006af <getuint+0x67>
		x= va_arg(*ap, unsigned long long);
  80065d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800661:	8b 00                	mov    (%rax),%eax
  800663:	83 f8 30             	cmp    $0x30,%eax
  800666:	73 24                	jae    80068c <getuint+0x44>
  800668:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80066c:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800670:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800674:	8b 00                	mov    (%rax),%eax
  800676:	89 c0                	mov    %eax,%eax
  800678:	48 01 d0             	add    %rdx,%rax
  80067b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80067f:	8b 12                	mov    (%rdx),%edx
  800681:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800684:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800688:	89 0a                	mov    %ecx,(%rdx)
  80068a:	eb 17                	jmp    8006a3 <getuint+0x5b>
  80068c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800690:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800694:	48 89 d0             	mov    %rdx,%rax
  800697:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  80069b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80069f:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8006a3:	48 8b 00             	mov    (%rax),%rax
  8006a6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8006aa:	e9 a3 00 00 00       	jmpq   800752 <getuint+0x10a>
	else if (lflag)
  8006af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8006b3:	74 4f                	je     800704 <getuint+0xbc>
		x= va_arg(*ap, unsigned long);
  8006b5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8006b9:	8b 00                	mov    (%rax),%eax
  8006bb:	83 f8 30             	cmp    $0x30,%eax
  8006be:	73 24                	jae    8006e4 <getuint+0x9c>
  8006c0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8006c4:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8006c8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8006cc:	8b 00                	mov    (%rax),%eax
  8006ce:	89 c0                	mov    %eax,%eax
  8006d0:	48 01 d0             	add    %rdx,%rax
  8006d3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8006d7:	8b 12                	mov    (%rdx),%edx
  8006d9:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8006dc:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8006e0:	89 0a                	mov    %ecx,(%rdx)
  8006e2:	eb 17                	jmp    8006fb <getuint+0xb3>
  8006e4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8006e8:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8006ec:	48 89 d0             	mov    %rdx,%rax
  8006ef:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  8006f3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8006f7:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8006fb:	48 8b 00             	mov    (%rax),%rax
  8006fe:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800702:	eb 4e                	jmp    800752 <getuint+0x10a>
	else
		x= va_arg(*ap, unsigned int);
  800704:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800708:	8b 00                	mov    (%rax),%eax
  80070a:	83 f8 30             	cmp    $0x30,%eax
  80070d:	73 24                	jae    800733 <getuint+0xeb>
  80070f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800713:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800717:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80071b:	8b 00                	mov    (%rax),%eax
  80071d:	89 c0                	mov    %eax,%eax
  80071f:	48 01 d0             	add    %rdx,%rax
  800722:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800726:	8b 12                	mov    (%rdx),%edx
  800728:	8d 4a 08             	lea    0x8(%rdx),%ecx
  80072b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80072f:	89 0a                	mov    %ecx,(%rdx)
  800731:	eb 17                	jmp    80074a <getuint+0x102>
  800733:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800737:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80073b:	48 89 d0             	mov    %rdx,%rax
  80073e:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800742:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800746:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80074a:	8b 00                	mov    (%rax),%eax
  80074c:	89 c0                	mov    %eax,%eax
  80074e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return x;
  800752:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  800756:	c9                   	leaveq 
  800757:	c3                   	retq   

0000000000800758 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800758:	55                   	push   %rbp
  800759:	48 89 e5             	mov    %rsp,%rbp
  80075c:	48 83 ec 1c          	sub    $0x1c,%rsp
  800760:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800764:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	long long x;
	if (lflag >= 2)
  800767:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  80076b:	7e 52                	jle    8007bf <getint+0x67>
		x=va_arg(*ap, long long);
  80076d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800771:	8b 00                	mov    (%rax),%eax
  800773:	83 f8 30             	cmp    $0x30,%eax
  800776:	73 24                	jae    80079c <getint+0x44>
  800778:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80077c:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800780:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800784:	8b 00                	mov    (%rax),%eax
  800786:	89 c0                	mov    %eax,%eax
  800788:	48 01 d0             	add    %rdx,%rax
  80078b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80078f:	8b 12                	mov    (%rdx),%edx
  800791:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800794:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800798:	89 0a                	mov    %ecx,(%rdx)
  80079a:	eb 17                	jmp    8007b3 <getint+0x5b>
  80079c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8007a0:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8007a4:	48 89 d0             	mov    %rdx,%rax
  8007a7:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  8007ab:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8007af:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8007b3:	48 8b 00             	mov    (%rax),%rax
  8007b6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8007ba:	e9 a3 00 00 00       	jmpq   800862 <getint+0x10a>
	else if (lflag)
  8007bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8007c3:	74 4f                	je     800814 <getint+0xbc>
		x=va_arg(*ap, long);
  8007c5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8007c9:	8b 00                	mov    (%rax),%eax
  8007cb:	83 f8 30             	cmp    $0x30,%eax
  8007ce:	73 24                	jae    8007f4 <getint+0x9c>
  8007d0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8007d4:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8007d8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8007dc:	8b 00                	mov    (%rax),%eax
  8007de:	89 c0                	mov    %eax,%eax
  8007e0:	48 01 d0             	add    %rdx,%rax
  8007e3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8007e7:	8b 12                	mov    (%rdx),%edx
  8007e9:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8007ec:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8007f0:	89 0a                	mov    %ecx,(%rdx)
  8007f2:	eb 17                	jmp    80080b <getint+0xb3>
  8007f4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8007f8:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8007fc:	48 89 d0             	mov    %rdx,%rax
  8007ff:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800803:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800807:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80080b:	48 8b 00             	mov    (%rax),%rax
  80080e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800812:	eb 4e                	jmp    800862 <getint+0x10a>
	else
		x=va_arg(*ap, int);
  800814:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800818:	8b 00                	mov    (%rax),%eax
  80081a:	83 f8 30             	cmp    $0x30,%eax
  80081d:	73 24                	jae    800843 <getint+0xeb>
  80081f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800823:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800827:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80082b:	8b 00                	mov    (%rax),%eax
  80082d:	89 c0                	mov    %eax,%eax
  80082f:	48 01 d0             	add    %rdx,%rax
  800832:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800836:	8b 12                	mov    (%rdx),%edx
  800838:	8d 4a 08             	lea    0x8(%rdx),%ecx
  80083b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80083f:	89 0a                	mov    %ecx,(%rdx)
  800841:	eb 17                	jmp    80085a <getint+0x102>
  800843:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800847:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80084b:	48 89 d0             	mov    %rdx,%rax
  80084e:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800852:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800856:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80085a:	8b 00                	mov    (%rax),%eax
  80085c:	48 98                	cltq   
  80085e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return x;
  800862:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  800866:	c9                   	leaveq 
  800867:	c3                   	retq   

0000000000800868 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800868:	55                   	push   %rbp
  800869:	48 89 e5             	mov    %rsp,%rbp
  80086c:	41 54                	push   %r12
  80086e:	53                   	push   %rbx
  80086f:	48 83 ec 60          	sub    $0x60,%rsp
  800873:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  800877:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  80087b:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  80087f:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
  800883:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800887:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  80088b:	48 8b 0a             	mov    (%rdx),%rcx
  80088e:	48 89 08             	mov    %rcx,(%rax)
  800891:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800895:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800899:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  80089d:	48 89 50 10          	mov    %rdx,0x10(%rax)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a1:	eb 17                	jmp    8008ba <vprintfmt+0x52>
			if (ch == '\0')
  8008a3:	85 db                	test   %ebx,%ebx
  8008a5:	0f 84 cc 04 00 00    	je     800d77 <vprintfmt+0x50f>
				return;
			putch(ch, putdat);
  8008ab:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8008af:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8008b3:	48 89 d6             	mov    %rdx,%rsi
  8008b6:	89 df                	mov    %ebx,%edi
  8008b8:	ff d0                	callq  *%rax
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ba:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8008be:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8008c2:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8008c6:	0f b6 00             	movzbl (%rax),%eax
  8008c9:	0f b6 d8             	movzbl %al,%ebx
  8008cc:	83 fb 25             	cmp    $0x25,%ebx
  8008cf:	75 d2                	jne    8008a3 <vprintfmt+0x3b>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8008d1:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
		width = -1;
  8008d5:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%rbp)
		precision = -1;
  8008dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
		lflag = 0;
  8008e3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
		altflag = 0;
  8008ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8008f5:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8008f9:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8008fd:	0f b6 00             	movzbl (%rax),%eax
  800900:	0f b6 d8             	movzbl %al,%ebx
  800903:	8d 43 dd             	lea    -0x23(%rbx),%eax
  800906:	83 f8 55             	cmp    $0x55,%eax
  800909:	0f 87 34 04 00 00    	ja     800d43 <vprintfmt+0x4db>
  80090f:	89 c0                	mov    %eax,%eax
  800911:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800918:	00 
  800919:	48 b8 38 4a 80 00 00 	movabs $0x804a38,%rax
  800920:	00 00 00 
  800923:	48 01 d0             	add    %rdx,%rax
  800926:	48 8b 00             	mov    (%rax),%rax
  800929:	ff e0                	jmpq   *%rax

			// flag to pad on the right
		case '-':
			padc = '-';
  80092b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%rbp)
			goto reswitch;
  80092f:	eb c0                	jmp    8008f1 <vprintfmt+0x89>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800931:	c6 45 d3 30          	movb   $0x30,-0x2d(%rbp)
			goto reswitch;
  800935:	eb ba                	jmp    8008f1 <vprintfmt+0x89>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800937:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%rbp)
				precision = precision * 10 + ch - '0';
  80093e:	8b 55 d8             	mov    -0x28(%rbp),%edx
  800941:	89 d0                	mov    %edx,%eax
  800943:	c1 e0 02             	shl    $0x2,%eax
  800946:	01 d0                	add    %edx,%eax
  800948:	01 c0                	add    %eax,%eax
  80094a:	01 d8                	add    %ebx,%eax
  80094c:	83 e8 30             	sub    $0x30,%eax
  80094f:	89 45 d8             	mov    %eax,-0x28(%rbp)
				ch = *fmt;
  800952:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800956:	0f b6 00             	movzbl (%rax),%eax
  800959:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80095c:	83 fb 2f             	cmp    $0x2f,%ebx
  80095f:	7e 0c                	jle    80096d <vprintfmt+0x105>
  800961:	83 fb 39             	cmp    $0x39,%ebx
  800964:	7f 07                	jg     80096d <vprintfmt+0x105>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800966:	48 83 45 98 01       	addq   $0x1,-0x68(%rbp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80096b:	eb d1                	jmp    80093e <vprintfmt+0xd6>
			goto process_precision;
  80096d:	eb 58                	jmp    8009c7 <vprintfmt+0x15f>

		case '*':
			precision = va_arg(aq, int);
  80096f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800972:	83 f8 30             	cmp    $0x30,%eax
  800975:	73 17                	jae    80098e <vprintfmt+0x126>
  800977:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80097b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80097e:	89 c0                	mov    %eax,%eax
  800980:	48 01 d0             	add    %rdx,%rax
  800983:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800986:	83 c2 08             	add    $0x8,%edx
  800989:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80098c:	eb 0f                	jmp    80099d <vprintfmt+0x135>
  80098e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800992:	48 89 d0             	mov    %rdx,%rax
  800995:	48 83 c2 08          	add    $0x8,%rdx
  800999:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  80099d:	8b 00                	mov    (%rax),%eax
  80099f:	89 45 d8             	mov    %eax,-0x28(%rbp)
			goto process_precision;
  8009a2:	eb 23                	jmp    8009c7 <vprintfmt+0x15f>

		case '.':
			if (width < 0)
  8009a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8009a8:	79 0c                	jns    8009b6 <vprintfmt+0x14e>
				width = 0;
  8009aa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
			goto reswitch;
  8009b1:	e9 3b ff ff ff       	jmpq   8008f1 <vprintfmt+0x89>
  8009b6:	e9 36 ff ff ff       	jmpq   8008f1 <vprintfmt+0x89>

		case '#':
			altflag = 1;
  8009bb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
			goto reswitch;
  8009c2:	e9 2a ff ff ff       	jmpq   8008f1 <vprintfmt+0x89>

		process_precision:
			if (width < 0)
  8009c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8009cb:	79 12                	jns    8009df <vprintfmt+0x177>
				width = precision, precision = -1;
  8009cd:	8b 45 d8             	mov    -0x28(%rbp),%eax
  8009d0:	89 45 dc             	mov    %eax,-0x24(%rbp)
  8009d3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
			goto reswitch;
  8009da:	e9 12 ff ff ff       	jmpq   8008f1 <vprintfmt+0x89>
  8009df:	e9 0d ff ff ff       	jmpq   8008f1 <vprintfmt+0x89>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009e4:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
			goto reswitch;
  8009e8:	e9 04 ff ff ff       	jmpq   8008f1 <vprintfmt+0x89>

			// character
		case 'c':
			putch(va_arg(aq, int), putdat);
  8009ed:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009f0:	83 f8 30             	cmp    $0x30,%eax
  8009f3:	73 17                	jae    800a0c <vprintfmt+0x1a4>
  8009f5:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8009f9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009fc:	89 c0                	mov    %eax,%eax
  8009fe:	48 01 d0             	add    %rdx,%rax
  800a01:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800a04:	83 c2 08             	add    $0x8,%edx
  800a07:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800a0a:	eb 0f                	jmp    800a1b <vprintfmt+0x1b3>
  800a0c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a10:	48 89 d0             	mov    %rdx,%rax
  800a13:	48 83 c2 08          	add    $0x8,%rdx
  800a17:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800a1b:	8b 10                	mov    (%rax),%edx
  800a1d:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800a21:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800a25:	48 89 ce             	mov    %rcx,%rsi
  800a28:	89 d7                	mov    %edx,%edi
  800a2a:	ff d0                	callq  *%rax
			break;
  800a2c:	e9 40 03 00 00       	jmpq   800d71 <vprintfmt+0x509>

			// error message
		case 'e':
			err = va_arg(aq, int);
  800a31:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a34:	83 f8 30             	cmp    $0x30,%eax
  800a37:	73 17                	jae    800a50 <vprintfmt+0x1e8>
  800a39:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800a3d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a40:	89 c0                	mov    %eax,%eax
  800a42:	48 01 d0             	add    %rdx,%rax
  800a45:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800a48:	83 c2 08             	add    $0x8,%edx
  800a4b:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800a4e:	eb 0f                	jmp    800a5f <vprintfmt+0x1f7>
  800a50:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a54:	48 89 d0             	mov    %rdx,%rax
  800a57:	48 83 c2 08          	add    $0x8,%rdx
  800a5b:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800a5f:	8b 18                	mov    (%rax),%ebx
			if (err < 0)
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	79 02                	jns    800a67 <vprintfmt+0x1ff>
				err = -err;
  800a65:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a67:	83 fb 15             	cmp    $0x15,%ebx
  800a6a:	7f 16                	jg     800a82 <vprintfmt+0x21a>
  800a6c:	48 b8 60 49 80 00 00 	movabs $0x804960,%rax
  800a73:	00 00 00 
  800a76:	48 63 d3             	movslq %ebx,%rdx
  800a79:	4c 8b 24 d0          	mov    (%rax,%rdx,8),%r12
  800a7d:	4d 85 e4             	test   %r12,%r12
  800a80:	75 2e                	jne    800ab0 <vprintfmt+0x248>
				printfmt(putch, putdat, "error %d", err);
  800a82:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800a86:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800a8a:	89 d9                	mov    %ebx,%ecx
  800a8c:	48 ba 21 4a 80 00 00 	movabs $0x804a21,%rdx
  800a93:	00 00 00 
  800a96:	48 89 c7             	mov    %rax,%rdi
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9e:	49 b8 80 0d 80 00 00 	movabs $0x800d80,%r8
  800aa5:	00 00 00 
  800aa8:	41 ff d0             	callq  *%r8
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800aab:	e9 c1 02 00 00       	jmpq   800d71 <vprintfmt+0x509>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800ab0:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800ab4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800ab8:	4c 89 e1             	mov    %r12,%rcx
  800abb:	48 ba 2a 4a 80 00 00 	movabs $0x804a2a,%rdx
  800ac2:	00 00 00 
  800ac5:	48 89 c7             	mov    %rax,%rdi
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	49 b8 80 0d 80 00 00 	movabs $0x800d80,%r8
  800ad4:	00 00 00 
  800ad7:	41 ff d0             	callq  *%r8
			break;
  800ada:	e9 92 02 00 00       	jmpq   800d71 <vprintfmt+0x509>

			// string
		case 's':
			if ((p = va_arg(aq, char *)) == NULL)
  800adf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ae2:	83 f8 30             	cmp    $0x30,%eax
  800ae5:	73 17                	jae    800afe <vprintfmt+0x296>
  800ae7:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800aeb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800aee:	89 c0                	mov    %eax,%eax
  800af0:	48 01 d0             	add    %rdx,%rax
  800af3:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800af6:	83 c2 08             	add    $0x8,%edx
  800af9:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800afc:	eb 0f                	jmp    800b0d <vprintfmt+0x2a5>
  800afe:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b02:	48 89 d0             	mov    %rdx,%rax
  800b05:	48 83 c2 08          	add    $0x8,%rdx
  800b09:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800b0d:	4c 8b 20             	mov    (%rax),%r12
  800b10:	4d 85 e4             	test   %r12,%r12
  800b13:	75 0a                	jne    800b1f <vprintfmt+0x2b7>
				p = "(null)";
  800b15:	49 bc 2d 4a 80 00 00 	movabs $0x804a2d,%r12
  800b1c:	00 00 00 
			if (width > 0 && padc != '-')
  800b1f:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800b23:	7e 3f                	jle    800b64 <vprintfmt+0x2fc>
  800b25:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%rbp)
  800b29:	74 39                	je     800b64 <vprintfmt+0x2fc>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b2b:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800b2e:	48 98                	cltq   
  800b30:	48 89 c6             	mov    %rax,%rsi
  800b33:	4c 89 e7             	mov    %r12,%rdi
  800b36:	48 b8 2c 10 80 00 00 	movabs $0x80102c,%rax
  800b3d:	00 00 00 
  800b40:	ff d0                	callq  *%rax
  800b42:	29 45 dc             	sub    %eax,-0x24(%rbp)
  800b45:	eb 17                	jmp    800b5e <vprintfmt+0x2f6>
					putch(padc, putdat);
  800b47:	0f be 55 d3          	movsbl -0x2d(%rbp),%edx
  800b4b:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800b4f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800b53:	48 89 ce             	mov    %rcx,%rsi
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	ff d0                	callq  *%rax
			// string
		case 's':
			if ((p = va_arg(aq, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5a:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800b5e:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800b62:	7f e3                	jg     800b47 <vprintfmt+0x2df>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b64:	eb 37                	jmp    800b9d <vprintfmt+0x335>
				if (altflag && (ch < ' ' || ch > '~'))
  800b66:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  800b6a:	74 1e                	je     800b8a <vprintfmt+0x322>
  800b6c:	83 fb 1f             	cmp    $0x1f,%ebx
  800b6f:	7e 05                	jle    800b76 <vprintfmt+0x30e>
  800b71:	83 fb 7e             	cmp    $0x7e,%ebx
  800b74:	7e 14                	jle    800b8a <vprintfmt+0x322>
					putch('?', putdat);
  800b76:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800b7a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800b7e:	48 89 d6             	mov    %rdx,%rsi
  800b81:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800b86:	ff d0                	callq  *%rax
  800b88:	eb 0f                	jmp    800b99 <vprintfmt+0x331>
				else
					putch(ch, putdat);
  800b8a:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800b8e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800b92:	48 89 d6             	mov    %rdx,%rsi
  800b95:	89 df                	mov    %ebx,%edi
  800b97:	ff d0                	callq  *%rax
			if ((p = va_arg(aq, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b99:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800b9d:	4c 89 e0             	mov    %r12,%rax
  800ba0:	4c 8d 60 01          	lea    0x1(%rax),%r12
  800ba4:	0f b6 00             	movzbl (%rax),%eax
  800ba7:	0f be d8             	movsbl %al,%ebx
  800baa:	85 db                	test   %ebx,%ebx
  800bac:	74 10                	je     800bbe <vprintfmt+0x356>
  800bae:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800bb2:	78 b2                	js     800b66 <vprintfmt+0x2fe>
  800bb4:	83 6d d8 01          	subl   $0x1,-0x28(%rbp)
  800bb8:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800bbc:	79 a8                	jns    800b66 <vprintfmt+0x2fe>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bbe:	eb 16                	jmp    800bd6 <vprintfmt+0x36e>
				putch(' ', putdat);
  800bc0:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800bc4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800bc8:	48 89 d6             	mov    %rdx,%rsi
  800bcb:	bf 20 00 00 00       	mov    $0x20,%edi
  800bd0:	ff d0                	callq  *%rax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bd2:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800bd6:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800bda:	7f e4                	jg     800bc0 <vprintfmt+0x358>
				putch(' ', putdat);
			break;
  800bdc:	e9 90 01 00 00       	jmpq   800d71 <vprintfmt+0x509>

			// (signed) decimal
		case 'd':
			num = getint(&aq, 3);
  800be1:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800be5:	be 03 00 00 00       	mov    $0x3,%esi
  800bea:	48 89 c7             	mov    %rax,%rdi
  800bed:	48 b8 58 07 80 00 00 	movabs $0x800758,%rax
  800bf4:	00 00 00 
  800bf7:	ff d0                	callq  *%rax
  800bf9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			if ((long long) num < 0) {
  800bfd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c01:	48 85 c0             	test   %rax,%rax
  800c04:	79 1d                	jns    800c23 <vprintfmt+0x3bb>
				putch('-', putdat);
  800c06:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800c0a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800c0e:	48 89 d6             	mov    %rdx,%rsi
  800c11:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800c16:	ff d0                	callq  *%rax
				num = -(long long) num;
  800c18:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c1c:	48 f7 d8             	neg    %rax
  800c1f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			}
			base = 10;
  800c23:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
			goto number;
  800c2a:	e9 d5 00 00 00       	jmpq   800d04 <vprintfmt+0x49c>

			// unsigned decimal
		case 'u':
			num = getuint(&aq, 3);
  800c2f:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800c33:	be 03 00 00 00       	mov    $0x3,%esi
  800c38:	48 89 c7             	mov    %rax,%rdi
  800c3b:	48 b8 48 06 80 00 00 	movabs $0x800648,%rax
  800c42:	00 00 00 
  800c45:	ff d0                	callq  *%rax
  800c47:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 10;
  800c4b:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
			goto number;
  800c52:	e9 ad 00 00 00       	jmpq   800d04 <vprintfmt+0x49c>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&aq, lflag);
  800c57:	8b 55 e0             	mov    -0x20(%rbp),%edx
  800c5a:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800c5e:	89 d6                	mov    %edx,%esi
  800c60:	48 89 c7             	mov    %rax,%rdi
  800c63:	48 b8 58 07 80 00 00 	movabs $0x800758,%rax
  800c6a:	00 00 00 
  800c6d:	ff d0                	callq  *%rax
  800c6f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 8;
  800c73:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
			goto number;
  800c7a:	e9 85 00 00 00       	jmpq   800d04 <vprintfmt+0x49c>


			// pointer
		case 'p':
			putch('0', putdat);
  800c7f:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800c83:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800c87:	48 89 d6             	mov    %rdx,%rsi
  800c8a:	bf 30 00 00 00       	mov    $0x30,%edi
  800c8f:	ff d0                	callq  *%rax
			putch('x', putdat);
  800c91:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800c95:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800c99:	48 89 d6             	mov    %rdx,%rsi
  800c9c:	bf 78 00 00 00       	mov    $0x78,%edi
  800ca1:	ff d0                	callq  *%rax
			num = (unsigned long long)
				(uintptr_t) va_arg(aq, void *);
  800ca3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ca6:	83 f8 30             	cmp    $0x30,%eax
  800ca9:	73 17                	jae    800cc2 <vprintfmt+0x45a>
  800cab:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800caf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cb2:	89 c0                	mov    %eax,%eax
  800cb4:	48 01 d0             	add    %rdx,%rax
  800cb7:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800cba:	83 c2 08             	add    $0x8,%edx
  800cbd:	89 55 b8             	mov    %edx,-0x48(%rbp)

			// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cc0:	eb 0f                	jmp    800cd1 <vprintfmt+0x469>
				(uintptr_t) va_arg(aq, void *);
  800cc2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cc6:	48 89 d0             	mov    %rdx,%rax
  800cc9:	48 83 c2 08          	add    $0x8,%rdx
  800ccd:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800cd1:	48 8b 00             	mov    (%rax),%rax

			// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cd4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				(uintptr_t) va_arg(aq, void *);
			base = 16;
  800cd8:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
			goto number;
  800cdf:	eb 23                	jmp    800d04 <vprintfmt+0x49c>

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&aq, 3);
  800ce1:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800ce5:	be 03 00 00 00       	mov    $0x3,%esi
  800cea:	48 89 c7             	mov    %rax,%rdi
  800ced:	48 b8 48 06 80 00 00 	movabs $0x800648,%rax
  800cf4:	00 00 00 
  800cf7:	ff d0                	callq  *%rax
  800cf9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 16;
  800cfd:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d04:	44 0f be 45 d3       	movsbl -0x2d(%rbp),%r8d
  800d09:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  800d0c:	8b 7d dc             	mov    -0x24(%rbp),%edi
  800d0f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800d13:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800d17:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800d1b:	45 89 c1             	mov    %r8d,%r9d
  800d1e:	41 89 f8             	mov    %edi,%r8d
  800d21:	48 89 c7             	mov    %rax,%rdi
  800d24:	48 b8 8d 05 80 00 00 	movabs $0x80058d,%rax
  800d2b:	00 00 00 
  800d2e:	ff d0                	callq  *%rax
			break;
  800d30:	eb 3f                	jmp    800d71 <vprintfmt+0x509>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d32:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800d36:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800d3a:	48 89 d6             	mov    %rdx,%rsi
  800d3d:	89 df                	mov    %ebx,%edi
  800d3f:	ff d0                	callq  *%rax
			break;
  800d41:	eb 2e                	jmp    800d71 <vprintfmt+0x509>

			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d43:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800d47:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800d4b:	48 89 d6             	mov    %rdx,%rsi
  800d4e:	bf 25 00 00 00       	mov    $0x25,%edi
  800d53:	ff d0                	callq  *%rax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d55:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  800d5a:	eb 05                	jmp    800d61 <vprintfmt+0x4f9>
  800d5c:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  800d61:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800d65:	48 83 e8 01          	sub    $0x1,%rax
  800d69:	0f b6 00             	movzbl (%rax),%eax
  800d6c:	3c 25                	cmp    $0x25,%al
  800d6e:	75 ec                	jne    800d5c <vprintfmt+0x4f4>
				/* do nothing */;
			break;
  800d70:	90                   	nop
		}
	}
  800d71:	90                   	nop
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d72:	e9 43 fb ff ff       	jmpq   8008ba <vprintfmt+0x52>
				/* do nothing */;
			break;
		}
	}
	va_end(aq);
}
  800d77:	48 83 c4 60          	add    $0x60,%rsp
  800d7b:	5b                   	pop    %rbx
  800d7c:	41 5c                	pop    %r12
  800d7e:	5d                   	pop    %rbp
  800d7f:	c3                   	retq   

0000000000800d80 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d80:	55                   	push   %rbp
  800d81:	48 89 e5             	mov    %rsp,%rbp
  800d84:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  800d8b:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  800d92:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  800d99:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800da0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800da7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800dae:	84 c0                	test   %al,%al
  800db0:	74 20                	je     800dd2 <printfmt+0x52>
  800db2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800db6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800dba:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800dbe:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800dc2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800dc6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800dca:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800dce:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  800dd2:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	va_start(ap, fmt);
  800dd9:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800de0:	00 00 00 
  800de3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800dea:	00 00 00 
  800ded:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800df1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800df8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800dff:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	vprintfmt(putch, putdat, fmt, ap);
  800e06:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800e0d:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  800e14:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  800e1b:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800e22:	48 89 c7             	mov    %rax,%rdi
  800e25:	48 b8 68 08 80 00 00 	movabs $0x800868,%rax
  800e2c:	00 00 00 
  800e2f:	ff d0                	callq  *%rax
	va_end(ap);
}
  800e31:	c9                   	leaveq 
  800e32:	c3                   	retq   

0000000000800e33 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800e33:	55                   	push   %rbp
  800e34:	48 89 e5             	mov    %rsp,%rbp
  800e37:	48 83 ec 10          	sub    $0x10,%rsp
  800e3b:	89 7d fc             	mov    %edi,-0x4(%rbp)
  800e3e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	b->cnt++;
  800e42:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800e46:	8b 40 10             	mov    0x10(%rax),%eax
  800e49:	8d 50 01             	lea    0x1(%rax),%edx
  800e4c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800e50:	89 50 10             	mov    %edx,0x10(%rax)
	if (b->buf < b->ebuf)
  800e53:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800e57:	48 8b 10             	mov    (%rax),%rdx
  800e5a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800e5e:	48 8b 40 08          	mov    0x8(%rax),%rax
  800e62:	48 39 c2             	cmp    %rax,%rdx
  800e65:	73 17                	jae    800e7e <sprintputch+0x4b>
		*b->buf++ = ch;
  800e67:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800e6b:	48 8b 00             	mov    (%rax),%rax
  800e6e:	48 8d 48 01          	lea    0x1(%rax),%rcx
  800e72:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800e76:	48 89 0a             	mov    %rcx,(%rdx)
  800e79:	8b 55 fc             	mov    -0x4(%rbp),%edx
  800e7c:	88 10                	mov    %dl,(%rax)
}
  800e7e:	c9                   	leaveq 
  800e7f:	c3                   	retq   

0000000000800e80 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e80:	55                   	push   %rbp
  800e81:	48 89 e5             	mov    %rsp,%rbp
  800e84:	48 83 ec 50          	sub    $0x50,%rsp
  800e88:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800e8c:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  800e8f:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800e93:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
	va_list aq;
	va_copy(aq,ap);
  800e97:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  800e9b:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  800e9f:	48 8b 0a             	mov    (%rdx),%rcx
  800ea2:	48 89 08             	mov    %rcx,(%rax)
  800ea5:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800ea9:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800ead:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800eb1:	48 89 50 10          	mov    %rdx,0x10(%rax)
	struct sprintbuf b = {buf, buf+n-1, 0};
  800eb5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800eb9:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  800ebd:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  800ec0:	48 98                	cltq   
  800ec2:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  800ec6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800eca:	48 01 d0             	add    %rdx,%rax
  800ecd:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  800ed1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)

	if (buf == NULL || n < 1)
  800ed8:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  800edd:	74 06                	je     800ee5 <vsnprintf+0x65>
  800edf:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  800ee3:	7f 07                	jg     800eec <vsnprintf+0x6c>
		return -E_INVAL;
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eea:	eb 2f                	jmp    800f1b <vsnprintf+0x9b>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, aq);
  800eec:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  800ef0:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800ef4:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  800ef8:	48 89 c6             	mov    %rax,%rsi
  800efb:	48 bf 33 0e 80 00 00 	movabs $0x800e33,%rdi
  800f02:	00 00 00 
  800f05:	48 b8 68 08 80 00 00 	movabs $0x800868,%rax
  800f0c:	00 00 00 
  800f0f:	ff d0                	callq  *%rax
	va_end(aq);
	// null terminate the buffer
	*b.buf = '\0';
  800f11:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800f15:	c6 00 00             	movb   $0x0,(%rax)

	return b.cnt;
  800f18:	8b 45 e0             	mov    -0x20(%rbp),%eax
}
  800f1b:	c9                   	leaveq 
  800f1c:	c3                   	retq   

0000000000800f1d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f1d:	55                   	push   %rbp
  800f1e:	48 89 e5             	mov    %rsp,%rbp
  800f21:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800f28:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  800f2f:	89 b5 04 ff ff ff    	mov    %esi,-0xfc(%rbp)
  800f35:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f3c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f43:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f4a:	84 c0                	test   %al,%al
  800f4c:	74 20                	je     800f6e <snprintf+0x51>
  800f4e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f52:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f56:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f5a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f5e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f62:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f66:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f6a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  800f6e:	48 89 95 f8 fe ff ff 	mov    %rdx,-0x108(%rbp)
	va_list ap;
	int rc;
	va_list aq;
	va_start(ap, fmt);
  800f75:	c7 85 30 ff ff ff 18 	movl   $0x18,-0xd0(%rbp)
  800f7c:	00 00 00 
  800f7f:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  800f86:	00 00 00 
  800f89:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f8d:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  800f94:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f9b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
	va_copy(aq,ap);
  800fa2:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  800fa9:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  800fb0:	48 8b 0a             	mov    (%rdx),%rcx
  800fb3:	48 89 08             	mov    %rcx,(%rax)
  800fb6:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800fba:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800fbe:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800fc2:	48 89 50 10          	mov    %rdx,0x10(%rax)
	rc = vsnprintf(buf, n, fmt, aq);
  800fc6:	48 8d 8d 18 ff ff ff 	lea    -0xe8(%rbp),%rcx
  800fcd:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  800fd4:	8b b5 04 ff ff ff    	mov    -0xfc(%rbp),%esi
  800fda:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800fe1:	48 89 c7             	mov    %rax,%rdi
  800fe4:	48 b8 80 0e 80 00 00 	movabs $0x800e80,%rax
  800feb:	00 00 00 
  800fee:	ff d0                	callq  *%rax
  800ff0:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
	va_end(aq);

	return rc;
  800ff6:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
}
  800ffc:	c9                   	leaveq 
  800ffd:	c3                   	retq   

0000000000800ffe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ffe:	55                   	push   %rbp
  800fff:	48 89 e5             	mov    %rsp,%rbp
  801002:	48 83 ec 18          	sub    $0x18,%rsp
  801006:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int n;

	for (n = 0; *s != '\0'; s++)
  80100a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  801011:	eb 09                	jmp    80101c <strlen+0x1e>
		n++;
  801013:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801017:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  80101c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801020:	0f b6 00             	movzbl (%rax),%eax
  801023:	84 c0                	test   %al,%al
  801025:	75 ec                	jne    801013 <strlen+0x15>
		n++;
	return n;
  801027:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  80102a:	c9                   	leaveq 
  80102b:	c3                   	retq   

000000000080102c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80102c:	55                   	push   %rbp
  80102d:	48 89 e5             	mov    %rsp,%rbp
  801030:	48 83 ec 20          	sub    $0x20,%rsp
  801034:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801038:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80103c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  801043:	eb 0e                	jmp    801053 <strnlen+0x27>
		n++;
  801045:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801049:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  80104e:	48 83 6d e0 01       	subq   $0x1,-0x20(%rbp)
  801053:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  801058:	74 0b                	je     801065 <strnlen+0x39>
  80105a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80105e:	0f b6 00             	movzbl (%rax),%eax
  801061:	84 c0                	test   %al,%al
  801063:	75 e0                	jne    801045 <strnlen+0x19>
		n++;
	return n;
  801065:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  801068:	c9                   	leaveq 
  801069:	c3                   	retq   

000000000080106a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80106a:	55                   	push   %rbp
  80106b:	48 89 e5             	mov    %rsp,%rbp
  80106e:	48 83 ec 20          	sub    $0x20,%rsp
  801072:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801076:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	char *ret;

	ret = dst;
  80107a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80107e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	while ((*dst++ = *src++) != '\0')
  801082:	90                   	nop
  801083:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801087:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80108b:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80108f:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801093:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  801097:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  80109b:	0f b6 12             	movzbl (%rdx),%edx
  80109e:	88 10                	mov    %dl,(%rax)
  8010a0:	0f b6 00             	movzbl (%rax),%eax
  8010a3:	84 c0                	test   %al,%al
  8010a5:	75 dc                	jne    801083 <strcpy+0x19>
		/* do nothing */;
	return ret;
  8010a7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8010ab:	c9                   	leaveq 
  8010ac:	c3                   	retq   

00000000008010ad <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010ad:	55                   	push   %rbp
  8010ae:	48 89 e5             	mov    %rsp,%rbp
  8010b1:	48 83 ec 20          	sub    $0x20,%rsp
  8010b5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8010b9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int len = strlen(dst);
  8010bd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8010c1:	48 89 c7             	mov    %rax,%rdi
  8010c4:	48 b8 fe 0f 80 00 00 	movabs $0x800ffe,%rax
  8010cb:	00 00 00 
  8010ce:	ff d0                	callq  *%rax
  8010d0:	89 45 fc             	mov    %eax,-0x4(%rbp)
	strcpy(dst + len, src);
  8010d3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8010d6:	48 63 d0             	movslq %eax,%rdx
  8010d9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8010dd:	48 01 c2             	add    %rax,%rdx
  8010e0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8010e4:	48 89 c6             	mov    %rax,%rsi
  8010e7:	48 89 d7             	mov    %rdx,%rdi
  8010ea:	48 b8 6a 10 80 00 00 	movabs $0x80106a,%rax
  8010f1:	00 00 00 
  8010f4:	ff d0                	callq  *%rax
	return dst;
  8010f6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8010fa:	c9                   	leaveq 
  8010fb:	c3                   	retq   

00000000008010fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8010fc:	55                   	push   %rbp
  8010fd:	48 89 e5             	mov    %rsp,%rbp
  801100:	48 83 ec 28          	sub    $0x28,%rsp
  801104:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801108:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80110c:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	size_t i;
	char *ret;

	ret = dst;
  801110:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801114:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	for (i = 0; i < size; i++) {
  801118:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80111f:	00 
  801120:	eb 2a                	jmp    80114c <strncpy+0x50>
		*dst++ = *src;
  801122:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801126:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80112a:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80112e:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801132:	0f b6 12             	movzbl (%rdx),%edx
  801135:	88 10                	mov    %dl,(%rax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  801137:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80113b:	0f b6 00             	movzbl (%rax),%eax
  80113e:	84 c0                	test   %al,%al
  801140:	74 05                	je     801147 <strncpy+0x4b>
			src++;
  801142:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801147:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80114c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801150:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  801154:	72 cc                	jb     801122 <strncpy+0x26>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  801156:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  80115a:	c9                   	leaveq 
  80115b:	c3                   	retq   

000000000080115c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80115c:	55                   	push   %rbp
  80115d:	48 89 e5             	mov    %rsp,%rbp
  801160:	48 83 ec 28          	sub    $0x28,%rsp
  801164:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801168:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80116c:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	char *dst_in;

	dst_in = dst;
  801170:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801174:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (size > 0) {
  801178:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80117d:	74 3d                	je     8011bc <strlcpy+0x60>
		while (--size > 0 && *src != '\0')
  80117f:	eb 1d                	jmp    80119e <strlcpy+0x42>
			*dst++ = *src++;
  801181:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801185:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801189:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80118d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801191:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  801195:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  801199:	0f b6 12             	movzbl (%rdx),%edx
  80119c:	88 10                	mov    %dl,(%rax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80119e:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  8011a3:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8011a8:	74 0b                	je     8011b5 <strlcpy+0x59>
  8011aa:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8011ae:	0f b6 00             	movzbl (%rax),%eax
  8011b1:	84 c0                	test   %al,%al
  8011b3:	75 cc                	jne    801181 <strlcpy+0x25>
			*dst++ = *src++;
		*dst = '\0';
  8011b5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8011b9:	c6 00 00             	movb   $0x0,(%rax)
	}
	return dst - dst_in;
  8011bc:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8011c0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8011c4:	48 29 c2             	sub    %rax,%rdx
  8011c7:	48 89 d0             	mov    %rdx,%rax
}
  8011ca:	c9                   	leaveq 
  8011cb:	c3                   	retq   

00000000008011cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8011cc:	55                   	push   %rbp
  8011cd:	48 89 e5             	mov    %rsp,%rbp
  8011d0:	48 83 ec 10          	sub    $0x10,%rsp
  8011d4:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8011d8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	while (*p && *p == *q)
  8011dc:	eb 0a                	jmp    8011e8 <strcmp+0x1c>
		p++, q++;
  8011de:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8011e3:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8011e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8011ec:	0f b6 00             	movzbl (%rax),%eax
  8011ef:	84 c0                	test   %al,%al
  8011f1:	74 12                	je     801205 <strcmp+0x39>
  8011f3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8011f7:	0f b6 10             	movzbl (%rax),%edx
  8011fa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8011fe:	0f b6 00             	movzbl (%rax),%eax
  801201:	38 c2                	cmp    %al,%dl
  801203:	74 d9                	je     8011de <strcmp+0x12>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801205:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801209:	0f b6 00             	movzbl (%rax),%eax
  80120c:	0f b6 d0             	movzbl %al,%edx
  80120f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801213:	0f b6 00             	movzbl (%rax),%eax
  801216:	0f b6 c0             	movzbl %al,%eax
  801219:	29 c2                	sub    %eax,%edx
  80121b:	89 d0                	mov    %edx,%eax
}
  80121d:	c9                   	leaveq 
  80121e:	c3                   	retq   

000000000080121f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80121f:	55                   	push   %rbp
  801220:	48 89 e5             	mov    %rsp,%rbp
  801223:	48 83 ec 18          	sub    $0x18,%rsp
  801227:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80122b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80122f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	while (n > 0 && *p && *p == *q)
  801233:	eb 0f                	jmp    801244 <strncmp+0x25>
		n--, p++, q++;
  801235:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  80123a:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80123f:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801244:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801249:	74 1d                	je     801268 <strncmp+0x49>
  80124b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80124f:	0f b6 00             	movzbl (%rax),%eax
  801252:	84 c0                	test   %al,%al
  801254:	74 12                	je     801268 <strncmp+0x49>
  801256:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80125a:	0f b6 10             	movzbl (%rax),%edx
  80125d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801261:	0f b6 00             	movzbl (%rax),%eax
  801264:	38 c2                	cmp    %al,%dl
  801266:	74 cd                	je     801235 <strncmp+0x16>
		n--, p++, q++;
	if (n == 0)
  801268:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80126d:	75 07                	jne    801276 <strncmp+0x57>
		return 0;
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
  801274:	eb 18                	jmp    80128e <strncmp+0x6f>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801276:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80127a:	0f b6 00             	movzbl (%rax),%eax
  80127d:	0f b6 d0             	movzbl %al,%edx
  801280:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801284:	0f b6 00             	movzbl (%rax),%eax
  801287:	0f b6 c0             	movzbl %al,%eax
  80128a:	29 c2                	sub    %eax,%edx
  80128c:	89 d0                	mov    %edx,%eax
}
  80128e:	c9                   	leaveq 
  80128f:	c3                   	retq   

0000000000801290 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801290:	55                   	push   %rbp
  801291:	48 89 e5             	mov    %rsp,%rbp
  801294:	48 83 ec 0c          	sub    $0xc,%rsp
  801298:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80129c:	89 f0                	mov    %esi,%eax
  80129e:	88 45 f4             	mov    %al,-0xc(%rbp)
	for (; *s; s++)
  8012a1:	eb 17                	jmp    8012ba <strchr+0x2a>
		if (*s == c)
  8012a3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8012a7:	0f b6 00             	movzbl (%rax),%eax
  8012aa:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8012ad:	75 06                	jne    8012b5 <strchr+0x25>
			return (char *) s;
  8012af:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8012b3:	eb 15                	jmp    8012ca <strchr+0x3a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012b5:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8012ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8012be:	0f b6 00             	movzbl (%rax),%eax
  8012c1:	84 c0                	test   %al,%al
  8012c3:	75 de                	jne    8012a3 <strchr+0x13>
		if (*s == c)
			return (char *) s;
	return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ca:	c9                   	leaveq 
  8012cb:	c3                   	retq   

00000000008012cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012cc:	55                   	push   %rbp
  8012cd:	48 89 e5             	mov    %rsp,%rbp
  8012d0:	48 83 ec 0c          	sub    $0xc,%rsp
  8012d4:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8012d8:	89 f0                	mov    %esi,%eax
  8012da:	88 45 f4             	mov    %al,-0xc(%rbp)
	for (; *s; s++)
  8012dd:	eb 13                	jmp    8012f2 <strfind+0x26>
		if (*s == c)
  8012df:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8012e3:	0f b6 00             	movzbl (%rax),%eax
  8012e6:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8012e9:	75 02                	jne    8012ed <strfind+0x21>
			break;
  8012eb:	eb 10                	jmp    8012fd <strfind+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012ed:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8012f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8012f6:	0f b6 00             	movzbl (%rax),%eax
  8012f9:	84 c0                	test   %al,%al
  8012fb:	75 e2                	jne    8012df <strfind+0x13>
		if (*s == c)
			break;
	return (char *) s;
  8012fd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  801301:	c9                   	leaveq 
  801302:	c3                   	retq   

0000000000801303 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801303:	55                   	push   %rbp
  801304:	48 89 e5             	mov    %rsp,%rbp
  801307:	48 83 ec 18          	sub    $0x18,%rsp
  80130b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80130f:	89 75 f4             	mov    %esi,-0xc(%rbp)
  801312:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	char *p;

	if (n == 0)
  801316:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80131b:	75 06                	jne    801323 <memset+0x20>
		return v;
  80131d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801321:	eb 69                	jmp    80138c <memset+0x89>
	if ((int64_t)v%4 == 0 && n%4 == 0) {
  801323:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801327:	83 e0 03             	and    $0x3,%eax
  80132a:	48 85 c0             	test   %rax,%rax
  80132d:	75 48                	jne    801377 <memset+0x74>
  80132f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801333:	83 e0 03             	and    $0x3,%eax
  801336:	48 85 c0             	test   %rax,%rax
  801339:	75 3c                	jne    801377 <memset+0x74>
		c &= 0xFF;
  80133b:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801342:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801345:	c1 e0 18             	shl    $0x18,%eax
  801348:	89 c2                	mov    %eax,%edx
  80134a:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80134d:	c1 e0 10             	shl    $0x10,%eax
  801350:	09 c2                	or     %eax,%edx
  801352:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801355:	c1 e0 08             	shl    $0x8,%eax
  801358:	09 d0                	or     %edx,%eax
  80135a:	09 45 f4             	or     %eax,-0xc(%rbp)
		asm volatile("cld; rep stosl\n"
			     :: "D" (v), "a" (c), "c" (n/4)
  80135d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801361:	48 c1 e8 02          	shr    $0x2,%rax
  801365:	48 89 c1             	mov    %rax,%rcx
	if (n == 0)
		return v;
	if ((int64_t)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801368:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80136c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80136f:	48 89 d7             	mov    %rdx,%rdi
  801372:	fc                   	cld    
  801373:	f3 ab                	rep stos %eax,%es:(%rdi)
  801375:	eb 11                	jmp    801388 <memset+0x85>
			     :: "D" (v), "a" (c), "c" (n/4)
			     : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801377:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80137b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80137e:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  801382:	48 89 d7             	mov    %rdx,%rdi
  801385:	fc                   	cld    
  801386:	f3 aa                	rep stos %al,%es:(%rdi)
			     :: "D" (v), "a" (c), "c" (n)
			     : "cc", "memory");
	return v;
  801388:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  80138c:	c9                   	leaveq 
  80138d:	c3                   	retq   

000000000080138e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80138e:	55                   	push   %rbp
  80138f:	48 89 e5             	mov    %rsp,%rbp
  801392:	48 83 ec 28          	sub    $0x28,%rsp
  801396:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80139a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80139e:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const char *s;
	char *d;

	s = src;
  8013a2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8013a6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	d = dst;
  8013aa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8013ae:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	if (s < d && s + n > d) {
  8013b2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8013b6:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8013ba:	0f 83 88 00 00 00    	jae    801448 <memmove+0xba>
  8013c0:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8013c4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8013c8:	48 01 d0             	add    %rdx,%rax
  8013cb:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8013cf:	76 77                	jbe    801448 <memmove+0xba>
		s += n;
  8013d1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8013d5:	48 01 45 f8          	add    %rax,-0x8(%rbp)
		d += n;
  8013d9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8013dd:	48 01 45 f0          	add    %rax,-0x10(%rbp)
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
  8013e1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8013e5:	83 e0 03             	and    $0x3,%eax
  8013e8:	48 85 c0             	test   %rax,%rax
  8013eb:	75 3b                	jne    801428 <memmove+0x9a>
  8013ed:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8013f1:	83 e0 03             	and    $0x3,%eax
  8013f4:	48 85 c0             	test   %rax,%rax
  8013f7:	75 2f                	jne    801428 <memmove+0x9a>
  8013f9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8013fd:	83 e0 03             	and    $0x3,%eax
  801400:	48 85 c0             	test   %rax,%rax
  801403:	75 23                	jne    801428 <memmove+0x9a>
			asm volatile("std; rep movsl\n"
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801405:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801409:	48 83 e8 04          	sub    $0x4,%rax
  80140d:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801411:	48 83 ea 04          	sub    $0x4,%rdx
  801415:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  801419:	48 c1 e9 02          	shr    $0x2,%rcx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80141d:	48 89 c7             	mov    %rax,%rdi
  801420:	48 89 d6             	mov    %rdx,%rsi
  801423:	fd                   	std    
  801424:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  801426:	eb 1d                	jmp    801445 <memmove+0xb7>
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801428:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80142c:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  801430:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801434:	48 8d 70 ff          	lea    -0x1(%rax),%rsi
		d += n;
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801438:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80143c:	48 89 d7             	mov    %rdx,%rdi
  80143f:	48 89 c1             	mov    %rax,%rcx
  801442:	fd                   	std    
  801443:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801445:	fc                   	cld    
  801446:	eb 57                	jmp    80149f <memmove+0x111>
	} else {
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
  801448:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80144c:	83 e0 03             	and    $0x3,%eax
  80144f:	48 85 c0             	test   %rax,%rax
  801452:	75 36                	jne    80148a <memmove+0xfc>
  801454:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801458:	83 e0 03             	and    $0x3,%eax
  80145b:	48 85 c0             	test   %rax,%rax
  80145e:	75 2a                	jne    80148a <memmove+0xfc>
  801460:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801464:	83 e0 03             	and    $0x3,%eax
  801467:	48 85 c0             	test   %rax,%rax
  80146a:	75 1e                	jne    80148a <memmove+0xfc>
			asm volatile("cld; rep movsl\n"
				     :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80146c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801470:	48 c1 e8 02          	shr    $0x2,%rax
  801474:	48 89 c1             	mov    %rax,%rcx
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801477:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80147b:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80147f:	48 89 c7             	mov    %rax,%rdi
  801482:	48 89 d6             	mov    %rdx,%rsi
  801485:	fc                   	cld    
  801486:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  801488:	eb 15                	jmp    80149f <memmove+0x111>
				     :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80148a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80148e:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801492:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  801496:	48 89 c7             	mov    %rax,%rdi
  801499:	48 89 d6             	mov    %rdx,%rsi
  80149c:	fc                   	cld    
  80149d:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
				     :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  80149f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8014a3:	c9                   	leaveq 
  8014a4:	c3                   	retq   

00000000008014a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8014a5:	55                   	push   %rbp
  8014a6:	48 89 e5             	mov    %rsp,%rbp
  8014a9:	48 83 ec 18          	sub    $0x18,%rsp
  8014ad:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8014b1:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8014b5:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	return memmove(dst, src, n);
  8014b9:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8014bd:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  8014c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8014c5:	48 89 ce             	mov    %rcx,%rsi
  8014c8:	48 89 c7             	mov    %rax,%rdi
  8014cb:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  8014d2:	00 00 00 
  8014d5:	ff d0                	callq  *%rax
}
  8014d7:	c9                   	leaveq 
  8014d8:	c3                   	retq   

00000000008014d9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8014d9:	55                   	push   %rbp
  8014da:	48 89 e5             	mov    %rsp,%rbp
  8014dd:	48 83 ec 28          	sub    $0x28,%rsp
  8014e1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8014e5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8014e9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const uint8_t *s1 = (const uint8_t *) v1;
  8014ed:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8014f1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	const uint8_t *s2 = (const uint8_t *) v2;
  8014f5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8014f9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	while (n-- > 0) {
  8014fd:	eb 36                	jmp    801535 <memcmp+0x5c>
		if (*s1 != *s2)
  8014ff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801503:	0f b6 10             	movzbl (%rax),%edx
  801506:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80150a:	0f b6 00             	movzbl (%rax),%eax
  80150d:	38 c2                	cmp    %al,%dl
  80150f:	74 1a                	je     80152b <memcmp+0x52>
			return (int) *s1 - (int) *s2;
  801511:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801515:	0f b6 00             	movzbl (%rax),%eax
  801518:	0f b6 d0             	movzbl %al,%edx
  80151b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80151f:	0f b6 00             	movzbl (%rax),%eax
  801522:	0f b6 c0             	movzbl %al,%eax
  801525:	29 c2                	sub    %eax,%edx
  801527:	89 d0                	mov    %edx,%eax
  801529:	eb 20                	jmp    80154b <memcmp+0x72>
		s1++, s2++;
  80152b:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801530:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801535:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801539:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  80153d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801541:	48 85 c0             	test   %rax,%rax
  801544:	75 b9                	jne    8014ff <memcmp+0x26>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801546:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154b:	c9                   	leaveq 
  80154c:	c3                   	retq   

000000000080154d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80154d:	55                   	push   %rbp
  80154e:	48 89 e5             	mov    %rsp,%rbp
  801551:	48 83 ec 28          	sub    $0x28,%rsp
  801555:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801559:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  80155c:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const void *ends = (const char *) s + n;
  801560:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801564:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801568:	48 01 d0             	add    %rdx,%rax
  80156b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	for (; s < ends; s++)
  80156f:	eb 15                	jmp    801586 <memfind+0x39>
		if (*(const unsigned char *) s == (unsigned char) c)
  801571:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801575:	0f b6 10             	movzbl (%rax),%edx
  801578:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80157b:	38 c2                	cmp    %al,%dl
  80157d:	75 02                	jne    801581 <memfind+0x34>
			break;
  80157f:	eb 0f                	jmp    801590 <memfind+0x43>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801581:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  801586:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80158a:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  80158e:	72 e1                	jb     801571 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801590:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  801594:	c9                   	leaveq 
  801595:	c3                   	retq   

0000000000801596 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801596:	55                   	push   %rbp
  801597:	48 89 e5             	mov    %rsp,%rbp
  80159a:	48 83 ec 34          	sub    $0x34,%rsp
  80159e:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8015a2:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8015a6:	89 55 cc             	mov    %edx,-0x34(%rbp)
	int neg = 0;
  8015a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	long val = 0;
  8015b0:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8015b7:	00 

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8015b8:	eb 05                	jmp    8015bf <strtol+0x29>
		s++;
  8015ba:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8015bf:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8015c3:	0f b6 00             	movzbl (%rax),%eax
  8015c6:	3c 20                	cmp    $0x20,%al
  8015c8:	74 f0                	je     8015ba <strtol+0x24>
  8015ca:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8015ce:	0f b6 00             	movzbl (%rax),%eax
  8015d1:	3c 09                	cmp    $0x9,%al
  8015d3:	74 e5                	je     8015ba <strtol+0x24>
		s++;

	// plus/minus sign
	if (*s == '+')
  8015d5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8015d9:	0f b6 00             	movzbl (%rax),%eax
  8015dc:	3c 2b                	cmp    $0x2b,%al
  8015de:	75 07                	jne    8015e7 <strtol+0x51>
		s++;
  8015e0:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8015e5:	eb 17                	jmp    8015fe <strtol+0x68>
	else if (*s == '-')
  8015e7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8015eb:	0f b6 00             	movzbl (%rax),%eax
  8015ee:	3c 2d                	cmp    $0x2d,%al
  8015f0:	75 0c                	jne    8015fe <strtol+0x68>
		s++, neg = 1;
  8015f2:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8015f7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8015fe:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801602:	74 06                	je     80160a <strtol+0x74>
  801604:	83 7d cc 10          	cmpl   $0x10,-0x34(%rbp)
  801608:	75 28                	jne    801632 <strtol+0x9c>
  80160a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80160e:	0f b6 00             	movzbl (%rax),%eax
  801611:	3c 30                	cmp    $0x30,%al
  801613:	75 1d                	jne    801632 <strtol+0x9c>
  801615:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801619:	48 83 c0 01          	add    $0x1,%rax
  80161d:	0f b6 00             	movzbl (%rax),%eax
  801620:	3c 78                	cmp    $0x78,%al
  801622:	75 0e                	jne    801632 <strtol+0x9c>
		s += 2, base = 16;
  801624:	48 83 45 d8 02       	addq   $0x2,-0x28(%rbp)
  801629:	c7 45 cc 10 00 00 00 	movl   $0x10,-0x34(%rbp)
  801630:	eb 2c                	jmp    80165e <strtol+0xc8>
	else if (base == 0 && s[0] == '0')
  801632:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801636:	75 19                	jne    801651 <strtol+0xbb>
  801638:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80163c:	0f b6 00             	movzbl (%rax),%eax
  80163f:	3c 30                	cmp    $0x30,%al
  801641:	75 0e                	jne    801651 <strtol+0xbb>
		s++, base = 8;
  801643:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801648:	c7 45 cc 08 00 00 00 	movl   $0x8,-0x34(%rbp)
  80164f:	eb 0d                	jmp    80165e <strtol+0xc8>
	else if (base == 0)
  801651:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801655:	75 07                	jne    80165e <strtol+0xc8>
		base = 10;
  801657:	c7 45 cc 0a 00 00 00 	movl   $0xa,-0x34(%rbp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80165e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801662:	0f b6 00             	movzbl (%rax),%eax
  801665:	3c 2f                	cmp    $0x2f,%al
  801667:	7e 1d                	jle    801686 <strtol+0xf0>
  801669:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80166d:	0f b6 00             	movzbl (%rax),%eax
  801670:	3c 39                	cmp    $0x39,%al
  801672:	7f 12                	jg     801686 <strtol+0xf0>
			dig = *s - '0';
  801674:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801678:	0f b6 00             	movzbl (%rax),%eax
  80167b:	0f be c0             	movsbl %al,%eax
  80167e:	83 e8 30             	sub    $0x30,%eax
  801681:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801684:	eb 4e                	jmp    8016d4 <strtol+0x13e>
		else if (*s >= 'a' && *s <= 'z')
  801686:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80168a:	0f b6 00             	movzbl (%rax),%eax
  80168d:	3c 60                	cmp    $0x60,%al
  80168f:	7e 1d                	jle    8016ae <strtol+0x118>
  801691:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801695:	0f b6 00             	movzbl (%rax),%eax
  801698:	3c 7a                	cmp    $0x7a,%al
  80169a:	7f 12                	jg     8016ae <strtol+0x118>
			dig = *s - 'a' + 10;
  80169c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8016a0:	0f b6 00             	movzbl (%rax),%eax
  8016a3:	0f be c0             	movsbl %al,%eax
  8016a6:	83 e8 57             	sub    $0x57,%eax
  8016a9:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8016ac:	eb 26                	jmp    8016d4 <strtol+0x13e>
		else if (*s >= 'A' && *s <= 'Z')
  8016ae:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8016b2:	0f b6 00             	movzbl (%rax),%eax
  8016b5:	3c 40                	cmp    $0x40,%al
  8016b7:	7e 48                	jle    801701 <strtol+0x16b>
  8016b9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8016bd:	0f b6 00             	movzbl (%rax),%eax
  8016c0:	3c 5a                	cmp    $0x5a,%al
  8016c2:	7f 3d                	jg     801701 <strtol+0x16b>
			dig = *s - 'A' + 10;
  8016c4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8016c8:	0f b6 00             	movzbl (%rax),%eax
  8016cb:	0f be c0             	movsbl %al,%eax
  8016ce:	83 e8 37             	sub    $0x37,%eax
  8016d1:	89 45 ec             	mov    %eax,-0x14(%rbp)
		else
			break;
		if (dig >= base)
  8016d4:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8016d7:	3b 45 cc             	cmp    -0x34(%rbp),%eax
  8016da:	7c 02                	jl     8016de <strtol+0x148>
			break;
  8016dc:	eb 23                	jmp    801701 <strtol+0x16b>
		s++, val = (val * base) + dig;
  8016de:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8016e3:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8016e6:	48 98                	cltq   
  8016e8:	48 0f af 45 f0       	imul   -0x10(%rbp),%rax
  8016ed:	48 89 c2             	mov    %rax,%rdx
  8016f0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8016f3:	48 98                	cltq   
  8016f5:	48 01 d0             	add    %rdx,%rax
  8016f8:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
		// we don't properly detect overflow!
	}
  8016fc:	e9 5d ff ff ff       	jmpq   80165e <strtol+0xc8>

	if (endptr)
  801701:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  801706:	74 0b                	je     801713 <strtol+0x17d>
		*endptr = (char *) s;
  801708:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80170c:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  801710:	48 89 10             	mov    %rdx,(%rax)
	return (neg ? -val : val);
  801713:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  801717:	74 09                	je     801722 <strtol+0x18c>
  801719:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80171d:	48 f7 d8             	neg    %rax
  801720:	eb 04                	jmp    801726 <strtol+0x190>
  801722:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  801726:	c9                   	leaveq 
  801727:	c3                   	retq   

0000000000801728 <strstr>:

char * strstr(const char *in, const char *str)
{
  801728:	55                   	push   %rbp
  801729:	48 89 e5             	mov    %rsp,%rbp
  80172c:	48 83 ec 30          	sub    $0x30,%rsp
  801730:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  801734:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	char c;
	size_t len;

	c = *str++;
  801738:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80173c:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801740:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801744:	0f b6 00             	movzbl (%rax),%eax
  801747:	88 45 ff             	mov    %al,-0x1(%rbp)
	if (!c)
  80174a:	80 7d ff 00          	cmpb   $0x0,-0x1(%rbp)
  80174e:	75 06                	jne    801756 <strstr+0x2e>
		return (char *) in;	// Trivial empty string case
  801750:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801754:	eb 6b                	jmp    8017c1 <strstr+0x99>

	len = strlen(str);
  801756:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80175a:	48 89 c7             	mov    %rax,%rdi
  80175d:	48 b8 fe 0f 80 00 00 	movabs $0x800ffe,%rax
  801764:	00 00 00 
  801767:	ff d0                	callq  *%rax
  801769:	48 98                	cltq   
  80176b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	do {
		char sc;

		do {
			sc = *in++;
  80176f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801773:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801777:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80177b:	0f b6 00             	movzbl (%rax),%eax
  80177e:	88 45 ef             	mov    %al,-0x11(%rbp)
			if (!sc)
  801781:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  801785:	75 07                	jne    80178e <strstr+0x66>
				return (char *) 0;
  801787:	b8 00 00 00 00       	mov    $0x0,%eax
  80178c:	eb 33                	jmp    8017c1 <strstr+0x99>
		} while (sc != c);
  80178e:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  801792:	3a 45 ff             	cmp    -0x1(%rbp),%al
  801795:	75 d8                	jne    80176f <strstr+0x47>
	} while (strncmp(in, str, len) != 0);
  801797:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80179b:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  80179f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8017a3:	48 89 ce             	mov    %rcx,%rsi
  8017a6:	48 89 c7             	mov    %rax,%rdi
  8017a9:	48 b8 1f 12 80 00 00 	movabs $0x80121f,%rax
  8017b0:	00 00 00 
  8017b3:	ff d0                	callq  *%rax
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	75 b6                	jne    80176f <strstr+0x47>

	return (char *) (in - 1);
  8017b9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8017bd:	48 83 e8 01          	sub    $0x1,%rax
}
  8017c1:	c9                   	leaveq 
  8017c2:	c3                   	retq   

00000000008017c3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int64_t
syscall(int num, int check, uint64_t a1, uint64_t a2, uint64_t a3, uint64_t a4, uint64_t a5)
{
  8017c3:	55                   	push   %rbp
  8017c4:	48 89 e5             	mov    %rsp,%rbp
  8017c7:	53                   	push   %rbx
  8017c8:	48 83 ec 48          	sub    $0x48,%rsp
  8017cc:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8017cf:	89 75 d8             	mov    %esi,-0x28(%rbp)
  8017d2:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8017d6:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  8017da:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  8017de:	4c 89 4d b8          	mov    %r9,-0x48(%rbp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017e2:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8017e5:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8017e9:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  8017ed:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  8017f1:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8017f5:	48 8b 75 10          	mov    0x10(%rbp),%rsi
  8017f9:	4c 89 c3             	mov    %r8,%rbx
  8017fc:	cd 30                	int    $0x30
  8017fe:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801802:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  801806:	74 3e                	je     801846 <syscall+0x83>
  801808:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80180d:	7e 37                	jle    801846 <syscall+0x83>
		panic("syscall %d returned %d (> 0)", num, ret);
  80180f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801813:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801816:	49 89 d0             	mov    %rdx,%r8
  801819:	89 c1                	mov    %eax,%ecx
  80181b:	48 ba e8 4c 80 00 00 	movabs $0x804ce8,%rdx
  801822:	00 00 00 
  801825:	be 23 00 00 00       	mov    $0x23,%esi
  80182a:	48 bf 05 4d 80 00 00 	movabs $0x804d05,%rdi
  801831:	00 00 00 
  801834:	b8 00 00 00 00       	mov    $0x0,%eax
  801839:	49 b9 7c 02 80 00 00 	movabs $0x80027c,%r9
  801840:	00 00 00 
  801843:	41 ff d1             	callq  *%r9

	return ret;
  801846:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  80184a:	48 83 c4 48          	add    $0x48,%rsp
  80184e:	5b                   	pop    %rbx
  80184f:	5d                   	pop    %rbp
  801850:	c3                   	retq   

0000000000801851 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801851:	55                   	push   %rbp
  801852:	48 89 e5             	mov    %rsp,%rbp
  801855:	48 83 ec 20          	sub    $0x20,%rsp
  801859:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80185d:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
  801861:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801865:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801869:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801870:	00 
  801871:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801877:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80187d:	48 89 d1             	mov    %rdx,%rcx
  801880:	48 89 c2             	mov    %rax,%rdx
  801883:	be 00 00 00 00       	mov    $0x0,%esi
  801888:	bf 00 00 00 00       	mov    $0x0,%edi
  80188d:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801894:	00 00 00 
  801897:	ff d0                	callq  *%rax
}
  801899:	c9                   	leaveq 
  80189a:	c3                   	retq   

000000000080189b <sys_cgetc>:

int
sys_cgetc(void)
{
  80189b:	55                   	push   %rbp
  80189c:	48 89 e5             	mov    %rsp,%rbp
  80189f:	48 83 ec 10          	sub    $0x10,%rsp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8018a3:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8018aa:	00 
  8018ab:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8018b1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8018b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	be 00 00 00 00       	mov    $0x0,%esi
  8018c6:	bf 01 00 00 00       	mov    $0x1,%edi
  8018cb:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  8018d2:	00 00 00 
  8018d5:	ff d0                	callq  *%rax
}
  8018d7:	c9                   	leaveq 
  8018d8:	c3                   	retq   

00000000008018d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8018d9:	55                   	push   %rbp
  8018da:	48 89 e5             	mov    %rsp,%rbp
  8018dd:	48 83 ec 10          	sub    $0x10,%rsp
  8018e1:	89 7d fc             	mov    %edi,-0x4(%rbp)
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8018e4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8018e7:	48 98                	cltq   
  8018e9:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8018f0:	00 
  8018f1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8018f7:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8018fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801902:	48 89 c2             	mov    %rax,%rdx
  801905:	be 01 00 00 00       	mov    $0x1,%esi
  80190a:	bf 03 00 00 00       	mov    $0x3,%edi
  80190f:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801916:	00 00 00 
  801919:	ff d0                	callq  *%rax
}
  80191b:	c9                   	leaveq 
  80191c:	c3                   	retq   

000000000080191d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80191d:	55                   	push   %rbp
  80191e:	48 89 e5             	mov    %rsp,%rbp
  801921:	48 83 ec 10          	sub    $0x10,%rsp
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801925:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80192c:	00 
  80192d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801933:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801939:	b9 00 00 00 00       	mov    $0x0,%ecx
  80193e:	ba 00 00 00 00       	mov    $0x0,%edx
  801943:	be 00 00 00 00       	mov    $0x0,%esi
  801948:	bf 02 00 00 00       	mov    $0x2,%edi
  80194d:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801954:	00 00 00 
  801957:	ff d0                	callq  *%rax
}
  801959:	c9                   	leaveq 
  80195a:	c3                   	retq   

000000000080195b <sys_yield>:

void
sys_yield(void)
{
  80195b:	55                   	push   %rbp
  80195c:	48 89 e5             	mov    %rsp,%rbp
  80195f:	48 83 ec 10          	sub    $0x10,%rsp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801963:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80196a:	00 
  80196b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801971:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801977:	b9 00 00 00 00       	mov    $0x0,%ecx
  80197c:	ba 00 00 00 00       	mov    $0x0,%edx
  801981:	be 00 00 00 00       	mov    $0x0,%esi
  801986:	bf 0b 00 00 00       	mov    $0xb,%edi
  80198b:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801992:	00 00 00 
  801995:	ff d0                	callq  *%rax
}
  801997:	c9                   	leaveq 
  801998:	c3                   	retq   

0000000000801999 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801999:	55                   	push   %rbp
  80199a:	48 89 e5             	mov    %rsp,%rbp
  80199d:	48 83 ec 20          	sub    $0x20,%rsp
  8019a1:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8019a4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8019a8:	89 55 f8             	mov    %edx,-0x8(%rbp)
	return syscall(SYS_page_alloc, 1, envid, (uint64_t) va, perm, 0, 0);
  8019ab:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8019ae:	48 63 c8             	movslq %eax,%rcx
  8019b1:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8019b5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8019b8:	48 98                	cltq   
  8019ba:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8019c1:	00 
  8019c2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8019c8:	49 89 c8             	mov    %rcx,%r8
  8019cb:	48 89 d1             	mov    %rdx,%rcx
  8019ce:	48 89 c2             	mov    %rax,%rdx
  8019d1:	be 01 00 00 00       	mov    $0x1,%esi
  8019d6:	bf 04 00 00 00       	mov    $0x4,%edi
  8019db:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  8019e2:	00 00 00 
  8019e5:	ff d0                	callq  *%rax
}
  8019e7:	c9                   	leaveq 
  8019e8:	c3                   	retq   

00000000008019e9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8019e9:	55                   	push   %rbp
  8019ea:	48 89 e5             	mov    %rsp,%rbp
  8019ed:	48 83 ec 30          	sub    $0x30,%rsp
  8019f1:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8019f4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8019f8:	89 55 f8             	mov    %edx,-0x8(%rbp)
  8019fb:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  8019ff:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
	return syscall(SYS_page_map, 1, srcenv, (uint64_t) srcva, dstenv, (uint64_t) dstva, perm);
  801a03:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  801a06:	48 63 c8             	movslq %eax,%rcx
  801a09:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  801a0d:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801a10:	48 63 f0             	movslq %eax,%rsi
  801a13:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801a17:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801a1a:	48 98                	cltq   
  801a1c:	48 89 0c 24          	mov    %rcx,(%rsp)
  801a20:	49 89 f9             	mov    %rdi,%r9
  801a23:	49 89 f0             	mov    %rsi,%r8
  801a26:	48 89 d1             	mov    %rdx,%rcx
  801a29:	48 89 c2             	mov    %rax,%rdx
  801a2c:	be 01 00 00 00       	mov    $0x1,%esi
  801a31:	bf 05 00 00 00       	mov    $0x5,%edi
  801a36:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801a3d:	00 00 00 
  801a40:	ff d0                	callq  *%rax
}
  801a42:	c9                   	leaveq 
  801a43:	c3                   	retq   

0000000000801a44 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801a44:	55                   	push   %rbp
  801a45:	48 89 e5             	mov    %rsp,%rbp
  801a48:	48 83 ec 20          	sub    $0x20,%rsp
  801a4c:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801a4f:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	return syscall(SYS_page_unmap, 1, envid, (uint64_t) va, 0, 0, 0);
  801a53:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801a57:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801a5a:	48 98                	cltq   
  801a5c:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801a63:	00 
  801a64:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801a6a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801a70:	48 89 d1             	mov    %rdx,%rcx
  801a73:	48 89 c2             	mov    %rax,%rdx
  801a76:	be 01 00 00 00       	mov    $0x1,%esi
  801a7b:	bf 06 00 00 00       	mov    $0x6,%edi
  801a80:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801a87:	00 00 00 
  801a8a:	ff d0                	callq  *%rax
}
  801a8c:	c9                   	leaveq 
  801a8d:	c3                   	retq   

0000000000801a8e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801a8e:	55                   	push   %rbp
  801a8f:	48 89 e5             	mov    %rsp,%rbp
  801a92:	48 83 ec 10          	sub    $0x10,%rsp
  801a96:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801a99:	89 75 f8             	mov    %esi,-0x8(%rbp)
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801a9c:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801a9f:	48 63 d0             	movslq %eax,%rdx
  801aa2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801aa5:	48 98                	cltq   
  801aa7:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801aae:	00 
  801aaf:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801ab5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801abb:	48 89 d1             	mov    %rdx,%rcx
  801abe:	48 89 c2             	mov    %rax,%rdx
  801ac1:	be 01 00 00 00       	mov    $0x1,%esi
  801ac6:	bf 08 00 00 00       	mov    $0x8,%edi
  801acb:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801ad2:	00 00 00 
  801ad5:	ff d0                	callq  *%rax
}
  801ad7:	c9                   	leaveq 
  801ad8:	c3                   	retq   

0000000000801ad9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801ad9:	55                   	push   %rbp
  801ada:	48 89 e5             	mov    %rsp,%rbp
  801add:	48 83 ec 20          	sub    $0x20,%rsp
  801ae1:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801ae4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	return syscall(SYS_env_set_trapframe, 1, envid, (uint64_t) tf, 0, 0, 0);
  801ae8:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801aec:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801aef:	48 98                	cltq   
  801af1:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801af8:	00 
  801af9:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801aff:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801b05:	48 89 d1             	mov    %rdx,%rcx
  801b08:	48 89 c2             	mov    %rax,%rdx
  801b0b:	be 01 00 00 00       	mov    $0x1,%esi
  801b10:	bf 09 00 00 00       	mov    $0x9,%edi
  801b15:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801b1c:	00 00 00 
  801b1f:	ff d0                	callq  *%rax
}
  801b21:	c9                   	leaveq 
  801b22:	c3                   	retq   

0000000000801b23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801b23:	55                   	push   %rbp
  801b24:	48 89 e5             	mov    %rsp,%rbp
  801b27:	48 83 ec 20          	sub    $0x20,%rsp
  801b2b:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801b2e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t) upcall, 0, 0, 0);
  801b32:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801b36:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801b39:	48 98                	cltq   
  801b3b:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801b42:	00 
  801b43:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801b49:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801b4f:	48 89 d1             	mov    %rdx,%rcx
  801b52:	48 89 c2             	mov    %rax,%rdx
  801b55:	be 01 00 00 00       	mov    $0x1,%esi
  801b5a:	bf 0a 00 00 00       	mov    $0xa,%edi
  801b5f:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801b66:	00 00 00 
  801b69:	ff d0                	callq  *%rax
}
  801b6b:	c9                   	leaveq 
  801b6c:	c3                   	retq   

0000000000801b6d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm)
{
  801b6d:	55                   	push   %rbp
  801b6e:	48 89 e5             	mov    %rsp,%rbp
  801b71:	48 83 ec 20          	sub    $0x20,%rsp
  801b75:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801b78:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801b7c:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801b80:	89 4d f8             	mov    %ecx,-0x8(%rbp)
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t) srcva, perm, 0);
  801b83:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801b86:	48 63 f0             	movslq %eax,%rsi
  801b89:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  801b8d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801b90:	48 98                	cltq   
  801b92:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801b96:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801b9d:	00 
  801b9e:	49 89 f1             	mov    %rsi,%r9
  801ba1:	49 89 c8             	mov    %rcx,%r8
  801ba4:	48 89 d1             	mov    %rdx,%rcx
  801ba7:	48 89 c2             	mov    %rax,%rdx
  801baa:	be 00 00 00 00       	mov    $0x0,%esi
  801baf:	bf 0c 00 00 00       	mov    $0xc,%edi
  801bb4:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801bbb:	00 00 00 
  801bbe:	ff d0                	callq  *%rax
}
  801bc0:	c9                   	leaveq 
  801bc1:	c3                   	retq   

0000000000801bc2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801bc2:	55                   	push   %rbp
  801bc3:	48 89 e5             	mov    %rsp,%rbp
  801bc6:	48 83 ec 10          	sub    $0x10,%rsp
  801bca:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
  801bce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801bd2:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801bd9:	00 
  801bda:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801be0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801beb:	48 89 c2             	mov    %rax,%rdx
  801bee:	be 01 00 00 00       	mov    $0x1,%esi
  801bf3:	bf 0d 00 00 00       	mov    $0xd,%edi
  801bf8:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801bff:	00 00 00 
  801c02:	ff d0                	callq  *%rax
}
  801c04:	c9                   	leaveq 
  801c05:	c3                   	retq   

0000000000801c06 <sys_net_tx>:

int
sys_net_tx(void *buf, size_t len)
{
  801c06:	55                   	push   %rbp
  801c07:	48 89 e5             	mov    %rsp,%rbp
  801c0a:	48 83 ec 20          	sub    $0x20,%rsp
  801c0e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801c12:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	return syscall(SYS_net_tx, 1, (uint64_t)buf, len, 0, 0, 0);
  801c16:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801c1a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801c1e:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801c25:	00 
  801c26:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c2c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801c32:	48 89 d1             	mov    %rdx,%rcx
  801c35:	48 89 c2             	mov    %rax,%rdx
  801c38:	be 01 00 00 00       	mov    $0x1,%esi
  801c3d:	bf 0f 00 00 00       	mov    $0xf,%edi
  801c42:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801c49:	00 00 00 
  801c4c:	ff d0                	callq  *%rax
}
  801c4e:	c9                   	leaveq 
  801c4f:	c3                   	retq   

0000000000801c50 <sys_net_rx>:

int
sys_net_rx(void *buf)
{
  801c50:	55                   	push   %rbp
  801c51:	48 89 e5             	mov    %rsp,%rbp
  801c54:	48 83 ec 10          	sub    $0x10,%rsp
  801c58:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	return syscall(SYS_net_rx, 0, (uint64_t)buf, 0, 0, 0, 0);
  801c5c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801c60:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801c67:	00 
  801c68:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c6e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801c74:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c79:	48 89 c2             	mov    %rax,%rdx
  801c7c:	be 00 00 00 00       	mov    $0x0,%esi
  801c81:	bf 10 00 00 00       	mov    $0x10,%edi
  801c86:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801c8d:	00 00 00 
  801c90:	ff d0                	callq  *%rax
}
  801c92:	c9                   	leaveq 
  801c93:	c3                   	retq   

0000000000801c94 <sys_time_msec>:


unsigned int
sys_time_msec(void)
{
  801c94:	55                   	push   %rbp
  801c95:	48 89 e5             	mov    %rsp,%rbp
  801c98:	48 83 ec 10          	sub    $0x10,%rsp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  801c9c:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801ca3:	00 
  801ca4:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801caa:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801cb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cba:	be 00 00 00 00       	mov    $0x0,%esi
  801cbf:	bf 0e 00 00 00       	mov    $0xe,%edi
  801cc4:	48 b8 c3 17 80 00 00 	movabs $0x8017c3,%rax
  801ccb:	00 00 00 
  801cce:	ff d0                	callq  *%rax
}
  801cd0:	c9                   	leaveq 
  801cd1:	c3                   	retq   

0000000000801cd2 <pgfault>:
        return esp;
}

static void
pgfault(struct UTrapframe *utf)
{
  801cd2:	55                   	push   %rbp
  801cd3:	48 89 e5             	mov    %rsp,%rbp
  801cd6:	48 83 ec 30          	sub    $0x30,%rsp
  801cda:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
	void *addr = (void *) utf->utf_fault_va;
  801cde:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ce2:	48 8b 00             	mov    (%rax),%rax
  801ce5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	uint32_t err = utf->utf_err;
  801ce9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ced:	48 8b 40 08          	mov    0x8(%rax),%rax
  801cf1:	89 45 f4             	mov    %eax,-0xc(%rbp)
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("I am in user's page fault handler\n");
	if(!(err &FEC_WR)&&(uvpt[PPN(addr)]& PTE_COW))
  801cf4:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801cf7:	83 e0 02             	and    $0x2,%eax
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	75 4d                	jne    801d4b <pgfault+0x79>
  801cfe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801d02:	48 c1 e8 0c          	shr    $0xc,%rax
  801d06:	48 89 c2             	mov    %rax,%rdx
  801d09:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801d10:	01 00 00 
  801d13:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801d17:	25 00 08 00 00       	and    $0x800,%eax
  801d1c:	48 85 c0             	test   %rax,%rax
  801d1f:	74 2a                	je     801d4b <pgfault+0x79>
		panic("Page isnt writable/ COW, why did I get a pagefault \n");
  801d21:	48 ba 18 4d 80 00 00 	movabs $0x804d18,%rdx
  801d28:	00 00 00 
  801d2b:	be 23 00 00 00       	mov    $0x23,%esi
  801d30:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801d37:	00 00 00 
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3f:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801d46:	00 00 00 
  801d49:	ff d1                	callq  *%rcx
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	if(0 == sys_page_alloc(0,(void*)PFTEMP,PTE_U|PTE_P|PTE_W)){
  801d4b:	ba 07 00 00 00       	mov    $0x7,%edx
  801d50:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801d55:	bf 00 00 00 00       	mov    $0x0,%edi
  801d5a:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  801d61:	00 00 00 
  801d64:	ff d0                	callq  *%rax
  801d66:	85 c0                	test   %eax,%eax
  801d68:	0f 85 cd 00 00 00    	jne    801e3b <pgfault+0x169>
		Pageaddr = ROUNDDOWN(addr,PGSIZE);
  801d6e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801d72:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801d76:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801d7a:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  801d80:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
		memmove(PFTEMP, Pageaddr, PGSIZE);
  801d84:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801d88:	ba 00 10 00 00       	mov    $0x1000,%edx
  801d8d:	48 89 c6             	mov    %rax,%rsi
  801d90:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  801d95:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  801d9c:	00 00 00 
  801d9f:	ff d0                	callq  *%rax
		if(0> sys_page_map(0,PFTEMP,0,Pageaddr,PTE_U|PTE_P|PTE_W))
  801da1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801da5:	41 b8 07 00 00 00    	mov    $0x7,%r8d
  801dab:	48 89 c1             	mov    %rax,%rcx
  801dae:	ba 00 00 00 00       	mov    $0x0,%edx
  801db3:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801db8:	bf 00 00 00 00       	mov    $0x0,%edi
  801dbd:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  801dc4:	00 00 00 
  801dc7:	ff d0                	callq  *%rax
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	79 2a                	jns    801df7 <pgfault+0x125>
				panic("Page map at temp address failed");
  801dcd:	48 ba 58 4d 80 00 00 	movabs $0x804d58,%rdx
  801dd4:	00 00 00 
  801dd7:	be 30 00 00 00       	mov    $0x30,%esi
  801ddc:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801de3:	00 00 00 
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
  801deb:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801df2:	00 00 00 
  801df5:	ff d1                	callq  *%rcx
		if(0> sys_page_unmap(0,PFTEMP))
  801df7:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  801dfc:	bf 00 00 00 00       	mov    $0x0,%edi
  801e01:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  801e08:	00 00 00 
  801e0b:	ff d0                	callq  *%rax
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	79 54                	jns    801e65 <pgfault+0x193>
				panic("Page unmap from temp location failed");
  801e11:	48 ba 78 4d 80 00 00 	movabs $0x804d78,%rdx
  801e18:	00 00 00 
  801e1b:	be 32 00 00 00       	mov    $0x32,%esi
  801e20:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801e27:	00 00 00 
  801e2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2f:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801e36:	00 00 00 
  801e39:	ff d1                	callq  *%rcx
	}else{
		panic("Page Allocation Failed during handling page fault");
  801e3b:	48 ba a0 4d 80 00 00 	movabs $0x804da0,%rdx
  801e42:	00 00 00 
  801e45:	be 34 00 00 00       	mov    $0x34,%esi
  801e4a:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801e51:	00 00 00 
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
  801e59:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801e60:	00 00 00 
  801e63:	ff d1                	callq  *%rcx
	}
	//panic("pgfault not implemented");
}
  801e65:	c9                   	leaveq 
  801e66:	c3                   	retq   

0000000000801e67 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801e67:	55                   	push   %rbp
  801e68:	48 89 e5             	mov    %rsp,%rbp
  801e6b:	48 83 ec 20          	sub    $0x20,%rsp
  801e6f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  801e72:	89 75 e8             	mov    %esi,-0x18(%rbp)
	int r;
	int perm = (uvpt[pn]) & PTE_SYSCALL; // Doubtful..
  801e75:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801e7c:	01 00 00 
  801e7f:	8b 55 e8             	mov    -0x18(%rbp),%edx
  801e82:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  801e86:	25 07 0e 00 00       	and    $0xe07,%eax
  801e8b:	89 45 fc             	mov    %eax,-0x4(%rbp)
	void* addr = (void*)((uint64_t)pn *PGSIZE);
  801e8e:	8b 45 e8             	mov    -0x18(%rbp),%eax
  801e91:	48 c1 e0 0c          	shl    $0xc,%rax
  801e95:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	//cprintf("DuPpage: Incoming addr = [%x], permission = [%d]\n", addr,perm);
	// LAB 4: Your code  here.
	if(perm & PTE_SHARE){
  801e99:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801e9c:	25 00 04 00 00       	and    $0x400,%eax
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	74 57                	je     801efc <duppage+0x95>
		if(0 < sys_page_map(0,addr,envid,addr,perm))
  801ea5:	8b 75 fc             	mov    -0x4(%rbp),%esi
  801ea8:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  801eac:	8b 55 ec             	mov    -0x14(%rbp),%edx
  801eaf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801eb3:	41 89 f0             	mov    %esi,%r8d
  801eb6:	48 89 c6             	mov    %rax,%rsi
  801eb9:	bf 00 00 00 00       	mov    $0x0,%edi
  801ebe:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  801ec5:	00 00 00 
  801ec8:	ff d0                	callq  *%rax
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	0f 8e 52 01 00 00    	jle    802024 <duppage+0x1bd>
			panic("Page alloc with COW  failed.\n");
  801ed2:	48 ba d2 4d 80 00 00 	movabs $0x804dd2,%rdx
  801ed9:	00 00 00 
  801edc:	be 4e 00 00 00       	mov    $0x4e,%esi
  801ee1:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801ee8:	00 00 00 
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef0:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801ef7:	00 00 00 
  801efa:	ff d1                	callq  *%rcx

	}else{
	if((perm & PTE_W || perm & PTE_COW)){
  801efc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801eff:	83 e0 02             	and    $0x2,%eax
  801f02:	85 c0                	test   %eax,%eax
  801f04:	75 10                	jne    801f16 <duppage+0xaf>
  801f06:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801f09:	25 00 08 00 00       	and    $0x800,%eax
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	0f 84 bb 00 00 00    	je     801fd1 <duppage+0x16a>
		perm = (perm|PTE_COW)&(~PTE_W);
  801f16:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801f19:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801f1e:	80 cc 08             	or     $0x8,%ah
  801f21:	89 45 fc             	mov    %eax,-0x4(%rbp)

		if(0 < sys_page_map(0,addr,envid,addr,perm))
  801f24:	8b 75 fc             	mov    -0x4(%rbp),%esi
  801f27:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  801f2b:	8b 55 ec             	mov    -0x14(%rbp),%edx
  801f2e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801f32:	41 89 f0             	mov    %esi,%r8d
  801f35:	48 89 c6             	mov    %rax,%rsi
  801f38:	bf 00 00 00 00       	mov    $0x0,%edi
  801f3d:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  801f44:	00 00 00 
  801f47:	ff d0                	callq  *%rax
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	7e 2a                	jle    801f77 <duppage+0x110>
			panic("Page alloc with COW  failed.\n");
  801f4d:	48 ba d2 4d 80 00 00 	movabs $0x804dd2,%rdx
  801f54:	00 00 00 
  801f57:	be 55 00 00 00       	mov    $0x55,%esi
  801f5c:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801f63:	00 00 00 
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6b:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801f72:	00 00 00 
  801f75:	ff d1                	callq  *%rcx
		if(0 <  sys_page_map(0,addr,0,addr,perm))
  801f77:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  801f7a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801f7e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801f82:	41 89 c8             	mov    %ecx,%r8d
  801f85:	48 89 d1             	mov    %rdx,%rcx
  801f88:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8d:	48 89 c6             	mov    %rax,%rsi
  801f90:	bf 00 00 00 00       	mov    $0x0,%edi
  801f95:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  801f9c:	00 00 00 
  801f9f:	ff d0                	callq  *%rax
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	7e 2a                	jle    801fcf <duppage+0x168>
			panic("Page alloc with COW  failed.\n");
  801fa5:	48 ba d2 4d 80 00 00 	movabs $0x804dd2,%rdx
  801fac:	00 00 00 
  801faf:	be 57 00 00 00       	mov    $0x57,%esi
  801fb4:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  801fbb:	00 00 00 
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc3:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  801fca:	00 00 00 
  801fcd:	ff d1                	callq  *%rcx
	if((perm & PTE_W || perm & PTE_COW)){
		perm = (perm|PTE_COW)&(~PTE_W);

		if(0 < sys_page_map(0,addr,envid,addr,perm))
			panic("Page alloc with COW  failed.\n");
		if(0 <  sys_page_map(0,addr,0,addr,perm))
  801fcf:	eb 53                	jmp    802024 <duppage+0x1bd>
			panic("Page alloc with COW  failed.\n");
	}else{
	
		if(0 < sys_page_map(0,addr,envid,addr,perm))
  801fd1:	8b 75 fc             	mov    -0x4(%rbp),%esi
  801fd4:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  801fd8:	8b 55 ec             	mov    -0x14(%rbp),%edx
  801fdb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801fdf:	41 89 f0             	mov    %esi,%r8d
  801fe2:	48 89 c6             	mov    %rax,%rsi
  801fe5:	bf 00 00 00 00       	mov    $0x0,%edi
  801fea:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  801ff1:	00 00 00 
  801ff4:	ff d0                	callq  *%rax
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	7e 2a                	jle    802024 <duppage+0x1bd>
			panic("Page alloc with COW  failed.\n");
  801ffa:	48 ba d2 4d 80 00 00 	movabs $0x804dd2,%rdx
  802001:	00 00 00 
  802004:	be 5b 00 00 00       	mov    $0x5b,%esi
  802009:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  802010:	00 00 00 
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  80201f:	00 00 00 
  802022:	ff d1                	callq  *%rcx
		}
	}

	//panic("duppage not implemented");
	
	return 0;
  802024:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802029:	c9                   	leaveq 
  80202a:	c3                   	retq   

000000000080202b <pt_is_mapped>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
bool
pt_is_mapped(void *va)
{
  80202b:	55                   	push   %rbp
  80202c:	48 89 e5             	mov    %rsp,%rbp
  80202f:	48 83 ec 18          	sub    $0x18,%rsp
  802033:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	uint64_t addr = (uint64_t)va;
  802037:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80203b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return (uvpml4e[VPML4E(addr)] & PTE_P) && (uvpde[VPDPE(addr<<12)] & PTE_P) && (uvpd[VPD(addr<<12)] & PTE_P);
  80203f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802043:	48 c1 e8 27          	shr    $0x27,%rax
  802047:	48 89 c2             	mov    %rax,%rdx
  80204a:	48 b8 00 20 40 80 00 	movabs $0x10080402000,%rax
  802051:	01 00 00 
  802054:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802058:	83 e0 01             	and    $0x1,%eax
  80205b:	48 85 c0             	test   %rax,%rax
  80205e:	74 51                	je     8020b1 <pt_is_mapped+0x86>
  802060:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802064:	48 c1 e0 0c          	shl    $0xc,%rax
  802068:	48 c1 e8 1e          	shr    $0x1e,%rax
  80206c:	48 89 c2             	mov    %rax,%rdx
  80206f:	48 b8 00 00 40 80 00 	movabs $0x10080400000,%rax
  802076:	01 00 00 
  802079:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80207d:	83 e0 01             	and    $0x1,%eax
  802080:	48 85 c0             	test   %rax,%rax
  802083:	74 2c                	je     8020b1 <pt_is_mapped+0x86>
  802085:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802089:	48 c1 e0 0c          	shl    $0xc,%rax
  80208d:	48 c1 e8 15          	shr    $0x15,%rax
  802091:	48 89 c2             	mov    %rax,%rdx
  802094:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  80209b:	01 00 00 
  80209e:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8020a2:	83 e0 01             	and    $0x1,%eax
  8020a5:	48 85 c0             	test   %rax,%rax
  8020a8:	74 07                	je     8020b1 <pt_is_mapped+0x86>
  8020aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8020af:	eb 05                	jmp    8020b6 <pt_is_mapped+0x8b>
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b6:	83 e0 01             	and    $0x1,%eax
}
  8020b9:	c9                   	leaveq 
  8020ba:	c3                   	retq   

00000000008020bb <fork>:

envid_t
fork(void)
{
  8020bb:	55                   	push   %rbp
  8020bc:	48 89 e5             	mov    %rsp,%rbp
  8020bf:	48 83 ec 20          	sub    $0x20,%rsp
	// LAB 4: Your code here.
	envid_t envid;
	int r;
	uint64_t i;
	uint64_t addr, last;
	set_pgfault_handler(pgfault);
  8020c3:	48 bf d2 1c 80 00 00 	movabs $0x801cd2,%rdi
  8020ca:	00 00 00 
  8020cd:	48 b8 e2 45 80 00 00 	movabs $0x8045e2,%rax
  8020d4:	00 00 00 
  8020d7:	ff d0                	callq  *%rax
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8020d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8020de:	cd 30                	int    $0x30
  8020e0:	89 45 e4             	mov    %eax,-0x1c(%rbp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8020e3:	8b 45 e4             	mov    -0x1c(%rbp),%eax
	envid = sys_exofork();
  8020e6:	89 45 f4             	mov    %eax,-0xc(%rbp)
	if(envid < 0)
  8020e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8020ed:	79 30                	jns    80211f <fork+0x64>
		panic("\nsys_exofork error: %e\n", envid);
  8020ef:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	48 ba f0 4d 80 00 00 	movabs $0x804df0,%rdx
  8020fb:	00 00 00 
  8020fe:	be 86 00 00 00       	mov    $0x86,%esi
  802103:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  80210a:	00 00 00 
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
  802112:	49 b8 7c 02 80 00 00 	movabs $0x80027c,%r8
  802119:	00 00 00 
  80211c:	41 ff d0             	callq  *%r8
    else if(envid == 0)
  80211f:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  802123:	75 46                	jne    80216b <fork+0xb0>
	{
		thisenv = &envs[ENVX(sys_getenvid())];
  802125:	48 b8 1d 19 80 00 00 	movabs $0x80191d,%rax
  80212c:	00 00 00 
  80212f:	ff d0                	callq  *%rax
  802131:	25 ff 03 00 00       	and    $0x3ff,%eax
  802136:	48 63 d0             	movslq %eax,%rdx
  802139:	48 89 d0             	mov    %rdx,%rax
  80213c:	48 c1 e0 03          	shl    $0x3,%rax
  802140:	48 01 d0             	add    %rdx,%rax
  802143:	48 c1 e0 05          	shl    $0x5,%rax
  802147:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  80214e:	00 00 00 
  802151:	48 01 c2             	add    %rax,%rdx
  802154:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80215b:	00 00 00 
  80215e:	48 89 10             	mov    %rdx,(%rax)
		return 0;
  802161:	b8 00 00 00 00       	mov    $0x0,%eax
  802166:	e9 d1 01 00 00       	jmpq   80233c <fork+0x281>
	}
	uint64_t ad = 0;
  80216b:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  802172:	00 
	for (addr = (uint64_t)USTACKTOP-PGSIZE; addr >=(uint64_t)UTEXT; addr -= PGSIZE){  // Is this enough, am I leaving a bug for future here???	
  802173:	b8 00 d0 7f ef       	mov    $0xef7fd000,%eax
  802178:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80217c:	e9 df 00 00 00       	jmpq   802260 <fork+0x1a5>
	/*Do we really need to scan all the pages????*/
		if(uvpml4e[VPML4E(addr)]& PTE_P){
  802181:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802185:	48 c1 e8 27          	shr    $0x27,%rax
  802189:	48 89 c2             	mov    %rax,%rdx
  80218c:	48 b8 00 20 40 80 00 	movabs $0x10080402000,%rax
  802193:	01 00 00 
  802196:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80219a:	83 e0 01             	and    $0x1,%eax
  80219d:	48 85 c0             	test   %rax,%rax
  8021a0:	0f 84 9e 00 00 00    	je     802244 <fork+0x189>
			if( uvpde[VPDPE(addr)] & PTE_P){
  8021a6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8021aa:	48 c1 e8 1e          	shr    $0x1e,%rax
  8021ae:	48 89 c2             	mov    %rax,%rdx
  8021b1:	48 b8 00 00 40 80 00 	movabs $0x10080400000,%rax
  8021b8:	01 00 00 
  8021bb:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8021bf:	83 e0 01             	and    $0x1,%eax
  8021c2:	48 85 c0             	test   %rax,%rax
  8021c5:	74 73                	je     80223a <fork+0x17f>
				if( uvpd[VPD(addr)] & PTE_P){
  8021c7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8021cb:	48 c1 e8 15          	shr    $0x15,%rax
  8021cf:	48 89 c2             	mov    %rax,%rdx
  8021d2:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8021d9:	01 00 00 
  8021dc:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8021e0:	83 e0 01             	and    $0x1,%eax
  8021e3:	48 85 c0             	test   %rax,%rax
  8021e6:	74 48                	je     802230 <fork+0x175>
					if((ad =uvpt[VPN(addr)])& PTE_P){
  8021e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8021ec:	48 c1 e8 0c          	shr    $0xc,%rax
  8021f0:	48 89 c2             	mov    %rax,%rdx
  8021f3:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8021fa:	01 00 00 
  8021fd:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802201:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  802205:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802209:	83 e0 01             	and    $0x1,%eax
  80220c:	48 85 c0             	test   %rax,%rax
  80220f:	74 47                	je     802258 <fork+0x19d>
						//cprintf("hi\n");
						//cprintf("addr = [%x]\n",ad);
						duppage(envid, VPN(addr));	
  802211:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802215:	48 c1 e8 0c          	shr    $0xc,%rax
  802219:	89 c2                	mov    %eax,%edx
  80221b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80221e:	89 d6                	mov    %edx,%esi
  802220:	89 c7                	mov    %eax,%edi
  802222:	48 b8 67 1e 80 00 00 	movabs $0x801e67,%rax
  802229:	00 00 00 
  80222c:	ff d0                	callq  *%rax
  80222e:	eb 28                	jmp    802258 <fork+0x19d>
					}
				}else{
					addr -= NPDENTRIES*PGSIZE;
  802230:	48 81 6d f8 00 00 20 	subq   $0x200000,-0x8(%rbp)
  802237:	00 
  802238:	eb 1e                	jmp    802258 <fork+0x19d>
					//addr -= ((VPD(addr)+1)<<PDXSHIFT);
				}
			}else{
				addr -= NPDENTRIES*NPDENTRIES*PGSIZE;
  80223a:	48 81 6d f8 00 00 00 	subq   $0x40000000,-0x8(%rbp)
  802241:	40 
  802242:	eb 14                	jmp    802258 <fork+0x19d>
				//addr -= ((VPDPE(addr)+1)<<PDPESHIFT);
			}
	
		}else{
		/*uvpml4e.. move by */
			addr -= ((VPML4E(addr)+1)<<PML4SHIFT)
  802244:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802248:	48 c1 e8 27          	shr    $0x27,%rax
  80224c:	48 83 c0 01          	add    $0x1,%rax
  802250:	48 c1 e0 27          	shl    $0x27,%rax
  802254:	48 29 45 f8          	sub    %rax,-0x8(%rbp)
	{
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	uint64_t ad = 0;
	for (addr = (uint64_t)USTACKTOP-PGSIZE; addr >=(uint64_t)UTEXT; addr -= PGSIZE){  // Is this enough, am I leaving a bug for future here???	
  802258:	48 81 6d f8 00 10 00 	subq   $0x1000,-0x8(%rbp)
  80225f:	00 
  802260:	48 81 7d f8 ff ff 7f 	cmpq   $0x7fffff,-0x8(%rbp)
  802267:	00 
  802268:	0f 87 13 ff ff ff    	ja     802181 <fork+0xc6>
		}
	
	}


	sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W); 
  80226e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  802271:	ba 07 00 00 00       	mov    $0x7,%edx
  802276:	be 00 f0 7f ef       	mov    $0xef7ff000,%esi
  80227b:	89 c7                	mov    %eax,%edi
  80227d:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  802284:	00 00 00 
  802287:	ff d0                	callq  *%rax

	sys_page_alloc(envid, (void*)(USTACKTOP - PGSIZE),PTE_P|PTE_U|PTE_W); 
  802289:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80228c:	ba 07 00 00 00       	mov    $0x7,%edx
  802291:	be 00 d0 7f ef       	mov    $0xef7fd000,%esi
  802296:	89 c7                	mov    %eax,%edi
  802298:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  80229f:	00 00 00 
  8022a2:	ff d0                	callq  *%rax

	sys_page_map(envid, (void*)(USTACKTOP - PGSIZE), 0, PFTEMP,PTE_P|PTE_U|PTE_W);
  8022a4:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8022a7:	41 b8 07 00 00 00    	mov    $0x7,%r8d
  8022ad:	b9 00 f0 5f 00       	mov    $0x5ff000,%ecx
  8022b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b7:	be 00 d0 7f ef       	mov    $0xef7fd000,%esi
  8022bc:	89 c7                	mov    %eax,%edi
  8022be:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  8022c5:	00 00 00 
  8022c8:	ff d0                	callq  *%rax

	memmove(PFTEMP, (void*)(USTACKTOP-PGSIZE), PGSIZE);
  8022ca:	ba 00 10 00 00       	mov    $0x1000,%edx
  8022cf:	be 00 d0 7f ef       	mov    $0xef7fd000,%esi
  8022d4:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  8022d9:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  8022e0:	00 00 00 
  8022e3:	ff d0                	callq  *%rax

	sys_page_unmap(0, PFTEMP);
  8022e5:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8022ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ef:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  8022f6:	00 00 00 
  8022f9:	ff d0                	callq  *%rax

    sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall); 
  8022fb:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802302:	00 00 00 
  802305:	48 8b 00             	mov    (%rax),%rax
  802308:	48 8b 90 f0 00 00 00 	mov    0xf0(%rax),%rdx
  80230f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  802312:	48 89 d6             	mov    %rdx,%rsi
  802315:	89 c7                	mov    %eax,%edi
  802317:	48 b8 23 1b 80 00 00 	movabs $0x801b23,%rax
  80231e:	00 00 00 
  802321:	ff d0                	callq  *%rax
	
	sys_env_set_status(envid, ENV_RUNNABLE);
  802323:	8b 45 f4             	mov    -0xc(%rbp),%eax
  802326:	be 02 00 00 00       	mov    $0x2,%esi
  80232b:	89 c7                	mov    %eax,%edi
  80232d:	48 b8 8e 1a 80 00 00 	movabs $0x801a8e,%rax
  802334:	00 00 00 
  802337:	ff d0                	callq  *%rax

	return envid;
  802339:	8b 45 f4             	mov    -0xc(%rbp),%eax
}
  80233c:	c9                   	leaveq 
  80233d:	c3                   	retq   

000000000080233e <sfork>:

	
// Challenge!
int
sfork(void)
{
  80233e:	55                   	push   %rbp
  80233f:	48 89 e5             	mov    %rsp,%rbp
	panic("sfork not implemented");
  802342:	48 ba 08 4e 80 00 00 	movabs $0x804e08,%rdx
  802349:	00 00 00 
  80234c:	be bf 00 00 00       	mov    $0xbf,%esi
  802351:	48 bf 4d 4d 80 00 00 	movabs $0x804d4d,%rdi
  802358:	00 00 00 
  80235b:	b8 00 00 00 00       	mov    $0x0,%eax
  802360:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  802367:	00 00 00 
  80236a:	ff d1                	callq  *%rcx

000000000080236c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80236c:	55                   	push   %rbp
  80236d:	48 89 e5             	mov    %rsp,%rbp
  802370:	48 83 ec 30          	sub    $0x30,%rsp
  802374:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802378:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80237c:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	// LAB 4: Your code here.
	int result;
	if(thisenv->env_status== 0){
  802380:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802387:	00 00 00 
  80238a:	48 8b 00             	mov    (%rax),%rax
  80238d:	8b 80 d4 00 00 00    	mov    0xd4(%rax),%eax
  802393:	85 c0                	test   %eax,%eax
  802395:	75 3c                	jne    8023d3 <ipc_recv+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  802397:	48 b8 1d 19 80 00 00 	movabs $0x80191d,%rax
  80239e:	00 00 00 
  8023a1:	ff d0                	callq  *%rax
  8023a3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8023a8:	48 63 d0             	movslq %eax,%rdx
  8023ab:	48 89 d0             	mov    %rdx,%rax
  8023ae:	48 c1 e0 03          	shl    $0x3,%rax
  8023b2:	48 01 d0             	add    %rdx,%rax
  8023b5:	48 c1 e0 05          	shl    $0x5,%rax
  8023b9:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  8023c0:	00 00 00 
  8023c3:	48 01 c2             	add    %rax,%rdx
  8023c6:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8023cd:	00 00 00 
  8023d0:	48 89 10             	mov    %rdx,(%rax)
	}
	if(!pg)
  8023d3:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8023d8:	75 0e                	jne    8023e8 <ipc_recv+0x7c>
		pg = (void*) UTOP;
  8023da:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  8023e1:	00 00 00 
  8023e4:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

	result = sys_ipc_recv(pg);
  8023e8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8023ec:	48 89 c7             	mov    %rax,%rdi
  8023ef:	48 b8 c2 1b 80 00 00 	movabs $0x801bc2,%rax
  8023f6:	00 00 00 
  8023f9:	ff d0                	callq  *%rax
  8023fb:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if(result< 0){
  8023fe:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802402:	79 19                	jns    80241d <ipc_recv+0xb1>
		*from_env_store = 0;
  802404:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802408:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
		*perm_store =0;
  80240e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802412:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
		return result;
  802418:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80241b:	eb 53                	jmp    802470 <ipc_recv+0x104>
	}
	if(from_env_store)
  80241d:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  802422:	74 19                	je     80243d <ipc_recv+0xd1>
		*from_env_store = thisenv->env_ipc_from;
  802424:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80242b:	00 00 00 
  80242e:	48 8b 00             	mov    (%rax),%rax
  802431:	8b 90 0c 01 00 00    	mov    0x10c(%rax),%edx
  802437:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80243b:	89 10                	mov    %edx,(%rax)
	if(perm_store)
  80243d:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  802442:	74 19                	je     80245d <ipc_recv+0xf1>
		*perm_store = thisenv->env_ipc_perm;
  802444:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80244b:	00 00 00 
  80244e:	48 8b 00             	mov    (%rax),%rax
  802451:	8b 90 10 01 00 00    	mov    0x110(%rax),%edx
  802457:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80245b:	89 10                	mov    %edx,(%rax)
	
	//cprintf("I am IPC Recv, sending value[%d] my env id is [%d]and status is [%d] and I am sending to [%d]",thisenv->env_ipc_value,thisenv->env_id,thisenv->env_status,thisenv->env_ipc_from);	
	return thisenv->env_ipc_value;
  80245d:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802464:	00 00 00 
  802467:	48 8b 00             	mov    (%rax),%rax
  80246a:	8b 80 08 01 00 00    	mov    0x108(%rax),%eax

	//panic("ipc_recv not implemented");
}
  802470:	c9                   	leaveq 
  802471:	c3                   	retq   

0000000000802472 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802472:	55                   	push   %rbp
  802473:	48 89 e5             	mov    %rsp,%rbp
  802476:	48 83 ec 30          	sub    $0x30,%rsp
  80247a:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80247d:	89 75 e8             	mov    %esi,-0x18(%rbp)
  802480:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  802484:	89 4d dc             	mov    %ecx,-0x24(%rbp)
	// LAB 4: Your code here.
	int result;
	if(!pg)
  802487:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  80248c:	75 0e                	jne    80249c <ipc_send+0x2a>
		pg = (void*)UTOP;
  80248e:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  802495:	00 00 00 
  802498:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	do{
	 	result = sys_ipc_try_send(to_env,val,pg,perm);
  80249c:	8b 75 e8             	mov    -0x18(%rbp),%esi
  80249f:	8b 4d dc             	mov    -0x24(%rbp),%ecx
  8024a2:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8024a6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8024a9:	89 c7                	mov    %eax,%edi
  8024ab:	48 b8 6d 1b 80 00 00 	movabs $0x801b6d,%rax
  8024b2:	00 00 00 
  8024b5:	ff d0                	callq  *%rax
  8024b7:	89 45 fc             	mov    %eax,-0x4(%rbp)
		if(-E_IPC_NOT_RECV == result)
  8024ba:	83 7d fc f8          	cmpl   $0xfffffff8,-0x4(%rbp)
  8024be:	75 0c                	jne    8024cc <ipc_send+0x5a>
			sys_yield();
  8024c0:	48 b8 5b 19 80 00 00 	movabs $0x80195b,%rax
  8024c7:	00 00 00 
  8024ca:	ff d0                	callq  *%rax
	}while(-E_IPC_NOT_RECV == result);
  8024cc:	83 7d fc f8          	cmpl   $0xfffffff8,-0x4(%rbp)
  8024d0:	74 ca                	je     80249c <ipc_send+0x2a>
	
	//panic("ipc_send not implemented");
}
  8024d2:	c9                   	leaveq 
  8024d3:	c3                   	retq   

00000000008024d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024d4:	55                   	push   %rbp
  8024d5:	48 89 e5             	mov    %rsp,%rbp
  8024d8:	48 83 ec 14          	sub    $0x14,%rsp
  8024dc:	89 7d ec             	mov    %edi,-0x14(%rbp)
	int i;
	for (i = 0; i < NENV; i++) {
  8024df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8024e6:	eb 5e                	jmp    802546 <ipc_find_env+0x72>
		if (envs[i].env_type == type)
  8024e8:	48 b9 00 00 80 00 80 	movabs $0x8000800000,%rcx
  8024ef:	00 00 00 
  8024f2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8024f5:	48 63 d0             	movslq %eax,%rdx
  8024f8:	48 89 d0             	mov    %rdx,%rax
  8024fb:	48 c1 e0 03          	shl    $0x3,%rax
  8024ff:	48 01 d0             	add    %rdx,%rax
  802502:	48 c1 e0 05          	shl    $0x5,%rax
  802506:	48 01 c8             	add    %rcx,%rax
  802509:	48 05 d0 00 00 00    	add    $0xd0,%rax
  80250f:	8b 00                	mov    (%rax),%eax
  802511:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  802514:	75 2c                	jne    802542 <ipc_find_env+0x6e>
			return envs[i].env_id;
  802516:	48 b9 00 00 80 00 80 	movabs $0x8000800000,%rcx
  80251d:	00 00 00 
  802520:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802523:	48 63 d0             	movslq %eax,%rdx
  802526:	48 89 d0             	mov    %rdx,%rax
  802529:	48 c1 e0 03          	shl    $0x3,%rax
  80252d:	48 01 d0             	add    %rdx,%rax
  802530:	48 c1 e0 05          	shl    $0x5,%rax
  802534:	48 01 c8             	add    %rcx,%rax
  802537:	48 05 c0 00 00 00    	add    $0xc0,%rax
  80253d:	8b 40 08             	mov    0x8(%rax),%eax
  802540:	eb 12                	jmp    802554 <ipc_find_env+0x80>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++) {
  802542:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  802546:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%rbp)
  80254d:	7e 99                	jle    8024e8 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	}
	return 0;
  80254f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802554:	c9                   	leaveq 
  802555:	c3                   	retq   

0000000000802556 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

uint64_t
fd2num(struct Fd *fd)
{
  802556:	55                   	push   %rbp
  802557:	48 89 e5             	mov    %rsp,%rbp
  80255a:	48 83 ec 08          	sub    $0x8,%rsp
  80255e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802562:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  802566:	48 b8 00 00 00 30 ff 	movabs $0xffffffff30000000,%rax
  80256d:	ff ff ff 
  802570:	48 01 d0             	add    %rdx,%rax
  802573:	48 c1 e8 0c          	shr    $0xc,%rax
}
  802577:	c9                   	leaveq 
  802578:	c3                   	retq   

0000000000802579 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802579:	55                   	push   %rbp
  80257a:	48 89 e5             	mov    %rsp,%rbp
  80257d:	48 83 ec 08          	sub    $0x8,%rsp
  802581:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	return INDEX2DATA(fd2num(fd));
  802585:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802589:	48 89 c7             	mov    %rax,%rdi
  80258c:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  802593:	00 00 00 
  802596:	ff d0                	callq  *%rax
  802598:	48 05 20 00 0d 00    	add    $0xd0020,%rax
  80259e:	48 c1 e0 0c          	shl    $0xc,%rax
}
  8025a2:	c9                   	leaveq 
  8025a3:	c3                   	retq   

00000000008025a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8025a4:	55                   	push   %rbp
  8025a5:	48 89 e5             	mov    %rsp,%rbp
  8025a8:	48 83 ec 18          	sub    $0x18,%rsp
  8025ac:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8025b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8025b7:	eb 6b                	jmp    802624 <fd_alloc+0x80>
		fd = INDEX2FD(i);
  8025b9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8025bc:	48 98                	cltq   
  8025be:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  8025c4:	48 c1 e0 0c          	shl    $0xc,%rax
  8025c8:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
		if ((uvpd[VPD(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8025cc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8025d0:	48 c1 e8 15          	shr    $0x15,%rax
  8025d4:	48 89 c2             	mov    %rax,%rdx
  8025d7:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8025de:	01 00 00 
  8025e1:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8025e5:	83 e0 01             	and    $0x1,%eax
  8025e8:	48 85 c0             	test   %rax,%rax
  8025eb:	74 21                	je     80260e <fd_alloc+0x6a>
  8025ed:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8025f1:	48 c1 e8 0c          	shr    $0xc,%rax
  8025f5:	48 89 c2             	mov    %rax,%rdx
  8025f8:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8025ff:	01 00 00 
  802602:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802606:	83 e0 01             	and    $0x1,%eax
  802609:	48 85 c0             	test   %rax,%rax
  80260c:	75 12                	jne    802620 <fd_alloc+0x7c>
			*fd_store = fd;
  80260e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802612:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802616:	48 89 10             	mov    %rdx,(%rax)
			return 0;
  802619:	b8 00 00 00 00       	mov    $0x0,%eax
  80261e:	eb 1a                	jmp    80263a <fd_alloc+0x96>
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802620:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  802624:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  802628:	7e 8f                	jle    8025b9 <fd_alloc+0x15>
		if ((uvpd[VPD(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80262a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80262e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
	return -E_MAX_OPEN;
  802635:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  80263a:	c9                   	leaveq 
  80263b:	c3                   	retq   

000000000080263c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80263c:	55                   	push   %rbp
  80263d:	48 89 e5             	mov    %rsp,%rbp
  802640:	48 83 ec 20          	sub    $0x20,%rsp
  802644:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802647:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80264b:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80264f:	78 06                	js     802657 <fd_lookup+0x1b>
  802651:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%rbp)
  802655:	7e 07                	jle    80265e <fd_lookup+0x22>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802657:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80265c:	eb 6c                	jmp    8026ca <fd_lookup+0x8e>
	}
	fd = INDEX2FD(fdnum);
  80265e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802661:	48 98                	cltq   
  802663:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  802669:	48 c1 e0 0c          	shl    $0xc,%rax
  80266d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (!(uvpd[VPD(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802671:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802675:	48 c1 e8 15          	shr    $0x15,%rax
  802679:	48 89 c2             	mov    %rax,%rdx
  80267c:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802683:	01 00 00 
  802686:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80268a:	83 e0 01             	and    $0x1,%eax
  80268d:	48 85 c0             	test   %rax,%rax
  802690:	74 21                	je     8026b3 <fd_lookup+0x77>
  802692:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802696:	48 c1 e8 0c          	shr    $0xc,%rax
  80269a:	48 89 c2             	mov    %rax,%rdx
  80269d:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8026a4:	01 00 00 
  8026a7:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8026ab:	83 e0 01             	and    $0x1,%eax
  8026ae:	48 85 c0             	test   %rax,%rax
  8026b1:	75 07                	jne    8026ba <fd_lookup+0x7e>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8026b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8026b8:	eb 10                	jmp    8026ca <fd_lookup+0x8e>
	}
	*fd_store = fd;
  8026ba:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8026be:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8026c2:	48 89 10             	mov    %rdx,(%rax)
	return 0;
  8026c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026ca:	c9                   	leaveq 
  8026cb:	c3                   	retq   

00000000008026cc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8026cc:	55                   	push   %rbp
  8026cd:	48 89 e5             	mov    %rsp,%rbp
  8026d0:	48 83 ec 30          	sub    $0x30,%rsp
  8026d4:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8026d8:	89 f0                	mov    %esi,%eax
  8026da:	88 45 d4             	mov    %al,-0x2c(%rbp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8026dd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8026e1:	48 89 c7             	mov    %rax,%rdi
  8026e4:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  8026eb:	00 00 00 
  8026ee:	ff d0                	callq  *%rax
  8026f0:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8026f4:	48 89 d6             	mov    %rdx,%rsi
  8026f7:	89 c7                	mov    %eax,%edi
  8026f9:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  802700:	00 00 00 
  802703:	ff d0                	callq  *%rax
  802705:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802708:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80270c:	78 0a                	js     802718 <fd_close+0x4c>
	    || fd != fd2)
  80270e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802712:	48 39 45 d8          	cmp    %rax,-0x28(%rbp)
  802716:	74 12                	je     80272a <fd_close+0x5e>
		return (must_exist ? r : 0);
  802718:	80 7d d4 00          	cmpb   $0x0,-0x2c(%rbp)
  80271c:	74 05                	je     802723 <fd_close+0x57>
  80271e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802721:	eb 05                	jmp    802728 <fd_close+0x5c>
  802723:	b8 00 00 00 00       	mov    $0x0,%eax
  802728:	eb 69                	jmp    802793 <fd_close+0xc7>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80272a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80272e:	8b 00                	mov    (%rax),%eax
  802730:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802734:	48 89 d6             	mov    %rdx,%rsi
  802737:	89 c7                	mov    %eax,%edi
  802739:	48 b8 95 27 80 00 00 	movabs $0x802795,%rax
  802740:	00 00 00 
  802743:	ff d0                	callq  *%rax
  802745:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802748:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80274c:	78 2a                	js     802778 <fd_close+0xac>
		if (dev->dev_close)
  80274e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802752:	48 8b 40 20          	mov    0x20(%rax),%rax
  802756:	48 85 c0             	test   %rax,%rax
  802759:	74 16                	je     802771 <fd_close+0xa5>
			r = (*dev->dev_close)(fd);
  80275b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80275f:	48 8b 40 20          	mov    0x20(%rax),%rax
  802763:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  802767:	48 89 d7             	mov    %rdx,%rdi
  80276a:	ff d0                	callq  *%rax
  80276c:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80276f:	eb 07                	jmp    802778 <fd_close+0xac>
		else
			r = 0;
  802771:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802778:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80277c:	48 89 c6             	mov    %rax,%rsi
  80277f:	bf 00 00 00 00       	mov    $0x0,%edi
  802784:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  80278b:	00 00 00 
  80278e:	ff d0                	callq  *%rax
	return r;
  802790:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  802793:	c9                   	leaveq 
  802794:	c3                   	retq   

0000000000802795 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802795:	55                   	push   %rbp
  802796:	48 89 e5             	mov    %rsp,%rbp
  802799:	48 83 ec 20          	sub    $0x20,%rsp
  80279d:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8027a0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int i;
	for (i = 0; devtab[i]; i++)
  8027a4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8027ab:	eb 41                	jmp    8027ee <dev_lookup+0x59>
		if (devtab[i]->dev_id == dev_id) {
  8027ad:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8027b4:	00 00 00 
  8027b7:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8027ba:	48 63 d2             	movslq %edx,%rdx
  8027bd:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8027c1:	8b 00                	mov    (%rax),%eax
  8027c3:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  8027c6:	75 22                	jne    8027ea <dev_lookup+0x55>
			*dev = devtab[i];
  8027c8:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8027cf:	00 00 00 
  8027d2:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8027d5:	48 63 d2             	movslq %edx,%rdx
  8027d8:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
  8027dc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8027e0:	48 89 10             	mov    %rdx,(%rax)
			return 0;
  8027e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8027e8:	eb 60                	jmp    80284a <dev_lookup+0xb5>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8027ea:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8027ee:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8027f5:	00 00 00 
  8027f8:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8027fb:	48 63 d2             	movslq %edx,%rdx
  8027fe:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802802:	48 85 c0             	test   %rax,%rax
  802805:	75 a6                	jne    8027ad <dev_lookup+0x18>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802807:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80280e:	00 00 00 
  802811:	48 8b 00             	mov    (%rax),%rax
  802814:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  80281a:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80281d:	89 c6                	mov    %eax,%esi
  80281f:	48 bf 20 4e 80 00 00 	movabs $0x804e20,%rdi
  802826:	00 00 00 
  802829:	b8 00 00 00 00       	mov    $0x0,%eax
  80282e:	48 b9 b5 04 80 00 00 	movabs $0x8004b5,%rcx
  802835:	00 00 00 
  802838:	ff d1                	callq  *%rcx
	*dev = 0;
  80283a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80283e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
	return -E_INVAL;
  802845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80284a:	c9                   	leaveq 
  80284b:	c3                   	retq   

000000000080284c <close>:

int
close(int fdnum)
{
  80284c:	55                   	push   %rbp
  80284d:	48 89 e5             	mov    %rsp,%rbp
  802850:	48 83 ec 20          	sub    $0x20,%rsp
  802854:	89 7d ec             	mov    %edi,-0x14(%rbp)
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802857:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  80285b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80285e:	48 89 d6             	mov    %rdx,%rsi
  802861:	89 c7                	mov    %eax,%edi
  802863:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  80286a:	00 00 00 
  80286d:	ff d0                	callq  *%rax
  80286f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802872:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802876:	79 05                	jns    80287d <close+0x31>
		return r;
  802878:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80287b:	eb 18                	jmp    802895 <close+0x49>
	else
		return fd_close(fd, 1);
  80287d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802881:	be 01 00 00 00       	mov    $0x1,%esi
  802886:	48 89 c7             	mov    %rax,%rdi
  802889:	48 b8 cc 26 80 00 00 	movabs $0x8026cc,%rax
  802890:	00 00 00 
  802893:	ff d0                	callq  *%rax
}
  802895:	c9                   	leaveq 
  802896:	c3                   	retq   

0000000000802897 <close_all>:

void
close_all(void)
{
  802897:	55                   	push   %rbp
  802898:	48 89 e5             	mov    %rsp,%rbp
  80289b:	48 83 ec 10          	sub    $0x10,%rsp
	int i;
	for (i = 0; i < MAXFD; i++)
  80289f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8028a6:	eb 15                	jmp    8028bd <close_all+0x26>
		close(i);
  8028a8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8028ab:	89 c7                	mov    %eax,%edi
  8028ad:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  8028b4:	00 00 00 
  8028b7:	ff d0                	callq  *%rax

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8028b9:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8028bd:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  8028c1:	7e e5                	jle    8028a8 <close_all+0x11>
		close(i);
}
  8028c3:	c9                   	leaveq 
  8028c4:	c3                   	retq   

00000000008028c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8028c5:	55                   	push   %rbp
  8028c6:	48 89 e5             	mov    %rsp,%rbp
  8028c9:	48 83 ec 40          	sub    $0x40,%rsp
  8028cd:	89 7d cc             	mov    %edi,-0x34(%rbp)
  8028d0:	89 75 c8             	mov    %esi,-0x38(%rbp)
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8028d3:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  8028d7:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8028da:	48 89 d6             	mov    %rdx,%rsi
  8028dd:	89 c7                	mov    %eax,%edi
  8028df:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  8028e6:	00 00 00 
  8028e9:	ff d0                	callq  *%rax
  8028eb:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8028ee:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8028f2:	79 08                	jns    8028fc <dup+0x37>
		return r;
  8028f4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8028f7:	e9 70 01 00 00       	jmpq   802a6c <dup+0x1a7>
	close(newfdnum);
  8028fc:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8028ff:	89 c7                	mov    %eax,%edi
  802901:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  802908:	00 00 00 
  80290b:	ff d0                	callq  *%rax

	newfd = INDEX2FD(newfdnum);
  80290d:	8b 45 c8             	mov    -0x38(%rbp),%eax
  802910:	48 98                	cltq   
  802912:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  802918:	48 c1 e0 0c          	shl    $0xc,%rax
  80291c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	ova = fd2data(oldfd);
  802920:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802924:	48 89 c7             	mov    %rax,%rdi
  802927:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  80292e:	00 00 00 
  802931:	ff d0                	callq  *%rax
  802933:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	nva = fd2data(newfd);
  802937:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80293b:	48 89 c7             	mov    %rax,%rdi
  80293e:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  802945:	00 00 00 
  802948:	ff d0                	callq  *%rax
  80294a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

	if ((uvpd[VPD(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80294e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802952:	48 c1 e8 15          	shr    $0x15,%rax
  802956:	48 89 c2             	mov    %rax,%rdx
  802959:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802960:	01 00 00 
  802963:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802967:	83 e0 01             	and    $0x1,%eax
  80296a:	48 85 c0             	test   %rax,%rax
  80296d:	74 73                	je     8029e2 <dup+0x11d>
  80296f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802973:	48 c1 e8 0c          	shr    $0xc,%rax
  802977:	48 89 c2             	mov    %rax,%rdx
  80297a:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  802981:	01 00 00 
  802984:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802988:	83 e0 01             	and    $0x1,%eax
  80298b:	48 85 c0             	test   %rax,%rax
  80298e:	74 52                	je     8029e2 <dup+0x11d>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802990:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802994:	48 c1 e8 0c          	shr    $0xc,%rax
  802998:	48 89 c2             	mov    %rax,%rdx
  80299b:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8029a2:	01 00 00 
  8029a5:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8029a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8029ae:	89 c1                	mov    %eax,%ecx
  8029b0:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8029b4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8029b8:	41 89 c8             	mov    %ecx,%r8d
  8029bb:	48 89 d1             	mov    %rdx,%rcx
  8029be:	ba 00 00 00 00       	mov    $0x0,%edx
  8029c3:	48 89 c6             	mov    %rax,%rsi
  8029c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8029cb:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  8029d2:	00 00 00 
  8029d5:	ff d0                	callq  *%rax
  8029d7:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8029da:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8029de:	79 02                	jns    8029e2 <dup+0x11d>
			goto err;
  8029e0:	eb 57                	jmp    802a39 <dup+0x174>
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8029e2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8029e6:	48 c1 e8 0c          	shr    $0xc,%rax
  8029ea:	48 89 c2             	mov    %rax,%rdx
  8029ed:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8029f4:	01 00 00 
  8029f7:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8029fb:	25 07 0e 00 00       	and    $0xe07,%eax
  802a00:	89 c1                	mov    %eax,%ecx
  802a02:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802a06:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802a0a:	41 89 c8             	mov    %ecx,%r8d
  802a0d:	48 89 d1             	mov    %rdx,%rcx
  802a10:	ba 00 00 00 00       	mov    $0x0,%edx
  802a15:	48 89 c6             	mov    %rax,%rsi
  802a18:	bf 00 00 00 00       	mov    $0x0,%edi
  802a1d:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  802a24:	00 00 00 
  802a27:	ff d0                	callq  *%rax
  802a29:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a2c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802a30:	79 02                	jns    802a34 <dup+0x16f>
		goto err;
  802a32:	eb 05                	jmp    802a39 <dup+0x174>

	return newfdnum;
  802a34:	8b 45 c8             	mov    -0x38(%rbp),%eax
  802a37:	eb 33                	jmp    802a6c <dup+0x1a7>

err:
	sys_page_unmap(0, newfd);
  802a39:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a3d:	48 89 c6             	mov    %rax,%rsi
  802a40:	bf 00 00 00 00       	mov    $0x0,%edi
  802a45:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  802a4c:	00 00 00 
  802a4f:	ff d0                	callq  *%rax
	sys_page_unmap(0, nva);
  802a51:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802a55:	48 89 c6             	mov    %rax,%rsi
  802a58:	bf 00 00 00 00       	mov    $0x0,%edi
  802a5d:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  802a64:	00 00 00 
  802a67:	ff d0                	callq  *%rax
	return r;
  802a69:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  802a6c:	c9                   	leaveq 
  802a6d:	c3                   	retq   

0000000000802a6e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a6e:	55                   	push   %rbp
  802a6f:	48 89 e5             	mov    %rsp,%rbp
  802a72:	48 83 ec 40          	sub    $0x40,%rsp
  802a76:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802a79:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802a7d:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
	int r;
	struct Dev *dev;
	struct Fd *fd;
	//cprintf("Inside Read");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a81:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802a85:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802a88:	48 89 d6             	mov    %rdx,%rsi
  802a8b:	89 c7                	mov    %eax,%edi
  802a8d:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  802a94:	00 00 00 
  802a97:	ff d0                	callq  *%rax
  802a99:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a9c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802aa0:	78 24                	js     802ac6 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802aa2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802aa6:	8b 00                	mov    (%rax),%eax
  802aa8:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802aac:	48 89 d6             	mov    %rdx,%rsi
  802aaf:	89 c7                	mov    %eax,%edi
  802ab1:	48 b8 95 27 80 00 00 	movabs $0x802795,%rax
  802ab8:	00 00 00 
  802abb:	ff d0                	callq  *%rax
  802abd:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802ac0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802ac4:	79 05                	jns    802acb <read+0x5d>
		return r;
  802ac6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ac9:	eb 76                	jmp    802b41 <read+0xd3>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802acb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802acf:	8b 40 08             	mov    0x8(%rax),%eax
  802ad2:	83 e0 03             	and    $0x3,%eax
  802ad5:	83 f8 01             	cmp    $0x1,%eax
  802ad8:	75 3a                	jne    802b14 <read+0xa6>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ada:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802ae1:	00 00 00 
  802ae4:	48 8b 00             	mov    (%rax),%rax
  802ae7:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802aed:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802af0:	89 c6                	mov    %eax,%esi
  802af2:	48 bf 3f 4e 80 00 00 	movabs $0x804e3f,%rdi
  802af9:	00 00 00 
  802afc:	b8 00 00 00 00       	mov    $0x0,%eax
  802b01:	48 b9 b5 04 80 00 00 	movabs $0x8004b5,%rcx
  802b08:	00 00 00 
  802b0b:	ff d1                	callq  *%rcx
		return -E_INVAL;
  802b0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b12:	eb 2d                	jmp    802b41 <read+0xd3>
	}
	if (!dev->dev_read)
  802b14:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802b18:	48 8b 40 10          	mov    0x10(%rax),%rax
  802b1c:	48 85 c0             	test   %rax,%rax
  802b1f:	75 07                	jne    802b28 <read+0xba>
		return -E_NOT_SUPP;
  802b21:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802b26:	eb 19                	jmp    802b41 <read+0xd3>
	return (*dev->dev_read)(fd, buf, n);
  802b28:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802b2c:	48 8b 40 10          	mov    0x10(%rax),%rax
  802b30:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  802b34:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802b38:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  802b3c:	48 89 cf             	mov    %rcx,%rdi
  802b3f:	ff d0                	callq  *%rax
}
  802b41:	c9                   	leaveq 
  802b42:	c3                   	retq   

0000000000802b43 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b43:	55                   	push   %rbp
  802b44:	48 89 e5             	mov    %rsp,%rbp
  802b47:	48 83 ec 30          	sub    $0x30,%rsp
  802b4b:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802b4e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802b52:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b56:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  802b5d:	eb 49                	jmp    802ba8 <readn+0x65>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b5f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802b62:	48 98                	cltq   
  802b64:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  802b68:	48 29 c2             	sub    %rax,%rdx
  802b6b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802b6e:	48 63 c8             	movslq %eax,%rcx
  802b71:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802b75:	48 01 c1             	add    %rax,%rcx
  802b78:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802b7b:	48 89 ce             	mov    %rcx,%rsi
  802b7e:	89 c7                	mov    %eax,%edi
  802b80:	48 b8 6e 2a 80 00 00 	movabs $0x802a6e,%rax
  802b87:	00 00 00 
  802b8a:	ff d0                	callq  *%rax
  802b8c:	89 45 f8             	mov    %eax,-0x8(%rbp)
		if (m < 0)
  802b8f:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  802b93:	79 05                	jns    802b9a <readn+0x57>
			return m;
  802b95:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802b98:	eb 1c                	jmp    802bb6 <readn+0x73>
		if (m == 0)
  802b9a:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  802b9e:	75 02                	jne    802ba2 <readn+0x5f>
			break;
  802ba0:	eb 11                	jmp    802bb3 <readn+0x70>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802ba2:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802ba5:	01 45 fc             	add    %eax,-0x4(%rbp)
  802ba8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802bab:	48 98                	cltq   
  802bad:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  802bb1:	72 ac                	jb     802b5f <readn+0x1c>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  802bb3:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  802bb6:	c9                   	leaveq 
  802bb7:	c3                   	retq   

0000000000802bb8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802bb8:	55                   	push   %rbp
  802bb9:	48 89 e5             	mov    %rsp,%rbp
  802bbc:	48 83 ec 40          	sub    $0x40,%rsp
  802bc0:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802bc3:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802bc7:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bcb:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802bcf:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802bd2:	48 89 d6             	mov    %rdx,%rsi
  802bd5:	89 c7                	mov    %eax,%edi
  802bd7:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  802bde:	00 00 00 
  802be1:	ff d0                	callq  *%rax
  802be3:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802be6:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802bea:	78 24                	js     802c10 <write+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bec:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802bf0:	8b 00                	mov    (%rax),%eax
  802bf2:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802bf6:	48 89 d6             	mov    %rdx,%rsi
  802bf9:	89 c7                	mov    %eax,%edi
  802bfb:	48 b8 95 27 80 00 00 	movabs $0x802795,%rax
  802c02:	00 00 00 
  802c05:	ff d0                	callq  *%rax
  802c07:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802c0a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802c0e:	79 05                	jns    802c15 <write+0x5d>
		return r;
  802c10:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802c13:	eb 75                	jmp    802c8a <write+0xd2>
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c15:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802c19:	8b 40 08             	mov    0x8(%rax),%eax
  802c1c:	83 e0 03             	and    $0x3,%eax
  802c1f:	85 c0                	test   %eax,%eax
  802c21:	75 3a                	jne    802c5d <write+0xa5>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802c23:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802c2a:	00 00 00 
  802c2d:	48 8b 00             	mov    (%rax),%rax
  802c30:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802c36:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802c39:	89 c6                	mov    %eax,%esi
  802c3b:	48 bf 5b 4e 80 00 00 	movabs $0x804e5b,%rdi
  802c42:	00 00 00 
  802c45:	b8 00 00 00 00       	mov    $0x0,%eax
  802c4a:	48 b9 b5 04 80 00 00 	movabs $0x8004b5,%rcx
  802c51:	00 00 00 
  802c54:	ff d1                	callq  *%rcx
		return -E_INVAL;
  802c56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c5b:	eb 2d                	jmp    802c8a <write+0xd2>
	{
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
		sys_cputs(buf, n);
	}
	if (!dev->dev_write)
  802c5d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c61:	48 8b 40 18          	mov    0x18(%rax),%rax
  802c65:	48 85 c0             	test   %rax,%rax
  802c68:	75 07                	jne    802c71 <write+0xb9>
		return -E_NOT_SUPP;
  802c6a:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802c6f:	eb 19                	jmp    802c8a <write+0xd2>
	return (*dev->dev_write)(fd, buf, n);
  802c71:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c75:	48 8b 40 18          	mov    0x18(%rax),%rax
  802c79:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  802c7d:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802c81:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  802c85:	48 89 cf             	mov    %rcx,%rdi
  802c88:	ff d0                	callq  *%rax
}
  802c8a:	c9                   	leaveq 
  802c8b:	c3                   	retq   

0000000000802c8c <seek>:

int
seek(int fdnum, off_t offset)
{
  802c8c:	55                   	push   %rbp
  802c8d:	48 89 e5             	mov    %rsp,%rbp
  802c90:	48 83 ec 18          	sub    $0x18,%rsp
  802c94:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802c97:	89 75 e8             	mov    %esi,-0x18(%rbp)
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c9a:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802c9e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802ca1:	48 89 d6             	mov    %rdx,%rsi
  802ca4:	89 c7                	mov    %eax,%edi
  802ca6:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  802cad:	00 00 00 
  802cb0:	ff d0                	callq  *%rax
  802cb2:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802cb5:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802cb9:	79 05                	jns    802cc0 <seek+0x34>
		return r;
  802cbb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802cbe:	eb 0f                	jmp    802ccf <seek+0x43>
	fd->fd_offset = offset;
  802cc0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802cc4:	8b 55 e8             	mov    -0x18(%rbp),%edx
  802cc7:	89 50 04             	mov    %edx,0x4(%rax)
	return 0;
  802cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ccf:	c9                   	leaveq 
  802cd0:	c3                   	retq   

0000000000802cd1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802cd1:	55                   	push   %rbp
  802cd2:	48 89 e5             	mov    %rsp,%rbp
  802cd5:	48 83 ec 30          	sub    $0x30,%rsp
  802cd9:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802cdc:	89 75 d8             	mov    %esi,-0x28(%rbp)
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cdf:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802ce3:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802ce6:	48 89 d6             	mov    %rdx,%rsi
  802ce9:	89 c7                	mov    %eax,%edi
  802ceb:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  802cf2:	00 00 00 
  802cf5:	ff d0                	callq  *%rax
  802cf7:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802cfa:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802cfe:	78 24                	js     802d24 <ftruncate+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d00:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802d04:	8b 00                	mov    (%rax),%eax
  802d06:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802d0a:	48 89 d6             	mov    %rdx,%rsi
  802d0d:	89 c7                	mov    %eax,%edi
  802d0f:	48 b8 95 27 80 00 00 	movabs $0x802795,%rax
  802d16:	00 00 00 
  802d19:	ff d0                	callq  *%rax
  802d1b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802d1e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802d22:	79 05                	jns    802d29 <ftruncate+0x58>
		return r;
  802d24:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802d27:	eb 72                	jmp    802d9b <ftruncate+0xca>
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d29:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802d2d:	8b 40 08             	mov    0x8(%rax),%eax
  802d30:	83 e0 03             	and    $0x3,%eax
  802d33:	85 c0                	test   %eax,%eax
  802d35:	75 3a                	jne    802d71 <ftruncate+0xa0>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d37:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802d3e:	00 00 00 
  802d41:	48 8b 00             	mov    (%rax),%rax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d44:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802d4a:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802d4d:	89 c6                	mov    %eax,%esi
  802d4f:	48 bf 78 4e 80 00 00 	movabs $0x804e78,%rdi
  802d56:	00 00 00 
  802d59:	b8 00 00 00 00       	mov    $0x0,%eax
  802d5e:	48 b9 b5 04 80 00 00 	movabs $0x8004b5,%rcx
  802d65:	00 00 00 
  802d68:	ff d1                	callq  *%rcx
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d6f:	eb 2a                	jmp    802d9b <ftruncate+0xca>
	}
	if (!dev->dev_trunc)
  802d71:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802d75:	48 8b 40 30          	mov    0x30(%rax),%rax
  802d79:	48 85 c0             	test   %rax,%rax
  802d7c:	75 07                	jne    802d85 <ftruncate+0xb4>
		return -E_NOT_SUPP;
  802d7e:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802d83:	eb 16                	jmp    802d9b <ftruncate+0xca>
	return (*dev->dev_trunc)(fd, newsize);
  802d85:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802d89:	48 8b 40 30          	mov    0x30(%rax),%rax
  802d8d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802d91:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  802d94:	89 ce                	mov    %ecx,%esi
  802d96:	48 89 d7             	mov    %rdx,%rdi
  802d99:	ff d0                	callq  *%rax
}
  802d9b:	c9                   	leaveq 
  802d9c:	c3                   	retq   

0000000000802d9d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802d9d:	55                   	push   %rbp
  802d9e:	48 89 e5             	mov    %rsp,%rbp
  802da1:	48 83 ec 30          	sub    $0x30,%rsp
  802da5:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802da8:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802dac:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802db0:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802db3:	48 89 d6             	mov    %rdx,%rsi
  802db6:	89 c7                	mov    %eax,%edi
  802db8:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  802dbf:	00 00 00 
  802dc2:	ff d0                	callq  *%rax
  802dc4:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802dc7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802dcb:	78 24                	js     802df1 <fstat+0x54>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dcd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802dd1:	8b 00                	mov    (%rax),%eax
  802dd3:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802dd7:	48 89 d6             	mov    %rdx,%rsi
  802dda:	89 c7                	mov    %eax,%edi
  802ddc:	48 b8 95 27 80 00 00 	movabs $0x802795,%rax
  802de3:	00 00 00 
  802de6:	ff d0                	callq  *%rax
  802de8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802deb:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802def:	79 05                	jns    802df6 <fstat+0x59>
		return r;
  802df1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802df4:	eb 5e                	jmp    802e54 <fstat+0xb7>
	if (!dev->dev_stat)
  802df6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802dfa:	48 8b 40 28          	mov    0x28(%rax),%rax
  802dfe:	48 85 c0             	test   %rax,%rax
  802e01:	75 07                	jne    802e0a <fstat+0x6d>
		return -E_NOT_SUPP;
  802e03:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802e08:	eb 4a                	jmp    802e54 <fstat+0xb7>
	stat->st_name[0] = 0;
  802e0a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802e0e:	c6 00 00             	movb   $0x0,(%rax)
	stat->st_size = 0;
  802e11:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802e15:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%rax)
  802e1c:	00 00 00 
	stat->st_isdir = 0;
  802e1f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802e23:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  802e2a:	00 00 00 
	stat->st_dev = dev;
  802e2d:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802e31:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802e35:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
	return (*dev->dev_stat)(fd, stat);
  802e3c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802e40:	48 8b 40 28          	mov    0x28(%rax),%rax
  802e44:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802e48:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  802e4c:	48 89 ce             	mov    %rcx,%rsi
  802e4f:	48 89 d7             	mov    %rdx,%rdi
  802e52:	ff d0                	callq  *%rax
}
  802e54:	c9                   	leaveq 
  802e55:	c3                   	retq   

0000000000802e56 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e56:	55                   	push   %rbp
  802e57:	48 89 e5             	mov    %rsp,%rbp
  802e5a:	48 83 ec 20          	sub    $0x20,%rsp
  802e5e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802e62:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e66:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802e6a:	be 00 00 00 00       	mov    $0x0,%esi
  802e6f:	48 89 c7             	mov    %rax,%rdi
  802e72:	48 b8 44 2f 80 00 00 	movabs $0x802f44,%rax
  802e79:	00 00 00 
  802e7c:	ff d0                	callq  *%rax
  802e7e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802e81:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802e85:	79 05                	jns    802e8c <stat+0x36>
		return fd;
  802e87:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802e8a:	eb 2f                	jmp    802ebb <stat+0x65>
	r = fstat(fd, stat);
  802e8c:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  802e90:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802e93:	48 89 d6             	mov    %rdx,%rsi
  802e96:	89 c7                	mov    %eax,%edi
  802e98:	48 b8 9d 2d 80 00 00 	movabs $0x802d9d,%rax
  802e9f:	00 00 00 
  802ea2:	ff d0                	callq  *%rax
  802ea4:	89 45 f8             	mov    %eax,-0x8(%rbp)
	close(fd);
  802ea7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802eaa:	89 c7                	mov    %eax,%edi
  802eac:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  802eb3:	00 00 00 
  802eb6:	ff d0                	callq  *%rax
	return r;
  802eb8:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
  802ebb:	c9                   	leaveq 
  802ebc:	c3                   	retq   

0000000000802ebd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802ebd:	55                   	push   %rbp
  802ebe:	48 89 e5             	mov    %rsp,%rbp
  802ec1:	48 83 ec 10          	sub    $0x10,%rsp
  802ec5:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802ec8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	static envid_t fsenv;
	if (fsenv == 0)
  802ecc:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802ed3:	00 00 00 
  802ed6:	8b 00                	mov    (%rax),%eax
  802ed8:	85 c0                	test   %eax,%eax
  802eda:	75 1d                	jne    802ef9 <fsipc+0x3c>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802edc:	bf 01 00 00 00       	mov    $0x1,%edi
  802ee1:	48 b8 d4 24 80 00 00 	movabs $0x8024d4,%rax
  802ee8:	00 00 00 
  802eeb:	ff d0                	callq  *%rax
  802eed:	48 ba 00 70 80 00 00 	movabs $0x807000,%rdx
  802ef4:	00 00 00 
  802ef7:	89 02                	mov    %eax,(%rdx)
	//static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ef9:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802f00:	00 00 00 
  802f03:	8b 00                	mov    (%rax),%eax
  802f05:	8b 75 fc             	mov    -0x4(%rbp),%esi
  802f08:	b9 07 00 00 00       	mov    $0x7,%ecx
  802f0d:	48 ba 00 80 80 00 00 	movabs $0x808000,%rdx
  802f14:	00 00 00 
  802f17:	89 c7                	mov    %eax,%edi
  802f19:	48 b8 72 24 80 00 00 	movabs $0x802472,%rax
  802f20:	00 00 00 
  802f23:	ff d0                	callq  *%rax
	return ipc_recv(NULL, dstva, NULL);
  802f25:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802f29:	ba 00 00 00 00       	mov    $0x0,%edx
  802f2e:	48 89 c6             	mov    %rax,%rsi
  802f31:	bf 00 00 00 00       	mov    $0x0,%edi
  802f36:	48 b8 6c 23 80 00 00 	movabs $0x80236c,%rax
  802f3d:	00 00 00 
  802f40:	ff d0                	callq  *%rax
}
  802f42:	c9                   	leaveq 
  802f43:	c3                   	retq   

0000000000802f44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f44:	55                   	push   %rbp
  802f45:	48 89 e5             	mov    %rsp,%rbp
  802f48:	48 83 ec 30          	sub    $0x30,%rsp
  802f4c:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  802f50:	89 75 d4             	mov    %esi,-0x2c(%rbp)
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here
	int r = -1;
  802f53:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%rbp)
	int d = -1;
  802f5a:	c7 45 f8 ff ff ff ff 	movl   $0xffffffff,-0x8(%rbp)
	int len = 0;
  802f61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	void *va;
	if(!path)
  802f68:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  802f6d:	75 08                	jne    802f77 <open+0x33>
	{
		return r;
  802f6f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802f72:	e9 f2 00 00 00       	jmpq   803069 <open+0x125>
	}	
	else if((len = strlen(path)) >= MAXPATHLEN) 
  802f77:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802f7b:	48 89 c7             	mov    %rax,%rdi
  802f7e:	48 b8 fe 0f 80 00 00 	movabs $0x800ffe,%rax
  802f85:	00 00 00 
  802f88:	ff d0                	callq  *%rax
  802f8a:	89 45 f4             	mov    %eax,-0xc(%rbp)
  802f8d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%rbp)
  802f94:	7e 0a                	jle    802fa0 <open+0x5c>
	{
		return -E_BAD_PATH;
  802f96:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  802f9b:	e9 c9 00 00 00       	jmpq   803069 <open+0x125>
	}
	else
	{
		struct Fd *fd_store = NULL;
  802fa0:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  802fa7:	00 
		if((r = fd_alloc(&fd_store)) < 0 || fd_store == NULL)
  802fa8:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  802fac:	48 89 c7             	mov    %rax,%rdi
  802faf:	48 b8 a4 25 80 00 00 	movabs $0x8025a4,%rax
  802fb6:	00 00 00 
  802fb9:	ff d0                	callq  *%rax
  802fbb:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802fbe:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802fc2:	78 09                	js     802fcd <open+0x89>
  802fc4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802fc8:	48 85 c0             	test   %rax,%rax
  802fcb:	75 08                	jne    802fd5 <open+0x91>
		{
			return r;
  802fcd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802fd0:	e9 94 00 00 00       	jmpq   803069 <open+0x125>
		}	
		strncpy(fsipcbuf.open.req_path,  path, MAXPATHLEN);
  802fd5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802fd9:	ba 00 04 00 00       	mov    $0x400,%edx
  802fde:	48 89 c6             	mov    %rax,%rsi
  802fe1:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  802fe8:	00 00 00 
  802feb:	48 b8 fc 10 80 00 00 	movabs $0x8010fc,%rax
  802ff2:	00 00 00 
  802ff5:	ff d0                	callq  *%rax
		fsipcbuf.open.req_omode = mode;
  802ff7:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802ffe:	00 00 00 
  803001:	8b 55 d4             	mov    -0x2c(%rbp),%edx
  803004:	89 90 00 04 00 00    	mov    %edx,0x400(%rax)
		if ((r = fsipc(FSREQ_OPEN, fd_store)) < 0)
  80300a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80300e:	48 89 c6             	mov    %rax,%rsi
  803011:	bf 01 00 00 00       	mov    $0x1,%edi
  803016:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  80301d:	00 00 00 
  803020:	ff d0                	callq  *%rax
  803022:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803025:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803029:	79 2b                	jns    803056 <open+0x112>
		{
			if((d = fd_close(fd_store, 0)) < 0)
  80302b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80302f:	be 00 00 00 00       	mov    $0x0,%esi
  803034:	48 89 c7             	mov    %rax,%rdi
  803037:	48 b8 cc 26 80 00 00 	movabs $0x8026cc,%rax
  80303e:	00 00 00 
  803041:	ff d0                	callq  *%rax
  803043:	89 45 f8             	mov    %eax,-0x8(%rbp)
  803046:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  80304a:	79 05                	jns    803051 <open+0x10d>
			{
				return d;
  80304c:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80304f:	eb 18                	jmp    803069 <open+0x125>
			}
			return r;
  803051:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803054:	eb 13                	jmp    803069 <open+0x125>
		}	
		return fd2num(fd_store);
  803056:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80305a:	48 89 c7             	mov    %rax,%rdi
  80305d:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  803064:	00 00 00 
  803067:	ff d0                	callq  *%rax
	}
	//panic ("open not implemented");
}
  803069:	c9                   	leaveq 
  80306a:	c3                   	retq   

000000000080306b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80306b:	55                   	push   %rbp
  80306c:	48 89 e5             	mov    %rsp,%rbp
  80306f:	48 83 ec 10          	sub    $0x10,%rsp
  803073:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803077:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80307b:	8b 50 0c             	mov    0xc(%rax),%edx
  80307e:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  803085:	00 00 00 
  803088:	89 10                	mov    %edx,(%rax)
	return fsipc(FSREQ_FLUSH, NULL);
  80308a:	be 00 00 00 00       	mov    $0x0,%esi
  80308f:	bf 06 00 00 00       	mov    $0x6,%edi
  803094:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  80309b:	00 00 00 
  80309e:	ff d0                	callq  *%rax
}
  8030a0:	c9                   	leaveq 
  8030a1:	c3                   	retq   

00000000008030a2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8030a2:	55                   	push   %rbp
  8030a3:	48 89 e5             	mov    %rsp,%rbp
  8030a6:	48 83 ec 30          	sub    $0x30,%rsp
  8030aa:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8030ae:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8030b2:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r = 0;
  8030b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	if(!fd || !buf)
  8030bd:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8030c2:	74 07                	je     8030cb <devfile_read+0x29>
  8030c4:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8030c9:	75 07                	jne    8030d2 <devfile_read+0x30>
		return -E_INVAL;
  8030cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8030d0:	eb 77                	jmp    803149 <devfile_read+0xa7>
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8030d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8030d6:	8b 50 0c             	mov    0xc(%rax),%edx
  8030d9:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8030e0:	00 00 00 
  8030e3:	89 10                	mov    %edx,(%rax)
	fsipcbuf.read.req_n = n;
  8030e5:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8030ec:	00 00 00 
  8030ef:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8030f3:	48 89 50 08          	mov    %rdx,0x8(%rax)
	if ((r = fsipc(FSREQ_READ, NULL)) <= 0){
  8030f7:	be 00 00 00 00       	mov    $0x0,%esi
  8030fc:	bf 03 00 00 00       	mov    $0x3,%edi
  803101:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  803108:	00 00 00 
  80310b:	ff d0                	callq  *%rax
  80310d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803110:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803114:	7f 05                	jg     80311b <devfile_read+0x79>
		//cprintf("devfile_read r is [%d]\n",r);
		return r;
  803116:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803119:	eb 2e                	jmp    803149 <devfile_read+0xa7>
	}
	//cprintf("devfile_read %x %x %x %x\n",fsipcbuf.readRet.ret_buf[0], fsipcbuf.readRet.ret_buf[1], fsipcbuf.readRet.ret_buf[2], fsipcbuf.readRet.ret_buf[3]);
	memmove(buf, (char*)fsipcbuf.readRet.ret_buf, r);
  80311b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80311e:	48 63 d0             	movslq %eax,%rdx
  803121:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803125:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  80312c:	00 00 00 
  80312f:	48 89 c7             	mov    %rax,%rdi
  803132:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  803139:	00 00 00 
  80313c:	ff d0                	callq  *%rax
	char* buf1 = (char*)buf;
  80313e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803142:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	//cprintf("devfile_read ri is [%d] %x %x %x %x\n",r,buf1[0],buf1[1],buf1[2],buf1[3]);
	return r;
  803146:	8b 45 fc             	mov    -0x4(%rbp),%eax
	//panic("devfile_read not implemented");
}
  803149:	c9                   	leaveq 
  80314a:	c3                   	retq   

000000000080314b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80314b:	55                   	push   %rbp
  80314c:	48 89 e5             	mov    %rsp,%rbp
  80314f:	48 83 ec 30          	sub    $0x30,%rsp
  803153:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  803157:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80315b:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r = -1;
  80315f:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%rbp)
	if(!fd || !buf)
  803166:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80316b:	74 07                	je     803174 <devfile_write+0x29>
  80316d:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  803172:	75 08                	jne    80317c <devfile_write+0x31>
		return r;
  803174:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803177:	e9 9a 00 00 00       	jmpq   803216 <devfile_write+0xcb>
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80317c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803180:	8b 50 0c             	mov    0xc(%rax),%edx
  803183:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  80318a:	00 00 00 
  80318d:	89 10                	mov    %edx,(%rax)
	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
  80318f:	48 81 7d d8 f4 0f 00 	cmpq   $0xff4,-0x28(%rbp)
  803196:	00 
  803197:	76 08                	jbe    8031a1 <devfile_write+0x56>
	{
		n = PGSIZE - (sizeof(int) + sizeof(size_t));
  803199:	48 c7 45 d8 f4 0f 00 	movq   $0xff4,-0x28(%rbp)
  8031a0:	00 
	}
	fsipcbuf.write.req_n = n;
  8031a1:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8031a8:	00 00 00 
  8031ab:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8031af:	48 89 50 08          	mov    %rdx,0x8(%rax)
	
	memmove((void*)fsipcbuf.write.req_buf, (void*)buf, n);
  8031b3:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8031b7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8031bb:	48 89 c6             	mov    %rax,%rsi
  8031be:	48 bf 10 80 80 00 00 	movabs $0x808010,%rdi
  8031c5:	00 00 00 
  8031c8:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  8031cf:	00 00 00 
  8031d2:	ff d0                	callq  *%rax
	if ((r = fsipc(FSREQ_WRITE, NULL)) <= 0){
  8031d4:	be 00 00 00 00       	mov    $0x0,%esi
  8031d9:	bf 04 00 00 00       	mov    $0x4,%edi
  8031de:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  8031e5:	00 00 00 
  8031e8:	ff d0                	callq  *%rax
  8031ea:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8031ed:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8031f1:	7f 20                	jg     803213 <devfile_write+0xc8>
		cprintf("fsipc-FSREQ_WRITE returns 0");
  8031f3:	48 bf 9e 4e 80 00 00 	movabs $0x804e9e,%rdi
  8031fa:	00 00 00 
  8031fd:	b8 00 00 00 00       	mov    $0x0,%eax
  803202:	48 ba b5 04 80 00 00 	movabs $0x8004b5,%rdx
  803209:	00 00 00 
  80320c:	ff d2                	callq  *%rdx
		return r;
  80320e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803211:	eb 03                	jmp    803216 <devfile_write+0xcb>
	}
	return r;
  803213:	8b 45 fc             	mov    -0x4(%rbp),%eax
	//panic("devfile_write not implemented");
}
  803216:	c9                   	leaveq 
  803217:	c3                   	retq   

0000000000803218 <devfile_stat>:


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  803218:	55                   	push   %rbp
  803219:	48 89 e5             	mov    %rsp,%rbp
  80321c:	48 83 ec 20          	sub    $0x20,%rsp
  803220:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  803224:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803228:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80322c:	8b 50 0c             	mov    0xc(%rax),%edx
  80322f:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  803236:	00 00 00 
  803239:	89 10                	mov    %edx,(%rax)
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80323b:	be 00 00 00 00       	mov    $0x0,%esi
  803240:	bf 05 00 00 00       	mov    $0x5,%edi
  803245:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  80324c:	00 00 00 
  80324f:	ff d0                	callq  *%rax
  803251:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803254:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803258:	79 05                	jns    80325f <devfile_stat+0x47>
		return r;
  80325a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80325d:	eb 56                	jmp    8032b5 <devfile_stat+0x9d>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80325f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803263:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  80326a:	00 00 00 
  80326d:	48 89 c7             	mov    %rax,%rdi
  803270:	48 b8 6a 10 80 00 00 	movabs $0x80106a,%rax
  803277:	00 00 00 
  80327a:	ff d0                	callq  *%rax
	st->st_size = fsipcbuf.statRet.ret_size;
  80327c:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  803283:	00 00 00 
  803286:	8b 90 80 00 00 00    	mov    0x80(%rax),%edx
  80328c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803290:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803296:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  80329d:	00 00 00 
  8032a0:	8b 90 84 00 00 00    	mov    0x84(%rax),%edx
  8032a6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8032aa:	89 90 84 00 00 00    	mov    %edx,0x84(%rax)
	return 0;
  8032b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8032b5:	c9                   	leaveq 
  8032b6:	c3                   	retq   

00000000008032b7 <devfile_trunc>:

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8032b7:	55                   	push   %rbp
  8032b8:	48 89 e5             	mov    %rsp,%rbp
  8032bb:	48 83 ec 10          	sub    $0x10,%rsp
  8032bf:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8032c3:	89 75 f4             	mov    %esi,-0xc(%rbp)
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8032c6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8032ca:	8b 50 0c             	mov    0xc(%rax),%edx
  8032cd:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8032d4:	00 00 00 
  8032d7:	89 10                	mov    %edx,(%rax)
	fsipcbuf.set_size.req_size = newsize;
  8032d9:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8032e0:	00 00 00 
  8032e3:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8032e6:	89 50 04             	mov    %edx,0x4(%rax)
	return fsipc(FSREQ_SET_SIZE, NULL);
  8032e9:	be 00 00 00 00       	mov    $0x0,%esi
  8032ee:	bf 02 00 00 00       	mov    $0x2,%edi
  8032f3:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  8032fa:	00 00 00 
  8032fd:	ff d0                	callq  *%rax
}
  8032ff:	c9                   	leaveq 
  803300:	c3                   	retq   

0000000000803301 <remove>:

// Delete a file
int
remove(const char *path)
{
  803301:	55                   	push   %rbp
  803302:	48 89 e5             	mov    %rsp,%rbp
  803305:	48 83 ec 10          	sub    $0x10,%rsp
  803309:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	if (strlen(path) >= MAXPATHLEN)
  80330d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803311:	48 89 c7             	mov    %rax,%rdi
  803314:	48 b8 fe 0f 80 00 00 	movabs $0x800ffe,%rax
  80331b:	00 00 00 
  80331e:	ff d0                	callq  *%rax
  803320:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803325:	7e 07                	jle    80332e <remove+0x2d>
		return -E_BAD_PATH;
  803327:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80332c:	eb 33                	jmp    803361 <remove+0x60>
	strcpy(fsipcbuf.remove.req_path, path);
  80332e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803332:	48 89 c6             	mov    %rax,%rsi
  803335:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  80333c:	00 00 00 
  80333f:	48 b8 6a 10 80 00 00 	movabs $0x80106a,%rax
  803346:	00 00 00 
  803349:	ff d0                	callq  *%rax
	return fsipc(FSREQ_REMOVE, NULL);
  80334b:	be 00 00 00 00       	mov    $0x0,%esi
  803350:	bf 07 00 00 00       	mov    $0x7,%edi
  803355:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  80335c:	00 00 00 
  80335f:	ff d0                	callq  *%rax
}
  803361:	c9                   	leaveq 
  803362:	c3                   	retq   

0000000000803363 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  803363:	55                   	push   %rbp
  803364:	48 89 e5             	mov    %rsp,%rbp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803367:	be 00 00 00 00       	mov    $0x0,%esi
  80336c:	bf 08 00 00 00       	mov    $0x8,%edi
  803371:	48 b8 bd 2e 80 00 00 	movabs $0x802ebd,%rax
  803378:	00 00 00 
  80337b:	ff d0                	callq  *%rax
}
  80337d:	5d                   	pop    %rbp
  80337e:	c3                   	retq   

000000000080337f <copy>:

//Copy a file from src to dest
int
copy(char *src, char *dest)
{
  80337f:	55                   	push   %rbp
  803380:	48 89 e5             	mov    %rsp,%rbp
  803383:	48 81 ec 20 02 00 00 	sub    $0x220,%rsp
  80338a:	48 89 bd e8 fd ff ff 	mov    %rdi,-0x218(%rbp)
  803391:	48 89 b5 e0 fd ff ff 	mov    %rsi,-0x220(%rbp)
	int r;
	int fd_src, fd_dest;
	char buffer[512];	//keep this small
	ssize_t read_size;
	ssize_t write_size;
	fd_src = open(src, O_RDONLY);
  803398:	48 8b 85 e8 fd ff ff 	mov    -0x218(%rbp),%rax
  80339f:	be 00 00 00 00       	mov    $0x0,%esi
  8033a4:	48 89 c7             	mov    %rax,%rdi
  8033a7:	48 b8 44 2f 80 00 00 	movabs $0x802f44,%rax
  8033ae:	00 00 00 
  8033b1:	ff d0                	callq  *%rax
  8033b3:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if (fd_src < 0) {	//error
  8033b6:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8033ba:	79 28                	jns    8033e4 <copy+0x65>
		cprintf("cp open src error:%e\n", fd_src);
  8033bc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033bf:	89 c6                	mov    %eax,%esi
  8033c1:	48 bf ba 4e 80 00 00 	movabs $0x804eba,%rdi
  8033c8:	00 00 00 
  8033cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8033d0:	48 ba b5 04 80 00 00 	movabs $0x8004b5,%rdx
  8033d7:	00 00 00 
  8033da:	ff d2                	callq  *%rdx
		return fd_src;
  8033dc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033df:	e9 74 01 00 00       	jmpq   803558 <copy+0x1d9>
	}
	
	fd_dest = open(dest, O_CREAT | O_WRONLY);
  8033e4:	48 8b 85 e0 fd ff ff 	mov    -0x220(%rbp),%rax
  8033eb:	be 01 01 00 00       	mov    $0x101,%esi
  8033f0:	48 89 c7             	mov    %rax,%rdi
  8033f3:	48 b8 44 2f 80 00 00 	movabs $0x802f44,%rax
  8033fa:	00 00 00 
  8033fd:	ff d0                	callq  *%rax
  8033ff:	89 45 f8             	mov    %eax,-0x8(%rbp)
	if (fd_dest < 0) {	//error
  803402:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  803406:	79 39                	jns    803441 <copy+0xc2>
		cprintf("cp create dest  error:%e\n", fd_dest);
  803408:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80340b:	89 c6                	mov    %eax,%esi
  80340d:	48 bf d0 4e 80 00 00 	movabs $0x804ed0,%rdi
  803414:	00 00 00 
  803417:	b8 00 00 00 00       	mov    $0x0,%eax
  80341c:	48 ba b5 04 80 00 00 	movabs $0x8004b5,%rdx
  803423:	00 00 00 
  803426:	ff d2                	callq  *%rdx
		close(fd_src);
  803428:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80342b:	89 c7                	mov    %eax,%edi
  80342d:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  803434:	00 00 00 
  803437:	ff d0                	callq  *%rax
		return fd_dest;
  803439:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80343c:	e9 17 01 00 00       	jmpq   803558 <copy+0x1d9>
	}
	
	while ((read_size = read(fd_src, buffer, 512)) > 0) {
  803441:	eb 74                	jmp    8034b7 <copy+0x138>
		write_size = write(fd_dest, buffer, read_size);
  803443:	8b 45 f4             	mov    -0xc(%rbp),%eax
  803446:	48 63 d0             	movslq %eax,%rdx
  803449:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  803450:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803453:	48 89 ce             	mov    %rcx,%rsi
  803456:	89 c7                	mov    %eax,%edi
  803458:	48 b8 b8 2b 80 00 00 	movabs $0x802bb8,%rax
  80345f:	00 00 00 
  803462:	ff d0                	callq  *%rax
  803464:	89 45 f0             	mov    %eax,-0x10(%rbp)
		if (write_size < 0) {
  803467:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
  80346b:	79 4a                	jns    8034b7 <copy+0x138>
			cprintf("cp write error:%e\n", write_size);
  80346d:	8b 45 f0             	mov    -0x10(%rbp),%eax
  803470:	89 c6                	mov    %eax,%esi
  803472:	48 bf ea 4e 80 00 00 	movabs $0x804eea,%rdi
  803479:	00 00 00 
  80347c:	b8 00 00 00 00       	mov    $0x0,%eax
  803481:	48 ba b5 04 80 00 00 	movabs $0x8004b5,%rdx
  803488:	00 00 00 
  80348b:	ff d2                	callq  *%rdx
			close(fd_src);
  80348d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803490:	89 c7                	mov    %eax,%edi
  803492:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  803499:	00 00 00 
  80349c:	ff d0                	callq  *%rax
			close(fd_dest);
  80349e:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8034a1:	89 c7                	mov    %eax,%edi
  8034a3:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  8034aa:	00 00 00 
  8034ad:	ff d0                	callq  *%rax
			return write_size;
  8034af:	8b 45 f0             	mov    -0x10(%rbp),%eax
  8034b2:	e9 a1 00 00 00       	jmpq   803558 <copy+0x1d9>
		cprintf("cp create dest  error:%e\n", fd_dest);
		close(fd_src);
		return fd_dest;
	}
	
	while ((read_size = read(fd_src, buffer, 512)) > 0) {
  8034b7:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  8034be:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034c1:	ba 00 02 00 00       	mov    $0x200,%edx
  8034c6:	48 89 ce             	mov    %rcx,%rsi
  8034c9:	89 c7                	mov    %eax,%edi
  8034cb:	48 b8 6e 2a 80 00 00 	movabs $0x802a6e,%rax
  8034d2:	00 00 00 
  8034d5:	ff d0                	callq  *%rax
  8034d7:	89 45 f4             	mov    %eax,-0xc(%rbp)
  8034da:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8034de:	0f 8f 5f ff ff ff    	jg     803443 <copy+0xc4>
			close(fd_src);
			close(fd_dest);
			return write_size;
		}		
	}
	if (read_size < 0) {
  8034e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8034e8:	79 47                	jns    803531 <copy+0x1b2>
		cprintf("cp read src error:%e\n", read_size);
  8034ea:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8034ed:	89 c6                	mov    %eax,%esi
  8034ef:	48 bf fd 4e 80 00 00 	movabs $0x804efd,%rdi
  8034f6:	00 00 00 
  8034f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8034fe:	48 ba b5 04 80 00 00 	movabs $0x8004b5,%rdx
  803505:	00 00 00 
  803508:	ff d2                	callq  *%rdx
		close(fd_src);
  80350a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80350d:	89 c7                	mov    %eax,%edi
  80350f:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  803516:	00 00 00 
  803519:	ff d0                	callq  *%rax
		close(fd_dest);
  80351b:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80351e:	89 c7                	mov    %eax,%edi
  803520:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  803527:	00 00 00 
  80352a:	ff d0                	callq  *%rax
		return read_size;
  80352c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80352f:	eb 27                	jmp    803558 <copy+0x1d9>
	}
	close(fd_src);
  803531:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803534:	89 c7                	mov    %eax,%edi
  803536:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  80353d:	00 00 00 
  803540:	ff d0                	callq  *%rax
	close(fd_dest);
  803542:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803545:	89 c7                	mov    %eax,%edi
  803547:	48 b8 4c 28 80 00 00 	movabs $0x80284c,%rax
  80354e:	00 00 00 
  803551:	ff d0                	callq  *%rax
	return 0;
  803553:	b8 00 00 00 00       	mov    $0x0,%eax
	
}
  803558:	c9                   	leaveq 
  803559:	c3                   	retq   

000000000080355a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80355a:	55                   	push   %rbp
  80355b:	48 89 e5             	mov    %rsp,%rbp
  80355e:	48 83 ec 20          	sub    $0x20,%rsp
  803562:	89 7d ec             	mov    %edi,-0x14(%rbp)
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803565:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  803569:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80356c:	48 89 d6             	mov    %rdx,%rsi
  80356f:	89 c7                	mov    %eax,%edi
  803571:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  803578:	00 00 00 
  80357b:	ff d0                	callq  *%rax
  80357d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803580:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803584:	79 05                	jns    80358b <fd2sockid+0x31>
		return r;
  803586:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803589:	eb 24                	jmp    8035af <fd2sockid+0x55>
	if (sfd->fd_dev_id != devsock.dev_id)
  80358b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80358f:	8b 10                	mov    (%rax),%edx
  803591:	48 b8 a0 60 80 00 00 	movabs $0x8060a0,%rax
  803598:	00 00 00 
  80359b:	8b 00                	mov    (%rax),%eax
  80359d:	39 c2                	cmp    %eax,%edx
  80359f:	74 07                	je     8035a8 <fd2sockid+0x4e>
		return -E_NOT_SUPP;
  8035a1:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8035a6:	eb 07                	jmp    8035af <fd2sockid+0x55>
	return sfd->fd_sock.sockid;
  8035a8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8035ac:	8b 40 0c             	mov    0xc(%rax),%eax
}
  8035af:	c9                   	leaveq 
  8035b0:	c3                   	retq   

00000000008035b1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8035b1:	55                   	push   %rbp
  8035b2:	48 89 e5             	mov    %rsp,%rbp
  8035b5:	48 83 ec 20          	sub    $0x20,%rsp
  8035b9:	89 7d ec             	mov    %edi,-0x14(%rbp)
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8035bc:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  8035c0:	48 89 c7             	mov    %rax,%rdi
  8035c3:	48 b8 a4 25 80 00 00 	movabs $0x8025a4,%rax
  8035ca:	00 00 00 
  8035cd:	ff d0                	callq  *%rax
  8035cf:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8035d2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8035d6:	78 26                	js     8035fe <alloc_sockfd+0x4d>
            || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8035d8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8035dc:	ba 07 04 00 00       	mov    $0x407,%edx
  8035e1:	48 89 c6             	mov    %rax,%rsi
  8035e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8035e9:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  8035f0:	00 00 00 
  8035f3:	ff d0                	callq  *%rax
  8035f5:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8035f8:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8035fc:	79 16                	jns    803614 <alloc_sockfd+0x63>
		nsipc_close(sockid);
  8035fe:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803601:	89 c7                	mov    %eax,%edi
  803603:	48 b8 be 3a 80 00 00 	movabs $0x803abe,%rax
  80360a:	00 00 00 
  80360d:	ff d0                	callq  *%rax
		return r;
  80360f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803612:	eb 3a                	jmp    80364e <alloc_sockfd+0x9d>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803614:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803618:	48 ba a0 60 80 00 00 	movabs $0x8060a0,%rdx
  80361f:	00 00 00 
  803622:	8b 12                	mov    (%rdx),%edx
  803624:	89 10                	mov    %edx,(%rax)
	sfd->fd_omode = O_RDWR;
  803626:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80362a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
	sfd->fd_sock.sockid = sockid;
  803631:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803635:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803638:	89 50 0c             	mov    %edx,0xc(%rax)
	return fd2num(sfd);
  80363b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80363f:	48 89 c7             	mov    %rax,%rdi
  803642:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  803649:	00 00 00 
  80364c:	ff d0                	callq  *%rax
}
  80364e:	c9                   	leaveq 
  80364f:	c3                   	retq   

0000000000803650 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803650:	55                   	push   %rbp
  803651:	48 89 e5             	mov    %rsp,%rbp
  803654:	48 83 ec 30          	sub    $0x30,%rsp
  803658:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80365b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80365f:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int r;
	if ((r = fd2sockid(s)) < 0)
  803663:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803666:	89 c7                	mov    %eax,%edi
  803668:	48 b8 5a 35 80 00 00 	movabs $0x80355a,%rax
  80366f:	00 00 00 
  803672:	ff d0                	callq  *%rax
  803674:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803677:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80367b:	79 05                	jns    803682 <accept+0x32>
		return r;
  80367d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803680:	eb 3b                	jmp    8036bd <accept+0x6d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803682:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  803686:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  80368a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80368d:	48 89 ce             	mov    %rcx,%rsi
  803690:	89 c7                	mov    %eax,%edi
  803692:	48 b8 9b 39 80 00 00 	movabs $0x80399b,%rax
  803699:	00 00 00 
  80369c:	ff d0                	callq  *%rax
  80369e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8036a1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8036a5:	79 05                	jns    8036ac <accept+0x5c>
		return r;
  8036a7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8036aa:	eb 11                	jmp    8036bd <accept+0x6d>
	return alloc_sockfd(r);
  8036ac:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8036af:	89 c7                	mov    %eax,%edi
  8036b1:	48 b8 b1 35 80 00 00 	movabs $0x8035b1,%rax
  8036b8:	00 00 00 
  8036bb:	ff d0                	callq  *%rax
}
  8036bd:	c9                   	leaveq 
  8036be:	c3                   	retq   

00000000008036bf <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8036bf:	55                   	push   %rbp
  8036c0:	48 89 e5             	mov    %rsp,%rbp
  8036c3:	48 83 ec 20          	sub    $0x20,%rsp
  8036c7:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8036ca:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8036ce:	89 55 e8             	mov    %edx,-0x18(%rbp)
	int r;
	if ((r = fd2sockid(s)) < 0)
  8036d1:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8036d4:	89 c7                	mov    %eax,%edi
  8036d6:	48 b8 5a 35 80 00 00 	movabs $0x80355a,%rax
  8036dd:	00 00 00 
  8036e0:	ff d0                	callq  *%rax
  8036e2:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8036e5:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8036e9:	79 05                	jns    8036f0 <bind+0x31>
		return r;
  8036eb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8036ee:	eb 1b                	jmp    80370b <bind+0x4c>
	return nsipc_bind(r, name, namelen);
  8036f0:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8036f3:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8036f7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8036fa:	48 89 ce             	mov    %rcx,%rsi
  8036fd:	89 c7                	mov    %eax,%edi
  8036ff:	48 b8 1a 3a 80 00 00 	movabs $0x803a1a,%rax
  803706:	00 00 00 
  803709:	ff d0                	callq  *%rax
}
  80370b:	c9                   	leaveq 
  80370c:	c3                   	retq   

000000000080370d <shutdown>:

int
shutdown(int s, int how)
{
  80370d:	55                   	push   %rbp
  80370e:	48 89 e5             	mov    %rsp,%rbp
  803711:	48 83 ec 20          	sub    $0x20,%rsp
  803715:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803718:	89 75 e8             	mov    %esi,-0x18(%rbp)
	int r;
	if ((r = fd2sockid(s)) < 0)
  80371b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80371e:	89 c7                	mov    %eax,%edi
  803720:	48 b8 5a 35 80 00 00 	movabs $0x80355a,%rax
  803727:	00 00 00 
  80372a:	ff d0                	callq  *%rax
  80372c:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80372f:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803733:	79 05                	jns    80373a <shutdown+0x2d>
		return r;
  803735:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803738:	eb 16                	jmp    803750 <shutdown+0x43>
	return nsipc_shutdown(r, how);
  80373a:	8b 55 e8             	mov    -0x18(%rbp),%edx
  80373d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803740:	89 d6                	mov    %edx,%esi
  803742:	89 c7                	mov    %eax,%edi
  803744:	48 b8 7e 3a 80 00 00 	movabs $0x803a7e,%rax
  80374b:	00 00 00 
  80374e:	ff d0                	callq  *%rax
}
  803750:	c9                   	leaveq 
  803751:	c3                   	retq   

0000000000803752 <devsock_close>:

static int
devsock_close(struct Fd *fd)
{
  803752:	55                   	push   %rbp
  803753:	48 89 e5             	mov    %rsp,%rbp
  803756:	48 83 ec 10          	sub    $0x10,%rsp
  80375a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	if (pageref(fd) == 1)
  80375e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803762:	48 89 c7             	mov    %rax,%rdi
  803765:	48 b8 22 47 80 00 00 	movabs $0x804722,%rax
  80376c:	00 00 00 
  80376f:	ff d0                	callq  *%rax
  803771:	83 f8 01             	cmp    $0x1,%eax
  803774:	75 17                	jne    80378d <devsock_close+0x3b>
		return nsipc_close(fd->fd_sock.sockid);
  803776:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80377a:	8b 40 0c             	mov    0xc(%rax),%eax
  80377d:	89 c7                	mov    %eax,%edi
  80377f:	48 b8 be 3a 80 00 00 	movabs $0x803abe,%rax
  803786:	00 00 00 
  803789:	ff d0                	callq  *%rax
  80378b:	eb 05                	jmp    803792 <devsock_close+0x40>
	else
		return 0;
  80378d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803792:	c9                   	leaveq 
  803793:	c3                   	retq   

0000000000803794 <connect>:

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803794:	55                   	push   %rbp
  803795:	48 89 e5             	mov    %rsp,%rbp
  803798:	48 83 ec 20          	sub    $0x20,%rsp
  80379c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80379f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8037a3:	89 55 e8             	mov    %edx,-0x18(%rbp)
	int r;
	if ((r = fd2sockid(s)) < 0)
  8037a6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8037a9:	89 c7                	mov    %eax,%edi
  8037ab:	48 b8 5a 35 80 00 00 	movabs $0x80355a,%rax
  8037b2:	00 00 00 
  8037b5:	ff d0                	callq  *%rax
  8037b7:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8037ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8037be:	79 05                	jns    8037c5 <connect+0x31>
		return r;
  8037c0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8037c3:	eb 1b                	jmp    8037e0 <connect+0x4c>
	return nsipc_connect(r, name, namelen);
  8037c5:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8037c8:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8037cc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8037cf:	48 89 ce             	mov    %rcx,%rsi
  8037d2:	89 c7                	mov    %eax,%edi
  8037d4:	48 b8 eb 3a 80 00 00 	movabs $0x803aeb,%rax
  8037db:	00 00 00 
  8037de:	ff d0                	callq  *%rax
}
  8037e0:	c9                   	leaveq 
  8037e1:	c3                   	retq   

00000000008037e2 <listen>:

int
listen(int s, int backlog)
{
  8037e2:	55                   	push   %rbp
  8037e3:	48 89 e5             	mov    %rsp,%rbp
  8037e6:	48 83 ec 20          	sub    $0x20,%rsp
  8037ea:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8037ed:	89 75 e8             	mov    %esi,-0x18(%rbp)
	int r;
	if ((r = fd2sockid(s)) < 0)
  8037f0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8037f3:	89 c7                	mov    %eax,%edi
  8037f5:	48 b8 5a 35 80 00 00 	movabs $0x80355a,%rax
  8037fc:	00 00 00 
  8037ff:	ff d0                	callq  *%rax
  803801:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803804:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803808:	79 05                	jns    80380f <listen+0x2d>
		return r;
  80380a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80380d:	eb 16                	jmp    803825 <listen+0x43>
	return nsipc_listen(r, backlog);
  80380f:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803812:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803815:	89 d6                	mov    %edx,%esi
  803817:	89 c7                	mov    %eax,%edi
  803819:	48 b8 4f 3b 80 00 00 	movabs $0x803b4f,%rax
  803820:	00 00 00 
  803823:	ff d0                	callq  *%rax
}
  803825:	c9                   	leaveq 
  803826:	c3                   	retq   

0000000000803827 <devsock_read>:

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  803827:	55                   	push   %rbp
  803828:	48 89 e5             	mov    %rsp,%rbp
  80382b:	48 83 ec 20          	sub    $0x20,%rsp
  80382f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803833:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803837:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80383b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80383f:	89 c2                	mov    %eax,%edx
  803841:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803845:	8b 40 0c             	mov    0xc(%rax),%eax
  803848:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  80384c:	b9 00 00 00 00       	mov    $0x0,%ecx
  803851:	89 c7                	mov    %eax,%edi
  803853:	48 b8 8f 3b 80 00 00 	movabs $0x803b8f,%rax
  80385a:	00 00 00 
  80385d:	ff d0                	callq  *%rax
}
  80385f:	c9                   	leaveq 
  803860:	c3                   	retq   

0000000000803861 <devsock_write>:

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803861:	55                   	push   %rbp
  803862:	48 89 e5             	mov    %rsp,%rbp
  803865:	48 83 ec 20          	sub    $0x20,%rsp
  803869:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80386d:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803871:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  803875:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803879:	89 c2                	mov    %eax,%edx
  80387b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80387f:	8b 40 0c             	mov    0xc(%rax),%eax
  803882:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  803886:	b9 00 00 00 00       	mov    $0x0,%ecx
  80388b:	89 c7                	mov    %eax,%edi
  80388d:	48 b8 5b 3c 80 00 00 	movabs $0x803c5b,%rax
  803894:	00 00 00 
  803897:	ff d0                	callq  *%rax
}
  803899:	c9                   	leaveq 
  80389a:	c3                   	retq   

000000000080389b <devsock_stat>:

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80389b:	55                   	push   %rbp
  80389c:	48 89 e5             	mov    %rsp,%rbp
  80389f:	48 83 ec 10          	sub    $0x10,%rsp
  8038a3:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8038a7:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	strcpy(stat->st_name, "<sock>");
  8038ab:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8038af:	48 be 18 4f 80 00 00 	movabs $0x804f18,%rsi
  8038b6:	00 00 00 
  8038b9:	48 89 c7             	mov    %rax,%rdi
  8038bc:	48 b8 6a 10 80 00 00 	movabs $0x80106a,%rax
  8038c3:	00 00 00 
  8038c6:	ff d0                	callq  *%rax
	return 0;
  8038c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8038cd:	c9                   	leaveq 
  8038ce:	c3                   	retq   

00000000008038cf <socket>:

int
socket(int domain, int type, int protocol)
{
  8038cf:	55                   	push   %rbp
  8038d0:	48 89 e5             	mov    %rsp,%rbp
  8038d3:	48 83 ec 20          	sub    $0x20,%rsp
  8038d7:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8038da:	89 75 e8             	mov    %esi,-0x18(%rbp)
  8038dd:	89 55 e4             	mov    %edx,-0x1c(%rbp)
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8038e0:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8038e3:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  8038e6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8038e9:	89 ce                	mov    %ecx,%esi
  8038eb:	89 c7                	mov    %eax,%edi
  8038ed:	48 b8 13 3d 80 00 00 	movabs $0x803d13,%rax
  8038f4:	00 00 00 
  8038f7:	ff d0                	callq  *%rax
  8038f9:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8038fc:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803900:	79 05                	jns    803907 <socket+0x38>
		return r;
  803902:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803905:	eb 11                	jmp    803918 <socket+0x49>
	return alloc_sockfd(r);
  803907:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80390a:	89 c7                	mov    %eax,%edi
  80390c:	48 b8 b1 35 80 00 00 	movabs $0x8035b1,%rax
  803913:	00 00 00 
  803916:	ff d0                	callq  *%rax
}
  803918:	c9                   	leaveq 
  803919:	c3                   	retq   

000000000080391a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80391a:	55                   	push   %rbp
  80391b:	48 89 e5             	mov    %rsp,%rbp
  80391e:	48 83 ec 10          	sub    $0x10,%rsp
  803922:	89 7d fc             	mov    %edi,-0x4(%rbp)
	static envid_t nsenv;
	if (nsenv == 0)
  803925:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  80392c:	00 00 00 
  80392f:	8b 00                	mov    (%rax),%eax
  803931:	85 c0                	test   %eax,%eax
  803933:	75 1d                	jne    803952 <nsipc+0x38>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803935:	bf 02 00 00 00       	mov    $0x2,%edi
  80393a:	48 b8 d4 24 80 00 00 	movabs $0x8024d4,%rax
  803941:	00 00 00 
  803944:	ff d0                	callq  *%rax
  803946:	48 ba 04 70 80 00 00 	movabs $0x807004,%rdx
  80394d:	00 00 00 
  803950:	89 02                	mov    %eax,(%rdx)
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803952:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  803959:	00 00 00 
  80395c:	8b 00                	mov    (%rax),%eax
  80395e:	8b 75 fc             	mov    -0x4(%rbp),%esi
  803961:	b9 07 00 00 00       	mov    $0x7,%ecx
  803966:	48 ba 00 a0 80 00 00 	movabs $0x80a000,%rdx
  80396d:	00 00 00 
  803970:	89 c7                	mov    %eax,%edi
  803972:	48 b8 72 24 80 00 00 	movabs $0x802472,%rax
  803979:	00 00 00 
  80397c:	ff d0                	callq  *%rax
	return ipc_recv(NULL, NULL, NULL);
  80397e:	ba 00 00 00 00       	mov    $0x0,%edx
  803983:	be 00 00 00 00       	mov    $0x0,%esi
  803988:	bf 00 00 00 00       	mov    $0x0,%edi
  80398d:	48 b8 6c 23 80 00 00 	movabs $0x80236c,%rax
  803994:	00 00 00 
  803997:	ff d0                	callq  *%rax
}
  803999:	c9                   	leaveq 
  80399a:	c3                   	retq   

000000000080399b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80399b:	55                   	push   %rbp
  80399c:	48 89 e5             	mov    %rsp,%rbp
  80399f:	48 83 ec 30          	sub    $0x30,%rsp
  8039a3:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8039a6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8039aa:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int r;

	nsipcbuf.accept.req_s = s;
  8039ae:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039b5:	00 00 00 
  8039b8:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8039bb:	89 10                	mov    %edx,(%rax)
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8039bd:	bf 01 00 00 00       	mov    $0x1,%edi
  8039c2:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  8039c9:	00 00 00 
  8039cc:	ff d0                	callq  *%rax
  8039ce:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8039d1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8039d5:	78 3e                	js     803a15 <nsipc_accept+0x7a>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
  8039d7:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039de:	00 00 00 
  8039e1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8039e5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8039e9:	8b 40 10             	mov    0x10(%rax),%eax
  8039ec:	89 c2                	mov    %eax,%edx
  8039ee:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  8039f2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8039f6:	48 89 ce             	mov    %rcx,%rsi
  8039f9:	48 89 c7             	mov    %rax,%rdi
  8039fc:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  803a03:	00 00 00 
  803a06:	ff d0                	callq  *%rax
		*addrlen = ret->ret_addrlen;
  803a08:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803a0c:	8b 50 10             	mov    0x10(%rax),%edx
  803a0f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803a13:	89 10                	mov    %edx,(%rax)
	}
	return r;
  803a15:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  803a18:	c9                   	leaveq 
  803a19:	c3                   	retq   

0000000000803a1a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803a1a:	55                   	push   %rbp
  803a1b:	48 89 e5             	mov    %rsp,%rbp
  803a1e:	48 83 ec 10          	sub    $0x10,%rsp
  803a22:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803a25:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803a29:	89 55 f8             	mov    %edx,-0x8(%rbp)
	nsipcbuf.bind.req_s = s;
  803a2c:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a33:	00 00 00 
  803a36:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803a39:	89 10                	mov    %edx,(%rax)
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803a3b:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803a3e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803a42:	48 89 c6             	mov    %rax,%rsi
  803a45:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  803a4c:	00 00 00 
  803a4f:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  803a56:	00 00 00 
  803a59:	ff d0                	callq  *%rax
	nsipcbuf.bind.req_namelen = namelen;
  803a5b:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a62:	00 00 00 
  803a65:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803a68:	89 50 14             	mov    %edx,0x14(%rax)
	return nsipc(NSREQ_BIND);
  803a6b:	bf 02 00 00 00       	mov    $0x2,%edi
  803a70:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803a77:	00 00 00 
  803a7a:	ff d0                	callq  *%rax
}
  803a7c:	c9                   	leaveq 
  803a7d:	c3                   	retq   

0000000000803a7e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  803a7e:	55                   	push   %rbp
  803a7f:	48 89 e5             	mov    %rsp,%rbp
  803a82:	48 83 ec 10          	sub    $0x10,%rsp
  803a86:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803a89:	89 75 f8             	mov    %esi,-0x8(%rbp)
	nsipcbuf.shutdown.req_s = s;
  803a8c:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a93:	00 00 00 
  803a96:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803a99:	89 10                	mov    %edx,(%rax)
	nsipcbuf.shutdown.req_how = how;
  803a9b:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803aa2:	00 00 00 
  803aa5:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803aa8:	89 50 04             	mov    %edx,0x4(%rax)
	return nsipc(NSREQ_SHUTDOWN);
  803aab:	bf 03 00 00 00       	mov    $0x3,%edi
  803ab0:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803ab7:	00 00 00 
  803aba:	ff d0                	callq  *%rax
}
  803abc:	c9                   	leaveq 
  803abd:	c3                   	retq   

0000000000803abe <nsipc_close>:

int
nsipc_close(int s)
{
  803abe:	55                   	push   %rbp
  803abf:	48 89 e5             	mov    %rsp,%rbp
  803ac2:	48 83 ec 10          	sub    $0x10,%rsp
  803ac6:	89 7d fc             	mov    %edi,-0x4(%rbp)
	nsipcbuf.close.req_s = s;
  803ac9:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803ad0:	00 00 00 
  803ad3:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803ad6:	89 10                	mov    %edx,(%rax)
	return nsipc(NSREQ_CLOSE);
  803ad8:	bf 04 00 00 00       	mov    $0x4,%edi
  803add:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803ae4:	00 00 00 
  803ae7:	ff d0                	callq  *%rax
}
  803ae9:	c9                   	leaveq 
  803aea:	c3                   	retq   

0000000000803aeb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803aeb:	55                   	push   %rbp
  803aec:	48 89 e5             	mov    %rsp,%rbp
  803aef:	48 83 ec 10          	sub    $0x10,%rsp
  803af3:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803af6:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803afa:	89 55 f8             	mov    %edx,-0x8(%rbp)
	nsipcbuf.connect.req_s = s;
  803afd:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b04:	00 00 00 
  803b07:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803b0a:	89 10                	mov    %edx,(%rax)
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803b0c:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803b0f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803b13:	48 89 c6             	mov    %rax,%rsi
  803b16:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  803b1d:	00 00 00 
  803b20:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  803b27:	00 00 00 
  803b2a:	ff d0                	callq  *%rax
	nsipcbuf.connect.req_namelen = namelen;
  803b2c:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b33:	00 00 00 
  803b36:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803b39:	89 50 14             	mov    %edx,0x14(%rax)
	return nsipc(NSREQ_CONNECT);
  803b3c:	bf 05 00 00 00       	mov    $0x5,%edi
  803b41:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803b48:	00 00 00 
  803b4b:	ff d0                	callq  *%rax
}
  803b4d:	c9                   	leaveq 
  803b4e:	c3                   	retq   

0000000000803b4f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803b4f:	55                   	push   %rbp
  803b50:	48 89 e5             	mov    %rsp,%rbp
  803b53:	48 83 ec 10          	sub    $0x10,%rsp
  803b57:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803b5a:	89 75 f8             	mov    %esi,-0x8(%rbp)
	nsipcbuf.listen.req_s = s;
  803b5d:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b64:	00 00 00 
  803b67:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803b6a:	89 10                	mov    %edx,(%rax)
	nsipcbuf.listen.req_backlog = backlog;
  803b6c:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b73:	00 00 00 
  803b76:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803b79:	89 50 04             	mov    %edx,0x4(%rax)
	return nsipc(NSREQ_LISTEN);
  803b7c:	bf 06 00 00 00       	mov    $0x6,%edi
  803b81:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803b88:	00 00 00 
  803b8b:	ff d0                	callq  *%rax
}
  803b8d:	c9                   	leaveq 
  803b8e:	c3                   	retq   

0000000000803b8f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803b8f:	55                   	push   %rbp
  803b90:	48 89 e5             	mov    %rsp,%rbp
  803b93:	48 83 ec 30          	sub    $0x30,%rsp
  803b97:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803b9a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803b9e:	89 55 e8             	mov    %edx,-0x18(%rbp)
  803ba1:	89 4d dc             	mov    %ecx,-0x24(%rbp)
	int r;

	nsipcbuf.recv.req_s = s;
  803ba4:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803bab:	00 00 00 
  803bae:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803bb1:	89 10                	mov    %edx,(%rax)
	nsipcbuf.recv.req_len = len;
  803bb3:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803bba:	00 00 00 
  803bbd:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803bc0:	89 50 04             	mov    %edx,0x4(%rax)
	nsipcbuf.recv.req_flags = flags;
  803bc3:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803bca:	00 00 00 
  803bcd:	8b 55 dc             	mov    -0x24(%rbp),%edx
  803bd0:	89 50 08             	mov    %edx,0x8(%rax)

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803bd3:	bf 07 00 00 00       	mov    $0x7,%edi
  803bd8:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803bdf:	00 00 00 
  803be2:	ff d0                	callq  *%rax
  803be4:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803be7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803beb:	78 69                	js     803c56 <nsipc_recv+0xc7>
		assert(r < 1600 && r <= len);
  803bed:	81 7d fc 3f 06 00 00 	cmpl   $0x63f,-0x4(%rbp)
  803bf4:	7f 08                	jg     803bfe <nsipc_recv+0x6f>
  803bf6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803bf9:	3b 45 e8             	cmp    -0x18(%rbp),%eax
  803bfc:	7e 35                	jle    803c33 <nsipc_recv+0xa4>
  803bfe:	48 b9 1f 4f 80 00 00 	movabs $0x804f1f,%rcx
  803c05:	00 00 00 
  803c08:	48 ba 34 4f 80 00 00 	movabs $0x804f34,%rdx
  803c0f:	00 00 00 
  803c12:	be 61 00 00 00       	mov    $0x61,%esi
  803c17:	48 bf 49 4f 80 00 00 	movabs $0x804f49,%rdi
  803c1e:	00 00 00 
  803c21:	b8 00 00 00 00       	mov    $0x0,%eax
  803c26:	49 b8 7c 02 80 00 00 	movabs $0x80027c,%r8
  803c2d:	00 00 00 
  803c30:	41 ff d0             	callq  *%r8
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803c33:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803c36:	48 63 d0             	movslq %eax,%rdx
  803c39:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803c3d:	48 be 00 a0 80 00 00 	movabs $0x80a000,%rsi
  803c44:	00 00 00 
  803c47:	48 89 c7             	mov    %rax,%rdi
  803c4a:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  803c51:	00 00 00 
  803c54:	ff d0                	callq  *%rax
	}

	return r;
  803c56:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  803c59:	c9                   	leaveq 
  803c5a:	c3                   	retq   

0000000000803c5b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803c5b:	55                   	push   %rbp
  803c5c:	48 89 e5             	mov    %rsp,%rbp
  803c5f:	48 83 ec 20          	sub    $0x20,%rsp
  803c63:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803c66:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803c6a:	89 55 f8             	mov    %edx,-0x8(%rbp)
  803c6d:	89 4d ec             	mov    %ecx,-0x14(%rbp)
	nsipcbuf.send.req_s = s;
  803c70:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803c77:	00 00 00 
  803c7a:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803c7d:	89 10                	mov    %edx,(%rax)
	assert(size < 1600);
  803c7f:	81 7d f8 3f 06 00 00 	cmpl   $0x63f,-0x8(%rbp)
  803c86:	7e 35                	jle    803cbd <nsipc_send+0x62>
  803c88:	48 b9 55 4f 80 00 00 	movabs $0x804f55,%rcx
  803c8f:	00 00 00 
  803c92:	48 ba 34 4f 80 00 00 	movabs $0x804f34,%rdx
  803c99:	00 00 00 
  803c9c:	be 6c 00 00 00       	mov    $0x6c,%esi
  803ca1:	48 bf 49 4f 80 00 00 	movabs $0x804f49,%rdi
  803ca8:	00 00 00 
  803cab:	b8 00 00 00 00       	mov    $0x0,%eax
  803cb0:	49 b8 7c 02 80 00 00 	movabs $0x80027c,%r8
  803cb7:	00 00 00 
  803cba:	41 ff d0             	callq  *%r8
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803cbd:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803cc0:	48 63 d0             	movslq %eax,%rdx
  803cc3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803cc7:	48 89 c6             	mov    %rax,%rsi
  803cca:	48 bf 0c a0 80 00 00 	movabs $0x80a00c,%rdi
  803cd1:	00 00 00 
  803cd4:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  803cdb:	00 00 00 
  803cde:	ff d0                	callq  *%rax
	nsipcbuf.send.req_size = size;
  803ce0:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803ce7:	00 00 00 
  803cea:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803ced:	89 50 04             	mov    %edx,0x4(%rax)
	nsipcbuf.send.req_flags = flags;
  803cf0:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803cf7:	00 00 00 
  803cfa:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803cfd:	89 50 08             	mov    %edx,0x8(%rax)
	return nsipc(NSREQ_SEND);
  803d00:	bf 08 00 00 00       	mov    $0x8,%edi
  803d05:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803d0c:	00 00 00 
  803d0f:	ff d0                	callq  *%rax
}
  803d11:	c9                   	leaveq 
  803d12:	c3                   	retq   

0000000000803d13 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803d13:	55                   	push   %rbp
  803d14:	48 89 e5             	mov    %rsp,%rbp
  803d17:	48 83 ec 10          	sub    $0x10,%rsp
  803d1b:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803d1e:	89 75 f8             	mov    %esi,-0x8(%rbp)
  803d21:	89 55 f4             	mov    %edx,-0xc(%rbp)
	nsipcbuf.socket.req_domain = domain;
  803d24:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803d2b:	00 00 00 
  803d2e:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803d31:	89 10                	mov    %edx,(%rax)
	nsipcbuf.socket.req_type = type;
  803d33:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803d3a:	00 00 00 
  803d3d:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803d40:	89 50 04             	mov    %edx,0x4(%rax)
	nsipcbuf.socket.req_protocol = protocol;
  803d43:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803d4a:	00 00 00 
  803d4d:	8b 55 f4             	mov    -0xc(%rbp),%edx
  803d50:	89 50 08             	mov    %edx,0x8(%rax)
	return nsipc(NSREQ_SOCKET);
  803d53:	bf 09 00 00 00       	mov    $0x9,%edi
  803d58:	48 b8 1a 39 80 00 00 	movabs $0x80391a,%rax
  803d5f:	00 00 00 
  803d62:	ff d0                	callq  *%rax
}
  803d64:	c9                   	leaveq 
  803d65:	c3                   	retq   

0000000000803d66 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803d66:	55                   	push   %rbp
  803d67:	48 89 e5             	mov    %rsp,%rbp
  803d6a:	53                   	push   %rbx
  803d6b:	48 83 ec 38          	sub    $0x38,%rsp
  803d6f:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803d73:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
  803d77:	48 89 c7             	mov    %rax,%rdi
  803d7a:	48 b8 a4 25 80 00 00 	movabs $0x8025a4,%rax
  803d81:	00 00 00 
  803d84:	ff d0                	callq  *%rax
  803d86:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803d89:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803d8d:	0f 88 bf 01 00 00    	js     803f52 <pipe+0x1ec>
            || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803d93:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d97:	ba 07 04 00 00       	mov    $0x407,%edx
  803d9c:	48 89 c6             	mov    %rax,%rsi
  803d9f:	bf 00 00 00 00       	mov    $0x0,%edi
  803da4:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  803dab:	00 00 00 
  803dae:	ff d0                	callq  *%rax
  803db0:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803db3:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803db7:	0f 88 95 01 00 00    	js     803f52 <pipe+0x1ec>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803dbd:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  803dc1:	48 89 c7             	mov    %rax,%rdi
  803dc4:	48 b8 a4 25 80 00 00 	movabs $0x8025a4,%rax
  803dcb:	00 00 00 
  803dce:	ff d0                	callq  *%rax
  803dd0:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803dd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803dd7:	0f 88 5d 01 00 00    	js     803f3a <pipe+0x1d4>
            || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803ddd:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803de1:	ba 07 04 00 00       	mov    $0x407,%edx
  803de6:	48 89 c6             	mov    %rax,%rsi
  803de9:	bf 00 00 00 00       	mov    $0x0,%edi
  803dee:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  803df5:	00 00 00 
  803df8:	ff d0                	callq  *%rax
  803dfa:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803dfd:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803e01:	0f 88 33 01 00 00    	js     803f3a <pipe+0x1d4>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803e07:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803e0b:	48 89 c7             	mov    %rax,%rdi
  803e0e:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  803e15:	00 00 00 
  803e18:	ff d0                	callq  *%rax
  803e1a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803e1e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803e22:	ba 07 04 00 00       	mov    $0x407,%edx
  803e27:	48 89 c6             	mov    %rax,%rsi
  803e2a:	bf 00 00 00 00       	mov    $0x0,%edi
  803e2f:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  803e36:	00 00 00 
  803e39:	ff d0                	callq  *%rax
  803e3b:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803e3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803e42:	79 05                	jns    803e49 <pipe+0xe3>
		goto err2;
  803e44:	e9 d9 00 00 00       	jmpq   803f22 <pipe+0x1bc>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803e49:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803e4d:	48 89 c7             	mov    %rax,%rdi
  803e50:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  803e57:	00 00 00 
  803e5a:	ff d0                	callq  *%rax
  803e5c:	48 89 c2             	mov    %rax,%rdx
  803e5f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803e63:	41 b8 07 04 00 00    	mov    $0x407,%r8d
  803e69:	48 89 d1             	mov    %rdx,%rcx
  803e6c:	ba 00 00 00 00       	mov    $0x0,%edx
  803e71:	48 89 c6             	mov    %rax,%rsi
  803e74:	bf 00 00 00 00       	mov    $0x0,%edi
  803e79:	48 b8 e9 19 80 00 00 	movabs $0x8019e9,%rax
  803e80:	00 00 00 
  803e83:	ff d0                	callq  *%rax
  803e85:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803e88:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803e8c:	79 1b                	jns    803ea9 <pipe+0x143>
		goto err3;
  803e8e:	90                   	nop
	pfd[0] = fd2num(fd0);
	pfd[1] = fd2num(fd1);
	return 0;

err3:
	sys_page_unmap(0, va);
  803e8f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803e93:	48 89 c6             	mov    %rax,%rsi
  803e96:	bf 00 00 00 00       	mov    $0x0,%edi
  803e9b:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  803ea2:	00 00 00 
  803ea5:	ff d0                	callq  *%rax
  803ea7:	eb 79                	jmp    803f22 <pipe+0x1bc>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803ea9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803ead:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803eb4:	00 00 00 
  803eb7:	8b 12                	mov    (%rdx),%edx
  803eb9:	89 10                	mov    %edx,(%rax)
	fd0->fd_omode = O_RDONLY;
  803ebb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803ebf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%rax)

	fd1->fd_dev_id = devpipe.dev_id;
  803ec6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803eca:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803ed1:	00 00 00 
  803ed4:	8b 12                	mov    (%rdx),%edx
  803ed6:	89 10                	mov    %edx,(%rax)
	fd1->fd_omode = O_WRONLY;
  803ed8:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803edc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%rax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803ee3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803ee7:	48 89 c7             	mov    %rax,%rdi
  803eea:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  803ef1:	00 00 00 
  803ef4:	ff d0                	callq  *%rax
  803ef6:	89 c2                	mov    %eax,%edx
  803ef8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803efc:	89 10                	mov    %edx,(%rax)
	pfd[1] = fd2num(fd1);
  803efe:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803f02:	48 8d 58 04          	lea    0x4(%rax),%rbx
  803f06:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803f0a:	48 89 c7             	mov    %rax,%rdi
  803f0d:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  803f14:	00 00 00 
  803f17:	ff d0                	callq  *%rax
  803f19:	89 03                	mov    %eax,(%rbx)
	return 0;
  803f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  803f20:	eb 33                	jmp    803f55 <pipe+0x1ef>

err3:
	sys_page_unmap(0, va);
err2:
	sys_page_unmap(0, fd1);
  803f22:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803f26:	48 89 c6             	mov    %rax,%rsi
  803f29:	bf 00 00 00 00       	mov    $0x0,%edi
  803f2e:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  803f35:	00 00 00 
  803f38:	ff d0                	callq  *%rax
err1:
	sys_page_unmap(0, fd0);
  803f3a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803f3e:	48 89 c6             	mov    %rax,%rsi
  803f41:	bf 00 00 00 00       	mov    $0x0,%edi
  803f46:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  803f4d:	00 00 00 
  803f50:	ff d0                	callq  *%rax
err:
	return r;
  803f52:	8b 45 ec             	mov    -0x14(%rbp),%eax
}
  803f55:	48 83 c4 38          	add    $0x38,%rsp
  803f59:	5b                   	pop    %rbx
  803f5a:	5d                   	pop    %rbp
  803f5b:	c3                   	retq   

0000000000803f5c <_pipeisclosed>:

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803f5c:	55                   	push   %rbp
  803f5d:	48 89 e5             	mov    %rsp,%rbp
  803f60:	53                   	push   %rbx
  803f61:	48 83 ec 28          	sub    $0x28,%rsp
  803f65:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803f69:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803f6d:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803f74:	00 00 00 
  803f77:	48 8b 00             	mov    (%rax),%rax
  803f7a:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
  803f80:	89 45 ec             	mov    %eax,-0x14(%rbp)
		ret = pageref(fd) == pageref(p);
  803f83:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803f87:	48 89 c7             	mov    %rax,%rdi
  803f8a:	48 b8 22 47 80 00 00 	movabs $0x804722,%rax
  803f91:	00 00 00 
  803f94:	ff d0                	callq  *%rax
  803f96:	89 c3                	mov    %eax,%ebx
  803f98:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803f9c:	48 89 c7             	mov    %rax,%rdi
  803f9f:	48 b8 22 47 80 00 00 	movabs $0x804722,%rax
  803fa6:	00 00 00 
  803fa9:	ff d0                	callq  *%rax
  803fab:	39 c3                	cmp    %eax,%ebx
  803fad:	0f 94 c0             	sete   %al
  803fb0:	0f b6 c0             	movzbl %al,%eax
  803fb3:	89 45 e8             	mov    %eax,-0x18(%rbp)
		nn = thisenv->env_runs;
  803fb6:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803fbd:	00 00 00 
  803fc0:	48 8b 00             	mov    (%rax),%rax
  803fc3:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
  803fc9:	89 45 e4             	mov    %eax,-0x1c(%rbp)
		if (n == nn)
  803fcc:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803fcf:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803fd2:	75 05                	jne    803fd9 <_pipeisclosed+0x7d>
			return ret;
  803fd4:	8b 45 e8             	mov    -0x18(%rbp),%eax
  803fd7:	eb 4f                	jmp    804028 <_pipeisclosed+0xcc>
		if (n != nn && ret == 1)
  803fd9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803fdc:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803fdf:	74 42                	je     804023 <_pipeisclosed+0xc7>
  803fe1:	83 7d e8 01          	cmpl   $0x1,-0x18(%rbp)
  803fe5:	75 3c                	jne    804023 <_pipeisclosed+0xc7>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803fe7:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803fee:	00 00 00 
  803ff1:	48 8b 00             	mov    (%rax),%rax
  803ff4:	8b 90 d8 00 00 00    	mov    0xd8(%rax),%edx
  803ffa:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  803ffd:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804000:	89 c6                	mov    %eax,%esi
  804002:	48 bf 66 4f 80 00 00 	movabs $0x804f66,%rdi
  804009:	00 00 00 
  80400c:	b8 00 00 00 00       	mov    $0x0,%eax
  804011:	49 b8 b5 04 80 00 00 	movabs $0x8004b5,%r8
  804018:	00 00 00 
  80401b:	41 ff d0             	callq  *%r8
	}
  80401e:	e9 4a ff ff ff       	jmpq   803f6d <_pipeisclosed+0x11>
  804023:	e9 45 ff ff ff       	jmpq   803f6d <_pipeisclosed+0x11>
}
  804028:	48 83 c4 28          	add    $0x28,%rsp
  80402c:	5b                   	pop    %rbx
  80402d:	5d                   	pop    %rbp
  80402e:	c3                   	retq   

000000000080402f <pipeisclosed>:

int
pipeisclosed(int fdnum)
{
  80402f:	55                   	push   %rbp
  804030:	48 89 e5             	mov    %rsp,%rbp
  804033:	48 83 ec 30          	sub    $0x30,%rsp
  804037:	89 7d dc             	mov    %edi,-0x24(%rbp)
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80403a:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80403e:	8b 45 dc             	mov    -0x24(%rbp),%eax
  804041:	48 89 d6             	mov    %rdx,%rsi
  804044:	89 c7                	mov    %eax,%edi
  804046:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  80404d:	00 00 00 
  804050:	ff d0                	callq  *%rax
  804052:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804055:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804059:	79 05                	jns    804060 <pipeisclosed+0x31>
		return r;
  80405b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80405e:	eb 31                	jmp    804091 <pipeisclosed+0x62>
	p = (struct Pipe*) fd2data(fd);
  804060:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804064:	48 89 c7             	mov    %rax,%rdi
  804067:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  80406e:	00 00 00 
  804071:	ff d0                	callq  *%rax
  804073:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	return _pipeisclosed(fd, p);
  804077:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80407b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80407f:	48 89 d6             	mov    %rdx,%rsi
  804082:	48 89 c7             	mov    %rax,%rdi
  804085:	48 b8 5c 3f 80 00 00 	movabs $0x803f5c,%rax
  80408c:	00 00 00 
  80408f:	ff d0                	callq  *%rax
}
  804091:	c9                   	leaveq 
  804092:	c3                   	retq   

0000000000804093 <devpipe_read>:

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  804093:	55                   	push   %rbp
  804094:	48 89 e5             	mov    %rsp,%rbp
  804097:	48 83 ec 40          	sub    $0x40,%rsp
  80409b:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80409f:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8040a3:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8040a7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8040ab:	48 89 c7             	mov    %rax,%rdi
  8040ae:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  8040b5:	00 00 00 
  8040b8:	ff d0                	callq  *%rax
  8040ba:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8040be:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8040c2:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	for (i = 0; i < n; i++) {
  8040c6:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8040cd:	00 
  8040ce:	e9 92 00 00 00       	jmpq   804165 <devpipe_read+0xd2>
		while (p->p_rpos == p->p_wpos) {
  8040d3:	eb 41                	jmp    804116 <devpipe_read+0x83>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8040d5:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8040da:	74 09                	je     8040e5 <devpipe_read+0x52>
				return i;
  8040dc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8040e0:	e9 92 00 00 00       	jmpq   804177 <devpipe_read+0xe4>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8040e5:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8040e9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8040ed:	48 89 d6             	mov    %rdx,%rsi
  8040f0:	48 89 c7             	mov    %rax,%rdi
  8040f3:	48 b8 5c 3f 80 00 00 	movabs $0x803f5c,%rax
  8040fa:	00 00 00 
  8040fd:	ff d0                	callq  *%rax
  8040ff:	85 c0                	test   %eax,%eax
  804101:	74 07                	je     80410a <devpipe_read+0x77>
				return 0;
  804103:	b8 00 00 00 00       	mov    $0x0,%eax
  804108:	eb 6d                	jmp    804177 <devpipe_read+0xe4>
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80410a:	48 b8 5b 19 80 00 00 	movabs $0x80195b,%rax
  804111:	00 00 00 
  804114:	ff d0                	callq  *%rax
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  804116:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80411a:	8b 10                	mov    (%rax),%edx
  80411c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804120:	8b 40 04             	mov    0x4(%rax),%eax
  804123:	39 c2                	cmp    %eax,%edx
  804125:	74 ae                	je     8040d5 <devpipe_read+0x42>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  804127:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80412b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80412f:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  804133:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804137:	8b 00                	mov    (%rax),%eax
  804139:	99                   	cltd   
  80413a:	c1 ea 1b             	shr    $0x1b,%edx
  80413d:	01 d0                	add    %edx,%eax
  80413f:	83 e0 1f             	and    $0x1f,%eax
  804142:	29 d0                	sub    %edx,%eax
  804144:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  804148:	48 98                	cltq   
  80414a:	0f b6 44 02 08       	movzbl 0x8(%rdx,%rax,1),%eax
  80414f:	88 01                	mov    %al,(%rcx)
		p->p_rpos++;
  804151:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804155:	8b 00                	mov    (%rax),%eax
  804157:	8d 50 01             	lea    0x1(%rax),%edx
  80415a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80415e:	89 10                	mov    %edx,(%rax)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  804160:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  804165:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804169:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80416d:	0f 82 60 ff ff ff    	jb     8040d3 <devpipe_read+0x40>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  804173:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  804177:	c9                   	leaveq 
  804178:	c3                   	retq   

0000000000804179 <devpipe_write>:

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  804179:	55                   	push   %rbp
  80417a:	48 89 e5             	mov    %rsp,%rbp
  80417d:	48 83 ec 40          	sub    $0x40,%rsp
  804181:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  804185:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  804189:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80418d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804191:	48 89 c7             	mov    %rax,%rdi
  804194:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  80419b:	00 00 00 
  80419e:	ff d0                	callq  *%rax
  8041a0:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8041a4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8041a8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	for (i = 0; i < n; i++) {
  8041ac:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8041b3:	00 
  8041b4:	e9 8e 00 00 00       	jmpq   804247 <devpipe_write+0xce>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8041b9:	eb 31                	jmp    8041ec <devpipe_write+0x73>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8041bb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8041bf:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8041c3:	48 89 d6             	mov    %rdx,%rsi
  8041c6:	48 89 c7             	mov    %rax,%rdi
  8041c9:	48 b8 5c 3f 80 00 00 	movabs $0x803f5c,%rax
  8041d0:	00 00 00 
  8041d3:	ff d0                	callq  *%rax
  8041d5:	85 c0                	test   %eax,%eax
  8041d7:	74 07                	je     8041e0 <devpipe_write+0x67>
				return 0;
  8041d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041de:	eb 79                	jmp    804259 <devpipe_write+0xe0>
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8041e0:	48 b8 5b 19 80 00 00 	movabs $0x80195b,%rax
  8041e7:	00 00 00 
  8041ea:	ff d0                	callq  *%rax
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8041ec:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8041f0:	8b 40 04             	mov    0x4(%rax),%eax
  8041f3:	48 63 d0             	movslq %eax,%rdx
  8041f6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8041fa:	8b 00                	mov    (%rax),%eax
  8041fc:	48 98                	cltq   
  8041fe:	48 83 c0 20          	add    $0x20,%rax
  804202:	48 39 c2             	cmp    %rax,%rdx
  804205:	73 b4                	jae    8041bb <devpipe_write+0x42>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  804207:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80420b:	8b 40 04             	mov    0x4(%rax),%eax
  80420e:	99                   	cltd   
  80420f:	c1 ea 1b             	shr    $0x1b,%edx
  804212:	01 d0                	add    %edx,%eax
  804214:	83 e0 1f             	and    $0x1f,%eax
  804217:	29 d0                	sub    %edx,%eax
  804219:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80421d:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  804221:	48 01 ca             	add    %rcx,%rdx
  804224:	0f b6 0a             	movzbl (%rdx),%ecx
  804227:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80422b:	48 98                	cltq   
  80422d:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
		p->p_wpos++;
  804231:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804235:	8b 40 04             	mov    0x4(%rax),%eax
  804238:	8d 50 01             	lea    0x1(%rax),%edx
  80423b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80423f:	89 50 04             	mov    %edx,0x4(%rax)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  804242:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  804247:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80424b:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80424f:	0f 82 64 ff ff ff    	jb     8041b9 <devpipe_write+0x40>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  804255:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  804259:	c9                   	leaveq 
  80425a:	c3                   	retq   

000000000080425b <devpipe_stat>:

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80425b:	55                   	push   %rbp
  80425c:	48 89 e5             	mov    %rsp,%rbp
  80425f:	48 83 ec 20          	sub    $0x20,%rsp
  804263:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804267:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80426b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80426f:	48 89 c7             	mov    %rax,%rdi
  804272:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  804279:	00 00 00 
  80427c:	ff d0                	callq  *%rax
  80427e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	strcpy(stat->st_name, "<pipe>");
  804282:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804286:	48 be 79 4f 80 00 00 	movabs $0x804f79,%rsi
  80428d:	00 00 00 
  804290:	48 89 c7             	mov    %rax,%rdi
  804293:	48 b8 6a 10 80 00 00 	movabs $0x80106a,%rax
  80429a:	00 00 00 
  80429d:	ff d0                	callq  *%rax
	stat->st_size = p->p_wpos - p->p_rpos;
  80429f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8042a3:	8b 50 04             	mov    0x4(%rax),%edx
  8042a6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8042aa:	8b 00                	mov    (%rax),%eax
  8042ac:	29 c2                	sub    %eax,%edx
  8042ae:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8042b2:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
	stat->st_isdir = 0;
  8042b8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8042bc:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  8042c3:	00 00 00 
	stat->st_dev = &devpipe;
  8042c6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8042ca:	48 b9 e0 60 80 00 00 	movabs $0x8060e0,%rcx
  8042d1:	00 00 00 
  8042d4:	48 89 88 88 00 00 00 	mov    %rcx,0x88(%rax)
	return 0;
  8042db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8042e0:	c9                   	leaveq 
  8042e1:	c3                   	retq   

00000000008042e2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8042e2:	55                   	push   %rbp
  8042e3:	48 89 e5             	mov    %rsp,%rbp
  8042e6:	48 83 ec 10          	sub    $0x10,%rsp
  8042ea:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	(void) sys_page_unmap(0, fd);
  8042ee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8042f2:	48 89 c6             	mov    %rax,%rsi
  8042f5:	bf 00 00 00 00       	mov    $0x0,%edi
  8042fa:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  804301:	00 00 00 
  804304:	ff d0                	callq  *%rax
	return sys_page_unmap(0, fd2data(fd));
  804306:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80430a:	48 89 c7             	mov    %rax,%rdi
  80430d:	48 b8 79 25 80 00 00 	movabs $0x802579,%rax
  804314:	00 00 00 
  804317:	ff d0                	callq  *%rax
  804319:	48 89 c6             	mov    %rax,%rsi
  80431c:	bf 00 00 00 00       	mov    $0x0,%edi
  804321:	48 b8 44 1a 80 00 00 	movabs $0x801a44,%rax
  804328:	00 00 00 
  80432b:	ff d0                	callq  *%rax
}
  80432d:	c9                   	leaveq 
  80432e:	c3                   	retq   

000000000080432f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80432f:	55                   	push   %rbp
  804330:	48 89 e5             	mov    %rsp,%rbp
  804333:	48 83 ec 20          	sub    $0x20,%rsp
  804337:	89 7d ec             	mov    %edi,-0x14(%rbp)
	char c = ch;
  80433a:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80433d:	88 45 ff             	mov    %al,-0x1(%rbp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  804340:	48 8d 45 ff          	lea    -0x1(%rbp),%rax
  804344:	be 01 00 00 00       	mov    $0x1,%esi
  804349:	48 89 c7             	mov    %rax,%rdi
  80434c:	48 b8 51 18 80 00 00 	movabs $0x801851,%rax
  804353:	00 00 00 
  804356:	ff d0                	callq  *%rax
}
  804358:	c9                   	leaveq 
  804359:	c3                   	retq   

000000000080435a <getchar>:

int
getchar(void)
{
  80435a:	55                   	push   %rbp
  80435b:	48 89 e5             	mov    %rsp,%rbp
  80435e:	48 83 ec 10          	sub    $0x10,%rsp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  804362:	48 8d 45 fb          	lea    -0x5(%rbp),%rax
  804366:	ba 01 00 00 00       	mov    $0x1,%edx
  80436b:	48 89 c6             	mov    %rax,%rsi
  80436e:	bf 00 00 00 00       	mov    $0x0,%edi
  804373:	48 b8 6e 2a 80 00 00 	movabs $0x802a6e,%rax
  80437a:	00 00 00 
  80437d:	ff d0                	callq  *%rax
  80437f:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if (r < 0)
  804382:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804386:	79 05                	jns    80438d <getchar+0x33>
		return r;
  804388:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80438b:	eb 14                	jmp    8043a1 <getchar+0x47>
	if (r < 1)
  80438d:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804391:	7f 07                	jg     80439a <getchar+0x40>
		return -E_EOF;
  804393:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  804398:	eb 07                	jmp    8043a1 <getchar+0x47>
	return c;
  80439a:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  80439e:	0f b6 c0             	movzbl %al,%eax
}
  8043a1:	c9                   	leaveq 
  8043a2:	c3                   	retq   

00000000008043a3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8043a3:	55                   	push   %rbp
  8043a4:	48 89 e5             	mov    %rsp,%rbp
  8043a7:	48 83 ec 20          	sub    $0x20,%rsp
  8043ab:	89 7d ec             	mov    %edi,-0x14(%rbp)
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8043ae:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8043b2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8043b5:	48 89 d6             	mov    %rdx,%rsi
  8043b8:	89 c7                	mov    %eax,%edi
  8043ba:	48 b8 3c 26 80 00 00 	movabs $0x80263c,%rax
  8043c1:	00 00 00 
  8043c4:	ff d0                	callq  *%rax
  8043c6:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8043c9:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8043cd:	79 05                	jns    8043d4 <iscons+0x31>
		return r;
  8043cf:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8043d2:	eb 1a                	jmp    8043ee <iscons+0x4b>
	return fd->fd_dev_id == devcons.dev_id;
  8043d4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8043d8:	8b 10                	mov    (%rax),%edx
  8043da:	48 b8 20 61 80 00 00 	movabs $0x806120,%rax
  8043e1:	00 00 00 
  8043e4:	8b 00                	mov    (%rax),%eax
  8043e6:	39 c2                	cmp    %eax,%edx
  8043e8:	0f 94 c0             	sete   %al
  8043eb:	0f b6 c0             	movzbl %al,%eax
}
  8043ee:	c9                   	leaveq 
  8043ef:	c3                   	retq   

00000000008043f0 <opencons>:

int
opencons(void)
{
  8043f0:	55                   	push   %rbp
  8043f1:	48 89 e5             	mov    %rsp,%rbp
  8043f4:	48 83 ec 10          	sub    $0x10,%rsp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8043f8:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  8043fc:	48 89 c7             	mov    %rax,%rdi
  8043ff:	48 b8 a4 25 80 00 00 	movabs $0x8025a4,%rax
  804406:	00 00 00 
  804409:	ff d0                	callq  *%rax
  80440b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80440e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804412:	79 05                	jns    804419 <opencons+0x29>
		return r;
  804414:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804417:	eb 5b                	jmp    804474 <opencons+0x84>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  804419:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80441d:	ba 07 04 00 00       	mov    $0x407,%edx
  804422:	48 89 c6             	mov    %rax,%rsi
  804425:	bf 00 00 00 00       	mov    $0x0,%edi
  80442a:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  804431:	00 00 00 
  804434:	ff d0                	callq  *%rax
  804436:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804439:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80443d:	79 05                	jns    804444 <opencons+0x54>
		return r;
  80443f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804442:	eb 30                	jmp    804474 <opencons+0x84>
	fd->fd_dev_id = devcons.dev_id;
  804444:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804448:	48 ba 20 61 80 00 00 	movabs $0x806120,%rdx
  80444f:	00 00 00 
  804452:	8b 12                	mov    (%rdx),%edx
  804454:	89 10                	mov    %edx,(%rax)
	fd->fd_omode = O_RDWR;
  804456:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80445a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
	return fd2num(fd);
  804461:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804465:	48 89 c7             	mov    %rax,%rdi
  804468:	48 b8 56 25 80 00 00 	movabs $0x802556,%rax
  80446f:	00 00 00 
  804472:	ff d0                	callq  *%rax
}
  804474:	c9                   	leaveq 
  804475:	c3                   	retq   

0000000000804476 <devcons_read>:

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  804476:	55                   	push   %rbp
  804477:	48 89 e5             	mov    %rsp,%rbp
  80447a:	48 83 ec 30          	sub    $0x30,%rsp
  80447e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804482:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  804486:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int c;

	if (n == 0)
  80448a:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80448f:	75 07                	jne    804498 <devcons_read+0x22>
		return 0;
  804491:	b8 00 00 00 00       	mov    $0x0,%eax
  804496:	eb 4b                	jmp    8044e3 <devcons_read+0x6d>

	while ((c = sys_cgetc()) == 0)
  804498:	eb 0c                	jmp    8044a6 <devcons_read+0x30>
		sys_yield();
  80449a:	48 b8 5b 19 80 00 00 	movabs $0x80195b,%rax
  8044a1:	00 00 00 
  8044a4:	ff d0                	callq  *%rax
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8044a6:	48 b8 9b 18 80 00 00 	movabs $0x80189b,%rax
  8044ad:	00 00 00 
  8044b0:	ff d0                	callq  *%rax
  8044b2:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8044b5:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8044b9:	74 df                	je     80449a <devcons_read+0x24>
		sys_yield();
	if (c < 0)
  8044bb:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8044bf:	79 05                	jns    8044c6 <devcons_read+0x50>
		return c;
  8044c1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8044c4:	eb 1d                	jmp    8044e3 <devcons_read+0x6d>
	if (c == 0x04)	// ctl-d is eof
  8044c6:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  8044ca:	75 07                	jne    8044d3 <devcons_read+0x5d>
		return 0;
  8044cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8044d1:	eb 10                	jmp    8044e3 <devcons_read+0x6d>
	*(char*)vbuf = c;
  8044d3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8044d6:	89 c2                	mov    %eax,%edx
  8044d8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8044dc:	88 10                	mov    %dl,(%rax)
	return 1;
  8044de:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8044e3:	c9                   	leaveq 
  8044e4:	c3                   	retq   

00000000008044e5 <devcons_write>:

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8044e5:	55                   	push   %rbp
  8044e6:	48 89 e5             	mov    %rsp,%rbp
  8044e9:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  8044f0:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  8044f7:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  8044fe:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  804505:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80450c:	eb 76                	jmp    804584 <devcons_write+0x9f>
		m = n - tot;
  80450e:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  804515:	89 c2                	mov    %eax,%edx
  804517:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80451a:	29 c2                	sub    %eax,%edx
  80451c:	89 d0                	mov    %edx,%eax
  80451e:	89 45 f8             	mov    %eax,-0x8(%rbp)
		if (m > sizeof(buf) - 1)
  804521:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804524:	83 f8 7f             	cmp    $0x7f,%eax
  804527:	76 07                	jbe    804530 <devcons_write+0x4b>
			m = sizeof(buf) - 1;
  804529:	c7 45 f8 7f 00 00 00 	movl   $0x7f,-0x8(%rbp)
		memmove(buf, (char*)vbuf + tot, m);
  804530:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804533:	48 63 d0             	movslq %eax,%rdx
  804536:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804539:	48 63 c8             	movslq %eax,%rcx
  80453c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  804543:	48 01 c1             	add    %rax,%rcx
  804546:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  80454d:	48 89 ce             	mov    %rcx,%rsi
  804550:	48 89 c7             	mov    %rax,%rdi
  804553:	48 b8 8e 13 80 00 00 	movabs $0x80138e,%rax
  80455a:	00 00 00 
  80455d:	ff d0                	callq  *%rax
		sys_cputs(buf, m);
  80455f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804562:	48 63 d0             	movslq %eax,%rdx
  804565:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  80456c:	48 89 d6             	mov    %rdx,%rsi
  80456f:	48 89 c7             	mov    %rax,%rdi
  804572:	48 b8 51 18 80 00 00 	movabs $0x801851,%rax
  804579:	00 00 00 
  80457c:	ff d0                	callq  *%rax
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80457e:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804581:	01 45 fc             	add    %eax,-0x4(%rbp)
  804584:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804587:	48 98                	cltq   
  804589:	48 3b 85 58 ff ff ff 	cmp    -0xa8(%rbp),%rax
  804590:	0f 82 78 ff ff ff    	jb     80450e <devcons_write+0x29>
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
  804596:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  804599:	c9                   	leaveq 
  80459a:	c3                   	retq   

000000000080459b <devcons_close>:

static int
devcons_close(struct Fd *fd)
{
  80459b:	55                   	push   %rbp
  80459c:	48 89 e5             	mov    %rsp,%rbp
  80459f:	48 83 ec 08          	sub    $0x8,%rsp
  8045a3:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	USED(fd);

	return 0;
  8045a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8045ac:	c9                   	leaveq 
  8045ad:	c3                   	retq   

00000000008045ae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8045ae:	55                   	push   %rbp
  8045af:	48 89 e5             	mov    %rsp,%rbp
  8045b2:	48 83 ec 10          	sub    $0x10,%rsp
  8045b6:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8045ba:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	strcpy(stat->st_name, "<cons>");
  8045be:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8045c2:	48 be 85 4f 80 00 00 	movabs $0x804f85,%rsi
  8045c9:	00 00 00 
  8045cc:	48 89 c7             	mov    %rax,%rdi
  8045cf:	48 b8 6a 10 80 00 00 	movabs $0x80106a,%rax
  8045d6:	00 00 00 
  8045d9:	ff d0                	callq  *%rax
	return 0;
  8045db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8045e0:	c9                   	leaveq 
  8045e1:	c3                   	retq   

00000000008045e2 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.


void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8045e2:	55                   	push   %rbp
  8045e3:	48 89 e5             	mov    %rsp,%rbp
  8045e6:	48 83 ec 10          	sub    $0x10,%rsp
  8045ea:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
        int r;
        //struct Env *thisenv = NULL;
        if (_pgfault_handler == 0) {
  8045ee:	48 b8 00 b0 80 00 00 	movabs $0x80b000,%rax
  8045f5:	00 00 00 
  8045f8:	48 8b 00             	mov    (%rax),%rax
  8045fb:	48 85 c0             	test   %rax,%rax
  8045fe:	0f 85 84 00 00 00    	jne    804688 <set_pgfault_handler+0xa6>
                // First time through!
                // LAB 4: Your code here.
                //cprintf("Inside set_pgfault_handler");
                if(0> sys_page_alloc(thisenv->env_id, (void*)UXSTACKTOP - PGSIZE,PTE_U|PTE_P|PTE_W)){
  804604:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80460b:	00 00 00 
  80460e:	48 8b 00             	mov    (%rax),%rax
  804611:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  804617:	ba 07 00 00 00       	mov    $0x7,%edx
  80461c:	be 00 f0 7f ef       	mov    $0xef7ff000,%esi
  804621:	89 c7                	mov    %eax,%edi
  804623:	48 b8 99 19 80 00 00 	movabs $0x801999,%rax
  80462a:	00 00 00 
  80462d:	ff d0                	callq  *%rax
  80462f:	85 c0                	test   %eax,%eax
  804631:	79 2a                	jns    80465d <set_pgfault_handler+0x7b>
                        panic("Page not available for exception stack");
  804633:	48 ba 90 4f 80 00 00 	movabs $0x804f90,%rdx
  80463a:	00 00 00 
  80463d:	be 23 00 00 00       	mov    $0x23,%esi
  804642:	48 bf b7 4f 80 00 00 	movabs $0x804fb7,%rdi
  804649:	00 00 00 
  80464c:	b8 00 00 00 00       	mov    $0x0,%eax
  804651:	48 b9 7c 02 80 00 00 	movabs $0x80027c,%rcx
  804658:	00 00 00 
  80465b:	ff d1                	callq  *%rcx
                }
                sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  80465d:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804664:	00 00 00 
  804667:	48 8b 00             	mov    (%rax),%rax
  80466a:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  804670:	48 be 9b 46 80 00 00 	movabs $0x80469b,%rsi
  804677:	00 00 00 
  80467a:	89 c7                	mov    %eax,%edi
  80467c:	48 b8 23 1b 80 00 00 	movabs $0x801b23,%rax
  804683:	00 00 00 
  804686:	ff d0                	callq  *%rax
				
               // sys_env_set_pgfault_upcall(thisenv->env_id,handler);
        }

        // Save handler pointer for assembly to call.
        _pgfault_handler = handler;
  804688:	48 b8 00 b0 80 00 00 	movabs $0x80b000,%rax
  80468f:	00 00 00 
  804692:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  804696:	48 89 10             	mov    %rdx,(%rax)
}
  804699:	c9                   	leaveq 
  80469a:	c3                   	retq   

000000000080469b <_pgfault_upcall>:
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
// function argument: pointer to UTF

movq  %rsp,%rdi                // passing the function argument in rdi
  80469b:	48 89 e7             	mov    %rsp,%rdi
movabs _pgfault_handler, %rax
  80469e:	48 a1 00 b0 80 00 00 	movabs 0x80b000,%rax
  8046a5:	00 00 00 
call *%rax
  8046a8:	ff d0                	callq  *%rax
    // LAB 4: Your code here.

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.

	movq 136(%rsp), %rbx  //Load RIP 
  8046aa:	48 8b 9c 24 88 00 00 	mov    0x88(%rsp),%rbx
  8046b1:	00 
	movq 152(%rsp), %rcx  //Load RSP
  8046b2:	48 8b 8c 24 98 00 00 	mov    0x98(%rsp),%rcx
  8046b9:	00 
	//Move pointer on the stack and save the RIP on trap time stack 
	subq $8, %rcx          
  8046ba:	48 83 e9 08          	sub    $0x8,%rcx
	movq %rbx, (%rcx) 
  8046be:	48 89 19             	mov    %rbx,(%rcx)
	//Now update value of trap time stack rsp after pushing rip in UXSTACKTOP
	movq %rcx, 152(%rsp)
  8046c1:	48 89 8c 24 98 00 00 	mov    %rcx,0x98(%rsp)
  8046c8:	00 
	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addq $16,%rsp
  8046c9:	48 83 c4 10          	add    $0x10,%rsp
	POPA_ 
  8046cd:	4c 8b 3c 24          	mov    (%rsp),%r15
  8046d1:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
  8046d6:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
  8046db:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
  8046e0:	4c 8b 5c 24 20       	mov    0x20(%rsp),%r11
  8046e5:	4c 8b 54 24 28       	mov    0x28(%rsp),%r10
  8046ea:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
  8046ef:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
  8046f4:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
  8046f9:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
  8046fe:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  804703:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
  804708:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
  80470d:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  804712:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
  804717:	48 83 c4 78          	add    $0x78,%rsp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addq $8, %rsp
  80471b:	48 83 c4 08          	add    $0x8,%rsp
	popfq
  80471f:	9d                   	popfq  
	
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popq %rsp
  804720:	5c                   	pop    %rsp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  804721:	c3                   	retq   

0000000000804722 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  804722:	55                   	push   %rbp
  804723:	48 89 e5             	mov    %rsp,%rbp
  804726:	48 83 ec 18          	sub    $0x18,%rsp
  80472a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	pte_t pte;

	if (!(uvpd[VPD(v)] & PTE_P))
  80472e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804732:	48 c1 e8 15          	shr    $0x15,%rax
  804736:	48 89 c2             	mov    %rax,%rdx
  804739:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  804740:	01 00 00 
  804743:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  804747:	83 e0 01             	and    $0x1,%eax
  80474a:	48 85 c0             	test   %rax,%rax
  80474d:	75 07                	jne    804756 <pageref+0x34>
		return 0;
  80474f:	b8 00 00 00 00       	mov    $0x0,%eax
  804754:	eb 53                	jmp    8047a9 <pageref+0x87>
	pte = uvpt[PGNUM(v)];
  804756:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80475a:	48 c1 e8 0c          	shr    $0xc,%rax
  80475e:	48 89 c2             	mov    %rax,%rdx
  804761:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  804768:	01 00 00 
  80476b:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80476f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (!(pte & PTE_P))
  804773:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804777:	83 e0 01             	and    $0x1,%eax
  80477a:	48 85 c0             	test   %rax,%rax
  80477d:	75 07                	jne    804786 <pageref+0x64>
		return 0;
  80477f:	b8 00 00 00 00       	mov    $0x0,%eax
  804784:	eb 23                	jmp    8047a9 <pageref+0x87>
	return pages[PPN(pte)].pp_ref;
  804786:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80478a:	48 c1 e8 0c          	shr    $0xc,%rax
  80478e:	48 89 c2             	mov    %rax,%rdx
  804791:	48 b8 00 00 a0 00 80 	movabs $0x8000a00000,%rax
  804798:	00 00 00 
  80479b:	48 c1 e2 04          	shl    $0x4,%rdx
  80479f:	48 01 d0             	add    %rdx,%rax
  8047a2:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8047a6:	0f b7 c0             	movzwl %ax,%eax
}
  8047a9:	c9                   	leaveq 
  8047aa:	c3                   	retq   
