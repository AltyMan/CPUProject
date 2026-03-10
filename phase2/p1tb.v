`timescale 1ns / 10ps

module tb();
    reg clock, clear;
    wire [31:0] Mdatain;
    reg [15:0] ALUControl;

    reg IRin, MARin, RZout, RYin, RBin, PCjump, MDRread;

    //ram signals
    reg GPR_Rin, GPR_Rout;
    reg [15:0] RinHI, RoutHI;

    reg Gra, Grb, Grc, BAout, Cout;

    reg RAMread, RAMwrite;

    parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,
    Reg_load2a = 4'b0011, Reg_load2b = 4'b0100,
    Reg_load3a = 4'b0101, Reg_load3b = 4'b0110,
    T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010,
    T4 = 4'b1011, T5 = 4'b1100, T6 = 4'b1101, T7 = 4'b1110;
    reg [3:0] Present_state = Default;
    
DataPath dp(
    .clock(clock),
    .clear(clear),
    .Mdatain(Mdatain),
    .ALUControl(ALUControl),
    .GPR_Rin(GPR_Rin),
    .GPR_Rout(GPR_Rout),
    .IRin(IRin),
    .MARin(MARin),
    .RZout(RZout),
    .RYin(RYin),
    .RBin(RBin),
    .PCjump(PCjump),
    .MDRread(MDRread),
    .RinHI(RinHI),
    .RoutHI(RoutHI),
    .Gra(Gra),
    .Grb(Grb),
    .Grc(Grc),
    .BAout(BAout),
    .Cout(Cout),
    .RAMread(RAMread),
    .RAMwrite(RAMwrite)
);

initial begin
    clock = 0;
    forever #10 clock = ~clock;
end

initial begin
    $dumpfile("phase2/p1tb.vcd");
    $dumpvars(0, tb);
    // initialize variables
    clear = 1;
    ALUControl = 16'h0;
    RinHi = 16'h0;
    RoutHi = 16'h0;
    IRin = 0;
    MARin = 0;
    RZout = 0;
    RYin = 0;
    RBin = 0;
    PCjump = 0;
    MDRread = 0;

    // RAM control signals initialization
    GPR_Rin = 0;
    GPR_Rout = 0;

    Gra = 0;
    Grb = 0;
    Grc = 0;
    BAout = 0;
    Cout = 0;

    RAMread = 0;
    RAMwrite = 0;

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
        Reg_load2b : Present_state = Reg_load3a;
        Reg_load3a : Present_state = Reg_load3b;
        Reg_load3b : Present_state = T0;
        T0 : Present_state = T1;
        T1 : Present_state = T2;
        T2 : Present_state = T3;
        T3 : Present_state = T4;
        T4 : Present_state = T5;
        T5 : Present_state = T6;
        T6 : Present_state = T7;
    endcase
end

/*
T0 PCout MARin IncPC Zin
T1 Zlowout PCin Read MDRin
T2 MDRout IRin
T3 Grb BAout Yin
T4 Cout ADD Zin
T5 Zlowout MARin
T6 Read MDRin
T7 MDRout Gra Rin
*/

always @(Present_state) begin
    case (Present_state)
        Default: begin
            // Rout <= 32'h0; // Clear all outputs (PCout, Zlowout, MDRout, etc.)
            // MARin <= 0; Rin <= 32'h0; // Clear all register inputs
            // IRin <= 0; RYin <= 0;
            // MDRread <= 0; ALUControl <= 16'd0;

        end
        Reg_load1a: begin
            // MDRread = 0; Rin[21] = 0;
            // MDRread <= 1; Rin[21] <= 1;
            // #20 MDRread <= 0; Rin[21] <= 0;


        end
        Reg_load1b: begin
            // Rout[21] <= 1; Rin[5] <= 1; // MDRout, R5in
            // #20 Rout[21] <= 0; Rin[5] <= 0; // initialize R5 with the value 0x34

        end
        Reg_load2a: begin
            MDRread <= 1; Rin[21] <= 1;
            #20 MDRread <= 0; Rin[21] <= 0;
        end
        Reg_load2b: begin
            Rout[21] <= 1; Rin[6] <= 1; // MDRout, R6in
            #20 Rout[21] <= 0; Rin[6] <= 0; // initialize R6 with the value 0x45
        end
        Reg_load3a: begin
            MDRread <= 1; Rin[21] <= 1;
            #20 MDRread <= 0; Rin[21] <= 0;
        end
        Reg_load3b: begin
            Rout[21] <= 1; Rin[2] <= 1; // MDRout, R2in
            #20 Rout[21] <= 0; Rin[2] <= 0; // initialize R2 with the value 0x67
        end


        T0: begin // PCout, MARin, IncPC, Zin
            RoutHI[4] <= 1; MARin <= 1; RinHI[3] <= 1;
            #20 RoutHI[4] <= 0; MARin <= 0; RinHI[3] <= 0;
        end
        T1: begin // Zlowout, PCin, Read, Mdatain[31..0], MDRin
            RoutHI[3] <= 1; RinHI[20] <= 1; RAMread <= 1; Rin[5] <= 1; MDRread <= 1; // Zlowout, PCin, Read->MDRread, MDRin
            #20 RoutHI[3] <= 0; RinHI[20] <= 0; RAMread <= 0; Rin[5] <= 0; MDRread <= 0;
        end
        T2: begin // MDRout, IRin
            RoutHI[5] <= 1; IRin <= 1; 
            #20 RoutHI[5] <= 0; IRin <= 0;
        end
        T3: begin // Grb, BAout, Yin
            Grb <= 1; BAout <= 1; RYin <= 1; // R5out, Yin->RYin
            #20 Grb <= 0; BAout <= 0; RYin <= 0;
        end
        T4: begin // Cout, ADD, Zin
            Cout <= 1; ALUControl <= 16'd12; RinHI[3] <= 1; 
            #20 Cout <= 0; ALUControl <= 16'd0; RinHI[3] <= 0;
        end
        T5: begin // Zlowout, MARin 
            RoutHI[3] <= 1; MARin <= 1;
            #20 RoutHI[3] <= 0; MARin <= 0;
        end
        T6: begin // Read, Mdatain[31..0], MDRin
            RAMread <= 1; Rin[5] <= 1; MDRread <= 1; // Read->MDRread, MDRin
            #20 RAMread <= 0; Rin[5] <= 0; MDRread <= 0;
        end
        T7: begin // MDRout, Gra, Rin
            RoutHI[5] <= 1; Gra <= 1; GPR_Rin <= 1; // MDRout, R2in
            #20 RoutHI[5] <= 0; Gra <= 0; GPR_Rin <= 0;
        end
    endcase
end

endmodule