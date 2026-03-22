`timescale 1ns / 10ps

// st

module tb();
    reg clock, clear;
    reg [15:0] ALUControl;

    reg IRin, MARin, RZout, RYin, RBin, PCjump, MDRread;
    reg GPR_Rin, GPR_Rout;
    reg [15:0] RinHI, RoutHI;

    reg Gra, Grb, Grc, BAout, Cout;
    reg RAMread, RAMwrite;
    reg InPortStrobe, OutPortEnable;

    // Define distinct states for Case 1 and Case 2 sequentially
    parameter Default = 6'd0,
              // Case 1: st 0x1F, R6
              C1_T0 = 6'd1, C1_T1 = 6'd2, C1_T2 = 6'd3, C1_T3 = 6'd4, C1_T4 = 6'd5, C1_T5 = 6'd6, C1_T6 = 6'd7, C1_T7 = 6'd8,
              // Case 2: st 0x1F(R6), R6
              C2_T0 = 6'd9, C2_T1 = 6'd10, C2_T2 = 6'd11, C2_T3 = 6'd12, C2_T4 = 6'd13, C2_T5 = 6'd14, C2_T6 = 6'd15, C2_T7 = 6'd16;

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
        $dumpfile("phase2/p2tb.vcd");
        $dumpvars(0, tb);
        
        // initialize variables
        clear = 1;
        ALUControl = 16'h0; RinHI = 16'h0; RoutHI = 16'h0;
        IRin = 0; MARin = 0; RZout = 0; RYin = 0; RBin = 0; PCjump = 0;
        MDRread = 0; GPR_Rin = 0; GPR_Rout = 0;
        Gra = 0; Grb = 0; Grc = 0; BAout = 0; Cout = 0;
        RAMread = 0; RAMwrite = 0; InPortStrobe = 0; OutPortEnable = 0;

        // Initialize memory contents as required by the lab
        dp.ram.memory[8'h1F] = 32'h000000D4;   // Case 1 initial value
        dp.ram.memory[8'h82] = 32'h000000A7;   // Case 2 initial value

        // Case 1: st 0x1F, R6
        // Ra=R6(0110), Rb=R0(0000), c=0x1F -> Hex: 0x1B00001F
        dp.ram.memory[0] = 32'h1B00001F;  
        
        // Case 2: st 0x1F(R6), R6
        // Ra=R6(0110), Rb=R6(0110), c=0x1F -> Hex: 0x1B30001F
        dp.ram.memory[4] = 32'h1B30001F;

        // Release clear to start the state machine
        #20 clear = 0;

        // Preload R6 = 0x63
        dp.R6.q = 32'h00000063;
        
        // Extended time to ensure all cases finish
        #1450; 
        
        // Print summary of RAM to terminal
        $display("\nRAM Contents After Simulation:");
        $display("Case 1 (st 0x1F, R6):");
        $display("RAM[0x1F] = %h (Expected: 00000063)", dp.ram.memory[9'h01F]);
        $display("Case 2 (st 0x1F(R6), R6):");
        $display("RAM[0x82] = %h (Expected: 00000063)", dp.ram.memory[9'h082]);
        $display("\n");
        
        #50 $finish;
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
        endcase
    end

    // Control Signal Assertions
    always @(Present_state) begin
        case (Present_state)
            Default: begin
                RinHI <= 16'h0; RoutHI <= 16'h0; MARin <= 0; IRin <= 0;
                RYin <= 0; RAMread <= 0; RAMwrite <= 0; MDRread <= 0;
                Gra <= 0; Grb <= 0; BAout <= 0; Cout <= 0;
                GPR_Rin <= 0; GPR_Rout <= 0; ALUControl <= 16'd0;
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
                Grb <= 1; BAout <= 1; GPR_Rout <= 1; RYin <= 1; 
                #20 Grb <= 0; BAout <= 0; GPR_Rout <= 0; RYin <= 0;
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

            C1_T6, C2_T6: begin // Ra_out, MDRin (From Bus, NOT RAM)
                Gra <= 1; GPR_Rout <= 1; RinHI[5] <= 1; MDRread <= 0;
                #20 Gra <= 0; GPR_Rout <= 0; RinHI[5] <= 0;
            end

            C1_T7, C2_T7: begin // MDRout, RAMwrite
                RoutHI[5] <= 1; RAMwrite <= 1;
                #20 RoutHI[5] <= 0; RAMwrite <= 0;
            end
        endcase
    end

endmodule