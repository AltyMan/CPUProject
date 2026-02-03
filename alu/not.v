
module not #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A,
    output [DATA_WIDTH-1:0] Result
);
wire   [DATA_WIDTH-1:0] Result;
assign Result = ~A;
endmodule