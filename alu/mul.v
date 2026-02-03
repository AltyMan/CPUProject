module mul #(parameter DATA_WIDTH = 32, HALF_WIDTH = 16, INIT=32'h0)(
    input [DATA_WIDTH-1:0] Q,
    input [DATA_WIDTH-1:0] M,
    output [DATA_WIDTH-1:0] HI,
    output [DATA_WIDTH-1:0] LO
);

reg [2*DATA_WIDTH-1:0] prod;
wire [DATA_WIDTH:0] M_padded;
assign M_padded = {M, 1'b0};

integer i;
reg [2*DATA_WIDTH-1:0] partial;

wire [2*DATA_WIDTH-1:0] Q_ext;
assign Q_ext = {{DATA_WIDTH{Q[DATA_WIDTH-1]}}, Q};

wire [2*DATA_WIDTH-1:0] Q_neg;
assign Q_neg = ~Q_ext + 1;
always @(*) begin
    prod = 64'd0;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
        case (M_padded[2*i +: 3])
            3'b000: partial = 0;
            3'b001: partial = Q_ext;
            3'b010: partial = Q_ext;
            3'b011: partial = Q_ext << 1;
            3'b100: partial = Q_neg << 1;
            3'b101: partial = Q_neg;
            3'b110: partial = Q_neg;
            3'b111: partial = 0;
        endcase
        prod = prod + (partial << (2*i));

    end
end
assign HI = prod[2*DATA_WIDTH-1:DATA_WIDTH];
assign LO = prod[DATA_WIDTH-1:0];

endmodule