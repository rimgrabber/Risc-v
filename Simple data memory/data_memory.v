module DataMemory (
    input clk,
    input [31:0] addr,
    input [31:0] writeData,
    input memWrite, memRead,
    output [31:0] readData
);
    reg [31:0] memory[0:255];

    always @(posedge clk) begin
        if (memWrite)
            memory[addr[9:2]] <= writeData;
    end

    assign readData = memRead ? memory[addr[9:2]] : 32'b0;
endmodule
