# -------------------------------------------------
# Project
# -------------------------------------------------
TARGET      := crpg
CONFIG      := c64.cfg

BUILD_DIR   := build
OBJ_DIR     := $(BUILD_DIR)/obj
SRC_DIR     := src
DATA_DIR    := data
MAP_DIR     := $(DATA_DIR)/maps
MAP_LIST    := $(MAP_DIR)/maps.txt

FILENAMES   := $(BUILD_DIR)/maps/filenames.s

OUT         := $(BUILD_DIR)/$(TARGET).prg
DISK        := $(BUILD_DIR)/$(TARGET).d64
LABELS      := $(BUILD_DIR)/$(TARGET).lbl
MAP         := $(BUILD_DIR)/$(TARGET).map

# -------------------------------------------------
# Tools
# -------------------------------------------------
CL65        := cl65
CC1541      := cc1541
MAPP        := mapp
MAPP-LISTER := mapp-lister
EMU         := x64sc

# -------------------------------------------------
# Verbosity: `make` stays quiet, `make V=1` shows real commands
# -------------------------------------------------
ifdef V
  Q :=
else
  Q := @
endif

# -------------------------------------------------
# Flags
# -------------------------------------------------
TARGET_SYS := c64
ASMFLAGS   := -t $(TARGET_SYS) --asm-include-dir $(SRC_DIR)
LDFLAGS    := -t $(TARGET_SYS) -Ln $(LABELS) -m $(MAP)

# -------------------------------------------------
# Sources
# -------------------------------------------------
SOURCES      := $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/*/*.s)
DATA_FILES   := $(wildcard $(DATA_DIR)/*.bin)
MAP_FILES    := $(wildcard $(MAP_DIR)/*.bin)

# -------------------------------------------------
# Objects
# -------------------------------------------------
OBJS := $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(SOURCES))
DEPS := $(OBJS:.o=.d)

# -------------------------------------------------
# Processed Maps
# -------------------------------------------------
PROC_MAP_DIR   := $(BUILD_DIR)/maps
PROC_MAP_FILES := $(patsubst $(MAP_DIR)/%.bin,$(PROC_MAP_DIR)/%.bin,$(MAP_FILES))

# -------------------------------------------------
# Housekeeping
# -------------------------------------------------
.PHONY: all clean rebuild help run
.DELETE_ON_ERROR:
MAKEFLAGS += -r

all: $(DISK)

# -------------------------------------------------
# Object files
# -------------------------------------------------
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s $(FILENAMES)
	@mkdir -p $(dir $@)
	@printf "CA65:  %s\n" "$<"
	$(Q)$(CL65) -c $(ASMFLAGS) --create-dep $(@:.o=.d) -o $@ $<

# generated map filename table
$(FILENAMES): $(MAP_LIST)
	@mkdir -p $(dir $@)
	@printf "MAPP-LISTER: creating %s\n" "$@"
	$(Q)$(MAPP-LISTER) $(MAP_LIST) $@

-include $(DEPS)

# -------------------------------------------------
# Link
# -------------------------------------------------
$(OUT): $(OBJS) $(CONFIG)
	@mkdir -p $(dir $@)
	@printf "LD65:  %s\n" "$@"
	$(Q)$(CL65) -C $(CONFIG) $(LDFLAGS) -o $@ $(OBJS)

# -------------------------------------------------
# Maps
# -------------------------------------------------
$(PROC_MAP_DIR)/%.bin: $(MAP_DIR)/%.bin $(MAP_DIR)/%.json
	@mkdir -p $(dir $@)
	@printf "MAPP:  %s\n" "$<"
	$(Q)$(MAPP) $< -j $(MAP_DIR)/$*.json -l $(MAP_LIST) -o $@

# -------------------------------------------------
# Disk image
# -------------------------------------------------
$(DISK): $(OUT) $(PROC_MAP_FILES) $(DATA_FILES)
	@printf "CC1541: creating %s\n" "$@"
	$(Q)$(CC1541) -n "$(TARGET)" -i "jay" \
		-f "$(TARGET)" -w $(OUT) \
		$(foreach data,$(DATA_FILES), \
			-f "$(notdir $(basename $(data)))" -T SEQ -w $(data)) \
		$(foreach map,$(PROC_MAP_FILES), \
			-f "$(notdir $(basename $(map)))" -T SEQ -w $(map)) \
		$(DISK)

# -------------------------------------------------
# Utility
# -------------------------------------------------
clean:
	@printf "Cleaning build directory...\n"
	rm -rf $(BUILD_DIR)

rebuild: clean all

run: $(DISK)
	$(EMU) -moncommands $(LABELS) $(DISK)

help:
	@printf "Targets:\n"
	@printf "  make          build %s\n" "$(OUT)"
	@printf "  make clean    remove build directory\n"
	@printf "  make rebuild  full rebuild\n"
	@printf "  make run      build and launch in VICE (%s)\n" "$(EMU)"
	@printf "  make V=1      show full compiler/linker commands\n"