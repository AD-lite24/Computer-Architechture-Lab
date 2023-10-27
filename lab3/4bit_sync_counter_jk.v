module jk_ff(j, k, clock, reset, q, qn);

    input j, k, clock, reset;
    output q, qn;
    reg q, qn;

    always @(posedge clock or posedge reset) begin

        if (reset) begin
            q <= 1'b0;
            qn <= 1'b0;
        end

        else begin

            if (j & k) begin
                q <= ~q;
                qn <= ~qn;
            end 

            else if (j) begin
                q <= 1'b1;
                qn <= 1'b0;
            end

            else if (k) begin
                q <= 1'b0;
                qn <= 1'b1;
            end
        end
    end
endmodule

module sync_counter_4bit(clock, reset, q);

    input clock, reset;
    output [3:0] q;
    wire [3:0] q;
    wire [3:0] qn;
    wire and1, and2;

    // initial begin
    //     q = 4'b0000;
    //     qn = 4'b1111;
    // end


    jk_ff ff0(1'b1, 1'b1, clock, reset, q[0], qn[0]);
    jk_ff ff1(q[0], q[0], clock, reset, q[1], qn[1]);

    assign and1 = q[0] & q[1];

    jk_ff ff2(and1, and1, clock, reset, q[2], q[2]);

    assign and2 = q[2] & and1;

    jk_ff ff3(and2, and2, clock, reset, q[3], q[3]);

endmodule

module testbench;

    reg clock;
    reg reset;
    wire [3:0] Q;

    sync_counter_4bit sync(clock, reset, Q);

    initial clock = 0;

    always
        #2 clock = ~clock;

    always @(posedge clock)
        $display($time, " Q=%b, clk=%b", Q, clock);

    initial begin
        reset = 1;
        #1 reset = 0;
        #50 $finish;
    end
endmodule
