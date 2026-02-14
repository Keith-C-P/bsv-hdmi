# BSV-HDMI
A bluespec verilog implementation of the HDMI protocol

## Installation:
1. Download and install `Vivado 2018.3`
2. Install the board files
3. `$ make`
4. Use generated bitstream or mcs (in ./build/bitstream and ./build/mcs) to flash onto Nexys Video board
5. Plug in a monitor through HDMI Out.

> Verilator simulation is also available, use `make help` for more information \
> Feel free to edit the Makefile to your own needs.