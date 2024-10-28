module DAC
    #(parameter DAC_OUT_WIDTH = 16,
    parameter DAC_DATA_WIDTH = 256
    )
    (input dac_clk,
    input [DAC_DATA_WIDTH-1:0] DAC_data_in,
    input DAC_data_valid,
    output reg [DAC_OUT_WIDTH-1:0] DAC_data_out
    );
    
    reg [3:0] sample = 0;
    always@(posedge dac_clk)
    begin
        if (DAC_data_valid)
        begin
            DAC_data_out <= DAC_data_in[DAC_OUT_WIDTH*sample +: DAC_OUT_WIDTH];
            sample <= sample + 1;
        end
    end


endmodule

