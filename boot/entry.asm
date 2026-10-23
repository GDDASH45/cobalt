
; Cobalt Kernel
; 32-bit x86 Multiboot 1 entry point

BITS 32

section .multiboot
align 4

MULTIBOOT_MAGIC    equ 0x1BADB002
MULTIBOOT_FLAGS    equ 0x00000003
MULTIBOOT_CHECKSUM equ -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

dd MULTIBOOT_MAGIC
dd MULTIBOOT_FLAGS
dd MULTIBOOT_CHECKSUM

section .bss nobits
align 16

stack_bottom:
    resb 16384
stack_top:

section .text
global _start
extern kernel_main

_start:
    cli

    ; Set up the kernel stack.
    mov esp, stack_top
    xor ebp, ebp

    ; Multiboot 1:
    ; EAX = bootloader magic
    ; EBX = Multiboot information pointer
    ;
    ; Push arguments in reverse order for cdecl.
    push ebx
    push eax

    call kernel_main

.hang:
    cli
    hlt
    jmp .hang

section .note.GNU-stack noalloc noexec nowrite progbits
