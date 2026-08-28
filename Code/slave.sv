`default_nettype none

module slave (
    input  wire clk,
    input  wire rst_n,
    input  wire sda_s_in,
    input  wire scl_s_in,
    output reg  sda_s_out
);
    localparam [6:0] SLAVE_ADDR = 7'h20;

    typedef enum logic [2:0] {
        IDLE, ADDRESS, R_W, ACK_ADDR, RX_DATA, TX_DATA, ACK_DATA
    } state_t;

    state_t state;

    reg [2:0] sda_sync, scl_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_sync <= 3'b111;
            scl_sync <= 3'b111;
        end else begin
            sda_sync <= {sda_sync[1:0], sda_s_in};
            scl_sync <= {scl_sync[1:0], scl_s_in};
        end
    end

    wire sda_fall = (sda_sync[2:1] == 2'b10);
    wire sda_rise = (sda_sync[2:1] == 2'b01);
    wire scl_high = (scl_sync[1] == 1'b1);
    wire scl_rise = (scl_sync[2:1] == 2'b01);
    wire scl_fall = (scl_sync[2:1] == 2'b10);

    wire start_cond = sda_fall && scl_high;
    wire stop_cond  = sda_rise && scl_high;

    reg [2:0] bit_cnt;
    reg [6:0] rx_addr;
    reg       rx_rw;
    reg       addr_match;
    reg [7:0] rx_data_reg;
    reg [7:0] tx_data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            sda_s_out   <= 1'b1;
            bit_cnt     <= 3'd0;
            rx_addr     <= 7'd0;
            rx_rw       <= 1'b0;
            addr_match  <= 1'b0;
            rx_data_reg <= 8'd0;
            tx_data_reg <= 8'hCC;
        end else begin
            if (start_cond) begin
                state     <= ADDRESS;
                bit_cnt   <= 3'd6;
                sda_s_out <= 1'b1;
            end else if (stop_cond) begin
                state     <= IDLE;
                sda_s_out <= 1'b1;
            end else begin
                case (state)
                    IDLE: sda_s_out <= 1'b1;

                    ADDRESS: begin
                        if (scl_rise) begin
                            rx_addr[bit_cnt] <= sda_sync[1];
                            if (bit_cnt == 0) state <= R_W;
                            else bit_cnt <= bit_cnt - 1'b1;
                        end
                    end

                    R_W: begin
                        if (scl_rise) begin
                            rx_rw <= sda_sync[1];
                            addr_match <= (rx_addr == SLAVE_ADDR);
                            state <= ACK_ADDR;
                        end
                    end

                    ACK_ADDR: begin
                        if (scl_fall) sda_s_out <= ~addr_match;
                        if (scl_rise) begin
                            if (addr_match) begin
                                state   <= rx_rw ? TX_DATA : RX_DATA;
                                bit_cnt <= 3'd7;
                            end else state <= IDLE;
                        end
                    end

                    RX_DATA: begin
                        if (scl_fall) sda_s_out <= 1'b1;
                        if (scl_rise) begin
                            rx_data_reg[bit_cnt] <= sda_sync[1];
                            if (bit_cnt == 0) state <= ACK_DATA;
                            else bit_cnt <= bit_cnt - 1'b1;
                        end
                    end

                    TX_DATA: begin
                        if (scl_fall) sda_s_out <= tx_data_reg[bit_cnt];
                        if (scl_rise) begin
                            if (bit_cnt == 0) state <= ACK_DATA;
                            else bit_cnt <= bit_cnt - 1'b1;
                        end
                    end

                    ACK_DATA: begin
                        if (scl_fall) sda_s_out <= (rx_rw) ? 1'b1 : 1'b0;
                        if (scl_rise) state <= IDLE;
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule