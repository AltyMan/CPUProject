// NOT operation
// Bitwise NOT of A.
// B is unused but kept for a consistent ALU interface. (We can remove it, if causes and contradictions in the future)
// Output is 64-bit, result in the lower 32 bits

module not_op(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = {{32{1'b0}}, (~A)};
endmodule
