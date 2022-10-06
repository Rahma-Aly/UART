module FSM #(parameter Prescale_value = 8)(
	input                              clk,
	input                              rst_n,
	input                              Parity_EN,
	input                              Rx_IN,
	input                              parity_err,
	input                              start_glitch,
	input                              stop_err,
	input [$clog2(Prescale_value)-1:0] Edge_count,
	input                        [3:0] Bit_count,
	output reg                         EN,
	output reg                         Par_chk_en,
	output reg                         Stop_check_en,
	output reg                         Start_check_en,
	output reg                         dat_samp_EN,
	output reg                         deser_en,
	output reg                         DataValid
	
);
//States 
reg [2:0] PState, NState;
localparam IDLE       = 'b00,
           Start_bit  = 'b01,
           Data_bits  = 'b10,
           Parity_bit = 'b11,
           Stop_bit   = 'b100;

wire CaptureEdge, DataFlag;
assign  CaptureEdge = (Edge_count == 'd6)| (Edge_count == 'd7) ;
assign DataFlag = ((Bit_count < 9) & (Bit_count > 0)); 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        PState <= IDLE;
    end
    else begin
            PState <= NState;
        end   
end

always @(*) begin
    EN             = 0;
    Par_chk_en     = 0;
    Stop_check_en  = 0;
    Start_check_en = 0;
    dat_samp_EN    = 0;
    deser_en       = 0;
    DataValid      = 0;
    case (PState)
        IDLE: begin
            if (~Rx_IN) begin
                EN          = 1;
                dat_samp_EN = 1;
                NState      = Start_bit;
            end
            else begin
                    NState = IDLE;
                end  
        end
        Start_bit: begin
            EN          = 1;
            dat_samp_EN = 1;
            if (CaptureEdge) begin
                Start_check_en = 1;
            end
            else begin
                    Start_check_en = 0;
            end  
            if (Edge_count == 'd7) begin
                if (start_glitch) begin
                    EN             = 0;
                    dat_samp_EN    = 0;
                    Start_check_en = 0;
                    NState         = IDLE;              
                end
                else begin
                     NState = Data_bits;   
                    end                        
            end
            else begin
                 NState = Start_bit;
            end   
        end
        Data_bits: begin
            EN          = 1;
            dat_samp_EN = 1;
            if (Edge_count == 'd6) begin
                deser_en = 1;
            end
            else begin
                deser_en = 0;
            end
            if (DataFlag) begin
                NState = Data_bits;
            end
            else if (Parity_EN) begin
                NState = Parity_bit;
            end
            else begin
                NState = Stop_bit;
            end              
        end       
        Parity_bit:begin
            EN          = 1;
            dat_samp_EN = 1;
            if (CaptureEdge) begin
                Par_chk_en = 1;
            end
            else begin
                    Par_chk_en = 0;
            end
            if (Edge_count == 'd7) begin
                   if (parity_err) begin
                       EN             = 0;
                       dat_samp_EN    = 0;
                       Par_chk_en     = 0;
                       NState         = IDLE;
                   end
                   else begin
                         NState = Stop_bit;
                    end
            end
            else begin
                    NState = Parity_bit;
            end    
        end
        Stop_bit:begin
            EN          = 1;
            dat_samp_EN = 1;
            if (CaptureEdge) begin
                Stop_check_en = 1;
            end
            else begin
                    Stop_check_en = 0;
            end  
            if (Edge_count == 'd7) begin
                if (stop_err) begin
                    EN             = 0;
                    dat_samp_EN    = 0;
                    Stop_check_en  = 0;
                    NState         = IDLE;              
                end
                else begin
                     EN        = 0;
                     DataValid = 1; 
//                     if (Rx_IN) begin  
                     NState    = IDLE;   
//                     end
//                      else begin
//                         NState    = Start_bit; 
//                     end 
                end                        
            end
            else begin
                 NState = Stop_bit;
            end   
        end
        default: begin
            NState = IDLE;
        end
    endcase
    end

	
endmodule : FSM
