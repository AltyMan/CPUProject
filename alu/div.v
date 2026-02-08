// DIV operation
// Signed division of A by B.
// Quotient is placed in Z[31:0] (LO register)
// Remainder is placed in Z[63:32] (HI register)
//---...---//
// Division by zero is safely handled

module div #(parameter integer DATA_WIDTH = 32)(
  input  wire [DATA_WIDTH-1:0] Q,   // dividend
  input  wire [DATA_WIDTH-1:0] M,   // divisor
  output wire [2*DATA_WIDTH-1:0] Z  // {remainder, quotient}
);

  //main regs
  reg  signed [DATA_WIDTH:0]   A_reg;   // remainder
  reg  signed [DATA_WIDTH:0]   M_reg;   // divisor (extended)
  reg         [DATA_WIDTH-1:0] Q_reg;   // quotient
  reg         [2*DATA_WIDTH:0] AQ_reg;

  integer i;

  //prep for algorithm, check signs
  wire Q_sign = Q[DATA_WIDTH-1];
  wire M_sign = M[DATA_WIDTH-1];
  wire Q_out_sign = Q_sign ^ M_sign;   // quotient sign
  wire A_out_sign = Q_sign;             // remainder follows dividend
  
  wire [DATA_WIDTH-1:0] Q_mag = Q_sign ? (~Q + 1'b1) : Q; //check if signed
  wire [DATA_WIDTH-1:0] M_mag = M_sign ? (~M + 1'b1) : M;

  reg [DATA_WIDTH-1:0] Q_u;   // unsigned quotient
  reg [DATA_WIDTH-1:0] A_u;   // unsigned remainder

  reg signed [DATA_WIDTH-1:0] Q_s;  // signed quotient
  reg signed [DATA_WIDTH-1:0] A_s;  // signed remainder

  always @(*) begin
    if (M_mag == '0) begin
      // divide-by-zero
      Q_u = {DATA_WIDTH{1'b1}};
      A_u = Q_mag;
    end else begin
      A_reg = '0;
      Q_reg = Q_mag;
      M_reg = {1'b0, M_mag};   // extend and force positive divisor

      for (i = 0; i < DATA_WIDTH; i = i + 1) begin
        AQ_reg = {A_reg, Q_reg};
        AQ_reg = AQ_reg << 1;

        A_reg  = AQ_reg[2*DATA_WIDTH : DATA_WIDTH];
        Q_reg  = AQ_reg[DATA_WIDTH-1 : 0];

        if (A_reg >= 0)
          A_reg = A_reg - M_reg;
        else
          A_reg = A_reg + M_reg;

        if (A_reg >= 0)
          Q_reg[0] = 1'b1;
        else
          Q_reg[0] = 1'b0;
      end

      if (A_reg < 0)
        A_reg = A_reg + M_reg;

      Q_u = Q_reg;
      A_u = A_reg[DATA_WIDTH-1:0];
    end


    //apply signs
    Q_s = Q_out_sign ? (~Q_u + 1'b1) : Q_u;
    A_s = A_out_sign ? (~A_u + 1'b1) : A_u;
  end

  // {remainder, quotient}
  assign Z = {A_s, Q_s};

endmodule
