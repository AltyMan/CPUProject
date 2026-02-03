module shra(A, B, Z);

   input signed [31:0] A;
   input  [31:0] B;
   output signed [31:0] Z;

   wire   [4:0]  sh;
   wire   [31:0] r;

   assign sh = B[4:0];
   assign r = A >>> sh;
   assign Z = r;

endmodule

