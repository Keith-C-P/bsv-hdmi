package HDMI;

import TMDS_Encoder::*;
import Vector::*;
import ClkWiz::*;

typedef struct {
    UInt#(12) h_active;
    UInt#(12) h_fp;
    UInt#(12) h_sync;
    UInt#(12) h_bp;
    UInt#(12) h_total;
    UInt#(12) v_active;
    UInt#(12) v_fp;
    UInt#(12) v_sync;
    UInt#(12) v_bp;
    UInt#(12) v_total;
} VideoTiming deriving (Bits, Eq);

typedef enum {
    MODE_640x480_60,
    MODE_720p_60,
    MODE_1080p_60
} VideoMode deriving (Bits, Eq);

interface HDMI_IFC;
    method Bit#(10) tmds_r;
    method Bit#(10) tmds_g;
    method Bit#(10) tmds_b;
endinterface

module mkhdmi(HDMI_IFC);
    TMDS_Encoder_IFC tmdsR <- mkTMDS_Encoder;
    TMDS_Encoder_IFC tmdsG <- mkTMDS_Encoder;
    TMDS_Encoder_IFC tmdsB <- mkTMDS_Encoder;

    Reg#(Bit#(8)) r <- mkReg(255);
    Reg#(Bit#(8)) g <- mkReg(0);
    Reg#(Bit#(8)) b <- mkReg(0);
    Reg#(UInt#(12)) h_cnt <- mkReg(0);
    Reg#(UInt#(12)) v_cnt <- mkReg(0);

    function VideoTiming timingFor(VideoMode m);
        case (m)
            MODE_640x480_60:
                return VideoTiming {
                    h_active: 640, h_fp: 16, h_sync: 96, h_bp: 48, h_total:800 ,
                    v_active: 480, v_fp: 10, v_sync: 2,  v_bp: 33, v_total: 525
                };
            MODE_720p_60:
                return VideoTiming {
                    h_active: 1280, h_fp: 110, h_sync: 40, h_bp: 220, h_total: 1650,
                    v_active: 720,  v_fp: 5,   v_sync: 5,  v_bp: 20,  v_total: 750
                };
            MODE_1080p_60:
                return VideoTiming {
                    h_active: 1920, h_fp: 88, h_sync: 44, h_bp: 148, h_total: 2200,
                    v_active: 1080, v_fp: 4,  v_sync: 5,  v_bp: 36,  v_total: 1125
                };
        endcase
    endfunction

    Reg#(VideoTiming) timing <- mkReg(timingFor(MODE_640x480_60));
    
    // Combine both rules into one to avoid scheduling issues
    rule generate_pixel;
       // Calculate sync signals and blanking (these are evaluated every cycle)
        Bool h_active = (h_cnt < unpack(pack(timing.h_active)));
        Bool v_active = (v_cnt < unpack(pack(timing.v_active)));
        Bool active = h_active && v_active;
        UInt#(12) h_sync_start = unpack(pack(timing.h_active)) + unpack(pack(timing.h_fp));
        UInt#(12) h_sync_end = h_sync_start + unpack(pack(timing.h_sync));
        Bool hsync = (h_cnt >= h_sync_start) && (h_cnt < h_sync_end);
        UInt#(12) v_sync_start = unpack(pack(timing.v_active)) + unpack(pack(timing.v_fp));
        UInt#(12) v_sync_end = v_sync_start + unpack(pack(timing.v_sync));
        Bool vsync = (v_cnt >= v_sync_start) && (v_cnt < v_sync_end);
       
       // Update counters
        if (h_cnt == timing.h_total - 1) begin
            h_cnt <= 0;
            if (v_cnt == timing.v_total - 1) begin
                v_cnt <= 0;
            end else begin
                v_cnt <= v_cnt + 1;
            end
        end else begin
            h_cnt <= h_cnt + 1;
        end
        // Send data to encoders
        if (active) begin
            tmdsR.encode(r, True, 2'b00);
            tmdsG.encode(g, True, 2'b00);
            tmdsB.encode(b, True, 2'b00);
        end else begin
            tmdsR.encode(8'b0, False, 2'b00);
            tmdsG.encode(8'b0, False, 2'b00);
            tmdsB.encode(8'b0, False, {pack(vsync), pack(hsync)});
        end
    endrule
    method Bit#(10) tmds_r = tmdsR.symbol;
    method Bit#(10) tmds_g = tmdsG.symbol;
    method Bit#(10) tmds_b = tmdsB.symbol;
endmodule

endpackage
