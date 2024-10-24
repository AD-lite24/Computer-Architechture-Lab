`timescale 1ms/1ns

module REG1(
    input clk, en,
    input [3:0] numin,
    output [3:0] numout
);
    reg [3:0] ram;

    always @(posedge clk) begin
        if (en)
            ram = numin;
    end

    assign numout = ram;
endmodule

module ROTATOR(
    input clk, en,
    input [3:0] num,
    output reg [3:0] numrotated
);

    reg tracker;

    initial begin
        tracker = 1'b0;
    end

    always @(posedge clk) begin
        if (en) begin
            if (tracker) begin
                numrotated = {numrotated[0], numrotated[3:1]};
                tracker = 1'b0;
            end
            else begin
                numrotated = {num[0], num[3:1]};
                tracker = 1'b1;
            end
        end 
    end

endmodule

module testbench;

    reg clk, en;
    reg [3:0] in_num;

    wire [3:0] out_num;

    ROTATOR rotate(clk, en, in_num, out_num);

    always 
        #0.5 clk = ~clk;

    initial
        $monitor(,$time, " clk=%b, en=%b, in_num=%b, out_num=%b", clk, en, in_num, out_num);

    initial begin
        clk = 1'b1;
        en = 1'b1;
        in_num = 4'b1010;
        
        #5 
        in_num = 4'b0011;

        #50 $finish;
    end
endmodule



