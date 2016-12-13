MEMORY
{
   page0 (rwx) : ORIGIN = 0x0, LENGTH = 256
   text  (rx)  : ORIGIN = 0x800, LENGTH = 0x200
   data        : ORIGIN = 0xa00, LENGTH = 0x200
   eeprom      : ORIGIN = 0xb00, LENGTH = 2048
}
PROVIDE (_stack = 0x0c00);
