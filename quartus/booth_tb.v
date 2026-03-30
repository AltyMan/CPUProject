`timescale 1ns / 1ps

module booth_tb;

    // 1. Parameters & Signals
    parameter DATA_WIDTH = 32;

    // Inputs (reg because we assign them in an initial block)
    reg signed [DATA_WIDTH-1:0] Q;
    reg signed [DATA_WIDTH-1:0] M;
    reg clk;

    // Outputs (wires because they are driven by the module)
    wire [DATA_WIDTH-1:0] HI;
    wire [DATA_WIDTH-1:0] LO;

    // Helper signal to see the full 64-bit result in waveforms
    wire signed [2*DATA_WIDTH-1:0] full_result;
    assign full_result = {HI, LO};

    // 2. Instantiate the Unit Under Test (UUT)
    boothmul #(DATA_WIDTH) uut (
        .Q(Q), 
        .M(M), 
        .HI(HI), 
        .LO(LO)
    );

    // 3. Clock Generation (10ns period)
    always #5 clk = ~clk;

    // 4. Test Stimulus
    initial begin
        // Setup waveform dumping (standard for viewers like GTKWave)
        $dumpfile("booth_tb.vcd");
        $dumpvars(0, booth_tb);

        // Initialize
        clk = 0;
        Q = 0;
        M = 0;

        // Wait a bit, then align with clock edges for clean waveforms
        #10;

        // Test Case 1: Simple Positive (10 * 5 = 50)
        @(posedge clk);
        Q = 32'd10;
        M = 32'd5;
        #1; // Small delay to let combinational logic settle for print
        $display("Time: %0t | %d * %d = %d", $time, Q, M, full_result);

        // Test Case 2: Positive * Negative (10 * -5 = -50)
        @(posedge clk);
        Q = 32'd10;
        M = -32'd5;
        #1;
        $display("Time: %0t | %d * %d = %d", $time, Q, M, full_result);

        // Test Case 3: Negative * Negative (-10 * -5 = 50)
        @(posedge clk);
        Q = -32'd10;
        M = -32'd5;
        #1;
        $display("Time: %0t | %d * %d = %d", $time, Q, M, full_result);

        // Test Case 4: Zero Multiplication
        @(posedge clk);
        Q = 32'd12345;
        M = 32'd0;
        #1;
        $display("Time: %0t | %d * %d = %d", $time, Q, M, full_result);

        // Test Case 5: Large Numbers / Random
        @(posedge clk);
        Q = 32'd2000;
        M = 32'd2000;
        #1;
        $display("Time: %0t | %d * %d = %d", $time, Q, M, full_result);

        // End simulation
        #20;
        $finish;
    end

endmodule