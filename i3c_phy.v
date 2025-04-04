module i3c_phy (
	input clk_i,
	input rst_ni,
	
	// Physical I/O
	input i3c_scl_i,
	output i3c_scl_o,
	input i3c_sda_i,
	output i3c_sda_o,
	
	// Controller interface
	input ctrl_scl_i,
	input ctrl_sda_i,
	output ctrl_scl_o,
	output ctrl_sda_o,
	
	// Drive mode select
	input sel_od_pp_i, // 0=Open drain, 1=Pushpull
	output sel_od_pp_o
);

endmodule