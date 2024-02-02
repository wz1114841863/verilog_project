/*
    PWM波形产生
*/

module pwm_1 (
    input wire clk,
    input [3: 0] pwm_in,
    output pwm_out
);
    reg [3: 0] cnt;
    always @(posedge clk) begin
        cnt <= cnt + 1'b1;
    end
    assign pwm_out = (pwm_in > cnt);
endmodule

module pwm_2 (
    input clk,
    input [3: 0] pwm_in,
    output pwm_out
);
    reg [3: 0] cnt;
    reg cnt_dir;
    wire [3: 0] cnt_text = cnt_dir ? cnt - 1'b1 : cnt + 1'b1;
    wire cnt_end = cnt_dir ? cnt == 4'b0000 : cnt == 4'b1111;

    always @(posedge clk) begin
        cnt <= cnt_end ? pwm_in : cnt_next;
    end
    always @(posedge clk) begin
        cnt_dir <= cnt_dir ^ cnt_end;
    end
    assign pwm_out = cnt_dir;
endmodule

module pwm_3 (
    input clk,
    input [7: 0] pwm_in,
    output pwm_out
);
    reg [8: 0] pwm_accum;
    always @(posedge clk) begin
        pwm_accum <= pwm_accum[7: 0] + pwm_in;
    end
    assign pwm_out = pwm_accum[8];
endmodule


