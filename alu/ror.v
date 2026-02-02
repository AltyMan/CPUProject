`timescale 1ns/10ps

module ror(A, B, Z);

   input  [31:0] A, B;
   output [63:0] Z;

   wire   [4:0]  sh;
   wire   [31:0] r;

   assign sh = B[4:0];

   // Rotate right:
   // (A >> sh) moves bits right
   // (A << (32 - sh)) wraps the bits around
   assign r = (A >> sh) | (A << (5'd32 - sh));
   assign Z = {32'b0, r};

endmodule
