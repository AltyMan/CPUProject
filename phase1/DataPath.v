module DataPath(
	input wire clock, clear,
	// Data inputs
	input wire [31:0] A,
	input wire [31:0] B,
	input wire [31:0] Mdatain,
	// Control signals: out = select, in = enable
	input wire [23:0] Rin,  // R0in to R15in
	input wire [23:0] Rout, // R0out to R15out
	input wire IRin, MARin,
	input wire RAout, RBout, RCout, RZout,
	input wire RYin, RAin, RBin, RCin, RZin,
	input wire PCjump,
	input wire MDRread
);

wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
			BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13,
			BusMuxInR14, BusMuxInR15,
			BusMuxInHI, BusMuxInLO, BusMuxInZHigh, BusMuxInZLow,
			BusMuxInPC, BusMuxInMDR, BusMuxInPort, BusMuxInCSignExtended;

wire [31:0] BusMuxOut;

wire [31:0] IROut, MAROut, Mdataout;

wire [31:0] Yregout;
wire [31:0] Zregin;

//Devices

// Generate R0 to R15 registers
register R0(clear, clock, Rin[0], BusMuxOut, BusMuxInR0);
register R1(clear, clock, Rin[1], BusMuxOut, BusMuxInR1);
register R2(clear, clock, Rin[2], BusMuxOut, BusMuxInR2);
register R3(clear, clock, Rin[3], BusMuxOut, BusMuxInR3);
register R4(clear, clock, Rin[4], BusMuxOut, BusMuxInR4);
register R5(clear, clock, Rin[5], BusMuxOut, BusMuxInR5);
register R6(clear, clock, Rin[6], BusMuxOut, BusMuxInR6);
register R7(clear, clock, Rin[7], BusMuxOut, BusMuxInR7);
register R8(clear, clock, Rin[8], BusMuxOut, BusMuxInR8);
register R9(clear, clock, Rin[9], BusMuxOut, BusMuxInR9);
register R10(clear, clock, Rin[10], BusMuxOut, BusMuxInR10);
register R11(clear, clock, Rin[11], BusMuxOut, BusMuxInR11);
register R12(clear, clock, Rin[12], BusMuxOut, BusMuxInR12);
register R13(clear, clock, Rin[13], BusMuxOut, BusMuxInR13);
register R14(clear, clock, Rin[14], BusMuxOut, BusMuxInR14);
register R15(clear, clock, Rin[15], BusMuxOut, BusMuxInR15);

register HI(clear, clock, Rin[16], BusMuxOut, BusMuxInHI);
register LO(clear, clock, Rin[17], BusMuxOut, BusMuxInLO);
register ZHigh(clear, clock, Rin[18], BusMuxOut, BusMuxInZHigh);
register ZLow(clear, clock, Rin[19], BusMuxOut, BusMuxInZLow);
pc PC(clear, clock, Rin[20], PCjump, BusMuxOut, BusMuxInPC);
mdr MDR(clear, clock, Rin[21], MDRread, BusMuxOut, Mdatain, BusMuxInMDR, Mdataout);
register InPort(clear, clock, Rin[22], BusMuxOut, BusMuxInPort);
register CSignExtended(clear, clock, Rin[23], BusMuxOut, BusMuxInCSignExtended);
ir IR(clear, clock, IRin, BusMuxOut, IROut);
mar MAR(clear, clock, MARin, BusMuxOut, MAROut);

// HERE: work on designing ALU operations & RY/RZ registers
// Old/existing code:
//register RY(clear, clock, RYin, BusMuxOut, Yregout);
//register RA(clear, clock, RAin, Yregout, BusMuxInRA);
//register RB(clear, clock, RBin, BusMuxOut, BusMuxInRB);
//adder add(A, BusMuxOut, Zregin);
//register RZ(clear, clock, RZin, Zregin, BusMuxInRZ);

//Bus
Bus bus(
	BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3,
	BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
	BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11,
	BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,
	BusMuxInHI, BusMuxInLO, BusMuxInZHigh, BusMuxInZLow,
	BusMuxInPC, BusMuxInMDR, BusMuxInPort, BusMuxInCSignExtended,
	Rout, BusMuxOut
	);

endmodule
