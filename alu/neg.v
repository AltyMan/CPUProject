// NEG operation
// Computes the two's complement of A, Make A NEGative
// B is unused but kept for a consistent ALU interface.
// Output is widened to 64 bits for the Z register.

module neg(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = {{32{1'b0}}, (-$signed(A))};
endmodule
