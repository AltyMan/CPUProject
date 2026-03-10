module CON_FF (
  input  wire        clk,
  input  wire        reset,
  input  wire        CONin,
  input  wire [3:0]  cond,   // IR 22 - 19
  input  wire [31:0] bus,    
  output reg         CON
);

  wire [1:0] c2;
  assign c2 = cond[1:0];

  wire c2_00;
  wire c2_01;
  wire c2_10;
  wire c2_11;

  // This is the decoder block in the diagram.
  // Decodes the c2 IR bits 
  assign c2_00 = (c2 == 2'b00);
  assign c2_01 = (c2 == 2'b01);
  assign c2_10 = (c2 == 2'b10);
  assign c2_11 = (c2 == 2'b11);

  wire bus_is_zero;
  wire bus_is_nonzero;
  wire bus_is_positive;
  wire bus_is_negative;

  // = 0
  // |bus == OR all bits together
  assign bus_is_zero    = ~|bus;    

  // != 0
  //If any bit is 1 then the number is nonzero
  assign bus_is_nonzero =  |bus;   
  
  // >= 0
  // Reverse all the bits
  assign bus_is_positive = ~bus[31];
  
  // < 0
  // If the sign bit is 1 the number is negative
  assign bus_is_negative =  bus[31];            

  // Full CON logic
  // Now we connect the decoder outputs with the value checks
  // The OR gate at the end 
  wire con_next;
  assign con_next = (c2_00 & bus_is_zero) | (c2_01 & bus_is_nonzero) | (c2_10 & bus_is_positive)| (c2_11 & bus_is_negative);

  // CON flip-flop
  always @(posedge clk or posedge reset) begin
      if (reset)
          CON <= 1'b0;
      else if (CONin)
          CON <= con_next;
  end
endmodule
