# NGBL - Nadeem Goodboy BootLoader

NGBL stands for **Nadeem Goodboy BootLoader**. Since Nadeem is such a good boy, this bootloader is made in his honor. He deserves it.

## Build

You need the `i686-elf` binutils. Yes, you need to compile a cross-compiler. Follow the OSDev wiki's instructions:

https://wiki.osdev.org/GCC_Cross-Compiler

Once you've got the toolchain set up, just run:

```bash
make
```

Should work fine. Probably works on your machine too.

## Functionality

**Current Version: 0.4**

***0.1***
Currently supports printing text to the screen - it displays "NGBL loaded" on boot. Simple, but it works. Getting even this working involved battling GAS's quirky 16-bit addressing modes, so it's an achievement.

***0.2***
Currently supports setting up the stack. It has a stack! Let's go!

***0.3***
Currently can draw some cute picture. Lets go!

***0.4***
Currently puts you on protected mode. No BIOS interrupts around but we now got 32 bit. Planning to turn on a20 lines after.

**Plans for 1.0:**
- Kernel loading capabilities
- Additional boot features
- We'll see where this goes

## Emulation

The `run.sh` script launches `qemu-system-i386` for testing. You could boot this on real hardware if you're brave (I haven't tested it personally).

```bash
chmod +x run.sh
./run.sh
```

Watch as "NGBL loaded" appears on your screen. Beautiful.

## Contributions

Clone it. Fork it. Break it. Fix it. Send PRs. I honestly don't care what you do with it.

---

*Written after debugging segment registers for 4 hours straight. Send help.*
load_gdt:
      .equ CODE_SEGMENT, 0x08
      cli # disable interrupts
      lgdt (gdt_descriptor)

      mov %cr0, %eax
      or $1, %al
      mov %eax, %cr0

      ljmp $CODE_SEGMENT, $protected_mode_main
      # long jump to code segment


    gdt_start:
      # this is for the Null segment descriptor
      .long 0x0000_0000
      .long 0x0000_0000

      # the code segment descriptors
      .word 0xFFFF # Limit
      .word 0x0000 # Base
      .byte 0x00   # Base
      .byte 0b10011011 # Access byte
      .byte 0b11001111 # Flags
      .byte 0x00   # Base

      # data segment descriptors
      .word 0xFFFF # Limit
      .word 0x0000 # Base
      .byte 0x00   # Base
      .byte 0b10010011 # Access byte
      .byte 0b11001111 # Flags
      .byte 0x00   # Base
    gdt_end:

    gdt_descriptor:
      .word gdt_end - gdt_start - 1
      .long gdt_start

    .code32
    protected_mode_main:
      .equ DATA_SEGMENT, 0x10
      mov $DATA_SEGMENT, %ax
      mov %ax, %ds
      mov %ax, %fs
      mov %ax, %es
      mov %ax, %ss
      mov %ax, %gs
