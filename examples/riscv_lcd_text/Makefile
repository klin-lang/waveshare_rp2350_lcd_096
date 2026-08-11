CC := riscv64-unknown-elf-gcc
CFLAGS := -march=rv32imac -mabi=ilp32 -ffreestanding -Os -ffunction-sections -fdata-sections
LDFLAGS := -T linker.ld -Wl,--gc-sections -nostdlib -march=rv32imac -mabi=ilp32

KLIN ?= klin
ROOT := ../..

.PHONY: all emit elf clean deps

all: emit

deps:
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" get github/klin-lang/machine_rp@v0.8.0 ;; \
	  *) "$(KLIN)" get github/klin-lang/machine_rp@v0.8.0 ;; \
	esac

emit: out/riscv_lcd_text.c

out/riscv_lcd_text.c out/riscv_lcd_text.link: riscv_lcd_text.kl $(wildcard $(ROOT)/waveshare_rp2350_lcd_096/*.kl)
	@mkdir -p out
	@case "$(KLIN)" in \
	  *.dart) dart run "$(KLIN)" --emit-c riscv_lcd_text.kl ;; \
	  *) "$(KLIN)" --emit-c riscv_lcd_text.kl ;; \
	esac

elf: riscv_lcd_text.elf

riscv_lcd_text.elf: linker.ld out/riscv_lcd_text.c out/riscv_lcd_text.link
	$(CC) $(CFLAGS) -I. $(LDFLAGS) $$(cat out/riscv_lcd_text.link) out/riscv_lcd_text.c -o $@

clean:
	rm -rf out riscv_lcd_text.elf
