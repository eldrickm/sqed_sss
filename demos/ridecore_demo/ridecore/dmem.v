`include "constants.vh"
`default_nettype none
//8KB Single PORT synchronous BRAM
module dmem
  (
   input wire 		      clk,
   input wire [`ADDR_LEN-1:0] addr,
   input wire [`DATA_LEN-1:0] wdata,
   input wire 		      we,
   output wire [`DATA_LEN-1:0] rdata
   );
// nuthakki: edit
   // reg [`DATA_LEN-1:0] 	      mem [0:2047];
   
   // always @ (posedge clk) begin
   //    rdata <= mem[addr[10:0]];
   //    if (we)
   // 	mem[addr] <= wdata;
   // end

   reg [`DATA_LEN-1:0] 	      mem[0:63];
   assign rdata = mem[addr[5:0]];
   
   always @ (posedge clk) begin
      if (we) begin
	mem[addr[5:0]] <= wdata; // can just use mem[addr[5:0]]
      end
   end


// nuthakki : end   
endmodule // dmem
`default_nettype wire
