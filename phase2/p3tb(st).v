`timescale 1ns / 10ps

module tb();
    reg clock, clear;
    reg [15:0] ALUControl;

    reg IRin, MARin, RZout, RYin, RBin, PCjump, MDRread;
    reg GPR_Rin, GPR_Rout;
    reg [15:0] RinHI, RoutHI;

    reg Gra, Grb, Grc, BAout, Cout;
    reg RAMread, RAMwrite;
    reg InPortStrobe, OutPortEnable;

    // Define distinct states for all 4 cases sequentially
    parameter Default = 6'd0,
              // Case 1: ld R7, 0x65 (Requires T0-T7)
              C1_T0 = 6'd1, C1_T1 = 6'd2, C1_T2 = 6'd3, C1_T3 = 6'd4, C1_T4 = 6'd5, C1_T5 = 6'd6, C1_T6 = 6'd7, C1_T7 = 6'd8,
              // Case 2: ld R0, 0x72(R2) (Requires T0-T7)
              C2_T0 = 6'd9, C2_T1 = 6'd10, C2_T2 = 6'd11, C2_T3 = 6'd12, C2_T4 = 6'd13, C2_T5 = 6'd14, C2_T6 = 6'd15, C2_T7 = 6'd16,
              // Case 3: ldi R7, 0x65 (Requires T0-T5)
              C3_T0 = 6'd17, C3_T1 = 6'd18, C3_T2 = 6'd19, C3_T3 = 6'd20, C3_T4 = 6'd21, C3_T5 = 6'd22,
              // Case 4: ldi R0, 0x72(R2) (Requires T0-T5)
              C4_T0 = 6'd23, C4_T1 = 6'd24, C4_T2 = 6'd25, C4_T3 = 6'd26, C4_T4 = 6'd27, C4_T5 = 6'd28;

    reg [5:0] Present_state = Default;
    
    DataPath dp(
        .clock(clock), .clear(clear), .ALUControl(ALUControl),
        .GPR_Rin(GPR_Rin), .GPR_Rout(GPR_Rout), .IRin(IRin),
        .MARin(MARin), .RZout(RZout), .RYin(RYin), .RBin(RBin),
        .PCjump(PCjump), .MDRread(MDRread), .RinHI(RinHI),
        .RoutHI(RoutHI), .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .BAout(BAout), .Cout(Cout), .RAMread(RAMread),
        .RAMwrite(RAMwrite), .InPortStrobe(InPortStrobe),
        .OutPortEnable(OutPortEnable)
    );

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("phase2/p3tb(st).vcd");
        $dumpvars(0, tb);
        
        // initialize variables
        clear = 1;
        ALUControl = 16'h0; RinHI = 16'h0; RoutHI = 16'h0;
        IRin = 0; MARin = 0; RZout = 0; RYin = 0; RBin = 0; PCjump = 0;
        MDRread = 0; GPR_Rin = 0; GPR_Rout = 0;
        Gra = 0; Grb = 0; Grc = 0; BAout = 0; Cout = 0;
        RAMread = 0; RAMwrite = 0; InPortStrobe = 0; OutPortEnable = 0;

        //Done, Faze

        // Initialize memory contents as required by the lab
        dp.ram.memory[8'h1F] = 32'h000000D4;   // Case 1 initial value
        dp.ram.memory[8'h82] = 32'h000000A7;   // Case 2 initial value
        
        // Preload R6 = 0x63
        dp.R6.q = 32'h00000063;
        
        // Case 1: st 0x1F, R6
        // store R6 -> memory[0x1F]
        dp.ram.memory[0] = 32'h????001F;  
        
        // Case 2: st 0x1F(R6), R6
        // store R6 -> memory[R6 + 0x1F] = 0x82
        dp.ram.memory[4] = 32'h????001F;
        // -----------------------------------------------------------------

        // Release clear to start the state machine
        #20 clear = 0;
        
        // Extended time to ensure all 4 cases finish
        #1500 $finish; 
    end

    // Sequential State Transition Logic
    always @(negedge clock) begin
        case (Present_state)
            Default: if (!clear) Present_state <= C1_T0;
            // Case 1
            C1_T0: Present_state <= C1_T1; C1_T1: Present_state <= C1_T2;
            C1_T2: Present_state <= C1_T3; C1_T3: Present_state <= C1_T4;
            C1_T4: Present_state <= C1_T5; C1_T5: Present_state <= C1_T6;
            C1_T6: Present_state <= C1_T7; C1_T7: Present_state <= C2_T0;
            // Case 2
            C2_T0: Present_state <= C2_T1; C2_T1: Present_state <= C2_T2;
            C2_T2: Present_state <= C2_T3; C2_T3: Present_state <= C2_T4;
            C2_T4: Present_state <= C2_T5; C2_T5: Present_state <= C2_T6;
            C2_T6: Present_state <= C2_T7; C2_T7: Present_state <= C2_T7; // Halt simulation loop
            // Case 3
            C3_T0: Present_state <= C3_T1; C3_T1: Present_state <= C3_T2;
            C3_T2: Present_state <= C3_T3; C3_T3: Present_state <= C3_T4;
            C3_T4: Present_state <= C3_T5; C3_T5: Present_state <= C4_T0; // LDI finishes at T5
            // Case 4
            C4_T0: Present_state <= C4_T1; C4_T1: Present_state <= C4_T2;
            C4_T2: Present_state <= C4_T3; C4_T3: Present_state <= C4_T4;
            C4_T4: Present_state <= C4_T5; C4_T5: Present_state <= C4_T5; // Halt simulation loop
        endcase
    end

    // Control Signal Assertions
    always @(Present_state) begin
    case (Present_state)
        Default: begin
            RinHI <= 16'h0; RoutHI <= 16'h0; MARin <= 0; IRin <= 0;
            RYin <= 0; RAMread <= 0; RAMwrite <= 0; MDRread <= 0;
            Gra <= 0; Grb <= 0; BAout <= 0; Cout <= 0;
            GPR_Rin <= 0; ALUControl <= 16'd0;
        end
        
        // COMMON FETCH & DECODE STAGES (T0 - T4)
        C1_T0, C2_T0: begin // PCout, MARin, IncPC, Zin
            RoutHI[4] <= 1; MARin <= 1; RinHI[3] <= 1;
            #20 RoutHI[4] <= 0; MARin <= 0; RinHI[3] <= 0;
        end
        C1_T1, C2_T1: begin // Zlowout, PCin, Read, MDRin
            RoutHI[3] <= 1; RinHI[4] <= 1; RAMread <= 1; RinHI[5] <= 1; MDRread <= 1;
            #20 RoutHI[3] <= 0; RinHI[4] <= 0; RAMread <= 0; RinHI[5] <= 0; MDRread <= 0;
        end
        C1_T2, C2_T2: begin // MDRout, IRin
            RoutHI[5] <= 1; IRin <= 1; 
            #20 RoutHI[5] <= 0; IRin <= 0;
        end
        C1_T3, C2_T3: begin // Grb, BAout, Yin
            Grb <= 1; BAout <= 1; RYin <= 1; 
            #20 Grb <= 0; BAout <= 0; RYin <= 0;
        end
        C1_T4, C2_T4: begin // Cout, ADD, Zin
            Cout <= 1; ALUControl <= 16'd12; RinHI[3] <= 1; 
            #20 Cout <= 0; ALUControl <= 16'd0; RinHI[3] <= 0;
        end

        // ST STAGES (T5 - T7)
        C1_T5, C2_T5: begin // Zlowout, MARin
            RoutHI[3] <= 1; MARin <= 1;
            #20 RoutHI[3] <= 0; MARin <= 0;
        end

        C1_T6, C2_T6: begin // Gra, MDRin
            Gra <= 1; RinHI[5] <= 1; MDRread <= 1;
            #20 Gra <= 0; RinHI[5] <= 0; MDRread <= 0;
        end

        C1_T7, C2_T7: begin // Write
            RAMwrite <= 1;
            #20 RAMwrite <= 0;
        end
    endcase
end

endmodule
