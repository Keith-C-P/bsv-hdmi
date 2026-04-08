package soc_top;

import HDMI :: *;

interface SocTop_IFC;
    method Bit#(10) tmds_r;
    method Bit#(10) tmds_g;
    method Bit#(10) tmds_b;

    method Bit#(1) hsync;
    method Bit#(1) vsync;
    method Bit#(1) de;

    method Bit#(1) led0;
    method Bit#(1) led1;
endinterface

(* synthesize *)
module mkSocTop(SocTop_IFC);

    HDMI_IFC hdmi <- mkhdmi;

    Reg#(Bit#(32)) counter <- mkReg(0);

    rule debug;
        counter <= counter + 1;
    endrule

    method Bit#(10) tmds_r = hdmi.tmds_r;
    method Bit#(10) tmds_g = hdmi.tmds_g;
    method Bit#(10) tmds_b = hdmi.tmds_b;

    method Bit#(1) hsync = hdmi.hsync;
    method Bit#(1) vsync = hdmi.vsync;
    method Bit#(1) de = hdmi.de;

    method Bit#(1) led0 = counter[25];
    method Bit#(1) led1 = 1'b1;
endmodule

endpackage