// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_encoding_top
    import h14tx_pkg::period_t;
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::ctl_t;
    import h14tx_pkg::data_t;
    import h14tx_pkg::video_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
    import h14tx_pkg::DataIslandActive;
    import h14tx_pkg::DataIslandPreamble;
    import h14tx_pkg::DataIslandGuard;
#(
    parameter integer Chan = 0
) (
    input logic clk,
    input logic rst_n,

    input ctl_t   ctl /*synthesis syn_keep=1*/,
    input data_t  data /*synthesis syn_keep=1*/,
    input video_t video /*synthesis syn_keep=1*/,

    input period_t period /*synthesis syn_keep=1*/,

    output symbol_t symbol /*synthesis syn_keep=1*/
);

    symbol_t ctl_s, data_s, video_s, guard_s /*synthesis syn_keep=1*/;

    h14tx_encoding_ctl u_ctl_enc (
        .ctl(ctl),
        .symbol(ctl_s)
    );

    h14tx_encoding_terc4 u_terc4_enc (
        .data  (data),
        .symbol(data_s)
    );

    h14tx_encoding_tmds u_tmds_enc (
        .clk(clk),
        .rst_n(rst_n),
        .active_n(period !== VideoActive),
        .video(video),
        .symbol(video_s)
    );

    h14tx_encoding_guard #(Chan) u_gaurd_enc (
        .guard_switch(period == DataIslandGuard),
        .bypass_symbol(data_s),
        .symbol(guard_s)
    );

    always_comb begin
        case (period)
            VideoGuard: symbol = guard_s;
            DataIslandGuard: symbol = guard_s;
            VideoActive: symbol = video_s;
            DataIslandActive: symbol = data_s;
            default: symbol = ctl_s;
        endcase
    end

endmodule : h14tx_encoding_top
