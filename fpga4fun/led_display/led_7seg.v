/*
    7段数码管
*/
module led_7seg (
    input wire clk,
    output reg segA,
    output reg segB,
    output reg segC,
    output reg segD,
    output reg segE,
    output reg segF,
    output reg segG,
    output reg sefDP
);
    reg [23: 0] cnt;
    always @(posedge clk) begin
        cnt <= cnt + 24'h1;
    end
    wire cnt_ovf = &cnt;

    reg [3: 0] BCD;
    always @(posedge clk) begin
        if (cnt_ovf) begin
            BCD <= (BCD == 4'h9 ? 4'h0 : BCD + 4'h1);  // from 0 to 9
        end
    end

    reg [7: 0] seven_seg;
    always @(*) begin
        case(BCD)
            4'h0: seven_seg = 8'b1111_1100;
            4'h1: seven_seg = 8'b0110_0000;
            4'h2: seven_seg = 8'b1101_1010;
            4'h3: seven_seg = 8'b1111_0010;
            4'h4: seven_seg = 8'b0110_0110;
            4'h5: seven_seg = 8'b1011_0110;
            4'h6: seven_seg = 8'b1011_1110;
            4'h7: seven_seg = 8'b1110_0000;
            4'h8: seven_seg = 8'b1111_1110;
            4'h9: seven_seg = 8'b1111_0110;
            default: seven_seg = 8'b0000_0000;
        endcase
    end

    assign {segA, segB, segC, segD, segE, segF, segG, segDP} = seven_seg;
endmodule

