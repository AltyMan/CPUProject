`include "core/registers.v"
`include "core/Bus.v"

module DataPath(
	input wire clock, clear,
	// Data inputs
	input wire [31:0] Mdatain,
	input wire [15:0] ALUControl,
	// Control signals: out = select, in = enable
	input wire GPR_Rin,
    input wire GPR_Rout,
    input wire [15:0] RinHI,  // Enables for HI, LO, ZHigh, etc.
    input wire [15:0] RoutHI, // Selects for HI, LO, ZHigh, etc.
	input wire IRin, MARin,
	input wire RZout,
	input wire RYin, RBin,
	input wire PCjump,
	input wire MDRread,
	// Control signals from control unit
	input wire Gra, Grb, Grc, BAout, Cout,
	// Control signals for RAM
	input wire RAMread, RAMwrite,
	// Control signals from/for ports
	input wire InPortStrobe, OutPortEnable,
	// Outport data
	output wire [31:0] OutPortData
);

wire [31:0] IROut, MAROut, Mdataout;

wire [15:0] Renable;
wire [15:0] Rselect;
wire [31:0] CSignExtended_Val;

wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
			BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13,
			BusMuxInR14, BusMuxInR15,
			BusMuxInHI, BusMuxInLO, BusMuxInZHigh, BusMuxInZLow,
			BusMuxInPC, BusMuxInMDR, BusMuxInPort, BusMuxInCSignExtended;

wire [31:0] BusMuxOut;

wire [31:0] Yregout;

wire [31:0] ALUResultHigh, ALUResultLow;
wire [31:0] ZHighIn, ZLowIn;

wire [31:0] resultR0;


// CON FF internal signals
wire [3:0] CON_IR;
wire CON_out_internal;

SelectEncode encode_unit(
	.IROut(IROut),
	.Gra(Gra),
	.Grb(Grb),
	.Grc(Grc),
	.Rin(GPR_Rin),
	.Rout(GPR_Rout),
	.BAout(BAout),
	.Cout(Cout),
	.Renable(Renable),
	.Rselect(Rselect),
	.CSignExtended(CSignExtended_Val)
);

// Reconstruct the 32-bit Rin and Rout signals for the rest of the DataPath
wire [31:0] Rin = {RinHI, Renable};
wire [31:0] Rout = {RoutHI[15:8], Cout, RoutHI[6:0], Rselect};

// Pass the combinational sign-extended value straight to the bus mux
assign BusMuxInCSignExtended = CSignExtended_Val;


// Pull branch condition field from IR
assign CON_IR = IROut[22:19];

//Devices
	
// Generate R0 to R15 registers
register R0(clear, clock, Rin[0], BusMuxOut, resultR0);
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
register ZHigh(clear, clock, Rin[18], ZHighIn, BusMuxInZHigh);
register ZLow(clear, clock, Rin[19], ZLowIn, BusMuxInZLow);
pc PC(clear, clock, Rin[20], PCjump, BusMuxOut, BusMuxInPC);
mdr MDR(clear, clock, Rin[21], MDRread, BusMuxOut, Mdatain, BusMuxInMDR, Mdataout);
inport InPort(clear, InPortStrobe, BusMuxOut, BusMuxInPort);
outport OutPort(clear, clock, OutPortEnable, BusMuxOut, OutPortData);

ir IR(clear, clock, IRin, BusMuxOut, IROut);
mar MAR(clear, clock, MARin, BusMuxOut, MAROut);

register RY(clear, clock, RYin, BusMuxOut, Yregout);

// CON FF
CON_FF con_ff(
	.clk(clock),
	.reset(clear),
	.CONin(CONin),
	.cond(CON_IR),
	.bus(BusMuxOut),
	.CON(CON_out_internal));
	
// New r0 logic
reg0logic R0Logic(BAout, resultR0, BusMuxInR0);

alu ALU(Yregout, BusMuxOut, ALUControl, ALUResultHigh, ALUResultLow);

// ALU results routed through mux
assign ZHighIn = (ALUControl != 16'd0) ? ALUResultHigh : BusMuxOut;
assign ZLowIn = (ALUControl != 16'd0) ? ALUResultLow : BusMuxOut;

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

//RAM
RAM ram(
	.clock(clock),
	.read(RAMread),
	.write(RAMwrite),
	.address(MAROut[8:0]), // 9-bit address from MAR
	.write_data(BusMuxOut),   // Data to write from the bus
	.read_data(Mdatain)      // Data read goes to Mdatain for MDR
);

endmodule

