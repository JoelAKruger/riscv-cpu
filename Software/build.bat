del *.o *.ver *.bin *.hex *.mif

clang -c -Iinclude --target=riscv32 -fno-builtin -ffreestanding -nostdlib -march=rv32i -mabi=ilp32 src/main.c -O3
REM clang -c --target=riscv32 -fno-builtin -ffreestanding -nostdlib -march=rv32i -mabi=ilp32 main.c -S
clang -c --target=riscv32 -march=rv32i -c -o init.o src/init.s
ld.lld -T src/link.ld --oformat=binary lib/libgcc.a lib/libm.a main.o init.o -o main.bin 
python bin_to_mif.py main.bin output.mif 32 8192

del *.o *.ver *.hex