module oneBitFullAdderGateModel(numA, numB, CarryIn, Sum, CarryOut);
    input numA, numB, CarryIn;
    output Sum, CarryOut;
    wire xorVal, andVal1, andVal2;


    xor x1(xorVal, numA, numB);
    and a1(andVal1, numA, numB);
    and a2(andVal2, CarryIn, xorVal);
    xor x2(Sum, CarryIn, xorVal);
    or o1(CarryOut, andVal1, andVal2);

endmodule

module FourbitAdder(out, in1, in2, cin, cout);

    input [0:3] in1;
    input [0:3] in2;
    input cin;

    output [0:3] out;
    output cout;

    wire c0, c1, c2;

    // xor x1(xor1, in2[0], cin);
    // xor x2(xor2, in2[1], cin);
    // xor x3(xor3, in2[2], cin);
    // xor x4(xor4, in2[3], cin);

    oneBitFullAdderGateModel fad1(in1[3], in2[3], cin, out[3], c0);
    oneBitFullAdderGateModel fad2(in1[2], in2[2], c0, out[2], c1);
    oneBitFullAdderGateModel fad3(in1[1], in2[1], c1, out[1], c2);
    oneBitFullAdderGateModel fad4(in1[0], in2[0], c2, out[0], cout);


endmodule

// module testbench;
//     reg [0:3] A;
//     reg [0:3] B;
//     reg cin;

//     wire [0:3] sum;
//     wire cout;

//     FourbitAdder add(sum, A, B, cin, cout);

//     initial begin
//         // $monitor(,$time," A = %b, B = %b, Cin = %b, S = %b, Cout = %b", A, B, Cin, S, Cout);

//         $display(,$time,"A = %s, B = %s, Cin = %b", A, B, cin);
//         $display(,$time,"Sum = %s, cout = %b", sum, cout);

        
//         #0 A=1'b0; B=1'b0; Cin=1'b0;
//         #1 A=1'b0; B=1'b1; Cin=1'b0;
//         #1 A=1'b1; B=1'b0; Cin=1'b0;
//         #1 A=1'b1; B=1'b1; Cin=1'b0;
        
//         #1 A=1'b0; B=1'b0; Cin=1'b1;
//         #1 A=1'b0; B=1'b1; Cin=1'b1;
//         #1 A=1'b1; B=1'b0; Cin=1'b1;
//         #1 A=1'b1; B=1'b1; Cin=1'b1;

//         #1 $finish;
//     end

// endmodule

module testbench;

    reg [3:0] A;
    reg [3:0] B;
    reg Cin;
    wire [3:0] S;
    wire Cout;

    FourbitAdder add(S, A, B, Cin, Cout);

    initial begin
        $monitor(,$time," A = %b, B = %b, Cin = %b, S = %b, Cout = %b", A, B, Cin, S, Cout);
        
        #0 A=4'b0000; B=4'b0000; Cin=1'b0;
        #1 A=4'b0000; B=4'b0000; Cin=1'b1;

        #1 A=4'b0001; B=4'b0000; Cin=1'b0;
        #1 A=4'b0001; B=4'b0000; Cin=1'b1;

        #1 A=4'b0001; B=4'b0001; Cin=1'b0;
        #1 A=4'b0001; B=4'b0001; Cin=1'b1;

        #1 A=4'b0010; B=4'b0001; Cin=1'b0;
        #1 A=4'b0010; B=4'b0001; Cin=1'b1;

        #1 A=4'b0011; B=4'b0110; Cin=1'b0;
        #1 A=4'b0011; B=4'b0110; Cin=1'b1;

        #1 A=4'b1110; B=4'b1100; Cin=1'b0;
        #1 A=4'b1110; B=4'b1100; Cin=1'b1;

        #1 $finish;
    end

endmodule