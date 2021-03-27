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

    // TODO: Make Cutpoint
    assign INSTR = 'b0;
    
    // connections with Data Memory
    wire [31:0] D_ADDR;
    wire [31:0] DATA_OUT;
    wire WR_REQ;
    wire [3:0] WR_MASK;
    wire [31:0] DATA_IN;

    // TODO: Wire up to memory
    assign DATA_IN = 'b0;
    
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

    ram mem (
        .CLK(CLK),
        .ADDRA(D_ADDR[12:2]),
        .ADDRB(I_ADDR[12:2]),
        .DINA(DATA_OUT),
        .WEA(WR_MASK),
        .DOUTA(DATA_IN),
        .DOUTB()
    );    

endmodule
