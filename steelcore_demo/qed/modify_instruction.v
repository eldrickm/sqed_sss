// Copyright (c) Stanford University
// 
// This source code is patent protected and being made available under the
// terms explained in the ../LICENSE-Academic and ../LICENSE-GOV files.
//
// Author: Mario J Srouji
// Email: msrouji@stanford.edu

module modify_instruction (
// Outputs
qed_instruction,
// Inputs
IS_R,
qic_qimux_instruction,
jimm20,
IS_LUI,
IS_B,
IS_I,
IS_AUIPC,
IS_J,
rs1,
rs2,
rd,
funct3,
funct7,
IS_SW,
imm12,
bimm10,
bimm11,
bimm12,
IS_LW,
jimm10,
jimm11,
uimm31,
opcode,
bimm4,
imm5,
imm7,
jimm19);

  input IS_R;
  input [31:0] qic_qimux_instruction;
  input jimm20;
  input IS_LUI;
  input IS_B;
  input IS_I;
  input IS_AUIPC;
  input IS_J;
  input [4:0] rs1;
  input [4:0] rs2;
  input [4:0] rd;
  input [2:0] funct3;
  input [6:0] funct7;
  input IS_SW;
  input [11:0] imm12;
  input [5:0] bimm10;
  input bimm11;
  input bimm12;
  input IS_LW;
  input [9:0] jimm10;
  input jimm11;
  input [19:0] uimm31;
  input [6:0] opcode;
  input [3:0] bimm4;
  input [4:0] imm5;
  input [6:0] imm7;
  input [7:0] jimm19;

  output [31:0] qed_instruction;

  wire [31:0] INS_B;
  wire [31:0] INS_CONSTRAINT;
  wire [31:0] INS_I;
  wire [31:0] INS_J;
  wire [31:0] INS_SW;
  wire [31:0] INS_LW;
  wire [31:0] INS_R;
  wire [31:0] INS_AUIPC;
  wire [31:0] INS_LUI;

  wire [4:0] NEW_rd;
  wire [4:0] NEW_rs1;
  wire [4:0] NEW_rs2;
  wire [11:0] NEW_imm12;
  wire [6:0] NEW_imm7;

  assign NEW_rd = (rd == 5'b00000) ? rd : {1'b1, rd[3:0]};
  assign NEW_rs1 = (rs1 == 5'b00000) ? rs1 : {1'b1, rs1[3:0]};
  assign NEW_rs2 = (rs2 == 5'b00000) ? rs2 : {1'b1, rs2[3:0]};
  // Start Edit: Shrink RAM Depth
  // RAM Depth Shrunk to 32-deep
  // Memory accesses are 4 byte aligned, hence we keep the lower 6 bits
  // and only change the 7th bit for 2 16-deep partitions
  assign NEW_imm12 = {6'b000001, imm12[5:0]};
  assign NEW_imm7  = {6'b000001, imm7[0]};
  // assign NEW_imm5 = {1'b1, imm5[3:0]};
  // End Edit: Shrink RAM Depth

  assign INS_B = {bimm12, bimm10, NEW_rs2, NEW_rs1, funct3, bimm4, bimm11, opcode};
  assign INS_I = {imm12, NEW_rs1, funct3, NEW_rd, opcode};
  assign INS_J = {jimm20, jimm10, jimm11, jimm19, NEW_rd, opcode};
  assign INS_SW = {NEW_imm7, NEW_rs2, NEW_rs1, funct3, imm5, opcode};
  assign INS_LW = {NEW_imm12, NEW_rs1, funct3, NEW_rd, opcode};
  assign INS_R = {funct7, NEW_rs2, NEW_rs1, funct3, NEW_rd, opcode};
  assign INS_AUIPC = {uimm31, NEW_rd, opcode};
  assign INS_LUI = {uimm31, NEW_rd, opcode};

  assign qed_instruction = IS_B ? INS_B : (IS_I ? INS_I : (IS_J ? INS_J : (IS_SW ? INS_SW : (IS_LW ? INS_LW : (IS_R ? INS_R : (IS_AUIPC ? INS_AUIPC : (IS_LUI ? INS_LUI : qic_qimux_instruction)))))));

endmodule
