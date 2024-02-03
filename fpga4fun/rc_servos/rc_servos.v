/*
    R/C srevos, clk = 25MHz
*/

module rc_servos (
    input wire clk,
    input wire RxD,
    output wire rc_servos_pulse;
);
    // use the serial port to control the servo

    wire RxD_data_ready;
    wire [7:0] RxD_data;
    async_receiver deserialer(.clk(clk), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));

    reg [7:0] RxD_data_reg;
    always @(posedge clk) begin
        if (RxD_data_ready) begin
            RxD_data_reg <= RxD_data;
        end
    end

    parameter clk_div = 98;
    reg [6: 0] clk_count;
    reg clk_tick;
    always @(posedge clk) begin
        clk_tick <= (clk_count == clk_div - 2);
    end
    always @(posedge clk) begin
        if (clk_tick) begin
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    // initial a counter
    reg [11: 0] pluse_count;
    always @(posedge clk) begin
        if (clk_tick) begin
            pluse_count <= pluse_count + 1;
        end
    end

    reg [7: 0] rc_servos_pos'
    always @(posedge clk) begin
        if (pluse_count) begin
            rc_servos <= RxD_data_reg;
        end
    end

    reg rc_servos_pulse;
    always @(posedge clk) begin
        rc_servos_pulse <= (pluse_count < < {4'b0001, rc_servos_pos});
    end
endmodule
