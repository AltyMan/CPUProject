// SHL (Shift Left Logical)
// Shifts A left by the amount specified in B[4:0]
// Only the lower 5 bits of B are used because shifting by more than 31 bits is basecally unnecessary for a 32-bit value.

module shl(input [31:0] A, input [31:0] B, output [63:0] Z);
  wire [4:0] sh = B[4:0];
  assign Z = {{32{1'b0}}, (A << sh)};
endmodule
