// DIV operation
// Signed division of A by B.
// Quotient is placed in Z[31:0] (LO register)
// Remainder is placed in Z[63:32] (HI register)
//---...---//
// Division by zero is safely handled

module nonresdiv(input [31:0] A, input [31:0] B, output [63:0] Z);
  wire signed [31:0] a = A;
  wire signed [31:0] b = B;

  wire signed [31:0] q = (b == 0) ? 32'sd0 : (a / b);
  wire signed [31:0] r = (b == 0) ? 32'sd0 : (a % b);

  assign Z = {r, q};
endmodule
