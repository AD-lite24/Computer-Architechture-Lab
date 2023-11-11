module mux4to1_gate(out, in, sel);
input [0:3] in;
input [0:1] sel;

output out;

wire n1, n0, a1, a2, a3, a4;

not n(n1, sel[1]);
not nn(n0, sel[0]);

and (a1, in[0], n1, n0);
and (a2, in[1], n1, sel[0]);
and (a3, in[2], sel[1], n0);
and (a4, in[3], sel[0], sel[1]);

or or1(out, a1, a2, a3, a4);

endmodule


module mux16to1(out, in, sel);

input [0:15] in;
input [0:3] sel;

output out;

wire [0:3] ma;

mux4to1_gate m0(ma[0], in[0:3], sel[0:1]);
mux4to1_gate m1(ma[1], in[4:7], sel[0:1]);
mux4to1_gate m2(ma[2], in[8:11], sel[0:1]);
mux4to1_gate m3(ma[3], in[12:15], sel[0:1]);

mux4to1_gate m4(out, ma, sel[2:3]);

endmodule

module test_mux_16;

    reg [0:15] in;
    reg [0:3] sel;
    wire out;

    mux16to1 mux(out, in, sel);
    
    initial
    begin 
        $monitor("in=%b | sel=%b | out=%b", in, sel, out);
    end

    initial
    begin
        in=16'b1000000000000000; sel=4'b0000;
        #3 in=16'b0100000010000000; sel=4'b0001;
        #3 in=16'b0010100000000000; sel=4'b0010;
        #3 in=16'b0001000000000000; sel=4'b0011;
        #3 in=16'b0000100000000000; sel=4'b0100;
        #3 in=16'b0000010000000000; sel=4'b0101;    
        #3 in=16'b0000001000000000; sel=4'b0110;
        #3 in=16'b0000000100000000; sel=4'b0111;
        #3 in=16'b0000000010000000; sel=4'b1000;
        #3 in=16'b0000000001000000; sel=4'b1001;
        #3 in=16'b0000000000100000; sel=4'b1010;
        #3 in=16'b0000000000010000; sel=4'b1011;
        #3 in=16'b0000000000001000; sel=4'b1100;
        #3 in=16'b0000000000000100; sel=4'b1101;
        #3 in=16'b0000000000000010; sel=4'b1110;
        #3 in=16'b0000000000000001; sel=4'b1111;    
    end

endmodule
