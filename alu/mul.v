module boothmul #(parameter DATA_WIDTH = 32)(
    input  wire [DATA_WIDTH-1:0] Q,
    input  wire [DATA_WIDTH-1:0] M,
    output wire [2*DATA_WIDTH-1:0] A
);
    wire [DATA_WIDTH+1:0] M_padded = {M[DATA_WIDTH-1], M, 1'b0}; // 34-bit M for Booth encoding

    wire [2*DATA_WIDTH-1:0] Q_ext = {{DATA_WIDTH{Q[DATA_WIDTH-1]}}, Q};

    integer i;
    reg [2*DATA_WIDTH-1:0] prod;
    reg [2*DATA_WIDTH-1:0] partial;
    reg [2*DATA_WIDTH-1:0] cin;

    always @(*) begin
        prod = 64'd0;
        for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
            cin = 64'd0;
            case (M_padded[2*i +: 3]) // examine 3 bits for Booth encoding
                3'b000: partial = 64'd0;
                3'b001: partial = Q_ext;
                3'b010: partial = Q_ext;
                3'b011: partial = Q_ext << 1;
                3'b100: begin partial = ~(Q_ext << 1); cin = 64'd1; end // for negative, invert bits with cin
                3'b101: begin partial = ~Q_ext;        cin = 64'd1; end
                3'b110: begin partial = ~Q_ext;        cin = 64'd1; end
                3'b111: partial = 64'd0;
            endcase
            prod = prod + (partial << (2*i)) + (cin << (2*i)); // route cin to LSB of this row's addition
        end
    end
    
    assign A = prod;

endmodule