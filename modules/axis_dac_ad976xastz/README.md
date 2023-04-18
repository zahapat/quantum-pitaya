## Description

This module performs writing data signals to an DAC connected to the FPGA.

This core is designed for single-ended data signals.

This module has been originaly developed to interface an DAC on the Red Pitaya STEMLab 125-10 board. Therefore, further testing (for example, signal pass-through) should be performed on other devices before using this core on other platforms.

### Main Operation

1. Set generic parameters:
- INT_DAC_CHANNELS: 1 or 2
- INT_DAC_DATA_WIDTH: Enter the number of DAC data bits
- INT_AXIS_DATA_WIDTH: 32 bits typically

2. To synthesize this module in out-of-context mode, do the following:
- make reset
- make src TOP=axis_dac_write.v
- make ooc

## TODO
- Add support for differential outputs