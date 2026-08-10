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

emit: out/temp_chip.c

out/temp_chip.c out/temp_chip.link: temp_chip.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c temp_chip.kl ;; \
	  *) "$(KLIN)" --emit-c temp_chip.kl ;; \
	esac

elf: temp_chip.elf

temp_chip.elf: linker.ld out/temp_chip.c out/temp_chip.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/temp_chip.link) out/temp_chip.c -o $@

clean:
	rm -rf out temp_chip.elf
