`include "i3c_params.vh"
module bus_controller (
	input 		clk_i,
	input 		rst_ni,
	input [2:0]	state_i,
	input 		scl_i,
	input 		sda_i,
	output reg 	scl_o,
	output reg 	sda_o,
	output reg 	sel_od_pp_o
);
    
	//Clock generation
	reg [15:0] clk_divider;
	reg 	scl_internal;
	wire	scl_rising_edge = (scl_internal && !scl_o);
	wire	scl_falling_edge= (!scl_internal && scl_o);
	
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			clk_divider <= 0;
			scl_internal <= 1'b1;
			scl_o	<= 1'b1;
			sda_o	<= 1'b1;
			sel_od_pp_o	<= 1'b0;
		end else begin
			//SCL generation
			if (!state_i == `IDLE) begin
				if (clk_divider == 16'd49) begin //example for 1mhz SCL
					clk_divider <= 0;
					scl_internal <= ~scl_internal;
					scl_o <= scl_internal;
				end else begin
					clk_divider <= clk_divider +1;
				end
			end else begin
				scl_o <= 1'b1;
				sda_o <= 1'b1;
			end
			
			//SDA Control
			case (state_i)
				`START: sda_o <= 1'b0;
				`STOP:  sda_o <= 1'b1;
				default: sda_o <= sda_o; // maintain previous state
			endcase
			
			//Drive mode selection
			sel_od_pp_o <= (state_i == `DATA) ? 1'b1 : 1'b0; //Push-pull for data phase
		end
	end

endmodule