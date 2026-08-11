# waveshare_rp2350_lcd_096

Board pack for [Waveshare RP2350-LCD-0.96](https://www.waveshare.com/wiki/RP2350-LCD-0.96)
in [Klin](https://github.com/klin-lang/klin).

Not a MicroPython port. No GC, no hidden heap, no hidden clocks.

Chip API: [`machine_rp`](https://github.com/klin-lang/machine_rp) `@v0.8.0` (`*_rp2350`, **Pio**).
This package adds **pin map + ST7735S LCD + font + ADC + UART0 + sprites + light-sleep + external WS2812 (PIO) + Hazard3 RISC-V twin example** for this board only.

Decision / catalog: [Klin issue 095](https://github.com/klin-lang/klin/blob/main/issues/095-board-waveshare-rp2350-lcd-096.md), chip targets [062](https://github.com/klin-lang/klin/blob/main/issues/062-targets-esp-rp.md).

## Status (`@v0.8.0`)

| Piece | Status |
|---|---|
| Pin map (LCD / VBUS / battery ADC / UART0 / WS2812 DIN) | ✅ |
| ST7735S 160×80 (`lcd_out`, `fill`, `fill_rect`, lines) | ✅ |
| Font 5×7 (`draw_char` / `draw_text` / `draw_text_n`) | ✅ |
| 8×8 mono sprites (`blit_mono8` / `blit_mono8_trans` + stock icons) | ✅ |
| Light sleep helpers (`sleep_cpu_hz` / `sleep_systick_reload`) + `sleep_demo` | ✅ |
| External WS2812 **PIO** (`ws2812_out` / `show`) + bit-bang `ws2812_bb_*` + `ws2812_strip` | ✅ |
| Hazard3 RISC-V twin (`examples/riscv_lcd_text`) | ✅ |
| `enable_clk_adc` + temp / battery mV helpers | ✅ |
| UART0 helpers (`uart0_out`, `uart_write_codes`) | ✅ |
| Backlight GPIO | ✅ |
| Onboard WS2812 | — none on this PCB |
| PIO·DMA LCD | later |
| POWMAN deep sleep / dormant | later |

`version()` → `8`.

## Pins (LCD)

| Signal | GPIO |
|---|---|
| DC | 8 |
| CS | 9 |
| SCLK | 10 |
| MOSI | 11 |
| RST | 12 |
| BL | 25 |
| SPI | SPI1 |
| Voltage monitor | 29 (ADC3) |
| UART0 TX / RX | 0 / 1 (header; external USB–UART) |
| WS2812 DIN (external) | 15 (`ws2812_data`) |

Offsets: X+1, Y+26 (Waveshare 160×80). MADCTL `0xA8`.

Battery divider assumed **3:1** (`battery_divider_num` / `battery_divider_den`) — explicit constants in `pins.kl`.

UART0 is the Pico-compatible header mapping (Arduino `SERIAL1`). Type-C is **native USB**, not this UART — use an adapter on GP0/GP1 for `uart_console`.

Sprites: 8 row bytes, **bit7 = leftmost** pixel. Stock: `sprite_heart` / `check` / `cross` / `battery` / `arrow_r` / `smile`.

Light sleep (`sleep_demo`): Cortex-M **SysTick + WFI** (not POWMAN). Duration uses explicit `sleep_cpu_hz()` (12 MHz assumption). No USER button on this PCB — timer wake only. App must supply `@[isr("SysTick_Handler")]`. **Arm-only** (SysTick / NVIC).

WS2812: **external** strip on GP15 via **PIO0 SM0** (side-set program; `machine_rp@v0.8.0`). Buffer `0x00RRGGBB`; wire GRB. Clkdiv from explicit `ws2812_cpu_hz()` (~12 MHz). Bit-bang escape: `ws2812_bb_out`. Avoid LCD SPI during `show`.

RISC-V twin (`riscv_lcd_text`): same Klin LCD module, Hazard3 crt0 + IMAGE_DEF `0x1101`. Needs `riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32` and `mem.S` (`memcpy`/`memset`; no `nano.specs` on Ubuntu’s RISC-V package).

## Usage

```klin
import "github/klin-lang/waveshare_rp2350_lcd_096" board

fn main() {
    let lcd = board.lcd_out(12000000, 1000000)
    lcd.backlight(true)
    let strip = board.ws2812_out_default()
    let mut px: [1]i32
    px[0] = board.ws2812_rgb(0, 40, 0)
    strip.show(px[:], 1)
}
```

```sh
klin get github/klin-lang/machine_rp@v0.8.0
klin get github/klin-lang/waveshare_rp2350_lcd_096@v0.8.0
```

## Examples

### Arm Cortex-M33

```sh
cd examples/lcd_text    # or ws2812_strip / sleep_demo / …
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
| `lcd_text` | green `KLIN 0.2`, cyan `FONT 5X7` (Arm) |
| `riscv_lcd_text` | green `KLIN RV32`, cyan `HAZARD3` (RISC-V) |
| `temp_chip` | `TEMP` + `T=xxC` updating, yellow bar |
| `battery_mv` | `BAT` + `B=xxxxMV`, green/red bar |
| `uart_console` | LCD `UART 0.3` + `TX=`/`RX=`/`CH=`; serial banner + echo @ 115200 |
| `lcd_sprites` | `SPRITES` + heart/check/batt/smile; magenta arrow bouncing |
| `sleep_demo` | `SLEEP 0.5` → backlight off → `AWAKE` + `N=` (Arm) |
| `ws2812_strip` | LCD `WS2812` / `GP15` / `I=`; 8-LED chase via PIO on external strip |

## License

MIT
