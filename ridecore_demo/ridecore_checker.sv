
module ridecore_checker (/*AUTOARG*/
   // Inputs
   clk, rst, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
   reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17,
   reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26,
   reg27, reg28, reg29, reg30, reg31
   );


   input        clk;
   input        rst;
   input [31:0] reg0;
   input [31:0] reg1;
   input [31:0] reg2;
   input [31:0] reg3;
   input [31:0] reg4;
   input [31:0] reg5;
   input [31:0] reg6;
   input [31:0] reg7;
   input [31:0] reg8;
   input [31:0] reg9;
   input [31:0] reg10;
   input [31:0] reg11;
   input [31:0] reg12;
   input [31:0] reg13;
   input [31:0] reg14;
   input [31:0] reg15;
   input [31:0] reg16;
   input [31:0] reg17;
   input [31:0] reg18;
   input [31:0] reg19;
   input [31:0] reg20;
   input [31:0] reg21;
   input [31:0] reg22;
   input [31:0] reg23;
   input [31:0] reg24;
   input [31:0] reg25;
   input [31:0] reg26;
   input [31:0] reg27;
   input [31:0] reg28;
   input [31:0] reg29;
   input [31:0] reg30;
   input [31:0] reg31;
   
   genvar       i;
   genvar 	j;
   

   wire [31:0]  iregs[31:0];

   assign iregs[0] = reg0;
   assign iregs[1] = reg1;
   assign iregs[2] = reg2;
   assign iregs[3] = reg3;
   assign iregs[4] = reg4;
   assign iregs[5] = reg5;
   assign iregs[6] = reg6;
   assign iregs[7] = reg7;
   assign iregs[8] = reg8;
   assign iregs[9] = reg9;
   assign iregs[10] = reg10;
   assign iregs[11] = reg11;
   assign iregs[12] = reg12;
   assign iregs[13] = reg13;
   assign iregs[14] = reg14;
   assign iregs[15] = reg15;
   assign iregs[16] = reg16;
   assign iregs[17] = reg17;
   assign iregs[18] = reg18;
   assign iregs[19] = reg19;
   assign iregs[20] = reg20;
   assign iregs[21] = reg21;
   assign iregs[22] = reg22;
   assign iregs[23] = reg23;
   assign iregs[24] = reg24;
   assign iregs[25] = reg25;
   assign iregs[26] = reg26;
   assign iregs[27] = reg27;
   assign iregs[28] = reg28;
   assign iregs[29] = reg29;
   assign iregs[30] = reg30;
   assign iregs[31] = reg31;

   wire 	ena;
   assign ena = top.pipe.chk_en;
  
   wire [4:0]	num_orig;
   assign num_orig = top.pipe.num_orig_insts;

   wire [4:0]	num_dup;
   assign num_dup = top.pipe.num_dup_insts;

   wire 	wait_for_commit;
   wire 	wait_for_commit_reg;
   assign wait_for_commit = top.pipe.wait_till_commit;
   assign wait_for_commit_reg = top.pipe.rob.wait_till_commit_reg;

   // assume properties

   assume_reg0: assume property (
				 @(posedge clk)
				 (iregs[0] == 0) && (iregs[16] == 0)
				 );
   
   generate
       for (j = 1; j < 16; j++) begin
	  assume_consistent_pipeline1: assume property (
							@(posedge wait_for_commit_reg)
//						       (~wait_for_commit_reg) |->
							 ((iregs[j] == iregs[j+16]) // ##1 (iregs[j] == iregs[j+16]) //##1 (iregs[j] == iregs[j+16]) ##1 (iregs[j] == iregs[j+16])
						 )
						       );
	  end
   endgenerate


   generate
       for (j = 0; j < 32; j++) begin
	  assume_consistent_mem: assume property (
							@(posedge wait_for_commit_reg)
//						       (~wait_for_commit_reg) |->
							 ((top.datamemory.mem[j] == top.datamemory.mem[j+32]) // ##1 (iregs[j] == iregs[j+16]) //##1 (iregs[j] == iregs[j+16]) ##1 (iregs[j] == iregs[j+16])
						 )
						       );
	  end
   endgenerate
      
      wire [63:0] formal_commit = top.pipe.rob.formal_commit;
      wire 	  commit2 = top.pipe.rob.commit2;
      wire [5:0]  comptr2;
      assume_consis_mult_commit: assume property (
						  @(posedge clk)
						  (~wait_for_commit_reg) |->
						  ~(formal_commit[comptr2] && commit2)
						  );

	 
   wire eq;
   wire lt;
   wire gt;
   wire [6:0] freenum;
   assign eq = (top.pipe.comptr == top.pipe.rrfptr);
   assign lt = (top.pipe.comptr < top.pipe.rrfptr);
   assign gt = (top.pipe.comptr > top.pipe.rrfptr);
   assign freenum = top.pipe.freenum;
   
   property as_freenum;
      @(posedge clk) ((eq && ((freenum == 0)||(freenum == 64))) 
		      || (lt && (freenum == (64 - (top.pipe.rrfptr - top.pipe.comptr)))) 
		      || (gt && (freenum == (top.pipe.comptr - top.pipe.rrfptr))) );
   endproperty

   wire [5:0] comptr;

   wire [5:0] rrfptr;
   wire [5:0] rrftag_arr[0:25];
   wire [25:0] rrftag_val;
   wire [63:0] rob_finish;
   assign rob_finish = top.pipe.rob.finish;

   assign rrftag_arr[0] = top.pipe.reserv_alu1.rrftag_0;
   assign rrftag_arr[1] = top.pipe.reserv_alu1.rrftag_1;
   assign rrftag_arr[2] = top.pipe.reserv_alu1.rrftag_2;
   assign rrftag_arr[3] = top.pipe.reserv_alu1.rrftag_3;
   assign rrftag_arr[4] = top.pipe.reserv_alu1.rrftag_4;
   assign rrftag_arr[5] = top.pipe.reserv_alu1.rrftag_5;
   assign rrftag_arr[6] = top.pipe.reserv_alu1.rrftag_6;
   assign rrftag_arr[7] = top.pipe.reserv_alu1.rrftag_7;
   assign rrftag_arr[8] = top.pipe.buf_rrftag_alu1;
   assign rrftag_arr[9] = top.pipe.reserv_alu2.rrftag_0;
   assign rrftag_arr[10] = top.pipe.reserv_alu2.rrftag_1;
   assign rrftag_arr[11] = top.pipe.reserv_alu2.rrftag_2;
   assign rrftag_arr[12] = top.pipe.reserv_alu2.rrftag_3;
   assign rrftag_arr[13] = top.pipe.reserv_alu2.rrftag_4;
   assign rrftag_arr[14] = top.pipe.reserv_alu2.rrftag_5;
   assign rrftag_arr[15] = top.pipe.reserv_alu2.rrftag_6;
   assign rrftag_arr[16] = top.pipe.reserv_alu2.rrftag_7;
   assign rrftag_arr[17] = top.pipe.buf_rrftag_alu2;
   assign rrftag_arr[18] = top.pipe.reserv_mul.rrftag_0;
   assign rrftag_arr[19] = top.pipe.reserv_mul.rrftag_1;
   assign rrftag_arr[20] = top.pipe.buf_rrftag_mul;
   assign rrftag_arr[21] = top.pipe.reserv_ldst.rrftag_0;
   assign rrftag_arr[22] = top.pipe.reserv_ldst.rrftag_1;
   assign rrftag_arr[23] = top.pipe.reserv_ldst.rrftag_2;
   assign rrftag_arr[24] = top.pipe.reserv_ldst.rrftag_3;
   assign rrftag_arr[25] = top.pipe.buf_rrftag_ldst;

   assign rrftag_val[7:0] = top.pipe.reserv_alu1.busyvec;
   assign rrftag_val[8] =  top.pipe.byakko.busy;
   assign rrftag_val[16:9] = top.pipe.reserv_alu2.busyvec;
   assign rrftag_val[17] =  top.pipe.suzaku.busy;
   assign rrftag_val[19:18] = top.pipe.reserv_mul.busyvec;
   assign rrftag_val[20] =  top.pipe.genbu.busy;
   assign rrftag_val[24:21] = top.pipe.reserv_ldst.busyvec;
   assign rrftag_val[25] =  top.pipe.seiryu.busy;
	 

   assign comptr = top.pipe.comptr;
   assign comptr2 = top.pipe.comptr2;   
   assign rrfptr = top.pipe.rrfptr;
   wire [31:0] busy_master;
   wire [31:0] tag0;
   wire [31:0] tag1;
   wire [31:0] tag2;
   wire [31:0] tag3;
   wire [31:0] tag4;
   wire [31:0] tag5;
   assign busy_master = top.pipe.aregfile.rt.busy_master;
   assign tag0 = top.pipe.aregfile.rt.tag0_master;
   assign tag1 = top.pipe.aregfile.rt.tag1_master;
   assign tag2 = top.pipe.aregfile.rt.tag2_master;
   assign tag3 = top.pipe.aregfile.rt.tag3_master;
   assign tag4 = top.pipe.aregfile.rt.tag4_master;
   assign tag5 = top.pipe.aregfile.rt.tag5_master;   

   property assume_const_rrftag (entry);
      @(posedge clk)
	(~wait_for_commit_reg) |->
   	((eq && (freenum == 0)) || (eq && (freenum == 64) && (rrftag_val[entry] == 0))
   	|| (lt && (rrftag_arr[entry] < rrfptr) && (rrftag_arr[entry] >= comptr))
   	|| (gt && ((rrftag_arr[entry] >= comptr) || (rrftag_arr[entry] < rrfptr)))
   	|| (rrftag_val[entry] == 0))
   endproperty   

   generate
       for (j = 0; j < 26; j++) begin
   	  assume_const_rrftag1: assume property (assume_const_rrftag(j));
       end
   endgenerate

   generate
       for (j = 0; j < 26; j++) begin
   	  assume_consist_robfinish: assume property (
   						   @(posedge clk)
						   (~wait_for_commit_reg) |->			   
   						   ((rrftag_val[j] == 0)
   						   || ((rob_finish[rrftag_arr[j]] == 0))
						    )
   						   );
       end
   endgenerate

   wire [675:0] tag_eq;
   generate
      for (i = 0; i < 26; i++) begin
	 for (j = 0; j < 26; j++) begin
	     assign tag_eq[26*i + j] = (j > i) ? ((rrftag_arr[i] == rrftag_arr[j]) && (rrftag_val[i] == 1) && (rrftag_val[j] == 1)) : 0;   
	 end
      end
   endgenerate

