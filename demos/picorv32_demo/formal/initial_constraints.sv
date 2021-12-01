module initial_constraints
(
    input clk
);

    // Constrain Initial QED Module and Signal State
    property qed_module_init;
        @(posedge clk)
        ((design_top.dut.qed0.qic.i_cache == 0)
        && (design_top.dut.qed0.qic.address_tail == 0)
        && (design_top.dut.qed0.qic.address_head == 0)
        && (design_top.dut.sif_commit == 0)
        && (design_top.dut.sif_state ==  0)
        && (design_top.dut.qed_num_orig == 0)
        && (design_top.dut.qed_num_dup == 0)
        // && (design_top.dut.is_lui_auipc_jal == 0)
	    // && (design_top.dut.is_lb_lh_lw_lbu_lhu == 0)
	    // && (design_top.dut.is_slli_srli_srai == 0)
	    // && (design_top.dut.is_jalr_addi_slti_sltiu_xori_ori_andi == 0)
	    // && (design_top.dut.is_sb_sh_sw == 0)
	    // && (design_top.dut.is_sll_srl_sra == 0)
	    // && (design_top.dut.is_lui_auipc_jal_jalr_addi_add_sub == 0)
	    // && (design_top.dut.is_slti_blt_slt == 0)
	    // && (design_top.dut.is_sltiu_bltu_sltu == 0)
	    // && (design_top.dut.is_beq_bne_blt_bge_bltu_bgeu == 0)
	    // && (design_top.dut.is_lbu_lhu_lw == 0)
	    // && (design_top.dut.is_alu_reg_imm == 0)
	    // && (design_top.dut.is_alu_reg_reg == 0)
	    // && (design_top.dut.is_compare == 0)
        // && (design_top.dut.mem_rdata_q == 0)
        // && (design_top.dut.mem_do_rinst == 0)
        // && (design_top.dut.mem_valid == 0)
        )
    endproperty

    initial begin
        assume_qed_module_init: assume property (qed_module_init);
    end

endmodule
