`default_nettype none

module Master #(parameter Width = 8) (
    input  wire               CLK,       // 200kHz clock
    input  wire               rst_n,
    input  wire               Start,
    input  wire  [6:0]        Slave_Addr,
    input  wire               Read_Write,
    input  wire  [Width-1:0]  Data_In,
    input  wire               SDA_IN,
    
    output reg   [Width-1:0]  Data_Out,
    output reg                Busy,
    output reg                Done,
    output reg                Ack_Error,
    output reg                SDA_Out,
    output reg                SCL_Out
);
    typedef enum logic [3:0] {
        IDLE, START, SEND_ADDR, SEND_RW, ACK_ADDR,
        SEND_DATA, RECV_DATA, ACK_DATA, STOP, DONE_ST
    } state_t;

    state_t state;
    reg [3:0] bit_cnt;
    reg phase; // 0 = SCL Low (Write Data), 1 = SCL High (Read Data)

    always @(posedge CLK or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            SCL_Out   <= 1'b1;
            SDA_Out   <= 1'b1;
            Done      <= 1'b0;
            Busy      <= 1'b0;
            Ack_Error <= 1'b0;
            Data_Out  <= 0;
            bit_cnt   <= 0;
            phase     <= 0;
        end else begin
            case (state)
                IDLE: begin
                    SCL_Out <= 1'b1;
                    SDA_Out <= 1'b1;
                    Done    <= 1'b0;
                    phase   <= 0;
                    if (Start) begin
                        Busy      <= 1'b1;
                        Ack_Error <= 1'b0;
                        state     <= START;
                    end else begin
                        Busy <= 1'b0;
                    end
                end 

                START: begin
                    if (phase == 0) begin
                        SDA_Out <= 1'b0; // SDA falls while SCL is high
                        phase   <= 1;
                    end else begin
                        SCL_Out   <= 1'b0; // SCL falls
                        bit_cnt   <= 4'd6;
                        phase     <= 0;
                        state     <= SEND_ADDR;
                    end
                end

                SEND_ADDR: begin
                    if (phase == 0) begin
                        SDA_Out <= Slave_Addr[bit_cnt];
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out <= 1'b1;
                        phase   <= 0;
                        if (bit_cnt == 0) state <= SEND_RW;
                        else bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                SEND_RW: begin
                    if (phase == 0) begin
                        SDA_Out <= Read_Write;
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out <= 1'b1;
                        phase   <= 0;
                        state   <= ACK_ADDR;
                    end
                end

                ACK_ADDR: begin
                    if (phase == 0) begin
                        SDA_Out <= 1'b1; // Release SDA
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out   <= 1'b1;
                        Ack_Error <= SDA_IN; // Read ACK
                        phase     <= 0;
                        if (SDA_IN) state <= STOP; // If NACK, abort
                        else begin
                            bit_cnt <= 4'd7;
                            state   <= (Read_Write) ? RECV_DATA : SEND_DATA;
                        end
                    end
                end

                SEND_DATA: begin
                    if (phase == 0) begin
                        SDA_Out <= Data_In[bit_cnt];
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out <= 1'b1;
                        phase   <= 0;
                        if (bit_cnt == 0) state <= ACK_DATA;
                        else bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                RECV_DATA: begin
                    if (phase == 0) begin
                        SDA_Out <= 1'b1; // Release SDA
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out <= 1'b1;
                        Data_Out[bit_cnt] <= SDA_IN;
                        phase   <= 0;
                        if (bit_cnt == 0) state <= ACK_DATA;
                        else bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                ACK_DATA: begin
                    if (phase == 0) begin
                        SDA_Out <= (Read_Write) ? 1'b0 : 1'b1; // Master ACKs reads, releases writes
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out <= 1'b1;
                        if (!Read_Write) Ack_Error <= SDA_IN;
                        phase   <= 0;
                        state   <= STOP;
                    end
                end

                STOP: begin
                    if (phase == 0) begin
                        SDA_Out <= 1'b0;
                        SCL_Out <= 1'b0;
                        phase   <= 1;
                    end else begin
                        SCL_Out <= 1'b1;
                        phase   <= 0;
                        state   <= DONE_ST;
                    end
                end

                DONE_ST: begin
                    SDA_Out <= 1'b1; // SDA rises while SCL is high (Stop Condition)
                    Done    <= 1'b1;
                    Busy    <= 1'b0;
                    state   <= IDLE;
                end
            endcase
        end
    end
endmodule