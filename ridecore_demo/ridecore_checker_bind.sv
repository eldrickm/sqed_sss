module ridecore_checker_bind;
   

   bind top.pipe.aregfile.regfile  ridecore_checker chk0 (.clk(clk),
                                       .rst(1'b0),
                                       .reg0 (mem[0]),
                                       .reg1 (mem[1]),
                                       .reg2 (mem[2]),
                                       .reg3 (mem[3]),
                                       .reg4 (mem[4]),
                                       .reg5 (mem[5]),
                                       .reg6 (mem[6]),
                                       .reg7 (mem[7]),
                                       .reg8 (mem[8]),
                                       .reg9 (mem[9]),
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
                                       .reg31(mem[31]));

endmodule // spc_checker_bind

   
