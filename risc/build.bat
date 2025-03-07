del *.o *.ver *.bin *.hex *.mif

clang -c --target=riscv32 -fno-builtin -ffreestanding -nostdlib -march=rv32i -mabi=ilp32 main.c -O3
clang -c --target=riscv32 -fno-builtin -ffreestanding -nostdlib -march=rv32i -mabi=ilp32 main.c -S
clang -c --target=riscv32 -march=rv32i -c -o init.o init.s
ld.lld -T link.ld --oformat=binary libgcc.a main.o init.o -o main.bin 
python bin_to_mif.py main.bin output.mif 32 8192

del *.o *.ver *.hex