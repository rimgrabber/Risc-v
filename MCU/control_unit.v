module ControlUnit (
    input [6:0] opcode,
    output reg Branch, MemRead, MemToReg,
    output reg [1:0] ALUOp,
    output reg MemWrite, ALUSrc, RegWrite
);
    always @(*) begin
        case(opcode)
            7'b0110011: begin // R-type
                ALUSrc = 0; MemToReg = 0; RegWrite = 1;
                MemRead = 0; MemWrite = 0; Branch = 0;
                ALUOp = 2'b10;
            end
            7'b0000011: begin // lw
                ALUSrc = 1; MemToReg = 1; RegWrite = 1;
                MemRead = 1; MemWrite = 0; Branch = 0;
                ALUOp = 2'b00;
            end
            7'b0100011: begin // sw
                ALUSrc = 1; MemToReg = 0; RegWrite = 0;
                MemRead = 0; MemWrite = 1; Branch = 0;
                ALUOp = 2'b00;
            end
            7'b1100011: begin // beq
                ALUSrc = 0; MemToReg = 0; RegWrite = 0;
                MemRead = 0; MemWrite = 0; Branch = 1;
                ALUOp = 2'b01;
            end
            default: begin
                ALUSrc = 0; MemToReg = 0; RegWrite = 0;
                MemRead = 0; MemWrite = 0; Branch = 0;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule
