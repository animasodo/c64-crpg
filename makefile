# -------------------------------------------------
# Project
# -------------------------------------------------
TARGET      := crpg
CONFIG    	:= c64.cfg

BUILD_DIR   := build
SRC_DIR		:= src
INC_DIR		:= include
DATA_DIR	:= data
MAP_DIR		:= $(DATA_DIR)/maps
MAP_LIST	:= $(MAP_DIR)/maps.txt
FILENAMES	:= $(BUILD_DIR)/maps/filenames.s
OUT         := $(BUILD_DIR)/$(TARGET).prg
DISK        := $(BUILD_DIR)/$(TARGET).d64
LABELS      := $(BUILD_DIR)/$(TARGET).lbl
MAP         := $(BUILD_DIR)/$(TARGET).map

# -------------------------------------------------
# Tools
# -------------------------------------------------
CL65		:= cl65
CC1541		:= cc1541
MAPP		:= mapp
MAPP-LISTER	:= mapp-lister

# -------------------------------------------------
# Flags
# -------------------------------------------------
CFLAGS		:= -Osir -Cl -I $(INC_DIR)
LDFLAGS 	:= -Ln $(LABELS) -m $(MAP)

# -------------------------------------------------
# Sources
# -------------------------------------------------
C_SOURCES		:= $(wildcard $(SRC_DIR)/*.c)
DATA_SOURCES	:= $(wildcard $(DATA_DIR)/*.c)
ASM_SOURCES		:= $(wildcard $(SRC_DIR)/*.s)
DATA_FILES		:= $(wildcard $(DATA_DIR)/*.bin)
MAP_FILES		:= $(wildcard $(MAP_DIR)/*.bin)

SOURCES			:= $(C_SOURCES) $(DATA_SOURCES) $(ASM_SOURCES)

# -------------------------------------------------
# Processed Maps
# -------------------------------------------------
PROC_MAP_DIR	:= $(BUILD_DIR)/maps
PROC_MAP_FILES	:= $(patsubst $(MAP_DIR)/%.bin,$(PROC_MAP_DIR)/%.bin,$(MAP_FILES))

# -------------------------------------------------
# Phony targets
# -------------------------------------------------
.PHONY: all clean rebuild help

all: $(DISK)

# -------------------------------------------------
# Build
# -------------------------------------------------
$(FILENAMES): $(MAP_LIST) | $(BUILD_DIR)
	@printf "MAPP-LISTER: creating %s\n" "$@"
	$(MAPP-LISTER) $(MAP_LIST) $@

$(OUT): $(FILENAMES) $(SOURCES) | $(BUILD_DIR)
	@printf "CL65: building %s\n" "$@"
	$(CL65) -C $(CONFIG) $(CFLAGS) $(ASFLAGS) $(LDFLAGS) -o $@ \
	$(SOURCES)

$(PROC_MAP_DIR)/%.bin: $(MAP_DIR)/%.bin $(MAP_DIR)/%.json | $(PROC_MAP_DIR)
	@printf "MAPP: processing %s\n" "$<"
	$(MAPP) $< -j $(MAP_DIR)/$*.json -l $(MAP_LIST) -o $@

$(DISK): $(FILENAMES) $(OUT) $(PROC_MAP_FILES)
	@printf "CC1541: creating %s\n" "$@"
	$(CC1541) -n "$(TARGET)" -i "jay" \
		-f "$(TARGET)" -w $(OUT) \
		$(foreach data,$(DATA_FILES), \
			-f "$(notdir $(basename $(data)))" -T SEQ -w $(data)) \
		$(foreach map,$(PROC_MAP_FILES), \
			-f "$(notdir $(basename $(map)))" -T SEQ -w $(map)) \
		$(DISK)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(PROC_MAP_DIR): | $(BUILD_DIR)
	@mkdir -p $(PROC_MAP_DIR)

# -------------------------------------------------
# Utility
# -------------------------------------------------
clean:
	@printf "Cleaning build directory...\n"
	rm -rf $(BUILD_DIR)

rebuild: clean all

help:
	@printf "Targets:\n"
	@printf "  make          build %s\n" "$(OUT)"
	@printf "  make clean    remove build directory\n"
	@printf "  make rebuild  full rebuild\n"
