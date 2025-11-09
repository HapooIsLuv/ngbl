.globl _start
.code16gcc

.section .text
  _start:
    print:
      mov $0x0e, %ah # move the 0x0e to ah (print)
      mov $0x0000, %bx
      mov $msg, %si # move the addr of msg to si
    .char:
      mov (%si), %al
      inc %si
      or $0, %al
      je done
      int $0x10
      jmp .char
    done:
      cli
      hlt
  msg: .asciz "ngbl loaded"

.fill 510 - (.-_start), 1, 0
.word 0xaa55
