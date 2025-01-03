default: sim

PROJECT = core
FILELIST = $(PROJECT)/$(PROJECT).f

TOP_MODULE = top
TB_PROGRAM = $(PROJECT)/src/tb_verilator.cpp
OBJ_DIR = obj_dir/
SIM_NAME = sim
VERILATOR_FLAGS = ""

build:
	cd ./$(PROJECT) && veryl fmt && veryl build

clean:
	veryl clean
	rm -rf $(OBJ_DIR)

sim:
	verilator --cc $(VERILATOR_FLAGS) -f $(FILELIST) --exe $(TB_PROGRAM) --top-module $(PROJECT)_$(TOP_MODULE) --Mdir $(OBJ_DIR)
	make -C $(OBJ_DIR) -f V$(PROJECT)_$(TOP_MODULE).mk
	mv $(OBJ_DIR)/V$(PROJECT)_$(TOP_MODULE) $(OBJ_DIR)/$(SIM_NAME)

.PHONY: build clean sim
