# waveshare_rp2350_lcd_096

Board pack for [Waveshare RP2350-LCD-0.96](https://www.waveshare.com/wiki/RP2350-LCD-0.96)
in [Klin](https://github.com/klin-lang/klin).

Not a MicroPython port. No GC, no hidden heap, no hidden clocks.

Chip API: [`machine_rp`](https://github.com/klin-lang/machine_rp) (`*_rp2350`).
This package adds **pin map + ST7735S LCD + font + ADC helpers + UART0 console** for this board only.

Decision / catalog: [Klin issue 095](https://github.com/klin-lang/klin/blob/main/issues/095-board-waveshare-rp2350-lcd-096.md), chip targets [062](https://github.com/klin-lang/klin/blob/main/issues/062-targets-esp-rp.md).

## Status (`@v0.3.0`)

| Piece | Status |
|---|---|
| Pin map (LCD / VBUS / battery ADC / UART0) | ✅ |
| ST7735S 160×80 (`lcd_out`, `fill`, `fill_rect`, lines) | ✅ |
| Font 5×7 (`draw_char` / `draw_text` / `draw_text_n`) | ✅ |
| `enable_clk_adc` + temp / battery mV helpers | ✅ |
| UART0 helpers (`uart0_out`, `uart_write_codes`) | ✅ |
| Backlight GPIO | ✅ |
| Examples (`…`, `lcd_text`, `temp_chip`, `battery_mv`, `uart_console`) | ✅ |
| Onboard WS2812 | — not in CircuitPython board def; use external strip later |
| PIO / DMA LCD | later |

`version()` → `3`.

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

## Usage

```klin
import "github/klin-lang/machine_rp" machine
import "github/klin-lang/waveshare_rp2350_lcd_096" board

fn main() {
    let lcd = board.lcd_out(12000000, 1000000)
    lcd.backlight(true)
    let u = board.uart0_out(12000000, board.uart_default_baud())
    let mut banner: [6]i32
    banner[0] = 'h'
    banner[1] = 'i'
    banner[2] = '\n'
    board.uart_write_codes_n(u, banner[:], 3)
    lcd.draw_char(8, 28, 'U', board.color_green(), board.color_black())
}
```

```sh
klin get github/klin-lang/machine_rp@v0.6.0
klin get github/klin-lang/waveshare_rp2350_lcd_096@v0.3.0
```

## Examples (Arm Cortex-M33)

```sh
cd examples/uart_console    # or lcd_text / temp_chip / battery_mv / …
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
| `uart_console` | LCD `UART 0.3` + `TX=`/`RX=`/`CH=`; serial banner `KLIN UART` + echo @ 115200 |

## License

MIT
