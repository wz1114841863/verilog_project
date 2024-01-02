/*
介绍：
    通过频率控制，产生不同的声音
    网址：https://www.fpga4fun.com/MusicBox.html
*/
module music_box_simple_beeps (
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

module music_box_ambulance_siren (
    input wire clk,
    output reg speaker
);
    reg [27: 0] tone;
    always @(posedge clk) begin
        tone <= tone + 1;
    end

    wire [6: 0] fast_sweep = (tone[22] ? tone[21: 15] : ~tone[21: 15]);
    wire [6: 0] slow_sweep = (tone[25] ? tone[24: 18] : ~tone[24: 18]);
    wire [14: 0] clk_divider = {2'b01, (tone[27] ? slow_sweep : fast_sweep), 6'b0000_00};

    reg [14: 0] counter;
    always @(posedge clk) begin
        if (counter == 0) begin
            counter <= clk_divider;
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

module music_playing_notes(
    input wire clk,
    output reg speaker
);

    reg [27:0] tone;
    always @(posedge clk) begin
        tone <= tone+1;
    end

    wire [5: 0] full_note = tone[27: 22];

    wire [2:0] octave;
    wire [3:0] note;
    divide_by12 divby12(.numer(full_note[5: 0]), .quotient(octave), .remain(note));

    reg [8: 0] clk_divider;
    always @(note)
    case(note)
        0: clk_divider = 512 - 1; // A
        1: clk_divider = 483 - 1; // A#/Bb
        2: clk_divider = 456 - 1; // B
        3: clk_divider = 431 - 1; // C
        4: clk_divider = 406 - 1; // C#/Db
        5: clk_divider = 384 - 1; // D
        6: clk_divider = 362 - 1; // D#/Eb
        7: clk_divider = 342 - 1; // E
        8: clk_divider = 323 - 1; // F
        9: clk_divider = 304 - 1; // F#/Gb
        10: clk_divider = 287 - 1; // G
        11: clk_divider = 271 - 1; // G#/Ab
        12: clk_divider = 0; // should never happen
        13: clk_divider = 0; // should never happen
        14: clk_divider = 0; // should never happen
        15: clk_divider = 0; // should never happen
    endcase

    reg [8: 0] counter_note;
    always @(posedge clk) begin
        if(counter_note==0) begin
            counter _note <= clk_divider;
        end else begin
            counter_note <= counter_note-1;
        end
    end

    reg [7: 0] counter_octave;
    always @(posedge clk) begin
        if(counter_note = 0) begin
            if(counter_octave==0) begin
                counter_octave <= (octave == 0 ? 255 :
                                   octave == 1 ? 127 :
                                   octave == 2 ? 63 :
                                   octave == 3 ? 31 :
                                   octave == 4 ? 15 : 7);
            end else begin
                counter_octave <= counter_octave - 1;
            end
        end
    end


reg speaker;
always @(posedge clk) begin
     if(counter_note = 0 && counter_octave == 0) begin
        speaker <= ~speaker;
     end
end
endmodule


module divide_by12(
    input [5: 0] numer,
    output [2:0 ] quotient,
    output [3: 0] remain
);

    reg [2: 0] quotient;
    reg [3: 0] remain_bit3_bit2;

    assign remain = {remain_bit3_bit2, numer[1: 0]};
    always @(numer[5:2]) begin
        case(numer[5:2])
            0: begin quotient = 0; remain_bit3_bit2 = 0; end
            1: begin quotient = 0; remain_bit3_bit2 = 1; end
            2: begin quotient = 0; remain_bit3_bit2 = 2; end
            3: begin quotient = 1; remain_bit3_bit2 = 0; end
            4: begin quotient = 1; remain_bit3_bit2 = 1; end
            5: begin quotient = 1; remain_bit3_bit2 = 2; end
            6: begin quotient = 2; remain_bit3_bit2 = 0; end
            7: begin quotient = 2; remain_bit3_bit2 = 1; end
            8: begin quotient = 2; remain_bit3_bit2 = 2; end
            9: begin quotient = 3; remain_bit3_bit2 = 0; end
            10: begin quotient = 3; remain_bit3_bit2 = 1; end
            11: begin quotient = 3; remain_bit3_bit2 = 2; end
            12: begin quotient = 4; remain_bit3_bit2 = 0; end
            13: begin quotient = 4; remain_bit3_bit2 = 1; end
            14: begin quotient = 4; remain_bit3_bit2 = 2; end
            15: begin quotient = 5; remain_bit3_bit2 = 0; end
        endcase
    end
endmodule
