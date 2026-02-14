package TMDS_Encoder;

import Vector::*;
import FIFO::*;
import RegFile::*;
import DefaultValue::*;

interface TMDS_Encoder_IFC;
    method Action encode(Bit#(8) data, Bool de, Bit#(2) ctrl);
    method Bit#(10) symbol;
    method Action clearDisparity();
endinterface

module mkTMDS_Encoder(TMDS_Encoder_IFC);

    Reg#(Int#(6)) running_disparity <- mkReg(0);
    Reg#(Bit#(10)) out_symbol <- mkReg(0);

    function Integer countOnes9(Bit#(9) d);
        Integer c = 0;
        for (Integer i = 0; i < 9; i = i + 1)
            if (d[i] == 1'b1) c = c + 1;
        return c;
    endfunction

    function Integer countOnes8(Bit#(8) d);
        Integer c = 0;
        for (Integer i = 0; i < 8; i = i + 1)
            if (d[i] == 1'b1) c = c + 1;
        return c;
    endfunction

    function Bit#(9) tmds_stage1(Bit#(8) d);
        Bit#(9) qm = 0;
        Integer ones = countOnes8(d);

        Bool use_xnor = (ones > 4) || ((ones == 4) && (d[0] == 0));

        qm[0] = d[0];
        for (Integer i = 1; i < 8; i = i + 1)
            qm[i] = use_xnor ? ~(qm[i-1] ^ d[i])
                             :  (qm[i-1] ^ d[i]);

        qm[8] = use_xnor ? 0 : 1;
        return qm;
    endfunction

    function Bit#(10) control_symbol(Bit#(2) c);
        case (c)
            2'b00: return 10'b1101010100;
            2'b01: return 10'b0010101011;
            2'b10: return 10'b0101010100;
            2'b11: return 10'b1010101011;
        endcase
    endfunction

    method Action encode(Bit#(8) data, Bool de, Bit#(2) ctrl);
        if (!de) begin
            // $display("[CTRL] ctrl=%b symbol=%b", ctrl, control_symbol(ctrl));
            out_symbol <= control_symbol(ctrl);
            running_disparity <= 0;
        end
        else begin
            let qm = tmds_stage1(data);
            Integer ones = countOnes9(qm[8:0]);
            Int#(6) qm_disp = fromInteger(ones - (8 - ones));

            Bit#(10) q_out;
            Int#(6) next_disp;

            // $display("[DATA] in=%h qm=%b qm8=%b ones=%0d qm_disp=%0d rd=%0d", data, qm, qm[8], ones, qm_disp, running_disparity);

            if (running_disparity == 0 || qm_disp == 0) begin
                q_out = {~qm[8], qm[8], qm[8] == 1'b1 ? qm[7:0] : ~qm[7:0]};
                next_disp = running_disparity + (qm[8] == 1'b1 ? qm_disp : -qm_disp);

                // $display("  BRANCH A (rd==0 || qm_disp==0)");
            end
            else if ((running_disparity > 0 && qm_disp > 0) || (running_disparity < 0 && qm_disp < 0)) begin
                q_out = {1'b1, ~qm[8], ~qm[7:0]};
                next_disp = running_disparity - qm_disp;

                // $display("  BRANCH B (same sign)");
            end
            else begin
                q_out = {1'b0, qm[8], qm[7:0]};
                next_disp = running_disparity + qm_disp;

                // $display("  BRANCH C (opposite sign)");
            end

            // $display("  OUT=%b next_rd=%0d", q_out, next_disp);

            out_symbol <= q_out;
            running_disparity <= next_disp;
        end
    endmethod

    method Bit#(10) symbol = out_symbol;

    method Action clearDisparity();
        running_disparity <= 0;
    endmethod

endmodule

endpackage