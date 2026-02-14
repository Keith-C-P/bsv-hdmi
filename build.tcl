set PART xc7a200tsbg484-1
set TOP mkTop

puts "Reading Clock Wizard IP..."
read_ip src/ip/clk/clk_wiz_0.xci
generate_target all [get_ips clk_wiz_0]
synth_ip [get_ips clk_wiz_0]

puts "Reading Verilog files..."
set verilog_files [glob build/verilog/*.v]
read_verilog $verilog_files

puts "Reading synthesis constraints..."
read_xdc constraints.xdc

puts "Running synthesis..."
synth_design -top $TOP -part $PART

puts "Running opt_design..."
opt_design

puts "Running place_design..."
place_design

puts "Reading implementation constraints..."
read_xdc -mode out_of_context constraints_impl.xdc

puts "Running route_design..."
route_design

puts "Writing bitstream..."
write_bitstream -force build/bitstream/hdmi.bit

puts "Build Complete!"
