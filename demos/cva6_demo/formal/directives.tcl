# Define clock
netlist clock design_top.clk_i -period 10 -waveform {0 5}

# Define reset - leave unasserted for symbolic starting state
netlist constant design_top.ndmreset_n 1'b1

# Define formal tool cutpoints
netlist cutpoint design_top.i_ariane.symbolic_instruction
netlist cutpoint design_top.i_ariane.fetch_entry_qed_id.address
netlist cutpoint design_top.i_ariane.fetch_entry_qed_id.branch_predict
netlist cutpoint design_top.i_ariane.fetch_entry_qed_id.ex
netlist cutpoint design_top.i_ariane.qed_exec_dup

report directives
