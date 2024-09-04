# awg-rfsoc
## An arbitrary waveform generator with the Real Digital RFSoC board.<br>

The FPGA on the device can be loaded with $2^{19}$ points and it can generate arbitrary waveform at a sampling rate of 9.34 GSps.<br><br>
The jupyter notebook included here provides some information on how the arbitrary wavefrom generation is implemented in the FPGA and how it can be programmed.<br>
The <i>srcs</i> folder contains the verilog code to realize the arbitrary generator block, a constraint file used for synthesis and implementation as well as the block diagram of the design.<br><br>
To use it copy the notebook <i>arb_with_rfsoc.ipynb</i> and the folder <i>package</i> onto the RFSoC device and execute the jupyter notebook with necessary modifications.

