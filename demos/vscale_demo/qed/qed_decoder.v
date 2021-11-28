// Copyright (c) Stanford University
// 
// This source code is patent protected and being made available under the
// terms explained in the ../LICENSE-Academic and ../LICENSE-GOV files.
//
// Author: Mario J Srouji
// Email: msrouji@stanford.edu

module qed_decoder (
// Outputs
IS_R,
IS_FENCE,
jimm20,
IS_LUI,
IS_B,
IS_I,
IS_AUIPC,
IS_J,
rs1,
rs2,
jimm11,
rd,
funct3,
funct7,
IS_SW,
imm12,
IS_SYSTEM,
bimm10,
bimm11,
bimm12,
IS_LW,
jimm10,
IS_JALR,
uimm31,
opcode,
bimm4,
imm5,
imm7,
jimm19,
// Inputs
ifu_qed_instruction);

  input [31:0] ifu_qed_instruction;

  output IS_R;
  output IS_FENCE;
  output jimm20;
  output IS_LUI;
  output IS_B;
  output IS_I;
  output IS_AUIPC;
  output IS_J;
  output [4:0] rs1;
  output [4:0] rs2;
  output jimm11;
  output [4:0] rd;
  output [2:0] funct3;
  output [6:0] funct7;
  output IS_SW;
  output [11:0] imm12;
  output IS_SYSTEM;
  output [5:0] bimm10;
  output bimm11;
  output bimm12;
  output IS_LW;
  output [9:0] jimm10;
  output IS_JALR;
  output [19:0] uimm31;
  output [6:0] opcode;
  output [3:0] bimm4;
  output [4:0] imm5;
  output [6:0] imm7;
  output [7:0] jimm19;

  assign imm12 = ifu_qed_instruction[31:20];
  assign bimm4 = ifu_qed_instruction[11:8];
  assign jimm10 = ifu_qed_instruction[30:21];
  assign bimm11 = ifu_qed_instruction[7:7];
  assign uimm31 = ifu_qed_instruction[31:12];
  assign jimm11 = ifu_qed_instruction[20:20];
  assign rd = ifu_qed_instruction[11:7];
  assign jimm20 = ifu_qed_instruction[31:31];
  assign funct3 = ifu_qed_instruction[14:12];
  assign opcode = ifu_qed_instruction[6:0];
  assign imm7 = ifu_qed_instruction[31:25];
  assign bimm12 = ifu_qed_instruction[31:31];
  assign funct7 = ifu_qed_instruction[31:25];
  assign bimm10 = ifu_qed_instruction[30:25];
  assign imm5 = ifu_qed_instruction[11:7];
  assign rs1 = ifu_qed_instruction[19:15];
  assign rs2 = ifu_qed_instruction[24:20];
  assign jimm19 = ifu_qed_instruction[19:12];

  assign IS_B = (opcode == 7'b1100011);
  assign IS_JALR = (opcode == 7'b1100111);
  assign IS_FENCE = (opcode == 7'b0001111);
  assign IS_I = (opcode == 7'b0010011);
  assign IS_J = (opcode == 7'b1101111);
  assign IS_SW = (opcode == 7'b0100011);
  assign IS_SYSTEM = (opcode == 7'b1110011);
  assign IS_LW = (opcode == 7'b0000011);
  assign IS_R = (opcode == 7'b0110011);
  assign IS_AUIPC = (opcode == 7'b0010111);
  assign IS_LUI = (opcode == 7'b0110111);

endmodule