//   initial begin
      assume_unique_tags: assume property(
					  @(posedge clk)
					  (~wait_for_commit_reg) |->
					  ~(|tag_eq)
					  );
//end
	 
   generate
       for (j = 0; j < 32; j++) begin
//	 initial begin
   	  assume_consist_rrftag3: assume property (
   						   @(posedge clk)
						   (~wait_for_commit_reg) |->						   
   						   ((eq && (freenum == 0)) || (eq && (freenum == 64) /*&& ({tag5[j],tag4[j],tag3[j],tag2[j],tag1[j],tag0[j]} == 0)*/ && (busy_master[j] == 0))
   						   || (lt && ({tag5[j],tag4[j],tag3[j],tag2[j],tag1[j],tag0[j]} < rrfptr) && ({tag5[j],tag4[j],tag3[j],tag2[j],tag1[j],tag0[j]} >= comptr))
   						   || (gt && (({tag5[j],tag4[j],tag3[j],tag2[j],tag1[j],tag0[j]} >= comptr) || ({tag5[j],tag4[j],tag3[j],tag2[j],tag1[j],tag0[j]} < rrfptr)))
   						   || (busy_master[j] == 0))
   						   );
//	 end
       end
   endgenerate

	 // source data assumption
wire [4:0]  src1[0:63];
wire [4:0]  src2[0:63];
wire [31:0] src1_data[0:63];
wire [31:0] src2_data[0:63];
wire [63:0] src1_valid;
wire [63:0] src2_valid;
wire [63:0] src_track;
wire [63:0] src1_datval;
wire [63:0] src2_datval;
wire [63:0] ldsrc_track;
wire [63:0] ldsrc_val;
//wire [5:0] ldsrc_addr[0:63];
generate
   for (j=0; j < 64; j++) begin
      assign src1[j] = top.pipe.rob.src1[j];
      assign src2[j] = top.pipe.rob.src2[j];
      assign src1_data[j] = top.pipe.rob.src1_data[j];
      assign src2_data[j] = top.pipe.rob.src2_data[j];
   end
