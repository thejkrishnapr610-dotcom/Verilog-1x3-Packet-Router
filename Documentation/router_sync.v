module router_sync(
    input detect_add,
    input [1:0] data_in,
    input write_enb_reg,
    input clk,
    input rst_n,

    input read_enb_0,
    input read_enb_1,
    input read_enb_2,

    input empty_0,
    input empty_1,
    input empty_2,

    input full_0,
    input full_1,
    input full_2,

    output soft_reset_0,
    output soft_reset_1,
    output soft_reset_2,

    output vld_out_0,
    output vld_out_1,
    output vld_out_2,

    output reg fifo_full,
    output reg [2:0] write_enb
);

reg [1:0] temp_reg;
reg [4:0] count_0, count_1, count_2;

assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

assign soft_reset_0 = (count_0 == 5'd30);
assign soft_reset_1 = (count_1 == 5'd30);
assign soft_reset_2 = (count_2 == 5'd30);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        temp_reg <= 2'b00;
    else if(detect_add)
        temp_reg <= data_in;
end

always @(*)
begin
    case(temp_reg)
        2'b00: fifo_full = full_0;
        2'b01: fifo_full = full_1;
        2'b10: fifo_full = full_2;
        default: fifo_full = 1'b0;
    endcase
end

always @(*)
begin
    if(write_enb_reg)
    begin
        case(temp_reg)
            2'b00: write_enb = 3'b001;
            2'b01: write_enb = 3'b010;
            2'b10: write_enb = 3'b100;
            default: write_enb = 3'b000;
        endcase
    end
    else
        write_enb = 3'b000;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        count_0 <= 5'd0;
    else if(!vld_out_0)
        count_0 <= 5'd0;
    else if(read_enb_0)
        count_0 <= 5'd0;
    else if(count_0 == 5'd30)
        count_0 <= 5'd0;
    else
        count_0 <= count_0 + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        count_1 <= 5'd0;
    else if(!vld_out_1)
        count_1 <= 5'd0;
    else if(read_enb_1)
        count_1 <= 5'd0;
    else if(count_1 == 5'd30)
        count_1 <= 5'd0;
    else
        count_1 <= count_1 + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        count_2 <= 5'd0;
    else if(!vld_out_2)
        count_2 <= 5'd0;
    else if(read_enb_2)
        count_2 <= 5'd0;
    else if(count_2 == 5'd30)
        count_2 <= 5'd0;
    else
        count_2 <= count_2 + 1'b1;
end

endmodule