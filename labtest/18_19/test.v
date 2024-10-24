module ControlLogic(t0, t1, t2, s, z, x, clk, reset);

    input s, z, clk, reset, x;
    output t0, t1, t2;

    wire qt0, qt1, qt2;
    wire dt0, dt1, dt2;

    wire sbar, zbar, xbar;

    not(sbar, s);
    not(zbar, z);
    not(xbar, x);

    wire t0_and_sbar, t2_and_z;

    and(t0_and_sbar, qt0, sbar);
    and(t2_and_z, qt2, z);
    or(dt0, t0_and_sbar, t0_and_sbar, t2_and_z);


    wire t0_and_s, t2_and_xbar_and_zbar, t1_and_xbar;

    and(t0_and_s, qt0, s);
    and(t2_and_xbar_and_zbar, qt2, xbar, zbar);
    and(t1_and_xbar, qt1, xbar);
    or(dt1, t0_and_s, t2_and_xbar_and_zbar, t1_and_xbar);
    

    wire t1_and_x, t2_and_zbar_and_x;

    and(t1_and_x, qt1, x);
    and(t2_and_xbar_and_zbar, qt2, xbar, zbar);
    or(dt2, t1_and_x, t2_and_zbar_and_x);

    DFF t0out(dt0, qt0, clk, reset);
    DFF t1out(dt1, qt1, clk, reset);
    DFF t2out(dt2, qt2, clk, reset);

    assign t0 = qt0;
    assign t1 = qt1;
    assign t2 = qt2;
endmodule

module DFF(D, Q, CLK, reset);

    input D, CLK, reset;
    output reg Q;

    always @(posedge CLK or reset) begin

        if (reset) begin
            Q = 1'b0;
        end

        else begin
            if (D)
                Q = 1'b1;
            else 
                Q = 1'b0;
        end
    end
endmodule;

module TFF(T, Q, clock, reset);

    input T, clock, reset;
    output reg Q;

    always @(posedge clock) begin
        if (reset)
            Q <= 1'b0;
        else begin
            if (T)
                Q <= ~Q;
        end
    end
endmodule

module COUNTER_4bit(Q, clk, reset, en);

    input clk, reset, en;
    output [3:0] Q;
    reg [3:0] q_count_bar;

    wire clock;

    wire [3:0] q_count;
    wire q0_and_q1, wire_and_q2;

    assign clock = clk & en;

    TFF t0(1'b1, q_count[0], clock, reset);
    TFF t1(q_count[0], q_count[1], clock, reset);

    and(q0_and_q1, q_count[0], q_count[1]);

    TFF t2(q0_and_q1, q_count[2], clock, reset);

    and(wire_and_q2, q0_and_q1, q2);

    TFF t3(wire_and_q2, q_count[3], clock, reset);
    
    assign Q = {q_count};
endmodule

module INTG(count_final, g, s, clk, x, enout);

    input s, clk, x;
    output g, enout;
    output [3:0] count_final;

    wire [3:0] count;
    wire [2:0] t;
    wire en, sync_clear, z;

    assign en = (t[1] & x) | (t[2] & ~z & x);
    assign sync_clear = t[0] & s;

    COUNTER_4bit counter(count, clk, sync_clear, en);
    assign z = count[0]&count[1]&count[2]&count[3];

    ControlLogic ctrlogic(t[0], t[1], t[2], s, z, x, clk, 1'b0); // reset bit was set to 0 assuming counter is never reset

    wire t2_and_z;
    assign t2_and_z = t[2] & z;
    assign enout = en;

    DFF finalff(t2_and_z, g, clk, sync_clear);

    assign count_final = {count};

endmodule

module testbench;

    reg s, x, clk;
    wire [3:0] count;
    wire g, en;

    always 
        #0.5 clk = ~clk;

    INTG mod(count, g, s, clk, x, en);

    always@(*)  
        $monitor($time," clk=%b, s = %b, x = %b, q = %d, g = %b, en=%b",clk, s, x, count, g, en);

    initial begin
        s = 1'b0;
        x = 1'b0;
        clk = 1'b0;

        #5 
        s = 1'b1;
        x = 1'b1;

        #30
        x = 1'b0;

        #100
        $finish;
    end

    

endmodule