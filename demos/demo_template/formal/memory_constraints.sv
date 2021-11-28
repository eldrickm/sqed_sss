module memory_constraints
(
    input clk,
    input sif_commit,
    input sif_commit_pulsed,
    input qed_check_valid,
    input [31:0] mem0,
    input [31:0] mem1,
    input [31:0] mem2,
    input [31:0] mem3,
    input [31:0] mem4,
    input [31:0] mem5,
    input [31:0] mem6,
    input [31:0] mem7,
    input [31:0] mem8,
    input [31:0] mem9, 
    input [31:0] mem10, 
    input [31:0] mem11, 
    input [31:0] mem12, 
    input [31:0] mem13, 
    input [31:0] mem14, 
    input [31:0] mem15,
    input [31:0] mem16, 
    input [31:0] mem17, 
    input [31:0] mem18, 
    input [31:0] mem19, 
    input [31:0] mem20, 
    input [31:0] mem21, 
    input [31:0] mem22, 
    input [31:0] mem23,
    input [31:0] mem24, 
    input [31:0] mem25, 
    input [31:0] mem26, 
    input [31:0] mem27, 
    input [31:0] mem28, 
    input [31:0] mem29, 
    input [31:0] mem30, 
    input [31:0] mem31
);

    wire [31:0]  imem[31:0];

    assign imem[0]  =  mem0;
    assign imem[1]  =  mem1;
    assign imem[2]  =  mem2;
    assign imem[3]  =  mem3;
    assign imem[4]  =  mem4;
    assign imem[5]  =  mem5;
    assign imem[6]  =  mem6;
    assign imem[7]  =  mem7;
    assign imem[8]  =  mem8;
    assign imem[9]  =  mem9;
    assign imem[10] = mem10;
    assign imem[11] = mem11;
    assign imem[12] = mem12;
    assign imem[13] = mem13;
    assign imem[14] = mem14;
    assign imem[15] = mem15;
    assign imem[16] = mem16;
    assign imem[17] = mem17;
    assign imem[18] = mem18;
    assign imem[19] = mem19;
    assign imem[20] = mem20;
    assign imem[21] = mem21;
    assign imem[22] = mem22;
    assign imem[23] = mem23;
    assign imem[24] = mem24;
    assign imem[25] = mem25;
    assign imem[26] = mem26;
    assign imem[27] = mem27;
    assign imem[28] = mem28;
    assign imem[29] = mem29;
    assign imem[30] = mem30;
    assign imem[31] = mem31;


    // =========================================================================
    // Assumptions
    // =========================================================================
    // C-2B: At T_C, the memory are QED Consistent
    genvar j;
    generate
    for (j = 0; j < 16; j++) begin
        assume_initial_consistent_memory: assume property
        (
            @(posedge clk)
            sif_commit_pulsed |-> (imem[j] == imem[j+16])
        );
    end
    endgenerate

    // =========================================================================
    // Assertions
    // =========================================================================
    // QED Consistency Check - Memory
    generate
        for (j = 0; j < 16; j++) begin
            assert_qed_consistent_memory : assert property
            (
                @(posedge clk)
                (qed_check_valid && sif_commit) |-> (imem[j] ==imem[j+16])
            );
        end
    endgenerate

endmodule
