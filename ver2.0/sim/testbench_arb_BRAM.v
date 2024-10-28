`timescale 1ns/1ps
`include "arb_BRAM.v"
`include "DAC.v"
module tb_awg_BRAM_parity;

    // Parameters
    parameter GPIO_DATA_WIDTH = 16;
    parameter DAC_DATA_WIDTH = 256;
    parameter RAM_DEPTH = 16;
    // Inputs
    reg [1:0] we;
    reg wclk;
    reg [RAM_DEPTH-1:0] row;
    reg [2:0] col;
    reg [GPIO_DATA_WIDTH-1:0] gpio_data_in;
    reg [31:0] MAX_POINTS;
    reg m00_axis_aclk;
    // Outputs
    wire [DAC_DATA_WIDTH-1:0] m00_axis_tdata;
    wire m00_axis_tvalid;

    reg dac_clk;
    
    // Instantiate the arb_rfsoc
    awg_BRAM_parity uut (
        .we(we),
        .wclk(wclk),
        .row(row),
        .col(col),
        .gpio_data_in(gpio_data_in),
        .MAX_POINTS(MAX_POINTS),
        .m00_axis_aclk(m00_axis_aclk),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tvalid(m00_axis_tvalid)
    );

    wire [GPIO_DATA_WIDTH-1:0] DAC_data_out;
    // Instantiate the DAC
    DAC dut (
        .dac_clk(dac_clk),
        .DAC_data_valid(m00_axis_tvalid),
        .DAC_data_in(m00_axis_tdata),
        .DAC_data_out(DAC_data_out)
    );
    
    // Clock generation
    initial begin
        wclk = 0;
        forever #0.25 wclk = ~wclk;  // 10 MHz clock period is 10ns, so half-period is 5 ns
    end
    
    initial begin
        m00_axis_aclk = 0;
        forever #0.8 m00_axis_aclk = ~m00_axis_aclk;  // 625 MHz clock period is 1.6 ns, half-period is 0.8 ns
    end

    initial begin
        dac_clk = 0;
        forever #0.05 dac_clk = ~dac_clk;  // 10 GHz DAC clock
    end

    // Variables for accessing data
    integer i;

    reg [RAM_DEPTH-1:0] data_points [0:(1<<(RAM_DEPTH+4))-1];
    initial begin
        $readmemh("data_points.txt", data_points);
    end

    integer counter;
    integer program_counter;
    reg we_idx;
    reg [1:0] we_ram [0:1];
    initial
    begin
        counter = 0;
        col = 0;
        row = 0;
        we = 1;
        we_idx = 0;
        we_ram[0] = 1;
        we_ram[1] = 2;
        MAX_POINTS = 2**16;
        //program_counter = 0;
    end

    always@(posedge wclk)
    begin
        if(we != 0)
        begin
            counter <= counter +1;
            gpio_data_in <= data_points[counter];
            we <= we_ram[we_idx];
            if (col == 7)
                we_idx <= we_idx +1;
            if ((col == 7) && (we == 2))
                row <= row + 1;
            if (row == 2**16-1)
            begin
                we <= 0;
                program_counter <= 0;
            end
            
        end
        col <= col +1;
    end

    integer file;
    initial
    begin
        file = $fopen("output.txt", "w");
    end

    always@(posedge dac_clk)
    begin
        if(counter > 2**16-1)
            $fwrite(file, "%h\n", DAC_data_out);
    end
    
    always @ (posedge m00_axis_aclk)
    begin
        program_counter <= program_counter +1;
        if(counter % 100000 == 0)
            $display("Counter : %d",counter);
        if(program_counter % 100000 == 0)
            $display("Program counter : %d, no of points %d", program_counter,(1<<(RAM_DEPTH+4))-1);
        if (program_counter > MAX_POINTS*3.2)
        begin
            $fclose(file);
            $finish;
        end
    end

    // VCD file generation
    initial begin
        $dumpfile("simulation_result.vcd");  // Specify VCD file name
        $dumpvars(0, tb_awg_BRAM_parity);  // Dump all variables in the testbench
    end
    
    
endmodule
