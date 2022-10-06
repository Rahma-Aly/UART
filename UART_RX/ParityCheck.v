module ParityCheck(
    input      clk,
	input      rst_n,
	input      Par_chk_en,
	input      Parity_Type, // 0 -> even , odd -> 1
	input      Sampled_Parity_bit,
	input [7:0]P_Data,
	output reg par_error // = 0 -> no error	
);
 
reg Calc_Parity_bit;   // parity -> 1 bit
        

localparam Even_parity = 0,
           Odd_parity  = 1;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        par_error       <= 0;
    end
    else if (Par_chk_en) begin
        par_error <= Calc_Parity_bit ^ Sampled_Parity_bit;
     end 
       
end
	
	always @(*) begin : parity_calc
	    if (Par_chk_en) begin
	       case (Parity_Type)
            Even_parity: Calc_Parity_bit = ^P_Data;
            Odd_parity:  Calc_Parity_bit = ~^P_Data; 
           endcase
       end
       else begin
       Calc_Parity_bit = 0;
       end
	end
	
endmodule : ParityCheck
