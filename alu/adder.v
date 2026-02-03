
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





// 4-bit CLA
module cla4(
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       P,
    output       G
);

    wire [3:0] p, g;
    wire c1, c2, c3;

    assign p = A ^ B;
    assign g = A & B;

    assign c1 = g[0] | (p[0] & Cin);
    assign c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & Cin);
    assign c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & Cin);

    assign Sum[0] = p[0] ^ Cin;
    assign Sum[1] = p[1] ^ c1;
    assign Sum[2] = p[2] ^ c2;
    assign Sum[3] = p[3] ^ c3;

    assign P = p[3] & p[2] & p[1] & p[0];
    assign G = g[3]
             | (p[3] & g[2])
             | (p[3] & p[2] & g[1])
             | (p[3] & p[2] & p[1] & g[0]);

endmodule


module CLA32(
    input  [31:0] A,
    input  [31:0] B,
    input         cin,
    output [31:0] Result,
    output        Cout
);

    wire [31:0] Bx;
    wire [7:0]  Pblk, Gblk;
    wire [8:0]  Cblk;

    assign Bx = B ^ {32{cin}};
    assign Cblk[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            assign Cblk[i+1] = Gblk[i] | (Pblk[i] & Cblk[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin
            cla4 U(
                .A   (A[4*i +: 4]),
                .B   (Bx[4*i +: 4]),
                .Cin (Cblk[i]),
                .Sum (Result[4*i +: 4]),
                .P   (Pblk[i]),
                .G   (Gblk[i])
            );
        end
    endgenerate

    assign Cout = Cblk[8];

endmodule
