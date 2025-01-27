default: run

PROJECT = core
FILELIST = $(PROJECT)/$(PROJECT).f

TOP_MODULE = top
TB_PROGRAM = $(PROJECT)/src/tb_verilator.cpp
OBJ_DIR = obj_dir/
SIM_NAME = sim
VERILATOR_FLAGS = ""

# mold, ld: (NOTE: verilator automatically uses mold if mold is present.)
# - ref: https://github.com/verilator/verilator/issues/4289
LINKER = mold
COMPILER = g++ # g++ or clang++
VERILATOR_FLAGS += -MAKEFLAGS "OBJCACHE=ccache CXX=$(COMPILER) LINK=$(LINKER)"

build:
	cd ./$(PROJECT) && veryl fmt && veryl build

check:
	cd ./$(PROJECT) && veryl fmt --check && veryl check

clean:
	cd ./$(PROJECT) && veryl clean
	rm -rf $(OBJ_DIR)

sim:
	verilator --cc $(VERILATOR_FLAGS) -f $(FILELIST) --exe $(TB_PROGRAM) --top-module $(PROJECT)_$(TOP_MODULE) --Mdir $(OBJ_DIR)
	make -C $(OBJ_DIR) -f V$(PROJECT)_$(TOP_MODULE).mk
	mv $(OBJ_DIR)/V$(PROJECT)_$(TOP_MODULE) $(OBJ_DIR)/$(SIM_NAME)

run: build sim
	./$(OBJ_DIR)/$(SIM_NAME) core/src/sample_mret.hex 9

test: build patch
	$(MAKE) sim VERILATOR_FLAGS="-DTEST_MODE" && ./$(OBJ_DIR)/$(SIM_NAME) $(PWD)/core/tests/share/riscv-tests/isa/rv32ui-p-add.bin.hex 0

patch:
ifeq ($(wildcard riscv-tests),) # Check if "riscv-tests" directory exists. If not, clone and build it
	git submodule update --init --recursive
endif

ifeq ($(wildcard core/tests/share),) # Check if core/tests/share exists before proceeding with further commands
	cd ./riscv-tests && ./configure --prefix=$(PWD)/core/tests && make && make install
endif

# Convert files to binary format and then to hex
ifeq ($(wildcard core/tests/share),) # Check if core/tests/share exists before proceeding with further commands
	git apply $(PWD)/patches/env_ld.patch
	find core/tests/share/ -type f -not -name "*.dump" -exec riscv64-unknown-elf-objcopy -O binary {} {}.bin \;
	find core/tests/share/ -type f -name "*.bin" -exec sh -c "python3 ./core/tests/bin2hex.py 4 {} > {}.hex" \;
	git apply --reverse $(PWD)/patches/env_ld.patch
endif

.PHONY: build clean check sim run test patch
