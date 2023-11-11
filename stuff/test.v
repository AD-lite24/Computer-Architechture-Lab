module bcd_to_gray(a1, a2, a3, a4, g2, g3, g4);
    input a1, a2, a3, a4;
    output g2, g3, g4;
    
    xor x1(g4, a3, a4);
    xor x2(g3, a3, a2);
    xor x3(g2, a2, a1);

endmodule

module testbench;
    reg a1, a2, a3, a4;
    wire b2, b3, b4;
    bcd_to_gray bcd(a1, a2, a3, a4, b2, b3, b4);
    initial begin
        $monitor (,$time," a1=%b, a2=%b, a3=%b a4=%b \n b1=%b, b2=%b, b3=%b, b4=%b", a1, a2, a3, a4, a1, b2, b3, b4);

        #0 a1=1'b0;a2=1'b0;a3=1'b0;a4=1'b0;
        #2 a1=1'b0;a2=1'b0;a3=1'b0;a4=1'b1;
        #4 a1=1'b1;a2=1'b1;a3=1'b0;a4=1'b0;
        #100 $finish;
    end
endmodule