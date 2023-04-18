## Description

This module performs reading both data and clock signals form an ADC connected to the FPGA.

ADC clock signal can be either differential or single-ended. Whether single-ended or differential clock is being used, the correcponding generic parameter should be set to enable successful synthesis, implementation, bitstream generation of this core.

This core is designed for single-ended data signals.

This module has been originaly developed to interface an ADC on the Red Pitaya STEMLab 125-10 board. Therefore, further testing (for example, signal pass-through) should be performed on other devices before using this core with other platforms.

### Main Operation

1. Set generic parameters:
- BIT_CREATE_CLK_BUFFERS: 1(true) or 0(false)
- BIT_DIFFERENTIAL_CLK: 1(true) or 0(false)
- INT_ADC_CHANNELS: 1 or 2
- INT_ADC_DATA_WIDTH: Enter the number of ADC data bits
- INT_AXIS_DATA_WIDTH: 32 bits typically

2. To synthesize this module in out-of-context mode, do the following:
- make reset
- make src TOP=axis_adc_read.v
- make ooc

## TODO
- Add support for differential inputs