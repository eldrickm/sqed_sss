`timescale 1ns / 1ps
`define PICORV32_REGS picosoc_regs
module design_top (input clk, input reset);
    // top module wire declarations

    wire CLK;
    assign CLK = clk;

    // not reset signal
    wire resetn;
    assign resetn = ~reset;

    // irq - hard wired to 0
    wire [31:0] irq;
    assign irq = 32'b0;

	wire mem_valid;
	wire mem_instr; // floating output - same as picosoc.v
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

    // ready to read from memory - hard wired to 1 
    assign mem_ready = 1;
    
    picorv32 #(
		.ENABLE_COUNTERS(0),
        .ENABLE_COUNTERS64(0),
        .ENABLE_REGS_16_31(0),
        .ENABLE_REGS_DUALPORT(0),
        .LATCHED_MEM_RDATA(0),
        .TWO_STAGE_SHIFT(1),
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
        .REGS_INIT_ZERO(0)
	) dut (
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
    picosoc_mem #(
        .WORDS(32)
    ) mem (
        .clk(CLK),
        .wen(mem_valid ? mem_wstrb : 4'b0),
        .addr(mem_addr[6:2]),
        .wdata(mem_wdata),
        .rdata(mem_rdata)
    );    

endmodule

module picosoc_regs (
	input clk, wen,
	input [5:0] waddr,
	input [5:0] raddr1,
	input [5:0] raddr2,
	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);
	reg [31:0] regs [0:31];

	always @(posedge clk)
		if (wen) regs[waddr[4:0]] <= wdata;

	assign rdata1 = regs[raddr1[4:0]];
	assign rdata2 = regs[raddr2[4:0]];
endmodule

module picosoc_mem #(
	parameter integer WORDS = 256
) (
	input clk,
	input [3:0] wen,
	input [31:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata
);
	reg [31:0] mem [0:WORDS-1];

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end
endmodule
