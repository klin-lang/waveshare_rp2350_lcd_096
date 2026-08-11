.syntax unified
.cpu cortex-m33
.thumb

@ ARM-only: enable IRQs then wait-for-interrupt (SysTick wake).
.global sleep_demo_wfi
.thumb_func
sleep_demo_wfi:
  cpsie i
  wfi
  bx lr
