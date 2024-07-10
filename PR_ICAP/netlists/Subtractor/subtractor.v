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

// AXI Slave Stream Module
reg [31:0] input1_reg;
reg [31:0] input2_reg;
reg [31:0] result_reg;
reg [1:0] state;
reg [3:0] tempstrb;
reg [1:0] m_axis_tvalid_reg;
reg [1:0] m_axis_tlast_reg;

localparam IDLE = 2'b00;
localparam INPUT1 = 2'b01;
localparam INPUT2 = 2'b10;
localparam ADD = 2'b11;

//localparam tready_param = 1'b1;   
//assign m_axis_tready = tready_param;
//assign s_axis_tready = tready_param;

assign s_axis_tready = m_axis_tready;
assign m_axis_tdata = result_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tstrb = tempstrb;
assign m_axis_tlast = m_axis_tlast_reg;

always @(posedge axis_clk) begin
    if (!axis_reset_n) begin
        state <= IDLE;
        input1_reg <= 0;
        input2_reg <= 0;
        result_reg <= 0;
    end 
    else begin
        case(state)
            IDLE: begin
                if (s_axis_tvalid) begin
                    input1_reg <= 0;
                    input2_reg <= 0;
                    result_reg <= 0;
                    state <= INPUT1;
                    m_axis_tvalid_reg <= 1'b0;
                end
            end
           INPUT1: begin
                if (s_axis_tvalid) begin
                
                    input1_reg <= s_axis_tdata;
                    state <= INPUT2;                     
                    m_axis_tvalid_reg <= 1'b0;
                end
          end
            INPUT2: begin
                input2_reg <= s_axis_tdata;
                state <= ADD;
                m_axis_tvalid_reg <= 1'b0;
            end
            ADD: begin
                result_reg <= input1_reg - input2_reg;
                tempstrb <= 4'b1111;
                m_axis_tvalid_reg <= 1'b1;
                if (m_axis_tready)begin
                    state <= IDLE;
                    m_axis_tlast_reg <= 1'b1;
                    end
            end
        endcase
    end
end

endmodule
