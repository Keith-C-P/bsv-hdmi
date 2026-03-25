set PART xc7a200tsbg484-1
set TOP mkTop

if {[catch {open_project ./build/my_proj.xpr}]} {
    create_project my_proj ./build -part xc7a200tsbg484-1
    set_property BOARD_PART digilentinc.com:nexys_video:part0:1.2 [current_project]
}

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

get_cells -hierarchical *ila*
get_cells -hierarchical *dbg_hub*

opt_design
place_design
route_design

write_debug_probes -force build/debug/ila.ltx
write_bitstream -force build/bitstream/hdmi.bit

puts "Build Complete!"