module DECODER(d0, d1, d2, d3, d4, d5, d6, d7, x, y, z);

    input x, y, z;
    output d0, d1, d2, d3, d4, d5, d6, d7;

    wire nx, ny, nz;

    not (nx, x);
    not (ny, y);
    not (nz, z);

    and (d0, nx, ny, nz);
    and (d1, nx, ny, z);
    and (d2, nx, y, nz);
    and (d3, nx, y, z);
    and (d4, x, ny, nz);
    and (d5, x, ny, z);
    and (d6, x, y, nz);
    and (d7, x, y, z);

endmodule 

module FADDER(s, c, x, y, z);

    input x, y, z;
    output s, c;
    
    wire a0, a1, a2, a3, a4, a5, a6, a7;

    DECODER decoder(a0, a1, a2, a3, a4, a5, a6, a7, x, y, z);

    or (s, a1, a2, a4, a7);
    or (c, a3, a5, a6, a7);

endmodule

module testbench;

    reg x, y, z;
    wire s, c;
    FADDER fadder(s, c, x, y, z);
    initial
        $monitor(,$time," x=%b,y=%b,z=%b,s=%b,c=%b", x, y, z, s, c);
    initial
        begin
            #0 x=1'b0;y=1'b0;z=1'b0;
            #4 x=1'b1;y=1'b0;z=1'b0;
            #4 x=1'b0;y=1'b1;z=1'b0;
            #4 x=1'b1;y=1'b1;z=1'b0;
            #4 x=1'b0;y=1'b0;z=1'b1;
            #4 x=1'b1;y=1'b0;z=1'b1;
            #4 x=1'b0;y=1'b1;z=1'b1;
            #4 x=1'b1;y=1'b1;z=1'b1;
        end

endmodule







