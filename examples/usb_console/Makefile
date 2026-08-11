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

emit: out/usb_console.c

out/usb_console.c out/usb_console.link: usb_console.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c usb_console.kl ;; \
	  *) "$(KLIN)" --emit-c usb_console.kl ;; \
	esac

elf: usb_console.elf

usb_console.elf: linker.ld out/usb_console.c out/usb_console.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/usb_console.link) out/usb_console.c -o $@

clean:
	rm -rf out usb_console.elf
