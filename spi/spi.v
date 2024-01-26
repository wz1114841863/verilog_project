// SPI Master
// 下降沿发送数据、上升沿接收数据
// 工作时钟：200 Mhz
// 波特率：20MHz
// 传输位度：16
// 地址位度：7
// 数据位宽：8
module spi_master (
    input wire clk,
    input wire rst_n,

    input wire [15: 0] tx_data,
    input wire tx_data_en,
    output [7: 0] rdata,
    output rdata_valid,
    output ready,

    output sclk,
    output csn,
    output mosi,
    input wire miso
);
    // 100MHz clk, 10MHz spi clk
    parameter BAUD_NUM = 100 / 10;
    // baud clk generating by baud counter
    reg [4: 0] baud_cnt_r;
    // generating negedge sclk
    wire baud_cnt_end = (baud_cnt_r == BAUD_NUM - 1);
    // generating posedge sclk
    wire baud_cnt_half = (baud_cnt_r == BAUD_NUM / 2 - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt_r <= 1'b0;
        end else if (csn) begin
            baud_cnt_r <= 1'b0;
        end else if (baud_cnt_end) begin
            baud_cnt_r <= 1'b0;
        end else begin
            baud_cnt_r <= baud_cnt_r + 1'b1;
        end
    end

    // bit counter
    reg [7: 0] bit_cnt_r;
    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            bit_cnt_r <= 1'b0;
        end else if (csn) begin
            bit_cnt_r <= 1'b0;
        end else if (baud_cnt_half && bit_cnt_r != 16) begin
            bit_cnt_r <= bit_cnt_r + 1'b1;
        end
    end

    // generate spi clk
    reg sclk_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_r <= 1'b1;
        end else if (csn) begin
            sclk_r <= 1'b1;
        end else if (baud_cnt_half && bit_cnt_r != 16) begin
            sclk_r <= 1'b0 ;
        end else if (baud_cnt_end) begin
            sclk_r <= 1'b1 ;
        end
    end

    assign sclk = sclk_r;

    // generate csn
    reg csn_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csn_r <= 1'b1;
        end else if (tx_data_en) begin
            csn_r <= 1'b0;
        end else if (!csn_r && bit_cnt_r == 16 && baud_cnt_half) begin
            //16 data finished, delay half cycle
            csn_r <= 1'b1;
        end
    end
    assign csn = csn_r;

    // tx_data buffer
    reg [15: 0] tx_data_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data_r <= 15'b0;
        end else if (tx_data_en && ready) begin
            tx_data_r <= tx_data;
        end
    end

    // generate mosi
    reg mosi_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mosi_r <= 1'b1;
        end else if (csn) begin
            mosi_r <= 1'b1;
        end else if (baud_cnt_half && bit_cnt_r != 16) begin
            // output tx_data
            mosi_r <= tx_data_r[15 - bit_cnt_r];
        end
    end

    assign mosi = mosi_r;

    // receive data by miso
    reg [7: 0] rdata_r;
    reg rdata_valid_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata_r <= 8'b0;
            rdata_valid_r <= 1'b0;
        end else if (rdata_valid_r) begin
            rdata_valid_r <= 1'b0;
        end else if (!tx_data_r[15] && bit_cnt_r == 16 && baud_cnt_end) begin
            rdata_r <= {rdata_r[6: 0], miso};
            rdata_valid_r <= 1'b1;
        end else if (!tx_data_r[15] && bit_cnt_r >= 9 && baud_cnt_end) begin
            // 分两次接收
            rdata_r <= {rdata_r[6: 0], miso};
        end
    end

    reg ready_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_r <= 1'b1;
        end else if (tx_data_en) begin
            ready_r <= 1'b0;
        end else if (csn) begin
            ready_r <= 1'b1;
        end
    end
    assign rdata = rdata_r;
    assign rdata_valid = rdata_valid_r;
endmodule
