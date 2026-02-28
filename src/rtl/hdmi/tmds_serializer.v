module tmds_serializer (
    input  wire        pixel_clk,
    input  wire        serial_clk,
    input  wire        rst,
    input  wire [9:0]  tmds_data,
    output wire        tmds_p,
    output wire        tmds_n
);
    wire shift1;
    wire shift2;
    wire serial_bit;
    
    // MASTER
    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("BUF"),        // Changed from "SDR" to "BUF"
        .DATA_WIDTH(10),
        .SERDES_MODE("MASTER"),
        .TRISTATE_WIDTH(1)
    ) master (
        .OQ(serial_bit),
        .OFB(),
        .TQ(),
        .TFB(),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .TBYTEOUT(),
        
        .SHIFTIN1(shift1),
        .SHIFTIN2(shift2),
        
        .CLK(serial_clk),
        .CLKDIV(pixel_clk),
        .RST(rst),
        
        .D1(tmds_data[0]),
        .D2(tmds_data[1]),
        .D3(tmds_data[2]),
        .D4(tmds_data[3]),
        .D5(tmds_data[4]),
        .D6(tmds_data[5]),
        .D7(tmds_data[6]),
        .D8(tmds_data[7]),
        
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        
        .TBYTEIN(1'b0),
        .TCE(1'b0),
        .OCE(1'b1)
    );
    
    // SLAVE
    (* DONT_TOUCH = "TRUE" *)
    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("BUF"),        // Changed from "SDR" to "BUF"
        .DATA_WIDTH(10),
        .SERDES_MODE("SLAVE"),
        .TRISTATE_WIDTH(1)
    ) slave (
        .OQ(),
        .OFB(),
        .TQ(),
        .TFB(),
        .SHIFTOUT1(shift1),
        .SHIFTOUT2(shift2),
        .TBYTEOUT(),
        
        .SHIFTIN1(),
        .SHIFTIN2(),
        
        .CLK(serial_clk),
        .CLKDIV(pixel_clk),
        .RST(rst),
        
        .D1(1'b0),
        .D2(1'b0),
        .D3(tmds_data[8]),
        .D4(tmds_data[9]),
        .D5(1'b0),
        .D6(1'b0),
        .D7(1'b0),
        .D8(1'b0),
        
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        
        .TBYTEIN(1'b0),
        .TCE(1'b0),
        .OCE(1'b1)
    );
    
    // Differential buffer
    OBUFDS #(
        .IOSTANDARD("TMDS_33")
    ) obufds_inst (
        .I(serial_bit),
        .O(tmds_p),
        .OB(tmds_n)
    );

endmodule
