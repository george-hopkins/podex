# Debugging with GDB

Podex is able to operate with the excellent GNU debugger GDB. GDB can be used with podex to load a code to RAM and FLASH memories of HC12, to run and step programs in them, to use breakpoints etc. while working at level of assembler as well as on a higher language (C) source level. I worked in gdb in cooperation with 68HC1x branche of GNU gcc and binutils, but GNU gdb should principially work with output of other compillers as well. There are supported formats such as ELF, S-record, headerless binary and others contained in bfd library, for source-level debugging there is used format stabs (and maybe also others).

## How to obtain GDB for podex?

GDB port for Kevin Ross' BDM12 protocol has been added to 68HC1x branch of gdb by Timothy Housel. While podex was in a development stage (April 2004), there were available 68HC1x patch for gdb-6.0 marked 20040222 ([gdb-6.0.tar.gz](http://ftp.gnu.org/pub/gnu/gdb/gdb-6.0.tar.gz), [m68hc1x-builder-2.91.tar.gz](http://m68hc11.serveftp.org/m68hc1x-builder-2.91.tar.gz)). I suggest also to apply another little patch for BDM12 support code in gdb, which corrects one race-condition bug and also enlarges some timeout constants, what has been found necessary, especially while working with USB-RS232 converter or on heavy loaded machines. (Patch haven't been merged with a 68HC1x branch yet, so it can be downloaded [here](gdb-bdm12-mp.diff).)

GNU gdb is in philosophy a unix application, but BDM12 port, what means its code for acces to RTS, CTS lines of serial port, is written to be compatible with unix-like GNU environment Cygwin32/Mingw32 for the poor ugly operating chaos M$ Windows. To compile gdb, download mentioned sources: official source GNU `gdb-6.0.tar.gz`, M68HC1x branch `m68hc1x-builder-2.91.tar.gz` and a patch `gdb-bdm12-mp.diff`. Then unpack, patch and make:

```bash
tar xzvf gdb-6.0.tar.gz
tar xzvf m68hc1x-builder-2.91.tar.gz
cd gdb-6.0
patch -p1 < ../m68hc1x-builder-2.91/gdb-6.0-m68hc1x-20040222.diffs
patch -p1 < ../gdb-bdm12-mp.diff

./configure --target=m68hc11-elf --program-prefix=m68hc12-
make
#optionally with root privileges do a make install (by defult to /usr/local/...)
```

I suggest also to install a 68HC1x GNU tools gcc and binutils (including the gas assembler). They are often available as precompiled packages in many GNU operating system distributions (eg. Debian Linux), what can save yourself from the bloody compilation.

## Basic use of gdb with podex

Operation with podex in gdb is introduced by command target bdm12:

```text
(gdb) target bdm12
Usage: target bdm12 <serial_device> <E-clock rate (1,2,4, or 8 MHz)>
                            <register base> <ram base> <eeprom base> <flash base>
(ex. target bdm12 com1 8 0x0 0x800 0xd00 0x8000 on Win32,
   or target bdm12 ttya 8 0x0 0x800 0xd00 0x8000 on UNIX)
```

Where `serial_device` is a name of the serial device, which is podex attched to, what can be in Linux eg. ttyS? for ordinary COM-port or ttyUSB? in case of USB converter. Attention, in current version of BDM12 port under unix there is contatenated prefix "/dev/" to the name of device -- this saves your fingers of typing of 5 characters, but it is restrictive and not very clever and it should be as soon as possible put away from the code. `E-clock_rate` is a frequency of BDM bus of target HC12, but in current version it is restricted to 4 integer values, because it uses only `SetParam` firmware command (I hope we'll very soon add support for arbitrary rated HC12's using `ExtendedSpeed` firmware command).

Argument `register_base` tells podex, that registers will be moved somewhere, see `SetRegisterBase` firmware command. Arguments `ram_base`, `eeprom_base` and `flash_base` gives information about location of internal memories, ie. 2KB RAM, 32KB FLASH and 768B EEPROM. It is not clear to me, how to solve complicated cases of numerous different configurations of external memories of different types (RAM, FLASH) connected to HC12 -- maybe it would be fine to look to more mature ports of gdb code for other processors for inspiration (if they exist and solve it).

If we want to debug a code from binary file, which contains debugging information (function and variable names -- labels, numbers of lines in source), we can supply its name as an argument when starting gdb or later by a file command.

