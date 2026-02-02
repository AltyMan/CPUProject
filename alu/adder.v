`timescale 1ns/10ps

// Half Adder
module halfadder(a, b, sum, carry);

input  a, b;
output sum, carry;

assign sum   = a ^ b;
assign carry = a & b;

  
endmodule


// Full Adder
module fulladder(a, b, cin, sum, cout);

  input  a, b, cin;
  output sum, cout;
  
  
  wire s1;
  wire c1;
  wire c2;
  
  halfadder HA1(a,  b,   s1, c1);
  halfadder HA2(s1, cin, sum, c2);

  assign cout = c1 | c2;
endmodule


//Ripple Carry Adder
module RCA(A, B, Result);

  input  [31:0] A, B;
  output [31:0] Result;
  
  reg    [31:0] Result;
  reg    [32:0] LocalCarry;
  
  integer i;

  always@(A or B)
      begin
          LocalCarry = 33'd0;
          for(i = 0; i < 32; i = i + 1)
              begin
                  Result[i] = A[i] ^ B[i] ^ LocalCarry[i];
                  LocalCarry[i+1] = (A[i] & B[i]) |
                                    (LocalCarry[i] & (A[i] | B[i]));
              end
      end
endmodule

