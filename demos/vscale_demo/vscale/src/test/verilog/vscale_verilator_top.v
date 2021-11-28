`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

module vscale_verilator_top(
                            input                        clk,
                            input                        reset,
                            input                        htif_pcr_req_valid,
                            output                       htif_pcr_req_ready,
                            input                        htif_pcr_req_rw,
                            input [`CSR_ADDR_WIDTH-1:0]  htif_pcr_req_addr,
                            input [`HTIF_PCR_WIDTH-1:0]  htif_pcr_req_data,
                            output                       htif_pcr_resp_valid,
                            input                        htif_pcr_resp_ready,
                            output [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data
                            );


   vscale_sim_top DUT(
                      .clk(clk),
                      .reset(reset),
                      .htif_pcr_req_valid(htif_pcr_req_valid),
                      .htif_pcr_req_ready(htif_pcr_req_ready),
                      .htif_pcr_req_rw(htif_pcr_req_rw),
                      .htif_pcr_req_addr(htif_pcr_req_addr),
                      .htif_pcr_req_data(htif_pcr_req_data),
                      .htif_pcr_resp_valid(htif_pcr_resp_valid),
                      .htif_pcr_resp_ready(htif_pcr_resp_ready),
                      .htif_pcr_resp_data(htif_pcr_resp_data)
                      );

   initial begin
      $readmemb("vscale_simple_test.bin", DUT.imem.mem);
   end

endmodule // vscale_verilator_top

