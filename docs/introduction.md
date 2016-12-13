# Introduction

## What is BDM of Motorola HC12?

BDM (background debugging mode) of Motorola 68HC12 processors is

 * special CPU mode, in which is possible to intervene in a program execution, to read and write memory and registers, debug the program (set breakpoints, watchpoints, step)
 * interface of HC12 CPU, which is used to control BDM mode (from another computer)

The BDM interface is used either for HC12 microcontroller program debugging as for programming of their FLASH memories. BDM is the most convenient way to program internal FLASH memory of HC12, but it is also able to program external memories, which are found eg. on some development boards.

BDM, used in Motorola HC12 CPU's, is implemented only in this processor family. There is a different interface, called also BDM, and offering similar functionality, implemented in Motorola 32bit MCU series 68300. Other similar, but more general interface, used by many vendors either for processors and microcontrollers, as in programmable logic devices and memories, is JTAG.

## What is podex (BDM pod)?

Our podex is an interface (physical, ie. a box, circuit -- called "pod"), interconnecting BDM of HC12 CPU with another computer, from which is the HC12 programmed and debugged. One side of podex is connected to BDM interface (standard 6pin or extended 10pin connector) and other side of podex to RS232 serial interface of control computer. It also works well with USB-RS232 converter and should work also with other computers, than Intel/IBM PC.

Schematics, directions for assembly and use, firmware for MCU contained in podex, are here offered for free public use. Cost of components (at least in the Czech republic, but they are anyway all manufactured in Asia) is about 5EUR (and it's still dropping...).

In a stage of podex development, I have heard of only two pods, which have had schematics publicly available:

 * Malte Avenhuse's pod, which creator also have published its firmware of MCU; this pod, however, isn't supported by any debugger
 * Kevin Ross' pod, which is commercial, but sold as a kit; it was the only pod beside Malte Avenhaus', which has had published a communication protocol and which is also supported by two commercial debuggers and by GNU gdb

Podex has been designed to be protocol-compatible with pod of Kevin Ross. The main goal was to develop a cheap and freely available BDM pod, which will be able to operate with GNU gdb debugger. I consider it's better to implement the Kevin Ross' protocol (even it's somehow thick-skulled), for which is GNU gdb already ported (and to improve this port and profit from wider user base), than to invent another, functionally the same, protocol, and put redundant support code for almost the same thing to gdb.

Podex interconnects one-wire bidirectional BDM interface (which requires pretty precise timing and so it cannot be implemented only in software without keeping some important time delays exact) with serial line of control computer. The main part of communication on the line is only passed over by pode between serial line and BDM, the rest of communication on the side of control computer are some service commands, such as time constant of BDM setting (according to HC12 frequency) or controlling of HC12 RESET line, also connected to podex. Podex is based on Atmel AVR MCU, in presented circuit with particular AT90S2313. Use of MCU as a BDM interface controller (as opposite to eg. gate array) implies, unfortunately, the BDM interface speed limit (what means limit of connected HC12's frequency).

## Where can I use podex?

Podex is able to operate with BDM of all microcomputers, boards and devices, based on Motorola HC12 or HCS12 core, which have

 * frequency of BDM (which is a half of clock rate) up to approximately the frequency of used AVR in podex; in presented circuit with 9.216MHz crystal it can operate with HC12 clocked up to cca 18..22MHz
 * power supply voltage 5V (the same as voltage supply of used AVR MCU); maybe in the future I can try to assemble a converter to 3V, another solution could be to use 3V AVR (but on the other hand, they use to be slower)

Podex operates with following debuggers:

 * [GNU gdb](https://www.gnu.org/software/gdb/) -- the main supported debugger (and IMHO the best debugger of all), it can be used together with [GNU m68hc1x toolsuite](https://www.gnu.org/software/m68hc11/), including binutils and GCC
 * [NoICE Debugger](http://www.noicedebugger.com/help/bdm12.htm)
 * [StingRay 68HC12 debugger](http://www.softtools.com/stingray_bdm12_features.htm) by Sid Prince

## How could it be done better?

Podex has been developped due to immediate need of a BDM pod in period of about two months (we didn't want t pay for expensive debuggers, especially when there are many people at our departments, who probably will found such BDM pods useful). The main goal was a low cost, easy construction and immediate application (with support of GNU gdb). It isn't, however, a state of the art solution, neither an original or inconquerable device. For an advice, I try to write down some ways of better solution or improvements:

 * faster podex MCU -- somebody, who needs to work with a faster rated HC12's, can try to use a faster AVR MCU in the circuit -- it is only necessary to change one timing constant in firmware source code (and, probably, a PCB layout)
 * direct use of USB -- surely, there could be used a MCU with direct support of USB (or with some external controller) and profit from a faster communication between MCU and control computer and for greater convenience of use with computers, offering USB and lacking a serial port; but in podex design I preferred to use a serial port for its widest support everywhere (asynchronous serial transfer with start and stopbits since end of 19th century), which also means it can be easily connected to USB via converter (while, you know, it's very difficult to connect USB device to serial port); on the other hand, it could be very interresting to connect BDM interface to USB controller without use of MCU, eg. to FT2232C with programmable synchronous serial port -- but I haven't been thinking about this
 * application of programmable serial interface controller -- there are some universal circuits, which should be able to be connected to BDM interface after appropriate setup; these controllers are part of some MCU's (Hitachi)
 * use of programmable gate array -- IMHO the most interresting way, allowing the highest speed of BDM; it should be enough to implement in gate array sending and receiving of one bit over BDM (it is done in 16 clock periods), for this purpose it should be sufficient to use a really little array (GAL22V10?); gate array would be then connected to parallel port (Centronics-LPT) or USB converter (FT245, FT2232C) -- if I will find someday somewere a piece of free time, I'd like to try this way of implementing BDM and try to add a support to GNU gdb, having the most of support code common to podex and gate array
 * support of more interfaces (BDM of other CPU's, JTAG) -- it is really wonderful to have a universal device for programming and debugging of wide range of processors and other devices, than to be limited only to HC12 series; but podex is designed to be and will remain tiny and cheap tool for HC12 -- those, who need greater solution, will find it somewhere else (hope, that soon)

### Related Projects

 * [Free AVR ICE / GDB-Serializer](http://savannah.nongnu.org/projects/freeice) (for AVR (with JTAG), arm7/9 (JTAG), 68HC08, 683xx, 68HC16, 68HC12, coldfire)
 * [BDM/GDB for 683xx](http://cmp.felk.cvut.cz/~pisa/m683xx/bdm_driver.html) by Pavel Píša
 * [BDM implementation in a gate array](http://micro.feld.cvut.cz/~rozehnal/) by Zdeněk Rozehnal
 * [BDM12](http://www.kevinro.com/bdm12.pdf) by Kevin Ross -- pod, with which we would like to be compatible
 * [BDM](http://www.avenhaus.de/Malte/BDM12/) by Malte Avenhaus -- as we know, the first author of BDM with publicly available sources
