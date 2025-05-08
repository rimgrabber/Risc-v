`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg reset;

    // Instantiate the datapath (top-level module)
    Datapath uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        $display("Starting Simulation");
        $dumpfile("riscv_pipeline.vcd");  // For GTKWave visualization
        $dumpvars(0, testbench);

        clk = 0;
        reset = 1;

        #15;
        reset = 0;

        // Run for 200 ns
        #200;
        $finish;
    end
endmodule
