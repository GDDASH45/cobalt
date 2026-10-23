# Cobalt Kernel Build System

CC      := gcc
AS      := as
LD      := ld

CFLAGS  :=  -m32 -std=gnu11 -ffreestanding -fno-stack-protector \
           -fno-pic -fno-pie -Wall -Wextra -O2
ASFLAGS := --32
LDFLAGS := -m elf_i386 -T boot/linker.ld

KCONFIG := Kconfig
CONFIG  := .config
TARGET  := kzImage

# Root-level objects and directories.
obj-y :=
descend-into := boot/ kernel/

-include $(CONFIG)

# Discover objects recursively from directory Makefiles.
COBALT_OBJECTS := $(obj-y)

define cobalt-scan-dir
$(eval obj-y :=)
$(eval descend-into :=)
$(eval include $(1)Makefile)
$(eval COBALT_OBJECTS += $(addprefix $(1),$(obj-y)))
$(foreach sub,$(descend-into),$(call cobalt-scan-dir,$(1)$(sub)))
endef

$(foreach sub,$(descend-into),$(call cobalt-scan-dir,$(sub)))

.PHONY: all clean genconfig

all: $(TARGET)

# C source files.
%.o: %.c
	@printf "  CC      %s\n" "$@"
	@$(CC) $(CFLAGS) -c "$<" -o "$@"

# Preprocessed assembly files.
%.o: %.S
	@printf "  CC      %s\n" "$@"
	@$(CC) $(CFLAGS) -c "$<" -o "$@"

# Plain assembly files.
%.o: %.asm
	@printf "  AS      %s\n" "$@"
	@nasm -f elf32 "$<" -o "$@"

%.o: %.s
	@printf "  AS      %s\n" "$@"
	@$(AS) $(ASFLAGS) "$<" -o "$@"

# Link the kernel.
$(TARGET): $(COBALT_OBJECTS) boot/linker.ld
	@printf "  LD      %s\n" "$@"
	@$(LD) $(LDFLAGS) -o "$@" $(COBALT_OBJECTS)

# Generate a basic .config from Kconfig defaults.
genconfig:
	@awk '\
	function emit() { \
		if (name == "") return; \
		if (type == "bool") { \
			if (value == "") value = "n"; \
			print "CONFIG_" name "=" value; \
		} else if (type == "string") { \
			if (value == "") value = "\"\""; \
			print "CONFIG_" name "=" value; \
		} \
	} \
	/^[[:space:]]*config[[:space:]]+/ { \
		emit(); name = $$2; type = ""; value = ""; next; \
	} \
	name != "" && /^[[:space:]]*bool([[:space:]]|$$)/ { \
		type = "bool"; next; \
	} \
	name != "" && /^[[:space:]]*string([[:space:]]|$$)/ { \
		type = "string"; next; \
	} \
	name != "" && /^[[:space:]]*default[[:space:]]+/ { \
		sub(/^[[:space:]]*default[[:space:]]+/, ""); \
		value = $$0; next; \
	} \
	END { emit(); }' $(KCONFIG) > $(CONFIG).tmp
	@mv $(CONFIG).tmp $(CONFIG)
	@printf "  GEN     %s\n" "$(CONFIG)"

clean:
	@rm -f $(COBALT_OBJECTS) $(TARGET) $(CONFIG).tmp