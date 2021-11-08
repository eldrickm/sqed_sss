`include "constants.vh"
`default_nettype none
module reorderbuf
  (
   input wire 			  clk,
   input wire 			  reset,
   //Write Signal
   input wire 			  dp1,
   input wire [`RRF_SEL-1:0] 	  dp1_addr,
   input wire [`INSN_LEN-1:0] 	  pc_dp1,
   input wire 			  storebit_dp1,
   input wire 			  dstvalid_dp1,
   input wire [`REG_SEL-1:0] 	  dst_dp1,
   input wire [`GSH_BHR_LEN-1:0]  bhr_dp1,
   input wire 			  isbranch_dp1,
   input wire 			  dp2,
   input wire [`RRF_SEL-1:0] 	  dp2_addr,
   input wire [`INSN_LEN-1:0] 	  pc_dp2,
   input wire 			  storebit_dp2,
   input wire 			  dstvalid_dp2,
   input wire [`REG_SEL-1:0] 	  dst_dp2,
   input wire [`GSH_BHR_LEN-1:0]  bhr_dp2,
   input wire 			  isbranch_dp2,
   input wire 			  exfin_alu1,
   input wire [`RRF_SEL-1:0] 	  exfin_alu1_addr,
   input wire 			  exfin_alu2,
   input wire [`RRF_SEL-1:0] 	  exfin_alu2_addr,
   input wire 			  exfin_mul,
   input wire [`RRF_SEL-1:0] 	  exfin_mul_addr,
   input wire 			  exfin_ldst,
   input wire [`RRF_SEL-1:0] 	  exfin_ldst_addr,
   input wire 			  exfin_branch,
   input wire [`RRF_SEL-1:0] 	  exfin_branch_addr,
   input wire 			  exfin_branch_brcond,
   input wire [`ADDR_LEN-1:0] 	  exfin_branch_jmpaddr, 
  
   output reg [`RRF_SEL-1:0] 	  comptr,
   output wire [`RRF_SEL-1:0] 	  comptr2,
   output wire [1:0] 		  comnum,
   output wire 			  stcommit,
   output wire 			  arfwe1,
   output wire 			  arfwe2,
   output wire [`REG_SEL-1:0] 	  dstarf1,
   output wire [`REG_SEL-1:0] 	  dstarf2,
   output wire [`ADDR_LEN-1:0] 	  pc_combranch,
   output wire [`GSH_BHR_LEN-1:0] bhr_combranch,
   output wire 			  brcond_combranch,
   output wire [`ADDR_LEN-1:0] 	  jmpaddr_combranch,
   output wire 			  combranch,
   input wire [`RRF_SEL-1:0] 	  dispatchptr,
   input wire [`RRF_SEL:0] 	  rrf_freenum,
   input wire 			  prmiss, // shashank symbolic state change
   input wire qed_rst,
   output wire wait_till_commit,
   input wire stall_IF,
   input wire kill_IF,
   input wire kill_ID,
   input wire stall_DP,
   output reg [63:0] formal_commit, // srcchange tracking
   input wire [4:0] rs1_1_id,
   input wire [4:0] rs2_1_id,
   input wire uses_rs1_1_id,
   input wire uses_rs2_1_id,
   input wire [4:0] rs1_2_id,
   input wire [4:0] rs2_2_id,
   input wire uses_rs1_2_id,
   input wire uses_rs2_2_id,
   // input wire [31:0] ex_src1_alu1,
   // input wire [31:0] ex_src2_alu1,
   // input wire [`RRF_SEL-1:0] rrftag_alu1,
   // input wire issue_alu1
   input wire [31:0] src1_1,
   input wire [31:0] src2_1,
   input wire resolved1_1,
   input wire resolved2_1,
   input wire [31:0] src1_2,
   input wire [31:0] src2_2,
   input wire resolved1_2,
   input wire resolved2_2,
   input wire robwe_alu1,
   input wire [31:0] result_alu1,
   input wire [5:0] buf_rrftag_alu1,
   input wire robwe_alu2,
   input wire [31:0] result_alu2,
   input wire [5:0] buf_rrftag_alu2,
   input wire robwe_mul,
   input wire [31:0] result_mul,
   input wire [5:0] buf_rrftag_mul,
   input wire robwe_ldst,
   input wire [31:0] result_ldst,
   input wire [5:0] buf_rrftag_ldst,
   input wire [31:0] dmem_addr,
   input wire inst1_is_lw,
   input wire inst2_is_lw
   );

   reg [`RRF_NUM-1:0] 		  finish;
   reg [`RRF_NUM-1:0] 		  storebit;
   reg [`RRF_NUM-1:0] 		  dstvalid;
   reg [`RRF_NUM-1:0] 		  brcond;
   reg [`RRF_NUM-1:0] 		  isbranch;
   
//   reg [`ADDR_LEN-1:0] 		  inst_pc [0:`RRF_NUM-1];
//   reg [`ADDR_LEN-1:0] 		  jmpaddr [0:`RRF_NUM-1];   
   reg [`REG_SEL-1:0] 		  dst [0:`RRF_NUM-1];
//   reg [`GSH_BHR_LEN-1:0] 	  bhr [0:`RRF_NUM-1];

   
   assign comptr2 = comptr+1;
   
   wire 			  hidp = (comptr > dispatchptr) || (rrf_freenum == 0) ?
				  1'b1 : 1'b0;
   wire 			  com_en1 = ({hidp, dispatchptr} - {1'b0, comptr}) > 0 ? 1'b1 : 1'b0;
   wire 			  com_en2 = ({hidp, dispatchptr} - {1'b0, comptr}) > 1 ? 1'b1 : 1'b0;
   wire 			  commit1 = com_en1 & finish[comptr];
   //   wire commit2 = commit1 & com_en2 & finish[comptr2];

   wire 			  commit2 = 
				  ~(~prmiss & commit1 & isbranch[comptr]) &
				  ~(commit1 & storebit[comptr] & ~prmiss) &
				  commit1 & com_en2 & finish[comptr2];

   assign comnum = {1'b0, commit1} + {1'b0, commit2};
   assign stcommit = (commit1 & storebit[comptr] & ~prmiss) |
		     (commit2 & storebit[comptr2] & ~prmiss);
   assign arfwe1 = ~prmiss & commit1 & dstvalid[comptr];
   assign arfwe2 = ~prmiss & commit2 & dstvalid[comptr2];
   assign dstarf1 = dst[comptr];
   assign dstarf2 = dst[comptr2];
   assign combranch = (~prmiss & commit1 & isbranch[comptr]) |
		      (~prmiss & commit2 & isbranch[comptr2]);
   assign brcond_combranch = (~prmiss & commit1 & isbranch[comptr]) ?
			     brcond[comptr] : brcond[comptr2];

   // shashank : logic for tracking new instruction
//   output reg [`RRF_NUM-1:0] 		  formal_commit;
   reg 				  wait_till_commit_reg;

   reg [1:0] 			  state_delay;

   always @(posedge clk) begin
      if (qed_rst) begin
	 state_delay <= 0; // initial state
      end else if (~stall_IF && ~kill_IF && (state_delay == 0)) begin
	 state_delay <= 1; // new instructions (can be just NOPs) in IF pipe register
      end else if (~stall_DP && ~kill_ID && (state_delay == 1)) begin
	 state_delay <= 2; // new instructions in ID pipe register
      end
   end

   reg wait_till_commit_reg2;
   always @(posedge clk) begin
      if (qed_rst) begin
	 formal_commit <= 0;
	 wait_till_commit_reg <= 0;
      end else begin
	 if (dp1 && (state_delay == 2)) begin
	    formal_commit[dp1_addr] <= 1'b1;
	 end
	 if (dp2 && (state_delay == 2)) begin
	    formal_commit[dp2_addr] <= 1'b1;	    
	 end
//	 wait_till_commit_reg2 <= formal_commit[comptr2] && commit2 && commit1;
	 wait_till_commit_reg <= (formal_commit[comptr]); // || (formal_commit[comptr2] && commit2 && commit1));  //&& finish[comptr];
      end // else: !if(qed_rst)
   end
   
//   assign wait_till_commit = formal_commit[comptr] && finish[comptr];

   assign wait_till_commit = (formal_commit[comptr] || (formal_commit[comptr2] && commit1 && commit2));
   
