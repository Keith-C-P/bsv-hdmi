
package fpga_top;

import HDMI :: *;
import Vector :: *;
import RegFile :: *;
import ClkWiz :: *;
import TMDS_Serializer :: *;
import Clocks :: *;

interface Top_IFC;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_p0;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_n0;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_p1;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_n1;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_p2;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_n2;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_clk_p;
    (* always_ready, always_enabled *)
    method Bit#(1) hdmi_tx_clk_n;
endinterface

(* synthesize *)
module mkTop(Top_IFC);

    ClkWiz_IFC clkgen <- mkClkWiz;

    Clock pixel_clk   = clkgen.clk_out1;
    Clock tmds_clk_5x = clkgen.clk_out2;

    HDMI_IFC hdmi <- mkhdmi(clocked_by pixel_clk, reset_by noReset);

    TMDS_Serializer_IFC red_ser <- mkTMDS_Serializer(
        pixel_clk,
        tmds_clk_5x,
        1'b0,
        hdmi.tmds_r
    );

    TMDS_Serializer_IFC green_ser <- mkTMDS_Serializer(
        pixel_clk,
        tmds_clk_5x,
        1'b0,
        hdmi.tmds_g
    );

    TMDS_Serializer_IFC blue_ser <- mkTMDS_Serializer(
        pixel_clk,
        tmds_clk_5x,
        1'b0,
        hdmi.tmds_b
    );

    TMDS_Serializer_IFC clk_ser <- mkTMDS_Serializer(
        pixel_clk,
        tmds_clk_5x,
        1'b0,
        10'b1111100000
    );

    method Bit#(1) hdmi_tx_p0    = red_ser.tmds_p;
    method Bit#(1) hdmi_tx_n0    = red_ser.tmds_n;
    method Bit#(1) hdmi_tx_p1    = green_ser.tmds_p;
    method Bit#(1) hdmi_tx_n1    = green_ser.tmds_n;
    method Bit#(1) hdmi_tx_p2    = blue_ser.tmds_p;
    method Bit#(1) hdmi_tx_n2    = blue_ser.tmds_n;
    method Bit#(1) hdmi_tx_clk_p = clk_ser.tmds_p;
    method Bit#(1) hdmi_tx_clk_n = clk_ser.tmds_n;

endmodule

endpackage

