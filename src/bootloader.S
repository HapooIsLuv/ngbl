.globl _start

.section .text
  .code16
  _start:
    ljmp $0x0000, $boot
    # we included this so there is no BIOS quirks.
    # sometimes, bios moves to seg:0x7c0 offset:0 or seg:0x0000 offset: 0x7c00
    # they inherently point to the same mem addr. Lets do a far jmp to change into a preferred value.
    boot:
      mov $0x0000, %ax
      mov %ax, %ds
      mov %ax, %es

      cli
      mov $0x0000, %ax
      mov %ax, %ss
      mov $0x07c0, %sp # set up a stack pointer

      xor %ax, %ax # clear the register
      sti

      call clear_screen

      push $0x13 # mode 13h for video mode. (320x200)
      call set_video_mode
      add $2, %sp

      push $art
      call draw
      add $2, %sp

      call wait
      call clear_screen

      push $0x03
      call set_video_mode
      add $2, %sp

      push $0x00
      call move_cursor
      add $2, %sp

      push $msg
      call print_str
      add $2, %sp

      call wait_for_key

      jmp load_gdt

    clear_screen:
      push %bp
      mov %sp, %bp
      pusha

      mov $0x07, %ah # scroll down
      mov $0x00, %al # clear the whole screen
      mov $0x07, %bh
      mov $0x00, %cx
      mov $0x18, %dh
      mov $0x4f, %dl
      int $0x10

      popa
      mov %bp, %sp
      pop %bp
      ret


    move_cursor:
      push %bp
      mov %sp, %bp
      pusha

      mov 4(%bp), %dx
      mov $0x02, %ah
      mov $0x00, %bh
      int $0x10

      popa
      mov %bp, %sp
      pop %bp
      ret

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
      je .done_str
      int $0x10
      jmp .char
    .done_str:
      popa
      mov %bp, %sp
      pop %bp
      ret


    wait:
      push %bp
      mov %sp, %bp
      pusha

      mov $0x86, %ah #set ah as 0x86, which is waiting
      mov $0x00, %al

#     these two are used for time intervals.
#     cx is high word, dx is low word
#     this is 3 seconds
      mov $0x002d, %cx
      mov $0xc6c0, %dx
      int $0x15

      popa
      mov %bp, %sp
      pop %bp
      ret

    wait_for_key:
      push %bp
      mov %sp, %bp
      pusha

      mov $0x00, %ah # wait for keystroke
      int $0x16

      popa
      mov %bp, %sp
      pop %bp
      ret

    set_video_mode:
      push %bp
      mov %sp, %bp
      pusha

      mov $0x00, %ah # BIOS int: set video mode
      mov 4(%bp), %al
      int $0x10

      popa
      mov %bp, %sp
      pop %bp
      ret

    #TODO: implement image scaling. This is too small
    draw:
      .equ PXL_COL_START, 110
      .equ PXL_ROW_START, 50

      .equ IMG_MAX_HEIGHT, (PXL_ROW_START + 9) - 1    # 9 is img height. -1 is for padding
      .equ IMG_MAX_LENGTH, (PXL_COL_START + 10) - 1   # 10 is the img length. -1 is for padding
      push %bp
      mov %sp, %bp
      pusha

      mov $0x0c, %ah # BIOS int: set graphic pixel
      mov $0x00, %bh # set page num to 0
      mov $PXL_COL_START, %cx # cx (column) - start from 110th pixel
      mov $PXL_ROW_START, %dx # dx (rows) - start from 50th pixel

      mov 4(%bp), %si
      jmp .color_pixel

    .move_row:
      # check if dx has reached the max amount, yes then finished
      cmp $IMG_MAX_HEIGHT, %dx
      je .done_pixel
      # else, we just move the row
      inc %dx
    .reset_col:
      mov $PXL_COL_START, %cx

    .color_pixel:
      mov (%si), %al # we move the byte to %al
      inc %si # increment the ptr
      int $0x10
      # we have to check if cx has reached the max amount (idk)
      cmp $IMG_MAX_LENGTH, %cx
      je .move_row
      inc %cx
      jmp .color_pixel

    .done_pixel:
      popa
      mov %bp, %sp
      pop %bp
      ret

    load_gdt:
      .equ CODE_SEG, 0x08
      cli # disable interrupts
      lgdt gdt_descriptor

      mov %cr0, %eax
      or $0x01, %al
      mov %eax, %cr0

      ljmp $CODE_SEG, $pm_main

    gdt_start:
      null_segment_descriptor:
        .long 0x00
        .long 0x00

      code_segment_descriptor:
        .word 0xFFFF # Limit
        .word 0x0000 # Base
        .byte 0x00   # Base
        .byte 0b10011011 # Access byte
        .byte 0b11001111 # Flags & limit
        .byte 0x0 # Base

      data_segment_register:
        .word 0xFFFF # Limit
        .word 0x0000 # Base
        .byte 0x00   # Base
        .byte 0b10010011 # access byte
        .byte 0b11001111 # Flags & limit
        .byte 0x0   # Base
    gdt_end:

    gdt_descriptor:
      .word gdt_end - gdt_start - 1
      .long gdt_start

    .code32
    pm_main:
      .equ DATA_SEG, 0x10
      mov $DATA_SEG, %ax
      mov %ax, %ds
      mov %ax, %es
      mov %ax, %fs
      mov %ax, %gs
      mov %ax, %ss

      mov $0x9c00, %ebp
      mov %ebp, %esp

      mov $0xB8000, %edi
      movw $0x0F41, (%edi)

      # TODO: turn on A20 line
      hlt



  msg: .asciz "[ OK ] NGBL booted!\r\n\r\npress any key to continue boot seq"
  art:.byte 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf
      .byte 0xf, 0xf, 0x4, 0x4, 0xf, 0xf, 0x4, 0x4, 0xf, 0xf
      .byte 0xf, 0x4, 0xd, 0xd, 0x4, 0x4, 0xd, 0xd, 0x4, 0xf
      .byte 0xf, 0x4, 0xd, 0xd, 0xd, 0xd, 0xd, 0xd, 0x4, 0xf
      .byte 0xf, 0x4, 0xd, 0xd, 0xd, 0xd, 0xd, 0xd, 0x4, 0xf
      .byte 0xf, 0xf, 0x4, 0xd, 0xd, 0xd, 0xd, 0x4, 0xf, 0xf
      .byte 0xf, 0xf, 0xf, 0x4, 0xd, 0xd, 0x4, 0xf, 0xf, 0xf
      .byte 0xf, 0xf, 0xf, 0xf, 0x4, 0x4, 0xf, 0xf, 0xf, 0xf
      .byte 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0xf


.fill 510 - (.-_start), 1, 0
.word 0xaa55
