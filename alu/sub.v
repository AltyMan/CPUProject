// SUB operation
// Subtracts B from A 
   //(A - B)
// Inputs are 32-bit because registers are 32-bit. Output is 64-bit to fit the Z register (even though subtraction)
// SUB only needs 32 bits.

module sub(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = {{32{1'b0}}, (A - B)};
endmodule
