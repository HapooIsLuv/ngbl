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

**Current Version: 0.1**

Currently supports printing text to the screen - it displays "NGBL loaded" on boot. Simple, but it works. Getting even this working involved battling GAS's quirky 16-bit addressing modes, so it's an achievement.

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

Clone it. Fork it. Break it. Fix it. Send PRs. I honestly don't care what you do with it. If you manage to improve this thing, you're a hero. If you're reading this README, you're probably also fighting with bootloaders at 3 AM, so welcome to the club.

---

*Written at 3 AM after debugging segment registers for 4 hours straight. Send help.* 
