`timescale 1ns/10ps

// Half Adder
module halfadder(a, b, sum, carry);

  input  a, b;
  output sum, carry;
  
  reg sum;
  reg carry;
  
  always@(a or b)
      begin
          sum   = a ^ b;
          carry = a & b;
      end
endmodule


// Full Adder
module fulladder(a, b, cin, sum, cout);

  input  a, b, cin;
  output sum, cout;
  
  reg sum;
  reg cout;
  
  reg s1;
  reg c1;
  reg c2;
  
  always@(a or b or cin)
      begin
          s1   = a ^ b;
          c1   = a & b;
  
          sum  = s1 ^ cin;
          c2   = s1 & cin;
  
          cout = c1 | c2;
      end
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
