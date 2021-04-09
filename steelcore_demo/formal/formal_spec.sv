module formal_spec(
    clk, rst,
    reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
    reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15,
    reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,
    reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31
    );

    input        clk;
    input        rst;
    input [31:0] reg0;
    input [31:0] reg1;
    input [31:0] reg2;
    input [31:0] reg3;
    input [31:0] reg4;
    input [31:0] reg5;
    input [31:0] reg6;
    input [31:0] reg7;
    input [31:0] reg8;
    input [31:0] reg9;
    input [31:0] reg10;
    input [31:0] reg11;
    input [31:0] reg12;
    input [31:0] reg13;
    input [31:0] reg14;
    input [31:0] reg15;
    input [31:0] reg16;
    input [31:0] reg17;
    input [31:0] reg18;
    input [31:0] reg19;
    input [31:0] reg20;
    input [31:0] reg21;
    input [31:0] reg22;
    input [31:0] reg23;
    input [31:0] reg24;
    input [31:0] reg25;
    input [31:0] reg26;
    input [31:0] reg27;
    input [31:0] reg28;
    input [31:0] reg29;
    input [31:0] reg30;
    input [31:0] reg31;

    
    wire [31:0]  iregs[31:0];
    assign iregs[0] = reg0;
    assign iregs[1] = reg1;
    assign iregs[2] = reg2;
    assign iregs[3] = reg3;
    assign iregs[4] = reg4;
    assign iregs[5] = reg5;
    assign iregs[6] = reg6;
    assign iregs[7] = reg7;
    assign iregs[8] = reg8;
    assign iregs[9] = reg9;
    assign iregs[10] = reg10;
    assign iregs[11] = reg11;
    assign iregs[12] = reg12;
    assign iregs[13] = reg13;
    assign iregs[14] = reg14;
    assign iregs[15] = reg15;
    assign iregs[16] = reg16;
    assign iregs[17] = reg17;
    assign iregs[18] = reg18;
    assign iregs[19] = reg19;
    assign iregs[20] = reg20;
    assign iregs[21] = reg21;
    assign iregs[22] = reg22;
    assign iregs[23] = reg23;
    assign iregs[24] = reg24;
    assign iregs[25] = reg25;
    assign iregs[26] = reg26;
    assign iregs[27] = reg27;
    assign iregs[28] = reg28;
    assign iregs[29] = reg29;
    assign iregs[30] = reg30;
    assign iregs[31] = reg31;

    wire sif_commit;
    assign sif_commit = design_top.dut.sif_commit;

    reg sif_commit_q;
    always @(posedge clk) begin
        sif_commit_q <= sif_commit;
    end
    wire sif_commit_pulsed = sif_commit & ~sif_commit_q;


    wire qed_check_valid;
    assign qed_check_valid = design_top.dut.qed_check_valid;
      

    // Assumptions
    
    // Assume r0 and it's corresponding duplicate register is always 0
    assume_reg0: assume property (
                 @(posedge clk)
                 (iregs[0] == 0) && (iregs[16] == 0)
                 );

    // Constraint C-2: At T_C, the processer is QED Consistent
    genvar j;
    generate
    for (j = 1; j < 16; j++) begin
        assume_consistent_pipeline1: assume property (
                                     @(posedge clk)
                                     sif_commit_pulsed |-> (iregs[j] == iregs[j+16])
                                     );
    end
    endgenerate
    
    // Constraint initial state of QED module and relevant signals
    property assume_init_mem;
        @(posedge clk)
        ((design_top.dut.qed0.qic.i_cache == 0)
        && (design_top.dut.qed0.qic.address_tail == 0)
        && (design_top.dut.qed0.qic.address_head == 0)
        && (design_top.dut.sif_commit == 0)
        && (design_top.dut.sif_state ==  0)
        && (design_top.dut.qed_num_orig == 0)
        && (design_top.dut.qed_num_dup == 0))
    endproperty
   initial begin
      assume_mem: assume property (assume_init_mem);
   end
   
   // QED Consistency Check
   generate
       for (j = 1; j < 16; j++) begin
      assert_ireg_match : assert property (
        @(posedge clk)
         (qed_check_valid && sif_commit) |-> (iregs[j] == iregs[j+16]));
     end
   endgenerate

   // Constrain to allowed instructions only
   inst_constraint inst_constraint_0 (.clk(clk), .instruction(design_top.INSTR));

endmodule
