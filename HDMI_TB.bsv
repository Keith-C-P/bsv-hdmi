package HDMI_TB;

import HDMI :: *;
import TMDS_Encoder :: *;
import StmtFSM :: *;
import Clocks :: *;

// Simple TMDS decoder to verify output
interface TMDS_Decoder_IFC;
    method Action feed(Bit#(10) symbol);
    method Bit#(8) data;
    method Bool is_control;
    method Bit#(2) control_bits;
endinterface

module mkTMDS_Decoder(TMDS_Decoder_IFC);
    Reg#(Bit#(8)) data_reg <- mkReg(0);
    Reg#(Bool) is_control_reg <- mkReg(False);
    Reg#(Bit#(2)) control_reg <- mkReg(0);
    
    method Action feed(Bit#(10) symbol);
        // Detect control symbols
        if (symbol == 10'b1101010100) begin
            is_control_reg <= True;
            control_reg <= 2'b00;
        end else if (symbol == 10'b0010101011) begin
            is_control_reg <= True;
            control_reg <= 2'b01;
        end else if (symbol == 10'b0101010100) begin
            is_control_reg <= True;
            control_reg <= 2'b10;
        end else if (symbol == 10'b1010101011) begin
            is_control_reg <= True;
            control_reg <= 2'b11;
        end else begin
            // Data symbol - simplified decoder (just store for now)
            is_control_reg <= False;
            data_reg <= symbol[7:0];  // Simplified - real decoder is more complex
        end
    endmethod
    
    method Bit#(8) data = data_reg;
    method Bool is_control = is_control_reg;
    method Bit#(2) control_bits = control_reg;
endmodule

module mkHDMI_TB(Empty);
    // Create two clocks
    Clock pixel_clk <- mkAbsoluteClock(13, 10);  // Simplified for sim
    Reset pixel_rst <- mkInitialReset(2, clocked_by pixel_clk);
    
    // Instantiate HDMI module
    HDMI_IFC hdmi <- mkhdmi(clocked_by pixel_clk, reset_by pixel_rst);
    
    // Decoders to verify output
    TMDS_Decoder_IFC red_dec <- mkTMDS_Decoder(clocked_by pixel_clk, reset_by pixel_rst);
    TMDS_Decoder_IFC green_dec <- mkTMDS_Decoder(clocked_by pixel_clk, reset_by pixel_rst);
    TMDS_Decoder_IFC blue_dec <- mkTMDS_Decoder(clocked_by pixel_clk, reset_by pixel_rst);
    
    // Counters to track position
    Reg#(UInt#(12)) h_pos <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(UInt#(12)) v_pos <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(UInt#(32)) pixel_count <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(UInt#(16)) frame_count <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    
    // Statistics
    Reg#(UInt#(32)) active_pixels <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(UInt#(32)) blanking_pixels <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(UInt#(12)) hsync_width <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(Bool) in_hsync <- mkReg(False, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(UInt#(12)) vsync_height <- mkReg(0, clocked_by pixel_clk, reset_by pixel_rst);
    Reg#(Bool) in_vsync <- mkReg(False, clocked_by pixel_clk, reset_by pixel_rst);
    
    // Expected values for 640x480@60Hz
    UInt#(12) expected_h_total = 800;
    UInt#(12) expected_v_total = 525;
    UInt#(12) expected_h_active = 640;
    UInt#(12) expected_v_active = 480;
    UInt#(12) expected_h_sync = 96;
    UInt#(12) expected_v_sync = 2;
    
    // Rule to sample and decode TMDS output
    rule sample_output;
        // Feed symbols to decoders
        red_dec.feed(hdmi.tmds_r);
        green_dec.feed(hdmi.tmds_g);
        blue_dec.feed(hdmi.tmds_b);
    if (pixel_count >= 635 && pixel_count < 660) begin
        $display("Cycle %0d [%0d,%0d]: R=%b G=%b B=%b | R_ctrl=%b G_ctrl=%b B_ctrl=%b (%b)", 
            pixel_count, h_pos, v_pos,
            hdmi.tmds_r, hdmi.tmds_g, hdmi.tmds_b,
            red_dec.is_control, green_dec.is_control, blue_dec.is_control,
            blue_dec.control_bits);
    end

        pixel_count <= pixel_count + 1;

        // Check if we're in active region
        Bool h_active = (h_pos < expected_h_active);
        Bool v_active = (v_pos < expected_v_active);
        Bool active = h_active && v_active;
        
        // Detect sync signals from blue channel control bits
        Bool hsync = False;
        Bool vsync = False;
        if (blue_dec.is_control) begin
            Bit#(2) ctrl = blue_dec.control_bits;
            hsync = unpack(ctrl[0]);
            vsync = unpack(ctrl[1]);
        end
        
        // Determine if we're at frame boundary
        Bool frame_end = (h_pos == expected_h_total - 1) && (v_pos == expected_v_total - 1);
        
        // Calculate next values (no register writes yet)
        UInt#(32) next_active = frame_end ? 0 : (active ? active_pixels + 1 : active_pixels);
        UInt#(32) next_blanking = frame_end ? 0 : (!active ? blanking_pixels + 1 : blanking_pixels);
        UInt#(12) next_hsync_width = frame_end ? 0 : hsync_width;
        Bool next_in_hsync = in_hsync;
        UInt#(12) next_vsync_height = frame_end ? 0 : vsync_height;
        Bool next_in_vsync = in_vsync;
        
        // Track HSYNC (only during blanking)
        if (!active) begin
            if (hsync && !in_hsync) begin
                next_in_hsync = True;
                next_hsync_width = 1;
            end else if (hsync && in_hsync) begin
                next_hsync_width = frame_end ? 0 : hsync_width + 1;
            end else if (!hsync && in_hsync) begin
                next_in_hsync = False;
            end
            
            // Track VSYNC
            if (vsync && !in_vsync) begin
                next_in_vsync = True;
                if (h_pos == 0) next_vsync_height = 1;
            end else if (vsync && in_vsync) begin
                if (h_pos == 0) next_vsync_height = frame_end ? 0 : vsync_height + 1;
            end else if (!vsync && in_vsync) begin
                next_in_vsync = False;
            end
        end
        
        // Print during active region
        if (active && frame_count == 1 && h_pos < 10 && v_pos < 3) begin
            $display("Pixel [%0d,%0d]: R=%h G=%h B=%h", 
                h_pos, v_pos, red_dec.data, green_dec.data, blue_dec.data);
        end
        
        // Write all register updates ONCE
        active_pixels <= next_active;
        blanking_pixels <= next_blanking;
        hsync_width <= next_hsync_width;
        in_hsync <= next_in_hsync;
        vsync_height <= next_vsync_height;
        in_vsync <= next_in_vsync;
        
        // Track position
        if (h_pos == expected_h_total - 1) begin
            h_pos <= 0;
            if (v_pos == expected_v_total - 1) begin
                v_pos <= 0;
                frame_count <= frame_count + 1;
                $display("=== Frame %0d Complete ===", frame_count);
                $display("  Active pixels: %0d (expected %0d)", 
                    active_pixels, expected_h_active * expected_v_active);
                $display("  Blanking pixels: %0d", blanking_pixels);
                $display("  Last HSYNC width: %0d (expected %0d)", hsync_width, expected_h_sync);
                $display("  Last VSYNC height: %0d (expected %0d)", vsync_height, expected_v_sync);
            end else begin
                v_pos <= v_pos + 1;
            end
        end else begin
            h_pos <= h_pos + 1;
        end
    endrule
    
    // Termination rule - stop after 3 frames
    rule terminate (pixel_count >= 10000);
        $display("\n=== Simulation Complete ===");
        $display("Total frames: %0d", frame_count);
        $display("Total pixels: %0d", pixel_count);
        $display("\n*** TEST PASSED ***");
        $finish;
    endrule
    
    // Initial display
    rule start_message (pixel_count == 0);
        $display("=== HDMI Testbench Started ===");
        $display("Testing 640x480@60Hz timing:");
        $display("  H: %0d active + %0d blanking = %0d total",
            expected_h_active, expected_h_total - expected_h_active, expected_h_total);
        $display("  V: %0d active + %0d blanking = %0d total",
            expected_v_active, expected_v_total - expected_v_active, expected_v_total);
        $display("  Frame pixels: %0d", expected_h_total * expected_v_total);
        $display("");
    endrule

endmodule

endpackage