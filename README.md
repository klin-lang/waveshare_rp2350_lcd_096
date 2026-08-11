# waveshare_rp2350_lcd_096

Board pack for [Waveshare RP2350-LCD-0.96](https://www.waveshare.com/wiki/RP2350-LCD-0.96)
in [Klin](https://github.com/klin-lang/klin).

Not a MicroPython port. No GC, no hidden heap, no hidden clocks.

Chip API: [`machine_rp`](https://github.com/klin-lang/machine_rp) `@v0.11.0` (`*_rp2350`, **Pio** + **Dma** + **UsbCdc**).
This package adds **pin map + ST7735S LCD (DMA→SPI1 **or** PIO-as-SPI) + USB CDC + font + ADC + UART0 + sprites + light-sleep + POWMAN + external WS2812 (PIO) + Hazard3 RISC-V twin example** for this board only.

Decision / catalog: [Klin issue 095](https://github.com/klin-lang/klin/blob/main/issues/095-board-waveshare-rp2350-lcd-096.md), chip targets [062](https://github.com/klin-lang/klin/blob/main/issues/062-targets-esp-rp.md).

## Status (`@v0.12.0`)

| Piece | Status |
|---|---|
| Pin map (LCD / VBUS / battery ADC / UART0 / WS2812 DIN) | ✅ |
| ST7735S 160×80 (`lcd_out`, `fill`, `fill_rect`, lines) | ✅ |
| **DMA→SPI1** bulk pixels (`fill_rect` / `blit_mono8`; ch `lcd_dma_ch()`) | ✅ |
| **PIO-as-SPI LCD** (`lcd_pio_out`; remux GP10/11 off SPI1; DMA→PIO TX) | ✅ |
| **USB CDC ACM** Type-C console (`usb_cdc_out` / `usb_console`) | ✅ |
| Font 5×7 (`draw_char` / `draw_text` / `draw_text_n`) | ✅ |
| 8×8 mono sprites (`blit_mono8` / `blit_mono8_trans` + stock icons) | ✅ |
| Light sleep helpers (`sleep_cpu_hz` / `sleep_systick_reload`) + `sleep_demo` | ✅ |
| **POWMAN** SWCORE power-down + LPOSC alarm wake + `powman_demo` | ✅ |
| External WS2812 **PIO** (`ws2812_out` / `show`) + bit-bang `ws2812_bb_*` + `ws2812_strip` | ✅ |
| Hazard3 RISC-V twin (`examples/riscv_lcd_text`) | ✅ |
| `enable_clk_adc` + temp / battery mV helpers | ✅ |
| UART0 helpers (`uart0_out`, `uart_write_codes`) | ✅ |
| Backlight GPIO | ✅ |
| Onboard WS2812 | — none on this PCB |
| XOSC dormant (clocks stop, no SWCORE PD) | later |

`version()` → `12`.

## Pins (LCD)

| Signal | GPIO |
|---|---|
| DC | 8 |
| CS | 9 |
| SCLK | 10 |
| MOSI | 11 |
| RST | 12 |
| BL | 25 |
| SPI (HW path) | SPI1 |
| PIO (remux path) | PIO0 SM1 @ instr `lcd_pio_prog_off()`=4; DREQ `dma_dreq_pio_tx(0,1)` |
| DMA | channel `lcd_dma_ch()` → `0` (SPI1 TX **or** PIO TX) |
| Voltage monitor | 29 (ADC3) |
| UART0 TX / RX | 0 / 1 (header; external USB–UART) |
| WS2812 DIN (external) | 15 (`ws2812_data`) |

Offsets: X+1, Y+26 (Waveshare 160×80). MADCTL `0xA8`.

Battery divider assumed **3:1** (`battery_divider_num` / `battery_divider_den`) — explicit constants in `pins.kl`.

UART0 is the Pico-compatible header mapping (Arduino `SERIAL1`). Type-C is **native USB**, not this UART — use an adapter on GP0/GP1 for `uart_console`.

LCD bulk (HW): `lcd_out` — `fill` / `fill_rect` use **DMA→SPI1** with a 2-byte RGB565 read-ring (`write_dma_repeat2`). `blit_mono8` packs 128 bytes then one `write_dma`. DC/CS stay CPU GPIO. Commands / single `pixel` stay byte SPI.

LCD bulk (PIO): `lcd_pio_out(sys_hz, bit_hz)` remuxes **GP10/11** to PIO0 (FUNCSEL 6), mode-0 MOSI+SCK program (`out pins,1` / `nop` side-set). Bulk uses **DMA→PIO TXF** + `wait_tx_stall` before CS high. Shares PIO0 with WS2812 (SM0 @0..=3; LCD SM1 @4..=5). Requires `lcd_mosi() == lcd_sclk()+1`.

Sprites: 8 row bytes, **bit7 = leftmost** pixel. Stock: `sprite_heart` / `check` / `cross` / `battery` / `arrow_r` / `smile`.

Light sleep (`sleep_demo`): Cortex-M **SysTick + WFI** (not POWMAN). Duration uses explicit `sleep_cpu_hz()` (12 MHz assumption). No USER button on this PCB — timer wake only. App must supply `@[isr("SysTick_Handler")]`. **Arm-only**.

POWMAN (`powman_demo`): powers down **switched-core** (+ XIP + SRAM) with **LPOSC** 1 kHz timer alarm wake. Wake **reboots** the cores — wake count in `powman_scratch_*` (survives PD). API: `powman_timer_start_lposc` / `powman_alarm_in_ms` / `powman_enter_swcore_off` then WFI. **Arm-only**.

WS2812: **external** strip on GP15 via **PIO0 SM0** (side-set program; `machine_rp@v0.11.0`). Buffer `0x00RRGGBB`; wire GRB. Clkdiv from explicit `ws2812_cpu_hz()` (~12 MHz). Bit-bang escape: `ws2812_bb_out`. Avoid overlapping `show` with LCD DMA (shared DMA ch0 / bus).

RISC-V twin (`riscv_lcd_text`): same Klin LCD module, Hazard3 crt0 + IMAGE_DEF `0x1101`. Needs `riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32` and `mem.S` (`memcpy`/`memset`; no `nano.specs` on Ubuntu’s RISC-V package).

USB CDC (`usb_console`): Type-C virtual COM. Call `enable_usb_clocks()` (XOSC→PLL_USB→clk_usb 48 MHz) then `usb_cdc_out()`; poll `u.poll()` in the main loop. Host: `/dev/ttyACM*`. `uart_console` (header USB–UART) unchanged.

## Usage

```klin
import "github/klin-lang/waveshare_rp2350_lcd_096" board

fn main() {
    let lcd = board.lcd_out(12000000, 1000000)
    lcd.backlight(true)
    lcd.fill(board.color_red())
    let strip = board.ws2812_out_default()
    let mut px: [1]i32
    px[0] = board.ws2812_rgb(0, 40, 0)
    strip.show(px[:], 1)
}
```

```sh
klin get github/klin-lang/machine_rp@v0.11.0
klin get github/klin-lang/waveshare_rp2350_lcd_096@v0.12.0
```

## Examples

### Arm Cortex-M33

```sh
cd examples/lcd_fill    # or lcd_sprites / powman_demo / ws2812_strip / …
make deps KLIN=/path/to/klin/bin/klin.dart
make emit KLIN=/path/to/klin/bin/klin.dart
make elf                # arm-none-eabi-gcc + --specs=nano.specs
```

### Hazard3 RISC-V

```sh
cd examples/riscv_lcd_text
make deps KLIN=/path/to/klin/bin/klin.dart
make emit KLIN=/path/to/klin/bin/klin.dart
make elf                # riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32
```

Flash the `.elf` / UF2 with picotool / OpenOCD / your usual Pico 2 flow.
Boot the core that matches the IMAGE_DEF (Arm vs RISC-V).

### Demo checklist

| Example | Expect |
|---|---|
| `lcd_fill` / `lcd_rects` | solid / rect colors via DMA→SPI1 |
| `lcd_pio_fill` | solid colors via **PIO-as-SPI** (GP10/11 remux) |
| `lcd_text` | green `KLIN 0.2`, cyan `FONT 5X7` (Arm) |
| `riscv_lcd_text` | green `KLIN RV32`, cyan `HAZARD3` (RISC-V) |
| `temp_chip` | `TEMP` + `T=xxC` updating, yellow bar |
| `battery_mv` | `BAT` + `B=xxxxMV`, green/red bar |
| `usb_console` | LCD `USB 0.11` + Type-C CDC echo |
| `uart_console` | LCD `UART 0.3` + `TX=`/`RX=`/`CH=`; serial banner + echo @ 115200 |
| `lcd_sprites` | `SPRITES` + heart/check/batt/smile; magenta arrow bouncing |
| `sleep_demo` | `SLEEP 0.5` → backlight off → `AWAKE` + `N=` (Arm light sleep) |
| `powman_demo` | `POWMAN 0.9` → off → reboot wake → `AWAKE` + `N=` (Arm POWMAN) |
| `ws2812_strip` | LCD `WS2812` / `GP15` / `I=`; 8-LED chase via PIO on external strip |

## License

MIT
