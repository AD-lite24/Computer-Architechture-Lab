module SCDataPath();

endmodule

module data_memory(clk, mem_access_addr, mem_write_data, mem_write_en, mem_read, mem_read_data);  

    input clk, mem_write_en, mem_read;
    input [15:0] mem_access_addr, mem_write_data;
    output [15:0] mem_read_data;

    integer i;  
    reg [15:0] ram [255:0];  
    wire [7 : 0] ram_addr = mem_access_addr[8 : 1];  
    initial begin  
        for(i=0;i<256;i=i+1)  
            ram[i] <= 16'd0;  
    end  
    always @(posedge clk) begin  
        if (mem_write_en)  
            ram[ram_addr] <= mem_write_data;  
    end  
    assign mem_read_data = (mem_read==1'b1) ? ram[ram_addr]: 16'd0;  
    
endmodule 

module alu(a, b, alu_control, result, zero);

    input [15:0] a, b;
    input [2:0] alu_control;
    output [15:0] result;
    output zero;

    always @(*) begin
        case(alu_control)
        3'b000: result = a+b;
        3'b001: result = a-b;
        3'b010: result = a&b;
        3'b011: result = a|b;
        3'b100: begin if (a<b) result = 16'd1;
                        else result = 16'd0;
        end;
        default: result = a+b;
        endcase
    end
    assign zero = (result=16'd0) ? 1'b1: 1'b0;
endmodule

module control( input[2:0] opcode,  
                           input reset,  
                           output reg[1:0] reg_dst,mem_to_reg,alu_op,  
                           output reg jump,branch,mem_read,mem_write,alu_src,reg_write,sign_or_zero                      
   );  
    always @(*)  
    begin  
        if(reset == 1'b1) begin  
            reg_dst = 2'b00;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b00;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b0;  
                reg_write = 1'b0;  
                sign_or_zero = 1'b1;  
            end  
            else begin  
            case(opcode)   
            3'b000: begin // add  
                reg_dst = 2'b01;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b00;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b0;  
                reg_write = 1'b1;  
                sign_or_zero = 1'b1;  
            end  
            3'b001: begin // sli  
                reg_dst = 2'b00;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b10;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b1;  
                reg_write = 1'b1;  
                sign_or_zero = 1'b0;  
            end  
            3'b010: begin // j  
                reg_dst = 2'b00;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b00;  
                jump = 1'b1;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b0;  
                reg_write = 1'b0;  
                sign_or_zero = 1'b1;  
            end  
            3'b011: begin // jal  
                reg_dst = 2'b10;  
                mem_to_reg = 2'b10;  
                alu_op = 2'b00;  
                jump = 1'b1;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b0;  
                reg_write = 1'b1;  
                sign_or_zero = 1'b1;  
            end  
            3'b100: begin // lw  
                reg_dst = 2'b00;  
                mem_to_reg = 2'b01;  
                alu_op = 2'b11;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b1;  
                mem_write = 1'b0;  
                alu_src = 1'b1;  
                reg_write = 1'b1;  
                sign_or_zero = 1'b1;  
            end  
            3'b101: begin // sw  
                reg_dst = 2'b00;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b11;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b1;  
                alu_src = 1'b1;  
                reg_write = 1'b0;  
                sign_or_zero = 1'b1;  
            end  
            3'b110: begin // beq  
                reg_dst = 2'b00;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b01;  
                jump = 1'b0;  
                branch = 1'b1;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b0;  
                reg_write = 1'b0;  
                sign_or_zero = 1'b1;  
            end  
            3'b111: begin // addi  
                reg_dst = 2'b00;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b11;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b1;  
                reg_write = 1'b1;  
                sign_or_zero = 1'b1;  
            end  
            default: begin  
                reg_dst = 2'b01;  
                mem_to_reg = 2'b00;  
                alu_op = 2'b00;  
                jump = 1'b0;  
                branch = 1'b0;  
                mem_read = 1'b0;  
                mem_write = 1'b0;  
                alu_src = 1'b0;  
                reg_write = 1'b1;  
                sign_or_zero = 1'b1;  
            end  
        endcase  
        end  
    end  
endmodule

module register_file  
(  
    input                    clk,  
    input                    rst,  
    // write port  
    input                    reg_write_en,  
    input          [2:0]     reg_write_dest,  
    input          [15:0]     reg_write_data,  
    //read port 1  
    input          [2:0]     reg_read_addr_1,  
    output          [15:0]     reg_read_data_1,  
    //read port 2  
    input          [2:0]     reg_read_addr_2,  
    output          [15:0]     reg_read_data_2  
);  
    reg     [15:0]     reg_array [7:0];  
    // write port  
    //reg [2:0] i;  
    always @ (posedge clk or posedge rst) begin  
        if(rst) begin  
                reg_array[0] <= 16'b0;  
                reg_array[1] <= 16'b0;  
                reg_array[2] <= 16'b0;  
                reg_array[3] <= 16'b0;  
                reg_array[4] <= 16'b0;  
                reg_array[5] <= 16'b0;  
                reg_array[6] <= 16'b0;  
                reg_array[7] <= 16'b0;       
        end  
        else begin  
                if(reg_write_en) begin  
                    reg_array[reg_write_dest] <= reg_write_data;  
                end  
        end  
    end  
    assign reg_read_data_1 = ( reg_read_addr_1 == 0)? 16'b0 : reg_array[reg_read_addr_1];  
    assign reg_read_data_2 = ( reg_read_addr_2 == 0)? 16'b0 : reg_array[reg_read_addr_2];  
 endmodule   

