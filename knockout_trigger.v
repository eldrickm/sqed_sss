`include "constants.vh"
`default_nettype none

module knockout_trigger
  (
   input wire [31:0] inst0,
   input wire [31:0] inst0_trig,
   input wire 	     clk,
   input wire	     rst,
   output wire	     trig1
   );

   reg [7:0] 	     inst0_level1;
   reg [1:0] 	     inst0_level2;

   assign trig1 = (inst0_level2 == 2'b11);
   // assign trig1 = (inst0 == inst0_trig);
   // assign trig2 = (inst1 == inst1_trig);
   
   always @ (posedge clk) begin
      if (rst) begin
   	 inst0_level2 <= 0;
   	 inst0_level1 <= 0;
      end
      else begin
   	 inst0_level1[0] <= (inst0[3:0] == inst0_trig[3:0]);
   	 inst0_level1[1] <= (inst0[7:4] == inst0_trig[7:4]);
   	 inst0_level1[2] <= (inst0[11:8] == inst0_trig[11:8]);
   	 inst0_level1[3] <= (inst0[15:12] == inst0_trig[15:12]);
   	 inst0_level1[4] <= (inst0[19:16] == inst0_trig[19:16]);
   	 inst0_level1[5] <= (inst0[23:20] == inst0_trig[23:20]);
   	 inst0_level1[6] <= (inst0[27:24] == inst0_trig[27:24]);
   	 inst0_level1[7] <= (inst0[31:28] == inst0_trig[31:28]);
   	 inst0_level2[0] <= (inst0_level1[3:0] == 4'b1111);
   	 inst0_level2[1] <= (inst0_level1[7:4] == 4'b1111);
      end // else: !if(rst)
   end

endmodule // knockout_trigger

`default_nettype wire