Program code is loaded to HC12 CPU by a load command (large data segments can probably by a restore command, but I haven't used it). This is a most important and also a most complicated task for gdb with podex. Program (data) can be loaded either in RAM, but also to EEPROM and mainly to FLASH, which is programmed by gdb via podex according to a proedure, described later. This way, gdb can be used as an internal HC12 FLASH memory programmer. Properties and problems of FLASH memory programming are described in next section.

After program is placed in some of HC12's memories, in the simplest case in RAM, it can be runned, stepped, stopped and tortured in any manner. Breakpoints can be set by a `break` command, on a line number level (`break 33` or `break apollo_jets.c:1811`), function name (`break speed_up`) or memory address (`break *0x8a0d`). Program is started by a `run` command, then it can be interrupted by pressing Ctrl-C. Execution can be then resumed by `continue` command, stepped by commands `step` (including diving to inner functions), `next` (to the next source line), `until` etc. on the source level, and on the machine instruction level by `stepi`, `nexti` (`nexti` similarly doesn't dive to subroutine calls).

GDB also allows to mess with HC12 registers and memory, contents of all (and there is really a lot of them at HC12) registers can be dumped with a `regs` command, writing to them is done by a set command (`set $d=-1977, set $pc=0x8000`), which can also write to a memory, as well as to a variable (`set rpm=0`) or arbitrary address (`set *0x804=0xbeef`). Maybe, there could probably work also writing to a FLASH, but I'm not sure, if current BDM12 port won't damage RAM contents. To read single registers, variables or memory, there can be used a `print` command (`print $x`, `print gear_box->wheel[5]`, `print *0x806`). To read from certain memory addresses, there is a useful command `x` (examine), which can show value in many different number bases and of arbitrary bit size (`x/b *0x808` will show byte from the address, `x/h *0x808` will show 16bit word from that address). If you will get a suspicion or paranoia, which can easily happen while debugging, you can dump the instructions within a function or a memory region by disassemble command (`disassemble _start`, `disassemble slow_down`, `disassemble 0x802c 0x8100`, without argument will disassemble the function, in which currently executed code of HC12 is).

GNU gdb is a mighty beast, so for discovering possibilities of its use with podex or without it, consult gdb command help | trying out | documentation | sources reading. Have a fun!

GNU gdb BDM12 (ie. podex) support code by Tim Housel is placed mainly in `bdm12.c` file, constant definitions and declarations are in `bdm12.h` file, this is glued with main program of gdb by `remote-bdm12.c` file. For FLASH programming purposes, there are files `bdm12_eraseflash.h` and `bdm12_programflash.h`.

## Flash memory programming

HC12 internal FLASH memories are accessed for reading in an ordinary manner, the same as RAM and EEPROM is read, either by any machine code instruction or using BDM commands READ_BYTE, READ_WORD. But for writing to internal FLASH it is needed to traffic a bit with HC12 control registers and to satisfy timing, as well as with EEPROM. But, in opposite, FLASH cannot be programmed directly by BDM write commands (to control registers and memory). To write to internal FLASH memories of HC12, there must be a program (routine) loaded to HC12 RAM, which will do FLASH writing operation.

There is a problem, that programmer's models of internal memories of different HC12 types is also different and probably there cannot be one universal routine, which could write to FLASH memories of all of HC12 variants. One man from Motorola assured me, that in HCS12 series they have advanced and there will be applied the same programmer's model for all FLASH memories in HCS12. Well, it seems that evolution goes sometimes not only backward, as from hand-axe to cellular phone. On the other hand, there will always remain wide set of different development boards with external FLASH memories, so if we would like to program them via BDM also, we will need appropriate routine for each of them.

HC12 FLASH programming is done in following steps: first, there is loaded an erasing program to RAM, and by its execution, entire FLASH is erased. Then, there is loaded a writing program to RAM, and into the free rest of RAM, there is always put a block of data, which is then, after passing information about target block position in FLASH and block length, programmed into the FLASH. Execution of writing program is repeated for each next block, until entire data are programmed into FLASH. Loading of erasing and writing routines to RAM, their execution and passing of parameters (by register or memory location) is done via BDM, after finishing execution of routines, they use to issue a BGND instruction, what is also detected by BDM. There is also necessary to tell to programs about timing, because it is derived from HC12 clock.

## Flash and GDB

