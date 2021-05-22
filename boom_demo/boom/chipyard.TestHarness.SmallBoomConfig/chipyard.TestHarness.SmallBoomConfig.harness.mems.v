module mem_ext( // @[anonymous source 2:2]
  input  [8:0]  RW0_addr, // @[anonymous source 3:4]
  input         RW0_clk, // @[anonymous source 4:4]
  input  [63:0] RW0_wdata, // @[anonymous source 5:4]
  output [63:0] RW0_rdata, // @[anonymous source 6:4]
  input         RW0_en, // @[anonymous source 7:4]
  input         RW0_wmode, // @[anonymous source 8:4]
  input  [7:0]  RW0_wmask // @[anonymous source 9:4]
);
  wire [8:0] mem_0_0_RW0_addr; // @[anonymous source 11:4]
  wire  mem_0_0_RW0_clk; // @[anonymous source 11:4]
  wire [7:0] mem_0_0_RW0_wdata; // @[anonymous source 11:4]
  wire [7:0] mem_0_0_RW0_rdata; // @[anonymous source 11:4]
  wire  mem_0_0_RW0_en; // @[anonymous source 11:4]
  wire  mem_0_0_RW0_wmode; // @[anonymous source 11:4]
  wire  mem_0_0_RW0_wmask; // @[anonymous source 11:4]
  wire [8:0] mem_0_1_RW0_addr; // @[anonymous source 12:4]
  wire  mem_0_1_RW0_clk; // @[anonymous source 12:4]
  wire [7:0] mem_0_1_RW0_wdata; // @[anonymous source 12:4]
  wire [7:0] mem_0_1_RW0_rdata; // @[anonymous source 12:4]
  wire  mem_0_1_RW0_en; // @[anonymous source 12:4]
  wire  mem_0_1_RW0_wmode; // @[anonymous source 12:4]
  wire  mem_0_1_RW0_wmask; // @[anonymous source 12:4]
  wire [8:0] mem_0_2_RW0_addr; // @[anonymous source 13:4]
  wire  mem_0_2_RW0_clk; // @[anonymous source 13:4]
  wire [7:0] mem_0_2_RW0_wdata; // @[anonymous source 13:4]
  wire [7:0] mem_0_2_RW0_rdata; // @[anonymous source 13:4]
  wire  mem_0_2_RW0_en; // @[anonymous source 13:4]
  wire  mem_0_2_RW0_wmode; // @[anonymous source 13:4]
  wire  mem_0_2_RW0_wmask; // @[anonymous source 13:4]
  wire [8:0] mem_0_3_RW0_addr; // @[anonymous source 14:4]
  wire  mem_0_3_RW0_clk; // @[anonymous source 14:4]
  wire [7:0] mem_0_3_RW0_wdata; // @[anonymous source 14:4]
  wire [7:0] mem_0_3_RW0_rdata; // @[anonymous source 14:4]
  wire  mem_0_3_RW0_en; // @[anonymous source 14:4]
  wire  mem_0_3_RW0_wmode; // @[anonymous source 14:4]
  wire  mem_0_3_RW0_wmask; // @[anonymous source 14:4]
  wire [8:0] mem_0_4_RW0_addr; // @[anonymous source 15:4]
  wire  mem_0_4_RW0_clk; // @[anonymous source 15:4]
  wire [7:0] mem_0_4_RW0_wdata; // @[anonymous source 15:4]
  wire [7:0] mem_0_4_RW0_rdata; // @[anonymous source 15:4]
  wire  mem_0_4_RW0_en; // @[anonymous source 15:4]
  wire  mem_0_4_RW0_wmode; // @[anonymous source 15:4]
  wire  mem_0_4_RW0_wmask; // @[anonymous source 15:4]
  wire [8:0] mem_0_5_RW0_addr; // @[anonymous source 16:4]
  wire  mem_0_5_RW0_clk; // @[anonymous source 16:4]
  wire [7:0] mem_0_5_RW0_wdata; // @[anonymous source 16:4]
  wire [7:0] mem_0_5_RW0_rdata; // @[anonymous source 16:4]
  wire  mem_0_5_RW0_en; // @[anonymous source 16:4]
  wire  mem_0_5_RW0_wmode; // @[anonymous source 16:4]
  wire  mem_0_5_RW0_wmask; // @[anonymous source 16:4]
  wire [8:0] mem_0_6_RW0_addr; // @[anonymous source 17:4]
  wire  mem_0_6_RW0_clk; // @[anonymous source 17:4]
  wire [7:0] mem_0_6_RW0_wdata; // @[anonymous source 17:4]
  wire [7:0] mem_0_6_RW0_rdata; // @[anonymous source 17:4]
  wire  mem_0_6_RW0_en; // @[anonymous source 17:4]
  wire  mem_0_6_RW0_wmode; // @[anonymous source 17:4]
  wire  mem_0_6_RW0_wmask; // @[anonymous source 17:4]
  wire [8:0] mem_0_7_RW0_addr; // @[anonymous source 18:4]
  wire  mem_0_7_RW0_clk; // @[anonymous source 18:4]
  wire [7:0] mem_0_7_RW0_wdata; // @[anonymous source 18:4]
  wire [7:0] mem_0_7_RW0_rdata; // @[anonymous source 18:4]
  wire  mem_0_7_RW0_en; // @[anonymous source 18:4]
  wire  mem_0_7_RW0_wmode; // @[anonymous source 18:4]
  wire  mem_0_7_RW0_wmask; // @[anonymous source 18:4]
  wire [7:0] RW0_rdata_0_0 = mem_0_0_RW0_rdata; // @[anonymous source 21:4]
  wire [7:0] RW0_rdata_0_1 = mem_0_1_RW0_rdata; // @[anonymous source 28:4]
  wire [7:0] RW0_rdata_0_2 = mem_0_2_RW0_rdata; // @[anonymous source 35:4]
  wire [7:0] RW0_rdata_0_3 = mem_0_3_RW0_rdata; // @[anonymous source 42:4]
  wire [7:0] RW0_rdata_0_4 = mem_0_4_RW0_rdata; // @[anonymous source 49:4]
  wire [7:0] RW0_rdata_0_5 = mem_0_5_RW0_rdata; // @[anonymous source 56:4]
  wire [7:0] RW0_rdata_0_6 = mem_0_6_RW0_rdata; // @[anonymous source 63:4]
  wire [7:0] RW0_rdata_0_7 = mem_0_7_RW0_rdata; // @[anonymous source 70:4]
  wire [15:0] _GEN_0 = {RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [23:0] _GEN_1 = {RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [31:0] _GEN_2 = {RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [39:0] _GEN_3 = {RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [47:0] _GEN_4 = {RW0_rdata_0_5,RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [55:0] _GEN_5 = {RW0_rdata_0_6,RW0_rdata_0_5,RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,
    RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [63:0] RW0_rdata_0 = {RW0_rdata_0_7,RW0_rdata_0_6,RW0_rdata_0_5,RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,
    RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [15:0] _GEN_6 = {RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [23:0] _GEN_7 = {RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [31:0] _GEN_8 = {RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [39:0] _GEN_9 = {RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [47:0] _GEN_10 = {RW0_rdata_0_5,RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,RW0_rdata_0_0}; // @[anonymous source 75:4]
  wire [55:0] _GEN_11 = {RW0_rdata_0_6,RW0_rdata_0_5,RW0_rdata_0_4,RW0_rdata_0_3,RW0_rdata_0_2,RW0_rdata_0_1,
    RW0_rdata_0_0}; // @[anonymous source 75:4]
  split_mem_ext mem_0_0 ( // @[anonymous source 11:4]
    .RW0_addr(mem_0_0_RW0_addr),
    .RW0_clk(mem_0_0_RW0_clk),
    .RW0_wdata(mem_0_0_RW0_wdata),
    .RW0_rdata(mem_0_0_RW0_rdata),
    .RW0_en(mem_0_0_RW0_en),
    .RW0_wmode(mem_0_0_RW0_wmode),
    .RW0_wmask(mem_0_0_RW0_wmask)
  );
  split_mem_ext mem_0_1 ( // @[anonymous source 12:4]
    .RW0_addr(mem_0_1_RW0_addr),
    .RW0_clk(mem_0_1_RW0_clk),
    .RW0_wdata(mem_0_1_RW0_wdata),
    .RW0_rdata(mem_0_1_RW0_rdata),
    .RW0_en(mem_0_1_RW0_en),
    .RW0_wmode(mem_0_1_RW0_wmode),
    .RW0_wmask(mem_0_1_RW0_wmask)
  );
  split_mem_ext mem_0_2 ( // @[anonymous source 13:4]
    .RW0_addr(mem_0_2_RW0_addr),
    .RW0_clk(mem_0_2_RW0_clk),
    .RW0_wdata(mem_0_2_RW0_wdata),
    .RW0_rdata(mem_0_2_RW0_rdata),
    .RW0_en(mem_0_2_RW0_en),
    .RW0_wmode(mem_0_2_RW0_wmode),
    .RW0_wmask(mem_0_2_RW0_wmask)
  );
  split_mem_ext mem_0_3 ( // @[anonymous source 14:4]
    .RW0_addr(mem_0_3_RW0_addr),
    .RW0_clk(mem_0_3_RW0_clk),
    .RW0_wdata(mem_0_3_RW0_wdata),
    .RW0_rdata(mem_0_3_RW0_rdata),
    .RW0_en(mem_0_3_RW0_en),
    .RW0_wmode(mem_0_3_RW0_wmode),
    .RW0_wmask(mem_0_3_RW0_wmask)
  );
  split_mem_ext mem_0_4 ( // @[anonymous source 15:4]
    .RW0_addr(mem_0_4_RW0_addr),
    .RW0_clk(mem_0_4_RW0_clk),
    .RW0_wdata(mem_0_4_RW0_wdata),
    .RW0_rdata(mem_0_4_RW0_rdata),
    .RW0_en(mem_0_4_RW0_en),
    .RW0_wmode(mem_0_4_RW0_wmode),
    .RW0_wmask(mem_0_4_RW0_wmask)
  );
  split_mem_ext mem_0_5 ( // @[anonymous source 16:4]
    .RW0_addr(mem_0_5_RW0_addr),
    .RW0_clk(mem_0_5_RW0_clk),
    .RW0_wdata(mem_0_5_RW0_wdata),
    .RW0_rdata(mem_0_5_RW0_rdata),
    .RW0_en(mem_0_5_RW0_en),
    .RW0_wmode(mem_0_5_RW0_wmode),
    .RW0_wmask(mem_0_5_RW0_wmask)
  );
  split_mem_ext mem_0_6 ( // @[anonymous source 17:4]
    .RW0_addr(mem_0_6_RW0_addr),
    .RW0_clk(mem_0_6_RW0_clk),
    .RW0_wdata(mem_0_6_RW0_wdata),
    .RW0_rdata(mem_0_6_RW0_rdata),
    .RW0_en(mem_0_6_RW0_en),
    .RW0_wmode(mem_0_6_RW0_wmode),
    .RW0_wmask(mem_0_6_RW0_wmask)
  );
  split_mem_ext mem_0_7 ( // @[anonymous source 18:4]
    .RW0_addr(mem_0_7_RW0_addr),
    .RW0_clk(mem_0_7_RW0_clk),
    .RW0_wdata(mem_0_7_RW0_wdata),
    .RW0_rdata(mem_0_7_RW0_rdata),
    .RW0_en(mem_0_7_RW0_en),
    .RW0_wmode(mem_0_7_RW0_wmode),
    .RW0_wmask(mem_0_7_RW0_wmask)
  );
  assign RW0_rdata = {RW0_rdata_0_7,_GEN_5}; // @[anonymous source 75:4]
  assign mem_0_0_RW0_addr = RW0_addr; // @[anonymous source 20:4]
  assign mem_0_0_RW0_clk = RW0_clk; // @[anonymous source 19:4]
  assign mem_0_0_RW0_wdata = RW0_wdata[7:0]; // @[anonymous source 22:4]
  assign mem_0_0_RW0_en = RW0_en; // @[anonymous source 25:4]
  assign mem_0_0_RW0_wmode = RW0_wmode; // @[anonymous source 24:4]
  assign mem_0_0_RW0_wmask = RW0_wmask[0]; // @[anonymous source 23:4]
  assign mem_0_1_RW0_addr = RW0_addr; // @[anonymous source 27:4]
  assign mem_0_1_RW0_clk = RW0_clk; // @[anonymous source 26:4]
  assign mem_0_1_RW0_wdata = RW0_wdata[15:8]; // @[anonymous source 29:4]
  assign mem_0_1_RW0_en = RW0_en; // @[anonymous source 32:4]
  assign mem_0_1_RW0_wmode = RW0_wmode; // @[anonymous source 31:4]
  assign mem_0_1_RW0_wmask = RW0_wmask[1]; // @[anonymous source 30:4]
  assign mem_0_2_RW0_addr = RW0_addr; // @[anonymous source 34:4]
  assign mem_0_2_RW0_clk = RW0_clk; // @[anonymous source 33:4]
  assign mem_0_2_RW0_wdata = RW0_wdata[23:16]; // @[anonymous source 36:4]
  assign mem_0_2_RW0_en = RW0_en; // @[anonymous source 39:4]
  assign mem_0_2_RW0_wmode = RW0_wmode; // @[anonymous source 38:4]
  assign mem_0_2_RW0_wmask = RW0_wmask[2]; // @[anonymous source 37:4]
  assign mem_0_3_RW0_addr = RW0_addr; // @[anonymous source 41:4]
  assign mem_0_3_RW0_clk = RW0_clk; // @[anonymous source 40:4]
  assign mem_0_3_RW0_wdata = RW0_wdata[31:24]; // @[anonymous source 43:4]
  assign mem_0_3_RW0_en = RW0_en; // @[anonymous source 46:4]
  assign mem_0_3_RW0_wmode = RW0_wmode; // @[anonymous source 45:4]
  assign mem_0_3_RW0_wmask = RW0_wmask[3]; // @[anonymous source 44:4]
  assign mem_0_4_RW0_addr = RW0_addr; // @[anonymous source 48:4]
  assign mem_0_4_RW0_clk = RW0_clk; // @[anonymous source 47:4]
  assign mem_0_4_RW0_wdata = RW0_wdata[39:32]; // @[anonymous source 50:4]
  assign mem_0_4_RW0_en = RW0_en; // @[anonymous source 53:4]
  assign mem_0_4_RW0_wmode = RW0_wmode; // @[anonymous source 52:4]
  assign mem_0_4_RW0_wmask = RW0_wmask[4]; // @[anonymous source 51:4]
  assign mem_0_5_RW0_addr = RW0_addr; // @[anonymous source 55:4]
  assign mem_0_5_RW0_clk = RW0_clk; // @[anonymous source 54:4]
  assign mem_0_5_RW0_wdata = RW0_wdata[47:40]; // @[anonymous source 57:4]
  assign mem_0_5_RW0_en = RW0_en; // @[anonymous source 60:4]
  assign mem_0_5_RW0_wmode = RW0_wmode; // @[anonymous source 59:4]
  assign mem_0_5_RW0_wmask = RW0_wmask[5]; // @[anonymous source 58:4]
  assign mem_0_6_RW0_addr = RW0_addr; // @[anonymous source 62:4]
  assign mem_0_6_RW0_clk = RW0_clk; // @[anonymous source 61:4]
  assign mem_0_6_RW0_wdata = RW0_wdata[55:48]; // @[anonymous source 64:4]
  assign mem_0_6_RW0_en = RW0_en; // @[anonymous source 67:4]
  assign mem_0_6_RW0_wmode = RW0_wmode; // @[anonymous source 66:4]
  assign mem_0_6_RW0_wmask = RW0_wmask[6]; // @[anonymous source 65:4]
  assign mem_0_7_RW0_addr = RW0_addr; // @[anonymous source 69:4]
  assign mem_0_7_RW0_clk = RW0_clk; // @[anonymous source 68:4]
  assign mem_0_7_RW0_wdata = RW0_wdata[63:56]; // @[anonymous source 71:4]
  assign mem_0_7_RW0_en = RW0_en; // @[anonymous source 74:4]
  assign mem_0_7_RW0_wmode = RW0_wmode; // @[anonymous source 73:4]
  assign mem_0_7_RW0_wmask = RW0_wmask[7]; // @[anonymous source 72:4]
endmodule
module split_mem_ext( // @[anonymous source 78:2]
  input  [8:0] RW0_addr, // @[anonymous source 79:4]
  input        RW0_clk, // @[anonymous source 80:4]
  input  [7:0] RW0_wdata, // @[anonymous source 81:4]
  output [7:0] RW0_rdata, // @[anonymous source 82:4]
  input        RW0_en, // @[anonymous source 83:4]
  input        RW0_wmode, // @[anonymous source 84:4]
  input        RW0_wmask // @[anonymous source 85:4]
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:511]; // @[anonymous source 87:4]
  wire [7:0] ram_RW_0_r_data; // @[anonymous source 87:4]
  wire [8:0] ram_RW_0_r_addr; // @[anonymous source 87:4]
  wire [7:0] ram_RW_0_w_data; // @[anonymous source 87:4]
  wire [8:0] ram_RW_0_w_addr; // @[anonymous source 87:4]
  wire  ram_RW_0_w_mask; // @[anonymous source 87:4]
  wire  ram_RW_0_w_en; // @[anonymous source 87:4]
  reg  ram_RW_0_r_en_pipe_0;
  reg [8:0] ram_RW_0_r_addr_pipe_0;
  wire  _GEN_0 = ~RW0_wmode;
  wire  _GEN_1 = ~RW0_wmode;
  assign ram_RW_0_r_addr = ram_RW_0_r_addr_pipe_0;
  assign ram_RW_0_r_data = ram[ram_RW_0_r_addr]; // @[anonymous source 87:4]
  assign ram_RW_0_w_data = RW0_wdata;
  assign ram_RW_0_w_addr = RW0_addr;
  assign ram_RW_0_w_mask = RW0_wmask;
  assign ram_RW_0_w_en = RW0_en & RW0_wmode;
  assign RW0_rdata = ram_RW_0_r_data; // @[anonymous source 99:4]
  always @(posedge RW0_clk) begin
    if(ram_RW_0_w_en & ram_RW_0_w_mask) begin
      ram[ram_RW_0_w_addr] <= ram_RW_0_w_data; // @[anonymous source 87:4]
    end
    ram_RW_0_r_en_pipe_0 <= RW0_en & ~RW0_wmode;
    if (RW0_en & ~RW0_wmode) begin
      ram_RW_0_r_addr_pipe_0 <= RW0_addr;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 512; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  ram_RW_0_r_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  ram_RW_0_r_addr_pipe_0 = _RAND_2[8:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
