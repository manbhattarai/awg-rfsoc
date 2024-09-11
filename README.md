# awg-rfsoc
## An arbitrary waveform generator (AWG) with the Real Digital RFSoC board.<br>

The FPGA on the device can be loaded with $2^{19}$ points and it can generate arbitrary waveform at a sampling rate of 9.34 GSps.<br><br>
An example jupyter notebook is included that demonstrates how the AWG can be programmed.<br>
The <i>srcs</i> folder contains the verilog code to realize the arbitrary generator block, a constraint file used for synthesis and implementation as well as the block diagram of the design.<br><br>
To use it copy the Jupyter notebook <i>arb_with_rfsoc.ipynb</i> and the folder <i>package</i> onto the RFSoC device and execute the notebook with necessary modifications.<br>
Once the overlay is loaded and the clocks are programmed, loading sample points on to the memory of the AWG can be initiated.The AWG memory contain two blocks of 128 bit wide by 32768 deep RAM as shown in the figure. AXI GPIOs, programmed with Pynq package, are used to write sample points onto the RAMs. The GPIOs send a row index and a column index that determines the RAM address at which the sample points are written. Row is a 15 bit unsigned number and column is a 3 bit unsigned number. For instance, the row value is initialzed to the value 0, and the column value is sequentially changed between 0 and 15 (16 values in total). When column value is 0, the first 16-bit sample point S0 is written on the 15 through to 0 index of the first memory address of the RAM0. The column value increases to 1, and the second 16-bit sample point S1 is written on the 31 through to 16 index of the first address of the RAM0. 
Each sample is sent ot the AWG as a 16-bit signed integer. For the sake of loading the AWG memory, the RAMs can be thought of as having  

