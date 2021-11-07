`timescale 1ns / 1ps

module design_top (input clk, input reset);
    // top module wire declarations
    wire CLK;
    wire RESETN;

    assign CLK = clk;
    assign RESETN = ~reset;
    
    // connection with Real Time Counter - hard wired to 0
    wire [63:0] REAL_TIME;

    assign REAL_TIME = 'b0;
    
    // connections with Instruction Memory
    wire [31:0] I_ADDR;
    wire [31:0] INSTR;

    // Cutpoint
    assign INSTR = 'b0;
    
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
    
    picorv32 #(
		.ENABLE_COUNTERS(0),
        .ENABLE_COUNTERS64(0),
        .ENABLE_REGS_16_31(0),
        .ENABLE_REGS_DUALPORT(0),
        .LATCHED_MEM_RDATA(0),
        .TWO_STAGE_SHIFT(0),
        .BARREL_SHIFTER(0),
        .TWO_CYCLE_COMPARE(0),
        .TWO_CYCLE_ALU(0),
        .COMPRESSED_ISA(0),
        .CATCH_MISALIGN(0),
        .CATCH_ILLINSN(0),
        .ENABLE_PCPI(0),
        .ENABLE_MUL(0),
        .ENABLE_FAST_MUL(0),
        .ENABLE_DIV(0),
        .ENABLE_IRQ(0),
        .ENABLE_IRQ_QREGS(0),
        .ENABLE_IRQ_TIMER(0),
        .ENABLE_TRACE(0),
        .REGS_INIT_ZERO(0),
	) cpu (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (irq        )
	);
    
    // Memory is 4 byte aligned - hence the indexing starts at bit 2
    ram #(
        .DEPTH(32)
    ) mem (
        .CLK(CLK),
        .ADDRA(D_ADDR[6:2]),
        .ADDRB(I_ADDR[6:2]),
        .DINA(DATA_OUT),
        .WEA(WR_MASK),
        .DOUTA(DATA_IN),
        .DOUTB()
    );    

endmodule
