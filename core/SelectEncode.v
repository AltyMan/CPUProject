module SelectEncode(
    input wire [31:0] IROut,
    input wire Gra,
    input wire Grb,
    input wire Grc,
    input wire Rin,
    input wire Rout,
    input wire BAout,
    input wire Cout,
    output wire [15:0] Renable,
    output wire [15:0] Rselect,
    output wire [31:0] CSignExtended
);

wire [3:0] opcode;
assign opcode = IROut[31:27];
wire [3:0] ra;
assign ra = IROut[26:23];
wire [3:0] rb;
assign rb = IROut[22:19];
wire [3:0] rc;
assign rc = IROut[18:15];

wire [3:0] s1, s2, s3;
wire [3:0] s;
assign s1 = (Gra) ? ra : 4'b0000;
assign s2 = (Grb) ? rb : 4'b0000;
assign s3 = (Grc) ? rc : 4'b0000;

wire op_jal = (opcode == 5'b10011);

assign s = (op_jal & Rin) ? 4'd12 : (s1 | s2 | s3);

wire [15:0] decoder_out;
assign decoder_out = 16'b1 << s[3:0]; // 4-to-16 decoder to create one-hot vector

// Combine the one-hot decoded signal with the global GPR Rin/Rout flags
assign Renable = {16{Rin}} & decoder_out;
assign Rselect = {16{Rout}} & decoder_out;

assign CSignExtended = {{14{IROut[18]}}, IROut[17:0]}; // fan out 18th bit

endmodule