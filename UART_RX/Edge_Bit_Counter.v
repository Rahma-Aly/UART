module Edge_Bit_Counter #(parameter Prescale_value = 8)(
	input                                   clk,
	input                                   rst_n,
	input                                   EN,
	output reg                      [3:0]   Bit_count,
	output reg [$clog2(Prescale_value)-1:0] Edge_count
);
	
	reg bit_flag;
	
	always @(posedge clk or negedge rst_n) begin : edge_counter
	if (~rst_n | ~EN) begin
	    Edge_count <= 0;
	end
	else if (EN) begin
	        Edge_count <= Edge_count + 1;
	        
	    end      
	end
	
	always @(posedge clk or negedge rst_n) begin: bit_counter
	        if (~rst_n | ~EN) begin
	            Bit_count <= 0;
	        end
	        else if (bit_flag) begin
            Bit_count <= Bit_count + 1;
            end 
	end
	
	always @(*) begin : flag_setter
	    if (Edge_count == 'd7) bit_flag = 1;
	    else bit_flag = 0;
	    end
	
endmodule : Edge_Bit_Counter
