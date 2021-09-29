`timescale 1ns/100ps
module timeuniti ();

   initial $timeformat (-9,1," ns",9);
endmodule // timeunit

module qed_testbench () ;
   
   reg rst;
   reg ena;
   reg clk;
   reg exec_dup;
   reg stall_IF;
   reg [31:0] ifu_qed_instruction;
   
   wire [31:0] qed_ifu_instruction;
   wire        vld_out;

   qed dut (
	    .rst(rst),
	    .ena(ena),
	    .clk(clk),
	    .exec_dup(exec_dup),
	    .stall_IF(stall_IF),
	    .ifu_qed_instruction(ifu_qed_instruction),
	    .qed_ifu_instruction(qed_ifu_instruction),
	    .vld_out(vld_out)
	    );

   always #10 clk = ~clk;

   initial
     begin
	$vcdplusfile("qed.vpd");
	$vcdpluson;
	$monitor ("time=%5d ns, clk=%b, rst=%b, ena=%b, exec_dup=%b, stall_IF=%b, ifu_qed_instruction=%b , qed_ifu_instruction=%b, vld_out=%b", $time, clk, rst, ena, exec_dup, stall_IF, ifu_qed_instruction, qed_ifu_instruction, vld_out);

	clk = 1'b0;
	rst = 1'b0;
	ena = 1'b0;
	exec_dup = 1'b0;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b0;

	@(posedge clk); #1;

	rst = 1'b1;
	ena = 1'b1;

	@(posedge clk); #1;

	rst = 1'b0;
	exec_dup = 1'b1;
	ifu_qed_instruction = 32'b000000000111_00000_000_00001_0010011;
	

	@(posedge clk); #1;

	exec_dup = 1'b0;
	stall_IF = 1'b1;
	ifu_qed_instruction = 32'b000000000111_00000_000_00001_0010011;
	

	@(posedge clk); #1;

	exec_dup = 1'b0;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000000111_00000_000_00001_0010011;

	@(posedge clk); #1;

	exec_dup = 1'b0;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000000111_00001_000_00011_0010011;


	@(posedge clk); #1;

	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000000111_00001_000_00011_0010011;

	@(posedge clk); #1;

	exec_dup = 1'b0;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00000_010_00111_0000011;

	@(posedge clk); #1;

	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00000_010_00111_0000011;

	@(posedge clk); #1;

	exec_dup = 1'b1;
	stall_IF = 1'b1;
	ifu_qed_instruction = 32'b000000001111_00000_010_00111_0000011;


	@(posedge clk); #1;

	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00000_010_00111_0000011;


	@(posedge clk); #1;

	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00000_010_00111_0000011;

	@(posedge clk); #1;
	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00000_010_00111_0000011;

	@(posedge clk); #1;
	exec_dup = 1'b0;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000010000000_00101_010_00111_0100011;

	@(posedge clk); #1;
	exec_dup = 1'b0;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00011_000_00111_0110011;

	@(posedge clk); #1;
	exec_dup = 1'b0;
	stall_IF = 1'b1;
	ifu_qed_instruction = 32'b000000001111_00011_000_00111_0110011;

	@(posedge clk); #1;
	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00011_000_00111_0110011;

	@(posedge clk); #1;
	
	exec_dup = 1'b1;
	stall_IF = 1'b0;
	ifu_qed_instruction = 32'b000000001111_00011_000_00111_0110011;

	@(posedge clk); #1;
	@(posedge clk); #1;

	$dumpfile ("qed-dump");
	$dumpvars (0,qed_testbench);
//	$vcdpusoff;
	$finish;	
     end // initial begin

   // initial
   //   begin
   // 	$dumpfile ("qed.dump");
   // 	$dumpvars (0,qed_testbench);
   //   end
   

   
     
endmodule // qed_testbench

   
