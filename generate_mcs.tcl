set BITFILE build/bitstream/hdmi.bit
set MCSFILE build/mcs/hdmi.mcs

write_cfgmem -force \
  -format mcs \
  -interface spix4 \
  -size 16 \
  -loadbit "up 0x0 $BITFILE" \
  $MCSFILE
