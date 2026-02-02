`timescale 1ns/10ps

module neg(A, Result);

   input  [31:0] A;
   output [31:0] Result;

   wire   [31:0] A_inv;
   wire   [31:0] Result;

   assign A_inv = ~A;
   RCA NEGATE(A_inv, 32'b00000000000000000000000000000001, Result);

endmodule
