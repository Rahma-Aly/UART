module StartCheck(
	input       clk,
	input       rst_n,
	input       EN,
	input       sampled_start_bit,
	input       Start_check_en,
	output reg  Start_glitch
);
	
	always @(posedge clk or negedge rst_n) begin
	if (~rst_n | ~EN) begin
	    Start_glitch <= 0;
	end
	else if (Start_check_en) begin
	        if (~sampled_start_bit) begin
	            Start_glitch <= 0;
	        end
	        else begin
	                Start_glitch <= 1;
	            end
	    end
//	 else begin
//	         Start_glitch <= 0;
//	     end
	     
	end
	
endmodule : StartCheck
