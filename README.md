# waveshare_rp2350_lcd_096

Board pack for [Waveshare RP2350-LCD-0.96](https://www.waveshare.com/wiki/RP2350-LCD-0.96)
in [Klin](https://github.com/klin-lang/klin).

Not a MicroPython port. No GC, no hidden heap, no hidden clocks.

Chip API: [`machine_rp`](https://github.com/klin-lang/machine_rp) (`*_rp2350`).
This package adds **pin map + ST7735S LCD + font + ADC + UART0 + sprites + light-sleep helpers** for this board only.

Decision / catalog: [Klin issue 095](https://github.com/klin-lang/klin/blob/main/issues/095-board-waveshare-rp2350-lcd-096.md), chip targets [062](https://github.com/klin-lang/klin/blob/main/issues/062-targets-esp-rp.md).

## Status (`@v0.5.0`)

| Piece | Status |
|---|---|
| Pin map (LCD / VBUS / battery ADC / UART0) | ✅ |
| ST7735S 160×80 (`lcd_out`, `fill`, `fill_rect`, lines) | ✅ |
| Font 5×7 (`draw_char` / `draw_text` / `draw_text_n`) | ✅ |
| 8×8 mono sprites (`blit_mono8` / `blit_mono8_trans` + stock icons) | ✅ |
| Light sleep helpers (`sleep_cpu_hz` / `sleep_systick_reload`) + `sleep_demo` | ✅ |
| `enable_clk_adc` + temp / battery mV helpers | ✅ |
| UART0 helpers (`uart0_out`, `uart_write_codes`) | ✅ |
| Backlight GPIO | ✅ |
| Examples (`…`, `uart_console`, `lcd_sprites`, `sleep_demo`) | ✅ |
| Onboard WS2812 | — not in CircuitPython board def; use external strip later |
| POWMAN deep sleep / dormant | later |
| PIO / DMA LCD | later |

`version()` → `5`.

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

Offsets: X+1, Y+26 (Waveshare 160×80). MADCTL `0xA8`.

Battery divider assumed **3:1** (`battery_divider_num` / `battery_divider_den`) — explicit constants in `pins.kl`.

UART0 is the Pico-compatible header mapping (Arduino `SERIAL1`). Type-C is **native USB**, not this UART — use an adapter on GP0/GP1 for `uart_console`.

Sprites: 8 row bytes, **bit7 = leftmost** pixel. Stock: `sprite_heart` / `check` / `cross` / `battery` / `arrow_r` / `smile`.

Light sleep (`sleep_demo`): Cortex-M **SysTick + WFI** (not POWMAN). Duration uses explicit `sleep_cpu_hz()` (12 MHz assumption). No USER button on this PCB — timer wake only. App must supply `@[isr("SysTick_Handler")]`.

## Usage

```klin
import "github/klin-lang/waveshare_rp2350_lcd_096" board

fn main() {
    let lcd = board.lcd_out(12000000, 1000000)
    lcd.backlight(true)
    let mut heart: [8]i32
    board.sprite_heart(heart[:])
    lcd.blit_mono8(16, 28, heart[:], board.color_red(), board.color_black())
}
```

```sh
klin get github/klin-lang/machine_rp@v0.6.0
klin get github/klin-lang/waveshare_rp2350_lcd_096@v0.5.0
```

## Examples (Arm Cortex-M33)

```sh
cd examples/sleep_demo    # or lcd_sprites / uart_console / lcd_text / …
make deps KLIN=/path/to/klin/bin/klin.dart
make emit KLIN=/path/to/klin/bin/klin.dart
make elf                # needs arm-none-eabi-gcc (+ newlib nano via --specs=nano.specs)
```

Link flags use `--specs=nano.specs -nostartfiles` (not bare `-nostdlib`) so
GCC-emitted `memcpy` / `memset` resolve. Flash the `.elf` with picotool / OpenOCD /
your usual Pico 2 / RP2350 flow.

### Demo checklist

| Example | Expect |
|---|---|
| `lcd_text` | green `KLIN 0.2`, cyan `FONT 5X7` |
| `temp_chip` | `TEMP` + `T=xxC` updating, yellow bar |
| `battery_mv` | `BAT` + `B=xxxxMV`, green/red bar |
| `uart_console` | LCD `UART 0.3` + `TX=`/`RX=`/`CH=`; serial banner + echo @ 115200 |
| `lcd_sprites` | `SPRITES` + heart/check/batt/smile; magenta arrow bouncing |
| `sleep_demo` | `SLEEP 0.5` → backlight off (`ZZZ...`) → `AWAKE` + `N=` wake count |

## License

MIT
