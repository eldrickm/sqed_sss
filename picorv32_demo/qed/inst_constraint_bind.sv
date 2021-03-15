module inst_constraint_bind;

    bind top.pipe.pipe_if inst_constraint inst_constraint_0 (.clk(clk),
                                                             .instruction(inst1));

endmodule // inst_constraint_bind
