package fpga_top;

import HDMI :: *;
import Vector :: *;
import RegFile :: *;
import ClkWiz :: *;
import TMDS_Serializer :: *;
import Clocks :: *;
import ILA :: *;

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

    (* always_ready, always_enabled *)
    method Bit#(1) led0;  // DEBUG LED
    (* always_ready, always_enabled *)
    method Bit#(1) led1;  // DEBUG LED
    // (* always_ready, always_enabled *)
    // method Bit#(1) led2;  // DEBUG LED
    // (* always_ready, always_enabled *)
    // method Bit#(1) led3;  // DEBUG LED
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
        10'b0000011111
    );

    ILA_IFC ila <- mkILA(clocked_by pixel_clk);

    SyncBitIfc#(Bit#(1)) led_sync <- mkSyncBit(pixel_clk, noReset, clockOf(clkgen));

    Reg#(Bit#(32)) counter <- mkReg(0, clocked_by pixel_clk, reset_by noReset);
    rule debug;
        ila.probe0_10(hdmi.tmds_r);
        ila.probe1_10(hdmi.tmds_g);
        ila.probe2_10(hdmi.tmds_b);
        ila.probe3_10(10'b0);
        ila.probe4_10(10'b0);
        ila.probe5_8(8'b0);
        ila.probe6_8(8'b0);
        ila.probe7_8(8'b0);
        ila.probe8_8(8'b0);
        ila.probe9_8(8'b0);
        ila.probe10_1(hdmi.hsync);
        ila.probe11_1(hdmi.vsync);
        ila.probe12_1(hdmi.de);
        ila.probe13_1(1'b0);

        counter <= counter + 1;
        led_sync.send(counter[25]);  // Send to default clock domain
    endrule

    method Bit#(1) hdmi_tx_p0    = red_ser.tmds_p;
    method Bit#(1) hdmi_tx_n0    = red_ser.tmds_n;
    method Bit#(1) hdmi_tx_p1    = green_ser.tmds_p;
    method Bit#(1) hdmi_tx_n1    = green_ser.tmds_n;
    method Bit#(1) hdmi_tx_p2    = blue_ser.tmds_p;
    method Bit#(1) hdmi_tx_n2    = blue_ser.tmds_n;
    method Bit#(1) hdmi_tx_clk_p = clk_ser.tmds_p;
    method Bit#(1) hdmi_tx_clk_n = clk_ser.tmds_n;

    method Bit#(1) led0 = led_sync.read;  // DEBUG LED
    method Bit#(1) led1 = 1'b1; // DEBUG LED
    // method Bit#(1) led2 = blue_ser.tmds_p;  // DEBUG LED
    // method Bit#(1) led3 = clk_ser.tmds_p;   // DEBUG LED
endmodule

endpackage