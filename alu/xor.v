module xor #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A, B,
    output [DATA_WIDTH-1:0] Result
);
wire   [DATA_WIDTH-1:0] A_neg, B_neg;
assign A_neg = ~A;
assign B_neg = ~B;
wire   [DATA_WIDTH-1:0] Result;
assign Result = (A & B_neg) | (A_neg & B);
endmodule