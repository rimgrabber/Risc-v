module Datapath (
    input clk, reset
);
    // === Program Counter ===
    reg [31:0] PC;
    wire [31:0] PC_next;
    wire [31:0] instruction;

    // === IF Stage ===
    InstructionMemory imem(.addr(PC), .instruction(instruction));

    // IF/ID pipeline registers
    reg [31:0] IF_ID_PC, IF_ID_Instruction;

    // === ID Stage ===
    wire [6:0] opcode = IF_ID_Instruction[6:0];
    wire [4:0] rs1 = IF_ID_Instruction[19:15];
    wire [4:0] rs2 = IF_ID_Instruction[24:20];
    wire [4:0] rd  = IF_ID_Instruction[11:7];

    wire [31:0] readData1, readData2;
    wire [31:0] imm = {{20{IF_ID_Instruction[31]}}, IF_ID_Instruction[31:20]}; // I-type

    RegisterFile rf(
        .clk(clk),
        .regWrite(RegWrite_WB),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd_WB),
        .writeData(writeData_WB),
        .readData1(readData1),
        .readData2(readData2)
    );

    wire Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    ControlUnit cu(
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    // ID/EX pipeline registers
    reg [31:0] ID_EX_PC, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm;
    reg [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    reg [1:0] ID_EX_ALUOp;
    reg ID_EX_ALUSrc, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemToReg, ID_EX_RegWrite;

    // === EX Stage ===
    wire [31:0] ALU_in2 = ID_EX_ALUSrc ? ID_EX_Imm : ID_EX_ReadData2;
    wire [31:0] ALU_result;
    wire ALU_zero;

    wire [3:0] ALU_control;
    assign ALU_control = (ID_EX_ALUOp == 2'b10) ? 4'b0010 : 4'b0000; // Simplified: use add for R-type

    ALU alu(
        .A(ID_EX_ReadData1),
        .B(ALU_in2),
        .ALU_Control(ALU_control),
        .ALU_Result(ALU_result),
        .Zero(ALU_zero)
    );

    // EX/MEM pipeline registers
    reg [31:0] EX_MEM_ALUResult, EX_MEM_WriteData;
    reg [4:0] EX_MEM_Rd;
    reg EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_MemToReg, EX_MEM_RegWrite;

    // === MEM Stage ===
    wire [31:0] readData_mem;
    DataMemory dmem(
        .clk(clk),
        .addr(EX_MEM_ALUResult),
        .writeData(EX_MEM_WriteData),
        .memWrite(EX_MEM_MemWrite),
        .memRead(EX_MEM_MemRead),
        .readData(readData_mem)
    );

    // MEM/WB pipeline registers
    reg [31:0] MEM_WB_MemData, MEM_WB_ALUResult;
    reg [4:0] MEM_WB_Rd;
    reg MEM_WB_MemToReg, MEM_WB_RegWrite;

    // === WB Stage ===
    wire [4:0] rd_WB = MEM_WB_Rd;
    wire [31:0] writeData_WB = MEM_WB_MemToReg ? MEM_WB_MemData : MEM_WB_ALUResult;
    wire RegWrite_WB = MEM_WB_RegWrite;

    // === PC Update ===
    assign PC_next = PC + 4;

    // === Pipeline Register Updates ===
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
        end else begin
            PC <= PC_next;

            // IF/ID
            IF_ID_PC <= PC;
            IF_ID_Instruction <= instruction;

            // ID/EX
            ID_EX_PC <= IF_ID_PC;
            ID_EX_ReadData1 <= readData1;
            ID_EX_ReadData2 <= readData2;
            ID_EX_Imm <= imm;
            ID_EX_Rs1 <= rs1;
            ID_EX_Rs2 <= rs2;
            ID_EX_Rd <= rd;
            ID_EX_ALUOp <= ALUOp;
            ID_EX_ALUSrc <= ALUSrc;
            ID_EX_MemRead <= MemRead;
            ID_EX_MemWrite <= MemWrite;
            ID_EX_MemToReg <= MemToReg;
            ID_EX_RegWrite <= RegWrite;

            // EX/MEM
            EX_MEM_ALUResult <= ALU_result;
            EX_MEM_WriteData <= ID_EX_ReadData2;
            EX_MEM_Rd <= ID_EX_Rd;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_MemToReg <= ID_EX_MemToReg;
            EX_MEM_RegWrite <= ID_EX_RegWrite;

            // MEM/WB
            MEM_WB_MemData <= readData_mem;
            MEM_WB_ALUResult <= EX_MEM_ALUResult;
            MEM_WB_Rd <= EX_MEM_Rd;
            MEM_WB_MemToReg <= EX_MEM_MemToReg;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
        end
    end
endmodule
