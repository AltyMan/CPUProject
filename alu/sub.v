
module sub(A, B, Result);

   input  [31:0] A, B;
   output [31:0] Result;

   wire   [31:0] Result;
   wire   [31:0] B_inv;
   wire   [31:0] B_neg;

   assign B_inv = ~B;


   RCA NEGATE_B(B_inv, 32'b00000000000000000000000000000001, B_neg);
   RCA SUBTRACT(A, B_neg, Result);

endmodule

