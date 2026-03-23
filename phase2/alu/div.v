// DIV operation
// Signed division of A by B.
// Quotient is placed in Z[31:0] (LO register)
// Remainder is placed in Z[63:32] (HI register)
//---...---//
// Division by zero is safely handled

module nonresdiv #(parameter integer DATA_WIDTH = 32)(
  input  wire [DATA_WIDTH-1:0] Q,   // dividend
  input  wire [DATA_WIDTH-1:0] M,   // divisor
  output reg  [2*DATA_WIDTH-1:0] Z  // {remainder, quotient}
);

  reg signed [DATA_WIDTH:0] A_reg;
  reg        [DATA_WIDTH-1:0] Q_reg;
  integer i;

  // Extract signs
  wire Q_sign = Q[DATA_WIDTH-1];
  wire M_sign = M[DATA_WIDTH-1];

  // Pre-compute abs. vals
  wire [DATA_WIDTH-1:0] Q_mag = Q_sign ? (~Q + 1'b1) : Q;
  wire [DATA_WIDTH-1:0] M_mag = M_sign ? (~M + 1'b1) : M;
  
  wire signed [DATA_WIDTH:0] M_ext = {1'b0, M_mag}; // Extended M_mag
  always @(*) begin
    if (M == 0) begin
      Z = {Q_mag, {DATA_WIDTH{1'b1}}}; // Fast exit for div by zero 
    end else begin
      A_reg = 0;
      Q_reg = Q_mag;

      for (i = 0; i < DATA_WIDTH; i = i + 1) begin
        // Hardwired bit-shift
        A_reg = {A_reg[DATA_WIDTH-1:0], Q_reg[DATA_WIDTH-1]};
        Q_reg = {Q_reg[DATA_WIDTH-2:0], 1'b0};
        // Add/Sub operation
        if (A_reg >= 0)
          A_reg = A_reg - M_ext;
        else
          A_reg = A_reg + M_ext;
        // Set quotient bit
        Q_reg[0] = (A_reg >= 0) ? 1'b1 : 1'b0;
      end
      // Final remainder restoration
      if (A_reg < 0) begin
        A_reg = A_reg + M_ext;
      end
      // Apply output signs
      if (Q_sign ^ M_sign) Q_reg = ~Q_reg + 1'b1;
      if (Q_sign)          A_reg = ~A_reg + 1'b1;

      Z = {A_reg[DATA_WIDTH-1:0], Q_reg};
    end
  end

endmodule