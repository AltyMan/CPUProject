module DataPath(
	input wire clock, clear, stop,
	input wire IRQ,
	input wire [31:0] InPortData,
	output wire [31:0] OutPortData,
	output wire run
);

// Control signals: out = select, in = enable
wire GPR_Rin, GPR_Rout;
wire Gra, Grb, Grc, BAout, Cout;
wire [15:0] RinHI, RoutHI; // Enables/Selects for HI, LO, ZHigh, etc.
wire IRin, MARin, RZout, RYin, RBin, PCjump, MDRread, CONin;

wire EPCin, EPCout, ISRout;
wire set_IE, clear_IE, IE_out;

// ALU control signals
wire [15:0] ALUControl;
// Memory/IO
wire RAMread, RAMwrite;
wire InPortStrobe, OutPortEnable;
wire [31:0] icache_data; // new for instruction fetch

wire [31:0] IROut, Mdatain, Mdataout;
wire [8:0] MAROut;

wire [15:0] Renable;
wire [15:0] Rselect;
wire [31:0] CSignExtended_Val;

wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
			BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13,
			BusMuxInR14, BusMuxInR15,
			BusMuxInHI, BusMuxInLO, BusMuxInZHigh, BusMuxInZLow,
			BusMuxInPC, BusMuxInMDR, BusMuxInPort, BusMuxInCSignExtended,
			BusMuxInEPC;
wire [31:0] BusMuxInISR = 32'h00000050;

wire [31:0] BusMuxOut;

wire [31:0] Yregout;

wire [31:0] ALUResultHigh, ALUResultLow;
wire [31:0] ZHighIn, ZLowIn;

wire [31:0] resultR0;

// CON FF internal signals
wire [3:0] CON_IR;
wire CON_out_internal;
wire PCjump_eff;
assign PCjump_eff = PCjump & CON_out_internal;

reg irq_latched;
initial irq_latched = 1'b0;

// IRQ latch
always @(posedge clock or posedge clear) begin
    if (clear) begin
        irq_latched <= 1'b0;
    end
    else if (EPCin) begin 
        irq_latched <= 1'b0;
    end
    else if (IRQ) begin
        irq_latched <= 1'b1;
    end
end

wire CU_IRQ = IRQ | irq_latched;

SelectEncode encode_unit(
	.IROut(IROut),
	.Gra(Gra),
	.Grb(Grb),
	.Grc(Grc),
	.Rin(GPR_Rin),
	.Rout(GPR_Rout),
	.Renable(Renable),
	.Rselect(Rselect),
	.CSignExtended(CSignExtended_Val)
);

// Reconstruct 32-bit Rin and Rout signals
wire [31:0] Rin = {RinHI, Renable};
wire [31:0] Rout = {RoutHI[15:10], ISRout, EPCout, Cout, RoutHI[6:0], Rselect};

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
pc PC(clear, clock, Rin[20], PCjump_eff, BusMuxOut, BusMuxInPC);
mdr MDR(clear, clock, Rin[21], MDRread, BusMuxOut, Mdatain, BusMuxInMDR, Mdataout);
inport InPort(clear, InPortStrobe, InPortData, BusMuxInPort);
outport OutPort(clear, clock, OutPortEnable, BusMuxOut, OutPortData);

ir IR(clear, clock, IRin, icache_data, IROut); // no longer bus, directly from icache
mar MAR(clear, clock, MARin, BusMuxOut, MAROut);

register RY(clear, clock, RYin, BusMuxOut, Yregout);

epc EPC_reg(clear, clock, EPCin, BusMuxOut, BusMuxInEPC);
IE IE_flag(clear, clock, set_IE, clear_IE, IE_out);

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
	BusMuxInEPC, BusMuxInISR,
	Rout, BusMuxOut
	);

// Instruction Cache (Read-Only)
RAM #(.INIT_FILE("bonus/instructions.mem")) l1_icache(
    .clock(clock),
    .read(1'b1), // always read
    .write(1'b0), // never write
    .address(BusMuxInPC[8:0]),
    .write_data(32'd0),
    .read_data(icache_data)
);

// Data Cache (Read/Write)
RAM #(.INIT_FILE("bonus/data.mem")) l1_dcache(
    .clock(clock),
    .read(RAMread),
    .write(RAMwrite),
    .address(MAROut),
    .write_data(Mdataout),
    .read_data(Mdatain)
);

//Control Unit
control CU(
    .clock(clock),
    .reset(clear),
    .stop(stop),

	.IRQ(CU_IRQ),
    .IE_out(IE_out),
    .EPCin(EPCin), .EPCout(EPCout),
    .ISRout(ISRout),
    .set_IE(set_IE), .clear_IE(clear_IE),

    .IR(IROut),
    .CON_FF(CON_out_internal),

    .GPR_Rin(GPR_Rin), .GPR_Rout(GPR_Rout),
    .RinHI(RinHI), .RoutHI(RoutHI),
    .IRin(IRin), .MARin(MARin), 
    .RZout(RZout), .RYin(RYin), .RBin(RBin), 
    .PCjump(PCjump), .MDRread(MDRread), .CONin(CONin),
    .ALUControl(ALUControl),
    .Gra(Gra), .Grb(Grb), .Grc(Grc), 
    .BAout(BAout), .Cout(Cout),
    .RAMread(RAMread), .RAMwrite(RAMwrite),
    .InPortStrobe(InPortStrobe), .OutPortEnable(OutPortEnable),

	.run(run)
);

endmodule