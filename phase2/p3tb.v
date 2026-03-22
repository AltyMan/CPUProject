`timescale 1ns / 10ps

// addi, andi, ori

module tb();
    reg clock, clear;
    reg [15:0] ALUControl;

    reg IRin, MARin, RZout, RYin, RBin, PCjump, MDRread;
    reg GPR_Rin, GPR_Rout;
    reg [15:0] RinHI, RoutHI;

    reg Gra, Grb, Grc, BAout, Cout;
    reg RAMread, RAMwrite;
    reg InPortStrobe, OutPortEnable;

    // Predefined ALU control codes for operations tested
    parameter ALU_ADD = 16'd12, 
              ALU_AND = 16'd1, 
              ALU_OR  = 16'd2; 

    // Define distinct states for Cases 1, 2, and 3 sequentially
    parameter Default = 6'd0,
              // Case 1: addi R7, R4, -9
              C1_T0 = 6'd1, C1_T1 = 6'd2, C1_T2 = 6'd3, C1_T3 = 6'd4, C1_T4 = 6'd5, C1_T5 = 6'd6,
              // Case 2: andi R7, R4, 0x71
              C2_T0 = 6'd7, C2_T1 = 6'd8, C2_T2 = 6'd9, C2_T3 = 6'd10, C2_T4 = 6'd11, C2_T5 = 6'd12,
              // Case 3: ori R7, R4, 0x71
              C3_T0 = 6'd13, C3_T1 = 6'd14, C3_T2 = 6'd15, C3_T3 = 6'd16, C3_T4 = 6'd17, C3_T5 = 6'd18;

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
        $dumpfile("phase2/p3tb.vcd");
        $dumpvars(0, tb);
        
        // Initialize variables and keep clear high
        clear = 1;
        ALUControl = 16'h0; RinHI = 16'h0; RoutHI = 16'h0;
        IRin = 0; MARin = 0; RZout = 0; RYin = 0; RBin = 0; PCjump = 0;
        MDRread = 0; GPR_Rin = 0; GPR_Rout = 0;
        Gra = 0; Grb = 0; Grc = 0; BAout = 0; Cout = 0;
        RAMread = 0; RAMwrite = 0; InPortStrobe = 0; OutPortEnable = 0;

        // Preload the 3 instructions into RAM
        dp.ram.memory[0] = 32'h63A7FFF7; // addi R7, R4, -9
        dp.ram.memory[4] = 32'h6BA00071; // andi R7, R4, 0x71
        dp.ram.memory[8] = 32'h73A00071; // ori  R7, R4, 0x71

        // Cycle the clock to process the clear
        #20 clear = 0;

        // Preload R4 with a test value (e.g., 0x25 / 37 in decimal)
        // Addi expected: 0x25 + (-9) = 0x1C
        // Andi expected: 0x25 & 0x71 = 0x21
        // Ori  expected: 0x25 | 0x71 = 0x75
        dp.R4.q = 32'h00000025;
        
        // Extended time to ensure all cases finish
        #1500 $finish;
    end

    always @(negedge clock) begin
        case (Present_state)
            Default: if (!clear) Present_state <= C1_T0;
            // Case 1
            C1_T0: Present_state <= C1_T1; C1_T1: Present_state <= C1_T2;
            C1_T2: Present_state <= C1_T3; C1_T3: Present_state <= C1_T4;
            C1_T4: Present_state <= C1_T5; C1_T5: Present_state <= C2_T0;
            // Case 2
            C2_T0: Present_state <= C2_T1; C2_T1: Present_state <= C2_T2;
            C2_T2: Present_state <= C2_T3; C2_T3: Present_state <= C2_T4;
            C2_T4: Present_state <= C2_T5; C2_T5: Present_state <= C3_T0;
            // Case 3
            C3_T0: Present_state <= C3_T1; C3_T1: Present_state <= C3_T2;
            C3_T2: Present_state <= C3_T3; C3_T3: Present_state <= C3_T4;
            C3_T4: Present_state <= C3_T5; C3_T5: Present_state <= C3_T5; // Halt
        endcase
    end

    always @(Present_state) begin
        case (Present_state)
            Default: begin
                RinHI <= 16'h0; RoutHI <= 16'h0; MARin <= 0; IRin <= 0;
                RYin <= 0; RAMread <= 0; MDRread <= 0; Gra <= 0; Grb <= 0;
                BAout <= 0; Cout <= 0; GPR_Rin <= 0; GPR_Rout <= 0; ALUControl <= 16'd0;
            end
            
            // COMMON FETCH & DECODE STAGES (T0 - T2)
            C1_T0, C2_T0, C3_T0: begin // PCout, MARin, IncPC, Zin
                RoutHI[4] <= 1; MARin <= 1; RinHI[3] <= 1;
                #20 RoutHI[4] <= 0; MARin <= 0; RinHI[3] <= 0;
            end
            C1_T1, C2_T1, C3_T1: begin // Zlowout, PCin, Read, MDRin
                RoutHI[3] <= 1; RinHI[4] <= 1; RAMread <= 1; RinHI[5] <= 1; MDRread <= 1;
                #20 RoutHI[3] <= 0; RinHI[4] <= 0; RAMread <= 0; RinHI[5] <= 0; MDRread <= 0;
            end
            C1_T2, C2_T2, C3_T2: begin // MDRout, IRin
                RoutHI[5] <= 1; IRin <= 1; 
                #20 RoutHI[5] <= 0; IRin <= 0;
            end

            // T3: LATCH BASE REGISTER INTO RY
            C1_T3, C2_T3, C3_T3: begin // Grb, Rout, Yin
                Grb <= 1; GPR_Rout <= 1; RYin <= 1; 
                #20 Grb <= 0; GPR_Rout <= 0; RYin <= 0;
            end

            // T4: ALU EXECUTIONS
            C1_T4: begin // ADDI
                Cout <= 1; ALUControl <= ALU_ADD; RinHI[3] <= 1; 
                #20 Cout <= 0; ALUControl <= 16'd0; RinHI[3] <= 0;
            end
            C2_T4: begin // ANDI
                Cout <= 1; ALUControl <= ALU_AND; RinHI[3] <= 1; 
                #20 Cout <= 0; ALUControl <= 16'd0; RinHI[3] <= 0;
            end
            C3_T4: begin // ORI
                Cout <= 1; ALUControl <= ALU_OR; RinHI[3] <= 1; 
                #20 Cout <= 0; ALUControl <= 16'd0; RinHI[3] <= 0;
            end

            // T5: WRITEBACK TO REGISTER
            C1_T5, C2_T5, C3_T5: begin // Zlowout, Gra, Rin
                RoutHI[3] <= 1; Gra <= 1; GPR_Rin <= 1; 
                #20 RoutHI[3] <= 0; Gra <= 0; GPR_Rin <= 0;
            end
        endcase
    end
endmodule