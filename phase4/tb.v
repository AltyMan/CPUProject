`timescale 1ns / 10ps

module phase4_tb();
    reg clock;
    reg clear;
    reg stop;
    
    // New physical I/O ports for Phase 4
    reg [31:0] ExternalIn;
    wire [31:0] ExternalOut;
    wire run;
    
    integer log_fd;

    // Notice we are now using the updated DataPath ports!
    DataPath dp(
        .clock(clock),
        .clear(clear),
        .stop(stop),
        .InPortData(ExternalIn),
        .OutPortData(ExternalOut),
        .run(run)
    );

    // Clock Generation
    initial begin
        clock = 0;
        forever #10 clock = ~clock; // 20ns period
    end

    // Task to print the full CPU State (Registers + Specific Memory)
    task print_cpu_state;
        begin
            $display("R0:  %8h | R1:  %8h", dp.resultR0, dp.BusMuxInR1);
            $display("R2:  %8h | R3:  %8h", dp.BusMuxInR2, dp.BusMuxInR3);
            $display("R4:  %8h | R5:  %8h", dp.BusMuxInR4, dp.BusMuxInR5);
            $display("R6:  %8h | R7:  %8h", dp.BusMuxInR6, dp.BusMuxInR7);
            $display("R8:  %8h | R9:  %8h", dp.BusMuxInR8, dp.BusMuxInR9);
            $display("R10: %8h | R11: %8h", dp.BusMuxInR10, dp.BusMuxInR11);
            $display("R12: %8h | R13: %8h", dp.BusMuxInR12, dp.BusMuxInR13);
            $display("R14: %8h | R15: %8h", dp.BusMuxInR14, dp.BusMuxInR15);
            $display("HI:  %8h | LO:  %8h", dp.BusMuxInHI, dp.BusMuxInLO);
            $display("MAR: %8h | MDR: %8h", {23'b0, dp.MAROut}, dp.Mdataout);
            
            // Added 0x88 for the Phase 4 delay counter inspection
            $display("MEM[0x88]: %8h | MEM[0x89]: %8h | MEM[0xA3]: %8h", 
                     dp.l1_dcache.memory[9'h088], dp.l1_dcache.memory[9'h089], dp.l1_dcache.memory[9'h0a3]);
            $display("\n");

            // Write to log file
            $fdisplay(log_fd, "R0:  %8h | R1:  %8h", dp.resultR0, dp.BusMuxInR1);
            $fdisplay(log_fd, "R2:  %8h | R3:  %8h", dp.BusMuxInR2, dp.BusMuxInR3);
            $fdisplay(log_fd, "R4:  %8h | R5:  %8h", dp.BusMuxInR4, dp.BusMuxInR5);
            $fdisplay(log_fd, "R6:  %8h | R7:  %8h", dp.BusMuxInR6, dp.BusMuxInR7);
            $fdisplay(log_fd, "R8:  %8h | R9:  %8h", dp.BusMuxInR8, dp.BusMuxInR9);
            $fdisplay(log_fd, "R10: %8h | R11: %8h", dp.BusMuxInR10, dp.BusMuxInR11);
            $fdisplay(log_fd, "R12: %8h | R13: %8h", dp.BusMuxInR12, dp.BusMuxInR13);
            $fdisplay(log_fd, "R14: %8h | R15: %8h", dp.BusMuxInR14, dp.BusMuxInR15);
            $fdisplay(log_fd, "HI:  %8h | LO:  %8h", dp.BusMuxInHI, dp.BusMuxInLO);
            $fdisplay(log_fd, "MAR: %8h | MDR: %8h", {23'b0, dp.MAROut}, dp.Mdataout);
            $fdisplay(log_fd, "MEM[0x88]: %8h | MEM[0x89]: %8h | MEM[0xA3]: %8h | MEM[0x77]: %8h", 
                      dp.l1_dcache.memory[9'h088], dp.l1_dcache.memory[9'h089], dp.l1_dcache.memory[9'h0a3], dp.l1_dcache.memory[9'h077]);
            $fdisplay(log_fd, "\n");
        end
    endtask

    // Main Simulation Block
    initial begin
        $dumpfile("phase4/tb.vcd");
        $dumpvars(0, phase4_tb);
        log_fd = $fopen("phase4/sim_log.txt", "w");
        if (log_fd == 0) begin
            $display("ERROR: Could not open phase4/sim_log.txt for writing.");
            $finish;
        end

        clear = 1;
        stop = 0;
        
        // Simulating the user setting the physical switches to 0xE0
        ExternalIn = 32'h000000E0; 
        
        #40;
        
        dp.l1_dcache.memory[9'h088] = 32'h00000005; // set to 5 for simulation

        $display("Initial States:");
        $fdisplay(log_fd, "Initial States:");
        print_cpu_state();
        
        clear = 0;
        
        // Failsafe Timeout: Massively increased for the Phase 4 loop!
        // Highly recommend changing MEM[0x88] to 0x0005 during simulation.
        #5000000000; 
        
        $display("Simulation Timeout Reached");
        $fdisplay(log_fd, "Simulation Timeout Reached");
        
        $display("\nTimeout States:");
        $fdisplay(log_fd, "\nTimeout States:");
        print_cpu_state();
        
        $fclose(log_fd);
        $finish;
    end

    // --- PHASE 4 7-SEGMENT DISPLAY TRACKER ---
    // This watches the ExternalOut port and alerts you every time the CPU 
    // updates the 7-segment displays.
    always @(ExternalOut) begin
        if (!clear) begin
            $display("\n>>> SEVEN SEGMENT DISPLAY UPDATED: %02h <<<\n", ExternalOut[7:0]);
            
            $fdisplay(log_fd, "\n>>> SEVEN SEGMENT DISPLAY UPDATED: %02h <<<\n", ExternalOut[7:0]);
        end
    end

    // --- THE DIAGNOSTIC LOGGER ---
    always @(negedge clock) begin
        if (!clear) begin
            // 1. Log the start of a new instruction
            if (dp.CU.state == 3'd1) begin
                $display("\n[%0t ns] FETCH: PC = %03h | IR = %08h", $time, dp.BusMuxInPC, dp.IROut);
                $fdisplay(log_fd, "\n[%0t ns] FETCH: PC = %03h | IR = %08h", $time, dp.BusMuxInPC, dp.IROut);
            end
            
            // 2. Log the current state and bus value
            $display("[%0t ns] State T%0d | Bus = %8h | ALU_Sel = %0d", 
                     $time, dp.CU.state, dp.BusMuxOut, dp.ALUControl);
            $fdisplay(log_fd, "[%0t ns] State T%0d | Bus = %8h | ALU_Sel = %0d", 
                      $time, dp.CU.state, dp.BusMuxOut, dp.ALUControl);
                     
            // 3. Log General Purpose Register Writes
            if (dp.GPR_Rin) begin
                $display("REG WRITE: Latched %8h (Renable mask: %b)", dp.BusMuxOut, dp.Renable);
                $fdisplay(log_fd, "REG WRITE: Latched %8h (Renable mask: %b)", dp.BusMuxOut, dp.Renable);
            end
            
            // 4. Log Memory Writes
            if (dp.RAMwrite) begin
                $display("MEM WRITE: Addr [%h] <= %h", dp.MAROut, dp.Mdataout);
                $fdisplay(log_fd, "MEM WRITE: Addr [%h] <= %h", dp.MAROut, dp.Mdataout);
            end

            // 5. Log Branching
            if (dp.PCjump) begin
                $display("BRANCH TAKEN: Next PC = %h", dp.BusMuxOut);
                $fdisplay(log_fd, "BRANCH TAKEN: Next PC = %h", dp.BusMuxOut);
            end

            // 6. Catch the Halt Instruction
            if (dp.CU.op_halt && dp.CU.state == 3'd1) begin
                $display("\nHALT INSTRUCTION REACHED");
                $fdisplay(log_fd, "\nHALT INSTRUCTION REACHED");
                
                // Print the FINAL state after execution
                $display("\nFinal States:");
                $fdisplay(log_fd, "\nFinal States:");
                print_cpu_state();
                
                $fclose(log_fd);
                $finish;
            end
        end
    end
endmodule