package tb_tmds;

import TMDS_Encoder::*;
import Vector::*;

module mktb_tmds(Empty);

    TMDS_Encoder_IFC enc <- mkTMDS_Encoder;
    Reg#(UInt#(5)) step <- mkReg(0);

    rule tb (step < 20);
        case (step)
            0: begin
                $display("---- TMDS ENCODER TEST ----");
                enc.encode(8'h00, False, 2'b00);
            end
            1: $display("CTRL 00 -> %b", enc.symbol);

            2: enc.encode(8'h00, False, 2'b01);
            3: $display("CTRL 01 -> %b", enc.symbol);

            4: enc.encode(8'h00, False, 2'b10);
            5: $display("CTRL 10 -> %b", enc.symbol);

            6: enc.encode(8'h00, False, 2'b11);
            7: $display("CTRL 11 -> %b", enc.symbol);

            8: enc.encode(8'h00, True, 2'b00);
            9: enc.clearDisparity();
            10: $display("DATA 00 -> %b", enc.symbol);

            11: enc.encode(8'hFF, True, 2'b00);
            12: enc.clearDisparity();
            13: $display("DATA FF -> %b", enc.symbol);

            14: enc.encode(8'h55, True, 2'b00);
            15: enc.clearDisparity();
            16: $display("DATA 55 -> %b", enc.symbol);

            17: enc.encode(8'hAB, True, 2'b00);
            18: enc.clearDisparity();
            19: $display("DATA AA -> %b", enc.symbol);

            20: enc.encode(8'h0F, True, 2'b00);
            21: enc.clearDisparity();
            22: $display("DATA 0F -> %b", enc.symbol);

            23: enc.encode(8'hF0, True, 2'b00);
            24: enc.clearDisparity();
            25: begin
                $display("DATA F0 -> %b", enc.symbol);
                $display("DONE");
                $finish;
            end
        endcase

        step <= step + 1;
    endrule

endmodule

endpackage

