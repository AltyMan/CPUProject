module Bus (
	//Mux
	input [31:0]BusMuxInR0, input [31:0]BusMuxInR1, input [31:0]BusMuxInR2, input [31:0]BusMuxInR3,
	input [31:0]BusMuxInR4, input [31:0]BusMuxInR5, input [31:0]BusMuxInR6, input [31:0]BusMuxInR7,
	input [31:0]BusMuxInR8, input [31:0]BusMuxInR9, input [31:0]BusMuxInR10, input [31:0]BusMuxInR11,
	input [31:0]BusMuxInR12, input [31:0]BusMuxInR13, input [31:0]BusMuxInR14, input [31:0]BusMuxInR15,
	input [31:0]BusMuxInHI, input [31:0]BusMuxInLO, input [31:0]BusMuxInZHigh, input [31:0]BusMuxInZLow,
	input [31:0]BusMuxInPC, input [31:0]BusMuxInMDR, input [31:0]BusMuxInPort, input [31:0]BusMuxInCSignExtended,
	//Encoder
	input [31:0] Rout, // R0out to R15out, HIout, LOout, ZHighout, ZLowout, PCout, MDRout, InPortout, CSignExtendedout

	output wire [31:0]BusMuxOut
);

reg [31:0]q;
wire [4:0]S;

// S0: OR of all odd indices (1, 3, 5...31)
assign S[0] = Rout[1]  | Rout[3]  | Rout[5]  | Rout[7]  | Rout[9]  | Rout[11] | Rout[13] | Rout[15] |
				Rout[17] | Rout[19] | Rout[21] | Rout[23] | Rout[25] | Rout[27] | Rout[29] | Rout[31];
// S1: OR of pairs (2-3, 6-7...30-31)
assign S[1] = Rout[2]  | Rout[3]  | Rout[6]  | Rout[7]  | Rout[10] | Rout[11] | Rout[14] | Rout[15] |
				Rout[18] | Rout[19] | Rout[22] | Rout[23] | Rout[26] | Rout[27] | Rout[30] | Rout[31];
// S2: OR of quads (4-7, 12-15...28-31)
assign S[2] = Rout[4]  | Rout[5]  | Rout[6]  | Rout[7]  | Rout[12] | Rout[13] | Rout[14] | Rout[15] |
				Rout[20] | Rout[21] | Rout[22] | Rout[23] | Rout[28] | Rout[29] | Rout[30] | Rout[31];
// S3: OR of octets (8-15, 24-31)
assign S[3] = Rout[8]  | Rout[9]  | Rout[10] | Rout[11] | Rout[12] | Rout[13] | Rout[14] | Rout[15] |
				Rout[24] | Rout[25] | Rout[26] | Rout[27] | Rout[28] | Rout[29] | Rout[30] | Rout[31];
// S4: OR of upper half (16-31)
assign S[4] = Rout[16] | Rout[17] | Rout[18] | Rout[19] | Rout[20] | Rout[21] | Rout[22] | Rout[23] |
				Rout[24] | Rout[25] | Rout[26] | Rout[27] | Rout[28] | Rout[29] | Rout[30] | Rout[31];

always @ (*) begin
	case (S)
		5'd0: q = BusMuxInR0;
		5'd1: q = BusMuxInR1;
		5'd2: q = BusMuxInR2;
		5'd3: q = BusMuxInR3;
		5'd4: q = BusMuxInR4;
		5'd5: q = BusMuxInR5;
		5'd6: q = BusMuxInR6;
		5'd7: q = BusMuxInR7;
		5'd8: q = BusMuxInR8;
		5'd9: q = BusMuxInR9;
		5'd10: q = BusMuxInR10;
		5'd11: q = BusMuxInR11;
		5'd12: q = BusMuxInR12;
		5'd13: q = BusMuxInR13;
		5'd14: q = BusMuxInR14;
		5'd15: q = BusMuxInR15;
		5'd16: q = BusMuxInHI;
		5'd17: q = BusMuxInLO;
		5'd18: q = BusMuxInZHigh;
		5'd19: q = BusMuxInZLow;
		5'd20: q = BusMuxInPC;
		5'd21: q = BusMuxInMDR;
		5'd22: q = BusMuxInPort;
		5'd23: q = BusMuxInCSignExtended;
		default: q = 32'd0;
	endcase
end
assign BusMuxOut = q;
endmodule