module shr #(parameter DATA_WIDTH = 32)(
   input [DATA_WIDTH-1:0] A, B,
   output [DATA_WIDTH-1:0] Z
);

   wire   [4:0]  sh;
   wire   [DATA_WIDTH-1:0] r;
   assign sh = B[4:0];
   assign r = A >> sh;
   assign Z = r;

endmodule

