module fpga_top (
    input  wire CLK,
    input  wire RST_N,
    output wire hdmi_tx_p0,
    output wire hdmi_tx_n0,
    output wire hdmi_tx_p1,
    output wire hdmi_tx_n1,
    output wire hdmi_tx_p2,
    output wire hdmi_tx_n2,
    output wire hdmi_tx_clk_p,
    output wire hdmi_tx_clk_n,
    output wire led0,
    output wire led1
);

wire pixel_clk;
wire tmds_clk_5x;
wire locked;
wire soc_rst_n;

wire [9:0] tmds_r;
wire [9:0] tmds_g;
wire [9:0] tmds_b;
wire hsync;
wire vsync;
wire de;

assign soc_rst_n = RST_N & locked;

clk_wiz_0 clkgen (
    .clk_out1(pixel_clk),
    .clk_out2(tmds_clk_5x),
    .reset(~RST_N),
    .locked(locked),
    .clk_in1(CLK)
);

mkSocTop soc (
    .CLK(pixel_clk),
    .RST_N(soc_rst_n),
    .tmds_r(tmds_r),
    .tmds_g(tmds_g),
    .tmds_b(tmds_b),
    .hsync(hsync),
    .vsync(vsync),
    .de(de),
    .led0(led0),
    .led1(led1)
);

tmds_serializer red_ser (
    .pixel_clk(pixel_clk),
    .tmds_data(tmds_r),
    .serial_clk(tmds_clk_5x),
    .rst(1'b0),
    .tmds_p(hdmi_tx_p0),
    .tmds_n(hdmi_tx_n0)
);

tmds_serializer green_ser (
    .pixel_clk(pixel_clk),
    .tmds_data(tmds_g),
    .serial_clk(tmds_clk_5x),
    .rst(1'b0),
    .tmds_p(hdmi_tx_p1),
    .tmds_n(hdmi_tx_n1)
);

tmds_serializer blue_ser (
    .pixel_clk(pixel_clk),
    .tmds_data(tmds_b),
    .serial_clk(tmds_clk_5x),
    .rst(1'b0),
    .tmds_p(hdmi_tx_p2),
    .tmds_n(hdmi_tx_n2)
);

tmds_serializer clk_ser (
    .pixel_clk(pixel_clk),
    .tmds_data(10'b0000011111),
    .serial_clk(tmds_clk_5x),
    .rst(1'b0),
    .tmds_p(hdmi_tx_clk_p),
    .tmds_n(hdmi_tx_clk_n)
);

ila_0 ila (
    .clk(pixel_clk),
    .probe0(tmds_r),
    .probe1(tmds_g),
    .probe2(tmds_b),
    .probe3(10'b0),
    .probe4(10'b0),
    .probe5(10'b0),
    .probe6(10'b0),
    .probe7(10'b0),
    .probe8(10'b0),
    .probe9(10'b0),
    .probe10(hsync),
    .probe11(vsync),
    .probe12(de),
    .probe13(1'b0)
);

endmodule