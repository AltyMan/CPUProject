module f_and #(parameter DATA_WIDTH = 32)(
    input  wire [DATA_WIDTH-1:0] A, 
    input  wire [DATA_WIDTH-1:0] B,
    output wire [DATA_WIDTH-1:0] C
);
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bitwise_and
            and (C[i], A[i], B[i]);
        end
    endgenerate
endmodule

module f_or #(parameter DATA_WIDTH = 32)(
    input  wire [DATA_WIDTH-1:0] A, 
    input  wire [DATA_WIDTH-1:0] B,
    output wire [DATA_WIDTH-1:0] C
);
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bitwise_or
            or (C[i], A[i], B[i]);
        end
    endgenerate
endmodule

module f_not #(parameter DATA_WIDTH = 32)(
    input [DATA_WIDTH-1:0] A,
    output wire [DATA_WIDTH-1:0] C
);
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bitwise_not
            not (C[i], A[i]);
        end
    endgenerate
endmodule

module f_xor #(parameter DATA_WIDTH = 32)(
    input  wire [DATA_WIDTH-1:0] A, 
    input  wire [DATA_WIDTH-1:0] B,
    output wire [DATA_WIDTH-1:0] C
);
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_xor
            assign C[i] = A[i] ^ B[i]; 
        end
    endgenerate
endmodule

module f_nor #(parameter DATA_WIDTH = 32)(
    input  wire [DATA_WIDTH-1:0] A, 
    input  wire [DATA_WIDTH-1:0] B,
    output wire [DATA_WIDTH-1:0] C
);
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_nor
            assign C[i] = ~(A[i] | B[i]); 
        end
    endgenerate
endmodule