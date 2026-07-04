module router_fifo(
    input clk,
    input rst_n,
    input soft_reset,
    input write_enb,
    input read_enb,
    input lfd_state,
    input [7:0] data_in,

    output reg [7:0] data_out,
    output empty,
    output full
);

reg [8:0] mem [0:15];
reg [4:0] wr_ptr;
reg [4:0] rd_ptr;
reg [6:0] count;

integer i;

assign empty = (wr_ptr == rd_ptr);
assign full  = (wr_ptr == {~rd_ptr[4], rd_ptr[3:0]});

always @(posedge clk)
begin
    if(!rst_n)
    begin
        wr_ptr <= 5'd0;
        for(i=0;i<16;i=i+1)
            mem[i] <= 9'd0;
    end
    else if(soft_reset)
    begin
        wr_ptr <= 5'd0;
        for(i=0;i<16;i=i+1)
            mem[i] <= 9'd0;
    end
    else if(write_enb && !full)
    begin
        mem[wr_ptr[3:0]] <= {lfd_state,data_in};
        wr_ptr <= wr_ptr + 1'b1;
    end
end

always @(posedge clk)
begin
    if(!rst_n)
    begin
        rd_ptr   <= 5'd0;
        data_out <= 8'd0;
        count    <= 7'd0;
    end
    else if(soft_reset)
    begin
        rd_ptr   <= 5'd0;
        data_out <= 8'bz;
        count    <= 7'd0;
    end
    else if(read_enb && !empty)
    begin
        data_out <= mem[rd_ptr[3:0]][7:0];
        rd_ptr   <= rd_ptr + 1'b1;

        if(mem[rd_ptr[3:0]][8])
            count <= mem[rd_ptr[3:0]][7:2] + 1'b1; // payload length + parity
        else if(count != 0)
            count <= count - 1'b1;
    end
    else if(empty)
    begin
        data_out <= 8'bz;
    end
end

endmodule
