# Demo Application

As a very little demonstration of podex use, a small program in C is included which displays eightbit moving light ("snake"), and guide how to compile it, load to RAM or FLASH and debug. The program expects that there are eight lights connected to port PH (switched on by level H). It has been tested on a board with M68HC912D60A.

At the beggining, source includes definition file `intvec.h`, where is defined data structure interrupt_vectors, copied from [a post](https://groups.yahoo.com/neo/groups/gnu-m68hc11/conversations/topics/4010) in a mailing list. Only one entry in this structure is used -- start of the program (`_start` is the very beggining of compiled program). If the program would use some interrupt handlers, their names should be added to this structure. This structure is inserted to a linker section called `.vectors`, which is on the end of memory address space, starting with address 0xff00, where HC12 looks for hardware event handler pointers. Who knows GNU ld well, he will perhaps find my strange solution fool, so, please, excuse me.

Follow a definition of I/O space constant pointers DDRH and PORTH, ie. control registers of output port, which has to be attached to lights. Function `sleep()` does a delay by thousands repetitions of nothing to get a speed of snake's motion reasonable. The eternal loop of main program contains no magic, only a very weird expression of rotation of eight bits, which isn't (at least in current version) optimized to a rotation instruction by gcc, what a wonder, gcc places this ugly thing in output verbatim. If anybody suffers from this, there is no problem to insert a piece of assembler in source.

In the case of execution from FLASH (ie. automatically after reset or power on) there is redefined the `__premain` function, which is called before first function call, so it means before call of `main()`. In this function, there is on the first place disabled an evil watchdog COP, because some HC12's are buggy and need this to not to be stopped by it. But mainly, there is remapped RAM memory from original location at 0x000 (which isn't very handy, because it's overlapped with control registers) to new address 0x800 and then the stack pointer is moved by the same distance to point to newly located RAM and not to the hole at old location.

Linker ld should know, in which address range should the result reside, it is possible to specify this by a so called ld-script. For operation with RAM only, there has been created script `ram.x`, for placement of program to FLASH there is a script `flash.x`. Compilation is exeuted using Makefile.

If you want the program to be in FLASH, to be run automatically after HC12 reset, you can execute:

```bash
make FLASH=
m68hc12-gdb snake.elf
# (gdb) target bdm12 ttyS0 4 0x0 0x800 0xd00 0x8000
# (gdb) load snake.elf
```

If you'd like to load the program to RAM and debug it a little bit, you can execute:

```bash
make
m68hc12-gdb snake.elf
# (gdb) target bdm12 ...
```
