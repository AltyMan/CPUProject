module shra #(parameter DATA_WIDTH = 32)(
   input signed [DATA_WIDTH-1:0] A,
   input  [DATA_WIDTH-1:0] B,
   output signed [DATA_WIDTH-1:0] Z
);
   wire   [4:0]  sh;
   wire   [DATA_WIDTH-1:0] r;
   assign sh = B[4:0];
   assign r = A >>> sh;
   assign Z = r;

endmodule

