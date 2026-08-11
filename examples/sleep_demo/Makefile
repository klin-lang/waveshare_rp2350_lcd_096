CC := arm-none-eabi-gcc
CFLAGS := -mcpu=cortex-m33 -mthumb -mfloat-abi=soft -ffreestanding -Os -ffunction-sections -fdata-sections
LDFLAGS := -T linker.ld -Wl,--gc-sections --specs=nano.specs -nostartfiles

KLIN ?= klin
ROOT := ../..

.PHONY: all emit elf clean deps

all: emit

deps:
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" get github/klin-lang/machine_rp@v0.9.0 ;; \
	  *) "$(KLIN)" get github/klin-lang/machine_rp@v0.9.0 ;; \
	esac

emit: out/sleep_demo.c

out/sleep_demo.c out/sleep_demo.link: sleep_demo.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c sleep_demo.kl ;; \
	  *) "$(KLIN)" --emit-c sleep_demo.kl ;; \
	esac

elf: sleep_demo.elf

sleep_demo.elf: linker.ld out/sleep_demo.c out/sleep_demo.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/sleep_demo.link) out/sleep_demo.c -o $@

clean:
	rm -rf out sleep_demo.elf
