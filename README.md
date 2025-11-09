NGBL stands for Nadeem Goodboy BootLoader. Since Nadeem is such a good boy, This bootloader is made for his honor.

##Build##
To build the bootloader, you need the i686-elf binutils. You can follow that in the OS dev Cross compiler section. 

https://wiki.osdev.org/GCC_Cross-Compiler

after that, you can type ```make``` to build the bootloader. 

##Functionality##
It currently has only printing capabilities. As it hits 1.0, it will be able to boot kernels. That is in the future. This release is only version 0.1.

##Emulation##
The run.sh shell script is there for emulation purposes. You can of course boot it to a drive if you have one (I haven't tested it). It runs qemu-system-i386. You might have to make it executable using:
```shell
# chmod +x run.sh
```

##contributions##
You are free to clone this repo and play around. I honestly don't give a fuck.
