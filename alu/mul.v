// MUL operation
// Signed multiplication of two 32-bit values
// Result is 64 bits, which fully fits in the Z register. Zhigh will later go to HI, and Zlow to LO.

module mul(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = $signed(A) * $signed(B);
endmodule
