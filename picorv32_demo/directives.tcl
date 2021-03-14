# Define clocks
netlist clock clk -period 10 -waveform {0 5}
netlist constant toppipe.reset 1'b0
#netlist constant top.pipe.pipe_if.predict_cond 1'b0
#netlist constant top.pipe.pipe_if.invalid2 1'b1
#netlist memory mem -exact -module top.datamemory
#netlist memory i_cache -exact -module top.pipe.qed
#netlist memory spectag -abstract -module top.pipe.sb
#netlist memory mem -exact -module dmem
#netlist memory i_cache -exact -module qed_i_cache
#netlist memory spectag -abstract -module storebuf
#netlist memory -exact top.pipe.qed.qic.i_cache

# netlist constant rst 1'b0
# Constrain rst
#formal netlist constraint rst 1'b0 
# formal netlist constraint cluster_arst_l 1'b1

# cut at instruction
netlist cutpoint toppipe.vpipe.imem_rdata
netlist cutpoint toppipe.vpipe.qed_exec_dup

report directives
