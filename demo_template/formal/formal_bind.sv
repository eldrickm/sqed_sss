module formal_bind;
    bind design_top.mem formal_spec chk0 (.clk(CLK),
                                           .rst(1'b0),
                                           .reg0 (ram[0]),
                                           .reg1 (ram[1]),
                                           .reg2 (ram[2]),
                                           .reg3 (ram[3]),
                                           .reg4 (ram[4]),
                                           .reg5 (ram[5]),
                                           .reg6 (ram[6]),
                                           .reg7 (ram[7]),
                                           .reg8 (ram[8]),
                                           .reg9 (ram[9]),
                                           .reg10(ram[10]),
                                           .reg11(ram[11]),
                                           .reg12(ram[12]),
                                           .reg13(ram[13]),
                                           .reg14(ram[14]),
                                           .reg15(ram[15]),
                                           .reg16(ram[16]),
                                           .reg17(ram[17]),
                                           .reg18(ram[18]),
                                           .reg19(ram[19]),
                                           .reg20(ram[20]),
                                           .reg21(ram[21]),
                                           .reg22(ram[22]),
                                           .reg23(ram[23]),
                                           .reg24(ram[24]),
                                           .reg25(ram[25]),
                                           .reg26(ram[26]),
                                           .reg27(ram[27]),
                                           .reg28(ram[28]),
                                           .reg29(ram[29]),
                                           .reg30(ram[30]),
                                           .reg31(ram[31]));
endmodule