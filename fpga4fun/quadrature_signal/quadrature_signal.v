/*
    正交解码器
*/
module quad(
    input wire clk,
    input wire quad_A,
    input wire quad_B,
    output [7: 0] count
);
    reg quad_A_delayed, quad_B_delayed;
    always @(posedge clk) begin
        quad_A_delayed <= quad_A;
    end
    always @(posedge clk) begin
        quad_B_delayed <= quad_B;
    end

    wire count_enable = quad_A ^ quad_A_delayed ^ quad_B ^ quad_B_delayed;
    wire count_direction = quad_A ^ quad_B_delayed;

    reg [7: 0] count;
    always @(posedge clk) begin
        if (count_enable) begin
            if (count_direction) begin
                count <= count + 1;
            end else begin
                count <= count - 1;
            end
        end
    end
endmodule

module quad(
    input wire clk,
    input wire quad_A,
    input wire quad_B,
    output [7: 0] count
);
    reg [2: 0] quad_A_delayed, quad_B_delayed;
    always @(posedge clk) begin
        quad_A_delayed <= {quad_A_delayed[1: 0], quad_A};
    end
    always @(posedge clk) begin
        quad_B_delayed<= {quad_B_delayed[1: 0], quad_B};
    end

    wire count_enable = quad_A_delayed[1] ^ quad_A_delayed[2] ^ quad_B_delayed[1] ^ quad_B_delayed[2];
    wire count_direction = quad_A_delayed[1] ^ quad_B_delayed[2];

    reg [7: 0] count;
    always @(posedge clk) begin
        if (count_enable) begin
            if (count_direction) begin
                count <= count + 1;
            end else begin
                count <= count - 1;
            end
        end
    end
endmodule
