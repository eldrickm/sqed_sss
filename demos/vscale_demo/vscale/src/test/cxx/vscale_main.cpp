#include "Vvscale_verilator_top.h"
#include "verilated.h"
int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  Vvscale_verilator_top* verilator_top = new Vvscale_verilator_top;
  while (!Verilated::gotFinish()) { verilator_top->eval(); }
  delete verilator_top;
  exit(0);
}
