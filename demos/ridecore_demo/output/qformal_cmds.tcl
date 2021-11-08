# do formal/directives.tcl
netlist clock clk -period 10 -waveform 0 5
netlist constant design_top.reset_x 1'b1
netlist memory mem -exact -module dmem
netlist memory i_cache -exact -module qed_i_cache
netlist cutpoint design_top.pipe.inst1
netlist cutpoint design_top.pipe.inst2
netlist cutpoint design_top.pipe.qed_exec_dup
report directives
# end do formal/directives.tcl
formal compile -d design_top -cuname formal_bind -target_cover_statements
