module CON_FF (
    input wire        clk,
    input wire        reset,
    input wire        CONin,
    input wire [2:0]  cond,        // condition selector
    input wire [31:0] test_value,  //checked for branch
    output reg        CON
);

    reg condition_met;

    always @(*) begin
        case (cond)
            3'b000: condition_met = 1'b0;                           // never
            3'b001: condition_met = 1'b1;                           // always
            3'b010: condition_met = (test_value == 32'd0);         // if zero
            3'b011: condition_met = (test_value != 32'd0);         //if nonzero
            3'b100: condition_met = (test_value[31] == 1'b0);     // if positive or zero
            3'b101: condition_met = (test_value[31] == 1'b1);     // if negative
            default: condition_met = 1'b0;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            CON <= 1'b0;
        else if (CONin)
            CON <= condition_met;
    end

endmodule
