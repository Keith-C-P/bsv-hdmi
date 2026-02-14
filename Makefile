# -------- FPGA Configuration --------
TOP = mkTop
PART = xc7a200tsbg484-1

# -------- Directories --------
BUILD_DIR = build
VERILOG_DIR = $(BUILD_DIR)/verilog
OBJ_DIR = obj_dir

# -------- Tools --------
BSC = bsc
VERILATOR = verilator
VIVADO = vivado

# -------- Flags --------
BSC_FLAGS = -u -verilog
BSC_SIM_FLAGS = -sim -g mkTB -u
VERILATOR_FLAGS = --cc --exe --build --trace -Wall -Wno-fatal

# -------- Color codes --------
BLUE := \033[1;34m
GREEN := \033[1;32m
PURPLE := \033[1;35m
CYAN := \033[1;36m
YELLOW := \033[1;33m
RED := \033[1;31m
MAGENTA := \033[0;35m
RESET := \033[0m

.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

# -------- Simulation Targets --------
.PHONY: sim run sim-build sim-clean

sim-build: $(OBJ_DIR)/V$(TARGET)
	@echo "$(GREEN)Simulation build complete$(RESET)"

$(OBJ_DIR)/V$(TARGET): $(TARGET).bsv sim_main.cpp
	@echo "$(MAGENTA)=== Building $(TARGET) for Simulation ===$(RESET)"
	@mkdir -p $(BUILD_DIR) $(VERILOG_DIR)
	@echo "$(BLUE)Compiling BSV to Verilog...$(RESET)"
	$(BSC) +RTS -K128M -RTS \
		$(BSC_FLAGS) \
		-vdir $(VERILOG_DIR) \
		-bdir $(BUILD_DIR) \
		-info-dir $(BUILD_DIR) \
		-g mk$(TARGET) \
		-p +:src \
		$(TARGET).bsv
	@echo "$(BLUE)Compiling with Verilator...$(RESET)"
	$(VERILATOR) $(VERILATOR_FLAGS) \
		--top-module mk$(TARGET) \
		-o V$(TARGET) \
		$(VERILOG_DIR)/mk$(TARGET).v \
		sim_main.cpp
	@echo "$(GREEN)Verilator build finished OK$(RESET)"

sim run: sim-build
	@echo "$(MAGENTA)=== Running simulation ===$(RESET)"
	./$(OBJ_DIR)/V$(TARGET)
	@if [ -f dump.vcd ]; then \
		echo "$(GREEN)VCD file generated: dump.vcd$(RESET)"; \
	fi

sim-clean:
	rm -rf $(OBJ_DIR) dump.vcd

# -------- FPGA Targets --------
.PHONY: verilog bitstream mcs fpga-clean all

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	mkdir -p $(VERILOG_DIR)

verilog: $(BUILD_DIR)
	@echo "$(PURPLE)=== Building Verilog for FPGA ===$(RESET)"
	@echo "$(BLUE)Compiling BSV...$(RESET)"
	bsc -u -verilog -g $(TOP) \
		-vdir $(VERILOG_DIR) \
		-bdir $(BUILD_DIR) \
		-info-dir $(BUILD_DIR) \
		-show-compiles \
		-show-schedule \
		-show-module-use \
		-steps 999999999 \
		-verbose \
		-p +:src \
		+RTS -K100M -RTS \
		src/fpga_top.bsv
	@echo "$(BLUE)BSV Compiled...$(RESET) $(GREEN)OK$(RESET)"
	@echo "$(BLUE)Copying RTL files...$(RESET)"
	@cp src/rtl/hdmi/* $(VERILOG_DIR)
	@echo "$(BLUE)Files copied...$(RESET) $(GREEN)OK$(RESET)"

bitstream: verilog
	@echo "$(PURPLE)=== Building Bitstream ===$(RESET)"
	@echo "$(BLUE)Running Vivado...$(RESET)"
	$(VIVADO) -mode batch -source build.tcl
	@echo "$(BLUE)Bitstream built...$(RESET) $(GREEN)OK$(RESET)"

mcs: bitstream
	@echo "$(PURPLE)=== Building MCS ===$(RESET)"
	@echo "$(BLUE)Generating MCS file...$(RESET)"
	$(VIVADO) -mode batch -source generate_mcs.tcl
	@echo "$(BLUE)MCS built...$(RESET) $(GREEN)OK$(RESET)"

all: mcs

# -------- Cleaning --------
.PHONY: clean

fpga-clean:
	@echo "$(RED)=== Cleaning FPGA build files ===$(RESET)"
	rm -rf $(BUILD_DIR) *.jou *.log *.str .Xil
	@echo "$(BLUE)FPGA clean finished...$(RESET) $(GREEN)OK$(RESET)"

clean: fpga-clean sim-clean
	@echo "$(RED)=== Full clean complete ===$(RESET)"

# -------- Help --------
.PHONY: help

help:
	@echo "$(CYAN)Simulation targets:$(RESET)"
	@echo "  make sim TARGET=Foo      Build and simulate Foo.bsv (generates dump.vcd)"
	@echo "  make run TARGET=Foo      Same as sim"
	@echo "  make sim-build TARGET=Foo  Only build simulation, don't run"
	@echo "  make sim-clean           Clean simulation files"
	@echo ""
	@echo "$(CYAN)FPGA targets:$(RESET)"
	@echo "  make verilog             Generate Verilog from BSV"
	@echo "  make bitstream           Synthesize bitstream"
	@echo "  make mcs                 Generate MCS file for flash"
	@echo "  make all                 Build everything (default: mcs)"
	@echo "  make fpga-clean          Clean FPGA build files"
	@echo ""
	@echo "$(CYAN)General:$(RESET)"
	@echo "  make clean               Clean everything"
	@echo "  make help                Show this help"
