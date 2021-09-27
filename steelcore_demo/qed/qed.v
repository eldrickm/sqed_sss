// Copyright (c) Stanford University
// 
// This source code is patent protected and being made available under the
// terms explained in the ../LICENSE-Academic and ../LICENSE-GOV files.
//
// Author: Mario J Srouji
// Email: msrouji@stanford.edu

module qed (
// Outputs
vld_out,
qed_ifu_instruction,
// Inputs
ena,
ifu_qed_instruction,
clk,
exec_dup,
stall_IF,
rst);

  input ena;
  input [31:0] ifu_qed_instruction;
  input clk;
  input exec_dup;
  input stall_IF;
  input rst;

  output vld_out;
  output [31:0] qed_ifu_instruction;
  wire [11:0] imm12;
  wire [3:0] bimm4;
  wire [9:0] jimm10;
  wire bimm11;
  wire [19:0] uimm31;
  wire jimm11;
  wire [4:0] rd;
  wire jimm20;
  wire [2:0] funct3;
  wire [6:0] opcode;
  wire [6:0] imm7;
  wire bimm12;
  wire [6:0] funct7;
  wire [5:0] bimm10;
  wire [4:0] imm5;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [7:0] jimm19;

  wire IS_B;
  wire IS_I;
  wire IS_J;
  wire IS_SW;
  wire IS_LW;
  wire IS_R;
  wire IS_AUIPC;
  wire IS_LUI;

  wire [31:0] qed_instruction;
  wire [31:0] qic_qimux_instruction;

  qed_decoder dec (.ifu_qed_instruction(qic_qimux_instruction),
                   .imm12(imm12),
                   .bimm4(bimm4),
                   .jimm10(jimm10),
                   .bimm11(bimm11),
                   .uimm31(uimm31),
                   .jimm11(jimm11),
                   .rd(rd),
                   .jimm20(jimm20),
                   .funct3(funct3),
                   .opcode(opcode),
                   .imm7(imm7),
                   .bimm12(bimm12),
                   .funct7(funct7),
                   .bimm10(bimm10),
                   .imm5(imm5),
                   .rs1(rs1),
                   .rs2(rs2),
                   .jimm19(jimm19),
                   .IS_B(IS_B),
                   .IS_I(IS_I),
                   .IS_J(IS_J),
                   .IS_SW(IS_SW),
                   .IS_LW(IS_LW),
                   .IS_R(IS_R),
                   .IS_AUIPC(IS_AUIPC),
                   .IS_LUI(IS_LUI));

  modify_instruction minst (.qed_instruction(qed_instruction),
                            .qic_qimux_instruction(qic_qimux_instruction),
                            .imm12(imm12),
                            .bimm4(bimm4),
                            .jimm10(jimm10),
                            .bimm11(bimm11),
                            .uimm31(uimm31),
                            .jimm11(jimm11),
                            .rd(rd),
                            .jimm20(jimm20),
                            .funct3(funct3),
                            .opcode(opcode),
                            .imm7(imm7),
                            .bimm12(bimm12),
                            .funct7(funct7),
                            .bimm10(bimm10),
                            .imm5(imm5),
                            .rs1(rs1),
                            .rs2(rs2),
                            .jimm19(jimm19),
                            .IS_B(IS_B),
                            .IS_I(IS_I),
                            .IS_J(IS_J),
                            .IS_SW(IS_SW),
                            .IS_LW(IS_LW),
                            .IS_R(IS_R),
                            .IS_AUIPC(IS_AUIPC),
                            .IS_LUI(IS_LUI));

  qed_instruction_mux imux (.qed_ifu_instruction(qed_ifu_instruction),
                            .ifu_qed_instruction(ifu_qed_instruction),
                            .qed_instruction(qed_instruction),
                            .exec_dup(exec_dup),
                            .ena(ena));

  qed_i_cache qic (.qic_qimux_instruction(qic_qimux_instruction),
                   .vld_out(vld_out),
                   .clk(clk),
                   .rst(rst),
                   .exec_dup(exec_dup),
                   .IF_stall(stall_IF),
                   .ifu_qed_instruction(ifu_qed_instruction));

endmodule
