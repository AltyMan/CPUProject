// ADD operation
// Adds two 32-bit values coming from Y (A) and BUS (B)
// Inputs are 32-bit [31:0]
// Output is 64-bit [63:0]
// For add, only the lower 32 bits are used the rest are zeros

module add(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = {{32{1'b0}}, (A + B)};
endmodule
