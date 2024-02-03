/*
    使用两个触发器将信号从clkA移动到clkB
*/

module signal_croos_domain (
    input clk_a,
    input sign_in_clk_a,
    input clk_b,
    output signal_out_b
);
    // use a two-stages shift-register to synchronize SignalIn_clkA to the clkB clock domain
    reg [1: 0] sync_a_clk_b;
    always @(posedge clk_b) begin
        sync_a_clk_b[0] <= sign_in_clk_a;
    end
    always @(posedge clk_b) begin
        sync_a_clk_b[1] <= sync_a_clk_b[0];
    end

    assign signal_out_b = sync_a_clk_b[1];
endmodule
