`timescale 1ns / 1ps

module router_top(
    input clock, resetn,
    input read_enb_0, read_enb_1, read_enb_2,
    input [7:0] data_in,
    input pkt_valid,

    output [7:0] data_out_0, data_out_1, data_out_2,
    output valid_out_0, valid_out_1, valid_out_2,
    output error, busy
);

    wire [2:0] write_enb;
    wire [7:0] dout;

    wire soft_reset_0, soft_reset_1, soft_reset_2;
    wire fifo_empty_0, fifo_empty_1, fifo_empty_2;
    wire fifo_full_0, fifo_full_1, fifo_full_2;
    wire fifo_full;
    wire low_pkt_valid, parity_done;
    wire detect_add, ld_state, laf_state, full_state, lfd_state;
    wire write_enb_reg, rst_int_reg;

    router_fsm FSM(
        .clock(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .low_pkt_valid(low_pkt_valid),
        .parity_done(parity_done),
        .data_in(data_in[1:0]),
        .soft_reset_0(soft_reset_0),
        .soft_reset_1(soft_reset_1),
        .soft_reset_2(soft_reset_2),
        .fifo_full(fifo_full),
        .fifo_empty_0(fifo_empty_0),
        .fifo_empty_1(fifo_empty_1),
        .fifo_empty_2(fifo_empty_2),
        .busy(busy),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .write_enb_reg(write_enb_reg),
        .rst_int_reg(rst_int_reg)
    );

    router_sync Synchronizer(
        .clk(clock),
        .rst_n(resetn),
        .detect_add(detect_add),
        .data_in(data_in[1:0]),
        .write_enb_reg(write_enb_reg),
        .read_enb_0(read_enb_0),
        .read_enb_1(read_enb_1),
        .read_enb_2(read_enb_2),
        .empty_0(fifo_empty_0),
        .empty_1(fifo_empty_1),
        .empty_2(fifo_empty_2),
        .full_0(fifo_full_0),
        .full_1(fifo_full_1),
        .full_2(fifo_full_2),
        .write_enb(write_enb),
        .fifo_full(fifo_full),
        .vld_out_0(valid_out_0),
        .vld_out_1(valid_out_1),
        .vld_out_2(valid_out_2),
        .soft_reset_0(soft_reset_0),
        .soft_reset_1(soft_reset_1),
        .soft_reset_2(soft_reset_2)
    );

    router_reg Register(
        .clock(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .data_in(data_in),
        .fifo_full(fifo_full),
        .rst_int_reg(rst_int_reg),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .parity_done(parity_done),
        .low_pkt_valid(low_pkt_valid),
        .err(error),
        .dout(dout)
    );

    router_fifo FIFO_0(
        .clk(clock),
        .rst_n(resetn),
        .write_enb(write_enb[0]),
        .soft_reset(soft_reset_0),
        .read_enb(read_enb_0),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(fifo_empty_0),
        .data_out(data_out_0),
        .full(fifo_full_0)
    );

    router_fifo FIFO_1(
        .clk(clock),
        .rst_n(resetn),
        .write_enb(write_enb[1]),
        .soft_reset(soft_reset_1),
        .read_enb(read_enb_1),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(fifo_empty_1),
        .data_out(data_out_1),
        .full(fifo_full_1)
    );

    router_fifo FIFO_2(
        .clk(clock),
        .rst_n(resetn),
        .write_enb(write_enb[2]),
        .soft_reset(soft_reset_2),
        .read_enb(read_enb_2),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(fifo_empty_2),
        .data_out(data_out_2),
        .full(fifo_full_2)
    );

endmodule
