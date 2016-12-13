#ifdef FLASH
#include "../intvec.h"

extern void _start();

#define FFFF_VEC ((interrupt_t) 0xffff)
struct interrupt_vectors __attribute__((section(".vectors"))) vectors = {
  FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC,
  FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC,
  FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC,
  FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC, FFFF_VEC,
  reset_handler: _start
};
#endif

#define IO_BASE 0
#define PORTH *(volatile unsigned char *)(IO_BASE + 0x29)
#define DDRH *(volatile unsigned char *)(IO_BASE + 0x2b)

#define SLEEP_N 30000
void sleep() {
  unsigned i;
  for (i = 0; i < SLEEP_N; i++);
}

main() {
  unsigned char b = 0x07;
  DDRH = 0xff;
  for (;;) {
    PORTH = b;
    sleep();
    b = (b<<1)|(b>>7);
  }
}

#ifdef FLASH
void __premain() {
  /* zrusit COPCTL */
  __asm__ __volatile__("clr 0x16");
  /* locate RAM at 0x800..0x9ff */
  __asm__ __volatile__("movb #0x08, 0x10");
  /* update stack pointer */
  __asm__ __volatile__("tfr sp, d");
  __asm__ __volatile__("addd #0x800");
  __asm__ __volatile__("tfr d, sp");
}
#endif
