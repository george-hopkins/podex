CC=m68hc12-gcc
CFLAGS=-Os -O3 -gstabs -Wl,-m,m68hc12elfb
#-nostartfiles
XFLAGS=

ifeq ($(origin FLASH), undefined)
MEMORY_X=ram.x
else
MEMORY_X=flash.x
XFLAGS=-DFLASH
endif

ukazka.elf: ukazka.c
	cp -f $(MEMORY_X) memory.x
	$(CC) $(CFLAGS) $(XFLAGS) -o ukazka.elf ukazka.c

output: ukazka.elf
	m68hc12-objcopy -O ihex ukazka.elf ukazka.hex
	m68hc12-objcopy -O srec ukazka.elf ukazka.sx
	m68hc12-objcopy	-O binary ukazka.elf ukazka.bin

clean:
	rm -f ukazka.elf ukazka.hex ukazka.bin ukazka.sx
