module initial_constraints
(
    input clk
);

    // Constrain Initial QED Module and Signal State
    property qed_module_init;
        @(posedge clk)
        ((design_top.i_ariane.qed0.qic.i_cache == 0)
        && (design_top.i_ariane.qed0.qic.address_tail == 0)
        && (design_top.i_ariane.qed0.qic.address_head == 0)
        && (design_top.i_ariane.sif_commit == 0)
        && (design_top.i_ariane.sif_state ==  0)
        && (design_top.i_ariane.qed_num_orig == 0)
        && (design_top.i_ariane.qed_num_dup == 0))
    endproperty

    initial begin
        assume_qed_module_init: assume property (qed_module_init);
    end

endmodule
