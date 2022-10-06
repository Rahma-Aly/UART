module DeSerializer(
	input            clk,
	input            rst_n,
	input            sampled_data_bit,
	input            deser_en,
	output reg [7:0] P_Data
);
	
	 
	
	always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
	    P_Data <= 0;
	end
	else if (deser_en) begin
	        P_Data <= {sampled_data_bit, P_Data[7:1]};
	    end
	    
	end
	
	
endmodule : DeSerializer
