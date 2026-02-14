package ClkWiz;

interface ClkWiz_IFC;
    interface Clock clk_out1;
    interface Clock clk_out2;
    method Bit#(1) locked;
endinterface

import "BVI" clk_wiz_0 =
module mkClkWiz(ClkWiz_IFC);

    default_clock clk_in1(clk_in1);
    default_reset rst(reset);

    output_clock clk_out1(clk_out1);
    output_clock clk_out2(clk_out2);

    method locked locked;

endmodule

endpackage

