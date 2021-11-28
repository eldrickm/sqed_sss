#include <ctime>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "Vzscale_benchmark_top.h"
#include "verilated.h"

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  Vzscale_benchmark_top* top = new Vzscale_benchmark_top;
  std::clock_t start;
  start = std::clock();
  for (int i = 0; i < 100; i++) {
    top->eval();
    top->clk = 0;
    top->reset = 1;
    top->eval();
    top->clk = 1;
  }
  top->eval();
  top->clk = 0;
  top->reset = 0;
  top->eval();
  top->clk = 1;
  for (int i = 0; i < 10000000; i++) {
    top->eval();
    top->clk = 0;
    top->htif_pcr_req_rw = (i / 2) % 2;
    top->htif_pcr_req_valid = i % 2;
    top->htif_pcr_req_addr = rand();
    top->htif_pcr_req_data = rand();
    top->htif_pcr_resp_ready = (i+1) % 2;
    top->reset = 0;
    top->eval();
    top->clk = 1;
  }
  std::cout << "Time: " << (std::clock() - start) / (double)(CLOCKS_PER_SEC / 1000) << " ms" << std::endl;
  delete top;
  exit(0);
}
