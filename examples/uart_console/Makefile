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

emit: out/uart_console.c

out/uart_console.c out/uart_console.link: uart_console.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c uart_console.kl ;; \
	  *) "$(KLIN)" --emit-c uart_console.kl ;; \
	esac

elf: uart_console.elf

uart_console.elf: linker.ld out/uart_console.c out/uart_console.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/uart_console.link) out/uart_console.c -o $@

clean:
	rm -rf out uart_console.elf
