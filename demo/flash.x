MEMORY
{
   page0 (rwx) : ORIGIN = 0x0, LENGTH = 256
   text  (rx)  : ORIGIN = 0x8000, LENGTH = 0x8000
   data        : ORIGIN = 0x800, LENGTH = 0x400 /* 0x800, 0x200 */
   eeprom      : ORIGIN = 0xc00, LENGTH = 2048
}
PROVIDE (_stack = 0x0400 /*0x0a00*/);
