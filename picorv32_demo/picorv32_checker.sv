module picorv32_checker (clk, rst,
                         reg0,   reg1,  reg2,  reg3,
                         reg4,   reg5,  reg6,  reg7,
                         reg8,   reg9, reg10, reg11,
                         reg12, reg13, reg14, reg15,
                         reg16, reg17, reg18, reg19,
                         reg20, reg21, reg22, reg23,
                         reg24, reg25, reg26, reg27,
                         reg28, reg29, reg30, reg31
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
   
    genvar i;
    genvar j;

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

    wire 	ena;
    wire 	wait_for_commit;
    wire 	wait_for_commit_reg;
    assign wait_for_commit = picorv32.wait_till_commit;
    assign wait_for_commit_reg = picorv32.wait_till_commit_reg;
    assign ena = picorv32.chk_en;
  
// =========================== START ASSUMES ==================================
    // register 0 always contains 0
    assume_reg0: assume property (
        @(posedge clk) (iregs[0] == 0) && (iregs[16] == 0)
	);

    // C1: QED Consistent when SIF Instructions Commit
    generate
        for (j = 0; j < 16; j++) begin
	        assume_consistent_pipeline1: assume property (
	            @(posedge wait_for_commit_reg) (iregs[j] == iregs[j+16]) 
		    );
	    end
    endgenerate

    // TODO: What does this assume exactly?
    // Assume QED module properly reset
    property assume_init_mem;
        @(posedge clk) 
	    (   (picorv32.qed0.qic.i_cache == 0)
	     && (picorv32.qed0.qic.address_tail == 0)
	     && (picorv32.qed0.qic.address_head == 0)
	     && (picorv32.wait_till_commit_reg == 0)
	     && (picorv32.state_delay == 0)
	     && (picorv32.num_orig_insts == 0)
	     && (picorv32.num_dup_insts == 0))
    endproperty
    initial begin
        assume_mem: assume property (assume_init_mem);
    end

    // TODO: Find Instruction wire for PicoRV32
    // Assume valid instruction (only certain instructions allowed)
    // Can be found in qed/inst_constraint.sv
    inst_constraint inst_constraint_0 (.clk(clk),
                                       .instruction(picorv32.imem_rdata));
// ============================ END ASSUMES ===================================
   
// =========================== START ASSERTIONS ===============================
    generate
        for (j = 1; j < 16; j++) begin
   	        assert_ireg_match : assert property (
                @(posedge clk)
                (ena && wait_for_commit_reg) |-> (iregs[j] == iregs[j+16]));
   	    end
    endgenerate
// =========================== END ASSERTIONS =================================

endmodule
