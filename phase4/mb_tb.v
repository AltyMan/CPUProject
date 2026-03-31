`timescale 1ns / 1ns

module mb_tb();
    // Physical board pins
    reg CLOCK_50;
    reg [1:0] KEY;
    reg [7:0] SW;
    
    wire [5:5] LEDR;
    wire [7:0] HEX0;
    wire [7:0] HEX1;

    // Instantiate the Motherboard, OVERRIDING the DIVISOR to 2 for simulation!
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

    initial begin
        // The physical buttons (KEY) are ACTIVE-LOW (0 means pressed)
        KEY[0] = 0; // Hold Reset down
        KEY[1] = 1; // Stop button unpressed
        
        // Set the physical slide switches to 0xE0
        SW = 8'hE0; 
        
        // Wait a few clock cycles, then let go of the Reset button
        #100;
        KEY[0] = 1; 

        mb.dp.l1_dcache.memory[9'h088] = 32'h00000005; // set to 5 for simulation

        // Let the simulation run. 
        $display("[%0t ns] --- CPU IS NOW CRUNCHING 0xFFFF. THIS MAY TAKE A FEW SECONDS OF REAL TIME... ---", $time);
        
        wait(LEDR[5] == 1'b0); // Wait for the run LED to turn off!
        
        $display("\n>>> SIMULATION FINISHED NATURALLY <<<");
        $finish;
    end

    // --- Motherboard Physical Hardware Logger ---
    // Instead of looking deep inside the Datapath, this logger acts like a human
    // looking at the physical LEDs and 7-Segment displays on the board.
    
    // Watch for changes on the 7-segment display pins
    always @(HEX0 or HEX1) begin
        if (KEY[0] == 1) begin // Only print if not in reset
            $display("[%0t ns] 7-SEGMENT DISPLAY CHANGED | HEX1 (Bits 7:4): %b | HEX0 (Bits 3:0): %b", 
                     $time, HEX1, HEX0);
        end
    end

    // Watch for the Run/Halt LED to turn off
    always @(negedge LEDR[5]) begin
        if (KEY[0] == 1) begin
            $display("\n[%0t ns] LEDR[5] TURNED OFF (CPU HALTED)", $time);
            #100 $finish; // End the simulation safely shortly after halting
        end
    end

endmodule