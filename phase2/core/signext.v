// Phase 2


module signext #(parameter IN_W = 15)(
    input  wire [IN_W-1:0] in,
    output wire [31:0] out
);

    assign out = {{(32-IN_W){in[IN_W-1]}}, in};

endmodule
