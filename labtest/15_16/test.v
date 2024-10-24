module MUX_16_entries(x, out);

    input [3:0] x;
    output reg [8:0] out;

    reg [8:0] inputs [15:0];

    integer i;
    initial begin
        for (i=0; i<16; i=i+1)
            inputs[i] = 25*i;
    end

    always @(*) begin
        out = inputs[x];
    end
endmodule

module ADDER_REGISTER(acc_rst1, acc_rst2, clock, y, muxval);

    input acc_rst1, acc_rst2, clock;
    input [8:0] muxval;
    output [12:0] y;

    reg [12:0] acc;

    initial 
        acc = 13'b0;

    always @(posedge clock) begin
        if (acc_rst1 == 1)
            acc = acc + {4'b0, muxval};
        else
            acc = acc;
    end

    always @(posedge acc_rst2 or negedge acc_rst2)
        acc = 13'b0;
    
    assign y = acc;

endmodule

module DFF(
    input clock, d, reset,
    output reg q
);

    always @(posedge clock or reset) begin
        if (reset)
            q = 1'b0;
        else
            q = d;
    end

endmodule

module ACC_RST(
    input clock, reset,
    output acc_rst1, acc_rst2,
    output [3:0] q_count
);
    wire [3:0] q;
    DFF d0(clock, ~q[0], reset, q[0]);
    DFF d1(q[0], ~q[1], reset, q[1]);
    DFF d2(q[1], ~q[2], reset, q[2]);
    DFF d3(q[2], ~q[3], reset, q[3]);

    assign q_count = {q[3], q[2], q[1], q[0]};
    assign acc_rst1 = q[2];
    assign acc_rst2 = q[3];

    // always @(*)
    //     $display($time, "clk=%b, count=%d, rst1=%b, rst2=%b", clock, q_count, acc_rst1, acc_rst2);

endmodule

module INTG(
    input clock, reset,
    input [3:0] x,
    output [12:0] y,
    output [3:0] q_count
);
    wire acc_rst1, acc_rst2;
    ACC_RST accreset(clock, reset, acc_rst1, acc_rst2, q_count);

    wire [8:0] mux_out;
    MUX_16_entries mux(x, mux_out);

    ADDER_REGISTER addreg(acc_rst1, acc_rst2, clock, y, mux_out);
endmodule

module testbench;

    reg clock, reset;
    reg [3:0] x;
    wire [12:0] y;
    wire [3:0] q_count;
    INTG integrator(clock, reset, x, y, q_count);

    always
        #0.5 clock = ~clock;

    always @(*)
        $monitor(,$time, " clk=%b, rst=%b, x=%b, y=%h, count=%d", clock, reset, x, y, q_count);

    initial begin
        clock = 1'b0;
        reset = 1'b1;

        #1
        reset = 1'b0;
        x = 4'd10;
        #1 x = 4'd5;
        #1 x = 4'd12;
        #1 x = 4'd1;

        #1 x = 4'd13;
        #1 x = 4'd7;
        #1 x = 4'd9;
        #1 x = 4'd2;

        #1 x = 4'd11;
        #1 x = 4'd5;
        #1 x = 4'd4;
        #1 x = 4'd2;

        #10 $finish;
    end
endmodule




