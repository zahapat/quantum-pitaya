import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtGui
import numpy as np
from math import ceil, log2

# Functions
# Extract the desired number of lower bits from 32b string hex and output integer value
def unsint_extract_lower_bits_from_32b_hex_string(str_hex_number, int_lower_bit_count):
    return (int(str_hex_number, 16) & ((1 << int_lower_bit_count) - 1))

def unsint_extract_higher_bits_from_32b_hex_string(str_hex_number, int_higher_bit_count):
    return (int(str_hex_number, 16) & ((1 << int_higher_bit_count) - 1)) >> (32 - int_higher_bit_count)



# ---------------------------------------------------
# Configuration
# ---------------------------------------------------
INT_ADC_RESOLUTION_BITS = 10
INT_ADC_RANGE_VOLTS = 2.2

# Generics
INT_BYPASS_DSP = 0
INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ = 25
INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ = 0
INT_DDC_NUMBER_OF_TAPS = 15
INT_DDC_COEF_WIDTH = 15
INT_DDC_OUT_DATA_WIDTH = 20
INT_DDC_DECIMATION = 1
INT_AVG_AVERAGE_BY = 1

filename_ch1 = "C:\\Git\zahapat\\FQEnv\outputs\\redpitaya\\"\
    +str(INT_BYPASS_DSP)+"_" \
    +str(INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ)+"_" \
    +str(INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ)+"_" \
    +str(INT_DDC_NUMBER_OF_TAPS)+"_" \
    +str(INT_DDC_COEF_WIDTH)+"_" \
    +str(INT_DDC_OUT_DATA_WIDTH)+"_" \
    +str(INT_DDC_DECIMATION)+"_" \
    +str(INT_AVG_AVERAGE_BY)+"_______\\" \
    +"read_ch1.txt"
filename_ch2 = "C:\\Git\zahapat\\FQEnv\outputs\\redpitaya\\"\
    +str(INT_BYPASS_DSP)+"_" \
    +str(INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ)+"_" \
    +str(INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ)+"_" \
    +str(INT_DDC_NUMBER_OF_TAPS)+"_" \
    +str(INT_DDC_COEF_WIDTH)+"_" \
    +str(INT_DDC_OUT_DATA_WIDTH)+"_" \
    +str(INT_DDC_DECIMATION)+"_" \
    +str(INT_AVG_AVERAGE_BY)+"_______\\" \
    +"read_ch2.txt"

# Correction
if (INT_BYPASS_DSP == 1):
    data_bits_range = 10
    INT_DDC_DECIMATION = 1
    INT_AVG_AVERAGE_BY = 1
else:
    data_bits_range = INT_DDC_OUT_DATA_WIDTH + ceil(log2(INT_AVG_AVERAGE_BY))


# ---------------------------------------------------
# Get Dataset 1
# ---------------------------------------------------
# Read hexadecimal data from text file and convert to numeric values
with open(filename_ch1, 'r') as file:
    lines_ch1 = file.readlines()

# Convert hexadecimal strings to integer values
resolution_maxval = (1 << data_bits_range)
# [print(unsint_extract_lower_bits_from_32b_hex_string(line, data_bits_range)) for line in lines_ch1]
values_ch1 = [unsint_extract_lower_bits_from_32b_hex_string(line, data_bits_range) for line in lines_ch1]
signed_values_averaged_ch1 = [(val-resolution_maxval)/INT_AVG_AVERAGE_BY if val >= (resolution_maxval/2) else val/INT_AVG_AVERAGE_BY for val in values_ch1]
# signed_values_averaged_ch1 = [(val-resolution_maxval) if val >= (resolution_maxval/2) else val for val in values_ch1]




# ---------------------------------------------------
# Get Dataset 2
# ---------------------------------------------------
# Read hexadecimal data from text file and convert to numeric values
with open(filename_ch2, 'r') as file:
    lines_ch2 = file.readlines()

# Convert hexadecimal strings to integer values
resolution_maxval = (1 << data_bits_range)
# [print(unsint_extract_lower_bits_from_32b_hex_string(line, data_bits_range)) for line in lines_ch2]
values_ch2 = [unsint_extract_lower_bits_from_32b_hex_string(line, data_bits_range) for line in lines_ch2]
signed_values_averaged_ch2 = [(val-resolution_maxval)/INT_AVG_AVERAGE_BY if val >= (resolution_maxval/2) else val/INT_AVG_AVERAGE_BY for val in values_ch2]
# signed_values_averaged_ch2 = [(val-resolution_maxval) if val >= (resolution_maxval/2) else val for val in values_ch2]





pg.mkQApp()
pw = pg.PlotWidget()
pw.show()
pw.setWindowTitle('pyqtgraph example: MultiplePlotAxes')


# ---------------------------------------------------
# Plot Dataset 1: Left Axis
# ---------------------------------------------------
plot1 = pw.plotItem
plot1.setLabels(left='axis 1')


# ---------------------------------------------------
# Plot Dataset 1: Right Axis
# ---------------------------------------------------
plot2 = pg.ViewBox()
plot1.showAxis('right')
plot1.scene().addItem(plot2)
plot1.getAxis('right').linkToView(plot2)
plot2.setXLink(plot1)
plot1.getAxis('right').setLabel('axis2', color='#0000ff')


## Handle view resizing 
def updateViews():
    ## view has resized; update auxiliary views to match
    global plot1, plot2
    plot2.setGeometry(plot1.vb.sceneBoundingRect())
    
    ## need to re-update linked axes since this was called
    ## incorrectly while views had different shapes.
    ## (probably this should be handled in ViewBox.resizeEvent)
    plot2.linkedViewChanged(plot1.vb, plot2.XAxis)

updateViews()
plot1.vb.sigResized.connect(updateViews)


plot1.plot(signed_values_averaged_ch1)
plot2.addItem(pg.PlotCurveItem(signed_values_averaged_ch2, pen='b'))

## Start Qt event loop unless running in interactive mode or using pyside.
if __name__ == '__main__':
    import sys
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QGuiApplication.instance().exec()