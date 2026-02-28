if {[catch {open_project ./build/my_proj.xpr}]} {
    create_project my_proj ./build
}
set PART xc7a200tsbg484-1
set TOP mkTop
set_property BOARD_PART digilentinc.com:nexys_video:part0:1.2 [current_project]
get_property PART [current_project]
# report_property [current_project]
# set_property IP_OUTPUT_DIR ./build/ip [current_project]

read_ip src/ip/clk/clk_wiz_0.xci
generate_target all [get_ips clk_wiz_0]
synth_ip [get_ips clk_wiz_0]

set verilog_files [glob build/verilog/*.v]
read_verilog $verilog_files
read_xdc constraints.xdc
synth_design -top $TOP -part $PART
puts [get_ports]
opt_design

# puts "Checking if LED constraint was applied..."
# puts "LED LOC: [get_property LOC [get_ports led0]]"
# puts "LED PIN: [get_property PACKAGE_PIN [get_ports led0]]"
# puts "LED IOSTANDARD: [get_property IOSTANDARD [get_ports led0]]"

puts "Checking HDMI constraint..."
puts "HDMI p0 LOC: [get_property LOC [get_ports hdmi_tx_p0]]"
puts "HDMI p0 IOSTANDARD: [get_property IOSTANDARD [get_ports hdmi_tx_p0]]"

place_design
route_design
write_bitstream -force build/bitstream/hdmi.bit
