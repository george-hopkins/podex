TARGET = podex
OBJ = podex.o

AS = avr-as
LD = avr-ld
OBJCOPY = avr-objcopy

all: $(TARGET).hex

%.o: %.s
	$(AS) -o $@ $<

$(TARGET).elf: $(OBJ)
	$(LD) -o $@ $^

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -R .eeprom -O ihex $< $@

clean:
	rm -f $(OBJ) $(TARGET).elf $(TARGET).hex
