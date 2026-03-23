module rol #(parameter DATA_WIDTH = 32)(
   input  wire [DATA_WIDTH-1:0] A, 
   input  wire [DATA_WIDTH-1:0] B,
   output wire [DATA_WIDTH-1:0] Z
);

wire [4:0] sh;
assign sh = B[4:0];

wire [DATA_WIDTH-1:0] s0, s1, s2, s3, s4;

// Stage 0: Rotate by 1 bit if sh[0] is 1
assign s0 = sh[0] ? {A[DATA_WIDTH-2:0], A[DATA_WIDTH-1]} : A;
// Stage 1: Rotate by 2 bits if sh[1] is 1
assign s1 = sh[1] ? {s0[DATA_WIDTH-3:0], s0[DATA_WIDTH-1:DATA_WIDTH-2]} : s0;
// Stage 2: Rotate by 4 bits if sh[2] is 1
assign s2 = sh[2] ? {s1[DATA_WIDTH-5:0], s1[DATA_WIDTH-1:DATA_WIDTH-4]} : s1;
// Stage 3: Rotate by 8 bits if sh[3] is 1
assign s3 = sh[3] ? {s2[DATA_WIDTH-9:0], s2[DATA_WIDTH-1:DATA_WIDTH-8]} : s2;
// Stage 4: Rotate by 16 bits if sh[4] is 1
assign s4 = sh[4] ? {s3[DATA_WIDTH-17:0], s3[DATA_WIDTH-1:DATA_WIDTH-16]} : s3;

assign Z = s4;

endmodule