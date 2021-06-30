// Copyright (c) Stanford University
//
// This source code is patent protected and being made available under the
// terms explained in the ../LICENSE-Academic and ../LICENSE-GOV files.
//
// Author: Eldrick Millares
// Email: eldrick@stanford.edu

module qed_mem_shim (
    // clock and reset
    input         clk_i,
    input         rst_i,

    // qed interface
    input         qed_vld_i,
    input [31:0]  qed_instr_i,

    // memory interface
    output [31:0] mem_addr_o,
    output [31:0] mem_data_o,
    output        mem_w_en_o
);

    reg [31:0] qed_instr_q;

    reg [31:0] mem_addr;
    reg        mem_w_en;

    always @(posedge clk_i) begin
        if (rst_i) begin
            mem_addr <= 'h0;
            mem_w_en <= 'b0;
            qed_instr_q <= 'h0;
        end else begin
            if(qed_vld_i) begin
                // increment 4 bytes since we have 1 word = 4 bytes
                mem_addr <= mem_addr + 'h4;
                mem_w_en <= 'b1;
                qed_instr_q <= qed_instr_i;
            end
        end
    end

    assign mem_data_o = qed_instr_q;
    assign mem_addr_o = mem_addr;
    assign mem_w_en_o = mem_w_en;

endmodule

