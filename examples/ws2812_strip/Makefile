CC := arm-none-eabi-gcc
CFLAGS := -mcpu=cortex-m33 -mthumb -mfloat-abi=soft -ffreestanding -Os -ffunction-sections -fdata-sections
LDFLAGS := -T linker.ld -Wl,--gc-sections --specs=nano.specs -nostartfiles

KLIN ?= klin
ROOT := ../..

.PHONY: all emit elf clean deps

all: emit

deps:
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" get github/klin-lang/machine_rp@v0.10.0 ;; \
	  *) "$(KLIN)" get github/klin-lang/machine_rp@v0.10.0 ;; \
	esac

emit: out/ws2812_strip.c

out/ws2812_strip.c out/ws2812_strip.link: ws2812_strip.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c ws2812_strip.kl ;; \
	  *) "$(KLIN)" --emit-c ws2812_strip.kl ;; \
	esac

elf: ws2812_strip.elf

ws2812_strip.elf: linker.ld out/ws2812_strip.c out/ws2812_strip.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/ws2812_strip.link) out/ws2812_strip.c -o $@

clean:
	rm -rf out ws2812_strip.elf
