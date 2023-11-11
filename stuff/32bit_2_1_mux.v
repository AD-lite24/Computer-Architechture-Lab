module bit32_2to1mux(out,sel,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    input sel;
    genvar j;
    //this is the variable that is be used in the generate
    //block
    generate for (j=0; j<32;j=j+1) begin: mux_loop
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

