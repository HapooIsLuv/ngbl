.globl _start
.code16

.section .text
  _start:
    ljmp $0x0000, $boot
    # we included this so there is no BIOS quirks.
    # sometimes, bootloader moves to seg:0x7c0 offset:0 or seg:0x0000 offset: 0x7c00
    # they inherently point to the same mem addr. Lets do a far jmp to change into a preferred value.
    boot:
      mov $0x0000, %ax # since the BIOS drops off at 0x7c00, we move the ds to 0x7c00
      mov %ax, %ds
      mov %ax, %es

      cli
      mov $0x0000, %ax
      mov %ax, %ss
      mov $0x07c0, %sp # set up a stack pointer

      xor %ax, %ax # clear the register
      sti

      push $msg
      call print_str
      add $2, %sp

      cli
      hlt

    print_str:
      push %bp
      mov %sp, %bp
      pusha


      mov $0x0e, %ah # move the 0x0e to ah (print)
      mov $0x0000, %bx
      mov 4(%bp), %si # move the addr of msg to si
    .char:
      mov (%si), %al
      inc %si
      or $0, %al
      je .done
      int $0x10
      jmp .char
    .done:
      popa
      mov %bp, %sp
      pop %bp
      ret

  msg: .asciz "ngbl loaded"

.fill 510 - (.-_start), 1, 0
.word 0xaa55
