module CON_FF (
    input wire        clk,
    input wire        reset,
    input wire        CONin,
    input wire [3:0]  cond,        // condition selector
    input wire [31:0] test_value,  //checked for branch
    output reg        CON
);

    wire [1:0] C2;
    assign C2 = cond[1:0];
    reg condition_met;

    always @(*) begin
        case (C2)
            2'b00: condition_met = 1'b0;                           // never
            2'b01: condition_met = 1'b1;                           // always
            2'b10: condition_met = (test_value == 32'd0);         // if zero
            2'b11: condition_met = (test_value != 32'd0);         //if nonzero
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
