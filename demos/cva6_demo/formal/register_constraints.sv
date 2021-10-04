module register_constraints
#(
    parameter DATA_WIDTH = 32
)
(
    input clk,
    input sif_commit,
    input sif_commit_pulsed,
    input qed_check_valid,
    input [DATA_WIDTH-1:0] reg0,
    input [DATA_WIDTH-1:0] reg1,
    input [DATA_WIDTH-1:0] reg2,
    input [DATA_WIDTH-1:0] reg3,
    input [DATA_WIDTH-1:0] reg4,
    input [DATA_WIDTH-1:0] reg5,
    input [DATA_WIDTH-1:0] reg6,
    input [DATA_WIDTH-1:0] reg7,
    input [DATA_WIDTH-1:0] reg8,
    input [DATA_WIDTH-1:0] reg9, 
    input [DATA_WIDTH-1:0] reg10, 
    input [DATA_WIDTH-1:0] reg11, 
    input [DATA_WIDTH-1:0] reg12, 
    input [DATA_WIDTH-1:0] reg13, 
    input [DATA_WIDTH-1:0] reg14, 
    input [DATA_WIDTH-1:0] reg15,
    input [DATA_WIDTH-1:0] reg16, 
    input [DATA_WIDTH-1:0] reg17, 
    input [DATA_WIDTH-1:0] reg18, 
    input [DATA_WIDTH-1:0] reg19, 
    input [DATA_WIDTH-1:0] reg20, 
    input [DATA_WIDTH-1:0] reg21, 
    input [DATA_WIDTH-1:0] reg22, 
    input [DATA_WIDTH-1:0] reg23,
    input [DATA_WIDTH-1:0] reg24, 
    input [DATA_WIDTH-1:0] reg25, 
    input [DATA_WIDTH-1:0] reg26, 
    input [DATA_WIDTH-1:0] reg27, 
    input [DATA_WIDTH-1:0] reg28, 
    input [DATA_WIDTH-1:0] reg29, 
    input [DATA_WIDTH-1:0] reg30, 
    input [DATA_WIDTH-1:0] reg31
);

    wire [DATA_WIDTH-1:0]  iregs[31:0];

    assign iregs[0]  =  reg0;
    assign iregs[1]  =  reg1;
    assign iregs[2]  =  reg2;
    assign iregs[3]  =  reg3;
    assign iregs[4]  =  reg4;
    assign iregs[5]  =  reg5;
    assign iregs[6]  =  reg6;
    assign iregs[7]  =  reg7;
    assign iregs[8]  =  reg8;
    assign iregs[9]  =  reg9;
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

    // =========================================================================
    // Assumptions
    // =========================================================================
    // Constrain R0 == 0
    // Assume r0 and it's corresponding duplicate register is always 0
    assume_reg0: assume property
    (
        @(posedge clk)
        (iregs[0] == 0) && (iregs[16] == 0)
    );

    // Constraint C-2:
    // C-2A: At T_C, the registers are QED Consistent
    genvar j;
    generate
    for (j = 1; j < 16; j++) begin
        assume_initial_consistent_register: assume property
        (
            @(posedge clk)
            sif_commit_pulsed |-> (iregs[j] == iregs[j+16])
        );
    end
    endgenerate

    // =========================================================================
    // Assertions
    // =========================================================================
    // QED Consistency Check - Registers
    generate
        for (j = 1; j < 16; j++) begin
        assert_qed_consistent_registers : assert property
        (
            @(posedge clk)
            (qed_check_valid && sif_commit) |-> (iregs[j] == iregs[j+16])
        );
        end
    endgenerate

endmodule
