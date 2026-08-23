# -------------------------------------------------
# Project
# -------------------------------------------------
TARGET      := crpg
MAIN_CONFIG := main.cfg
LOADER_CONFIG := loader.cfg

BUILD_DIR   := build
OBJ_DIR     := $(BUILD_DIR)/obj
SRC_DIR     := src
LOADER_DIR  := loader
DATA_DIR    := data
MAP_DIR     := $(DATA_DIR)/maps
MAP_LIST    := $(MAP_DIR)/maps.txt
MANIFEST    := $(DATA_DIR)/manifest.txt
MANIFEST_INC:= $(BUILD_DIR)/manifest.inc

FILENAMES   := $(BUILD_DIR)/maps/filenames.s

OUT         := $(BUILD_DIR)/$(TARGET).prg
LOADER_OUT  := $(BUILD_DIR)/loader.prg
DISK        := $(BUILD_DIR)/$(TARGET).d64
PACKED_DISK := $(BUILD_DIR)/$(TARGET)_final.d64
LABELS      := $(BUILD_DIR)/$(TARGET).lbl
MAP         := $(BUILD_DIR)/$(TARGET).map

LOADER_NAME := loader

# -------------------------------------------------
# Tools
# -------------------------------------------------
CL65        := cl65
CC1541      := cc1541
MAPP        := mapp
MAPP-LISTER := mapp-lister
PACK-ASSETS := pack-assets
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
ASMFLAGS   := -t $(TARGET_SYS) --asm-include-dir $(SRC_DIR) --asm-include-dir $(BUILD_DIR)
LDFLAGS    := -t $(TARGET_SYS) -Ln $(LABELS) -m $(MAP)
LOADER_LDFLAGS := -t $(TARGET_SYS)

BOOT_TRACK  := 30
BOOT_SECTOR := 0
BOOT_COUNT  := 1

# -------------------------------------------------
# Sources
# -------------------------------------------------
SOURCES      := $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/*/*.s)
LOADER_SOURCES := $(wildcard $(LOADER_DIR)/*.s)
DATA_FILES   := $(wildcard $(DATA_DIR)/*.bin)
MAP_FILES    := $(wildcard $(MAP_DIR)/*.bin)

# -------------------------------------------------
# Objects
# -------------------------------------------------
OBJS := $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(SOURCES))
DEPS := $(OBJS:.o=.d)

LOADER_OBJS := $(patsubst $(LOADER_DIR)/%.s,$(OBJ_DIR)/loader/%.o,$(LOADER_SOURCES))
LOADER_DEPS := $(LOADER_OBJS:.o=.d)

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

all: $(PACKED_DISK)

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

# loader is linked independently of the game
$(OBJ_DIR)/loader/%.o: $(LOADER_DIR)/%.s
	@mkdir -p $(dir $@)
	@printf "CA65:  %s\n" "$<"
	$(Q)$(CL65) -c $(ASMFLAGS) --create-dep $(@:.o=.d) -o $@ $<

-include $(DEPS)
-include $(LOADER_DEPS)

# -------------------------------------------------
# Link
# -------------------------------------------------
$(OUT): $(OBJS) $(MAIN_CONFIG)
	@mkdir -p $(dir $@)
	@printf "LD65:  %s\n" "$@"
	$(Q)$(CL65) -C $(MAIN_CONFIG) $(LDFLAGS) -o $@ $(OBJS)

$(LOADER_OUT): $(LOADER_OBJS) $(LOADER_CONFIG)
	@mkdir -p $(dir $@)
	@printf "LD65:  %s\n" "$@"
	$(Q)$(CL65) -C $(LOADER_CONFIG) $(LOADER_LDFLAGS) -o $@ $(LOADER_OBJS)

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
$(DISK): $(LOADER_OUT) $(OUT) $(PROC_MAP_FILES) $(DATA_FILES)
	@printf "CC1541: creating %s\n" "$@"
	$(Q)$(CC1541) -n "$(TARGET)" -i "jay" \
		-f "$(LOADER_NAME)" -w $(LOADER_OUT) \
		-f "$(TARGET)" -w $(OUT) \
		$(foreach data,$(DATA_FILES), \
			-f "$(notdir $(basename $(data)))" -T SEQ -w $(data)) \
		$(foreach map,$(PROC_MAP_FILES), \
			-f "$(notdir $(basename $(map)))" -T SEQ -w $(map)) \
		$(DISK)

# final disk with all the hidden data packed in
$(PACKED_DISK): $(DISK) $(MANIFEST)
	@printf "PACK-ASSETS: creating %s\n" "$@"
	$(Q)$(PACK-ASSETS) "$(DISK)" "$@" "$(MANIFEST)" "$(MANIFEST_INC)" -t $(BOOT_TRACK) -s $(BOOT_SECTOR) -c $(BOOT_COUNT)

# -------------------------------------------------
# Utility
# -------------------------------------------------
clean:
	@printf "Cleaning build directory...\n"
	rm -rf $(BUILD_DIR)

rebuild: clean all

run: $(PACKED_DISK)
	$(EMU) -moncommands $(LABELS) $(PACKED_DISK)

help:
	@printf "Targets:\n"
	@printf "  make          build %s (with %s)\n" "$(OUT)" "$(LOADER_OUT)"
	@printf "  make clean    remove build directory\n"
	@printf "  make rebuild  full rebuild\n"
	@printf "  make run      build and launch in VICE (%s)\n" "$(EMU)"
	@printf "  make V=1      show full compiler/linker commands\n"