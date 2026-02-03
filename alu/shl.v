
module shl(A, B, Z);

   input  [31:0] A, B;
   output [63:0] Z;

   wire   [4:0] sh;
   wire   [31:0] r;

   assign sh = B[4:0];
   assign r = A << sh;
   assign Z = {32'b0, r};

endmodule

