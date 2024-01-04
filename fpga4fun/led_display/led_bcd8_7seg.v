/*
    驱动8个七段数码管，八条线控制显示内容，八条线控制led低电平
*/

module led_BCD8x7seg (
    input wire clk,
    output segA, segB, segC, segD, segE, segF, segG, segDP;
    output [7: 0] seg_cathode
);
    reg [23: 0] cnt;
    always @(posedge clk) begin
        cnt <= cnt + 24'h1;
    end
    wire cnt_ovf = &cnt;

    wire [2: 0] digit_scan = cnt[18: 16];
    assign seg_cathode[0] = ~(digit_scan == 3'h0);
    assign seg_cathode[1] = ~(digit_scan == 3'h1);
    assign seg_cathode[2] = ~(digit_scan == 3'h2);
    assign seg_cathode[3] = ~(digit_scan == 3'h3);
    assign seg_cathode[4] = ~(digit_scan == 3'h4);
    assign seg_cathode[5] = ~(digit_scan == 3'h5);
    assign seg_cathode[6] = ~(digit_scan == 3'h6);
    assign seg_cathode[7] = ~(digit_scan == 3'h7);

    wire [8 * 4 - 1: 0] BCD_digits;
    BCD8 bcd(.clk(clk), .ena(cnt_ovf), ,BCD_digits(BCD_digits));

    // multipliexer
    reg [3: 0] BCD_digit;
    always @(*) begin
        case (digit_scan)
            3'd0: BCD_digit = BCD_digits[ 3: 0];
            3'd1: BCD_digit = BCD_digits[ 7: 4];
            3'd2: BCD_digit = BCD_digits[11: 8];
            3'd3: BCD_digit = BCD_digits[15:12];
            3'd4: BCD_digit = BCD_digits[19:16];
            3'd5: BCD_digit = BCD_digits[23:20];
            3'd6: BCD_digit = BCD_digits[27:24];
            3'd7: BCD_digit = BCD_digits[31:28];
        endcase
    end

    reg [7:0] seven_seg;
    always @(*) begin
        case(BCD_digit)
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

module BCD8(
    input wire clk,
    input wire ena,
    output reg [8*4-1:0] BCD_digits
);
    wire [7: 0] carryout;
    assign carryout[0] = ena;
    BCD1 digit0(.clk(clk), .ena(carryout[0]), .BCD_digit(BCD_digits[ 3: 0]), .BCD_carryout(carryout[1]));
    BCD1 digit1(.clk(clk), .ena(carryout[1]), .BCD_digit(BCD_digits[ 7: 4]), .BCD_carryout(carryout[2]));
    BCD1 digit2(.clk(clk), .ena(carryout[2]), .BCD_digit(BCD_digits[11: 8]), .BCD_carryout(carryout[3]));
    BCD1 digit3(.clk(clk), .ena(carryout[3]), .BCD_digit(BCD_digits[15:12]), .BCD_carryout(carryout[4]));
    BCD1 digit4(.clk(clk), .ena(carryout[4]), .BCD_digit(BCD_digits[19:16]), .BCD_carryout(carryout[5]));
    BCD1 digit5(.clk(clk), .ena(carryout[5]), .BCD_digit(BCD_digits[23:20]), .BCD_carryout(carryout[6]));
    BCD1 digit6(.clk(clk), .ena(carryout[6]), .BCD_digit(BCD_digits[27:24]), .BCD_carryout(carryout[7]));
    BCD1 digit7(.clk(clk), .ena(carryout[7]), .BCD_digit(BCD_digits[31:28]));
endmodule

module BCD1 (
    input wire clk,
    input wire ena,
    output reg [3: 0] BCD_digit,
    output reg BCD_carryout
);
    wire BCD_rollover = (BCD_digit == 4'd9);
    always @(posedge clk) begin
        if (ena) begin
            if (BCD_rollover) begin
                BCD_digit <= 4'd0;
            end else begin
                BCD_digit <= BCD_digit + 4'd1;
            end
        end
    end

    assign BCD_carryout = ena & BCD_rollover;
endmodule
