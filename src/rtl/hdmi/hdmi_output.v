module hdmi_output (
    input wire clk_p,
    input wire clk_n,
    input wire data0_p,
    input wire data0_n,
    input wire data1_p,
    input wire data1_n,
    input wire data2_p,
    input wire data2_n,
    
    output wire hdmi_tx_clk_p,
    output wire hdmi_tx_clk_n,
    output wire hdmi_tx_p0,
    output wire hdmi_tx_n0,
    output wire hdmi_tx_p1,
    output wire hdmi_tx_n1,
    output wire hdmi_tx_p2,
    output wire hdmi_tx_n2
);

    OBUFDS clk_buf (
        .I(clk_p),
        .O(hdmi_tx_clk_p),
        .OB(hdmi_tx_clk_n)
    );

    OBUFDS data0_buf (
        .I(data0_p),
        .O(hdmi_tx_p0),
        .OB(hdmi_tx_n0)
    );

    OBUFDS data1_buf (
        .I(data1_p),
        .O(hdmi_tx_p1),
        .OB(hdmi_tx_n1)
    );

    OBUFDS data2_buf (
        .I(data2_p),
        .O(hdmi_tx_p2),
        .OB(hdmi_tx_n2)
    );

endmodule