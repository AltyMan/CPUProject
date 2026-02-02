// 32x32 sequential add-shift multiplier (classic {C,A,Q} datapath)
// Supports unsigned OR signed (2's complement) via is_signed input.
//
// Operation (core):
//  - If Q[0]==1: {C,A} = A + M
//  - Shift-right {C,A,Q} by 1 (end of each cycle)
//  - 32 cycles
//
// Signed mode:
//  - Convert operands to magnitudes (abs) before run
//  - After unsigned multiply, negate 64-bit product if signs differ

module seq_mul32 (
    input              clk,
    input              reset,       // synchronous reset
    input              start,       // pulse to start
    input              is_signed,   // 1 = signed multiply, 0 = unsigned
    input      [31:0]  op_a,
    input      [31:0]  op_b,
    output reg [63:0]  product,
    output reg         busy,
    output reg         done
);

    localparam S_IDLE = 2'd0;
    localparam S_RUN  = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0] state;

    // Core datapath registers (match the diagram)
    reg [31:0] A;   // accumulator
    reg [31:0] Q;   // multiplier shift register
    reg [31:0] M;   // multiplicand register
    reg        C;   // carry flip-flop

    reg [5:0]  count;      // 0..31
    reg        neg_result; // whether final product should be negated (signed mode)

    // Unsigned adder result: {carry,sum} = A + M
    wire [32:0] add_res = {1'b0, A} + {1'b0, M};

    // Helpers for abs value in signed mode (still 32-bit magnitude)
    function [31:0] abs32;
        input [31:0] x;
        begin
            abs32 = x[31] ? (~x + 32'd1) : x;
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state      <= S_IDLE;
            A          <= 32'd0;
            Q          <= 32'd0;
            M          <= 32'd0;
            C          <= 1'b0;
            count      <= 6'd0;
            product    <= 64'd0;
            busy       <= 1'b0;
            done       <= 1'b0;
            neg_result <= 1'b0;
        end else begin
            done <= 1'b0; // 1-cycle pulse

            case (state)
                S_IDLE: begin
                    busy <= 1'b0;

                    if (start) begin
                        // Decide sign correction for signed multiply
                        // If signed and signs differ -> negate at end
                        neg_result <= is_signed & (op_a[31] ^ op_b[31]);

                        // Load magnitudes into core (unsigned multiply)
                        M <= is_signed ? abs32(op_a) : op_a;
                        Q <= is_signed ? abs32(op_b) : op_b;

                        // Clear partial product
                        A     <= 32'd0;
                        C     <= 1'b0;
                        count <= 6'd0;

                        busy  <= 1'b1;
                        state <= S_RUN;
                    end
                end

                S_RUN: begin
                    // Compute "after add" then shift {C,A,Q} right by 1.
                    // We do it using temporaries to reflect the diagram:
                    //   (1) optional add into {C,A}
                    //   (2) shift-right at end of cycle
                    begin : STEP
                        reg [31:0] A_after;
                        reg        C_after;
                        reg [64:0] CAQ;

                        // (1) Add/Noadd
                        if (Q[0]) begin
                            A_after = add_res[31:0];
                            C_after = add_res[32];
                        end else begin
                            A_after = A;
                            C_after = 1'b0; // matches the classic "add 0" path
                        end

                        // (2) Shift right at end of cycle
                        CAQ = {C_after, A_after, Q};
                        CAQ = CAQ >> 1; // logical shift (unsigned core)

                        // Update registers
                        C <= CAQ[64];
                        A <= CAQ[63:32];
                        Q <= CAQ[31:0];
                    end

                    // Count cycles
                    if (count == 6'd31) begin
                        state <= S_DONE;
                    end
                    count <= count + 6'd1;
                end

                S_DONE: begin
                    // Core product is {A,Q}
                    // Apply sign correction if needed
                    if (neg_result)
                        product <= (~{A, Q}) + 64'd1; // two's complement negate
                    else
                        product <= {A, Q};

                    done  <= 1'b1;
                    busy  <= 1'b0;
                    state <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule


