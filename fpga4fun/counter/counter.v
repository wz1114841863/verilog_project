/*
    counter
*/

module bina_cnt (
    input wire clk,
    output tick
);
    reg [31: 0] cnt = 0;
    reg [32: 0] cnt_next = cnt + 1;

    always @(posedge clk) begin
        cnt <= cnt_next[31: 0];
    end
    wire tick = cnt_next[32];
endmodule

module gray_cnt(
  input clk,
  output [3:0] cnt_gray
);

    reg [3:0] cnt = 0;
    always @(posedge clk) begin
        cnt <= cnt+1;  // 4bit binary counter
    end
    assign cnt_gray = cnt ^ cnt[3:1];  // then convert to gray
endmodule
