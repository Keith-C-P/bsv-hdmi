package TMDS_Serializer;

interface TMDS_Serializer_IFC;
    (* always_ready *)
    method Bit#(1) tmds_p;
    (* always_ready *)
    method Bit#(1) tmds_n;
endinterface

import "BVI" tmds_serializer =
module mkTMDS_Serializer
   #( Clock pixel_clk
    , Clock serial_clk
    , Bit#(1) rst
    , Bit#(10) tmds_data
    )
   (TMDS_Serializer_IFC);

    default_reset no_reset;

    input_clock pixel_clk (pixel_clk) = pixel_clk;
    input_clock serial_clk (serial_clk) = serial_clk;

    default_clock pixel_clk;

    port rst       = rst;
    port tmds_data = tmds_data;

    method tmds_p tmds_p
        clocked_by(no_clock)
        reset_by(no_reset);
    
    method tmds_n tmds_n
        clocked_by(no_clock)
        reset_by(no_reset);

    schedule tmds_p CF tmds_p;
    schedule tmds_n CF tmds_n;
    schedule tmds_p CF tmds_n;

endmodule

endpackage
