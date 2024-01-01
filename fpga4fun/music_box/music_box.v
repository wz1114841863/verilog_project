/*


*/
module music_box (
    input wire clk,
    output reg speaker
);
    parameter clk_divider = 25000000 / 440 / 2;

    reg [14: 0] counter;
    always @(posedge clk)  begin
        if (counter == 0) begin
            counter <= clk_divider - 1;
        end else begin
            counter <= counter - 1;
        end
    end

    reg speaker;
    always @(posedge clk) begin
        if (counter == 0) begin
            speaker <= ~speaker;
        end
    end
endmodule
