/*
    LCD屏幕显示
*/

module lcd_module(
    input wire clk,
    input wire RxD,
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [7: 0] LCD_data_bus
);
    wire RxD_data_ready;
    wire [7:0] RxD_data;
    async_receiver deserializer(.clk(clk), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));

    assign LCD_RW = 0;
    assign LCD_data_bus = RxD_data;

    wire recv_Escape = RxD_data_ready & (RxD_data == 0);
    wire recv_Data = RxD_data_ready & (RxD_data != 0);

    reg [2: 0] count;
    always @(posedge clk) begin
        if (RxD_data_ready | (count != 0)) begin
            count <= count + 1;
        end
    end
    reg LCD_E;
    always @(posedge clk) begin
        if (LCD_E == 0) begin
            LCD_E <= recv_Data;
        end else begin
            LCD_E <= (count != 6);
        end
    end

    reg LCD_instruction;
    always @(posedge clk) begin
        if (LCD_instruction == 0) begin
            LCD_instruction <=recv_Escape;
        end else begin
            LCD_instruction <= (count != 7);
        end
    end

    assign LCD_RS = ~LCD_instruction;
endmodule
