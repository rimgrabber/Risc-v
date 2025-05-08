module HazardUnit (
    input [4:0] ID_EX_Rd,
    input ID_EX_MemRead,
    input [4:0] IF_ID_Rs1, IF_ID_Rs2,
    output reg PCWrite, IF_ID_Write, Hazard
);
    always @(*) begin
        if (ID_EX_MemRead &&
            (ID_EX_Rd == IF_ID_Rs1 || ID_EX_Rd == IF_ID_Rs2)) begin
            PCWrite = 0;
            IF_ID_Write = 0;
            Hazard = 1;
        end else begin
            PCWrite = 1;
            IF_ID_Write = 1;
            Hazard = 0;
        end
    end
endmodule
