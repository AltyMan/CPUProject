module Bus (
	//Mux
	input [31:0]BusMuxInR0, input [31:0]BusMuxInR1, input [31:0]BusMuxInR2, input [31:0]BusMuxInR3,
	input [31:0]BusMuxInR4, input [31:0]BusMuxInR5, input [31:0]BusMuxInR6, input [31:0]BusMuxInR7,
	input [31:0]BusMuxInR8, input [31:0]BusMuxInR9, input [31:0]BusMuxInR10, input [31:0]BusMuxInR11,
	input [31:0]BusMuxInR12, input [31:0]BusMuxInR13, input [31:0]BusMuxInR14, input [31:0]BusMuxInR15,
	input [31:0]BusMuxInHI, input [31:0]BusMuxInLO, input [31:0]BusMuxInZHigh, input [31:0]BusMuxInZLow,
	input [31:0]BusMuxInPC, input [31:0]BusMuxInMDR, input [31:0]BusMuxInPort, input [31:0]BusMuxInCSignExtended,
	//Encoder
	input [24:0] Rout, // R0out to R15out, HIout, LOout, ZHighout, ZLowout, PCout, MDRout, InPortout, CSignExtendedout

	output wire [31:0]BusMuxOut
);

reg [31:0]q;

always @ (*) begin
	if (Rout[0])          q = BusMuxInR0;
    else if (Rout[1])     q = BusMuxInR1;
    else if (Rout[2])     q = BusMuxInR2;
    else if (Rout[3])     q = BusMuxInR3;
    else if (Rout[4])     q = BusMuxInR4;
    else if (Rout[5])     q = BusMuxInR5;
    else if (Rout[6])     q = BusMuxInR6;
    else if (Rout[7])     q = BusMuxInR7;
    else if (Rout[8])     q = BusMuxInR8;
    else if (Rout[9])     q = BusMuxInR9;
    else if (Rout[10])    q = BusMuxInR10;
    else if (Rout[11])    q = BusMuxInR11;
    else if (Rout[12])    q = BusMuxInR12;
    else if (Rout[13])    q = BusMuxInR13;
    else if (Rout[14])    q = BusMuxInR14;
    else if (Rout[15])    q = BusMuxInR15;
    else if (Rout[16])     q = BusMuxInHI;
    else if (Rout[17])     q = BusMuxInLO;
    else if (Rout[18])  q = BusMuxInZHigh;
    else if (Rout[19])   q = BusMuxInZLow;
    else if (Rout[20])     q = BusMuxInPC;
    else if (Rout[21])    q = BusMuxInMDR;
    else if (Rout[22]) q = BusMuxInPort;
    else if (Rout[23])      q = BusMuxInCSignExtended;
end
assign BusMuxOut = q;
endmodule
