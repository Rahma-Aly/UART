module StopCheck(
	input       clk,
	input       rst_n,
	input       sampled_stop_bit,
	input       Stop_check_en,
	output reg  Stop_err
);
	
	always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
	    Stop_err <= 0;
	end
	else if (Stop_check_en) begin
	        if (sampled_stop_bit) begin
	            Stop_err <= 0;
	        end
	        else begin
	                Stop_err <= 1;
	            end
	    end
	else begin
         Stop_err <= 0;
         end
             
	end
	
endmodule : StopCheck
