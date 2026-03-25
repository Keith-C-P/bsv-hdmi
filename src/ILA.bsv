package ILA;

interface ILA_IFC;
    // 10-bit probes
    method Action probe0_10(Bit#(10) data);
    method Action probe1_10(Bit#(10) data);
    method Action probe2_10(Bit#(10) data);
    method Action probe3_10(Bit#(10) data);
    method Action probe4_10(Bit#(10) data);
    
    // 8-bit probes
    method Action probe5_8(Bit#(8) data);
    method Action probe6_8(Bit#(8) data);
    method Action probe7_8(Bit#(8) data);
    method Action probe8_8(Bit#(8) data);
    method Action probe9_8(Bit#(8) data);
    
    // 1-bit probes
    method Action probe10_1(Bit#(1) data);
    method Action probe11_1(Bit#(1) data);
    method Action probe12_1(Bit#(1) data);
    method Action probe13_1(Bit#(1) data);
endinterface

import "BVI" ila_0 =
module mkILA(ILA_IFC);
    default_clock clk(clk);
    default_reset no_reset;
    
    method probe0_10(probe0) enable((*inhigh*) EN0);
    method probe1_10(probe1) enable((*inhigh*) EN1);
    method probe2_10(probe2) enable((*inhigh*) EN2);
    method probe3_10(probe3) enable((*inhigh*) EN3);
    method probe4_10(probe4) enable((*inhigh*) EN4);
    
    method probe5_8(probe5) enable((*inhigh*) EN5);
    method probe6_8(probe6) enable((*inhigh*) EN6);
    method probe7_8(probe7) enable((*inhigh*) EN7);
    method probe8_8(probe8) enable((*inhigh*) EN8);
    method probe9_8(probe9) enable((*inhigh*) EN9);
    
    method probe10_1(probe10) enable((*inhigh*) EN10);
    method probe11_1(probe11) enable((*inhigh*) EN11);
    method probe12_1(probe12) enable((*inhigh*) EN12);
    method probe13_1(probe13) enable((*inhigh*) EN13);
    
    schedule (probe0_10, probe1_10, probe2_10, probe3_10, probe4_10,
              probe5_8, probe6_8, probe7_8, probe8_8, probe9_8,
              probe10_1, probe11_1, probe12_1, probe13_1) CF
             (probe0_10, probe1_10, probe2_10, probe3_10, probe4_10,
              probe5_8, probe6_8, probe7_8, probe8_8, probe9_8,
              probe10_1, probe11_1, probe12_1, probe13_1);
endmodule

endpackage
