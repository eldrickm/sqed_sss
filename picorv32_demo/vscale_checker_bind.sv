module vscale_checker_bind;
   

   bind toppipe.vpipe.regfile  vscale_checker chk0 (.clk(clk),
                                       .rst(1'b0),
                                       .reg0 (data[0]),
                                       .reg1 (data[1]),
                                       .reg2 (data[2]),
                                       .reg3 (data[3]),
                                       .reg4 (data[4]),
                                       .reg5 (data[5]),
                                       .reg6 (data[6]),
                                       .reg7 (data[7]),
                                       .reg8 (data[8]),
                                       .reg9 (data[9]),
                                       .reg10(data[10]),
                                       .reg11(data[11]),
                                       .reg12(data[12]),
                                       .reg13(data[13]),
                                       .reg14(data[14]),
                                       .reg15(data[15]),
                                       .reg16(data[16]),
                                       .reg17(data[17]),
                                       .reg18(data[18]),
                                       .reg19(data[19]),
                                       .reg20(data[20]),
                                       .reg21(data[21]),
                                       .reg22(data[22]),
                                       .reg23(data[23]),
                                       .reg24(data[24]),
                                       .reg25(data[25]),
                                       .reg26(data[26]),
                                       .reg27(data[27]),
                                       .reg28(data[28]),
                                       .reg29(data[29]),
                                       .reg30(data[30]),
                                       .reg31(data[31]));

endmodule // spc_checker_bind

   