endgenerate
assign src1_valid = top.pipe.rob.src1_valid;
assign src2_valid = top.pipe.rob.src2_valid;
assign src_track = top.pipe.rob.src_track;
assign src1_datval = top.pipe.rob.src1_datval;
assign src2_datval = top.pipe.rob.src2_datval;
assign ldsrc_track = top.pipe.rob.ldsrc_track;
assign ldsrc_val = top.pipe.rob.ldsrc_val;
   
generate
   for (j=0; j<64; j++) begin
      assume_consist_source_data:   assume property (
						     @(posedge wait_for_commit_reg)
						     ( (src_track[j] == 0)
						       || ( ((src1_valid[j] == 0) || (src1_datval[j] == 0) || (src1_data[j] == iregs[src1[j]]))
							    &&
							    ((src2_valid[j] == 0) || (src2_datval[j] == 0) || (src2_data[j] == iregs[src2[j]]))
							   )
						      )
						     );
   end
endgenerate

generate
   for (j=0; j<64; j++) begin
      assume_consist_ldsource_data:   assume property (
						     @(posedge wait_for_commit_reg)
						     ( (ldsrc_track[j] == 0)
						       || ( ((ldsrc_val[j] == 0) || (top.pipe.rob.ldsrc_data[j] == top.datamemory.mem[top.pipe.rob.ldsrc_addr[j][5:0]]))							   )
						      )
						     );
   end
