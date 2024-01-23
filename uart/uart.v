// 接收模块：接收串行数据
/*
    clock: 50Mhz
    baud: 115200
    一位起始位、八位数据位、一位停止位
*/
module uart_rx #(
    parameter CLK_FRE = 50,         // clock frequency(Mhz)
    parameter BAUD_RATE = 115200    // serial baud rate
) (
    input wire clk,                 // clock input
    input wire rst_n,               // asynchronous reset input, low active
    input wire rx_data_ready,       // receive serial dat is valid
    input wire rx_pin,              // serial data input
    output reg [7: 0] rx_data,      // receive seial data
    output reg rx_data_valid        // receive serial data is valid
);
    // calc the clock cycle for baud rate
    localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE;
    // state machine code
    localparam S_IDLE      = 1;
    localparam S_START     = 2; // start bit
    localparam S_RECV_BYTE = 3; // data bits
    localparam S_STOP      = 4; // stop bit
    localparam S_DATA      = 5;

    reg [2: 0] state;
    reg [2: 0] next_state;
    reg rx_d0;  // delay 1 clock for rx_pin
    reg rx_d1;  // delay 1 clock for rx_d0
    wire rx_negedge;  // negedge of rx_pin;
    reg [7: 0] rx_bits;  // temporary stoage of received data
    reg [15: 0] cycle_cnt;  // baud counter;
    reg [2: 0] bit_cnt;  // bit counter

    assign rx_negedge = rx_d1 && ~rx_d0;

    // 异步复位 和 接收数据输入信号
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            rx_d0 <= 1'b0;
            rx_d1 <= 1'b0;
        end else begin
            rx_d0 <= rx_pin;
            rx_d1 <= rx_d0;
        end
    end

    // 状态机
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            S_IDLE: begin
                if (rx_negedge) begin
                    next_state <= S_START;
                end else begin
                    next_state <= S_IDLE;
                end
            end
            S_START: begin
                if (cycle_cnt == CYCLE - 1) begin
                    next_state <= S_RECV_BYTE;
                end else begin
                    next_state <= S_START;
                end
            end
            S_RECV_BYTE: begin
                if (cycle_cnt == CYCLE - 1 && bit_cnt == 3'd7) begin
                    next_state <= S_STOP;
                end else begin
                    next_state <= S_RECV_BYTE;
                end
            end
            S_STOP: begin
                //half bit cycle,to avoid missing the next byte receiver
                if (cycle_cnt == CYCLE / 2 - 1) begin
                    next_state <= S_DATA;
                end else begin
                    next_state <= S_STOP;
                end
            end
            S_DATA: begin
                // data receive complete
                if (rx_data_ready) begin
                    next_state <= S_IDLE;
                end else begin
                    next_state <= S_DATA;
                end
            end
            default: next_state <= S_IDLE;
        endcase
    end

    // rx_data_valid 标志位设置， 接收完成后，设为1后置0
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            rx_data_valid <= 1'b0;
        end else if (state == S_STOP && next_state != state) begin
            rx_data_valid <= 1'b1;
        end else if (state == S_DATA && rx_data_ready) begin
            rx_data_valid <= 1'b0;
        end
    end

    // receive serial data bit data
    // 避免对串行输入数据的误采样，在波特率计数器的中间值时刻进行采样
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            rx_bits <= 8'd0;
        end else if (state == S_RECV_BYTE && cycle_cnt == CYCLE/2 - 1) begin
            rx_bits[bit_cnt] <= rx_pin;
        end else begin
            rx_bits <= rx_bits;
        end
    end

    // 输出数据, 使用锁存器
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            rx_data <= 8'd0;
        end else if (state == S_STOP && next_state != state) begin
            // latch received data
            rx_data <= rx_bits;
        end
    end

    // 计数
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            bit_cnt <= 3'd0;
        end else if (state == S_RECV_BYTE) begin
            if (cycle_cnt == CYCLE - 1) begin
                bit_cnt <= bit_cnt + 3'd1;
            end else begin
                bit_cnt <= bit_cnt;
            end
        end else begin
            bit_cnt <= 3'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            cycle_cnt <= 16'd0;
        end else if ((state == S_RECV_BYTE && cycle_cnt == CYCLE - 1) || next_state != state) begin
            cycle_cnt <= 16'd0;
        end else begin
            cycle_cnt <= cycle_cnt + 16'd1;
        end
    end

endmodule


module uart_tx #(
    parameter CLK_FRE = 50,         // clock frequency(Mhz)
    parameter BAUD_RATE = 115200    // serial baud rate
) (
    input wire clk,                 // clock input
    input wire rst_n,               // asynchronous reset input, low active
    input wire [7: 0] tx_data,      // data to send
    input wire tx_data_valid,       // data ro be sent is valid
    output reg tx_data_ready,       // send valid
    output wire tx_pin               // serial data output
);

    // calc the clock cycle for baud rate
    localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE;
    // state machine code
    localparam S_IDLE      = 1;
    localparam S_START     = 2; // start bit
    localparam S_SEND_BYTE = 3; // send bits
    localparam S_STOP      = 4; // stop bit

    reg [2: 0] state;
    reg [2: 0] next_state;
    reg [15: 0] cycle_cnt;  // baud counter
    reg [2: 0] bit_cnt;  // bit counter
    reg [7: 0] tx_data_latch;  // latch data to send
    reg tx_reg; // serial data output

    // 输出
    assign tx_pin = tx_reg;

    // 状态机
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case(state)
            S_IDLE: begin
                if (tx_data_valid == 1'b1) begin
                    next_state <= S_START;
                end else begin
                    next_state <= S_IDLE;
                end
            end
            S_START: begin
                if (cycle_cnt == CYCLE - 1) begin
                    next_state <= S_SEND_BYTE;
                end else begin
                    next_state <= S_START;
                end
            end
            S_SEND_BYTE: begin
                if (cycle_cnt == CYCLE - 1 && bit_cnt == 3'd7) begin
                    next_state <= S_STOP;
                end else begin
                    next_state <= S_SEND_BYTE;
                end
            end
            S_STOP: begin
                if (cycle_cnt == CYCLE - 1) begin
                    next_state <= S_IDLE;
                end else begin
                    next_state <= S_STOP;
                end
            end
            default: next_state <= S_IDLE;
        endcase
    end

    // 设置tx_data_ready
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_data_ready <= 1'b0;
        end else if (state == S_IDLE) begin
            if (tx_data_valid == 1'b1) begin
                tx_data_ready <= 1'b0;
            end else begin
                tx_data_ready <= 1'b1;
            end
        end else if (state == S_STOP && cycle_cnt == CYCLE - 1) begin
            tx_data_ready <= 1'b1;
        end
    end

    // 输出数据
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_data_latch <= 8'd0;
        end else if (state == S_IDLE && tx_data_valid == 1'b1)begin
            tx_data_latch <= tx_data;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_reg <= 1'b1;
        end else begin
            case (state)
                S_IDLE, S_STOP: begin
                    tx_reg <= 1'b1;
                end
                S_START: begin
                    tx_reg <= 1'b0;
                end
                S_SEND_BYTE: begin
                    tx_reg <= tx_data_latch[bit_cnt];
                end
                default: tx_reg <= 1'b1;
            endcase
        end
    end

    // 计数
	 always@(posedge clk or negedge rst_n) begin
			if(rst_n == 1'b0) begin
					bit_cnt <= 3'd0;
         end else if(state == S_SEND_BYTE) begin
                if(cycle_cnt == CYCLE - 1) begin
							bit_cnt <= bit_cnt + 3'd1;
                end else begin
							bit_cnt <= bit_cnt;
					 end
			end else begin
				bit_cnt <= 3'd0;
			end
	end

   always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            cycle_cnt <= 16'd0;
        end else if ((state == S_SEND_BYTE && cycle_cnt == CYCLE - 1) || next_state != state) begin
            cycle_cnt <= 16'd0;
        end else begin
            cycle_cnt <= cycle_cnt + 16'd1;
        end
    end
endmodule

module uart #(
    parameter CLK_FRE = 50,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst_n,
    input rx,
    input rx_ready,
    output [7:0] rx_data,
    output rx_data_valid,

    input [7: 0] tx_data,
    input tx_data_valid,
    output tx,
    output tx_ready
);
    uart_rx #(
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx(
        .clk(clk),
        .rst_n(rst_n),
        .rx_pin(rx),
        .rx_data_ready(rx_ready),
        .rx_data(rx_data),
        .rx_data_valid(rx_data_valid)
    );


    uart_tx #(
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_data_valid(tx_data_valid),
        .tx_pin(tx),
        .tx_data_ready(tx_ready)
    );
endmodule
