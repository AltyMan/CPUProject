`timescale 1ns/10ps

module test_tb();

reg clock, clear;
reg [31:0] A, B;
reg [31:0] Mdatain;
reg [23:0] Rin, Rout;
reg IRin, MARin;
reg RAout, RBout, RCout, RZout;
reg RYin, RAin, RBin, RCin, RZin;
reg MDRread;

wire [31:0] BusMuxOut;

// Instantiate DataPath
DataPath dut(
	.clock(clock),
	.clear(clear),
	.A(A),
	.B(B),
    .Mdatain(Mdatain),
	.Rin(Rin),
	.Rout(Rout),
	.IRin(IRin),
	.MARin(MARin),
	.RAout(RAout),
	.RBout(RBout),
	.RCout(RCout),
	.RZout(RZout),
	.RYin(RYin),
	.RAin(RAin),
	.RBin(RBin),
	.RCin(RCin),
	.RZin(RZin),
	.MDRread(MDRread)
);

// Clock generation
initial begin
	clock = 0;
	forever #10 clock = ~clock;
end

// Test stimulus
initial begin
	// VCD file for waveform viewing
	$dumpfile("test_tb.vcd");
	$dumpvars(0, test_tb);
	
	clear = 1;
	A = 32'h00000000;
	B = 32'h00000000;
	Rin = 24'h000000;
	Rout = 24'h000000;
	IRin = 0;
	MARin = 0;
	RAout = 0;
	RBout = 0;
	RCout = 0;
	RZout = 0;
	RYin = 0;
	RAin = 0;
	RBin = 0;
	RCin = 0;
	RZin = 0;
	MDRread = 0;
	
	// Release clear signal
	#15 clear = 0;
	
    // TEST 0: Load MDR
    $display("\n=== TEST 0: Loading MDR Register ===");
    #15 begin
        Rin[21] = 1'b1;       // Enable MDR input
        MDRread = 1'b1;      // Enable MDR read
        Mdatain = 32'hDEADBEEF; // Load data into MDR
    end
    #15 begin
        Rin[21] = 1'b0;
        MDRread = 1'b0;
    end
    #15 begin
        Rout[21] = 1'b1;     // Output MDR to bus
        Rin[5] = 1'b1;      // Load MDR value into R5 for verification
    end
    #15 begin
        Rout[21] = 1'b0;
        Rin[5] = 1'b0;
    end
    $display("MDR output to bus: 0x%h", BusMuxOut);
    Rout[21] = 1'b0;

	// ===== TEST 1: Load PC register (Rin[20] = PC) =====
	$display("\n=== TEST 1: Loading PC Register ===");
	#15 begin
		Rin[20] = 1'b1;		// Enable PC input
		B = 32'h00000000;	// Initial PC value = 0
	end
	#15 begin
		Rin[20] = 1'b0;
		Rout[20] = 1'b1;	// Output PC to bus
	end
	#15 $display("PC output to bus: 0x%h", BusMuxOut);
	Rout[20] = 1'b0;
	
	// ===== TEST 2: PC Counter (Increment PC) =====
	$display("\n=== TEST 2: Incrementing PC Counter ===");
	#15 begin
		Rin[20] = 1'b1;
		B = 32'h00000001;	// Load 1 into PC
	end
	#15 begin
		Rin[20] = 1'b0;
		Rout[20] = 1'b1;	// Output PC
	end
	$display("PC after increment: 0x%h", BusMuxOut);
	#15 begin
		Rin[20] = 1'b1;
		B = 32'h00000002;	// Load 2 into PC
	end
	#15 begin
		Rin[20] = 1'b0;
		Rout[20] = 1'b1;
	end
	$display("PC after next increment: 0x%h", BusMuxOut);
	Rout[20] = 1'b0;
	
	// ===== TEST 3: Load MAR register (Rin[20] for MAR) =====
	$display("\n=== TEST 3: Loading MAR Register ===");
	#15 begin
		MARin = 1'b1;		// Enable MAR input
		B = 32'h10000000;	// Load address into MAR
	end
	$display("Address loaded into MAR: 0x%h", B);
	MARin = 1'b0;
	
	#15 begin
		MARin = 1'b1;
		B = 32'h20000000;	// Change MAR to new address
	end
	$display("New address loaded into MAR: 0x%h", B);
	MARin = 1'b0;
	
	// ===== TEST 4: Load IR register (Instruction Register) =====
	$display("\n=== TEST 4: Loading IR Register ===");
	#15 begin
		IRin = 1'b1;		// Enable IR input
		B = 32'hABCD1234;	// Load instruction
	end
	$display("Instruction loaded into IR: 0x%h", B);
	IRin = 1'b0;
	
	#15 begin
		IRin = 1'b1;
		B = 32'h5678EFFF;	// Load new instruction
	end
	$display("New instruction loaded into IR: 0x%h", B);
	IRin = 1'b0;
	
	// ===== TEST 5: Load General Purpose Registers R0-R3 =====
	$display("\n=== TEST 5: Loading General Purpose Registers (R0-R3) ===");
	#15 begin
		Rin[0] = 1'b1;		// Enable R0 input
		B = 32'h11111111;
	end
	#15 begin
		Rin[0] = 1'b0;
		Rout[0] = 1'b1;		// Output R0
	end
	$display("R0 value: 0x%h", BusMuxOut);
	Rout[0] = 1'b0;
	
	#15 begin
		Rin[1] = 1'b1;		// Enable R1 input
		B = 32'h22222222;
	end
	#15 begin
		Rin[1] = 1'b0;
		Rout[1] = 1'b1;		// Output R1
	end
	$display("R1 value: 0x%h", BusMuxOut);
	Rout[1] = 1'b0;
	
	#15 begin
		Rin[2] = 1'b1;		// Enable R2 input
		B = 32'h33333333;
	end
	#15 begin
		Rin[2] = 1'b0;
		Rout[2] = 1'b1;		// Output R2
	end
	$display("R2 value: 0x%h", BusMuxOut);
	Rout[2] = 1'b0;
	
	#15 begin
		Rin[3] = 1'b1;		// Enable R3 input
		B = 32'h44444444;
	end
	#15 begin
		Rin[3] = 1'b0;
		Rout[3] = 1'b1;		// Output R3
	end
	$display("R3 value: 0x%h", BusMuxOut);
	Rout[3] = 1'b0;
	
	// ===== TEST 6: Load HI/LO Registers =====
	$display("\n=== TEST 6: Loading HI/LO Registers ===");
	#15 begin
		Rin[16] = 1'b1;		// Enable HI input
		B = 32'hDEADBEEF;
	end
	#15 begin
		Rin[16] = 1'b0;
		Rout[16] = 1'b1;	// Output HI
	end
	$display("HI value: 0x%h", BusMuxOut);
	Rout[16] = 1'b0;
	
	#15 begin
		Rin[17] = 1'b1;		// Enable LO input
		B = 32'hCAFEBABE;
	end
	#15 begin
		Rin[17] = 1'b0;
		Rout[17] = 1'b1;	// Output LO
	end
	$display("LO value: 0x%h", BusMuxOut);
	Rout[17] = 1'b0;
	
	// ===== TEST 7: Load Z High/Low Registers =====
	$display("\n=== TEST 7: Loading Z High/Low Registers ===");
	#15 begin
		Rin[18] = 1'b1;		// Enable ZHigh input
		B = 32'h12345678;
	end
	#15 begin
		Rin[18] = 1'b0;
		Rout[18] = 1'b1;	// Output ZHigh
	end
	$display("ZHigh value: 0x%h", BusMuxOut);
	Rout[18] = 1'b0;
	
	#15 begin
		Rin[19] = 1'b1;		// Enable ZLow input
		B = 32'h9ABCDEF0;
	end
	#15 begin
		Rin[19] = 1'b0;
		Rout[19] = 1'b1;	// Output ZLow
	end
	$display("ZLow value: 0x%h", BusMuxOut);
	Rout[19] = 1'b0;
	
	// ===== TEST 8: Load InPort Register =====
	$display("\n=== TEST 8: Loading InPort Register ===");
	#15 begin
		Rin[22] = 1'b1;		// Enable InPort input
		B = 32'hAAAAAAAA;
	end
	#15 begin
		Rin[22] = 1'b0;
		Rout[22] = 1'b1;	// Output InPort
	end
	$display("InPort value: 0x%h", BusMuxOut);
	Rout[22] = 1'b0;
	
	// ===== TEST 9: Clear all registers =====
	$display("\n=== TEST 9: Testing Clear Signal ===");
	#15 begin
		clear = 1'b1;
	end
	#15 begin
		clear = 1'b0;
		Rout[0] = 1'b1;		// Try to output R0 (should be cleared)
	end
	$display("R0 after clear: 0x%h (should be 0x00000000)", BusMuxOut);
	Rout[0] = 1'b0;
	
	// ===== TEST 10: Sequential Register Load/Output =====
	$display("\n=== TEST 10: Sequential Load and Output ===");
	#15 begin
		// Load R4-R7 with sequential values
		Rin[4] = 1'b1;
		B = 32'h11223344;
	end
	#15 begin
		Rin[4] = 1'b0;
		Rin[5] = 1'b1;
		B = 32'h55667788;
	end
	#15 begin
		Rin[5] = 1'b0;
		Rin[6] = 1'b1;
		B = 32'h99AABBCC;
	end
	#15 begin
		Rin[6] = 1'b0;
		Rin[7] = 1'b1;
		B = 32'hDDEEFF00;
	end
	#15 begin
		Rin[7] = 1'b0;
		Rout[4] = 1'b1;
	end
	$display("R4: 0x%h", BusMuxOut);
	#15 begin
		Rout[4] = 1'b0;
		Rout[5] = 1'b1;
	end
	$display("R5: 0x%h", BusMuxOut);
	#15 begin
		Rout[5] = 1'b0;
		Rout[6] = 1'b1;
	end
	$display("R6: 0x%h", BusMuxOut);
	#15 begin
		Rout[6] = 1'b0;
		Rout[7] = 1'b1;
	end
	$display("R7: 0x%h", BusMuxOut);
	Rout[7] = 1'b0;
	
	$display("\n=== All Tests Complete ===\n");
	#15 $finish;
end

endmodule
