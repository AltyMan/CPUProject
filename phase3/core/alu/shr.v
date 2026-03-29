module shr #(parameter DATA_WIDTH = 32)(
   input  wire [DATA_WIDTH-1:0] A, 
   input  wire [DATA_WIDTH-1:0] B,
   output wire [DATA_WIDTH-1:0] Z
);

wire [4:0] sh;
assign sh = B[4:0];

wire [DATA_WIDTH-1:0] s0, s1, s2, s3, s4;

// Stage 0: Shift right by 1, pad with 1 zero
assign s0 = sh[0] ? {1'b0, A[DATA_WIDTH-1:1]} : A;
// Stage 1: Shift right by 2, pad with 2 zeros
assign s1 = sh[1] ? {2'b00, s0[DATA_WIDTH-1:2]} : s0;
// Stage 2: Shift right by 4, pad with 4 zeros
assign s2 = sh[2] ? {4'b0000, s1[DATA_WIDTH-1:4]} : s1;
// Stage 3: Shift right by 8, pad with 8 zeros
assign s3 = sh[3] ? {8'h00, s2[DATA_WIDTH-1:8]} : s2;
// Stage 4: Shift right by 16, pad with 16 zeros
assign s4 = sh[4] ? {16'h0000, s3[DATA_WIDTH-1:16]} : s3;

assign Z = s4;

endmodule