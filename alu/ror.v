module ror #(parameter DATA_WIDTH = 32)(
   input  wire [DATA_WIDTH-1:0] A, 
   input  wire [DATA_WIDTH-1:0] B,
   output wire [DATA_WIDTH-1:0] Z
);

wire [4:0] sh;
assign sh = B[4:0];

wire [DATA_WIDTH-1:0] s0, s1, s2, s3, s4;

// Stage 0: Rotate right by 1
assign s0 = sh[0] ? {A[0], A[DATA_WIDTH-1:1]} : A;
// Stage 1: Rotate right by 2
assign s1 = sh[1] ? {s0[1:0], s0[DATA_WIDTH-1:2]} : s0;
// Stage 2: Rotate right by 4
assign s2 = sh[2] ? {s1[3:0], s1[DATA_WIDTH-1:4]} : s1;
// Stage 3: Rotate right by 8
assign s3 = sh[3] ? {s2[7:0], s2[DATA_WIDTH-1:8]} : s2;
// Stage 4: Rotate right by 16
assign s4 = sh[4] ? {s3[15:0], s3[DATA_WIDTH-1:16]} : s3;

assign Z = s4;

endmodule