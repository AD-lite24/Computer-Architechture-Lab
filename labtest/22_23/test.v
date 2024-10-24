module REG_8bit(reg_out, num_in, clock, reset);

    input clock, reset;
    input [7:0] num_in;
    output reg [7:0] reg_out;

    initial reg_out = 7'd0;

    always @(posedge clock or reset) begin
        if (reset == 1'b1) 
            reg_out = 8'h00;

        else 
            reg_out <= num_in;
    end
endmodule

module EXPANSION_BOX(in, out);

    input [3:0] in;
    output [7:0] out;

    assign out[7] = in[3];
    assign out[6] = in[0];
    assign out[5] = in[1];
    assign out[4] = in[2];
    assign out[3] = in[1];
    assign out[2] = in[3];
    assign out[1] = in[2];
    assign out[0] = in[0];

endmodule

module XOR_8BIT(xout_8, xin1_8, xin2_8);

    input [7:0] xin1_8, xin2_8;
    output [7:0] xout_8;

    assign xout_8 = xin1_8 ^ xin2_8;
endmodule

module XOR_4BIT(xout_4, xin1_4, xin2_4);

    input [3:0] xin1_4, xin2_4;
    output [3:0] xout_4;

    assign xout_4 = xin1_4 ^ xin2_4;
endmodule

module CSA_4BIT(cin, inA, inB, cout, out);

    input [3:0] inA, inB;
    input cin;
    output [3:0] out;
    reg [3:0] out;
    output cout;
    reg cout;

    wire [3:0] out1, out2;
    wire cout1, cout2;

    RIPPLE_CARRY_ADDER R1(inA, inB, 1'b1, out1, cout1);
    RIPPLE_CARRY_ADDER R2(inA, inB, 1'b0, out2, cout2);

    always @* begin
        if (cin == 1'b0) begin
            out = {out2};
            cout = cout2;
        end
        else begin
            out = {out1};
            cout = cout1;
        end
    end
endmodule

module CONCAT(concat_out, concat_in1, concat_in2);
    input [3:0] concat_in1, concat_in2;
    output [7:0] concat_out;

    assign concat_out = {concat_in1, concat_in2};
endmodule

module ENCRYPT(number, key, clock, reset, enc_number, expanded_out, xor1_out, xor2_out, csa_total_out);
    input [7:0] number, key;
    input clock, reset;
    output [7:0] enc_number, expanded_out, xor1_out;
    output [3:0] xor2_out, csa_total_out;

    wire [7:0] reg_num_out, reg_key_out, expanded, xor_out;
    wire [3:0] csa_out, xor4_out;
    wire csa_cout;

    REG_8bit numreg(reg_num_out, number, clock, reset);
    REG_8bit keyreg(reg_key_out, key, clock, reset);

    EXPANSION_BOX exp(reg_num_out[3:0], expanded);

    assign expanded_out = expanded;

    XOR_8BIT xor1(xor_out, expanded, reg_key_out);
    assign xor1_out = xor_out;

    CSA_4BIT csa(reg_key_out[0], xor_out[7:4], xor_out[3:0], csa_cout, csa_out);
    assign csa_total_out = csa_out;

    XOR_4BIT xor2(xor4_out, csa_out, reg_num_out[7:4]);
    assign xor2_out = xor4_out;

    CONCAT conc(enc_number, xor4_out, reg_num_out[3:0]);
endmodule


module FULLADDER(a, b, cin, s, cout);
    input a, b, cin;
    output s, cout;

    // assign s = a ^ b ^ cin;
    // assign cout = (a&b)|(a&cin)|(b&cin);
    assign {cout, s} = a + b + cin;
endmodule

module RIPPLE_CARRY_ADDER(A, B, cin, out, cout);

    input [3:0] A, B;
    input cin;
    output [3:0] out;
    output cout;

    wire w1, w2, w3;

    FULLADDER f0(A[0], B[0], cin, out[0], w1);
    FULLADDER f1(A[1], B[1], w1, out[1], w2);
    FULLADDER f2(A[2], B[2], w2, out[2], w3);
    FULLADDER f3(A[3], B[3], w3, out[3], cout);
endmodule

module testbench;

    reg clock, reset;
    reg [7:0] num, key;
    wire [7:0] enc, expanded_out, xor1_out;
    wire [3:0] xor2_out, csa_out;

    ENCRYPT encrypter(num, key, clock, reset, enc, expanded_out, xor1_out, xor2_out, csa_out);

    always 
        #5 clock = ~clock;

    always @*
        $monitor($time, " clk=%b, reset=%b, num=%h, key=%h, enc=%h, expanded=%b, xor1=%b, csa_out=%b, xor2=%b", clock, reset, num, key, enc, expanded_out, xor1_out, csa_out, xor2_out);

    initial begin
        reset = 1'b1;
        clock = 1'b1;
        
        num = 8'b01000110;
        key = 8'b10010011;
        #1
        reset = 1'b0;

        #10
        reset = 1'b1;
        num = 8'b11001001;
        key = 8'b10101100;
        #1 reset = 1'b0;

        #20
        reset = 1'b1;
        num = 8'b10100101;
        key = 8'b01011010;
        #1 reset = 1'b0;


        #30 
        reset = 1'b1;
        num = 8'b11110000;
        key = 8'b10110001;
        #1 reset = 1'b0;
        #100 $finish;
    end
endmodule


