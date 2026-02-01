// SHRA (Shift Right ARithmetic)
// Shifts A to the right while preserving the sign bit
// A is treated as signed

module shra(input [31:0] A, input [31:0] B, output [63:0] Z);
  wire [4:0] sh = B[4:0];
  assign Z = {{32{1'b0}}, ($signed(A) >>> sh)};
endmodule
