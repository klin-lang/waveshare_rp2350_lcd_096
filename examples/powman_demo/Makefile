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

emit: out/powman_demo.c

out/powman_demo.c out/powman_demo.link: powman_demo.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c powman_demo.kl ;; \
	  *) "$(KLIN)" --emit-c powman_demo.kl ;; \
	esac

elf: powman_demo.elf

powman_demo.elf: linker.ld out/powman_demo.c out/powman_demo.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/powman_demo.link) out/powman_demo.c -o $@

clean:
	rm -rf out powman_demo.elf
