`include "i3c_params.vh"

module state_machine(
	input		  clk_i,
	input		  rst_ni,
	input		  start_i,
	input		  addr_acked_i,
	input		  data_acked_i,
	input         error_i,
	output reg [`STATE_WIDTH-1:0] state_o,
	output		  transfer_complete_o,
	output		  error_o
);

	reg [`STATE_WIDTH-1:0] next_state; //using 3-bit registers for states
	
	//state transitions
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni)
			state_o <= `IDLE;
		else
			state_o <= next_state;
			
	end
	
	//Next state logic
	always @(*) begin
		next_state = state_o;
		
		case (state_o)
			`IDLE: if (start_i) next_state = `START;
			`START: next_state = `ADDRESS;
			`ADDRESS: if (addr_acked_i === 1'b1)
			             next_state = `DATA;
				      else if (addr_acked_i === 1'b0) 
				         next_state = `ERROR;
			`DATA: if (data_acked_i) next_state = `STOP;
				  else if (!data_acked_i) next_state = `ERROR;
			`STOP: next_state = `IDLE;
			`ERROR: next_state = `IDLE;
			default: next_state = `IDLE;
		endcase
	end
	
	assign transfer_complete_o = (state_o == `STOP);
	assign error_o = (state_o == `ERROR) | error_i;
endmodule
		