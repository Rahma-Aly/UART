module Serializer#(parameter width = 8)(
    input                  clk,
    input                  rst_n,
    input                  Data_Valid,
    input      [width-1:0] P_DataIn, //Parallel input
    input                  Shift_EN, //shift enable
    output reg             S_Done,   //-> 1 = all bits were shifted
    output reg             S_DataOut   //serial output
);

reg [width-1:0] P_DataInternal;
reg [2:0] counter;

	always @(posedge clk, negedge rst_n)
    begin :Shift_Block
        if (~rst_n) begin
            P_DataInternal <= 'b0;
            end
        if (Data_Valid) begin
                P_DataInternal <= P_DataIn;
            end
        if (Shift_EN) begin  
                P_DataInternal <= P_DataIn >> 1;
            end
                
    end
    
    always @(posedge clk, negedge rst_n)
    begin: counter_block
        if (~rst_n) begin
            counter <= 'b0;
            S_Done <= 0;
        end
        else if (Shift_EN) begin
                if (counter == width-1)
                begin
                    S_Done <= 'b1;
                    counter <= 'b0;
                end
                else begin
                        counter <= counter + 1;
                        S_Done  <= 'b0;
                    end
                end
    end    
    
    always@(*) begin
        S_DataOut = P_DataInternal[0];
        end
endmodule : Serializer
