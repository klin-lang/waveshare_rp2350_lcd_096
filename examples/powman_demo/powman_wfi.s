.syntax unified
.cpu cortex-m33
.thumb

@ ARM-only: after POWMAN_STATE_WAITING, WFI lets switched-core power down.
.global powman_demo_wfi
.thumb_func
powman_demo_wfi:
  cpsie i
  wfi
  bx lr
