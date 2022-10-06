module ControlLogic(
    input              clk,
    input              rst_n, //sychronous reset signal
    input              Data_Valid, //input data valid signal
    input              Parity_EN,
    input              S_Done,
    output reg [1:0]   MUX_SEL,
    output reg         SData_EN,
    output reg         Busy

);

 /*state machine States are: Idle, Send Start bit, send data, send parity (optional), send stop bit*/
 localparam IDLE      = 'b01,
            START     = 'b10,
            DATA      = 'b11,
            PARITY    = 'b100,
            STOP      = 'b101; 
            
//current state of state machine
reg [2:0]       PState,NState;

//MUX_SEL Output values
localparam Start_bit  = 'b00,
           Stop_bit   = 'b01,
           S_Data     = 'b10,
           Parity_bit = 'b11;
           
           
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n) PState <= IDLE;
    else
    PState <= NState;
end

always @(*)
 begin 	
     Busy     = 0;
     SData_EN = 0;
     MUX_SEL = Stop_bit;
      case (PState)
          IDLE   : begin
              if (Data_Valid) begin
                  NState = START;
              end   
          end
          START  : begin
              Busy = 1;
              MUX_SEL = Start_bit;
              NState = DATA;
              end
          DATA   : begin
              Busy     = 1;
              SData_EN = 1;
              MUX_SEL = S_Data;
              if (Parity_EN && S_Done) begin
              NState = PARITY;
              end
              else if (S_Done) begin
              NState = STOP;
              end
              end
          PARITY : begin
              Busy = 1;
              MUX_SEL = Parity_bit;
              NState = STOP;
              end
          STOP   : begin
              Busy = 1;
              NState = IDLE;
              end
          default: begin
               NState = IDLE;
              end
          endcase     
 end
 


	
endmodule : ControlLogic
