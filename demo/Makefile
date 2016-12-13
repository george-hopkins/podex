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

snake.elf: snake.c
	cp -f $(MEMORY_X) memory.x
	$(CC) $(CFLAGS) $(XFLAGS) -o snake.elf snake.c

output: snake.elf
	m68hc12-objcopy -O ihex snake.elf snake.hex
	m68hc12-objcopy -O srec snake.elf snake.sx
	m68hc12-objcopy	-O binary snake.elf snake.bin

clean:
	rm -f snake.elf snake.hex snake.bin snake.sx
