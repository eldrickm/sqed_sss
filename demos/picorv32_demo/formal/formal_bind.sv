module formal_bind;

    // Constrain QED Module Initial State
    bind design_top initial_constraints init_con
    (
        .clk(CLK)
    );

    // Constrain Allowed Instructions
    bind design_top inst_constraint inst_con
    (
        .clk(CLK),
        .instruction(design_top.dut.mem_rdata_latched)
    );

    // Constrain Registers
    bind design_top.dut.cpuregs register_constraints reg_con
    (
        .clk  (CLK  ),
        .sif_commit(design_top.dut.sif_commit),
        .sif_commit_pulsed(design_top.dut.sif_commit_pulsed),
        .qed_check_valid(design_top.dut.qed_check_valid),
        .reg0 ('b0  ),
        .reg1 (regs[1] ),
        .reg2 (regs[2] ),
        .reg3 (regs[3] ),
        .reg4 (regs[4] ),
        .reg5 (regs[5] ),
        .reg6 (regs[6] ),
        .reg7 (regs[7] ),
        .reg8 (regs[8] ),
        .reg9 (regs[9] ),
        .reg10(regs[10]),
        .reg11(regs[11]),
        .reg12(regs[12]),
        .reg13(regs[13]),
        .reg14(regs[14]),
        .reg15(regs[15]),
        .reg16(regs[16]),
        .reg17(regs[17]),
        .reg18(regs[18]),
        .reg19(regs[19]),
        .reg20(regs[20]),
        .reg21(regs[21]),
        .reg22(regs[22]),
        .reg23(regs[23]),
        .reg24(regs[24]),
        .reg25(regs[25]),
        .reg26(regs[26]),
        .reg27(regs[27]),
        .reg28(regs[28]),
        .reg29(regs[29]),
        .reg30(regs[30]),
        .reg31(regs[31])
    );

    // Constrain Memory
    bind design_top.mem memory_constraints mem_con
    (
        .clk  (CLK  ),
        .sif_commit(design_top.dut.sif_commit),
        .sif_commit_pulsed(design_top.dut.sif_commit_pulsed),
        .qed_check_valid(design_top.dut.qed_check_valid),
        .mem0 (mem[0] ),
        .mem1 (mem[1] ),
        .mem2 (mem[2] ),
        .mem3 (mem[3] ),
        .mem4 (mem[4] ),
        .mem5 (mem[5] ),
        .mem6 (mem[6] ),
        .mem7 (mem[7] ),
        .mem8 (mem[8] ),
        .mem9 (mem[9] ),
        .mem10(mem[10]),
        .mem11(mem[11]),
        .mem12(mem[12]),
        .mem13(mem[13]),
        .mem14(mem[14]),
        .mem15(mem[15]),
        .mem16(mem[16]),
        .mem17(mem[17]),
        .mem18(mem[18]),
        .mem19(mem[19]),
        .mem20(mem[20]),
        .mem21(mem[21]),
        .mem22(mem[22]),
        .mem23(mem[23]),
        .mem24(mem[24]),
        .mem25(mem[25]),
        .mem26(mem[26]),
        .mem27(mem[27]),
        .mem28(mem[28]),
        .mem29(mem[29]),
        .mem30(mem[30]),
        .mem31(mem[31])
    );

endmodule
