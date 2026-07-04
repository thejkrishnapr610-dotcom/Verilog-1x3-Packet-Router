module router_reg(
    input clock,
    input resetn,
    input pkt_valid,
    input [7:0] data_in,

    input fifo_full,
    input rst_int_reg,
    input detect_add,
    input ld_state,
    input laf_state,
    input full_state,
    input lfd_state,

    output reg parity_done,
    output reg low_pkt_valid,
    output reg err,
    output reg [7:0] dout
);

reg [7:0] header_byte;
reg [7:0] fifo_full_state_byte;
reg [7:0] internal_parity;
reg [7:0] packet_parity;

always @(posedge clock or negedge resetn)
begin
    if(!resetn)
    begin
        dout                <= 8'd0;
        header_byte         <= 8'd0;
        fifo_full_state_byte<= 8'd0;
        internal_parity     <= 8'd0;
        packet_parity       <= 8'd0;
        parity_done         <= 1'b0;
        low_pkt_valid       <= 1'b0;
        err                 <= 1'b0;
    end
    else
    begin

        if(rst_int_reg)
            low_pkt_valid <= 1'b0;

        if(detect_add)
            parity_done <= 1'b0;

        // Header capture
        if(detect_add && pkt_valid)
            header_byte <= data_in;

        // Header to output
        if(lfd_state)
            dout <= header_byte;

        // Payload loading
        else if(ld_state && !fifo_full)
            dout <= data_in;

        // FIFO full condition
        else if(ld_state && fifo_full)
            fifo_full_state_byte <= data_in;

        // Load after full
        else if(laf_state)
            dout <= fifo_full_state_byte;

        // low_pkt_valid generation
        if(ld_state && !pkt_valid)
            low_pkt_valid <= 1'b1;

        // Internal parity calculation
        if(detect_add)
            internal_parity <= 8'd0;

        else if(lfd_state)
            internal_parity <= internal_parity ^ header_byte;

        else if(ld_state && pkt_valid && !fifo_full)
            internal_parity <= internal_parity ^ data_in;

        else if(full_state)
            internal_parity <= internal_parity ^ fifo_full_state_byte;

        // Packet parity capture
        if(ld_state && !pkt_valid && !fifo_full)
        begin
            packet_parity <= data_in;
            parity_done   <= 1'b1;
        end

        if(laf_state && low_pkt_valid && !parity_done)
        begin
            packet_parity <= fifo_full_state_byte;
            parity_done   <= 1'b1;
        end

        // Error generation
        if(parity_done)
            err <= (packet_parity != internal_parity);
    end
end

endmodule
