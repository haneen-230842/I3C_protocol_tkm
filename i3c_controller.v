`include "i3c_params.vh"

module i3c_controller (
	input clk_i,
	input rst_ni,
	
	//phy interface
	input  scl_i,
	input  sda_i,
	output scl_o,
	output sda_o,
	output sel_od_pp_o,
	
	//Basic i3c commands
	input  [`ADDR_WIDTH-1:0]	device_address,
	input			start_transfer,
	input			is_read,
	input  [`DATA_WIDTH-1:0]	write_data,
	output [`DATA_WIDTH-1:0]	read_data,
	output			transfer_complete,
	//Error handling
	output 			error,
	output [`STATE_WIDTH-1:0] current_state_o  //for debug/test
);

	//Wire declarations for inter-module connections
	wire [`STATE_WIDTH-1:0]	target_addr;
	wire [`ADDR_WIDTH-1:0]  state;
	wire		addr_valid;
	wire		addr_acked;
	wire [`DATA_WIDTH-1:0]	rx_data;
	wire		data_valid;
	wire		data_acked;
	
	//Instantiate State machine
	state_machine state_machine_inst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.start_i(start_transfer),
		.addr_acked_i(addr_acked),
		.data_acked_i(data_acked),
		.error_i(1'b0),
		.state_o(state),
		.transfer_complete_o(transfer_complete),
		.error_o(error)
	);
	
	//Instatiate bus controller
	bus_controller bus_controller_inst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.state_i(state),
		.scl_i(scl_i),
		.sda_i(sda_i),
		.scl_o(scl_o),
		.sda_o(sda_o),
		.sel_od_pp_o(sel_od_pp_o)
	);
	
	//Instatiate addressing module
	addressing addressing_inst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.state_i(state),
		.sda_i(sda_i),
		.device_address_i(device_address),
		.is_read_i(is_read),
		.target_addr_o(target_addr),
		.addr_valid_o(addr_valid),
		.addr_acked_o(addr_acked)
	);
	
	//Instantiate data handler
	data_handler data_handler_inst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.state_i(state),
		.write_data_i(write_data),
		.is_read_i(is_read),
		.sda_i(sda_i),
		.tx_data_o(sda_o),
		.rx_data_o(rx_data),
		.data_valid_o(data_valid),
		.data_acked_o(data_acked),
		.read_data_o(read_data)
	);
    // Clock generation (simplified)
    assign scl_o = (state != `IDLE) ? clk_i : 1'b1;
    assign sel_od_pp_o = (state == `DATA) ? 1'b1 : 1'b0; // Push-pull in data phase
    assign current_state_o = state;  // Expose state for debug
endmodule