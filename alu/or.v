module orit #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A, B,
    output [DATA_WIDTH-1:0] C
);
wire   [DATA_WIDTH-1:0] C;
assign C = A | B;
endmodule