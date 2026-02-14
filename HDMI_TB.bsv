// Rule to sample and decode TMDS output
    rule sample_output;
        // Feed symbols to decoders
        red_dec.feed(hdmi.tmds_r);
        green_dec.feed(hdmi.tmds_g);
        blue_dec.feed(hdmi.tmds_b);
        
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
        
        // Update statistics based on active/blanking
        if (active) begin
            active_pixels <= active_pixels + 1;
            
            // Check that we're NOT getting control codes during active video
            if (blue_dec.is_control) begin
                $display("ERROR at pixel %0d: Control code during active region!", pixel_count);
                $display("  Position: h=%0d, v=%0d", h_pos, v_pos);
            end
            
            // Optionally print some pixel values
            if (frame_count == 1 && h_pos < 10 && v_pos < 3) begin
                $display("Pixel [%0d,%0d]: R=%h G=%h B=%h", 
                    h_pos, v_pos, red_dec.data, green_dec.data, blue_dec.data);
            end
        end else begin
            blanking_pixels <= blanking_pixels + 1;
            
            // Check that we ARE getting control codes during blanking
            if (!blue_dec.is_control && !red_dec.is_control && !green_dec.is_control) begin
                $display("WARNING at pixel %0d: No control codes during blanking!", pixel_count);
                $display("  Position: h=%0d, v=%0d", h_pos, v_pos);
            end
        end
        
        // Track HSYNC width (separate if-else chain to avoid conflicts)
        if (hsync) begin
            if (!in_hsync) begin
                in_hsync <= True;
                hsync_width <= 1;
            end else begin
                hsync_width <= hsync_width + 1;
            end
        end else begin
            if (in_hsync) begin
                in_hsync <= False;
            end
        end
        
        // Track VSYNC height (separate if-else chain to avoid conflicts)
        if (vsync) begin
            if (!in_vsync) begin
                in_vsync <= True;
                if (h_pos == 0) vsync_height <= 1;
            end else begin
                if (h_pos == 0) vsync_height <= vsync_height + 1;
            end
        end else begin
            if (in_vsync) begin
                in_vsync <= False;
            end
        end
        
        // Track position (do this at the end after using current values)
        if (h_pos == expected_h_total - 1) begin
            h_pos <= 0;
            if (v_pos == expected_v_total - 1) begin
                v_pos <= 0;
                frame_count <= frame_count + 1;
                
                // Print frame statistics
                $display("=== Frame %0d Complete ===", frame_count);
                $display("  Active pixels: %0d (expected %0d)", 
                    active_pixels, expected_h_active * expected_v_active);
                $display("  Blanking pixels: %0d", blanking_pixels);
                $display("  Last HSYNC width: %0d (expected %0d)", hsync_width, expected_h_sync);
                $display("  Last VSYNC height: %0d (expected %0d)", vsync_height, expected_v_sync);
                
                // Reset statistics
                active_pixels <= 0;
                blanking_pixels <= 0;
                hsync_width <= 0;
                vsync_height <= 0;
            end else begin
                v_pos <= v_pos + 1;
            end
        end else begin
            h_cnt <= h_pos + 1;
        end
    endrule