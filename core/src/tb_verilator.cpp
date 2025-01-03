#include <filesystem>
#include <iostream>
#include <stdlib.h>
#include <verilated.h>

#include "Vcore_top.h"

namespace fs = std::filesystem;

extern "C" const char *get_env_value(const char *key) {
  const char *value = getenv(key);
  if (value == nullptr)
    return "";
  return value;
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " MEMORY_FILE_PATH [CYCLE]"
              << std::endl;
    return 1;
  }

  // Name of the file that contains the initial memory values
  std::string memory_file_path = argv[1];
  try {
    fs::path absolutePath = fs::absolute(memory_file_path);
    memory_file_path = absolutePath.string();
  } catch (const std::exception &e) {
    std::cerr << "Invalid memory file path : " << e.what() << std::endl;
    return 1;
  }

  // Number of clock cycles to run the simulation
  unsigned long long cycles = 0;
  if (argc >= 3) {
    std::string cycles_string = argv[2];
    try {
      cycles = stoull(cycles_string);
    } catch (const std::exception &e) {
      std::cerr << "Invalid number: " << argv[2] << std::endl;
      return 1;
    }
  }

  // Specify a file for memory initialization in an environment variable
  const char *original_env = getenv("MEMORY_FILE_PATH");
  setenv("MEMORY_FILE_PATH", memory_file_path.c_str(), 1);

  // top
  Vcore_top *dut = new Vcore_top();

  // reset
  dut->clk = 0;
  dut->rst = 1;
  dut->eval();
  dut->rst = 0;
  dut->eval();

  // Restore environment variables
  if (original_env != nullptr) {
    setenv("MEMORY_FILE_PATH", original_env, 1);
  }

  // loop
  dut->rst = 1;
  for (long long i = 0;
       !Verilated::gotFinish() && (cycles == 0 || i / 2 < cycles); i++) {
    dut->clk = !dut->clk;
    dut->eval();
  }

  dut->final();
}
