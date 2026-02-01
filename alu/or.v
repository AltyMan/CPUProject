// OR operation
// OR between A and B.
// Inputs are 32-bit registers but the output is expanded to 64 bits
// to match the Z register.

module or_op(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = {{32{1'b0}}, (A | B)};
endmodule
