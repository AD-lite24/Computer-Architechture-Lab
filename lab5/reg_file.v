module regfile(clk,reset,set,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2, reg0_init, reg1_init, reg2_init, reg3_init);

    // Write data is the control signal
    // RegWrite is also a control signal
    // Readreg1/2 are address lines of two registers
    // Write reg is the decoder o/p

    input clk, reset, set, RegWrite;
    input [31:0] reg0_init, reg1_init, reg2_init, reg3_init; // init data
    input [1:0] ReadReg1, ReadReg2, WriteReg;
    input [31:0] WriteData;

    output [31:0] ReadData1, ReadData2;

    reg [3:0] reg_clk;
    wire [3:0] decoder_out;
    reg [31:0] reg0_in, reg1_in, reg2_in, reg3_in;
    wire [31:0] reg0_out, reg1_out, reg2_out, reg3_out;

    // initial begin
    //     reg_clk = {clk, clk, clk, clk};
    //     #10
    //     reg_clk = 4'b0000;
    // end

    reg_32bit reg0(reg0_out, reg0_in, reg_clk[0], reset);
    reg_32bit reg1(reg1_out, reg1_in, reg_clk[1], reset);
    reg_32bit reg2(reg2_out, reg2_in, reg_clk[2], reset);
    reg_32bit reg3(reg3_out, reg3_in, reg_clk[3], reset);


    // logic [datawidth - 1 : 0] regs[numRegs];

    // initial begin
    //     regs[0] = 32'hAFAFAFAF;
    //     regs[1] = 32'hAAAAAAAA;
    //     regs[2] = 32'hFFFFFFFF;
    //     regs[3] = 32'hBBBBBBBB;
    // end

    decoder_2_4 dec23(WriteReg, decoder_out);

    always @(posedge clk or negedge reset) begin

        if (set) begin
            reg_clk = 4'b1111;
            reg0_in = reg0_init;
            reg1_in = reg1_init;
            reg2_in = reg2_init;
            reg3_in = reg3_init;
        end

        else begin

            reg_clk = 4'b0000;
            if (RegWrite) begin // Write to particular register

                assign reg0_in = WriteData;
                assign reg1_in = WriteData;
                assign reg2_in = WriteData;
                assign reg3_in = WriteData;

                if (clk) begin
                    if (decoder_out[0]) begin
                        reg_clk[0] <= 1'b1;
                    end
                    if (decoder_out[1]) begin
                        reg_clk[1] <= 1'b1;
                    end
                    if (decoder_out[2]) begin
                        reg_clk[2] <= 1'b1;
                    end
                    if (decoder_out[3]) begin
                        reg_clk[3] <= 1'b1;
                    end
                end
            end
        end
    end    

    mux4to1_32bit mux1(ReadData1, ReadReg1, reg0_out, reg1_out, reg2_out, reg3_out);
    mux4to1_32bit mux2(ReadData2, ReadReg2, reg0_out, reg1_out, reg2_out, reg3_out);

endmodule

module testbench;
    reg clk, reset, RegWrite, set;
    wire [31:0] ReadData1, ReadData2;
    reg [1:0] ReadReg1, ReadReg2, WriteReg;
    reg [31:0] WriteData, reg0_in, reg1_in, reg2_in, reg3_in;

    regfile file(clk, reset, set, ReadReg1, ReadReg2, WriteData, WriteReg, RegWrite, ReadData1, ReadData2, reg0_in, reg1_in, reg2_in, reg3_in);

    always 
        #5 clk = ~clk;
    
    always @(posedge clk)
        $monitor($time, " clk=%b, reset=%b, set=%b, reg1=%b RD1=%h, reg2=%b RD2=%h", clk, reset, set, ReadReg1, ReadData1, ReadReg2, ReadData2);
    
    initial begin

        reset = 1'b0;
        clk = 1'b1;
        set = 1'b0;
        #10
        reset = 1'b1;
        set = 1'b1;
        reg0_in = 32'hAFAFAFAF;
        reg1_in = 32'hFFFFFFFF;
        reg2_in = 32'hAAAAAAAA;
        reg3_in = 32'h00000000;
        #1
        set = 1'b0;

        #9
        ReadReg1 = 2'b00;
        ReadReg2 = 2'b11;

        #9
        ReadReg1 = 2'b01;
        ReadReg2 = 2'b10;
        
        #200 $finish;
    end

endmodule

module mux4to1_32bit(out, sel, in0, in1, in2, in3);
    input [31:0] in0, in1, in2, in3;
    input [1:0] sel;
    output [31:0] out;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: mux_loop
            mux4to1 m41(out[i], sel, in0[i], in1[i], in2[i], in3[i]);
        end
    endgenerate
endmodule

module mux4to1(out, sel, in0, in1, in2, in3);
    input in0, in1, in2, in3;
    input [1:0] sel;

    wire mux2to1_out1, mux2to1_out2;
    output out;

    mux2to1 m1(mux2to1_out1, sel[0], in0, in1);
    mux2to1 m2(mux2to1_out2, sel[0], in2, in3);

    mux2to1 m3(out, sel[1], mux2to1_out1, mux2to1_out2);
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

module decoder_2_4(inp, out);

    input [1:0] inp;
    output [3:0] out;

    assign out[0] = (inp == 2'b00) ? 1'b1 : 1'b0;
    assign out[1] = (inp == 2'b01) ? 1'b1 : 1'b0;
    assign out[2] = (inp == 2'b10) ? 1'b1 : 1'b0;
    assign out[3] = (inp == 2'b11) ? 1'b1 : 1'b0;
endmodule;

module reg_32bit(q, d, clock, reset);

    output [31:0] q;
    input [31:0] d;
    input clock, reset;

    wire [31:0] q_out;

    genvar i;
    generate
        for (i = 0; i < 32; i = i+1) begin
            dff_async_clear dff(d[i], reset, clock, q_out[i]);
        end
    endgenerate

    assign q = q_out;
endmodule

module dff_async_clear(d, clearb, clock, q);
    input d, clearb, clock;
    output q;
    reg q;
    
    always @ (negedge clearb or posedge clock)
    begin
        if (!clearb) q <= 1'b0;
        else q <= d;
    end

endmodule