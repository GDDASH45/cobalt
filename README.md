# Cobalt Kernel

**Cobalt** is a small experimental operating system kernel written primarily in C, with x86 assembly for low-level bootstrapping.

The project aims to build a kernel from scratch with a simple, modular build system and a clear directory structure.

## Project Status

Cobalt is in early development.

Current goals:
- [x] Establish a recursive Makefile-based build system
- [x] Add a 32-bit x86 Multiboot 1 entry point
- [x] Add a linker script for the kernel ELF image
- [x] Add early C kernel initialization
- [ ] Implement VGA text-mode console output
- [ ] Add interrupt handling
- [ ] Implement physical memory management
- [ ] Add keyboard input
- [ ] Create a basic kernel command line

Features marked complete represent initial implementations, not necessarily a fully tested bootable system.

## Architecture

- **Target:** 32-bit x86 (`i386`)
- **Languages:** C and NASM assembly
- **Boot protocol:** Multiboot 1
- **Build system:** GNU Make
- **Compiler:** GCC
- **Linker:** GNU ld
- **Output:** `kzImage` (currently a linked ELF kernel image)

## Building

Install the required development tools on Ubuntu:

```bash
sudo apt install build-essential nasm binutils grub-common
```

Generate the configuration:

```bash
make genconfig
```

Build the kernel:

```bash
make
```

Clean generated objects and the kernel image:

```bash
make clean
```

The build system prints compilation and linking steps using labels such as `CC`, `AS`, and `LD`.

## Configuration

Cobalt uses a `Kconfig` file to define configuration options. Run:

```bash
make genconfig
```

This generates `.config` from the supported configuration defaults.

The configuration system is currently a minimal implementation and does not yet support the full Linux Kconfig language.

## Build System

Each directory can provide a `Makefile` containing object declarations:

```makefile
obj-y += start.o
```

Directories can include additional subdirectories:

```makefile
descend-into += drivers/
```

The top-level Makefile recursively collects the declared objects and compiles them into the kernel image.

## Repository Layout

```text
cobalt/
├── Makefile
├── Kconfig
├── README.md
├── LICENSE
├── boot/
│   ├── Makefile
│   ├── entry.asm
│   └── linker.ld
├── kernel/
│   ├── Makefile
│   └── start.c
├── drivers/
├── mm/
└── .config
```

Some directories may remain empty until their subsystems are implemented.

## Booting

Cobalt is designed to be loaded by a Multiboot 1-compatible bootloader such as GRUB.

The kernel entry point establishes its stack and calls `kernel_main()` in C. A linker script places the Multiboot header near the beginning of the kernel image.

Before attempting to boot, verify the image:

```bash
grub-file --is-x86-multiboot kzImage
```

An exit status of `0` indicates that GRUB recognizes the Multiboot 1 header. It does not guarantee that the kernel will boot successfully.

## License

Cobalt Kernel is intended to be licensed under **GNU General Public License v2.0 only (GPL-2.0-only)**.

See [`LICENSE`](LICENSE) for the complete license text.

## Contributing

Cobalt is an experimental kernel project. Contributions should keep the build system simple, preserve the freestanding environment, and follow the existing directory-based organization.