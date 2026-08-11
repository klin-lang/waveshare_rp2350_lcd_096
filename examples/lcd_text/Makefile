CC := arm-none-eabi-gcc
CFLAGS := -mcpu=cortex-m33 -mthumb -mfloat-abi=soft -ffreestanding -Os -ffunction-sections -fdata-sections
LDFLAGS := -T linker.ld -Wl,--gc-sections --specs=nano.specs -nostartfiles

KLIN ?= klin
ROOT := ../..

.PHONY: all emit elf clean deps

all: emit

deps:
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" get github/klin-lang/machine_rp@v0.11.0 ;; \
	  *) "$(KLIN)" get github/klin-lang/machine_rp@v0.11.0 ;; \
	esac

emit: out/lcd_text.c

out/lcd_text.c out/lcd_text.link: lcd_text.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c lcd_text.kl ;; \
	  *) "$(KLIN)" --emit-c lcd_text.kl ;; \
	esac

elf: lcd_text.elf

lcd_text.elf: linker.ld out/lcd_text.c out/lcd_text.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/lcd_text.link) out/lcd_text.c -o $@

clean:
	rm -rf out lcd_text.elf
