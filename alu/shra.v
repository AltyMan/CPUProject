`timescale 1ns/10ps

module shra(A, B, Z);

   input  [31:0] A, B;
   output [63:0] Z;

   wire   [4:0]  sh;
   wire   [31:0] r;

   assign sh = B[4:0];
   assign r = $signed(A) >>> sh;
   assign Z = {{32{r[31]}}, r};

endmodule
