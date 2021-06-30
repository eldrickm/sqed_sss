`timescale 1ns / 1ps

module design_top (input clk, input reset);
    // top module wire declarations
    wire CLK;
    wire RESET;

    assign CLK = clk;
    assign RESET = reset;
    
    // connection with Real Time Counter - hard wired to 0
    wire [63:0] REAL_TIME;

    assign REAL_TIME = 'b0;
    
    // connections with Instruction Memory
    wire [31:0] I_ADDR;
    wire [31:0] INSTR;

    // connections with Data Memory
    wire [31:0] D_ADDR;
    wire [31:0] DATA_OUT;
    wire WR_REQ;
    wire [3:0] WR_MASK;
    wire [31:0] DATA_IN;

    // connections with Interrupt Controller - hard-wired to 0
    wire E_IRQ;
    wire T_IRQ;
    wire S_IRQ;

    assign E_IRQ = 'b0;
    assign T_IRQ = 'b0;
    assign S_IRQ = 'b0;
    
    steel_top dut (
        .CLK(CLK),
        .RESET(RESET),

        // connection with Real Time Counter
        .REAL_TIME(REAL_TIME),

        // connections with Instruction Memory
        .I_ADDR(I_ADDR),
        .INSTR(INSTR),

        // connections with Data Memory
        .D_ADDR(D_ADDR),
        .DATA_OUT(DATA_OUT),
        .WR_REQ(WR_REQ),
        .WR_MASK(WR_MASK),
        .DATA_IN(DATA_IN),

        //connections with Interrupt Controller
        .E_IRQ(E_IRQ),
        .T_IRQ(T_IRQ),
        .S_IRQ(S_IRQ)
    );

    // Memory is 4 byte aligned - hence the indexing starts at bit 2
    ram #(
        .DEPTH(32)
    ) d_mem (
        .CLK(CLK),
        .ADDRA(D_ADDR[6:2]),
        .ADDRB(5'b0),
        .DINA(DATA_OUT),
        .WEA(WR_MASK),
        .DOUTA(DATA_IN),
        .DOUTB()
    );    

    // Start QED Edit - Add QED Module
    wire qed_vld_out;
    wire [31:0] qed_ifu_instruction;
    // instr_cutpoint is a cutpoint - control given to formal tool
    wire [31:0] instr_cutpoint;
    assign instr_cutpoint = 32'b0;
    // exec_dup is a cutpoint - given to the formal tool
    wire qed_exec_dup;
    assign qed_exec_dup = 1'b0;

    qed qed0 (
        // Outputs
        .vld_out(qed_vld_out),
        .qed_ifu_instruction(qed_ifu_instruction),
        // Inputs
        .ena(1'b1),
        .ifu_qed_instruction(instr_cutpoint),
        .clk(CLK),
        .exec_dup(qed_exec_dup),
        .stall_IF(1'b0),
        .rst(RESET)
    );

    wire [31:0] qed_mem_addr_o;
    wire [31:0] qed_mem_data_o;
    wire        qed_mem_w_en_o;

    qed_mem_shim shim0 (
        // clock and reset
        .clk_i(CLK),
        .rst_i(RESET),

        // qed interface
        .qed_vld_i(qed_vld_out),
        .qed_instr_i(qed_ifu_instruction),

        // memory interface
        .mem_addr_o(qed_mem_addr_o),
        .mem_data_o(qed_mem_data_o),
        .mem_w_en_o(qed_mem_w_en_o)
    );

    // End QED Edit - Add QED Module

    // Memory is 4 byte aligned - hence the indexing starts at bit 2
    ram #(
        .DEPTH(32)
    ) i_mem (
        .CLK(CLK),
        .ADDRA(qed_mem_addr_o[6:2]),
        .ADDRB(I_ADDR[6:2]),
        .DINA(qed_mem_data_o),
        .WEA({4{qed_mem_w_en_o}}),
        .DOUTA(),
        .DOUTB(INSTR)
    );    

endmodule
