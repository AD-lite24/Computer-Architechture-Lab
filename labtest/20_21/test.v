module RSFF(S, R, Q, Qn, clock, reset);

    input S, R, clock, reset;
    output reg Q, Qn;

    always @(posedge clock or reset) begin
        if (reset) begin
            Q = 1'b0;
        end else begin
            if (R) 
                Q = 1'b0;
            else if (S)
                Q = 1'b1;
        end

        Qn = ~Q;
    end
endmodule

module DFF(D, Q, Qn, clock, reset);

    input D, clock, reset;
    output Q, Qn;

    RSFF ff(D, ~D, Q, Qn, clock, reset);
endmodule

module D_FF_Barge(input d, output reg q, qn, input clock, input reset);
    always @(reset)
        if (reset) begin
            q<= 1'b0;
            qn<= 1'b1;
        end
    
    always @(posedge clock) begin
        q <= d;
        qn <= ~d;
    end
endmodule

module RIPPLE_COUNTER(clock, reset, Q_count);

    input clock, reset;
    output [3:0] Q_count;

    wire [3:0] q, qn;

    DFF ff0(qn[0], q[0], qn[0], clock, reset);
    DFF ff1(qn[1], q[1], qn[1], qn[0], reset);
    DFF ff2(qn[2], q[2], qn[2], qn[1], reset);
    DFF ff3(qn[3], q[3], qn[3], qn[2], reset);

    assign Q_count = {q[3], q[2], q[1], q[0]};

    // initial $monitor($time, " %b %b", q, qn);

endmodule

module MEM1(address, data, parity);

    input [2:0] address;
    output reg [7:0] data;
    output reg parity;

    always @(*) begin
        case (address)

            3'b000 : begin
                data = 8'h1f;
                parity = 1;
            end
            3'b001 : begin
                data = 8'h31;
                parity = 1;
            end
            3'b010 : begin
                data = 8'h53;
                parity = 1;
            end
            3'b011 : begin
                data = 8'h75;
                parity = 1;
            end
            3'b100 : begin
                data = 8'h97;
                parity = 1;
            end
            3'b101 : begin
                data = 8'hb9;
                parity = 1;
            end
            3'b110 : begin
                data = 8'hdb;
                parity = 1;
            end
            3'b111 : begin
                data = 8'hfd;
                parity = 1;
            end
        
            default : begin
                data = 8'bxxxx_xxxx;
                parity = 1'bx;
            end
        endcase
    end
endmodule;

module MEM2(address, data, parity);

    input [2:0] address;
    output reg [7:0] data;
    output reg parity;

    always @(*) begin
        case (address)

            3'b000 : begin
                data = 8'h00;
                parity = 0;
            end
            3'b001 : begin
                data = 8'h22;
                parity = 0;
            end
            3'b010 : begin
                data = 8'h44;
                parity = 0;
            end
            3'b011 : begin
                data = 8'h66;
                parity = 0;
            end
            3'b100 : begin
                data = 8'h88;
                parity = 0;
            end
            3'b101 : begin
                data = 8'haa;
                parity = 0;
            end
            3'b110 : begin
                data = 8'hcc;
                parity = 0;
            end
            3'b111 : begin
                data = 8'hee;
                parity = 0;
            end
        
            default : begin
                data = 8'bxxxx_xxxx;
                parity = 1'bx;
            end
        endcase
    end
endmodule;

module MUX16to8(in1, in0, sel, out);

    input [7:0] in1, in0;
    input sel;
    output [7:0] out;

    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin
            MUX2to1 mux(in1[i], in0[i], sel, out[i]);
        end
    endgenerate

endmodule;

module MUX2to1(in1, in0, sel, out);

    input in1, in0, sel;
    output out;

    assign out = sel ? in1 : in0;
endmodule;
    

module FETCH_DATA(Q_count, data, parity);

    input [3:0] Q_count;
    output [7:0] data;
    output parity;

    wire [2:0] address;
    wire sel;

    assign address = {Q_count[2:0]};
    assign sel = Q_count[3];

    // bank2 is put in input 1 and bank 1 is put in input 0 for mux
    // same for parity

    wire [7:0] bank1_out, bank2_out;
    wire parity1, parity2;

    MEM1 mem1(address, bank1_out, parity1);
    MEM2 mem2(address, bank2_out, parity2);

    MUX16to8 mux_data(bank2_out, bank1_out, sel, data);
    MUX2to1 mux_parity(parity2, parity1, sel, parity);

endmodule

module PARITY_CHECKER(data, parity, result, detect);
    input [7:0] data;
    input parity;
    output reg result, detect;

    // assign detect = (data[0]^data[1]^data[2]^data[3]^data[4]^data[5]^data[6]^data[7]) == parity;
    
    always @(*)
        detect = data[0]^data[1]^data[2]^data[3]^data[4]^data[5]^data[6]^data[7];
                     
    always @(*) begin
        if (parity == detect)
            result = 1'b1;
        else
            result = 1'b0;
    end
endmodule

module DESIGN(clock, reset, count, data, store_parity, detected_parity, match);

    input clock, reset;
 
    output [3:0] count;
    output [7:0] data;
    output store_parity, detected_parity, match;

    wire [3:0] count_wire;
    wire [7:0] data_wire;
    wire store_parity_wire, detected_parity_wire, match_wire;

    RIPPLE_COUNTER counter(clock, reset, count_wire);
    FETCH_DATA fetchdata(count_wire, data_wire, store_parity_wire);
    PARITY_CHECKER checker(data_wire, store_parity_wire, match_wire, detected_parity_wire);

    assign count = count_wire;
    assign data = data_wire;
    assign store_parity = store_parity_wire;
    assign detected_parity = detected_parity_wire;
    assign match = match_wire;

endmodule

module testbench;
    reg clock, reset;

    wire [3:0] count;
    wire [7:0] data;
    wire store_parity, detected_parity, match;

    DESIGN desi(clock, reset, count, data, store_parity, detected_parity, match);

    always @(*)
        $monitor(,$time, " clk=%b, reset=%b, counter_op=%b, store_data=%h, store_parity=%b, detected_parity=%b, match=%b",
                            clock, reset, count, data, store_parity, detected_parity, match);

    always
        #0.5 clock = ~clock;
    
    initial begin
        // $dumpfile("test.vcd");
        // $dumpvars();
        reset = 1'b1;
        clock = 1'b0;
        #0.5 reset = 1'b0;

        #32 $finish;
    end
endmodule



