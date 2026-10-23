
/*
 * Cobalt Kernel
 * Early kernel initialization
 */

#include <stdint.h>

#define MULTIBOOT_BOOTLOADER_MAGIC 0x2BADB002u

static void halt(void)
{
    __asm__ volatile ("cli");

    for (;;) {
        __asm__ volatile ("hlt");
    }
}

void kernel_main(uint32_t magic, uint32_t multiboot_info)
{
    if (magic != MULTIBOOT_BOOTLOADER_MAGIC)
        halt();

    /*
     * The bootloader supplied the Multiboot information address.
     * Save it for later memory-map and boot-module initialization.
     */
    (void)multiboot_info;

    /*
     * TODO:
     *   Initialize the console.
     *   Initialize the physical memory manager.
     *   Set up interrupt handling.
     */

    halt();
}