//   assign wait_till_commit = wait_till_commit_reg;
   
   // shashank end 

   // shashank : logic for tracking src registers // srcchange
   reg [`RRF_NUM-1:0]  src_track;
   reg [`RRF_NUM-1:0]  src1_valid;
   reg [`RRF_NUM-1:0]  src2_valid;
   reg [31:0] 	       src1_data[0:`RRF_NUM-1];
   reg [31:0] 	       src2_data[0:`RRF_NUM-1];
   reg [4:0] 	       src1[0:`RRF_NUM-1];
   reg [4:0] 	       src2[0:`RRF_NUM-1];
   reg [`RRF_NUM-1:0]  src1_datval;
   reg [`RRF_NUM-1:0]  src2_datval;
   reg [5:0] 	       src1_rrftag[0:63];
   reg [5:0] 	       src2_rrftag[0:63];
   reg [63:0] 	       src1_rrftag_val;
   reg [63:0] 	       src2_rrftag_val;
   reg [63:0] 	       ldsrc_val;
   reg [63:0] 	       ldsrc_track;
   reg [31:0] 	       ldsrc_addr[0:63];
   reg [31:0] 	       ldsrc_data[0:63];

   always @(posedge clk) begin
      if (qed_rst) begin
	 src_track = 0;
	 src1_valid = 0;
	 src2_valid = 0;
//	 src1_datval = 0;
//	 src2_datval = 0;
	 src1_rrftag_val = 0;
	 src2_rrftag_val = 0;
//	 ldsrc_track = 0;
      end else begin
	 if (dp1 && (state_delay == 2) && ~wait_till_commit) begin // stop tracking when in-flight instructions commit
	    src_track[dp1_addr] <= 1'b1;
	    src1_valid[dp1_addr] <= uses_rs1_1_id;
	    src2_valid[dp1_addr] <= uses_rs2_1_id;
	    src1[dp1_addr] <= rs1_1_id;
	    src2[dp1_addr] <= rs2_1_id;
//	    src1_datval[dp1_addr] <= (uses_rs1_1_id && resolved1_1);
//	    src1_data[dp1_addr] <= (uses_rs1_1_id && resolved1_1) ? src1_1 : 0;
	    src1_rrftag_val[dp1_addr] <= (uses_rs1_1_id && (~resolved1_1));
	    src1_rrftag[dp1_addr] <= (uses_rs1_1_id && (~resolved1_1)) ? src1_1[5:0] : 0;
//	    src2_datval[dp1_addr] <= (uses_rs2_1_id && resolved2_1);
//	    src2_data[dp1_addr] <= (uses_rs2_1_id && resolved2_1) ? src2_1 : 0;
	    src2_rrftag_val[dp1_addr] <= (uses_rs2_1_id && (~resolved2_1));
	    src2_rrftag[dp1_addr] <= (uses_rs2_1_id && (~resolved2_1)) ? src2_1[5:0] : 0;
	 end
	 if (dp2 && (state_delay == 2) && ~wait_till_commit) begin
	    src_track[dp2_addr] <= 1'b1;
	    src1_valid[dp2_addr] <= uses_rs1_2_id;
	    src2_valid[dp2_addr] <= uses_rs2_2_id;
	    src1[dp2_addr] <= rs1_2_id;
	    src2[dp2_addr] <= rs2_2_id;
//	    src1_datval[dp2_addr] <= (uses_rs1_2_id && resolved1_2);
//	    src1_data[dp2_addr] <= (uses_rs1_2_id && resolved1_2) ? src1_2 : 0;
	    src1_rrftag_val[dp2_addr] <= (uses_rs1_2_id && (~resolved1_2));
	    src1_rrftag[dp2_addr] <= (uses_rs1_2_id && (~resolved1_2)) ? src1_2[5:0] : 0;
//	    src2_datval[dp2_addr] <= (uses_rs2_2_id && resolved2_2);
//	    src2_data[dp2_addr] <= (uses_rs2_2_id && resolved2_2) ? src2_2 : 0;
	    src2_rrftag_val[dp2_addr] <= (uses_rs2_2_id && (~resolved2_2));
	    src2_rrftag[dp2_addr] <= (uses_rs2_2_id && (~resolved2_2)) ? src2_2[5:0] : 0;
	 end
      end // else: !if(qed_rst)
   end

   always @(posedge clk) begin
      if (dp1 && inst1_is_lw && (state_delay == 2) && ~wait_till_commit) begin
	 ldsrc_track[dp1_addr] <= 1'b1;
      end
      if (dp2 && inst2_is_lw && (state_delay == 2) && ~wait_till_commit) begin
	 ldsrc_track[dp2_addr] <= 1'b1;
      end
      
      if (robwe_ldst) begin
	if (ldsrc_track[0] && (~ldsrc_val[0]) && (buf_rrftag_ldst == 0)) begin
	   ldsrc_data[0] <= result_ldst;
	   ldsrc_addr[0] <= dmem_addr;
	   ldsrc_val[0] <= 1'b1;
	end
	if (ldsrc_track[1] && (~ldsrc_val[1]) && (buf_rrftag_ldst == 1)) begin
	   ldsrc_data[1] <= result_ldst;
	   ldsrc_addr[1] <= dmem_addr;
	   ldsrc_val[1] <= 1'b1;	   
	end
	if (ldsrc_track[2] && (~ldsrc_val[2]) && (buf_rrftag_ldst == 2)) begin
	   ldsrc_data[2] <= result_ldst;
	   ldsrc_addr[2] <= dmem_addr;
	   ldsrc_val[2] <= 1'b1;	   
	end
	 if (ldsrc_track[3] && (~ldsrc_val[3]) && (buf_rrftag_ldst == 3)) begin
	   ldsrc_data[3] <= result_ldst;
	   ldsrc_addr[3] <= dmem_addr;
	   ldsrc_val[3] <= 1'b1;	    
	end
	if (ldsrc_track[4] && (~ldsrc_val[4]) && (buf_rrftag_ldst == 4)) begin
	   ldsrc_data[4] <= result_ldst;
	   ldsrc_addr[4] <= dmem_addr;
	   ldsrc_val[4] <= 1'b1;	   
	end
	if (ldsrc_track[5] && (~ldsrc_val[5]) && (buf_rrftag_ldst == 5)) begin
	   ldsrc_data[5] <= result_ldst;
	   ldsrc_addr[5] <= dmem_addr;
	   ldsrc_val[5] <= 1'b1;	   
	end
	if (ldsrc_track[6] && (~ldsrc_val[6]) && (buf_rrftag_ldst == 6)) begin
	   ldsrc_data[6] <= result_ldst;
	   ldsrc_addr[6] <= dmem_addr;
	   ldsrc_val[6] <= 1'b1;	   
	end
	if (ldsrc_track[7] && (~ldsrc_val[7]) && (buf_rrftag_ldst == 7)) begin
	   ldsrc_data[7] <= result_ldst;
	   ldsrc_addr[7] <= dmem_addr;
	   ldsrc_val[7] <= 1'b1;	   
	end
	if (ldsrc_track[8] && (~ldsrc_val[8]) && (buf_rrftag_ldst == 8)) begin
	   ldsrc_data[8] <= result_ldst;
	   ldsrc_addr[8] <= dmem_addr;
	   ldsrc_val[8] <= 1'b1;	   
	end
	if (ldsrc_track[9] && (~ldsrc_val[9]) && (buf_rrftag_ldst == 9)) begin
	   ldsrc_data[9] <= result_ldst;
	   ldsrc_addr[9] <= dmem_addr;
	   ldsrc_val[9] <= 1'b1;	   
	end
	if (ldsrc_track[10] && (~ldsrc_val[10]) && (buf_rrftag_ldst == 10)) begin
	   ldsrc_data[10] <= result_ldst;
	   ldsrc_addr[10] <= dmem_addr;
	   ldsrc_val[10] <= 1'b1;	   
	end
	if (ldsrc_track[11] && (~ldsrc_val[11]) && (buf_rrftag_ldst == 11)) begin
	   ldsrc_data[11] <= result_ldst;
	   ldsrc_addr[11] <= dmem_addr;
	   ldsrc_val[11] <= 1'b1;	   
	end
	if (ldsrc_track[12] && (~ldsrc_val[12]) && (buf_rrftag_ldst == 12)) begin
	   ldsrc_data[12] <= result_ldst;
	   ldsrc_addr[12] <= dmem_addr;
	   ldsrc_val[12] <= 1'b1;	   
	end
	 if (ldsrc_track[13] && (~ldsrc_val[13]) && (buf_rrftag_ldst == 13)) begin
	   ldsrc_data[13] <= result_ldst;
	   ldsrc_addr[13] <= dmem_addr;
	   ldsrc_val[13] <= 1'b1;	    
	end
	if (ldsrc_track[14] && (~ldsrc_val[14]) && (buf_rrftag_ldst == 14)) begin
	   ldsrc_data[14] <= result_ldst;
	   ldsrc_addr[14] <= dmem_addr;
	   ldsrc_val[14] <= 1'b1;	   
	end
	if (ldsrc_track[15] && (~ldsrc_val[15]) && (buf_rrftag_ldst == 15)) begin
	   ldsrc_data[15] <= result_ldst;
	   ldsrc_addr[15] <= dmem_addr;
	   ldsrc_val[15] <= 1'b1;	   
	end
	if (ldsrc_track[16] && (~ldsrc_val[16]) && (buf_rrftag_ldst == 16)) begin
	   ldsrc_data[16] <= result_ldst;
	   ldsrc_addr[16] <= dmem_addr;
	   ldsrc_val[16] <= 1'b1;	   
	end
	if (ldsrc_track[17] && (~ldsrc_val[17]) && (buf_rrftag_ldst == 17)) begin
	   ldsrc_data[17] <= result_ldst;
	   ldsrc_addr[17] <= dmem_addr;
	   ldsrc_val[17] <= 1'b1;	   
	end
	if (ldsrc_track[18] && (~ldsrc_val[18]) && (buf_rrftag_ldst == 18)) begin
	   ldsrc_data[18] <= result_ldst;
	   ldsrc_addr[18] <= dmem_addr;
	   ldsrc_val[18] <= 1'b1;	   
	end
	if (ldsrc_track[19] && (~ldsrc_val[19]) && (buf_rrftag_ldst == 19)) begin
	   ldsrc_data[19] <= result_ldst;
	   ldsrc_addr[19] <= dmem_addr;
	   ldsrc_val[19] <= 1'b1;	   
	end
	 if (ldsrc_track[20] && (~ldsrc_val[20]) && (buf_rrftag_ldst == 20)) begin
	   ldsrc_data[20] <= result_ldst;
	   ldsrc_addr[20] <= dmem_addr;
	   ldsrc_val[20] <= 1'b1;	    
	end
	if (ldsrc_track[21] && (~ldsrc_val[21]) && (buf_rrftag_ldst == 21)) begin
	   ldsrc_data[21] <= result_ldst;
	   ldsrc_addr[21] <= dmem_addr;
	   ldsrc_val[21] <= 1'b1;	   
	end
	if (ldsrc_track[22] && (~ldsrc_val[22]) && (buf_rrftag_ldst == 22)) begin
	   ldsrc_data[22] <= result_ldst;
	   ldsrc_addr[22] <= dmem_addr;
	   ldsrc_val[22] <= 1'b1;	   	   
	end
	 if (ldsrc_track[23] && (~ldsrc_val[23]) && (buf_rrftag_ldst == 23)) begin
	   ldsrc_data[23] <= result_ldst;
	   ldsrc_addr[23] <= dmem_addr;
	   ldsrc_val[23] <= 1'b1;	   	    
	end
	if (ldsrc_track[24] && (~ldsrc_val[24]) && (buf_rrftag_ldst == 24)) begin
	   ldsrc_data[24] <= result_ldst;
	   ldsrc_addr[24] <= dmem_addr;
	   ldsrc_val[24] <= 1'b1;	   	   
	end
	if (ldsrc_track[25] && (~ldsrc_val[25]) && (buf_rrftag_ldst == 25)) begin
	   ldsrc_data[25] <= result_ldst;
	   ldsrc_addr[25] <= dmem_addr;
	   ldsrc_val[25] <= 1'b1;	   	   
	end
	if (ldsrc_track[26] && (~ldsrc_val[26]) && (buf_rrftag_ldst == 26)) begin
	   ldsrc_data[26] <= result_ldst;
	   ldsrc_addr[26] <= dmem_addr;
	   ldsrc_val[26] <= 1'b1;	   	   
	end
	if (ldsrc_track[27] && (~ldsrc_val[27]) && (buf_rrftag_ldst == 27)) begin
	   ldsrc_data[27] <= result_ldst;
	   ldsrc_addr[27] <= dmem_addr;
	   ldsrc_val[27] <= 1'b1;	   	   
	end
	if (ldsrc_track[28] && (~ldsrc_val[28]) && (buf_rrftag_ldst == 28)) begin
	   ldsrc_data[28] <= result_ldst;
	   ldsrc_addr[28] <= dmem_addr;
	   ldsrc_val[28] <= 1'b1;	   	   
	end
	if (ldsrc_track[29] && (~ldsrc_val[29]) && (buf_rrftag_ldst == 29)) begin
	   ldsrc_data[29] <= result_ldst;
	   ldsrc_addr[29] <= dmem_addr;
	   ldsrc_val[29] <= 1'b1;	   	   
	end
	 if (ldsrc_track[30] && (~ldsrc_val[30]) && (buf_rrftag_ldst == 30)) begin
	   ldsrc_data[30] <= result_ldst;
	   ldsrc_addr[30] <= dmem_addr;
	   ldsrc_val[30] <= 1'b1;	   	    
	end
	if (ldsrc_track[31] && (~ldsrc_val[31]) && (buf_rrftag_ldst == 31)) begin
	   ldsrc_data[31] <= result_ldst;
	   ldsrc_addr[31] <= dmem_addr;
	   ldsrc_val[31] <= 1'b1;	   	   
	end
	if (ldsrc_track[32] && (~ldsrc_val[32]) && (buf_rrftag_ldst == 32)) begin
	   ldsrc_data[32] <= result_ldst;
	   ldsrc_addr[32] <= dmem_addr;
	   ldsrc_val[32] <= 1'b1;	   	   	   
	end
	 if (ldsrc_track[33] && (~ldsrc_val[33]) && (buf_rrftag_ldst == 33)) begin
	   ldsrc_data[33] <= result_ldst;
	   ldsrc_addr[33] <= dmem_addr;
	   ldsrc_val[33] <= 1'b1;	   	    
	end
	if (ldsrc_track[34] && (~ldsrc_val[34]) && (buf_rrftag_ldst == 34)) begin
	   ldsrc_data[34] <= result_ldst;
	   ldsrc_addr[34] <= dmem_addr;
	   ldsrc_val[34] <= 1'b1;	   	   
	end
	if (ldsrc_track[35] && (~ldsrc_val[35]) && (buf_rrftag_ldst == 35)) begin
	   ldsrc_data[35] <= result_ldst;
	   ldsrc_addr[35] <= dmem_addr;
	   ldsrc_val[35] <= 1'b1;	   	   	   
	end
	if (ldsrc_track[36] && (~ldsrc_val[36]) && (buf_rrftag_ldst == 36)) begin
	   ldsrc_data[36] <= result_ldst;
	   ldsrc_addr[36] <= dmem_addr;
	   ldsrc_val[36] <= 1'b1;	   	   	   
	end
	if (ldsrc_track[37] && (~ldsrc_val[37]) && (buf_rrftag_ldst == 37)) begin
	   ldsrc_data[37] <= result_ldst;
	   ldsrc_addr[37] <= dmem_addr;
	   ldsrc_val[37] <= 1'b1;	   	   	   
	end
	if (ldsrc_track[38] && (~ldsrc_val[38]) && (buf_rrftag_ldst == 38)) begin
	   ldsrc_data[38] <= result_ldst;
	   ldsrc_addr[38] <= dmem_addr;
	   ldsrc_val[38] <= 1'b1;	   	   	   	   
	end
	if (ldsrc_track[39] && (~ldsrc_val[39]) && (buf_rrftag_ldst == 39)) begin
	   ldsrc_data[39] <= result_ldst;
	   ldsrc_addr[39] <= dmem_addr;
	   ldsrc_val[39] <= 1'b1;	   	   	   	   
	end
	 if (ldsrc_track[40] && (~ldsrc_val[40]) && (buf_rrftag_ldst == 40)) begin
	   ldsrc_data[40] <= result_ldst;
	   ldsrc_addr[40] <= dmem_addr;
	   ldsrc_val[40] <= 1'b1;	   	   	   	    
	end
	if (ldsrc_track[41] && (~ldsrc_val[41]) && (buf_rrftag_ldst == 41)) begin
	   ldsrc_data[41] <= result_ldst;
	   ldsrc_addr[41] <= dmem_addr;
	   ldsrc_val[41] <= 1'b1;	   	   	   	    	   
	end
	if (ldsrc_track[42] && (~ldsrc_val[42]) && (buf_rrftag_ldst == 42)) begin
	   ldsrc_data[42] <= result_ldst;
	   ldsrc_addr[42] <= dmem_addr;
	   ldsrc_val[42] <= 1'b1;	   
	end
	 if (ldsrc_track[43] && (~ldsrc_val[43]) && (buf_rrftag_ldst == 43)) begin
	   ldsrc_data[43] <= result_ldst;
	   ldsrc_addr[43] <= dmem_addr;
	   ldsrc_val[43] <= 1'b1;	    
	end
	if (ldsrc_track[44] && (~ldsrc_val[44]) && (buf_rrftag_ldst == 44)) begin
	   ldsrc_data[44] <= result_ldst;
	   ldsrc_addr[44] <= dmem_addr;
	   ldsrc_val[44] <= 1'b1;	   
	end
	if (ldsrc_track[45] && (~ldsrc_val[45]) && (buf_rrftag_ldst == 45)) begin
	   ldsrc_data[45] <= result_ldst;
	   ldsrc_addr[45] <= dmem_addr;
	   ldsrc_val[45] <= 1'b1;	   
	end
	if (ldsrc_track[46] && (~ldsrc_val[46]) && (buf_rrftag_ldst == 46)) begin
	   ldsrc_data[46] <= result_ldst;
	   ldsrc_addr[46] <= dmem_addr;
	   ldsrc_val[46] <= 1'b1;	   
	end
	if (ldsrc_track[47] && (~ldsrc_val[47]) && (buf_rrftag_ldst == 47)) begin
	   ldsrc_data[47] <= result_ldst;
	   ldsrc_addr[47] <= dmem_addr;
	   ldsrc_val[47] <= 1'b1;	   
	end
	if (ldsrc_track[48] && (~ldsrc_val[48]) && (buf_rrftag_ldst == 48)) begin
	   ldsrc_data[48] <= result_ldst;
	   ldsrc_addr[48] <= dmem_addr;
	   ldsrc_val[48] <= 1'b1;	   
	end
	if (ldsrc_track[49] && (~ldsrc_val[49]) && (buf_rrftag_ldst == 49)) begin
	   ldsrc_data[49] <= result_ldst;
	   ldsrc_addr[49] <= dmem_addr;
	   ldsrc_val[49] <= 1'b1;	   
	end
	 if (ldsrc_track[50] && (~ldsrc_val[50]) && (buf_rrftag_ldst == 50)) begin
	   ldsrc_data[50] <= result_ldst;
	   ldsrc_addr[50] <= dmem_addr;
	   ldsrc_val[50] <= 1'b1;	    
	end
	if (ldsrc_track[51] && (~ldsrc_val[51]) && (buf_rrftag_ldst == 51)) begin
	   ldsrc_data[51] <= result_ldst;
	   ldsrc_addr[51] <= dmem_addr;
	   ldsrc_val[51] <= 1'b1;	    	   
	end
	if (ldsrc_track[52] && (~ldsrc_val[52]) && (buf_rrftag_ldst == 52)) begin
	   ldsrc_data[52] <= result_ldst;
	   ldsrc_addr[52] <= dmem_addr;
	   ldsrc_val[52] <= 1'b1;	   
	end
	 if (ldsrc_track[53] && (~ldsrc_val[53]) && (buf_rrftag_ldst == 53)) begin
	   ldsrc_data[53] <= result_ldst;
	   ldsrc_addr[53] <= dmem_addr;
	   ldsrc_val[53] <= 1'b1;	    
	end
	if (ldsrc_track[54] && (~ldsrc_val[54]) && (buf_rrftag_ldst == 54)) begin
	   ldsrc_data[54] <= result_ldst;
	   ldsrc_addr[54] <= dmem_addr;
	   ldsrc_val[54] <= 1'b1;	   
	end
	if (ldsrc_track[55] && (~ldsrc_val[55]) && (buf_rrftag_ldst == 55)) begin
	   ldsrc_data[55] <= result_ldst;
	   ldsrc_addr[55] <= dmem_addr;
	   ldsrc_val[55] <= 1'b1;	   
	end
	if (ldsrc_track[56] && (~ldsrc_val[56]) && (buf_rrftag_ldst == 56)) begin
	   ldsrc_data[56] <= result_ldst;
	   ldsrc_addr[56] <= dmem_addr;
	   ldsrc_val[56] <= 1'b1;	   
	end
	if (ldsrc_track[57] && (~ldsrc_val[57]) && (buf_rrftag_ldst == 57)) begin
	   ldsrc_data[57] <= result_ldst;
	   ldsrc_addr[57] <= dmem_addr;
	   ldsrc_val[57] <= 1'b1;	   
	end
	if (ldsrc_track[58] && (~ldsrc_val[58]) && (buf_rrftag_ldst == 58)) begin
	   ldsrc_data[58] <= result_ldst;
	   ldsrc_addr[58] <= dmem_addr;
	   ldsrc_val[58] <= 1'b1;	   
	end
	if (ldsrc_track[59] && (~ldsrc_val[59]) && (buf_rrftag_ldst == 59)) begin
	   ldsrc_data[59] <= result_ldst;
	   ldsrc_addr[59] <= dmem_addr;
	   ldsrc_val[59] <= 1'b1;	   
	end
	 if (ldsrc_track[60] && (~ldsrc_val[60]) && (buf_rrftag_ldst == 60)) begin
	   ldsrc_data[60] <= result_ldst;
	   ldsrc_addr[60] <= dmem_addr;
	   ldsrc_val[60] <= 1'b1;	    
	end
	if (ldsrc_track[61] && (~ldsrc_val[61]) && (buf_rrftag_ldst == 61)) begin
	   ldsrc_data[61] <= result_ldst;
	   ldsrc_addr[61] <= dmem_addr;
	   ldsrc_val[61] <= 1'b1;	   
	end
	if (ldsrc_track[62] && (~ldsrc_val[62]) && (buf_rrftag_ldst == 62)) begin
	   ldsrc_data[62] <= result_ldst;
	   ldsrc_addr[62] <= dmem_addr;
	   ldsrc_val[62] <= 1'b1;	   
	end
	 if (ldsrc_track[63] && (~ldsrc_val[63]) && (buf_rrftag_ldst == 63)) begin
	   ldsrc_data[63] <= result_ldst;
	   ldsrc_addr[63] <= dmem_addr;
	   ldsrc_val[63] <= 1'b1;	    
	end
      end

   end // always @ (posedge clk)
	
   always @(posedge clk) begin
      if (dp1 && (state_delay == 2) && ~wait_till_commit) begin
	 src1_datval[dp1_addr] <= (uses_rs1_1_id && resolved1_1);
	 src1_data[dp1_addr] <= (uses_rs1_1_id && resolved1_1) ? src1_1 : 0;
	 src2_datval[dp1_addr] <= (uses_rs2_1_id && resolved2_1);
	 src2_data[dp1_addr] <= (uses_rs2_1_id && resolved2_1) ? src2_1 : 0;
      end
      if (dp2 && (state_delay == 2) && ~wait_till_commit) begin
	 src1_datval[dp2_addr] <= (uses_rs1_2_id && resolved1_2);
	 src1_data[dp2_addr] <= (uses_rs1_2_id && resolved1_2) ? src1_2 : 0;
	 src2_datval[dp2_addr] <= (uses_rs2_2_id && resolved2_2);
	 src2_data[dp2_addr] <= (uses_rs2_2_id && resolved2_2) ? src2_2 : 0;
      end
      
      if (robwe_alu1) begin
	 if (src_track[0] && src1_valid[0] && (~src1_datval[0]) && (src1_rrftag_val[0]) && (src1_rrftag[0] == buf_rrftag_alu1)) begin
	    src1_data[0] <= result_alu1;
	    src1_datval[0] <= 1;
	 end
	 if (src_track[1] && src1_valid[1] && (~src1_datval[1]) && (src1_rrftag_val[1]) && (src1_rrftag[1] == buf_rrftag_alu1)) begin
	    src1_data[1] <= result_alu1;
	    src1_datval[1] <= 1;
	 end
	 if (src_track[2] && src1_valid[2] && (~src1_datval[2]) && (src1_rrftag_val[2]) && (src1_rrftag[2] == buf_rrftag_alu1)) begin
	    src1_data[2] <= result_alu1;
	    src1_datval[2] <= 1;
	 end
	 if (src_track[3] && src1_valid[3] && (~src1_datval[3]) && (src1_rrftag_val[3]) && (src1_rrftag[3] == buf_rrftag_alu1)) begin
	    src1_data[3] <= result_alu1;
	    src1_datval[3] <= 1;
	 end
	 if (src_track[4] && src1_valid[4] && (~src1_datval[4]) && (src1_rrftag_val[4]) && (src1_rrftag[4] == buf_rrftag_alu1)) begin
	    src1_data[4] <= result_alu1;
	    src1_datval[4] <= 1;
	 end
	 if (src_track[5] && src1_valid[5] && (~src1_datval[5]) && (src1_rrftag_val[5]) && (src1_rrftag[5] == buf_rrftag_alu1)) begin
	    src1_data[5] <= result_alu1;
	    src1_datval[5] <= 1;
	 end
	 if (src_track[6] && src1_valid[6] && (~src1_datval[6]) && (src1_rrftag_val[6]) && (src1_rrftag[6] == buf_rrftag_alu1)) begin
	    src1_data[6] <= result_alu1;
	    src1_datval[6] <= 1;
	 end
	 if (src_track[7] && src1_valid[7] && (~src1_datval[7]) && (src1_rrftag_val[7]) && (src1_rrftag[7] == buf_rrftag_alu1)) begin
	    src1_data[7] <= result_alu1;
	    src1_datval[7] <= 1;
	 end
	 if (src_track[8] && src1_valid[8] && (~src1_datval[8]) && (src1_rrftag_val[8]) && (src1_rrftag[8] == buf_rrftag_alu1)) begin
	    src1_data[8] <= result_alu1;
	    src1_datval[8] <= 1;
	 end
	 if (src_track[9] && src1_valid[9] && (~src1_datval[9]) && (src1_rrftag_val[9]) && (src1_rrftag[9] == buf_rrftag_alu1)) begin
	    src1_data[9] <= result_alu1;
	    src1_datval[9] <= 1;
	 end
	 if (src_track[10] && src1_valid[10] && (~src1_datval[10]) && (src1_rrftag_val[10]) && (src1_rrftag[10] == buf_rrftag_alu1)) begin
	    src1_data[10] <= result_alu1;
	    src1_datval[10] <= 1;
	 end
	 if (src_track[11] && src1_valid[11] && (~src1_datval[11]) && (src1_rrftag_val[11]) && (src1_rrftag[11] == buf_rrftag_alu1)) begin
	    src1_data[11] <= result_alu1;
	    src1_datval[11] <= 1;
	 end
	 if (src_track[12] && src1_valid[12] && (~src1_datval[12]) && (src1_rrftag_val[12]) && (src1_rrftag[12] == buf_rrftag_alu1)) begin
	    src1_data[12] <= result_alu1;
	    src1_datval[12] <= 1;
	 end
	 if (src_track[13] && src1_valid[13] && (~src1_datval[13]) && (src1_rrftag_val[13]) && (src1_rrftag[13] == buf_rrftag_alu1)) begin
	    src1_data[13] <= result_alu1;
	    src1_datval[13] <= 1;
	 end
	 if (src_track[14] && src1_valid[14] && (~src1_datval[14]) && (src1_rrftag_val[14]) && (src1_rrftag[14] == buf_rrftag_alu1)) begin
	    src1_data[14] <= result_alu1;
	    src1_datval[14] <= 1;
	 end
	 if (src_track[15] && src1_valid[15] && (~src1_datval[15]) && (src1_rrftag_val[15]) && (src1_rrftag[15] == buf_rrftag_alu1)) begin
	    src1_data[15] <= result_alu1;
	    src1_datval[15] <= 1;
	 end
	 if (src_track[16] && src1_valid[16] && (~src1_datval[16]) && (src1_rrftag_val[16]) && (src1_rrftag[16] == buf_rrftag_alu1)) begin
	    src1_data[16] <= result_alu1;
	    src1_datval[16] <= 1;
	 end
	 if (src_track[17] && src1_valid[17] && (~src1_datval[17]) && (src1_rrftag_val[17]) && (src1_rrftag[17] == buf_rrftag_alu1)) begin
	    src1_data[17] <= result_alu1;
	    src1_datval[17] <= 1;
	 end
	 if (src_track[18] && src1_valid[18] && (~src1_datval[18]) && (src1_rrftag_val[18]) && (src1_rrftag[18] == buf_rrftag_alu1)) begin
	    src1_data[18] <= result_alu1;
	    src1_datval[18] <= 1;
	 end
	 if (src_track[19] && src1_valid[19] && (~src1_datval[19]) && (src1_rrftag_val[19]) && (src1_rrftag[19] == buf_rrftag_alu1)) begin
	    src1_data[19] <= result_alu1;
	    src1_datval[19] <= 1;
	 end
	 if (src_track[20] && src1_valid[20] && (~src1_datval[20]) && (src1_rrftag_val[20]) && (src1_rrftag[20] == buf_rrftag_alu1)) begin
	    src1_data[20] <= result_alu1;
	    src1_datval[20] <= 1;
	 end
	 if (src_track[21] && src1_valid[21] && (~src1_datval[21]) && (src1_rrftag_val[21]) && (src1_rrftag[21] == buf_rrftag_alu1)) begin
	    src1_data[21] <= result_alu1;
	    src1_datval[21] <= 1;
	 end
	 if (src_track[22] && src1_valid[22] && (~src1_datval[22]) && (src1_rrftag_val[22]) && (src1_rrftag[22] == buf_rrftag_alu1)) begin
	    src1_data[22] <= result_alu1;
	    src1_datval[22] <= 1;
	 end
	 if (src_track[23] && src1_valid[23] && (~src1_datval[23]) && (src1_rrftag_val[23]) && (src1_rrftag[23] == buf_rrftag_alu1)) begin
	    src1_data[23] <= result_alu1;
	    src1_datval[23] <= 1;
	 end
	 if (src_track[24] && src1_valid[24] && (~src1_datval[24]) && (src1_rrftag_val[24]) && (src1_rrftag[24] == buf_rrftag_alu1)) begin
	    src1_data[24] <= result_alu1;
	    src1_datval[24] <= 1;
	 end
	 if (src_track[25] && src1_valid[25] && (~src1_datval[25]) && (src1_rrftag_val[25]) && (src1_rrftag[25] == buf_rrftag_alu1)) begin
	    src1_data[25] <= result_alu1;
	    src1_datval[25] <= 1;
	 end
	 if (src_track[26] && src1_valid[26] && (~src1_datval[26]) && (src1_rrftag_val[26]) && (src1_rrftag[26] == buf_rrftag_alu1)) begin
	    src1_data[26] <= result_alu1;
	    src1_datval[26] <= 1;
	 end
	 if (src_track[27] && src1_valid[27] && (~src1_datval[27]) && (src1_rrftag_val[27]) && (src1_rrftag[27] == buf_rrftag_alu1)) begin
	    src1_data[27] <= result_alu1;
	    src1_datval[27] <= 1;
	 end
	 if (src_track[28] && src1_valid[28] && (~src1_datval[28]) && (src1_rrftag_val[28]) && (src1_rrftag[28] == buf_rrftag_alu1)) begin
	    src1_data[28] <= result_alu1;
	    src1_datval[28] <= 1;
	 end
	 if (src_track[29] && src1_valid[29] && (~src1_datval[29]) && (src1_rrftag_val[29]) && (src1_rrftag[29] == buf_rrftag_alu1)) begin
	    src1_data[29] <= result_alu1;
	    src1_datval[29] <= 1;
	 end
	 if (src_track[30] && src1_valid[30] && (~src1_datval[30]) && (src1_rrftag_val[30]) && (src1_rrftag[30] == buf_rrftag_alu1)) begin
	    src1_data[30] <= result_alu1;
	    src1_datval[30] <= 1;
	 end
	 if (src_track[31] && src1_valid[31] && (~src1_datval[31]) && (src1_rrftag_val[31]) && (src1_rrftag[31] == buf_rrftag_alu1)) begin
	    src1_data[31] <= result_alu1;
	    src1_datval[31] <= 1;
	 end
	 if (src_track[32] && src1_valid[32] && (~src1_datval[32]) && (src1_rrftag_val[32]) && (src1_rrftag[32] == buf_rrftag_alu1)) begin
	    src1_data[32] <= result_alu1;
	    src1_datval[32] <= 1;
	 end
	 if (src_track[33] && src1_valid[33] && (~src1_datval[33]) && (src1_rrftag_val[33]) && (src1_rrftag[33] == buf_rrftag_alu1)) begin
	    src1_data[33] <= result_alu1;
	    src1_datval[33] <= 1;
	 end
	 if (src_track[34] && src1_valid[34] && (~src1_datval[34]) && (src1_rrftag_val[34]) && (src1_rrftag[34] == buf_rrftag_alu1)) begin
	    src1_data[34] <= result_alu1;
	    src1_datval[34] <= 1;
	 end
	 if (src_track[35] && src1_valid[35] && (~src1_datval[35]) && (src1_rrftag_val[35]) && (src1_rrftag[35] == buf_rrftag_alu1)) begin
	    src1_data[35] <= result_alu1;
	    src1_datval[35] <= 1;
	 end
	 if (src_track[36] && src1_valid[36] && (~src1_datval[36]) && (src1_rrftag_val[36]) && (src1_rrftag[36] == buf_rrftag_alu1)) begin
	    src1_data[36] <= result_alu1;
	    src1_datval[36] <= 1;
	 end
	 if (src_track[37] && src1_valid[37] && (~src1_datval[37]) && (src1_rrftag_val[37]) && (src1_rrftag[37] == buf_rrftag_alu1)) begin
	    src1_data[37] <= result_alu1;
	    src1_datval[37] <= 1;
	 end
	 if (src_track[38] && src1_valid[38] && (~src1_datval[38]) && (src1_rrftag_val[38]) && (src1_rrftag[38] == buf_rrftag_alu1)) begin
	    src1_data[38] <= result_alu1;
	    src1_datval[38] <= 1;
	 end
	 if (src_track[39] && src1_valid[39] && (~src1_datval[39]) && (src1_rrftag_val[39]) && (src1_rrftag[39] == buf_rrftag_alu1)) begin
	    src1_data[39] <= result_alu1;
	    src1_datval[39] <= 1;
	 end
	 if (src_track[40] && src1_valid[40] && (~src1_datval[40]) && (src1_rrftag_val[40]) && (src1_rrftag[40] == buf_rrftag_alu1)) begin
	    src1_data[40] <= result_alu1;
	    src1_datval[40] <= 1;
	 end
	 if (src_track[41] && src1_valid[41] && (~src1_datval[41]) && (src1_rrftag_val[41]) && (src1_rrftag[41] == buf_rrftag_alu1)) begin
	    src1_data[41] <= result_alu1;
	    src1_datval[41] <= 1;
	 end
	 if (src_track[42] && src1_valid[42] && (~src1_datval[42]) && (src1_rrftag_val[42]) && (src1_rrftag[42] == buf_rrftag_alu1)) begin
	    src1_data[42] <= result_alu1;
	    src1_datval[42] <= 1;
	 end
	 if (src_track[43] && src1_valid[43] && (~src1_datval[43]) && (src1_rrftag_val[43]) && (src1_rrftag[43] == buf_rrftag_alu1)) begin
	    src1_data[43] <= result_alu1;
	    src1_datval[43] <= 1;
	 end
	 if (src_track[44] && src1_valid[44] && (~src1_datval[44]) && (src1_rrftag_val[44]) && (src1_rrftag[44] == buf_rrftag_alu1)) begin
	    src1_data[44] <= result_alu1;
	    src1_datval[44] <= 1;
	 end
	 if (src_track[45] && src1_valid[45] && (~src1_datval[45]) && (src1_rrftag_val[45]) && (src1_rrftag[45] == buf_rrftag_alu1)) begin
	    src1_data[45] <= result_alu1;
	    src1_datval[45] <= 1;
	 end
	 if (src_track[46] && src1_valid[46] && (~src1_datval[46]) && (src1_rrftag_val[46]) && (src1_rrftag[46] == buf_rrftag_alu1)) begin
	    src1_data[46] <= result_alu1;
	    src1_datval[46] <= 1;
	 end
	 if (src_track[47] && src1_valid[47] && (~src1_datval[47]) && (src1_rrftag_val[47]) && (src1_rrftag[47] == buf_rrftag_alu1)) begin
	    src1_data[47] <= result_alu1;
	    src1_datval[47] <= 1;
	 end
	 if (src_track[48] && src1_valid[48] && (~src1_datval[48]) && (src1_rrftag_val[48]) && (src1_rrftag[48] == buf_rrftag_alu1)) begin
	    src1_data[48] <= result_alu1;
	    src1_datval[48] <= 1;
	 end
	 if (src_track[49] && src1_valid[49] && (~src1_datval[49]) && (src1_rrftag_val[49]) && (src1_rrftag[49] == buf_rrftag_alu1)) begin
	    src1_data[49] <= result_alu1;
	    src1_datval[49] <= 1;
	 end
	 if (src_track[50] && src1_valid[50] && (~src1_datval[50]) && (src1_rrftag_val[50]) && (src1_rrftag[50] == buf_rrftag_alu1)) begin
	    src1_data[50] <= result_alu1;
	    src1_datval[50] <= 1;
	 end
	 if (src_track[51] && src1_valid[51] && (~src1_datval[51]) && (src1_rrftag_val[51]) && (src1_rrftag[51] == buf_rrftag_alu1)) begin
	    src1_data[51] <= result_alu1;
	    src1_datval[51] <= 1;
	 end
	 if (src_track[52] && src1_valid[52] && (~src1_datval[52]) && (src1_rrftag_val[52]) && (src1_rrftag[52] == buf_rrftag_alu1)) begin
	    src1_data[52] <= result_alu1;
	    src1_datval[52] <= 1;
	 end
	 if (src_track[53] && src1_valid[53] && (~src1_datval[53]) && (src1_rrftag_val[53]) && (src1_rrftag[53] == buf_rrftag_alu1)) begin
	    src1_data[53] <= result_alu1;
	    src1_datval[53] <= 1;
	 end
	 if (src_track[54] && src1_valid[54] && (~src1_datval[54]) && (src1_rrftag_val[54]) && (src1_rrftag[54] == buf_rrftag_alu1)) begin
	    src1_data[54] <= result_alu1;
	    src1_datval[54] <= 1;
	 end
	 if (src_track[55] && src1_valid[55] && (~src1_datval[55]) && (src1_rrftag_val[55]) && (src1_rrftag[55] == buf_rrftag_alu1)) begin
	    src1_data[55] <= result_alu1;
	    src1_datval[55] <= 1;
	 end
	 if (src_track[56] && src1_valid[56] && (~src1_datval[56]) && (src1_rrftag_val[56]) && (src1_rrftag[56] == buf_rrftag_alu1)) begin
	    src1_data[56] <= result_alu1;
	    src1_datval[56] <= 1;
	 end
	 if (src_track[57] && src1_valid[57] && (~src1_datval[57]) && (src1_rrftag_val[57]) && (src1_rrftag[57] == buf_rrftag_alu1)) begin
	    src1_data[57] <= result_alu1;
	    src1_datval[57] <= 1;
	 end
	 if (src_track[58] && src1_valid[58] && (~src1_datval[58]) && (src1_rrftag_val[58]) && (src1_rrftag[58] == buf_rrftag_alu1)) begin
	    src1_data[58] <= result_alu1;
	    src1_datval[58] <= 1;
	 end
	 if (src_track[59] && src1_valid[59] && (~src1_datval[59]) && (src1_rrftag_val[59]) && (src1_rrftag[59] == buf_rrftag_alu1)) begin
	    src1_data[59] <= result_alu1;
	    src1_datval[59] <= 1;
	 end
	 if (src_track[60] && src1_valid[60] && (~src1_datval[60]) && (src1_rrftag_val[60]) && (src1_rrftag[60] == buf_rrftag_alu1)) begin
	    src1_data[60] <= result_alu1;
	    src1_datval[60] <= 1;
	 end
	 if (src_track[61] && src1_valid[61] && (~src1_datval[61]) && (src1_rrftag_val[61]) && (src1_rrftag[61] == buf_rrftag_alu1)) begin
	    src1_data[61] <= result_alu1;
	    src1_datval[61] <= 1;
	 end
	 if (src_track[62] && src1_valid[62] && (~src1_datval[62]) && (src1_rrftag_val[62]) && (src1_rrftag[62] == buf_rrftag_alu1)) begin
	    src1_data[62] <= result_alu1;
	    src1_datval[62] <= 1;
	 end
	 if (src_track[63] && src1_valid[63] && (~src1_datval[63]) && (src1_rrftag_val[63]) && (src1_rrftag[63] == buf_rrftag_alu1)) begin
	    src1_data[63] <= result_alu1;
	    src1_datval[63] <= 1;
	 end

	 if (src_track[0] && src2_valid[0] && (~src2_datval[0]) && (src2_rrftag_val[0]) && (src2_rrftag[0] == buf_rrftag_alu1)) begin
	    src2_data[0] <= result_alu1;
	    src2_datval[0] <= 1;
	 end
	 if (src_track[1] && src2_valid[1] && (~src2_datval[1]) && (src2_rrftag_val[1]) && (src2_rrftag[1] == buf_rrftag_alu1)) begin
	    src2_data[1] <= result_alu1;
	    src2_datval[1] <= 1;
	 end
	 if (src_track[2] && src2_valid[2] && (~src2_datval[2]) && (src2_rrftag_val[2]) && (src2_rrftag[2] == buf_rrftag_alu1)) begin
	    src2_data[2] <= result_alu1;
	    src2_datval[2] <= 1;
	 end
	 if (src_track[3] && src2_valid[3] && (~src2_datval[3]) && (src2_rrftag_val[3]) && (src2_rrftag[3] == buf_rrftag_alu1)) begin
	    src2_data[3] <= result_alu1;
	    src2_datval[3] <= 1;
	 end
	 if (src_track[4] && src2_valid[4] && (~src2_datval[4]) && (src2_rrftag_val[4]) && (src2_rrftag[4] == buf_rrftag_alu1)) begin
	    src2_data[4] <= result_alu1;
	    src2_datval[4] <= 1;
	 end
	 if (src_track[5] && src2_valid[5] && (~src2_datval[5]) && (src2_rrftag_val[5]) && (src2_rrftag[5] == buf_rrftag_alu1)) begin
	    src2_data[5] <= result_alu1;
	    src2_datval[5] <= 1;
	 end
	 if (src_track[6] && src2_valid[6] && (~src2_datval[6]) && (src2_rrftag_val[6]) && (src2_rrftag[6] == buf_rrftag_alu1)) begin
	    src2_data[6] <= result_alu1;
	    src2_datval[6] <= 1;
	 end
	 if (src_track[7] && src2_valid[7] && (~src2_datval[7]) && (src2_rrftag_val[7]) && (src2_rrftag[7] == buf_rrftag_alu1)) begin
	    src2_data[7] <= result_alu1;
	    src2_datval[7] <= 1;
	 end
	 if (src_track[8] && src2_valid[8] && (~src2_datval[8]) && (src2_rrftag_val[8]) && (src2_rrftag[8] == buf_rrftag_alu1)) begin
	    src2_data[8] <= result_alu1;
	    src2_datval[8] <= 1;
	 end
	 if (src_track[9] && src2_valid[9] && (~src2_datval[9]) && (src2_rrftag_val[9]) && (src2_rrftag[9] == buf_rrftag_alu1)) begin
	    src2_data[9] <= result_alu1;
	    src2_datval[9] <= 1;
	 end
	 if (src_track[10] && src2_valid[10] && (~src2_datval[10]) && (src2_rrftag_val[10]) && (src2_rrftag[10] == buf_rrftag_alu1)) begin
	    src2_data[10] <= result_alu1;
	    src2_datval[10] <= 1;
	 end
	 if (src_track[11] && src2_valid[11] && (~src2_datval[11]) && (src2_rrftag_val[11]) && (src2_rrftag[11] == buf_rrftag_alu1)) begin
	    src2_data[11] <= result_alu1;
	    src2_datval[11] <= 1;
	 end
	 if (src_track[12] && src2_valid[12] && (~src2_datval[12]) && (src2_rrftag_val[12]) && (src2_rrftag[12] == buf_rrftag_alu1)) begin
	    src2_data[12] <= result_alu1;
	    src2_datval[12] <= 1;
	 end
	 if (src_track[13] && src2_valid[13] && (~src2_datval[13]) && (src2_rrftag_val[13]) && (src2_rrftag[13] == buf_rrftag_alu1)) begin
	    src2_data[13] <= result_alu1;
	    src2_datval[13] <= 1;
	 end
	 if (src_track[14] && src2_valid[14] && (~src2_datval[14]) && (src2_rrftag_val[14]) && (src2_rrftag[14] == buf_rrftag_alu1)) begin
	    src2_data[14] <= result_alu1;
	    src2_datval[14] <= 1;
	 end
	 if (src_track[15] && src2_valid[15] && (~src2_datval[15]) && (src2_rrftag_val[15]) && (src2_rrftag[15] == buf_rrftag_alu1)) begin
	    src2_data[15] <= result_alu1;
	    src2_datval[15] <= 1;
	 end
	 if (src_track[16] && src2_valid[16] && (~src2_datval[16]) && (src2_rrftag_val[16]) && (src2_rrftag[16] == buf_rrftag_alu1)) begin
	    src2_data[16] <= result_alu1;
	    src2_datval[16] <= 1;
	 end
	 if (src_track[17] && src2_valid[17] && (~src2_datval[17]) && (src2_rrftag_val[17]) && (src2_rrftag[17] == buf_rrftag_alu1)) begin
	    src2_data[17] <= result_alu1;
	    src2_datval[17] <= 1;
	 end
	 if (src_track[18] && src2_valid[18] && (~src2_datval[18]) && (src2_rrftag_val[18]) && (src2_rrftag[18] == buf_rrftag_alu1)) begin
	    src2_data[18] <= result_alu1;
	    src2_datval[18] <= 1;
	 end
	 if (src_track[19] && src2_valid[19] && (~src2_datval[19]) && (src2_rrftag_val[19]) && (src2_rrftag[19] == buf_rrftag_alu1)) begin
	    src2_data[19] <= result_alu1;
	    src2_datval[19] <= 1;
	 end
	 if (src_track[20] && src2_valid[20] && (~src2_datval[20]) && (src2_rrftag_val[20]) && (src2_rrftag[20] == buf_rrftag_alu1)) begin
	    src2_data[20] <= result_alu1;
	    src2_datval[20] <= 1;
	 end
	 if (src_track[21] && src2_valid[21] && (~src2_datval[21]) && (src2_rrftag_val[21]) && (src2_rrftag[21] == buf_rrftag_alu1)) begin
	    src2_data[21] <= result_alu1;
	    src2_datval[21] <= 1;
	 end
	 if (src_track[22] && src2_valid[22] && (~src2_datval[22]) && (src2_rrftag_val[22]) && (src2_rrftag[22] == buf_rrftag_alu1)) begin
	    src2_data[22] <= result_alu1;
	    src2_datval[22] <= 1;
	 end
	 if (src_track[23] && src2_valid[23] && (~src2_datval[23]) && (src2_rrftag_val[23]) && (src2_rrftag[23] == buf_rrftag_alu1)) begin
	    src2_data[23] <= result_alu1;
	    src2_datval[23] <= 1;
	 end
	 if (src_track[24] && src2_valid[24] && (~src2_datval[24]) && (src2_rrftag_val[24]) && (src2_rrftag[24] == buf_rrftag_alu1)) begin
	    src2_data[24] <= result_alu1;
	    src2_datval[24] <= 1;
	 end
	 if (src_track[25] && src2_valid[25] && (~src2_datval[25]) && (src2_rrftag_val[25]) && (src2_rrftag[25] == buf_rrftag_alu1)) begin
	    src2_data[25] <= result_alu1;
	    src2_datval[25] <= 1;
	 end
	 if (src_track[26] && src2_valid[26] && (~src2_datval[26]) && (src2_rrftag_val[26]) && (src2_rrftag[26] == buf_rrftag_alu1)) begin
	    src2_data[26] <= result_alu1;
	    src2_datval[26] <= 1;
	 end
	 if (src_track[27] && src2_valid[27] && (~src2_datval[27]) && (src2_rrftag_val[27]) && (src2_rrftag[27] == buf_rrftag_alu1)) begin
	    src2_data[27] <= result_alu1;
	    src2_datval[27] <= 1;
	 end
	 if (src_track[28] && src2_valid[28] && (~src2_datval[28]) && (src2_rrftag_val[28]) && (src2_rrftag[28] == buf_rrftag_alu1)) begin
	    src2_data[28] <= result_alu1;
	    src2_datval[28] <= 1;
	 end
	 if (src_track[29] && src2_valid[29] && (~src2_datval[29]) && (src2_rrftag_val[29]) && (src2_rrftag[29] == buf_rrftag_alu1)) begin
	    src2_data[29] <= result_alu1;
	    src2_datval[29] <= 1;
	 end
	 if (src_track[30] && src2_valid[30] && (~src2_datval[30]) && (src2_rrftag_val[30]) && (src2_rrftag[30] == buf_rrftag_alu1)) begin
	    src2_data[30] <= result_alu1;
	    src2_datval[30] <= 1;
	 end
	 if (src_track[31] && src2_valid[31] && (~src2_datval[31]) && (src2_rrftag_val[31]) && (src2_rrftag[31] == buf_rrftag_alu1)) begin
	    src2_data[31] <= result_alu1;
	    src2_datval[31] <= 1;
	 end
	 if (src_track[32] && src2_valid[32] && (~src2_datval[32]) && (src2_rrftag_val[32]) && (src2_rrftag[32] == buf_rrftag_alu1)) begin
	    src2_data[32] <= result_alu1;
	    src2_datval[32] <= 1;
	 end
	 if (src_track[33] && src2_valid[33] && (~src2_datval[33]) && (src2_rrftag_val[33]) && (src2_rrftag[33] == buf_rrftag_alu1)) begin
	    src2_data[33] <= result_alu1;
	    src2_datval[33] <= 1;
	 end
	 if (src_track[34] && src2_valid[34] && (~src2_datval[34]) && (src2_rrftag_val[34]) && (src2_rrftag[34] == buf_rrftag_alu1)) begin
	    src2_data[34] <= result_alu1;
	    src2_datval[34] <= 1;
	 end
	 if (src_track[35] && src2_valid[35] && (~src2_datval[35]) && (src2_rrftag_val[35]) && (src2_rrftag[35] == buf_rrftag_alu1)) begin
	    src2_data[35] <= result_alu1;
	    src2_datval[35] <= 1;
	 end
	 if (src_track[36] && src2_valid[36] && (~src2_datval[36]) && (src2_rrftag_val[36]) && (src2_rrftag[36] == buf_rrftag_alu1)) begin
	    src2_data[36] <= result_alu1;
	    src2_datval[36] <= 1;
	 end
	 if (src_track[37] && src2_valid[37] && (~src2_datval[37]) && (src2_rrftag_val[37]) && (src2_rrftag[37] == buf_rrftag_alu1)) begin
	    src2_data[37] <= result_alu1;
	    src2_datval[37] <= 1;
	 end
	 if (src_track[38] && src2_valid[38] && (~src2_datval[38]) && (src2_rrftag_val[38]) && (src2_rrftag[38] == buf_rrftag_alu1)) begin
	    src2_data[38] <= result_alu1;
	    src2_datval[38] <= 1;
	 end
	 if (src_track[39] && src2_valid[39] && (~src2_datval[39]) && (src2_rrftag_val[39]) && (src2_rrftag[39] == buf_rrftag_alu1)) begin
	    src2_data[39] <= result_alu1;
	    src2_datval[39] <= 1;
	 end
	 if (src_track[40] && src2_valid[40] && (~src2_datval[40]) && (src2_rrftag_val[40]) && (src2_rrftag[40] == buf_rrftag_alu1)) begin
	    src2_data[40] <= result_alu1;
	    src2_datval[40] <= 1;
	 end
	 if (src_track[41] && src2_valid[41] && (~src2_datval[41]) && (src2_rrftag_val[41]) && (src2_rrftag[41] == buf_rrftag_alu1)) begin
	    src2_data[41] <= result_alu1;
	    src2_datval[41] <= 1;
	 end
	 if (src_track[42] && src2_valid[42] && (~src2_datval[42]) && (src2_rrftag_val[42]) && (src2_rrftag[42] == buf_rrftag_alu1)) begin
	    src2_data[42] <= result_alu1;
	    src2_datval[42] <= 1;
	 end
	 if (src_track[43] && src2_valid[43] && (~src2_datval[43]) && (src2_rrftag_val[43]) && (src2_rrftag[43] == buf_rrftag_alu1)) begin
	    src2_data[43] <= result_alu1;
	    src2_datval[43] <= 1;
	 end
	 if (src_track[44] && src2_valid[44] && (~src2_datval[44]) && (src2_rrftag_val[44]) && (src2_rrftag[44] == buf_rrftag_alu1)) begin
	    src2_data[44] <= result_alu1;
	    src2_datval[44] <= 1;
	 end
	 if (src_track[45] && src2_valid[45] && (~src2_datval[45]) && (src2_rrftag_val[45]) && (src2_rrftag[45] == buf_rrftag_alu1)) begin
	    src2_data[45] <= result_alu1;
	    src2_datval[45] <= 1;
	 end
	 if (src_track[46] && src2_valid[46] && (~src2_datval[46]) && (src2_rrftag_val[46]) && (src2_rrftag[46] == buf_rrftag_alu1)) begin
	    src2_data[46] <= result_alu1;
	    src2_datval[46] <= 1;
	 end
	 if (src_track[47] && src2_valid[47] && (~src2_datval[47]) && (src2_rrftag_val[47]) && (src2_rrftag[47] == buf_rrftag_alu1)) begin
	    src2_data[47] <= result_alu1;
	    src2_datval[47] <= 1;
	 end
	 if (src_track[48] && src2_valid[48] && (~src2_datval[48]) && (src2_rrftag_val[48]) && (src2_rrftag[48] == buf_rrftag_alu1)) begin
	    src2_data[48] <= result_alu1;
	    src2_datval[48] <= 1;
	 end
	 if (src_track[49] && src2_valid[49] && (~src2_datval[49]) && (src2_rrftag_val[49]) && (src2_rrftag[49] == buf_rrftag_alu1)) begin
	    src2_data[49] <= result_alu1;
	    src2_datval[49] <= 1;
	 end
	 if (src_track[50] && src2_valid[50] && (~src2_datval[50]) && (src2_rrftag_val[50]) && (src2_rrftag[50] == buf_rrftag_alu1)) begin
	    src2_data[50] <= result_alu1;
	    src2_datval[50] <= 1;
	 end
	 if (src_track[51] && src2_valid[51] && (~src2_datval[51]) && (src2_rrftag_val[51]) && (src2_rrftag[51] == buf_rrftag_alu1)) begin
	    src2_data[51] <= result_alu1;
	    src2_datval[51] <= 1;
	 end
	 if (src_track[52] && src2_valid[52] && (~src2_datval[52]) && (src2_rrftag_val[52]) && (src2_rrftag[52] == buf_rrftag_alu1)) begin
	    src2_data[52] <= result_alu1;
	    src2_datval[52] <= 1;
	 end
	 if (src_track[53] && src2_valid[53] && (~src2_datval[53]) && (src2_rrftag_val[53]) && (src2_rrftag[53] == buf_rrftag_alu1)) begin
	    src2_data[53] <= result_alu1;
	    src2_datval[53] <= 1;
	 end
	 if (src_track[54] && src2_valid[54] && (~src2_datval[54]) && (src2_rrftag_val[54]) && (src2_rrftag[54] == buf_rrftag_alu1)) begin
	    src2_data[54] <= result_alu1;
	    src2_datval[54] <= 1;
	 end
	 if (src_track[55] && src2_valid[55] && (~src2_datval[55]) && (src2_rrftag_val[55]) && (src2_rrftag[55] == buf_rrftag_alu1)) begin
	    src2_data[55] <= result_alu1;
	    src2_datval[55] <= 1;
	 end
	 if (src_track[56] && src2_valid[56] && (~src2_datval[56]) && (src2_rrftag_val[56]) && (src2_rrftag[56] == buf_rrftag_alu1)) begin
	    src2_data[56] <= result_alu1;
	    src2_datval[56] <= 1;
	 end
	 if (src_track[57] && src2_valid[57] && (~src2_datval[57]) && (src2_rrftag_val[57]) && (src2_rrftag[57] == buf_rrftag_alu1)) begin
	    src2_data[57] <= result_alu1;
	    src2_datval[57] <= 1;
	 end
	 if (src_track[58] && src2_valid[58] && (~src2_datval[58]) && (src2_rrftag_val[58]) && (src2_rrftag[58] == buf_rrftag_alu1)) begin
	    src2_data[58] <= result_alu1;
	    src2_datval[58] <= 1;
	 end
	 if (src_track[59] && src2_valid[59] && (~src2_datval[59]) && (src2_rrftag_val[59]) && (src2_rrftag[59] == buf_rrftag_alu1)) begin
	    src2_data[59] <= result_alu1;
	    src2_datval[59] <= 1;
	 end
	 if (src_track[60] && src2_valid[60] && (~src2_datval[60]) && (src2_rrftag_val[60]) && (src2_rrftag[60] == buf_rrftag_alu1)) begin
	    src2_data[60] <= result_alu1;
	    src2_datval[60] <= 1;
	 end
	 if (src_track[61] && src2_valid[61] && (~src2_datval[61]) && (src2_rrftag_val[61]) && (src2_rrftag[61] == buf_rrftag_alu1)) begin
	    src2_data[61] <= result_alu1;
	    src2_datval[61] <= 1;
	 end
	 if (src_track[62] && src2_valid[62] && (~src2_datval[62]) && (src2_rrftag_val[62]) && (src2_rrftag[62] == buf_rrftag_alu1)) begin
	    src2_data[62] <= result_alu1;
	    src2_datval[62] <= 1;
	 end
	 if (src_track[63] && src2_valid[63] && (~src2_datval[63]) && (src2_rrftag_val[63]) && (src2_rrftag[63] == buf_rrftag_alu1)) begin
	    src2_data[63] <= result_alu1;
	    src2_datval[63] <= 1;
	 end
      end // if (robwe_alu1)

      if (robwe_alu2) begin
	 if (src_track[0] && src1_valid[0] && (~src1_datval[0]) && (src1_rrftag_val[0]) && (src1_rrftag[0] == buf_rrftag_alu2)) begin
	    src1_data[0] <= result_alu2;
	    src1_datval[0] <= 1;
	 end
	 if (src_track[1] && src1_valid[1] && (~src1_datval[1]) && (src1_rrftag_val[1]) && (src1_rrftag[1] == buf_rrftag_alu2)) begin
	    src1_data[1] <= result_alu2;
	    src1_datval[1] <= 1;
	 end
	 if (src_track[2] && src1_valid[2] && (~src1_datval[2]) && (src1_rrftag_val[2]) && (src1_rrftag[2] == buf_rrftag_alu2)) begin
	    src1_data[2] <= result_alu2;
	    src1_datval[2] <= 1;
	 end
	 if (src_track[3] && src1_valid[3] && (~src1_datval[3]) && (src1_rrftag_val[3]) && (src1_rrftag[3] == buf_rrftag_alu2)) begin
	    src1_data[3] <= result_alu2;
	    src1_datval[3] <= 1;
	 end
	 if (src_track[4] && src1_valid[4] && (~src1_datval[4]) && (src1_rrftag_val[4]) && (src1_rrftag[4] == buf_rrftag_alu2)) begin
	    src1_data[4] <= result_alu2;
	    src1_datval[4] <= 1;
	 end
	 if (src_track[5] && src1_valid[5] && (~src1_datval[5]) && (src1_rrftag_val[5]) && (src1_rrftag[5] == buf_rrftag_alu2)) begin
	    src1_data[5] <= result_alu2;
	    src1_datval[5] <= 1;
	 end
	 if (src_track[6] && src1_valid[6] && (~src1_datval[6]) && (src1_rrftag_val[6]) && (src1_rrftag[6] == buf_rrftag_alu2)) begin
	    src1_data[6] <= result_alu2;
	    src1_datval[6] <= 1;
	 end
	 if (src_track[7] && src1_valid[7] && (~src1_datval[7]) && (src1_rrftag_val[7]) && (src1_rrftag[7] == buf_rrftag_alu2)) begin
	    src1_data[7] <= result_alu2;
	    src1_datval[7] <= 1;
	 end
	 if (src_track[8] && src1_valid[8] && (~src1_datval[8]) && (src1_rrftag_val[8]) && (src1_rrftag[8] == buf_rrftag_alu2)) begin
	    src1_data[8] <= result_alu2;
	    src1_datval[8] <= 1;
	 end
	 if (src_track[9] && src1_valid[9] && (~src1_datval[9]) && (src1_rrftag_val[9]) && (src1_rrftag[9] == buf_rrftag_alu2)) begin
	    src1_data[9] <= result_alu2;
	    src1_datval[9] <= 1;
	 end
	 if (src_track[10] && src1_valid[10] && (~src1_datval[10]) && (src1_rrftag_val[10]) && (src1_rrftag[10] == buf_rrftag_alu2)) begin
	    src1_data[10] <= result_alu2;
	    src1_datval[10] <= 1;
	 end
	 if (src_track[11] && src1_valid[11] && (~src1_datval[11]) && (src1_rrftag_val[11]) && (src1_rrftag[11] == buf_rrftag_alu2)) begin
	    src1_data[11] <= result_alu2;
	    src1_datval[11] <= 1;
	 end
	 if (src_track[12] && src1_valid[12] && (~src1_datval[12]) && (src1_rrftag_val[12]) && (src1_rrftag[12] == buf_rrftag_alu2)) begin
	    src1_data[12] <= result_alu2;
	    src1_datval[12] <= 1;
	 end
	 if (src_track[13] && src1_valid[13] && (~src1_datval[13]) && (src1_rrftag_val[13]) && (src1_rrftag[13] == buf_rrftag_alu2)) begin
	    src1_data[13] <= result_alu2;
	    src1_datval[13] <= 1;
	 end
	 if (src_track[14] && src1_valid[14] && (~src1_datval[14]) && (src1_rrftag_val[14]) && (src1_rrftag[14] == buf_rrftag_alu2)) begin
	    src1_data[14] <= result_alu2;
	    src1_datval[14] <= 1;
	 end
	 if (src_track[15] && src1_valid[15] && (~src1_datval[15]) && (src1_rrftag_val[15]) && (src1_rrftag[15] == buf_rrftag_alu2)) begin
	    src1_data[15] <= result_alu2;
	    src1_datval[15] <= 1;
	 end
	 if (src_track[16] && src1_valid[16] && (~src1_datval[16]) && (src1_rrftag_val[16]) && (src1_rrftag[16] == buf_rrftag_alu2)) begin
	    src1_data[16] <= result_alu2;
	    src1_datval[16] <= 1;
	 end
	 if (src_track[17] && src1_valid[17] && (~src1_datval[17]) && (src1_rrftag_val[17]) && (src1_rrftag[17] == buf_rrftag_alu2)) begin
	    src1_data[17] <= result_alu2;
	    src1_datval[17] <= 1;
	 end
	 if (src_track[18] && src1_valid[18] && (~src1_datval[18]) && (src1_rrftag_val[18]) && (src1_rrftag[18] == buf_rrftag_alu2)) begin
	    src1_data[18] <= result_alu2;
	    src1_datval[18] <= 1;
	 end
	 if (src_track[19] && src1_valid[19] && (~src1_datval[19]) && (src1_rrftag_val[19]) && (src1_rrftag[19] == buf_rrftag_alu2)) begin
	    src1_data[19] <= result_alu2;
	    src1_datval[19] <= 1;
	 end
	 if (src_track[20] && src1_valid[20] && (~src1_datval[20]) && (src1_rrftag_val[20]) && (src1_rrftag[20] == buf_rrftag_alu2)) begin
	    src1_data[20] <= result_alu2;
	    src1_datval[20] <= 1;
	 end
	 if (src_track[21] && src1_valid[21] && (~src1_datval[21]) && (src1_rrftag_val[21]) && (src1_rrftag[21] == buf_rrftag_alu2)) begin
	    src1_data[21] <= result_alu2;
	    src1_datval[21] <= 1;
	 end
	 if (src_track[22] && src1_valid[22] && (~src1_datval[22]) && (src1_rrftag_val[22]) && (src1_rrftag[22] == buf_rrftag_alu2)) begin
	    src1_data[22] <= result_alu2;
	    src1_datval[22] <= 1;
	 end
	 if (src_track[23] && src1_valid[23] && (~src1_datval[23]) && (src1_rrftag_val[23]) && (src1_rrftag[23] == buf_rrftag_alu2)) begin
	    src1_data[23] <= result_alu2;
	    src1_datval[23] <= 1;
	 end
	 if (src_track[24] && src1_valid[24] && (~src1_datval[24]) && (src1_rrftag_val[24]) && (src1_rrftag[24] == buf_rrftag_alu2)) begin
	    src1_data[24] <= result_alu2;
	    src1_datval[24] <= 1;
	 end
	 if (src_track[25] && src1_valid[25] && (~src1_datval[25]) && (src1_rrftag_val[25]) && (src1_rrftag[25] == buf_rrftag_alu2)) begin
	    src1_data[25] <= result_alu2;
	    src1_datval[25] <= 1;
	 end
	 if (src_track[26] && src1_valid[26] && (~src1_datval[26]) && (src1_rrftag_val[26]) && (src1_rrftag[26] == buf_rrftag_alu2)) begin
	    src1_data[26] <= result_alu2;
	    src1_datval[26] <= 1;
	 end
	 if (src_track[27] && src1_valid[27] && (~src1_datval[27]) && (src1_rrftag_val[27]) && (src1_rrftag[27] == buf_rrftag_alu2)) begin
	    src1_data[27] <= result_alu2;
	    src1_datval[27] <= 1;
	 end
	 if (src_track[28] && src1_valid[28] && (~src1_datval[28]) && (src1_rrftag_val[28]) && (src1_rrftag[28] == buf_rrftag_alu2)) begin
	    src1_data[28] <= result_alu2;
	    src1_datval[28] <= 1;
	 end
	 if (src_track[29] && src1_valid[29] && (~src1_datval[29]) && (src1_rrftag_val[29]) && (src1_rrftag[29] == buf_rrftag_alu2)) begin
	    src1_data[29] <= result_alu2;
	    src1_datval[29] <= 1;
	 end
	 if (src_track[30] && src1_valid[30] && (~src1_datval[30]) && (src1_rrftag_val[30]) && (src1_rrftag[30] == buf_rrftag_alu2)) begin
	    src1_data[30] <= result_alu2;
	    src1_datval[30] <= 1;
	 end
	 if (src_track[31] && src1_valid[31] && (~src1_datval[31]) && (src1_rrftag_val[31]) && (src1_rrftag[31] == buf_rrftag_alu2)) begin
	    src1_data[31] <= result_alu2;
	    src1_datval[31] <= 1;
	 end
	 if (src_track[32] && src1_valid[32] && (~src1_datval[32]) && (src1_rrftag_val[32]) && (src1_rrftag[32] == buf_rrftag_alu2)) begin
	    src1_data[32] <= result_alu2;
	    src1_datval[32] <= 1;
	 end
	 if (src_track[33] && src1_valid[33] && (~src1_datval[33]) && (src1_rrftag_val[33]) && (src1_rrftag[33] == buf_rrftag_alu2)) begin
	    src1_data[33] <= result_alu2;
	    src1_datval[33] <= 1;
	 end
	 if (src_track[34] && src1_valid[34] && (~src1_datval[34]) && (src1_rrftag_val[34]) && (src1_rrftag[34] == buf_rrftag_alu2)) begin
	    src1_data[34] <= result_alu2;
	    src1_datval[34] <= 1;
	 end
	 if (src_track[35] && src1_valid[35] && (~src1_datval[35]) && (src1_rrftag_val[35]) && (src1_rrftag[35] == buf_rrftag_alu2)) begin
	    src1_data[35] <= result_alu2;
	    src1_datval[35] <= 1;
	 end
	 if (src_track[36] && src1_valid[36] && (~src1_datval[36]) && (src1_rrftag_val[36]) && (src1_rrftag[36] == buf_rrftag_alu2)) begin
	    src1_data[36] <= result_alu2;
	    src1_datval[36] <= 1;
	 end
	 if (src_track[37] && src1_valid[37] && (~src1_datval[37]) && (src1_rrftag_val[37]) && (src1_rrftag[37] == buf_rrftag_alu2)) begin
	    src1_data[37] <= result_alu2;
	    src1_datval[37] <= 1;
	 end
	 if (src_track[38] && src1_valid[38] && (~src1_datval[38]) && (src1_rrftag_val[38]) && (src1_rrftag[38] == buf_rrftag_alu2)) begin
	    src1_data[38] <= result_alu2;
	    src1_datval[38] <= 1;
	 end
	 if (src_track[39] && src1_valid[39] && (~src1_datval[39]) && (src1_rrftag_val[39]) && (src1_rrftag[39] == buf_rrftag_alu2)) begin
	    src1_data[39] <= result_alu2;
	    src1_datval[39] <= 1;
	 end
	 if (src_track[40] && src1_valid[40] && (~src1_datval[40]) && (src1_rrftag_val[40]) && (src1_rrftag[40] == buf_rrftag_alu2)) begin
	    src1_data[40] <= result_alu2;
	    src1_datval[40] <= 1;
	 end
	 if (src_track[41] && src1_valid[41] && (~src1_datval[41]) && (src1_rrftag_val[41]) && (src1_rrftag[41] == buf_rrftag_alu2)) begin
	    src1_data[41] <= result_alu2;
	    src1_datval[41] <= 1;
	 end
	 if (src_track[42] && src1_valid[42] && (~src1_datval[42]) && (src1_rrftag_val[42]) && (src1_rrftag[42] == buf_rrftag_alu2)) begin
	    src1_data[42] <= result_alu2;
	    src1_datval[42] <= 1;
	 end
	 if (src_track[43] && src1_valid[43] && (~src1_datval[43]) && (src1_rrftag_val[43]) && (src1_rrftag[43] == buf_rrftag_alu2)) begin
	    src1_data[43] <= result_alu2;
	    src1_datval[43] <= 1;
	 end
	 if (src_track[44] && src1_valid[44] && (~src1_datval[44]) && (src1_rrftag_val[44]) && (src1_rrftag[44] == buf_rrftag_alu2)) begin
	    src1_data[44] <= result_alu2;
	    src1_datval[44] <= 1;
	 end
	 if (src_track[45] && src1_valid[45] && (~src1_datval[45]) && (src1_rrftag_val[45]) && (src1_rrftag[45] == buf_rrftag_alu2)) begin
	    src1_data[45] <= result_alu2;
	    src1_datval[45] <= 1;
	 end
	 if (src_track[46] && src1_valid[46] && (~src1_datval[46]) && (src1_rrftag_val[46]) && (src1_rrftag[46] == buf_rrftag_alu2)) begin
	    src1_data[46] <= result_alu2;
	    src1_datval[46] <= 1;
	 end
	 if (src_track[47] && src1_valid[47] && (~src1_datval[47]) && (src1_rrftag_val[47]) && (src1_rrftag[47] == buf_rrftag_alu2)) begin
	    src1_data[47] <= result_alu2;
	    src1_datval[47] <= 1;
	 end
	 if (src_track[48] && src1_valid[48] && (~src1_datval[48]) && (src1_rrftag_val[48]) && (src1_rrftag[48] == buf_rrftag_alu2)) begin
	    src1_data[48] <= result_alu2;
	    src1_datval[48] <= 1;
	 end
	 if (src_track[49] && src1_valid[49] && (~src1_datval[49]) && (src1_rrftag_val[49]) && (src1_rrftag[49] == buf_rrftag_alu2)) begin
	    src1_data[49] <= result_alu2;
	    src1_datval[49] <= 1;
	 end
	 if (src_track[50] && src1_valid[50] && (~src1_datval[50]) && (src1_rrftag_val[50]) && (src1_rrftag[50] == buf_rrftag_alu2)) begin
	    src1_data[50] <= result_alu2;
	    src1_datval[50] <= 1;
	 end
	 if (src_track[51] && src1_valid[51] && (~src1_datval[51]) && (src1_rrftag_val[51]) && (src1_rrftag[51] == buf_rrftag_alu2)) begin
	    src1_data[51] <= result_alu2;
	    src1_datval[51] <= 1;
	 end
	 if (src_track[52] && src1_valid[52] && (~src1_datval[52]) && (src1_rrftag_val[52]) && (src1_rrftag[52] == buf_rrftag_alu2)) begin
	    src1_data[52] <= result_alu2;
	    src1_datval[52] <= 1;
	 end
	 if (src_track[53] && src1_valid[53] && (~src1_datval[53]) && (src1_rrftag_val[53]) && (src1_rrftag[53] == buf_rrftag_alu2)) begin
	    src1_data[53] <= result_alu2;
	    src1_datval[53] <= 1;
	 end
	 if (src_track[54] && src1_valid[54] && (~src1_datval[54]) && (src1_rrftag_val[54]) && (src1_rrftag[54] == buf_rrftag_alu2)) begin
	    src1_data[54] <= result_alu2;
	    src1_datval[54] <= 1;
	 end
	 if (src_track[55] && src1_valid[55] && (~src1_datval[55]) && (src1_rrftag_val[55]) && (src1_rrftag[55] == buf_rrftag_alu2)) begin
	    src1_data[55] <= result_alu2;
	    src1_datval[55] <= 1;
	 end
	 if (src_track[56] && src1_valid[56] && (~src1_datval[56]) && (src1_rrftag_val[56]) && (src1_rrftag[56] == buf_rrftag_alu2)) begin
	    src1_data[56] <= result_alu2;
	    src1_datval[56] <= 1;
	 end
	 if (src_track[57] && src1_valid[57] && (~src1_datval[57]) && (src1_rrftag_val[57]) && (src1_rrftag[57] == buf_rrftag_alu2)) begin
	    src1_data[57] <= result_alu2;
	    src1_datval[57] <= 1;
	 end
	 if (src_track[58] && src1_valid[58] && (~src1_datval[58]) && (src1_rrftag_val[58]) && (src1_rrftag[58] == buf_rrftag_alu2)) begin
	    src1_data[58] <= result_alu2;
	    src1_datval[58] <= 1;
	 end
	 if (src_track[59] && src1_valid[59] && (~src1_datval[59]) && (src1_rrftag_val[59]) && (src1_rrftag[59] == buf_rrftag_alu2)) begin
	    src1_data[59] <= result_alu2;
	    src1_datval[59] <= 1;
	 end
	 if (src_track[60] && src1_valid[60] && (~src1_datval[60]) && (src1_rrftag_val[60]) && (src1_rrftag[60] == buf_rrftag_alu2)) begin
	    src1_data[60] <= result_alu2;
	    src1_datval[60] <= 1;
	 end
	 if (src_track[61] && src1_valid[61] && (~src1_datval[61]) && (src1_rrftag_val[61]) && (src1_rrftag[61] == buf_rrftag_alu2)) begin
	    src1_data[61] <= result_alu2;
	    src1_datval[61] <= 1;
	 end
	 if (src_track[62] && src1_valid[62] && (~src1_datval[62]) && (src1_rrftag_val[62]) && (src1_rrftag[62] == buf_rrftag_alu2)) begin
	    src1_data[62] <= result_alu2;
	    src1_datval[62] <= 1;
	 end
	 if (src_track[63] && src1_valid[63] && (~src1_datval[63]) && (src1_rrftag_val[63]) && (src1_rrftag[63] == buf_rrftag_alu2)) begin
	    src1_data[63] <= result_alu2;
	    src1_datval[63] <= 1;
	 end

	 if (src_track[0] && src2_valid[0] && (~src2_datval[0]) && (src2_rrftag_val[0]) && (src2_rrftag[0] == buf_rrftag_alu2)) begin
	    src2_data[0] <= result_alu2;
	    src2_datval[0] <= 1;
	 end
	 if (src_track[1] && src2_valid[1] && (~src2_datval[1]) && (src2_rrftag_val[1]) && (src2_rrftag[1] == buf_rrftag_alu2)) begin
	    src2_data[1] <= result_alu2;
	    src2_datval[1] <= 1;
	 end
	 if (src_track[2] && src2_valid[2] && (~src2_datval[2]) && (src2_rrftag_val[2]) && (src2_rrftag[2] == buf_rrftag_alu2)) begin
	    src2_data[2] <= result_alu2;
	    src2_datval[2] <= 1;
	 end
	 if (src_track[3] && src2_valid[3] && (~src2_datval[3]) && (src2_rrftag_val[3]) && (src2_rrftag[3] == buf_rrftag_alu2)) begin
	    src2_data[3] <= result_alu2;
	    src2_datval[3] <= 1;
	 end
	 if (src_track[4] && src2_valid[4] && (~src2_datval[4]) && (src2_rrftag_val[4]) && (src2_rrftag[4] == buf_rrftag_alu2)) begin
	    src2_data[4] <= result_alu2;
	    src2_datval[4] <= 1;
	 end
	 if (src_track[5] && src2_valid[5] && (~src2_datval[5]) && (src2_rrftag_val[5]) && (src2_rrftag[5] == buf_rrftag_alu2)) begin
	    src2_data[5] <= result_alu2;
	    src2_datval[5] <= 1;
	 end
	 if (src_track[6] && src2_valid[6] && (~src2_datval[6]) && (src2_rrftag_val[6]) && (src2_rrftag[6] == buf_rrftag_alu2)) begin
	    src2_data[6] <= result_alu2;
	    src2_datval[6] <= 1;
	 end
	 if (src_track[7] && src2_valid[7] && (~src2_datval[7]) && (src2_rrftag_val[7]) && (src2_rrftag[7] == buf_rrftag_alu2)) begin
	    src2_data[7] <= result_alu2;
	    src2_datval[7] <= 1;
	 end
	 if (src_track[8] && src2_valid[8] && (~src2_datval[8]) && (src2_rrftag_val[8]) && (src2_rrftag[8] == buf_rrftag_alu2)) begin
	    src2_data[8] <= result_alu2;
	    src2_datval[8] <= 1;
	 end
	 if (src_track[9] && src2_valid[9] && (~src2_datval[9]) && (src2_rrftag_val[9]) && (src2_rrftag[9] == buf_rrftag_alu2)) begin
	    src2_data[9] <= result_alu2;
	    src2_datval[9] <= 1;
	 end
	 if (src_track[10] && src2_valid[10] && (~src2_datval[10]) && (src2_rrftag_val[10]) && (src2_rrftag[10] == buf_rrftag_alu2)) begin
	    src2_data[10] <= result_alu2;
	    src2_datval[10] <= 1;
	 end
	 if (src_track[11] && src2_valid[11] && (~src2_datval[11]) && (src2_rrftag_val[11]) && (src2_rrftag[11] == buf_rrftag_alu2)) begin
	    src2_data[11] <= result_alu2;
	    src2_datval[11] <= 1;
	 end
	 if (src_track[12] && src2_valid[12] && (~src2_datval[12]) && (src2_rrftag_val[12]) && (src2_rrftag[12] == buf_rrftag_alu2)) begin
	    src2_data[12] <= result_alu2;
	    src2_datval[12] <= 1;
	 end
	 if (src_track[13] && src2_valid[13] && (~src2_datval[13]) && (src2_rrftag_val[13]) && (src2_rrftag[13] == buf_rrftag_alu2)) begin
	    src2_data[13] <= result_alu2;
	    src2_datval[13] <= 1;
	 end
	 if (src_track[14] && src2_valid[14] && (~src2_datval[14]) && (src2_rrftag_val[14]) && (src2_rrftag[14] == buf_rrftag_alu2)) begin
	    src2_data[14] <= result_alu2;
	    src2_datval[14] <= 1;
	 end
	 if (src_track[15] && src2_valid[15] && (~src2_datval[15]) && (src2_rrftag_val[15]) && (src2_rrftag[15] == buf_rrftag_alu2)) begin
	    src2_data[15] <= result_alu2;
	    src2_datval[15] <= 1;
	 end
	 if (src_track[16] && src2_valid[16] && (~src2_datval[16]) && (src2_rrftag_val[16]) && (src2_rrftag[16] == buf_rrftag_alu2)) begin
	    src2_data[16] <= result_alu2;
	    src2_datval[16] <= 1;
	 end
	 if (src_track[17] && src2_valid[17] && (~src2_datval[17]) && (src2_rrftag_val[17]) && (src2_rrftag[17] == buf_rrftag_alu2)) begin
	    src2_data[17] <= result_alu2;
	    src2_datval[17] <= 1;
	 end
	 if (src_track[18] && src2_valid[18] && (~src2_datval[18]) && (src2_rrftag_val[18]) && (src2_rrftag[18] == buf_rrftag_alu2)) begin
	    src2_data[18] <= result_alu2;
	    src2_datval[18] <= 1;
	 end
	 if (src_track[19] && src2_valid[19] && (~src2_datval[19]) && (src2_rrftag_val[19]) && (src2_rrftag[19] == buf_rrftag_alu2)) begin
	    src2_data[19] <= result_alu2;
	    src2_datval[19] <= 1;
	 end
	 if (src_track[20] && src2_valid[20] && (~src2_datval[20]) && (src2_rrftag_val[20]) && (src2_rrftag[20] == buf_rrftag_alu2)) begin
	    src2_data[20] <= result_alu2;
	    src2_datval[20] <= 1;
	 end
	 if (src_track[21] && src2_valid[21] && (~src2_datval[21]) && (src2_rrftag_val[21]) && (src2_rrftag[21] == buf_rrftag_alu2)) begin
	    src2_data[21] <= result_alu2;
	    src2_datval[21] <= 1;
	 end
	 if (src_track[22] && src2_valid[22] && (~src2_datval[22]) && (src2_rrftag_val[22]) && (src2_rrftag[22] == buf_rrftag_alu2)) begin
	    src2_data[22] <= result_alu2;
	    src2_datval[22] <= 1;
	 end
	 if (src_track[23] && src2_valid[23] && (~src2_datval[23]) && (src2_rrftag_val[23]) && (src2_rrftag[23] == buf_rrftag_alu2)) begin
	    src2_data[23] <= result_alu2;
	    src2_datval[23] <= 1;
	 end
	 if (src_track[24] && src2_valid[24] && (~src2_datval[24]) && (src2_rrftag_val[24]) && (src2_rrftag[24] == buf_rrftag_alu2)) begin
	    src2_data[24] <= result_alu2;
	    src2_datval[24] <= 1;
	 end
	 if (src_track[25] && src2_valid[25] && (~src2_datval[25]) && (src2_rrftag_val[25]) && (src2_rrftag[25] == buf_rrftag_alu2)) begin
	    src2_data[25] <= result_alu2;
	    src2_datval[25] <= 1;
	 end
	 if (src_track[26] && src2_valid[26] && (~src2_datval[26]) && (src2_rrftag_val[26]) && (src2_rrftag[26] == buf_rrftag_alu2)) begin
	    src2_data[26] <= result_alu2;
	    src2_datval[26] <= 1;
	 end
	 if (src_track[27] && src2_valid[27] && (~src2_datval[27]) && (src2_rrftag_val[27]) && (src2_rrftag[27] == buf_rrftag_alu2)) begin
	    src2_data[27] <= result_alu2;
	    src2_datval[27] <= 1;
	 end
	 if (src_track[28] && src2_valid[28] && (~src2_datval[28]) && (src2_rrftag_val[28]) && (src2_rrftag[28] == buf_rrftag_alu2)) begin
	    src2_data[28] <= result_alu2;
	    src2_datval[28] <= 1;
	 end
	 if (src_track[29] && src2_valid[29] && (~src2_datval[29]) && (src2_rrftag_val[29]) && (src2_rrftag[29] == buf_rrftag_alu2)) begin
	    src2_data[29] <= result_alu2;
	    src2_datval[29] <= 1;
	 end
	 if (src_track[30] && src2_valid[30] && (~src2_datval[30]) && (src2_rrftag_val[30]) && (src2_rrftag[30] == buf_rrftag_alu2)) begin
	    src2_data[30] <= result_alu2;
	    src2_datval[30] <= 1;
	 end
	 if (src_track[31] && src2_valid[31] && (~src2_datval[31]) && (src2_rrftag_val[31]) && (src2_rrftag[31] == buf_rrftag_alu2)) begin
	    src2_data[31] <= result_alu2;
	    src2_datval[31] <= 1;
	 end
	 if (src_track[32] && src2_valid[32] && (~src2_datval[32]) && (src2_rrftag_val[32]) && (src2_rrftag[32] == buf_rrftag_alu2)) begin
	    src2_data[32] <= result_alu2;
	    src2_datval[32] <= 1;
	 end
	 if (src_track[33] && src2_valid[33] && (~src2_datval[33]) && (src2_rrftag_val[33]) && (src2_rrftag[33] == buf_rrftag_alu2)) begin
	    src2_data[33] <= result_alu2;
	    src2_datval[33] <= 1;
	 end
	 if (src_track[34] && src2_valid[34] && (~src2_datval[34]) && (src2_rrftag_val[34]) && (src2_rrftag[34] == buf_rrftag_alu2)) begin
	    src2_data[34] <= result_alu2;
	    src2_datval[34] <= 1;
	 end
	 if (src_track[35] && src2_valid[35] && (~src2_datval[35]) && (src2_rrftag_val[35]) && (src2_rrftag[35] == buf_rrftag_alu2)) begin
	    src2_data[35] <= result_alu2;
	    src2_datval[35] <= 1;
	 end
	 if (src_track[36] && src2_valid[36] && (~src2_datval[36]) && (src2_rrftag_val[36]) && (src2_rrftag[36] == buf_rrftag_alu2)) begin
	    src2_data[36] <= result_alu2;
	    src2_datval[36] <= 1;
	 end
	 if (src_track[37] && src2_valid[37] && (~src2_datval[37]) && (src2_rrftag_val[37]) && (src2_rrftag[37] == buf_rrftag_alu2)) begin
	    src2_data[37] <= result_alu2;
	    src2_datval[37] <= 1;
	 end
	 if (src_track[38] && src2_valid[38] && (~src2_datval[38]) && (src2_rrftag_val[38]) && (src2_rrftag[38] == buf_rrftag_alu2)) begin
	    src2_data[38] <= result_alu2;
	    src2_datval[38] <= 1;
	 end
	 if (src_track[39] && src2_valid[39] && (~src2_datval[39]) && (src2_rrftag_val[39]) && (src2_rrftag[39] == buf_rrftag_alu2)) begin
	    src2_data[39] <= result_alu2;
	    src2_datval[39] <= 1;
	 end
	 if (src_track[40] && src2_valid[40] && (~src2_datval[40]) && (src2_rrftag_val[40]) && (src2_rrftag[40] == buf_rrftag_alu2)) begin
	    src2_data[40] <= result_alu2;
	    src2_datval[40] <= 1;
	 end
	 if (src_track[41] && src2_valid[41] && (~src2_datval[41]) && (src2_rrftag_val[41]) && (src2_rrftag[41] == buf_rrftag_alu2)) begin
	    src2_data[41] <= result_alu2;
	    src2_datval[41] <= 1;
	 end
	 if (src_track[42] && src2_valid[42] && (~src2_datval[42]) && (src2_rrftag_val[42]) && (src2_rrftag[42] == buf_rrftag_alu2)) begin
	    src2_data[42] <= result_alu2;
	    src2_datval[42] <= 1;
	 end
	 if (src_track[43] && src2_valid[43] && (~src2_datval[43]) && (src2_rrftag_val[43]) && (src2_rrftag[43] == buf_rrftag_alu2)) begin
	    src2_data[43] <= result_alu2;
	    src2_datval[43] <= 1;
	 end
	 if (src_track[44] && src2_valid[44] && (~src2_datval[44]) && (src2_rrftag_val[44]) && (src2_rrftag[44] == buf_rrftag_alu2)) begin
	    src2_data[44] <= result_alu2;
	    src2_datval[44] <= 1;
	 end
	 if (src_track[45] && src2_valid[45] && (~src2_datval[45]) && (src2_rrftag_val[45]) && (src2_rrftag[45] == buf_rrftag_alu2)) begin
	    src2_data[45] <= result_alu2;
	    src2_datval[45] <= 1;
	 end
	 if (src_track[46] && src2_valid[46] && (~src2_datval[46]) && (src2_rrftag_val[46]) && (src2_rrftag[46] == buf_rrftag_alu2)) begin
	    src2_data[46] <= result_alu2;
	    src2_datval[46] <= 1;
	 end
	 if (src_track[47] && src2_valid[47] && (~src2_datval[47]) && (src2_rrftag_val[47]) && (src2_rrftag[47] == buf_rrftag_alu2)) begin
	    src2_data[47] <= result_alu2;
	    src2_datval[47] <= 1;
	 end
	 if (src_track[48] && src2_valid[48] && (~src2_datval[48]) && (src2_rrftag_val[48]) && (src2_rrftag[48] == buf_rrftag_alu2)) begin
	    src2_data[48] <= result_alu2;
	    src2_datval[48] <= 1;
	 end
	 if (src_track[49] && src2_valid[49] && (~src2_datval[49]) && (src2_rrftag_val[49]) && (src2_rrftag[49] == buf_rrftag_alu2)) begin
	    src2_data[49] <= result_alu2;
	    src2_datval[49] <= 1;
	 end
	 if (src_track[50] && src2_valid[50] && (~src2_datval[50]) && (src2_rrftag_val[50]) && (src2_rrftag[50] == buf_rrftag_alu2)) begin
	    src2_data[50] <= result_alu2;
	    src2_datval[50] <= 1;
	 end
	 if (src_track[51] && src2_valid[51] && (~src2_datval[51]) && (src2_rrftag_val[51]) && (src2_rrftag[51] == buf_rrftag_alu2)) begin
	    src2_data[51] <= result_alu2;
	    src2_datval[51] <= 1;
	 end
	 if (src_track[52] && src2_valid[52] && (~src2_datval[52]) && (src2_rrftag_val[52]) && (src2_rrftag[52] == buf_rrftag_alu2)) begin
	    src2_data[52] <= result_alu2;
	    src2_datval[52] <= 1;
	 end
	 if (src_track[53] && src2_valid[53] && (~src2_datval[53]) && (src2_rrftag_val[53]) && (src2_rrftag[53] == buf_rrftag_alu2)) begin
	    src2_data[53] <= result_alu2;
	    src2_datval[53] <= 1;
	 end
	 if (src_track[54] && src2_valid[54] && (~src2_datval[54]) && (src2_rrftag_val[54]) && (src2_rrftag[54] == buf_rrftag_alu2)) begin
	    src2_data[54] <= result_alu2;
	    src2_datval[54] <= 1;
	 end
	 if (src_track[55] && src2_valid[55] && (~src2_datval[55]) && (src2_rrftag_val[55]) && (src2_rrftag[55] == buf_rrftag_alu2)) begin
	    src2_data[55] <= result_alu2;
	    src2_datval[55] <= 1;
	 end
	 if (src_track[56] && src2_valid[56] && (~src2_datval[56]) && (src2_rrftag_val[56]) && (src2_rrftag[56] == buf_rrftag_alu2)) begin
	    src2_data[56] <= result_alu2;
	    src2_datval[56] <= 1;
	 end
	 if (src_track[57] && src2_valid[57] && (~src2_datval[57]) && (src2_rrftag_val[57]) && (src2_rrftag[57] == buf_rrftag_alu2)) begin
	    src2_data[57] <= result_alu2;
	    src2_datval[57] <= 1;
	 end
	 if (src_track[58] && src2_valid[58] && (~src2_datval[58]) && (src2_rrftag_val[58]) && (src2_rrftag[58] == buf_rrftag_alu2)) begin
	    src2_data[58] <= result_alu2;
	    src2_datval[58] <= 1;
	 end
	 if (src_track[59] && src2_valid[59] && (~src2_datval[59]) && (src2_rrftag_val[59]) && (src2_rrftag[59] == buf_rrftag_alu2)) begin
	    src2_data[59] <= result_alu2;
	    src2_datval[59] <= 1;
	 end
	 if (src_track[60] && src2_valid[60] && (~src2_datval[60]) && (src2_rrftag_val[60]) && (src2_rrftag[60] == buf_rrftag_alu2)) begin
	    src2_data[60] <= result_alu2;
	    src2_datval[60] <= 1;
	 end
	 if (src_track[61] && src2_valid[61] && (~src2_datval[61]) && (src2_rrftag_val[61]) && (src2_rrftag[61] == buf_rrftag_alu2)) begin
	    src2_data[61] <= result_alu2;
	    src2_datval[61] <= 1;
	 end
	 if (src_track[62] && src2_valid[62] && (~src2_datval[62]) && (src2_rrftag_val[62]) && (src2_rrftag[62] == buf_rrftag_alu2)) begin
	    src2_data[62] <= result_alu2;
	    src2_datval[62] <= 1;
	 end
	 if (src_track[63] && src2_valid[63] && (~src2_datval[63]) && (src2_rrftag_val[63]) && (src2_rrftag[63] == buf_rrftag_alu2)) begin
	    src2_data[63] <= result_alu2;
	    src2_datval[63] <= 1;
	 end
      end // if (robwe_alu2)
      

      if (robwe_mul) begin
	 if (src_track[0] && src1_valid[0] && (~src1_datval[0]) && (src1_rrftag_val[0]) && (src1_rrftag[0] == buf_rrftag_mul)) begin
	    src1_data[0] <= result_mul;
	    src1_datval[0] <= 1;
	 end
	 if (src_track[1] && src1_valid[1] && (~src1_datval[1]) && (src1_rrftag_val[1]) && (src1_rrftag[1] == buf_rrftag_mul)) begin
	    src1_data[1] <= result_mul;
	    src1_datval[1] <= 1;
	 end
	 if (src_track[2] && src1_valid[2] && (~src1_datval[2]) && (src1_rrftag_val[2]) && (src1_rrftag[2] == buf_rrftag_mul)) begin
	    src1_data[2] <= result_mul;
	    src1_datval[2] <= 1;
	 end
	 if (src_track[3] && src1_valid[3] && (~src1_datval[3]) && (src1_rrftag_val[3]) && (src1_rrftag[3] == buf_rrftag_mul)) begin
	    src1_data[3] <= result_mul;
	    src1_datval[3] <= 1;
	 end
	 if (src_track[4] && src1_valid[4] && (~src1_datval[4]) && (src1_rrftag_val[4]) && (src1_rrftag[4] == buf_rrftag_mul)) begin
	    src1_data[4] <= result_mul;
	    src1_datval[4] <= 1;
	 end
	 if (src_track[5] && src1_valid[5] && (~src1_datval[5]) && (src1_rrftag_val[5]) && (src1_rrftag[5] == buf_rrftag_mul)) begin
	    src1_data[5] <= result_mul;
	    src1_datval[5] <= 1;
	 end
	 if (src_track[6] && src1_valid[6] && (~src1_datval[6]) && (src1_rrftag_val[6]) && (src1_rrftag[6] == buf_rrftag_mul)) begin
	    src1_data[6] <= result_mul;
	    src1_datval[6] <= 1;
	 end
	 if (src_track[7] && src1_valid[7] && (~src1_datval[7]) && (src1_rrftag_val[7]) && (src1_rrftag[7] == buf_rrftag_mul)) begin
	    src1_data[7] <= result_mul;
	    src1_datval[7] <= 1;
	 end
	 if (src_track[8] && src1_valid[8] && (~src1_datval[8]) && (src1_rrftag_val[8]) && (src1_rrftag[8] == buf_rrftag_mul)) begin
	    src1_data[8] <= result_mul;
	    src1_datval[8] <= 1;
	 end
	 if (src_track[9] && src1_valid[9] && (~src1_datval[9]) && (src1_rrftag_val[9]) && (src1_rrftag[9] == buf_rrftag_mul)) begin
	    src1_data[9] <= result_mul;
	    src1_datval[9] <= 1;
	 end
	 if (src_track[10] && src1_valid[10] && (~src1_datval[10]) && (src1_rrftag_val[10]) && (src1_rrftag[10] == buf_rrftag_mul)) begin
	    src1_data[10] <= result_mul;
	    src1_datval[10] <= 1;
	 end
	 if (src_track[11] && src1_valid[11] && (~src1_datval[11]) && (src1_rrftag_val[11]) && (src1_rrftag[11] == buf_rrftag_mul)) begin
	    src1_data[11] <= result_mul;
	    src1_datval[11] <= 1;
	 end
	 if (src_track[12] && src1_valid[12] && (~src1_datval[12]) && (src1_rrftag_val[12]) && (src1_rrftag[12] == buf_rrftag_mul)) begin
	    src1_data[12] <= result_mul;
	    src1_datval[12] <= 1;
	 end
	 if (src_track[13] && src1_valid[13] && (~src1_datval[13]) && (src1_rrftag_val[13]) && (src1_rrftag[13] == buf_rrftag_mul)) begin
	    src1_data[13] <= result_mul;
	    src1_datval[13] <= 1;
	 end
	 if (src_track[14] && src1_valid[14] && (~src1_datval[14]) && (src1_rrftag_val[14]) && (src1_rrftag[14] == buf_rrftag_mul)) begin
	    src1_data[14] <= result_mul;
	    src1_datval[14] <= 1;
	 end
	 if (src_track[15] && src1_valid[15] && (~src1_datval[15]) && (src1_rrftag_val[15]) && (src1_rrftag[15] == buf_rrftag_mul)) begin
	    src1_data[15] <= result_mul;
	    src1_datval[15] <= 1;
	 end
	 if (src_track[16] && src1_valid[16] && (~src1_datval[16]) && (src1_rrftag_val[16]) && (src1_rrftag[16] == buf_rrftag_mul)) begin
	    src1_data[16] <= result_mul;
	    src1_datval[16] <= 1;
	 end
	 if (src_track[17] && src1_valid[17] && (~src1_datval[17]) && (src1_rrftag_val[17]) && (src1_rrftag[17] == buf_rrftag_mul)) begin
	    src1_data[17] <= result_mul;
	    src1_datval[17] <= 1;
	 end
	 if (src_track[18] && src1_valid[18] && (~src1_datval[18]) && (src1_rrftag_val[18]) && (src1_rrftag[18] == buf_rrftag_mul)) begin
	    src1_data[18] <= result_mul;
	    src1_datval[18] <= 1;
	 end
	 if (src_track[19] && src1_valid[19] && (~src1_datval[19]) && (src1_rrftag_val[19]) && (src1_rrftag[19] == buf_rrftag_mul)) begin
	    src1_data[19] <= result_mul;
	    src1_datval[19] <= 1;
	 end
	 if (src_track[20] && src1_valid[20] && (~src1_datval[20]) && (src1_rrftag_val[20]) && (src1_rrftag[20] == buf_rrftag_mul)) begin
	    src1_data[20] <= result_mul;
	    src1_datval[20] <= 1;
	 end
	 if (src_track[21] && src1_valid[21] && (~src1_datval[21]) && (src1_rrftag_val[21]) && (src1_rrftag[21] == buf_rrftag_mul)) begin
	    src1_data[21] <= result_mul;
	    src1_datval[21] <= 1;
	 end
	 if (src_track[22] && src1_valid[22] && (~src1_datval[22]) && (src1_rrftag_val[22]) && (src1_rrftag[22] == buf_rrftag_mul)) begin
	    src1_data[22] <= result_mul;
	    src1_datval[22] <= 1;
	 end
	 if (src_track[23] && src1_valid[23] && (~src1_datval[23]) && (src1_rrftag_val[23]) && (src1_rrftag[23] == buf_rrftag_mul)) begin
	    src1_data[23] <= result_mul;
	    src1_datval[23] <= 1;
	 end
	 if (src_track[24] && src1_valid[24] && (~src1_datval[24]) && (src1_rrftag_val[24]) && (src1_rrftag[24] == buf_rrftag_mul)) begin
	    src1_data[24] <= result_mul;
	    src1_datval[24] <= 1;
	 end
	 if (src_track[25] && src1_valid[25] && (~src1_datval[25]) && (src1_rrftag_val[25]) && (src1_rrftag[25] == buf_rrftag_mul)) begin
	    src1_data[25] <= result_mul;
	    src1_datval[25] <= 1;
	 end
	 if (src_track[26] && src1_valid[26] && (~src1_datval[26]) && (src1_rrftag_val[26]) && (src1_rrftag[26] == buf_rrftag_mul)) begin
	    src1_data[26] <= result_mul;
	    src1_datval[26] <= 1;
	 end
	 if (src_track[27] && src1_valid[27] && (~src1_datval[27]) && (src1_rrftag_val[27]) && (src1_rrftag[27] == buf_rrftag_mul)) begin
	    src1_data[27] <= result_mul;
	    src1_datval[27] <= 1;
	 end
	 if (src_track[28] && src1_valid[28] && (~src1_datval[28]) && (src1_rrftag_val[28]) && (src1_rrftag[28] == buf_rrftag_mul)) begin
	    src1_data[28] <= result_mul;
	    src1_datval[28] <= 1;
	 end
	 if (src_track[29] && src1_valid[29] && (~src1_datval[29]) && (src1_rrftag_val[29]) && (src1_rrftag[29] == buf_rrftag_mul)) begin
	    src1_data[29] <= result_mul;
	    src1_datval[29] <= 1;
	 end
	 if (src_track[30] && src1_valid[30] && (~src1_datval[30]) && (src1_rrftag_val[30]) && (src1_rrftag[30] == buf_rrftag_mul)) begin
	    src1_data[30] <= result_mul;
	    src1_datval[30] <= 1;
	 end
	 if (src_track[31] && src1_valid[31] && (~src1_datval[31]) && (src1_rrftag_val[31]) && (src1_rrftag[31] == buf_rrftag_mul)) begin
	    src1_data[31] <= result_mul;
	    src1_datval[31] <= 1;
	 end
	 if (src_track[32] && src1_valid[32] && (~src1_datval[32]) && (src1_rrftag_val[32]) && (src1_rrftag[32] == buf_rrftag_mul)) begin
	    src1_data[32] <= result_mul;
	    src1_datval[32] <= 1;
	 end
	 if (src_track[33] && src1_valid[33] && (~src1_datval[33]) && (src1_rrftag_val[33]) && (src1_rrftag[33] == buf_rrftag_mul)) begin
	    src1_data[33] <= result_mul;
	    src1_datval[33] <= 1;
	 end
	 if (src_track[34] && src1_valid[34] && (~src1_datval[34]) && (src1_rrftag_val[34]) && (src1_rrftag[34] == buf_rrftag_mul)) begin
	    src1_data[34] <= result_mul;
	    src1_datval[34] <= 1;
	 end
	 if (src_track[35] && src1_valid[35] && (~src1_datval[35]) && (src1_rrftag_val[35]) && (src1_rrftag[35] == buf_rrftag_mul)) begin
	    src1_data[35] <= result_mul;
	    src1_datval[35] <= 1;
	 end
	 if (src_track[36] && src1_valid[36] && (~src1_datval[36]) && (src1_rrftag_val[36]) && (src1_rrftag[36] == buf_rrftag_mul)) begin
	    src1_data[36] <= result_mul;
	    src1_datval[36] <= 1;
	 end
	 if (src_track[37] && src1_valid[37] && (~src1_datval[37]) && (src1_rrftag_val[37]) && (src1_rrftag[37] == buf_rrftag_mul)) begin
	    src1_data[37] <= result_mul;
	    src1_datval[37] <= 1;
	 end
	 if (src_track[38] && src1_valid[38] && (~src1_datval[38]) && (src1_rrftag_val[38]) && (src1_rrftag[38] == buf_rrftag_mul)) begin
	    src1_data[38] <= result_mul;
	    src1_datval[38] <= 1;
	 end
	 if (src_track[39] && src1_valid[39] && (~src1_datval[39]) && (src1_rrftag_val[39]) && (src1_rrftag[39] == buf_rrftag_mul)) begin
	    src1_data[39] <= result_mul;
	    src1_datval[39] <= 1;
	 end
	 if (src_track[40] && src1_valid[40] && (~src1_datval[40]) && (src1_rrftag_val[40]) && (src1_rrftag[40] == buf_rrftag_mul)) begin
	    src1_data[40] <= result_mul;
	    src1_datval[40] <= 1;
	 end
	 if (src_track[41] && src1_valid[41] && (~src1_datval[41]) && (src1_rrftag_val[41]) && (src1_rrftag[41] == buf_rrftag_mul)) begin
	    src1_data[41] <= result_mul;
	    src1_datval[41] <= 1;
	 end
	 if (src_track[42] && src1_valid[42] && (~src1_datval[42]) && (src1_rrftag_val[42]) && (src1_rrftag[42] == buf_rrftag_mul)) begin
	    src1_data[42] <= result_mul;
	    src1_datval[42] <= 1;
	 end
	 if (src_track[43] && src1_valid[43] && (~src1_datval[43]) && (src1_rrftag_val[43]) && (src1_rrftag[43] == buf_rrftag_mul)) begin
	    src1_data[43] <= result_mul;
	    src1_datval[43] <= 1;
	 end
	 if (src_track[44] && src1_valid[44] && (~src1_datval[44]) && (src1_rrftag_val[44]) && (src1_rrftag[44] == buf_rrftag_mul)) begin
	    src1_data[44] <= result_mul;
	    src1_datval[44] <= 1;
	 end
	 if (src_track[45] && src1_valid[45] && (~src1_datval[45]) && (src1_rrftag_val[45]) && (src1_rrftag[45] == buf_rrftag_mul)) begin
	    src1_data[45] <= result_mul;
	    src1_datval[45] <= 1;
	 end
	 if (src_track[46] && src1_valid[46] && (~src1_datval[46]) && (src1_rrftag_val[46]) && (src1_rrftag[46] == buf_rrftag_mul)) begin
	    src1_data[46] <= result_mul;
	    src1_datval[46] <= 1;
	 end
	 if (src_track[47] && src1_valid[47] && (~src1_datval[47]) && (src1_rrftag_val[47]) && (src1_rrftag[47] == buf_rrftag_mul)) begin
	    src1_data[47] <= result_mul;
	    src1_datval[47] <= 1;
	 end
	 if (src_track[48] && src1_valid[48] && (~src1_datval[48]) && (src1_rrftag_val[48]) && (src1_rrftag[48] == buf_rrftag_mul)) begin
	    src1_data[48] <= result_mul;
	    src1_datval[48] <= 1;
	 end
	 if (src_track[49] && src1_valid[49] && (~src1_datval[49]) && (src1_rrftag_val[49]) && (src1_rrftag[49] == buf_rrftag_mul)) begin
	    src1_data[49] <= result_mul;
	    src1_datval[49] <= 1;
	 end
	 if (src_track[50] && src1_valid[50] && (~src1_datval[50]) && (src1_rrftag_val[50]) && (src1_rrftag[50] == buf_rrftag_mul)) begin
	    src1_data[50] <= result_mul;
	    src1_datval[50] <= 1;
	 end
	 if (src_track[51] && src1_valid[51] && (~src1_datval[51]) && (src1_rrftag_val[51]) && (src1_rrftag[51] == buf_rrftag_mul)) begin
	    src1_data[51] <= result_mul;
	    src1_datval[51] <= 1;
	 end
	 if (src_track[52] && src1_valid[52] && (~src1_datval[52]) && (src1_rrftag_val[52]) && (src1_rrftag[52] == buf_rrftag_mul)) begin
	    src1_data[52] <= result_mul;
	    src1_datval[52] <= 1;
	 end
	 if (src_track[53] && src1_valid[53] && (~src1_datval[53]) && (src1_rrftag_val[53]) && (src1_rrftag[53] == buf_rrftag_mul)) begin
	    src1_data[53] <= result_mul;
	    src1_datval[53] <= 1;
	 end
	 if (src_track[54] && src1_valid[54] && (~src1_datval[54]) && (src1_rrftag_val[54]) && (src1_rrftag[54] == buf_rrftag_mul)) begin
	    src1_data[54] <= result_mul;
	    src1_datval[54] <= 1;
	 end
	 if (src_track[55] && src1_valid[55] && (~src1_datval[55]) && (src1_rrftag_val[55]) && (src1_rrftag[55] == buf_rrftag_mul)) begin
	    src1_data[55] <= result_mul;
	    src1_datval[55] <= 1;
	 end
	 if (src_track[56] && src1_valid[56] && (~src1_datval[56]) && (src1_rrftag_val[56]) && (src1_rrftag[56] == buf_rrftag_mul)) begin
	    src1_data[56] <= result_mul;
	    src1_datval[56] <= 1;
	 end
	 if (src_track[57] && src1_valid[57] && (~src1_datval[57]) && (src1_rrftag_val[57]) && (src1_rrftag[57] == buf_rrftag_mul)) begin
	    src1_data[57] <= result_mul;
	    src1_datval[57] <= 1;
	 end
	 if (src_track[58] && src1_valid[58] && (~src1_datval[58]) && (src1_rrftag_val[58]) && (src1_rrftag[58] == buf_rrftag_mul)) begin
	    src1_data[58] <= result_mul;
	    src1_datval[58] <= 1;
	 end
	 if (src_track[59] && src1_valid[59] && (~src1_datval[59]) && (src1_rrftag_val[59]) && (src1_rrftag[59] == buf_rrftag_mul)) begin
	    src1_data[59] <= result_mul;
	    src1_datval[59] <= 1;
	 end
	 if (src_track[60] && src1_valid[60] && (~src1_datval[60]) && (src1_rrftag_val[60]) && (src1_rrftag[60] == buf_rrftag_mul)) begin
	    src1_data[60] <= result_mul;
	    src1_datval[60] <= 1;
	 end
	 if (src_track[61] && src1_valid[61] && (~src1_datval[61]) && (src1_rrftag_val[61]) && (src1_rrftag[61] == buf_rrftag_mul)) begin
	    src1_data[61] <= result_mul;
	    src1_datval[61] <= 1;
	 end
	 if (src_track[62] && src1_valid[62] && (~src1_datval[62]) && (src1_rrftag_val[62]) && (src1_rrftag[62] == buf_rrftag_mul)) begin
	    src1_data[62] <= result_mul;
	    src1_datval[62] <= 1;
	 end
	 if (src_track[63] && src1_valid[63] && (~src1_datval[63]) && (src1_rrftag_val[63]) && (src1_rrftag[63] == buf_rrftag_mul)) begin
	    src1_data[63] <= result_mul;
	    src1_datval[63] <= 1;
	 end

	 if (src_track[0] && src2_valid[0] && (~src2_datval[0]) && (src2_rrftag_val[0]) && (src2_rrftag[0] == buf_rrftag_mul)) begin
	    src2_data[0] <= result_mul;
	    src2_datval[0] <= 1;
	 end
	 if (src_track[1] && src2_valid[1] && (~src2_datval[1]) && (src2_rrftag_val[1]) && (src2_rrftag[1] == buf_rrftag_mul)) begin
	    src2_data[1] <= result_mul;
	    src2_datval[1] <= 1;
	 end
	 if (src_track[2] && src2_valid[2] && (~src2_datval[2]) && (src2_rrftag_val[2]) && (src2_rrftag[2] == buf_rrftag_mul)) begin
	    src2_data[2] <= result_mul;
	    src2_datval[2] <= 1;
	 end
	 if (src_track[3] && src2_valid[3] && (~src2_datval[3]) && (src2_rrftag_val[3]) && (src2_rrftag[3] == buf_rrftag_mul)) begin
	    src2_data[3] <= result_mul;
	    src2_datval[3] <= 1;
	 end
	 if (src_track[4] && src2_valid[4] && (~src2_datval[4]) && (src2_rrftag_val[4]) && (src2_rrftag[4] == buf_rrftag_mul)) begin
	    src2_data[4] <= result_mul;
	    src2_datval[4] <= 1;
	 end
	 if (src_track[5] && src2_valid[5] && (~src2_datval[5]) && (src2_rrftag_val[5]) && (src2_rrftag[5] == buf_rrftag_mul)) begin
	    src2_data[5] <= result_mul;
	    src2_datval[5] <= 1;
	 end
	 if (src_track[6] && src2_valid[6] && (~src2_datval[6]) && (src2_rrftag_val[6]) && (src2_rrftag[6] == buf_rrftag_mul)) begin
	    src2_data[6] <= result_mul;
	    src2_datval[6] <= 1;
	 end
	 if (src_track[7] && src2_valid[7] && (~src2_datval[7]) && (src2_rrftag_val[7]) && (src2_rrftag[7] == buf_rrftag_mul)) begin
	    src2_data[7] <= result_mul;
	    src2_datval[7] <= 1;
	 end
	 if (src_track[8] && src2_valid[8] && (~src2_datval[8]) && (src2_rrftag_val[8]) && (src2_rrftag[8] == buf_rrftag_mul)) begin
	    src2_data[8] <= result_mul;
	    src2_datval[8] <= 1;
	 end
	 if (src_track[9] && src2_valid[9] && (~src2_datval[9]) && (src2_rrftag_val[9]) && (src2_rrftag[9] == buf_rrftag_mul)) begin
	    src2_data[9] <= result_mul;
	    src2_datval[9] <= 1;
	 end
	 if (src_track[10] && src2_valid[10] && (~src2_datval[10]) && (src2_rrftag_val[10]) && (src2_rrftag[10] == buf_rrftag_mul)) begin
	    src2_data[10] <= result_mul;
	    src2_datval[10] <= 1;
	 end
	 if (src_track[11] && src2_valid[11] && (~src2_datval[11]) && (src2_rrftag_val[11]) && (src2_rrftag[11] == buf_rrftag_mul)) begin
	    src2_data[11] <= result_mul;
	    src2_datval[11] <= 1;
	 end
	 if (src_track[12] && src2_valid[12] && (~src2_datval[12]) && (src2_rrftag_val[12]) && (src2_rrftag[12] == buf_rrftag_mul)) begin
	    src2_data[12] <= result_mul;
	    src2_datval[12] <= 1;
	 end
	 if (src_track[13] && src2_valid[13] && (~src2_datval[13]) && (src2_rrftag_val[13]) && (src2_rrftag[13] == buf_rrftag_mul)) begin
	    src2_data[13] <= result_mul;
	    src2_datval[13] <= 1;
	 end
	 if (src_track[14] && src2_valid[14] && (~src2_datval[14]) && (src2_rrftag_val[14]) && (src2_rrftag[14] == buf_rrftag_mul)) begin
	    src2_data[14] <= result_mul;
	    src2_datval[14] <= 1;
	 end
	 if (src_track[15] && src2_valid[15] && (~src2_datval[15]) && (src2_rrftag_val[15]) && (src2_rrftag[15] == buf_rrftag_mul)) begin
	    src2_data[15] <= result_mul;
	    src2_datval[15] <= 1;
	 end
	 if (src_track[16] && src2_valid[16] && (~src2_datval[16]) && (src2_rrftag_val[16]) && (src2_rrftag[16] == buf_rrftag_mul)) begin
	    src2_data[16] <= result_mul;
	    src2_datval[16] <= 1;
	 end
	 if (src_track[17] && src2_valid[17] && (~src2_datval[17]) && (src2_rrftag_val[17]) && (src2_rrftag[17] == buf_rrftag_mul)) begin
	    src2_data[17] <= result_mul;
	    src2_datval[17] <= 1;
	 end
	 if (src_track[18] && src2_valid[18] && (~src2_datval[18]) && (src2_rrftag_val[18]) && (src2_rrftag[18] == buf_rrftag_mul)) begin
	    src2_data[18] <= result_mul;
	    src2_datval[18] <= 1;
	 end
	 if (src_track[19] && src2_valid[19] && (~src2_datval[19]) && (src2_rrftag_val[19]) && (src2_rrftag[19] == buf_rrftag_mul)) begin
	    src2_data[19] <= result_mul;
	    src2_datval[19] <= 1;
	 end
	 if (src_track[20] && src2_valid[20] && (~src2_datval[20]) && (src2_rrftag_val[20]) && (src2_rrftag[20] == buf_rrftag_mul)) begin
	    src2_data[20] <= result_mul;
	    src2_datval[20] <= 1;
	 end
	 if (src_track[21] && src2_valid[21] && (~src2_datval[21]) && (src2_rrftag_val[21]) && (src2_rrftag[21] == buf_rrftag_mul)) begin
	    src2_data[21] <= result_mul;
	    src2_datval[21] <= 1;
	 end
	 if (src_track[22] && src2_valid[22] && (~src2_datval[22]) && (src2_rrftag_val[22]) && (src2_rrftag[22] == buf_rrftag_mul)) begin
	    src2_data[22] <= result_mul;
	    src2_datval[22] <= 1;
	 end
	 if (src_track[23] && src2_valid[23] && (~src2_datval[23]) && (src2_rrftag_val[23]) && (src2_rrftag[23] == buf_rrftag_mul)) begin
	    src2_data[23] <= result_mul;
	    src2_datval[23] <= 1;
	 end
	 if (src_track[24] && src2_valid[24] && (~src2_datval[24]) && (src2_rrftag_val[24]) && (src2_rrftag[24] == buf_rrftag_mul)) begin
	    src2_data[24] <= result_mul;
	    src2_datval[24] <= 1;
	 end
	 if (src_track[25] && src2_valid[25] && (~src2_datval[25]) && (src2_rrftag_val[25]) && (src2_rrftag[25] == buf_rrftag_mul)) begin
	    src2_data[25] <= result_mul;
	    src2_datval[25] <= 1;
	 end
	 if (src_track[26] && src2_valid[26] && (~src2_datval[26]) && (src2_rrftag_val[26]) && (src2_rrftag[26] == buf_rrftag_mul)) begin
	    src2_data[26] <= result_mul;
	    src2_datval[26] <= 1;
	 end
	 if (src_track[27] && src2_valid[27] && (~src2_datval[27]) && (src2_rrftag_val[27]) && (src2_rrftag[27] == buf_rrftag_mul)) begin
	    src2_data[27] <= result_mul;
	    src2_datval[27] <= 1;
	 end
	 if (src_track[28] && src2_valid[28] && (~src2_datval[28]) && (src2_rrftag_val[28]) && (src2_rrftag[28] == buf_rrftag_mul)) begin
	    src2_data[28] <= result_mul;
	    src2_datval[28] <= 1;
	 end
	 if (src_track[29] && src2_valid[29] && (~src2_datval[29]) && (src2_rrftag_val[29]) && (src2_rrftag[29] == buf_rrftag_mul)) begin
	    src2_data[29] <= result_mul;
	    src2_datval[29] <= 1;
	 end
	 if (src_track[30] && src2_valid[30] && (~src2_datval[30]) && (src2_rrftag_val[30]) && (src2_rrftag[30] == buf_rrftag_mul)) begin
	    src2_data[30] <= result_mul;
	    src2_datval[30] <= 1;
	 end
	 if (src_track[31] && src2_valid[31] && (~src2_datval[31]) && (src2_rrftag_val[31]) && (src2_rrftag[31] == buf_rrftag_mul)) begin
	    src2_data[31] <= result_mul;
	    src2_datval[31] <= 1;
	 end
	 if (src_track[32] && src2_valid[32] && (~src2_datval[32]) && (src2_rrftag_val[32]) && (src2_rrftag[32] == buf_rrftag_mul)) begin
	    src2_data[32] <= result_mul;
	    src2_datval[32] <= 1;
	 end
	 if (src_track[33] && src2_valid[33] && (~src2_datval[33]) && (src2_rrftag_val[33]) && (src2_rrftag[33] == buf_rrftag_mul)) begin
	    src2_data[33] <= result_mul;
	    src2_datval[33] <= 1;
	 end
	 if (src_track[34] && src2_valid[34] && (~src2_datval[34]) && (src2_rrftag_val[34]) && (src2_rrftag[34] == buf_rrftag_mul)) begin
	    src2_data[34] <= result_mul;
	    src2_datval[34] <= 1;
	 end
	 if (src_track[35] && src2_valid[35] && (~src2_datval[35]) && (src2_rrftag_val[35]) && (src2_rrftag[35] == buf_rrftag_mul)) begin
	    src2_data[35] <= result_mul;
	    src2_datval[35] <= 1;
	 end
	 if (src_track[36] && src2_valid[36] && (~src2_datval[36]) && (src2_rrftag_val[36]) && (src2_rrftag[36] == buf_rrftag_mul)) begin
	    src2_data[36] <= result_mul;
	    src2_datval[36] <= 1;
	 end
	 if (src_track[37] && src2_valid[37] && (~src2_datval[37]) && (src2_rrftag_val[37]) && (src2_rrftag[37] == buf_rrftag_mul)) begin
	    src2_data[37] <= result_mul;
	    src2_datval[37] <= 1;
	 end
	 if (src_track[38] && src2_valid[38] && (~src2_datval[38]) && (src2_rrftag_val[38]) && (src2_rrftag[38] == buf_rrftag_mul)) begin
	    src2_data[38] <= result_mul;
	    src2_datval[38] <= 1;
	 end
	 if (src_track[39] && src2_valid[39] && (~src2_datval[39]) && (src2_rrftag_val[39]) && (src2_rrftag[39] == buf_rrftag_mul)) begin
	    src2_data[39] <= result_mul;
	    src2_datval[39] <= 1;
	 end
	 if (src_track[40] && src2_valid[40] && (~src2_datval[40]) && (src2_rrftag_val[40]) && (src2_rrftag[40] == buf_rrftag_mul)) begin
	    src2_data[40] <= result_mul;
	    src2_datval[40] <= 1;
	 end
	 if (src_track[41] && src2_valid[41] && (~src2_datval[41]) && (src2_rrftag_val[41]) && (src2_rrftag[41] == buf_rrftag_mul)) begin
	    src2_data[41] <= result_mul;
	    src2_datval[41] <= 1;
	 end
	 if (src_track[42] && src2_valid[42] && (~src2_datval[42]) && (src2_rrftag_val[42]) && (src2_rrftag[42] == buf_rrftag_mul)) begin
	    src2_data[42] <= result_mul;
	    src2_datval[42] <= 1;
	 end
	 if (src_track[43] && src2_valid[43] && (~src2_datval[43]) && (src2_rrftag_val[43]) && (src2_rrftag[43] == buf_rrftag_mul)) begin
	    src2_data[43] <= result_mul;
	    src2_datval[43] <= 1;
	 end
	 if (src_track[44] && src2_valid[44] && (~src2_datval[44]) && (src2_rrftag_val[44]) && (src2_rrftag[44] == buf_rrftag_mul)) begin
	    src2_data[44] <= result_mul;
	    src2_datval[44] <= 1;
	 end
	 if (src_track[45] && src2_valid[45] && (~src2_datval[45]) && (src2_rrftag_val[45]) && (src2_rrftag[45] == buf_rrftag_mul)) begin
	    src2_data[45] <= result_mul;
	    src2_datval[45] <= 1;
	 end
	 if (src_track[46] && src2_valid[46] && (~src2_datval[46]) && (src2_rrftag_val[46]) && (src2_rrftag[46] == buf_rrftag_mul)) begin
	    src2_data[46] <= result_mul;
	    src2_datval[46] <= 1;
	 end
	 if (src_track[47] && src2_valid[47] && (~src2_datval[47]) && (src2_rrftag_val[47]) && (src2_rrftag[47] == buf_rrftag_mul)) begin
	    src2_data[47] <= result_mul;
	    src2_datval[47] <= 1;
	 end
	 if (src_track[48] && src2_valid[48] && (~src2_datval[48]) && (src2_rrftag_val[48]) && (src2_rrftag[48] == buf_rrftag_mul)) begin
	    src2_data[48] <= result_mul;
	    src2_datval[48] <= 1;
	 end
	 if (src_track[49] && src2_valid[49] && (~src2_datval[49]) && (src2_rrftag_val[49]) && (src2_rrftag[49] == buf_rrftag_mul)) begin
	    src2_data[49] <= result_mul;
	    src2_datval[49] <= 1;
	 end
	 if (src_track[50] && src2_valid[50] && (~src2_datval[50]) && (src2_rrftag_val[50]) && (src2_rrftag[50] == buf_rrftag_mul)) begin
	    src2_data[50] <= result_mul;
	    src2_datval[50] <= 1;
	 end
	 if (src_track[51] && src2_valid[51] && (~src2_datval[51]) && (src2_rrftag_val[51]) && (src2_rrftag[51] == buf_rrftag_mul)) begin
	    src2_data[51] <= result_mul;
	    src2_datval[51] <= 1;
	 end
	 if (src_track[52] && src2_valid[52] && (~src2_datval[52]) && (src2_rrftag_val[52]) && (src2_rrftag[52] == buf_rrftag_mul)) begin
	    src2_data[52] <= result_mul;
	    src2_datval[52] <= 1;
	 end
	 if (src_track[53] && src2_valid[53] && (~src2_datval[53]) && (src2_rrftag_val[53]) && (src2_rrftag[53] == buf_rrftag_mul)) begin
	    src2_data[53] <= result_mul;
	    src2_datval[53] <= 1;
	 end
	 if (src_track[54] && src2_valid[54] && (~src2_datval[54]) && (src2_rrftag_val[54]) && (src2_rrftag[54] == buf_rrftag_mul)) begin
	    src2_data[54] <= result_mul;
	    src2_datval[54] <= 1;
	 end
	 if (src_track[55] && src2_valid[55] && (~src2_datval[55]) && (src2_rrftag_val[55]) && (src2_rrftag[55] == buf_rrftag_mul)) begin
	    src2_data[55] <= result_mul;
	    src2_datval[55] <= 1;
	 end
	 if (src_track[56] && src2_valid[56] && (~src2_datval[56]) && (src2_rrftag_val[56]) && (src2_rrftag[56] == buf_rrftag_mul)) begin
	    src2_data[56] <= result_mul;
	    src2_datval[56] <= 1;
	 end
	 if (src_track[57] && src2_valid[57] && (~src2_datval[57]) && (src2_rrftag_val[57]) && (src2_rrftag[57] == buf_rrftag_mul)) begin
	    src2_data[57] <= result_mul;
	    src2_datval[57] <= 1;
	 end
	 if (src_track[58] && src2_valid[58] && (~src2_datval[58]) && (src2_rrftag_val[58]) && (src2_rrftag[58] == buf_rrftag_mul)) begin
	    src2_data[58] <= result_mul;
	    src2_datval[58] <= 1;
	 end
	 if (src_track[59] && src2_valid[59] && (~src2_datval[59]) && (src2_rrftag_val[59]) && (src2_rrftag[59] == buf_rrftag_mul)) begin
	    src2_data[59] <= result_mul;
	    src2_datval[59] <= 1;
	 end
	 if (src_track[60] && src2_valid[60] && (~src2_datval[60]) && (src2_rrftag_val[60]) && (src2_rrftag[60] == buf_rrftag_mul)) begin
	    src2_data[60] <= result_mul;
	    src2_datval[60] <= 1;
	 end
	 if (src_track[61] && src2_valid[61] && (~src2_datval[61]) && (src2_rrftag_val[61]) && (src2_rrftag[61] == buf_rrftag_mul)) begin
	    src2_data[61] <= result_mul;
	    src2_datval[61] <= 1;
	 end
	 if (src_track[62] && src2_valid[62] && (~src2_datval[62]) && (src2_rrftag_val[62]) && (src2_rrftag[62] == buf_rrftag_mul)) begin
	    src2_data[62] <= result_mul;
	    src2_datval[62] <= 1;
	 end
	 if (src_track[63] && src2_valid[63] && (~src2_datval[63]) && (src2_rrftag_val[63]) && (src2_rrftag[63] == buf_rrftag_mul)) begin
	    src2_data[63] <= result_mul;
	    src2_datval[63] <= 1;
	 end
      end // if (robwe_mul)
      
   end
       
   // shashank : end



   
// shashank edit
   // assign pc_combranch = (~prmiss & commit1 & isbranch[comptr]) ? 
   // 			 inst_pc[comptr] : inst_pc[comptr2];
   // assign bhr_combranch = (~prmiss & commit1 & isbranch[comptr]) ?
   // 			  bhr[comptr] : bhr[comptr2];
   // assign jmpaddr_combranch = (~prmiss & commit1 & isbranch[comptr]) ?
   // 			      jmpaddr[comptr] : jmpaddr[comptr2];
   assign pc_combranch = 32'b0;
   assign bhr_combranch = 10'b0;
   assign jmpaddr_combranch = 32'b0;

   
// shashank end
   always @ (posedge clk) begin
      if (reset) begin
	 comptr <= 0;
      end else if (~prmiss) begin
	 comptr <= comptr + commit1 + commit2;
      end
   end


   always @ (posedge clk) begin
      brcond <= 0;
//      storebit <= 0;
      isbranch <= 0;
   end
   
   always @ (posedge clk) begin
      if (reset) begin
	 finish <= 0;
	 // brcond <= 0;  // shashank symbolic change
	 // isbranch <= 0;
//	 storebit <= 0;
      end else begin
	 if (dp1)
	   finish[dp1_addr] <= 1'b0;
	 if (dp2)
	   finish[dp2_addr] <= 1'b0;
	 if (exfin_alu1)
	   finish[exfin_alu1_addr] <= 1'b1;
	 if (exfin_alu2)
	   finish[exfin_alu2_addr] <= 1'b1;
	 if (exfin_mul)
	   finish[exfin_mul_addr] <= 1'b1;
	 if (exfin_ldst)
	   finish[exfin_ldst_addr] <= 1'b1;
	 // if (exfin_branch) begin
	 //    finish[exfin_branch_addr] <= 1'b1;
	 //    brcond[exfin_branch_addr] <= exfin_branch_brcond;
//	    jmpaddr[exfin_branch_addr] <= exfin_branch_jmpaddr; // shashank edit
//	 end
      end
   end // always @ (posedge clk)

   // shashank edit
   // always @ (posedge clk) begin
   //    if (dp1) begin
   // 	 isbranch[dp1_addr] <= isbranch_dp1;
   // 	 storebit[dp1_addr] <= storebit_dp1;
   // 	 dstvalid[dp1_addr] <= dstvalid_dp1;
   // 	 dst[dp1_addr] <= dst_dp1;
   // 	 bhr[dp1_addr] <= bhr_dp1;
   // 	 inst_pc[dp1_addr] <= pc_dp1;
   //    end
   //    if (dp2) begin
   // 	 isbranch[dp2_addr] <= isbranch_dp2;
   // 	 storebit[dp2_addr] <= storebit_dp2;
   // 	 dstvalid[dp2_addr] <= dstvalid_dp2;
   // 	 dst[dp2_addr] <= dst_dp2;
   // 	 bhr[dp2_addr] <= bhr_dp2;
   // 	 inst_pc[dp2_addr] <= pc_dp2;
   //    end
   // end // always @ (posedge clk)

   always @ (posedge clk) begin
      if (dp1) begin
//	 isbranch[dp1_addr] <= isbranch_dp1;
	 storebit[dp1_addr] <= storebit_dp1;
	 dstvalid[dp1_addr] <= dstvalid_dp1;
	 dst[dp1_addr] <= dst_dp1;
//	 bhr[dp1_addr] <= bhr_dp1;
//	 inst_pc[dp1_addr] <= pc_dp1;
      end
      if (dp2) begin
//	 isbranch[dp2_addr] <= isbranch_dp2;
	 storebit[dp2_addr] <= storebit_dp2;
	 dstvalid[dp2_addr] <= dstvalid_dp2;
	 dst[dp2_addr] <= dst_dp2;
//	 bhr[dp2_addr] <= bhr_dp2;
//	 inst_pc[dp2_addr] <= pc_dp2;
      end
   end // always @ (posedge clk)

   // shashank end
endmodule // reorderbuf
`default_nettype wire
