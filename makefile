all:
	@mkdir -p obj
	i686-elf-as -o obj/bootloader.o src/bootloader.S
	i686-elf-ld -o boot.bin --oformat binary -T linker.ld obj/bootloader.o

clean:
	rm -r obj
	rm boot.bin

.PHONY:
	all, clean
