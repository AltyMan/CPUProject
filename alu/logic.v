module f_and #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A, B,
    output wire [DATA_WIDTH-1:0] C
);
assign C = A & B;
endmodule

module f_or #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A, B,
    output wire [DATA_WIDTH-1:0] C
);
assign C = A | B;
endmodule

module f_not #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A,
    output wire [DATA_WIDTH-1:0] Result
);
assign Result = ~A;
endmodule

module f_xor #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A, B,
    output wire [DATA_WIDTH-1:0] Result
);
wire   [DATA_WIDTH-1:0] A_neg, B_neg;
assign A_neg = ~A;
assign B_neg = ~B;
assign Result = (A & B_neg) | (A_neg & B);
endmodule

module f_nor #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A, B,
    output wire [DATA_WIDTH-1:0] Result
);
wire   [DATA_WIDTH-1:0] A_neg, B_neg;
assign A_neg = ~A;
assign B_neg = ~B;
assign Result = A_neg & B_neg;
endmodule