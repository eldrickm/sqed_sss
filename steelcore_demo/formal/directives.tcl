# Define clock
netlist clock clk -period 10 -waveform {0 5}

# Define reset
netlist constant design_top.reset 1'b0

# Define formal tool cutpoints
netlist cutpoint design_top.qed_instr_cutpoint
netlist cutpoint design_top.qed_exec_dup

report directives
