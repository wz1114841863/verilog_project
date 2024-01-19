/*
    使用VGA显示图像, 设定clk频率为25MHz
*/

module pong_game (
    input wire clk,

);
    reg [9: 0] counter_X;
    reg [8: 0] counter_Y;  // 0 - 511
    wire counter_X_maxed = (counter_X == 767);

    always @(posedge clk) begin
        if (counter_X_maxed) begin
            counter_X <= 0;
        end else begin
            counter_X = counter_X + 1;
        end
    end

    always @(posedge clk) begin
        if (counter_X_maxed) begin
            counter_Y <= counter_Y + 1;
        end
    end

    reg vga_HS, vga_VS;
    always @(posedge clk) begin
        vga_HS <= (counter_X[9: 4] == 0);
        vga_VS <= (counter_Y == 0);
    end

    assign vga_h_sync = ~vga_HS;
    assign vga_v_sync = ~vga_VS;

    assign R = counter_Y[3] | (counter_X == 256);
    assign G = (counter_X[5] ^ counter_X[6]) | (counter_X == 256);
    assign B = counter_X[4] | (counter_X == 256);
endmodule
