# Define clock
netlist clock design_top.clk_i -period 10 -waveform {0 5}

# Define reset - leave unasserted for symbolic starting state
netlist constant design_top.rst_ni 1'b1

# Define formal tool cutpoints
# netlist cutpoint design_top.INSTR
# netlist cutpoint design_top.dut.qed_exec_dup
netlist cutpoint design_top.slave\[0\].r_ready
netlist cutpoint design_top.dram.aw_valid
netlist cutpoint design_top.dram.ar_valid

report directives
