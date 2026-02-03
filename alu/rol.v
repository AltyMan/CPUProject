module rol #(parameter DATA_WIDTH = 32)(
   input [DATA_WIDTH-1:0] A, B,
   output [DATA_WIDTH-1:0] Z
);

   wire   [4:0]  sh;
   wire   [DATA_WIDTH-1:0] r;

   assign sh = B[4:0];

   // Rotate left:
   // (A << sh) moves bits left
   // (A >> (32 - sh)) wraps the bits around
   assign r = (A << sh) | (A >> (6'd32 - sh));
   assign Z = r;

endmodule