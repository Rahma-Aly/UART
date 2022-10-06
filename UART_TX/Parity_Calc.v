module Parity_Calc(
    input       clk,
    input       rst_n,
	input       Parity_EN,
	input [7:0] P_Data,
	input       Valid_Data,
	input       Parity_type, 
	output reg  Parity_bit
);

localparam even_parity = 0,
           odd_parity  = 1;

	always@(posedge clk, negedge rst_n)
	begin
	    if (~rst_n) Parity_bit <= 'b0; 
	    else if (Parity_EN && Valid_Data) begin
	      case (Parity_type)
	        even_parity: Parity_bit <= ^P_Data;
	        odd_parity : Parity_bit <= ~^P_Data;
	        default: Parity_bit <= 'b0;
	    endcase
	    end 
	end
	
endmodule : Parity_Calc
