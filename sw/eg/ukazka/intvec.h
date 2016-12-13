typedef void (* interrupt_t) (void);

/** Interrupt vectors as a struct. */
struct interrupt_vectors
{
interrupt_t res0_handler;
interrupt_t res1_handler;
interrupt_t res2_handler;
interrupt_t res3_handler;
interrupt_t res4_handler;
interrupt_t res5_handler;
interrupt_t res6_handler;
interrupt_t res7_handler;
interrupt_t res8_handler;
interrupt_t res9_handler;
interrupt_t res10_handler;

/** SCI interrupt handler. */
interrupt_t sci_handler;

/** SPI interrupt handler. */
interrupt_t spi_handler;

/** Accumulator input handler. */
interrupt_t acc_input_handler;

/** Accumulator overflow interrupt handler. */
interrupt_t acc_overflow_handler;

/** Timer overflow interrupt handler. */
interrupt_t timer_overflow_handler;

/** Output compare 5 interrupt handler. */
interrupt_t output5_handler;

/** Output compare 4 interrupt handler. */
interrupt_t output4_handler;

/** Output compare 3 interrupt handler. */
interrupt_t output3_handler;

/** Output compare 2 interrupt handler. */
interrupt_t output2_handler;

/** Output compare 1 interrupt handler. */
interrupt_t output1_handler;

/** Input capture 3 interrupt handler. */
interrupt_t capture3_handler;

/** Input capture 2 interrupt handler. */
interrupt_t capture2_handler;

/** Input capture 1 interrupt handler. */
interrupt_t capture1_handler;

/** Realtime timer interrupt handler. */
interrupt_t rtii_handler;

/** External interrupt handler. */
interrupt_t irq_handler;

/** Non-maskable interrupt handler. */
interrupt_t xirq_handler;

/** Software interrupt handler. */
interrupt_t swi_handler;

/** Illegal instruction interrupt handler. */
interrupt_t illegal_handler;

/** COP fail interrupt handler. */
interrupt_t cop_fail_handler;

/** COP clock failure interrupt handler. */
interrupt_t cop_clock_handler;

/** Reset handler. */
interrupt_t reset_handler;
};

typedef struct interrupt_vectors interrupt_vectors_t;
