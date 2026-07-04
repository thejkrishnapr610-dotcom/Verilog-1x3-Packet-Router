module router_fsm(
    input clock,
    input resetn,

    input pkt_valid,
    input parity_done,
    input fifo_full,
    input low_pkt_valid,

    input fifo_empty_0,
    input fifo_empty_1,
    input fifo_empty_2,

    input soft_reset_0,
    input soft_reset_1,
    input soft_reset_2,

    input [1:0] data_in,

    output reg busy,
    output reg detect_add,
    output reg ld_state,
    output reg laf_state,
    output reg full_state,
    output reg write_enb_reg,
    output reg rst_int_reg,
    output reg lfd_state
);

parameter DECODE_ADDRESS   = 3'b000,
          LOAD_FIRST_DATA  = 3'b001,
          LOAD_DATA        = 3'b010,
          FIFO_FULL_STATE  = 3'b011,
          LOAD_AFTER_FULL  = 3'b100,
          LOAD_PARITY      = 3'b101,
          CHECK_PARITY_ERR = 3'b110,
          WAIT_TILL_EMPTY  = 3'b111;

reg [2:0] state;
reg [2:0] next_state;
reg [1:0] addr;

// Address Latch
always @(posedge clock)
begin
    if(!resetn)
        addr <= 2'b00;
    else if(detect_add && pkt_valid)
        addr <= data_in;
end

// State Register
always @(posedge clock)
begin
    if(!resetn)
        state <= DECODE_ADDRESS;
    else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
        state <= DECODE_ADDRESS;
    else
        state <= next_state;
end

// Next State Logic
always @(*)
begin
    next_state = state;

    case(state)

        DECODE_ADDRESS:
        begin
            if(pkt_valid)
            begin
                case(data_in)
                    2'b00: next_state = fifo_empty_0 ? LOAD_FIRST_DATA : WAIT_TILL_EMPTY;
                    2'b01: next_state = fifo_empty_1 ? LOAD_FIRST_DATA : WAIT_TILL_EMPTY;
                    2'b10: next_state = fifo_empty_2 ? LOAD_FIRST_DATA : WAIT_TILL_EMPTY;
                    default: next_state = DECODE_ADDRESS;
                endcase
            end
            else
                next_state = DECODE_ADDRESS;
        end

        LOAD_FIRST_DATA:
            next_state = LOAD_DATA;

        LOAD_DATA:
        begin
            if(fifo_full)
                next_state = FIFO_FULL_STATE;
            else if(!pkt_valid)
                next_state = LOAD_PARITY;
            else
                next_state = LOAD_DATA;
        end

        FIFO_FULL_STATE:
        begin
            if(!fifo_full)
                next_state = LOAD_AFTER_FULL;
            else
                next_state = FIFO_FULL_STATE;
        end

        LOAD_AFTER_FULL:
        begin
            if(parity_done)
                next_state = DECODE_ADDRESS;
            else if(low_pkt_valid)
                next_state = LOAD_PARITY;
            else
                next_state = LOAD_DATA;
        end

        LOAD_PARITY:
            next_state = CHECK_PARITY_ERR;

        CHECK_PARITY_ERR:
        begin
            if(!fifo_full)
                next_state = DECODE_ADDRESS;
            else
                next_state = FIFO_FULL_STATE;
        end

        WAIT_TILL_EMPTY:
        begin
            case(addr)
                2'b00: next_state = fifo_empty_0 ? LOAD_FIRST_DATA : WAIT_TILL_EMPTY;
                2'b01: next_state = fifo_empty_1 ? LOAD_FIRST_DATA : WAIT_TILL_EMPTY;
                2'b10: next_state = fifo_empty_2 ? LOAD_FIRST_DATA : WAIT_TILL_EMPTY;
                default: next_state = WAIT_TILL_EMPTY;
            endcase
        end

        default:
            next_state = DECODE_ADDRESS;

    endcase
end

// Output Logic
always @(*)
begin
    busy          = 1'b0;
    detect_add    = 1'b0;
    ld_state      = 1'b0;
    laf_state     = 1'b0;
    full_state    = 1'b0;
    write_enb_reg = 1'b0;
    rst_int_reg   = 1'b0;
    lfd_state     = 1'b0;

    case(state)

        DECODE_ADDRESS:
        begin
            detect_add = 1'b1;
        end

        LOAD_FIRST_DATA:
        begin
            busy = 1'b1;
            lfd_state = 1'b1;
        end

        LOAD_DATA:
        begin
            ld_state = 1'b1;
            write_enb_reg = 1'b1;
        end

        FIFO_FULL_STATE:
        begin
            busy = 1'b1;
            full_state = 1'b1;
        end

        LOAD_AFTER_FULL:
        begin
            busy = 1'b1;
            laf_state = 1'b1;
            write_enb_reg = 1'b1;
        end

        LOAD_PARITY:
        begin
            busy = 1'b1;
            write_enb_reg = 1'b1;
        end

        CHECK_PARITY_ERR:
        begin
            busy = 1'b1;
            rst_int_reg = 1'b1;
        end

        WAIT_TILL_EMPTY:
        begin
            busy = 1'b1;
        end

    endcase
end

endmodule