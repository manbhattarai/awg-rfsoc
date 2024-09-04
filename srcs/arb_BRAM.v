module awg_BRAM_2CLKS 
    #(parameter GPIO_DATA_WIDTH = 16,
    parameter RAM_DATA_WIDTH = 128,
    parameter DAC_DATA_WIDTH = 256,
    parameter RAM_DEPTH = 15,
    parameter URAM_DATA_WIDTH=128,
    parameter URAM_DEPTH = 32768)
    (input [1:0]we,
    input wclk,
    input [RAM_DEPTH-1:0] row,
    input [2:0] col,
    input [GPIO_DATA_WIDTH-1:0] gpio_data_in,
    input [31:0] MAX_POINTS,
    input m00_axis_aclk,
    output [DAC_DATA_WIDTH-1:0] m00_axis_tdata,
    output m00_axis_tvalid
    );
    
    reg [RAM_DEPTH-1:0] raddr0;
    reg [RAM_DEPTH-1:0] raddr1;
    
    reg [URAM_DATA_WIDTH-1:0] uram0 [0:URAM_DEPTH-1];
    reg [URAM_DATA_WIDTH-1:0] uram1 [0:URAM_DEPTH-1];
    
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] uram0_pipe0;
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] uram1_pipe0;
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] uram0_pipe1;
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] uram1_pipe1;
    
    (*ASYNC_REG = "TRUE"*) reg [DAC_DATA_WIDTH-1:0] data_out_pipe0;
    (*ASYNC_REG = "TRUE"*) reg [DAC_DATA_WIDTH-1:0] data_out_pipe1;    
    
    reg valid_out = 0;
    reg write_complete = 0;
    always@(posedge wclk)
    begin
        if(we==1)
            uram0[row][col*16 +: 16] <= gpio_data_in;
        else if(we == 2)
            uram1[row][col*16 +: 16] <= gpio_data_in;
        else
            write_complete <= 1;
    end
    
    always@(posedge m00_axis_aclk)
    begin
        if(we == 0)
        begin
            valid_out <= 1;
            uram0_pipe0 <= uram0[raddr0];
            uram1_pipe0 <= uram1[raddr1];
            uram0_pipe1 <= uram0_pipe0;
            uram1_pipe1 <= uram1_pipe0;
                          
            data_out_pipe0 <= {uram1_pipe1,uram0_pipe1};
            data_out_pipe1 <= data_out_pipe0;
        end 
        else
            data_out_pipe0 <= 0;
    end
     
     reg [RAM_DEPTH-1:0] raddr0_pipe = 0;
     reg [RAM_DEPTH-1:0] raddr1_pipe = 0;
     always@(posedge m00_axis_aclk)
     begin
        if (raddr0_pipe < MAX_POINTS)
        begin    
            raddr0_pipe <= raddr0_pipe + 1;
            raddr1_pipe <= raddr1_pipe + 1;
        end
        else
        begin
            raddr0_pipe <= 0;
            raddr1_pipe <= 0;
        end
        raddr0 <= raddr0_pipe;
        raddr1 <= raddr1_pipe;
     end
     
     assign m00_axis_tdata = data_out_pipe1;
     assign m00_axis_tvalid = valid_out;
     
    
endmodule
