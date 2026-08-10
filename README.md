# waveshare_rp2350_lcd_096

Board pack for [Waveshare RP2350-LCD-0.96](https://www.waveshare.com/wiki/RP2350-LCD-0.96)
in [Klin](https://github.com/klin-lang/klin).

Not a MicroPython port. No GC, no hidden heap, no hidden clocks.

Chip API: [`machine_rp`](https://github.com/klin-lang/machine_rp) (`*_rp2350`).
This package adds **pin map + ST7735S LCD + font + ADC helpers** for this board only.

Decision / catalog: [Klin issue 095](https://github.com/klin-lang/klin/blob/main/issues/095-board-waveshare-rp2350-lcd-096.md), chip targets [062](https://github.com/klin-lang/klin/blob/main/issues/062-targets-esp-rp.md).

## Status (`@v0.2.0`)

| Piece | Status |
|---|---|
| Pin map (LCD / VBUS / battery ADC) | ✅ |
| ST7735S 160×80 (`lcd_out`, `fill`, `fill_rect`, lines) | ✅ |
| Font 5×7 (`draw_char` / `draw_text` / `draw_text_n`) | ✅ |
| `enable_clk_adc` + temp / battery mV helpers | ✅ |
| Backlight GPIO | ✅ |
| Examples (`backlight`, `lcd_fill`, `lcd_rects`, `lcd_hello`, `lcd_text`, `temp_chip`, `battery_mv`) | ✅ |
| Onboard WS2812 | — not in CircuitPython board def; use external strip later |
| PIO / DMA LCD | later |

`version()` → `2`.

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

Offsets: X+1, Y+26 (Waveshare 160×80). MADCTL `0xA8`.

Battery divider assumed **3:1** (`battery_divider_num` / `battery_divider_den`) — explicit constants in `pins.kl`.

## Usage

```klin
import "github/klin-lang/machine_rp" machine
import "github/klin-lang/waveshare_rp2350_lcd_096" board

fn main() {
    let lcd = board.lcd_out(12000000, 1000000)
    lcd.backlight(true)
    board.enable_clk_adc()
    let adc = machine.adc_out_rp2350(0, board.temp_adc_ch())
    let tc = board.temp_c_from_adc12(adc.read_u12())
    let mut line: [16]i32
    let mut pre: [2]i32
    pre[0] = 'T'
    pre[1] = '='
    let mut suf: [1]i32
    suf[0] = 'C'
    let n = board.format_label_u32(line[:], pre[:], tc, suf[:])
    lcd.draw_text_n(8, 28, line[:], n, board.color_green(), board.color_black())
}
```

```sh
klin get github/klin-lang/machine_rp@v0.6.0
klin get github/klin-lang/waveshare_rp2350_lcd_096@v0.2.0
```

## Examples (Arm Cortex-M33)

```sh
cd examples/lcd_text    # or temp_chip / battery_mv / backlight / …
make deps KLIN=/path/to/klin/bin/klin.dart
make emit KLIN=/path/to/klin/bin/klin.dart
make elf                # needs arm-none-eabi-gcc (+ newlib nano via --specs=nano.specs)
```

Link flags use `--specs=nano.specs -nostartfiles` (not bare `-nostdlib`) so
GCC-emitted `memcpy` / `memset` resolve. Flash the `.elf` with picotool / OpenOCD /
your usual Pico 2 / RP2350 flow.

### Hardware smoke (`@v0.2`)

| Example | Expect on LCD |
|---|---|
| `lcd_text` | green `KLIN 0.2`, cyan `FONT 5X7` |
| `temp_chip` | `TEMP` + `T=xxC` updating, yellow bar |
| `battery_mv` | `BAT` + `B=xxxxMV`, green/red bar (USB ≈ ~5000 mV class if divider OK) |

Sanity: die temp roughly room ±15 °C (datasheet slope; not calibrated per chip).
Battery: confirm `battery_divider_*` 3:1 vs your PCB / USB-vs-LiPo.

## License

MIT
