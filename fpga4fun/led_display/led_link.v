/*
    点亮LED
*/

module led_link (
    input wire clk,
    output reg led
);
    reg [31: 0] cnt;
    always @(posedge clk) begin
        cnt <= cnt + 1;
    end

    assign led = cnt[22];
endmodule

module led_half_lit (
    input wire clk,
    output led
);
    reg toggle;
    always @(posedge clk) begin
        toggle <= ~toggle;
    end

    assign led = toggle;
endmodule

module led_pwm(
    input wire clk,
    input [3: 0] pwm_input,
    output led
);
    reg [4: 0] pwm;
    always @(posedge clk) begin
        pwm <= pwm[3: 0] + pwm_input;
    end

    assign led = pwm[4];
endmodule

module led_glow (
    input wire clk,
    output led
);
    reg [23: 0] cnt;
    always @(posedge clk) begin
        cnt <= cnt + 1;
    end

    reg [4: 0] pwm;
    wire [3: 0] intensity = cnt[23] ? cnt[22: 19] : ~cnt[22: 19];
    always @(posedge clk) begin
        pwm <= pwm[3: 0] + intensity;
    end

    assign led = pwm[4];
endmodule
