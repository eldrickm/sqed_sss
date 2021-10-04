module formal_bind;

    // Constrain QED Module Initial State
    bind design_top initial_constraints init_con
    (
        .clk(clk_i)
    );

    // Constrain Allowed Instructions
    bind design_top inst_constraint inst_con
    (
        .clk(clk_i),
        .instruction(design_top.i_ariane.fetch_entry_qed_id.instruction)
    );

    // Constrain Integer Register File
    bind design_top.i_ariane.issue_stage_i.i_issue_read_operands.i_ariane_regfile register_constraints
    #(
        .DATA_WIDTH(64)
    )
    reg_con
    (
        .clk  (clk_i  ),
        .sif_commit(design_top.i_ariane.sif_commit),
        .sif_commit_pulsed(design_top.i_ariane.sif_commit_pulsed),
        .qed_check_valid(design_top.i_ariane.qed_check_valid),
        .reg0 (mem[0]),
        .reg1 (mem[1] ),
        .reg2 (mem[2] ),
        .reg3 (mem[3] ),
        .reg4 (mem[4] ),
        .reg5 (mem[5] ),
        .reg6 (mem[6] ),
        .reg7 (mem[7] ),
        .reg8 (mem[8] ),
        .reg9 (mem[9] ),
        .reg10(mem[10]),
        .reg11(mem[11]),
        .reg12(mem[12]),
        .reg13(mem[13]),
        .reg14(mem[14]),
        .reg15(mem[15]),
        .reg16(mem[16]),
        .reg17(mem[17]),
        .reg18(mem[18]),
        .reg19(mem[19]),
        .reg20(mem[20]),
        .reg21(mem[21]),
        .reg22(mem[22]),
        .reg23(mem[23]),
        .reg24(mem[24]),
        .reg25(mem[25]),
        .reg26(mem[26]),
        .reg27(mem[27]),
        .reg28(mem[28]),
        .reg29(mem[29]),
        .reg30(mem[30]),
        .reg31(mem[31])
    );

    // // Constrain Memory
    // bind design_top.mem memory_constraints mem_con
    // (
    //     .clk  (clk_i  ),
    //     .sif_commit(design_top.dut.sif_commit),
    //     .sif_commit_pulsed(design_top.dut.sif_commit_pulsed),
    //     .qed_check_valid(design_top.dut.qed_check_valid),
    //     .mem0 (ram[0] ),
    //     .mem1 (ram[1] ),
    //     .mem2 (ram[2] ),
    //     .mem3 (ram[3] ),
    //     .mem4 (32'b0),
    //     .mem5 (ram[5] ),
    //     .mem6 (ram[6] ),
    //     .mem7 (ram[7] ),
    //     .mem8 (ram[8] ),
    //     .mem9 (ram[9] ),
    //     .mem10(ram[10]),
    //     .mem11(ram[11]),
    //     .mem12(ram[12]),
    //     .mem13(ram[13]),
    //     .mem14(ram[14]),
    //     .mem15(ram[15]),
    //     .mem16(ram[16]),
    //     .mem17(ram[17]),
    //     .mem18(ram[18]),
    //     .mem19(ram[19]),
    //     .mem20(ram[20]),
    //     .mem21(ram[21]),
    //     .mem22(ram[22]),
    //     .mem23(ram[23]),
    //     .mem24(ram[24]),
    //     .mem25(ram[25]),
    //     .mem26(ram[26]),
    //     .mem27(ram[27]),
    //     .mem28(ram[28]),
    //     .mem29(ram[29]),
    //     .mem30(ram[30]),
    //     .mem31(ram[31])
    // );

endmodule
