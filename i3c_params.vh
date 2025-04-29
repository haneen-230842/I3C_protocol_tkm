//i3c_params.vh - is shared by all modules
`ifndef I3C_PARAMS_VH
`define I3C_PARAMS_VH

//State Machine Encoding
`define STATE_WIDTH 3
`define IDLE    3'b000
`define START   3'b001
`define ADDRESS 3'b010
`define ACK_WAIT 3'b011
`define DATA    3'b100
`define STOP    3'b101
`define ERROR   3'b110

//Bus Parameters
`define ADDR_WIDTH 7
`define DATA_WIDTH 8
`define BROAD_CAST 7'h7F

//Timing Parameters (ns)
`define CLK_PERIOD 20   //50MHz
`define SCL_PERIOD 100  //10MHz SCL
`define T_HD_STA   400  //Start hold time
`define T_SU_STA   600  //Start setup time

`endif