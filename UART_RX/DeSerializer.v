module DeSerializer #( parameter width = 8)(
	input                  clk,
	input                  rst_n,
	input                  sampled_data_bit,
	input                  deser_en,
	output reg [width-1:0] P_Data
);
	
	 
	
	always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
	    P_Data <= 0;
	end
	else if (deser_en) begin
	        P_Data <= {sampled_data_bit, P_Data[width-1:1]};
	    end
	    
	end
	
	
endmodule : DeSerializer
