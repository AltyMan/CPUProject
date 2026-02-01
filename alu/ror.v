// ROR (rotate right)
// Rotates bits of A to the right by B[4:0] positions
// Bits that fall off the right enter on the left

module ror(input [31:0] A, input [31:0] B, output [63:0] Z);
  wire [4:0] sh = B[4:0];
  wire [31:0] r;
  helper h();
  assign r = h.ror32(A, sh);
  assign Z = {{32{1'b0}}, r};
endmodule
