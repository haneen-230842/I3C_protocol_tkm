`timescale 1ns/1ps
`include "i3c_params.vh"

module tb_i3c_controller();
    // Clock and Reset
    reg clk;
    reg rst_n;
    
    // PHY Interface
    wire scl;
    wire sda;
    reg sda_pull_down;      
    
    // Control Interface
    reg [`ADDR_WIDTH-1:0] device_address;
    reg start_transfer;
    reg is_read;
    reg [`DATA_WIDTH-1:0] write_data;
    wire [`DATA_WIDTH-1:0] read_data;
    wire transfer_complete;
    wire error;
    wire [`STATE_WIDTH-1:0] current_state;
    
    // Instantiate I3C Controller
    i3c_controller dut (
        .clk_i(clk),
        .rst_ni(rst_n),
        
        // PHY Interface
        .scl_i(scl),
        .sda_i(sda),
        .scl_o(scl),
        .sda_o(sda),
        .sel_od_pp_o(),
        
        // Control Interface
        .device_address(device_address),
        .start_transfer(start_transfer),
        .is_read(is_read),
        .write_data(write_data),
        .read_data(read_data),
        .transfer_complete(transfer_complete),
        .error(error),
        .current_state_o(current_state)
    );
    
    // SDA bus modeling (open-drain)
    assign sda = sda_pull_down ? 1'b0 : 1'bz;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(`CLK_PERIOD/2) clk = ~clk; // 50MHz clock
    end
    
    // State monitor
        always @(current_state) begin
            case (current_state)
                `IDLE:    $display("[%0t] State: IDLE", $time);
                `START:   $display("[%0t] State: START", $time);
                `ADDRESS: $display("[%0t] State: ADDRESS", $time);
                `DATA:    $display("[%0t] State: DATA", $time);
                `STOP:    $display("[%0t] State: STOP", $time);
                `ERROR:   $display("[%0t] State: ERROR", $time);
            endcase
        end
        
    // Main test sequence
	initial begin
            // Initialize
            rst_n = 0;
            sda_pull_down = 0;
            device_address = 0;
            start_transfer = 0;
            is_read = 0;
            write_data = 0;
            
            // Apply reset
            #100 rst_n = 1;
            #200;
            
            // Test 1: Write operation
            $display("\nTest 1: Basic Write");
            device_address = 7'h50;
            write_data = 8'hA5;
            start_transfer = 1;
            @(posedge clk);
            start_transfer = 0;
            
            // Wait for address phase
            wait(current_state == `ADDRESS);
            $display("  Address phase started");
            
            // Simulate slave ACK
            #400 sda_pull_down = 1;
            @(negedge scl);
            #50 sda_pull_down = 0;
            
            // Wait for completion
            wait(transfer_complete);
            $display("  Write test completed");
            
            // Test 2: Read operation
            #200;
            $display("\nTest 2: Basic Read");
            device_address = 7'h51;
            is_read = 1;
            start_transfer = 1;
            @(posedge clk);
            start_transfer = 0;
            
            wait(current_state == `ADDRESS);
            #400 sda_pull_down = 1; // ACK
            @(negedge scl);
            #50 sda_pull_down = 0;
            
            // Slave sends data 0x3C
            wait(current_state == `DATA);
            fork
                begin
                    sda_pull_down = 0; @(negedge scl); // Bit 7 (0)
                    sda_pull_down = 0; @(negedge scl); // Bit 6 (0)
                    sda_pull_down = 1; @(negedge scl); // Bit 5 (1)
                    sda_pull_down = 1; @(negedge scl); // Bit 4 (1)
                    sda_pull_down = 1; @(negedge scl); // Bit 3 (1)
                    sda_pull_down = 1; @(negedge scl); // Bit 2 (1)
                    sda_pull_down = 0; @(negedge scl); // Bit 1 (0)
                    sda_pull_down = 0; @(negedge scl); // Bit 0 (0)
                end
            join
            
            wait(transfer_complete);
            if (read_data === 8'h3C)
                $display("  Read test passed: Received 0x3C");
            else
                $error("  Read test failed: Expected 0x3C, got %h", read_data);
            
            $display("\nAll tests completed");
            $finish;
        end
 endmodule
            