Current support of HC12 FLASHing in gdb is in a dismal state. Tim Housel filled bdm12_eraseflash.h and bdm12_programflash.h files by routines for programming M68HC12B32 family FLASH, moreover, containing fixed timing constant, see their sourcecode. So, probably, this source is able to successfuly program only FLASH memories of HC12B32 with 16MHz crystal frequency.

How to overcome? The best solution would be to have

 * unified program interface for execution of erasing and writing routines, ie. defined calling, perhaps relocation, parameter passing -- containing target and maybe also source address, data block length and CPU frequency
 * set (a lots of) erasing and writing routines dynamically loadable from a file, external to gdb, allowing the user to supply own routines

Such solution is implemented for example by [P&E for HC12](http://www.pemicro.com/support/flash_list_menu.cfm), [Pavel Píša for M683xx](http://cmp.felk.cvut.cz/~pisa/m683xx/bdm_driver.html). There is a question, which format to choose for external loadable routines, maybe it would be fine to use ELF, which already solves symbol names and relocation -- but on the other hand, it is a complex beast and from other point of view, the simplicity of headerless binary file is really beautiful... Furthermore, it would be also desirable to look to some other parts of gdb, if there is dynamical loading of some kind of modules already solved in gdb, for efforts to be unified. I would like to live to see such flexible and efficient support of HC12 FLASHing in gdb and I would also like, if I will have a time, to help with it a bit, but now I'm heavily occupied, so I hope somebody else will join the task.

As a temporary solution, there could be defined a simple head(er)less interface, similar to code of Tim Housel, where would be defined memory offsets of necessary argument and maybe there could be also supplied some skeleton of program in assembler or GNU C (with delay loop in assembler), to help users to supply their particular routines for their specific HC12 confgurations, and also to extend current code of passing of a HC12 CPU frequency (timing) argument.

What to do, if you need with current state of gdb port to use a FLASH with your flavour of HC12? I have been in the same case, when I had to prepare for my colleague support for internal FLASH of M68HC12D60A, at least its upper 32KB bank. With the minimal effort, or in other words, with minimum intervention to gdb code and within minimal time, I have only replaced support code for HC12B32 in bdm12_*flash.h by the code for HC12D60A.

For the educational and inquisitive reasons, I haven't wrote the code by myself, but rather used freely downloadable routines from P&E server. The main goal of this was to speculate, whether it would be good in the future (hope it will come) support of dynamically loadable modules to use the same or similar philosophy, as our predecessors did. If it will be allowed by your conscience and by the law of your country, you will see, that these are in fact S-records, enriched by a header with some initial setup of some registers; this header can be deleted and then cruelly disassembled by `m68hc12-objdump -mm68hc12 -D something.sx`. If you need it quickly and only for personal use, I hope, that nobody will be angry at you about that.

## Incorporating your own programming routine in the current (poor) code of GDB

I will describe a recipe, by which I added a support (as a temporary solution, but you know, that temporary solutions are immortal) for erasing and writing to 32KB FLASH of HC12D60A.

 * Create your own flashing program, probably in assembler, but it should make sense to do it in C also (I'd like to put here some example); programming algorithm (what to write to which control registers and how many microseconds to sleep between) is described in datasheet of particular HC12 (eg. for D60A it is on page 102 of the [datasheet](http://www.nxp.com/assets/documents/data/en/data-sheets/MC68HC912D60A.pdf)), or sometimes in an application note (for D60A it is [AN2166](http://www.nxp.com/assets/documents/data/en/application-notes/AN2166.pdf))
 * Take a look at `gdb/blesk.s` to see how such a program might look like. Note: I was too lazy to divide the code to erasing and flashing part, so I left it in one block, even it's true, that erase part occupies a space in RAM.
 * Compile the program -- I don't know why, but I haven't succeeded with generation of binary incarnation of a code, located in RAM from address 0x800, with GNU assembler gas and binutils -- after conversion by objcopy it filled address fields with nonsense zeroes (you must excuse my inability to work with GNU tools).
   - Solution, even it is a pity: Use the assembler [ASM12](https://www.mgtek.com/miniide/) from MGTEK. Convert the code using `gas2mtek.pl` to comply with the slightly different syntax.
 * Make a constant (global variable) in a header file `bdm*flash.h` from the compiled program. I did it using `gdb/mpconvert.c` (see original convert.c in Tim Housel's comment) and the Makefile in the same directory. The resulting header file is then, in my lazy case, included to both bdm12_program and eraseflash.h
