// Copyright (c) Stanford University
// 
// This source code is patent protected and being made available under the
// terms explained in the ../LICENSE-Academic and ../LICENSE-GOV files.
//
// Author: Mario J Srouji
// Email: msrouji@stanford.edu

module inst_constraint (
// Inputs
instruction,
clk);

  input [31:0] instruction;
  input clk;

  wire [4:0] shamt;
  wire [11:0] imm12;
  wire [4:0] rd;
  wire [2:0] funct3;
  wire [6:0] opcode;
  wire [6:0] imm7;
  wire [6:0] funct7;
  wire [4:0] imm5;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [9:0] jimm10;
  wire jimm11;
  wire [7:0] jimm19;
  wire jimm20;

  wire FORMAT_I;
  wire ALLOWED_I;
  wire ANDI;
  wire SLTIU;
  wire SRLI;
  wire SLTI;
  wire SRAI;
  wire SLLI;
  wire ORI;
  wire XORI;
  wire ADDI;

  wire FORMAT_J;
  wire ALLOWED_J;
  wire JAL;

  wire FORMAT_LW;
  wire ALLOWED_LW;
  wire LW;

  wire FORMAT_R;
  wire ALLOWED_R;
  wire AND;
  wire SLTU;
  wire MULH;
  wire SRA;
  wire XOR;
  wire SUB;
  wire SLT;
  wire MULHSU;
  wire MULHU;
  wire SRL;
  wire SLL;
  wire ADD;
  wire MUL;
  wire OR;

  wire FORMAT_SW;
  wire ALLOWED_SW;
  wire SW;

  wire ALLOWED_NOP;
  wire NOP;

  assign shamt = instruction[24:20];
  assign imm12 = instruction[31:20];
  assign rd = instruction[11:7];
  assign funct3 = instruction[14:12];
  assign opcode = instruction[6:0];
  assign imm7 = instruction[31:25];
  assign funct7 = instruction[31:25];
  assign imm5 = instruction[11:7];
  assign rs1 = instruction[19:15];
  assign rs2 = instruction[24:20];
  assign jimm10 = instruction[30:21];
  assign jimm11 = instruction[20:20];
  assign jimm19 = instruction[19:12];
  assign jimm20 = instruction[31:31];

  assign FORMAT_I = (rs1 < 16) && (rd < 16);
  assign ANDI = FORMAT_I && (funct3 == 3'b111) && (opcode == 7'b0010011);
  assign SLTIU = FORMAT_I && (funct3 == 3'b011) && (opcode == 7'b0010011);
  assign SRLI = FORMAT_I && (funct3 == 3'b101) && (opcode == 7'b0010011) && (funct7 == 7'b0000000);
  assign SLTI = FORMAT_I && (funct3 == 3'b010) && (opcode == 7'b0010011);
  assign SRAI = FORMAT_I && (funct3 == 3'b101) && (opcode == 7'b0010011) && (funct7 == 7'b0100000);
  assign SLLI = FORMAT_I && (funct3 == 3'b001) && (opcode == 7'b0010011) && (funct7 == 7'b0000000);
  assign ORI = FORMAT_I && (funct3 == 3'b110) && (opcode == 7'b0010011);
  assign XORI = FORMAT_I && (funct3 == 3'b100) && (opcode == 7'b0010011);
  assign ADDI = FORMAT_I && (funct3 == 3'b000) && (opcode == 7'b0010011);
  assign ALLOWED_I = ANDI || SLTIU || SRLI || SLTI || SRAI || SLLI || ORI || XORI || ADDI;

  assign FORMAT_LW = (instruction[31:30] == 00) && (rs1 < 16) && (rd < 16) && (imm12 < 64);
  assign LW = FORMAT_LW && (funct3 == 3'b010) && (opcode == 7'b0000011) && (rs1 == 5'b00000);
  assign ALLOWED_LW = LW;

  assign FORMAT_J = (rd < 16);
  assign JAL = FORMAT_J && (opcode == 7'b1101111);
  assign ALLOWED_J = JAL;

  assign FORMAT_R = (rs2 < 16) && (rs1 < 16) && (rd < 16);
  assign AND = FORMAT_R && (funct3 == 3'b111) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign SLTU = FORMAT_R && (funct3 == 3'b011) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign SRA = FORMAT_R && (funct3 == 3'b101) && (opcode == 7'b0110011) && (funct7 == 7'b0100000);
  assign XOR = FORMAT_R && (funct3 == 3'b100) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign SUB = FORMAT_R && (funct3 == 3'b000) && (opcode == 7'b0110011) && (funct7 == 7'b0100000);
  assign SLT = FORMAT_R && (funct3 == 3'b010) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign SRL = FORMAT_R && (funct3 == 3'b101) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign SLL = FORMAT_R && (funct3 == 3'b001) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign ADD = FORMAT_R && (funct3 == 3'b000) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign OR = FORMAT_R && (funct3 == 3'b110) && (opcode == 7'b0110011) && (funct7 == 7'b0000000);
  assign ALLOWED_R = AND || SLTU || SRA || XOR || SUB || SLT || SRL || SLL || ADD || OR;

  assign FORMAT_SW = (instruction[31:30] == 00) && (rs2 < 16) && (rs1 < 16) && (imm7 < 2);
  assign SW = FORMAT_SW && (funct3 == 3'b010) && (opcode == 7'b0100011) && (rs1 == 5'b00000);
  assign ALLOWED_SW = SW;

  assign NOP = (opcode == 7'b1111111);
  assign ALLOWED_NOP = NOP;
  
  wire sif_commit;
  assign sif_commit = design_top.dut.sif_commit;
  // only allow certain instructions before SIF commit
  // in this case, prevent SW from occuring before SIF commit since it will
  // commit only 1 cycle after issue, leading to a violation of constraint C2
  assume_allowed_instructions_before_tc: assume property (
                         @(posedge clk)
                         ~sif_commit |->
                         (ALLOWED_I || ALLOWED_LW || ALLOWED_J || ALLOWED_R || ALLOWED_NOP)
                         );
  assume_allowed_instructions_after_tc: assume property (
                         @(posedge clk)
                         sif_commit |->
                         (ALLOWED_I || ALLOWED_LW || ALLOWED_J || ALLOWED_R || ALLOWED_SW || ALLOWED_NOP)
                         );

endmodule
