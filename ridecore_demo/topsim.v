//`include "define.v"
`include "ridecore/constants.vh"

module top
  (
   input clk,
   input reset_x,
   input qed_rst
   );


   wire [`ADDR_LEN-1:0] pc;
//   wire [4*`INSN_LEN-1:0] idata;
//   wire [8:0] 		  imem_addr;
   wire [`DATA_LEN-1:0]   dmem_data;
   wire [`DATA_LEN-1:0]   dmem_wdata;
   wire [`ADDR_LEN-1:0]   dmem_addr;
   wire 		  dmem_we;
   
   // shashank begin
   
   // wire [`DATA_LEN-1:0]   dmem_wdata_core;
   // wire [`ADDR_LEN-1:0]   dmem_addr_core;
   // wire 		  dmem_we_core;
   // shashank end
   // edit begin shashank
   //wire 		  utx_we; 
  // wire 		  finish_we;
  // wire 		  ready_tx;
  // wire 		  loaded;
   // shashank end

   // begin shashank
   // reg 			  prog_loading;
   // wire [4*`INSN_LEN-1:0] prog_loaddata = 0;
   // wire [`ADDR_LEN-1:0]   prog_loadaddr = 0;
   // wire 		  prog_dmem_we = 0;
   // wire 		  prog_imem_we = 0;
 

   // always @ (posedge clk) begin
   //    if (!reset_x) begin
   // 	 prog_loading <= 1'b1;
   //    end else begin
   // 	 prog_loading <= 0;
   //    end
   // end
  // end shashank

//   assign dmem_data = 32'b0;
   
   pipeline pipe
     (
      .clk(clk),
//      .reset(~reset_x | prog_loading),
      .reset(~reset_x),
      .pc(pc),
      .idata(128'b0),
      .dmem_wdata(dmem_wdata),
      .dmem_addr(dmem_addr),
      .dmem_we(dmem_we),
      .dmem_data(dmem_data),
      .qed_rst(qed_rst)
      );

//   begin shashank
//   assign dmem_addr = prog_loading ? prog_loadaddr : dmem_addr_core;
//   assign dmem_we = prog_loading ? prog_dmem_we : dmem_we_core;
//   assign dmem_wdata = prog_loading ? prog_loaddata[127:96] : dmem_wdata_core;
//   end shashank

//   dmem_addr for the loads/stores we are using with SQED is just the immdiate value chosen by the
//   formal tool; i.e. for original instructions it can range 0:1023 or 0:127 (when dmem is reduced to decrease exec time of the formal tool)
   dmem datamemory(
   		   .clk(clk),
   		   //.addr({2'b0, dmem_addr[`ADDR_LEN-1:2]}), //edit shashank
   		   .addr(dmem_addr),
 		   .wdata(dmem_wdata),
   		   .we(dmem_we),
   		   .rdata(dmem_data)
   		   );

   // even though pc is 32 bits wide, the mem in imem has only 512 locations; so they are only using pc[12:4]
   // this block will not be used with symbolic QED
   // shashank edit
   // assign imem_addr = pc[12:4]; 
   // imem_ld instmemory(
   // 		      .clk(~clk),
   // 		      .addr(imem_addr),
   // 		      .rdata(idata),
   // 		      //.wdata(prog_loaddata),
   // 		      .wdata(128'b0),        // with symblolic QED instmemory is never written; 128'b0 assuming INSN_LEN = 32
   // 		      //.we(prog_imem_we)
   // 		      .we(1'b0)               // with symblolic QED instmemory is never written
   // 		      );
   // shashank end

endmodule // top

   
