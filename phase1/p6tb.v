`timescale 1ns / 10ps

module p1tb();
    reg clock, clear;
    reg [31:0] Mdatain;
    reg [15:0] ALUControl;
    reg [31:0] Rin, Rout;
    reg IRin, MARin, RZout, RYin, RBin, PCjump, MDRread;

    parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,
    Reg_load2a = 4'b0011, Reg_load2b = 4'b0100,
    T0 = 4'b0101, T1 = 4'b0110, T2 = 4'b0111, T3 = 4'b1000,
    T4 = 4'b1001, T5 = 4'b1010, T6 = 4'b1011;
    reg [3:0] Present_state = Default;
    
DataPath dp(
    .clock(clock),
    .clear(clear),
    .Mdatain(Mdatain),
    .ALUControl(ALUControl),
    .Rin(Rin),
    .Rout(Rout),
    .IRin(IRin),
    .MARin(MARin),
    .RZout(RZout),
    .RYin(RYin),
    .RBin(RBin),
    .PCjump(PCjump),
    .MDRread(MDRread)
);

initial begin
    clock = 0;
    forever #10 clock = ~clock;
end

initial begin
    $dumpfile("phase1/p1tb.vcd");
    $dumpvars(0, p1tb);
    // initialize variables
    clear = 1;
    Mdatain = 32'h0;
    ALUControl = 16'h0;
    Rin = 32'h0;
    Rout = 32'h0;
    IRin = 0;
    MARin = 0;
    RZout = 0;
    RYin = 0;
    RBin = 0;
    PCjump = 0;
    MDRread = 0;
    // release clear
    #20 clear = 0;
    
    #1000 $finish;
end

/*initial begin
    #20 Present_state = Reg_load1a;
    forever #40 Present_state = Present_state + 4'b0001;
end*/

always @(negedge clock) begin
    case (Present_state)
        Default : Present_state = Reg_load1a;
        Reg_load1a : Present_state = Reg_load1b;
        Reg_load1b : Present_state = Reg_load2a;
        Reg_load2a : Present_state = Reg_load2b;
        Reg_load2b : Present_state = T0;
        T0 : Present_state = T1;
        T1 : Present_state = T2;
        T2 : Present_state = T3;
        T3 : Present_state = T4;
        T4 : Present_state = T5;
        T5: Present_state = T6;
    endcase
end

always @(Present_state) begin
    case (Present_state)
        Default: begin
            Rout <= 32'h0; // Clear all outputs (PCout, Zlowout, MDRout, etc.)
            MARin <= 0; Rin <= 32'h0; // Clear all register inputs
            IRin <= 0; RYin <= 0;
            MDRread <= 0; ALUControl <= 16'd0;
            Mdatain <= 32'h00000000;
        end
        Reg_load1a: begin
            Mdatain <= 32'd19;
            MDRread = 0; Rin[21] = 0;
            MDRread <= 1; Rin[21] <= 1;
            #20 MDRread <= 0; Rin[21] <= 0;
        end
        Reg_load1b: begin
            Rout[21] <= 1; Rin[3] <= 1; // MDRout, R3in
            #20 Rout[21] <= 0; Rin[3] <= 0; // initialize R3 with the value 0x34
        end
        Reg_load2a: begin
            Mdatain <= 32'd0;
            MDRread <= 1; Rin[21] <= 1;
            #20 MDRread <= 0; Rin[21] <= 0;
        end
        Reg_load2b: begin
            Rout[21] <= 1; Rin[1] <= 1; // MDRout, R1in
            #20 Rout[21] <= 0; Rin[1] <= 0; // initialize R1 with the value 0x45
        end
        T0: begin
            Rout[20] <= 1; MARin <= 1; Rin[19] <= 1; // PCout, MARin, Zin->ZLowin
            #20 Rout[20] <= 0; MARin <= 0; Rin[19] <= 0;
        end
        T1: begin
            Rout[19] <= 1; Rin[20] <= 1; MDRread <= 1; Rin[21] <= 1; // Zlowout, PCin, Read->MDRread, MDRin
            Mdatain <= 32'h112B0000; // opcode for "div R3, R1"
            #20 Rout[19] <= 0; Rin[20] <= 0; MDRread <= 0; Rin[21] <= 0;
        end
        T2: begin
            Rout[21] <= 1; IRin <= 1; // MDRout, IRin
            #20 Rout[21] <= 0; IRin <= 0;
        end
        T3: begin
            Rout[3] <= 1; RYin <= 1; // R3out, Yin->RYin
            #20 Rout[3] <= 0; RYin <= 0;
        end
        T4: begin
            Rout[1] <= 1; ALUControl <= 16'd15; Rin[18] <= 1; Rin[19] <= 1; // R1out, DIV operation, Zin->ZLowin
            #20 Rout[1] <= 0; ALUControl <= 16'd0; Rin[18] <= 0; Rin[19] <= 0;
        end
        T5: begin
            Rout[19] <= 1; Rin[17] <= 1; // Zlowout, LOin
            #20 Rout[19] <= 0; Rin[17] <= 0;
        end
        T6: begin
            Rout[18] <= 1; Rin[16] <= 1; // Zhighout, HIin
            #20 Rout[18] <= 0; Rin[16] <= 0;
        end
    endcase
end

endmodule