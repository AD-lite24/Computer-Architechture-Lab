`timescale 1ms/1ns

module MUX_2x1(inA, inB, sel, out);

    input inA, inB, sel;
    output out;

    assign out = sel ? inA : inB;
endmodule

module MUX_8x1(in, sel, out);

    input [7:0] in;
    input [2:0] sel;
    output out;

    assign out = sel[2] ? (sel[1] ? (sel[0]?in[7]:in[6]) : (sel[0]?in[5]:in[4])) : (sel[1] ? (sel[0]?in[3]:in[2]) : (sel[0]?in[1]:in[0]));
endmodule

module MUX_ARRAY(inA, inB, sel, out);

    input [7:0] inA, inB, sel;
    output [7:0] out;

    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin : MUX_GEN
            MUX_2x1 m1(inA[i], inB[i], sel[i], out[i]);
        end
    endgenerate
endmodule

module COUNTER_3bit(clock, reset, Q);
    output [2:0] Q;
    reg [2:0] Q;
    input clock, reset;

    always @(posedge clock or posedge reset) begin
        if (reset) 
            Q <= 3'b000;
        else if (Q == 3'b111)
            Q <= 3'b000;
        else
            Q <= Q + 1;
    end
endmodule

module DECODER(A, en, out);

    input [2:0] A;
    input en;
    output [7:0] out;
    reg [7:0] out;

    always @(A) begin
        if (en) begin
            case (A) 
                3'b000: out = 8'd1;
                3'b001: out = 8'd2;
                3'b010: out = 8'd4;
                3'b011: out = 8'd8;
                3'b100: out = 8'd16;
                3'b101: out = 8'd32;
                3'b110: out = 8'd64;
                3'b111: out = 8'd128;
            endcase
        end
    end
endmodule

module MEMORY(sel, out);

    input [2:0] sel;
    output reg [7:0] out;
    reg [7:0] ram [7:0];
    initial begin
        ram[0] = 8'h01;
        ram[1] = 8'h03;
        ram[2] = 8'h07;
        ram[3] = 8'h0F;
        ram[4] = 8'h1F;
        ram[5] = 8'h3F;
        ram[6] = 8'h7F;
        ram[7] = 8'hFF;
    end

    always @* begin
        case(sel)
            3'b000: out = ram[0];
            3'b001: out = ram[1];
            3'b010: out = ram[2];
            3'b011: out = ram[3];
            3'b100: out = ram[4];
            3'b101: out = ram[5];
            3'b110: out = ram[6];
            3'b111: out = ram[7];
        endcase
    end
endmodule

module TOP_MODULE(clock, reset, out, en, sel, ram_data, count, mux_out_release, decoder_out_release);

    input clock, reset, en, mem_clock;
    input [2:0] sel;

    wire [2:0] counter_Q;
    wire [7:0] decoder_out, mem_out, mux_2_1_out, mux_out;
    output out;
    output [2:0] count;
    output [7:0] ram_data;
    output [7:0] mux_out_release, decoder_out_release;

    MEMORY mem(sel, mem_out);
    COUNTER_3bit counter(clock, reset, counter_Q);
    DECODER dec(counter_Q, en, decoder_out);
    MUX_ARRAY muxarray(decoder_out, 8'd0, mem_out, mux_out);
    MUX_8x1 mux8(mux_out, counter_Q, out);
    assign ram_data = mem_out;
    assign count = counter_Q;
    assign mux_out_release = mux_out;
    assign decoder_out_release = decoder_out;

endmodule

module testbench;

    reg clock, reset, en, mem_clock, mem_reset;
    reg [2:0] data_sel;
    wire [2:0] count;
    wire [7:0] ram_data;

    wire [7:0] mux_out_release, decoder_out_release;

    wire out;

    TOP_MODULE tm(clock, reset, out, en, data_sel, ram_data, count, mux_out_release, decoder_out_release);
    // COUNTER_3bit mem_counter(mem_clock, mem_reset, data_sel);

    always	
		#0.5 clock = ~clock;

    always @*
        // $monitor(,$time, "clock=%b, reset=%b, data_sel=%b, data=%h, count=%b, out=%b, release1=%b, release2=%b, en=%b", clock, reset, data_sel, ram_data, count, out, mux_out_release, decoder_out_release, en);
        $monitor(,$time, " ,CLK = %b, S = %b, CLEAR = %b, O = %b", clock, data_sel, reset, out);


    initial begin
        clock = 1'b0;
        mem_clock = 1'b1;
        reset = 1'b1;
        en = 1'b1;
        data_sel = 3'b000;
        // count = 3'b000;
        #1 reset = 1'b0;
        #100
        $finish;
    end
        always
        #8 data_sel = data_sel + 1;
endmodule
// gawd