clang --target=riscv32 -O3 -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding main.c init.s -L. -lgcc -T link.ld -o output.elf
objcopy -O ihex output.elf output.hex --change-addresses=2
rm output.elf