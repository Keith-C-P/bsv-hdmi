set PART  xc7a200t1sbg484C-1
set TOP mkTop

puts "Reading Clock Wizard IP..."
read_ip src/ip/clk/clk_wiz_0.xci
generate_target all [get_ips clk_wiz_0]
synth_ip [get_ips clk_wiz_0]

puts "Reading Verilog files..."
set verilog_files [glob build/verilog/*.v]
read_verilog $verilog_files

puts "Reading pin constraints AFTER opt..."
read_xdc constraints.xdc

puts "Running synthesis..."
synth_design -top $TOP -part $PART

puts "Ports after synthesis:"
puts [get_ports]

puts "Running opt_design..."
opt_design

# puts "Checking if LED constraint was applied..."
# puts "LED LOC: [get_property LOC [get_ports led0]]"
# puts "LED PIN: [get_property PACKAGE_PIN [get_ports led0]]"
# puts "LED IOSTANDARD: [get_property IOSTANDARD [get_ports led0]]"

puts "Checking HDMI constraint..."
puts "HDMI p0 LOC: [get_property LOC [get_ports hdmi_tx_p0]]"
puts "HDMI p0 IOSTANDARD: [get_property IOSTANDARD [get_ports hdmi_tx_p0]]"

puts "Running place_design..."
place_design

puts "Running route_design..."
route_design

puts "Writing bitstream..."
write_bitstream -force build/bitstream/hdmi.bit

puts "Build Complete!"
