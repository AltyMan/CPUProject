`include "alu/and.v"
`include "alu/or.v"
`include "alu/not.v"
`include "alu/xor.v"
`include "alu/nor.v"
`include "alu/neg.v"
`include "alu/adder.v"
`include "alu/mul.v"
`include "alu/div.v"
`include "alu/rol.v"
`include "alu/ror.v"
`include "alu/shl.v"
`include "alu/shr.v"
`include "alu/shra.v"
module alu #(parameter DATA_WIDTH = 32, SEL_WIDTH = 16, INIT = 32'h0)(
    input wire [DATA_WIDTH-1:0] A,
    input wire [DATA_WIDTH-1:0] B,
    input wire [SEL_WIDTH-1:0]  ALU_Sel,
    output wire [DATA_WIDTH-1:0] ZHigh, ZLow
);

wire cin;
assign cin = 1'b0;

wire [DATA_WIDTH-1:0] B_neg;
assign B_neg = ~B + 1;

wire [DATA_WIDTH-1:0] Z_and, Z_or, Z_not, Z_xor, Z_nor, Z_neg, Z_rol, Z_ror, Z_shl, Z_shr, Z_shra;
wire [DATA_WIDTH-1:0] Z_add, Z_sub; // Note overflow for add
wire [2*DATA_WIDTH-1:0] Z_mul, Z_div;

andf and(A, B, Z_and);
orit or(A, B, Z_or);
not not(A, Z_not);
xor xor(A, B, Z_xor);
nor nor(A, B, Z_nor);
neg neg(A, Z_neg);
rol rol(A, B, Z_rol);
ror ror(A, B, Z_ror);
shl shl(A, B, Z_shl);
shr shr(A, B, Z_shr);
shra shra(A, B, Z_shra);
RCA add(A, B, Z_add);
RCA sub(A, B_neg, Z_sub); // To be touched on later
boothmul mul(A, B, Z_mul);
nonresdiv div(A, B, Z_div);

reg [2*DATA_WIDTH-1:0] Z;

always @ (*) begin
    case (ALU_Sel)
        16'd0: Z = Z_and;
        16'd1: Z = Z_or;
        16'd2: Z = Z_not;
        16'd3: Z = Z_xor;
        16'd4: Z = Z_nor;
        16'd5: Z = Z_neg;
        16'd6: Z = Z_rol;
        16'd7: Z = Z_ror;
        16'd8: Z = Z_shl;
        16'd9: Z = Z_shr;
        16'd10: Z = Z_shra;
        16'd11: Z = Z_add;
        16'd12: Z = Z_sub;
        16'd13: Z = Z_mul;
        16'd14: Z = Z_div;
        default: Z = {2*DATA_WIDTH{1'b0}};
    endcase
end
assign ZHigh = Z[2*DATA_WIDTH-1:DATA_WIDTH];
assign ZLow = Z[DATA_WIDTH-1:0];
endmodule