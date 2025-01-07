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
	@echo "==============================================================================================================="
	obj_dir/sim core/src/sample.hex 7

test:
	cd ./$(PROJECT) && veryl test --verbose

.PHONY: build clean check sim run test
