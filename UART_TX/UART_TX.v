module UART_TX #(parameter width = 8)(
    input              clk,
    input              rst_n, //sychronous reset signal
    input              Data_Valid, //input data valid signal , indicates start of transmission
    input              Parity_type, //0 -> even , 1->odd
    input              Parity_EN,
    input [width-1:0]  P_Data, //parallel input data
    output reg         TX_Out, //serial output data
    output reg         Busy //high signal when transmitting
);

/*The UART transmitter section sends the following to the receiving device:
 * 1. 1 start bit
 * 2. 5 to 8 data bits depending on the data width section.
 * 3. 1 optional parity bit
 * 4. 1 or 2 stop bits
 * 
 * Method of transmission: Asynchronous */

//start and stop bits values           
localparam START_BIT = 0, STOP_BIT = 1;

//MUX_SEL values
localparam Start_bit  = 'b00,
           Stop_bit   = 'b01,
           S_Data     = 'b10,
           Parity_Bit = 'b11;
           
wire  Par_bit, S_DataOut, S_Done;
wire [1:0] MUX_SEL;
wire internal_busy;

Serializer #(
    .width(width)
) Serializer_instance(
    .clk(clk),
    .rst_n(rst_n),
    .Data_Valid(Data_Valid),
    .P_DataIn(P_Data),
    .Shift_EN(SData_EN),
    .S_Done(S_Done),
    .S_DataOut(S_DataOut)
);

Parity_Calc Parity_Calc_instance(
    .clk(clk),
    .rst_n(rst_n),
    .Parity_EN(Parity_EN),
    .P_Data(P_Data),
    .Valid_Data(Data_Valid),
    .Parity_type(Parity_type),
    .Parity_bit(Par_bit)
);

ControlLogic ControlLogic_instance(
    .clk(clk),
    .rst_n(rst_n),
    .Data_Valid(Data_Valid),
    .Parity_EN(Parity_EN),
    .S_Done(S_Done),
    .MUX_SEL(MUX_SEL),
    .SData_EN(SData_EN),
    .Busy(internal_busy)
);

always @(*)
 begin
     Busy = internal_busy;
        case (MUX_SEL)
            Start_bit: begin
                TX_Out = START_BIT;
            end
            Stop_bit: begin
                TX_Out = STOP_BIT;
            end
            S_Data: begin
                TX_Out = S_DataOut;
            end
            Parity_Bit: begin
                TX_Out = Par_bit;
            end
       endcase           
     
 end
 
endmodule : UART_TX
