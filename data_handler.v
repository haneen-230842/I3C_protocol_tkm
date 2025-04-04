`include "i3c_params.vh"
module data_handler(
	input 		clk_i,
    input 		rst_ni,
    input [`STATE_WIDTH-1:0] state_i,
    input [`DATA_WIDTH-1:0] write_data_i,
    input 		is_read_i,
	input 		sda_i,
    output reg [`DATA_WIDTH-1:0] tx_data_o,
    output reg [`DATA_WIDTH-1:0] rx_data_o,
    output reg 		 data_valid_o,
    output reg 		 data_acked_o,
    output reg [`DATA_WIDTH-1:0] read_data_o
);
    
	reg [2:0] bit_counter;
	reg [`DATA_WIDTH-1:0] tx_shift_reg;
	reg [`DATA_WIDTH-1:0] rx_shift_reg;
	
	always @(posedge clk_i or negedge rst_ni) begin
		if(!rst_ni) begin
			bit_counter <= 0;
			tx_shift_reg <= 8'h00;
			rx_shift_reg <= 8'h00;
			tx_data_o <= 8'h00;
			rx_data_o <= 8'h00;
			data_valid_o <= 1'b0;
			data_acked_o <= 1'b0;
			read_data_o <= 8'h00;
		end else begin
			case (state_i)
				`IDLE: begin
					bit_counter <= 0;
					tx_shift_reg <= write_data_i;
					rx_shift_reg <= 8'h00;
					data_valid_o <= 1'b0;
					data_acked_o <= 1'b0;
				end
				`DATA: begin
					if (bit_counter < `DATA_WIDTH) begin
						if (is_read_i) begin
							//Master reading - drive SDA
							tx_data_o <= tx_shift_reg[`DATA_WIDTH-1];
							tx_shift_reg <= {tx_shift_reg[`DATA_WIDTH-2:0], 1'b0};
						end else begin
							//Master writing - read SDA
							rx_shift_reg <= {rx_shift_reg[`DATA_WIDTH-2:0], 1'b0};
						end
						bit_counter <= bit_counter + 1;
						data_valid_o <= 1'b1;
					end else begin
						//Check for ACK/NACK
						data_acked_o <= !sda_i; //Low = ACK
						data_valid_o <= 1'b0;
						read_data_o <= rx_shift_reg;
					end
				end
				default: begin
					data_valid_o <= 1'b0;
				end
			endcase
		end
	end

endmodule