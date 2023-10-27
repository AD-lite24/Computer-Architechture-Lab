module reg_32bit(q, d, clock, reset);

    output [31:0] q;
    input [31:0] d;
    input clock, reset;

    wire [31:0] q_out;

    genvar i;
    generate
        for (i = 0; i < 32; i = i+1) begin
            dff_sync_clear dff(d[i], reset, clock, q_out[i]);
        end
    endgenerate

    assign q = q_out;
endmodule

module tb32reg;

    reg [31:0] d;
    reg clk, reset;
    wire [31:0] q;
    reg_32bit R(q,d,clk,reset);

    always @(clk)
        #5 clk<=~clk;

    always @(posedge clk)
        $display($time, " clk=%b, reset=%b, q=%b", clk, reset, q);

    initial begin
        clk= 1'b1;
        reset=1'b0;//reset the register
        #20 reset=1'b1;
        #0 d=32'hAFAFAFAF;
        #200 $finish;
    end

endmodule

module dff_sync_clear(d, clearb, clock, q);

    input d, clearb, clock;
    output q;
    reg q;

    always @ (posedge clock)
    begin
        if (!clearb) q <= 1'b0;
        else q <= d;
    end
endmodule