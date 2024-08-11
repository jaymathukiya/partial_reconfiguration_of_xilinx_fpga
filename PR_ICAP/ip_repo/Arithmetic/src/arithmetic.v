`timescale 1ns / 1ps


module arithmetic #(
    // Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line
        input wire axis_clk,
        input wire axis_reset_n,

		// Ports of Axi Slave Bus Interface S00_AXIS
		output wire  s_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
		input wire  s_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		output wire  m_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
		output wire m_axis_tlast,
		input wire  m_axis_tready
	);

    endmodule
