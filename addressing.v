`timescale 1ns/1ps
`include "i3c_params.vh"
module addressing(
	input		clk_i,
	input 		rst_ni,
	input      [`STATE_WIDTH-1:0] state_i,
	input       sda_i,
	input      [`ADDR_WIDTH-1:0]  device_address_i,
	input       is_read_i,
    output reg [`ADDR_WIDTH-1:0]  target_addr_o,
    output reg	addr_valid_o,
    output reg	addr_acked_o
);  
	reg [3:0] bit_counter;
	reg [`ADDR_WIDTH:0] addr_shift_reg; // Includes R/W bit
	
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			bit_counter <= 0;
			addr_shift_reg <= 8'h00;
			target_addr_o <= 7'h00;
			addr_valid_o <= 1'b0;
			addr_acked_o <= 1'b0;
		end else begin
			case (state_i)
				`IDLE: begin
					bit_counter <= 0;
					addr_shift_reg <= {device_address_i, is_read_i};
					addr_valid_o <= 1'b0;
					addr_acked_o <= 1'b0;
				end
				`ADDRESS: begin
				    if (bit_counter < 8 ) begin
                        target_addr_o <= {target_addr_o[6:0], sda_i};  // should be shift-in
                        bit_counter <= bit_counter + 1;
                    //end          
					//if(bit_counter < 8)ESS_PHASE; begin
					//    addr_shift_reg <= {addr_shift_reg[6:0], 1'b0}; 
					//	bit_counter <= bit_counter + 1;
					//	addr_valid_o <= 1'b1;
					//	target_addr_o <= addr_shift_reg[`ADDR_WIDTH:1];
					end else begin
						//Check for ACK on the 9th clock
						addr_acked_o <= !sda_i; // Low = ACK
						addr_valid_o <= 1'b0;
					end
				end
				default: begin
					addr_valid_o <= 1'b0;
				end
			endcase
		end
	end
endmodule