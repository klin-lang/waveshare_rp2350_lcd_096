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

emit: out/xosc_dormant_demo.c

out/xosc_dormant_demo.c out/xosc_dormant_demo.link: xosc_dormant_demo.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c xosc_dormant_demo.kl ;; \
	  *) "$(KLIN)" --emit-c xosc_dormant_demo.kl ;; \
	esac

elf: xosc_dormant_demo.elf

xosc_dormant_demo.elf: linker.ld out/xosc_dormant_demo.c out/xosc_dormant_demo.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/xosc_dormant_demo.link) out/xosc_dormant_demo.c -o $@

clean:
	rm -rf out xosc_dormant_demo.elf
