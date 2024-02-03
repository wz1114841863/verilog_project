/*
    按键防抖
*/

module push_button_debounce (
    input wire clk,
    input wire pb,
    output reg pb_state,
    output rb_down,
    output pb_up
);
    // two filp-flops
    reg pb_sync_0;
    always @(posedge clk) begin
        pb_sync_0 <= ~pb;
    end
    reg pb_sync_1;
    always @(posedge clk) begin
        pb_sync_1 <= pb_sync_0;
    end

    // 16-bits counter
    reg [15: 0] pb_cnt;
    wire pb_idle = (pb_state == pb_sync_1);
    wire pb_cnt_max = &(pb_cnt);
    always @(posedge clk) begin
        if (pb_idle) begin
            pb_cnt <= 0;
        end else begin
            pb_cnt <= pb_cnt + 16'd1;
            if (pb_cnt_max) begin
                pb_state <= ~pb_state;
            end
        end
    end

    assign pb_down = ~pb_idle & pb_cnt_max & ~pb_state;
    assign pb_up = ~pb_idle & pb_cnt_max & pb_state;
endmodule
