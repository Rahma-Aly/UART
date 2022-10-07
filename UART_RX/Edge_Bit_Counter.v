module Edge_Bit_Counter (
	input                                   clk,
	input                                   rst_n,
	input                                   EN,
	input                           [5:0]   Prescale,
	output reg                      [3:0]   Bit_count,
	output reg                      [5:0]   Edge_count
);
	
	reg bit_flag;
	
	always @(posedge clk or negedge rst_n) begin : edge_counter
	if (~rst_n | ~EN) begin
	    Edge_count <= 0;
	end
	else if (EN) begin
            if (bit_flag) begin
               Edge_count <= 0;
           end
           else begin
	        Edge_count <= Edge_count + 1;   
	        end
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
	    if (Edge_count == (Prescale-1)) bit_flag = 1;
	    else bit_flag = 0;
	    end
	
endmodule : Edge_Bit_Counter
