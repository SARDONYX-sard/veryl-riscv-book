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

test: build
	$(MAKE) sim VERILATOR_FLAGS="-DTEST_MODE" && ./$(OBJ_DIR)/$(SIM_NAME) $(PWD)/core/tests/share/riscv-tests/isa/rv32ui-p-add.bin.hex 0

test-debug: build
	$(MAKE) sim VERILATOR_FLAGS="-DTEST_MODE" && ./$(OBJ_DIR)/$(SIM_NAME) $(PWD)/core/tests/share/riscv-tests/isa/rv32ui-p-add.bin.hex 1500 > ./dump.txt

patch:
ifeq ($(wildcard riscv-tests),) # “riscv-tests” directory exists? -> If not, clone & build
	git submodule update --init --recursive
	cd ./riscv-tests && ./configure --prefix=$(PWD)/core/tests && make && make install
endif
	git apply patches/env_ld.patch
	find core/tests/share/ -type f -not -name "*.dump" -exec riscv64-unknown-elf-objcopy -O binary {} {}.bin \;
	find core/tests/share/ -type f -name "*.bin" -exec sh -c "python3 ./core/tests/bin2hex.py 4 {} > {}.hex" \;
	git apply --reverse patches/env_ld.patch

doc-test:
	python3 $(PWD)/core/tests/doctest_runner.py $(PWD)/core/tests/bin2hex.py

.PHONY: build clean check sim run test patch python
