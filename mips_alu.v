module bit32AND (out,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    assign {out}=in1 & in2;
endmodule

module bit32NOT(out, in);
    input [31:0] in;
    output [31:0] out;
    assign out = ~in;
endmodule

module bit32OR (out, in1, in2);
    input [31:0] in1, in2;
    output [31:0] out;
    assign {out} = in1 | in2;
endmodule

module bit32FA (in0, in1, cin, sum, cout);
    input [31:0] in0, in1;
    input cin;
    output [31:0] sum;
    output cout;
    assign {cout, sum} = in0 + in1 + cin;
endmodule

module bit32_2to1mux(out,sel,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    input sel;
    genvar j;
    //this is the variable that is be used in the generate
    //block
    generate 
        for (j=0; j<32;j=j+1) begin: mux_loop
        //mux_loop is the name of the loop
        mux2to1 m1(out[j],sel,in1[j],in2[j]);
        //mux2to1 is instantiated every time it is called
        end
    endgenerate
endmodule

module mux2to1(out,sel,in1,in2);
    input in1,in2,sel;
    output out;
    wire not_sel,a1,a2;
    not (not_sel,sel);
    and (a1,sel,in2);
    and (a2,not_sel,in1);
    or(out,a1,a2);
endmodule

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

module fourToOneMux(sel, inputs, outputs); 
  
    input [3:0] inputs; 
    input [1:0] sel; 
    output outputs; 
  
    wire a, b, c, d, s1, s2; 
  
    not n1(s1, sel[0]); 
    not n2(s2, sel[1]); 
  
    and a1(a, inputs[0], s2, s1); 
    and a2(b, inputs[1], s2, sel[0]); 
    and a3(c, inputs[2], sel[1], s1); 
    and a4(d, inputs[3], sel[1], sel[0]); 
  
    or o1(outputs, a, b, c, d); 
  
endmodule

// module binvert (out, in, op):
//     input [31:0] in;
//     input op;
//     output [31:0] out;
//     wire [31:0] not_in;

//     // 0 is add 1 is subtract
//     bit32_2to1mux bm1(out, op, in, not_in);
// endmodule

module ALU(a, b, bin, op, cin, res, cout);
    input [31:0] a, b;
    input [1:0] op;
    input bin, cin;

    output [31:0] res;
    output cout;

    wire [31:0] not_b, b_fa_input, out_and, out_or, out_fa;

    bit32NOT b32n1(not_b, b);
    bit32_2to1mux bm1(b_fa_input, bin, b, not_b);

    bit32AND ba1(out_and, b_fa_input, a);
    bit32OR bo1(out_or, b_fa_input, a);
    bit32FA bfa1(a, b_fa_input, cin, out_fa, cout);

    mux4to1_32bit m1(res, op, out_and, out_or, out_fa, 0);
endmodule

module tbALU;
    reg Binvert, Carryin;
    reg [1:0] Operation;
    reg [31:0] a,b;
    wire [31:0] Result;
    wire CarryOut;

    ALU a1(a, b, Binvert, Operation, Carryin, Result, CarryOut);

    initial
        $monitor(,$time," a=%h, b=%h, op=%b, bin=%b, cin=%b, res=%h, cout=%b", a, b, Operation, Binvert, Carryin, Result, CarryOut);

    initial
    begin
        a=32'ha5a5a5a5;
        b=32'h5a5a5a5a;
        Operation=2'b00;
        Binvert=1'b0;
        Carryin=1'b0; //must perform AND resulting in zero
        #100 Operation=2'b01; //OR
        #100 Operation=2'b10; //ADD
        #100 Binvert=1'b1;//SUB
        Carryin = 1'b1;
        #200 $finish;
    end
endmodule

















