`timescale 1ns/10ps

module rol(A, B, Z);

   input  [31:0] A, B;
   output [63:0] Z;

   wire   [4:0]  sh;
   wire   [31:0] r;

   assign sh = B[4:0];

   // Rotate left:
   // (A << sh) moves bits left
   // (A >> (32 - sh)) wraps the bits around
   assign r = (A << sh) | (A >> (5'd32 - sh));

   // Zero-extend to 64 bits (upper 32 are 0)
   assign Z = {32'b0, r};

endmodule