endgenerate   

   property assume_init_mem;
      @(posedge clk)
//	$rose(top.reset_x) |-> 
	((top.pipe.qed0.qic.i_cache == 0)
	&& (top.pipe.qed0.qic.address_tail == 0)
	&& (top.pipe.qed0.qic.address_head == 0)
	&& (top.pipe.rob.wait_till_commit_reg == 0)
	&& (top.pipe.rob.state_delay == 0)
	&& (top.pipe.rob.formal_commit == 0)
	&& (top.pipe.rob.src_track == 0)
	&& (top.pipe.rob.src1_valid == 0)
	&& (top.pipe.rob.src2_valid == 0)	 
	&& (top.pipe.rob.src1_datval == 0)
	&& (top.pipe.rob.src2_datval == 0)
	&& (top.pipe.rob.src1_rrftag_val == 0)
	&& (top.pipe.rob.src2_rrftag_val == 0)
	&& (top.pipe.rob.ldsrc_track == 0)
	&& (top.pipe.rob.ldsrc_val == 0)	 	 	 	 	 
	&& (top.pipe.num_orig_insts == 0)
	&& (top.pipe.num_dup_insts == 0)
	&& (top.pipe.qed1.qic.i_cache == 0)
	&& (top.pipe.qed1.qic.address_tail == 0)
	&& (top.pipe.qed1.qic.address_head == 0))
   endproperty

//   ass_mem: assume property (assume_init_mem);

   initial begin
      assume_mem: assume property (assume_init_mem);
      assume_freenum: assume property (as_freenum);
//      assume_inv2: assume property (as_inv2);
//      assume_id_incons: assume property (as_id_incons);
   end
   
   generate
       for (j = 1; j < 16; j++) begin
   	  assert_ireg_match : assert property (
   		@(posedge clk)
   		 (ena && wait_for_commit_reg) |-> (iregs[j] == iregs[j+16])  );
   	 end
   endgenerate


   // assert_orig_ge_dup: assert property (
   // 					@(posedge clk) (num_orig >= num_dup)
   // 					);
   
   inst_constraint inst_constraint_0 (.clk(clk), .instruction(top.pipe.inst1));
   inst_constraint inst_constraint_1 (.clk(clk), .instruction(top.pipe.inst2));   

   // ASSUMTPIONS

   // COVERS

   generate
      for (i = 0; i < 3; i++) begin : cover_ireg_match_i
         cover_ireg_match : cover property (@(posedge clk) (iregs[i] == i));
      end
   endgenerate


   cover_test_trace_1 : cover property (
					@(posedge clk)
					(
					 (top.pipe.inst1 == 32'h00700093)&&(top.pipe.qed_exec_dup == 1'b0)
					 ##1
					 (top.pipe.inst1 == 32'h00708193)&&(top.pipe.qed_exec_dup == 1'b0)
					 ##1
					 (top.pipe.inst1 == 32'h00f02383)&&(top.pipe.qed_exec_dup == 1'b0)
					 ##2
					 (top.pipe.qed_exec_dup == 1'b1)
					 ##1
					 (top.pipe.qed_exec_dup == 1'b1)
					 ##1
					 (top.pipe.qed_exec_dup == 1'b1)
					 ##8
					 (top.pipe.qed_exec_dup == 1'b1)
					 )
					);

   cover_test_trace_2: cover property (
				       @(posedge clk)
					(
					 (top.pipe.inst1 == 32'h007000f7)&&(top.pipe.qed_exec_dup == 1'b0)
					 ##1
					 (top.pipe.inst1 == 32'h007081f7)&&(top.pipe.qed_exec_dup == 1'b0)
					 )
				       );

   // rand_property : cover property (
   // 				   @(posedge clk) (iregs[1]&iregs[2]&iregs[3]&iregs[4]&iregs[5]&iregs[6]&iregs[7]&iregs[8]
   						   
   // 						    != 0)
   // 				    );

   // rand_property2 : cover property (
   // 				   @(posedge clk) (iregs[1]&iregs[2]&iregs[3]&iregs[4]&iregs[5]&iregs[6]
   // 						   &iregs[7]&iregs[8]&iregs[9]&iregs[10]&iregs[11]&iregs[12]&iregs[13]
   // 						   &iregs[14]&iregs[15]&iregs[17] != 0)
   // 				    );
   
   
endmodule // spc_checker
