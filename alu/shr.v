// SHR (shift right logical)
// Shifts A to the right and fills with zeros
// Uses B[4:0] as the shift amount
// This is a logical shift, no sign extension

module shr(input [31:0] A, input [31:0] B, output [63:0] Z);
  wire [4:0] sh = B[4:0];
  assign Z = {{32{1'b0}}, (A >> sh)};
endmodule
