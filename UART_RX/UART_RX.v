module UART_RX#(parameter width = 8, Prescale_value = 8)(
	input                                          clk,
	input                                          rst_n,
	input                                          Rx_IN,
	input [$clog2(Prescale_value):0]               Prescale,
    input                                          Parity_Type, //0 -> even , 1->odd
    input                                          Parity_EN,
    output reg [width-1:0]                         P_Data,
    output reg                                     Data_Valid
);

	wire                              Sampled_bit, par_error, Start_glitch, Stop_err;
	wire                              dat_samp_EN, deser_en,Par_chk_en, Start_check_en, Stop_check_en,EN;
	wire [$clog2(Prescale_value)-1:0] edge_cnt;
	wire [3:0]                        Bit_count;
	wire [width-1:0]                  internal_P_Data;
	wire                              internal_Data_Valid;
	
	DataSampling #(
	    .Prescale_value(Prescale_value)
	) DataSampling_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .Rx_IN(Rx_IN),
	    .dat_samp_EN(dat_samp_EN),
	    .edge_cnt(edge_cnt),
	    .Prescale(Prescale),
	    .Sampled_bit(Sampled_bit)
	);
	
	DeSerializer DeSerializer_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .sampled_data_bit(Sampled_bit),
	    .deser_en(deser_en),
	    .P_Data(internal_P_Data)
	);
	
	ParityCheck ParityCheck_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .Par_chk_en(Par_chk_en),
	    .Parity_Type(Parity_Type),
	    .Sampled_Parity_bit(Sampled_bit),
	    .P_Data(internal_P_Data),
	    .par_error(par_error)
	);
	
	StartCheck StartCheck_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .sampled_start_bit(Sampled_bit),
	    .Start_check_en(Start_check_en),
	    .Start_glitch(Start_glitch)
	);
	
	StopCheck StopCheck_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .sampled_stop_bit(Sampled_bit),
	    .Stop_check_en(Stop_check_en),
	    .Stop_err(Stop_err)
	);
	
	Edge_Bit_Counter #(
	    .Prescale_value(Prescale_value)
	) Edge_Bit_Counter_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .EN(EN),
	    .Bit_count(Bit_count),
	    .Edge_count(edge_cnt)
	);
	
	FSM #(
	    .Prescale_value(Prescale_value)
	) FSM_instance(
	    .clk(clk),
	    .rst_n(rst_n),
	    .Parity_EN(Parity_EN),
	    .Rx_IN(Rx_IN),
	    .parity_err(par_error),
	    .start_glitch(Start_glitch),
	    .stop_err(Stop_err),
	    .Edge_count(edge_cnt),
	    .Bit_count(Bit_count),
	    .EN(EN),
	    .Par_chk_en(Par_chk_en),
	    .Stop_check_en(Stop_check_en),
	    .Start_check_en(Start_check_en),
	    .dat_samp_EN(dat_samp_EN),
	    .deser_en(deser_en),
	    .DataValid(internal_Data_Valid)
	);
	
	always @(*) begin
	Data_Valid = internal_Data_Valid;
	P_Data = internal_P_Data;
	end
	
endmodule : UART_RX
