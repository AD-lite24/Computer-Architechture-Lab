module MUX_SMALL(in0, in1, sel, out);

    input in0, in1, sel;
    output out;

    assign out = in1 ? sel : in0;

endmodule

module MUX_BIG(in, sel, out);

    input [7:0] in;
    input [2:0] sel;
    output out;

    wire [3:0] layer0outs;
    wire [1:0] layer1outs; 

    MUX_SMALL layer0mux1(in[0], in[1], sel[0], layer0outs[0]);
    MUX_SMALL layer0mux2(in[2], in[3], sel[0], layer0outs[1]);
    MUX_SMALL layer0mux3(in[4], in[5], sel[0], layer0outs[2]);
    MUX_SMALL layer0mux4(in[6], in[7], sel[0], layer0outs[3]);

    MUX_SMALL layer1mux1(layer0outs[0], layer0outs[1], sel[1], layer1outs[0]);
    MUX_SMALL layer1mux2(layer0outs[2], layer0outs[3], sel[1], layer1outs[1]);

    MUX_SMALL layer2mux1(layer1outs[0], layer1outs[1], sel[2], out);

endmodule

module TFF(t, q, clock, clear);

    input t, clock, clear;
    output reg q;

    always@(posedge clock or clear) begin
        if (clear)
            q <= 1'b0;
        else begin
            if (t)
                q <= ~q;
            else    
                q <= q;
        end
    end

endmodule

module COUNTER_4BIT(q_out, clock, clear);

    input clock, clear;
    output [3:0] q_out;

    wire [3:0] q;

    TFF t0(1'b1, q[0], clock, clear);
    TFF t1(q[0], q[1], clock, clear);

    wire and1;
    assign and1 = q[0]&q[1];
    TFF t2(and1, q[2], clock, clear);

    wire and2;
    assign and2 = and1&q[2];

    TFF t3(and2, q[3], clock, clear);

    assign q_out = {q};
endmodule

module COUNTER_3BIT(q_out, clock, clear);

    input clock, clear;
    output [2:0] q_out;

    wire [3:0] q_temp;

    COUNTER_4BIT tempcounter(q_temp, clock, clear);

    assign q_out = {q_temp[2], q_temp[1], q_temp[0]};
endmodule

module MEMORY(in, out);

    input [3:0] in;
    output reg [7:0] out;

    reg [15:0] ram [7:0];

    always@(*) begin
        if (in[0])
            out = 8'hcc;
        else
            out = 8'haa;
    end
endmodule

module INTG(clock, clear, out, q3count, q4count);

    input clock, clear;
    output out;
    output [3:0] q4count;
    output [2:0] q3count;

    wire [2:0] q_3count;
    wire and_output;
    wire [3:0] q_4count;
    wire [7:0] mem_out;

    COUNTER_3BIT counter3bit(q_3count, clock, clear);
    and(and_output, q_3count[2], q_3count[1], q_3count[0]);

    COUNTER_4BIT counter(q_4count, and_output, clear);

    MEMORY mem(q_4count, mem_out);

    MUX_BIG muxbig(mem_out, q_3count, out);

    assign q3count = {q_3count};
    assign q4count = {q_4count};

endmodule


module testbench;

    reg clock, clear;

    wire [2:0] count;
    wire out;

    wire [3:0] q4count;
    wire [2:0] q3count;

    INTG integrator(clock, clear, out, q3count, q4count);

    always
        #0.5 clock = ~clock;

    initial 
        $monitor($time, " clock=%b, clear=%b, out=%b, count3=%b, count4=%b", clock, clear, out, q3count, q4count);
        // $monitor(,$time, " clock=%b, clear=%b, in=%b, out=%b", clock, clear, in, out);


    initial begin
        clock = 1'b0;
        clear = 1'b1;

        #1 clear = 1'b0;

        // #5 in = 4'b0000;
        // #5 in = 4'b0101;
        #200
        $finish;
    end
endmodule