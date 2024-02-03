/*
    在两个不同的时钟域传递标志位。
*/

module flag_cross_domain (
    input wire clk_a,
    input wire flag_in_clk_a,
    input wire clk_b,
    output flag_out_clk_b
);
    reg flag_toggle_clk_a;
    always @(negedge clk_a) begin
        flag_toggle_clk_a <= flag_toggle_clk_a ^ flag_in_clk_a;
    end

    reg [2: 0] sync_a_clk_b;
    always @(posedge clk_b) begin
        sync_a_clk_b <= {sync_a_clk_b[1:0], flag_toggle_clk_a};
    end
    assign flag_out_clk_ = (sync_a_clk_b[2] ^ sync_a_clk_b[1]);
endmodule

module flag_cross_domain_ack (
    input wire clk_a,
    input wire flag_in_clk_a,
    output busy_clk_a,
    input wire clk_b,
    output flag_out_clk_b
);
    reg flag_toggle_clk_a;
    always @(posedge clk_a) begin
        flag_toggle_clk_a <= flag_toggle_clk_a ^ (flag_in_clk_a & ~busy_clk_a);
    end

    reg [2: 0] sync_a_clk_b;
    always @(posedge clk_b) begin
        sync_a_clk_b <= {sync_a_clk_b[1:0], flag_toggle_clk_a};
    end

    reg [1: 0] sync_b_clk_a;
    always @(posedge clk_a) begin
        sync_b_clk_a <= {sync_b_clk_a[0], sync_a_clk_b[2]};
    end

    assign flag_out_clk_b = (sync_a_clk_b[2] ^ sync_a_clk_b[1]);
    assign busy_clk_a = flag_toggle_clk_a ^ sync_b_clk_a[1];
endmodule
