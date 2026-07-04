`timescale 1ns/1ps

module router_top_tb;

reg clock, resetn, pkt_valid;
reg read_enb_0, read_enb_1, read_enb_2;
reg [7:0] data_in;

wire [7:0] data_out_0, data_out_1, data_out_2;
wire valid_out_0, valid_out_1, valid_out_2;
wire error, busy;

router_top DUT (
    .clock(clock),
    .resetn(resetn),
    .pkt_valid(pkt_valid),
    .read_enb_0(read_enb_0),
    .read_enb_1(read_enb_1),
    .read_enb_2(read_enb_2),
    .data_in(data_in),
    .data_out_0(data_out_0),
    .data_out_1(data_out_1),
    .data_out_2(data_out_2),
    .valid_out_0(valid_out_0),
    .valid_out_1(valid_out_1),
    .valid_out_2(valid_out_2),
    .error(error),
    .busy(busy)
);

initial
begin
    clock = 1'b0;
    forever #5 clock = ~clock;
end

task reset_dut;
begin
    resetn = 1'b0;
    pkt_valid = 1'b0;
    read_enb_0 = 1'b0;
    read_enb_1 = 1'b0;
    read_enb_2 = 1'b0;
    data_in = 8'd0;

    #20;
    resetn = 1'b1;
end
endtask

task send_packet_0;
reg [7:0] parity;
integer i;
begin
    parity = 8'd0;

    @(negedge clock);
    pkt_valid = 1'b1;
    data_in = 8'b00010100;   // length = 5, address = 00
    parity = parity ^ data_in;

    for(i = 0; i < 5; i = i + 1)
    begin
        @(negedge clock);
        wait(!busy);
        data_in = i + 8'd10;
        parity = parity ^ data_in;
    end

    @(negedge clock);
    wait(!busy);
    pkt_valid = 1'b0;
    data_in = parity;

    @(negedge clock);
end
endtask

task read_fifo_0;
begin
    wait(valid_out_0);
    @(negedge clock);
    read_enb_0 = 1'b1;

    wait(!valid_out_0);
    @(negedge clock);
    read_enb_0 = 1'b0;
end
endtask

initial
begin
    reset_dut;

    #20;
    send_packet_0;

    #20;
    read_fifo_0;

    #100;
    $finish;
end

endmodule