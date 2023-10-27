module mux4to1_32bit(out, sel, in0, in1, in2, in3);
    input [31:0] in0, in1, in2, in3;
    input [1:0] sel;
    output [31:0] out;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: mux_loop
            mux4to1 m41(out[i], sel, in0[i], in1[i], in2[i], in3[i]);
        end
    endgenerate
endmodule

module mux4to1(out, sel, in0, in1, in2, in3);
    input in0, in1, in2, in3;
    input [1:0] sel;

    wire mux2to1_out1, mux2to1_out2;
    output out;

    mux2to1 m1(mux2to1_out1, sel[0], in0, in1);
    mux2to1 m2(mux2to1_out2, sel[0], in2, in3);

    mux2to1 m3(out, sel[1], mux2to1_out1, mux2to1_out2);
endmodule

module decoder_2_4(inp, out);

    input [1:0] inp;
    output [3:0] out;

    assign out[0] = (inp == 2'b00) ? 1'b1 : 1'b0;
    assign out[1] = (inp == 2'b01) ? 1'b1 : 1'b0;
    assign out[2] = (inp == 2'b10) ? 1'b1 : 1'b0;
    assign out[3] = (inp == 2'b11) ? 1'b1 : 1'b0;
endmodule;