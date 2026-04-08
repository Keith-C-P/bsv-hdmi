set PART xc7a200tsbg484-1
set TOP fpga_top

if {[file exists ./build/my_proj.xpr]} {
    close_project -quiet
}
create_project -force my_proj ./build -part xc7a200tsbg484-1
set_property BOARD_PART digilentinc.com:nexys_video:part0:1.2 [current_project]

read_ip src/ip/clk/clk_wiz_0.xci
generate_target all [get_ips clk_wiz_0]
synth_ip [get_ips clk_wiz_0]

read_ip src/ip/ila/ila_0.xci
generate_target all [get_ips ila_0]
synth_ip [get_ips ila_0]

set verilog_files [glob build/verilog/*.v]
read_verilog $verilog_files

read_xdc constraints.xdc

synth_design -top $TOP -part $PART

set clk_net [get_nets -of_objects [get_clocks sys_clk_pin]]
puts $clk_net
connect_debug_port dbg_hub/clk $clk_net
report_clocks
report_debug_core
report_timing_summary

opt_design
place_design
route_design

write_debug_probes -force build/debug/ila.ltx
write_bitstream -force build/bitstream/hdmi.bit

puts "Build Complete!"
