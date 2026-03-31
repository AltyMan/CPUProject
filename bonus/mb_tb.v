`timescale 1ns / 10ps

module mb_tb();
    // Physical board pins
    reg CLOCK_50;
    reg [2:0] KEY; // Updated to 3 bits to include IRQ
    reg [7:0] SW;
    
    wire [5:5] LEDR;
    wire [7:0] HEX0;
    wire [7:0] HEX1;

    // DECLARE THE LOG FILE INTEGER HERE (At the module level!)
    integer log_fd;

    // Instantiate the Motherboard, overriding DIVISOR to 2 so simulation is fast
    Motherboard #(.DIVISOR(2)) mb (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1)
    );

    // Generate the 50 MHz physical board clock (20ns period)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Main Hardware Interaction Script
    initial begin
        // OPEN THE LOG FILE HERE
        log_fd = $fopen("bonus/hardware_log.txt", "w");
        
        $display("\n=======================================================");
        $display("--- FPGA MOTHERBOARD PHYSICAL SIMULATION STARTING ---");
        $display("=======================================================\n");

        // The physical buttons (KEY) are ACTIVE-LOW (0 means pressed)
        KEY[0] = 0; // Hold Reset down
        KEY[1] = 1; // Stop button unpressed
        KEY[2] = 1; // IRQ button unpressed
        
        // Set the physical slide switches to 0xE0
        SW = 8'hE0; 
        
        // Wait a few clock cycles, then let go of the Reset button
        #100;
        KEY[0] = 1; 

        // ---------------------------------------------------------
        // THE INTERRUPT TEST SEQUENCE
        // ---------------------------------------------------------
        
        // 1. Wait dynamically until the processor sets the internal IE flag to 1
        wait(mb.dp.IE_out == 1'b1);
        
        // 2. Wait until the FSM hits state 0 (T0) to ensure we are aligned with instruction boundaries
        wait(mb.dp.CU.state == 3'd0);
        
        // 3. Wait 5 full instruction cycles
        repeat(5) begin
            wait(mb.dp.CU.state == 3'd5); // Wait for an instruction to almost finish
            wait(mb.dp.CU.state == 3'd0); // Wait for the next one to start
        end
        
        $display("\n[%0t ns] --- USER FLIPS SWITCHES TO 0xAA ---", $time);
        $fdisplay(log_fd, "\n[%0t ns] --- USER FLIPS SWITCHES TO 0xAA ---", $time);
        SW = 8'hAA; 
        
        $display("[%0t ns] --- USER PRESSES IRQ BUTTON (KEY[2]) ---", $time);
        $fdisplay(log_fd, "[%0t ns] --- USER PRESSES IRQ BUTTON (KEY[2]) ---", $time);
        
        // 3. Press the physical button 
        KEY[2] = 0;
        
        // Hold the button until the CPU actually enters the interrupt state!
        // This simulates a human holding the button until the screen changes.
        wait(mb.dp.CU.state == 3'd6); 
        
        $display("[%0t ns] --- USER RELEASES IRQ BUTTON (KEY[2]) ---", $time);
        $fdisplay(log_fd, "[%0t ns] --- USER RELEASES IRQ BUTTON (KEY[2]) ---", $time);
        KEY[2] = 1;

        // Let the simulation run to completion
        #5000000;
        
        $display("\n>>> SIMULATION TIMEOUT <<<");
        $finish;
    end

    // --- External Hardware Logger ---
    // Watch for changes on the physical 7-segment display pins
    always @(HEX0 or HEX1) begin
        // Only print if not in reset and if it's an actual hex value (not 'x')
        if (KEY[0] == 1 && HEX0 !== 8'hxx) begin 
            $display("[%0t ns] EXTERNAL DISPLAY UPDATED | HEX1: %b | HEX0: %b", 
                     $time, HEX1, HEX0);
            $fdisplay(log_fd, "[%0t ns] EXTERNAL DISPLAY UPDATED | HEX1: %b | HEX0: %b", 
                     $time, HEX1, HEX0);
        end
    end

    // Watch for the physical Run/Halt LED to turn off
    always @(negedge LEDR[5]) begin
        if (KEY[0] == 1) begin
            $display("\n[%0t ns] CPU HALTED (LEDR[5] turned off)", $time);
            $fdisplay(log_fd, "\n[%0t ns] CPU HALTED (LEDR[5] turned off)", $time);
            
            // Print the final internal state just to confirm everything matches
            $display("\n--- FINAL INTERNAL CPU STATE ---");
            $display("R6: %08h | R7: %08h", mb.dp.BusMuxInR6, mb.dp.BusMuxInR7);
            $display("EPC: %08h", mb.dp.BusMuxInEPC);
            
            $fdisplay(log_fd, "\n--- FINAL INTERNAL CPU STATE ---");
            $fdisplay(log_fd, "R6: %08h | R7: %08h", mb.dp.BusMuxInR6, mb.dp.BusMuxInR7);
            $fdisplay(log_fd, "EPC: %08h", mb.dp.BusMuxInEPC);
            
            #100;
            $fclose(log_fd);
            $finish; 
        end
    end

endmodule