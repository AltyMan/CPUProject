
module not(A, Result);

   input  [31:0] A;
   output [31:0] Result;

   wire   [31:0] Result;

   assign Result = ~A;

endmodule

