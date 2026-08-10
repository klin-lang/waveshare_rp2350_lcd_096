CC := arm-none-eabi-gcc
CFLAGS := -mcpu=cortex-m33 -mthumb -mfloat-abi=soft -ffreestanding -Os -ffunction-sections -fdata-sections
LDFLAGS := -T linker.ld -Wl,--gc-sections --specs=nano.specs -nostartfiles

KLIN ?= klin
ROOT := ../..

.PHONY: all emit elf clean deps

all: emit

deps:
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" get github/klin-lang/machine_rp@v0.6.0 ;; \
	  *) "$(KLIN)" get github/klin-lang/machine_rp@v0.6.0 ;; \
	esac

emit: out/battery_mv.c

out/battery_mv.c out/battery_mv.link: battery_mv.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c battery_mv.kl ;; \
	  *) "$(KLIN)" --emit-c battery_mv.kl ;; \
	esac

elf: battery_mv.elf

battery_mv.elf: linker.ld out/battery_mv.c out/battery_mv.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/battery_mv.link) out/battery_mv.c -o $@

clean:
	rm -rf out battery_mv.elf
