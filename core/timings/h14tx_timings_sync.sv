// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_timings_sync #(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter logic [BitWidth-1:0] HSyncStart = BitWidth'(1280 + 110),
    parameter logic [BitWidth-1:0] HSyncEnd = BitWidth'(1280 + 110 + 40),
    parameter logic [BitHeight-1:0] VSyncStart = BitHeight'(720 + 5),
    parameter logic [BitHeight-1:0] VSyncEnd = BitHeight'(720 + 5 + 5)
) (
    input logic clk,
    input logic rst_n,

    input logic [ BitWidth-1:0] x,
    input logic [BitHeight-1:0] y,

    output logic hsync,
    output logic vsync
);

    logic hs, vs;

    always_comb begin
        hs = x >= HSyncStart && x < HSyncEnd;

        if (y == VSyncStart) begin
            vs = x >= HSyncStart;
        end else if (y == VSyncEnd - BitHeight'(1)) begin
            vs = x < HSyncStart;
        end else begin
            vs = y >= VSyncStart && y < VSyncEnd;
        end
    end

    `FF(hsync, hs, 1'b0)
    `FF(vsync, vs, 1'b0)

endmodule : h14tx_timings_sync

