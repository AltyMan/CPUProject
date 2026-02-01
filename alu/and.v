// AND operation
// AND between A and B
// Both inputs are 32-bit values from the datapath
// Result is placed in the lower 32 bits of Z

module and_op(input [31:0] A, input [31:0] B, output [63:0] Z);
  assign Z = {{32{1'b0}}, (A & B)};
endmodule
