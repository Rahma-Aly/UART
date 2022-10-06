module DataSampling #(parameter Prescale_value = 8)(
	input wire                              clk,
	input wire                              rst_n,
	input wire                              Rx_IN,       //serial input
	input wire                              dat_samp_EN, //Data Sample enable
	input wire [$clog2(Prescale_value)-1:0] edge_cnt,  // edge counter -> number of edges , if equal prescale -1 , 
	                                                   //                  1 bit has been transmitted
	input wire [$clog2(Prescale_value):0]   Prescale,
	output reg                              Sampled_bit
);


           
reg [2:0]  samples;     
reg [1:0]  ones_counter;  
 
wire req_Edges, final_value;
wire [$clog2(Prescale_value):0] Middle_Sample, Left_Sample, Right_Sample, final_Sample;   

assign Middle_Sample = (Prescale >> 1)-1;
assign Left_Sample   = (Middle_Sample - 1);
assign Right_Sample  = (Middle_Sample + 1);
assign final_Sample  = (Middle_Sample + 2);


assign req_Edges   = (edge_cnt == Middle_Sample)|(edge_cnt == Left_Sample)|(edge_cnt == Right_Sample) ;    
assign final_value = (edge_cnt == final_Sample) |(edge_cnt == Middle_Sample)| (edge_cnt == Right_Sample);
  
    always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        samples <= 0;
        end
    else if (dat_samp_EN & req_Edges) begin
        samples <= {samples[1:0], Rx_IN};
    end    
    end


    always @(posedge clk or negedge rst_n) begin : OnesCounter
        if (~rst_n) begin
            Sampled_bit  <= 0;
            ones_counter <= 0; 
        end
        else if (dat_samp_EN & final_value) begin
            if (samples[0]) begin
                ones_counter <= ones_counter + 1;
            end               
        end
        else if (edge_cnt == (Prescale - 1)) begin
           ones_counter <= 0; 
        end
    end
    
    always @(*) begin : MUX_BLOCK //TODO: Check if output needs to be regestered
        case (ones_counter)
            'b00: Sampled_bit = 0;
            'b01: Sampled_bit = 0;
            'b10: Sampled_bit = 1;
            'b11: Sampled_bit = 1;
        endcase
    end

	
endmodule : DataSampling
