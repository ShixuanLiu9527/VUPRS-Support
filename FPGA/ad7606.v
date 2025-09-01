/**
 * Author: Shixuan Liu
 * Date:   2025-8
 */

module ad7606 
#(
/* --------------------------------------------- Parameters ---------------------------------------------- */

parameter USR_SYSTEM_CLOCK_CYCLE = 20,       /* unit: ns, system frequency cycle (50 MHz -> 20 ns) */
          TIMEOUT_CYCLE          = 2000,     /* unit: ns, total timeout threshold */
          BUSY_MAX_CYCLE         = 200,      /* unit: ns, BUSY timeout threshold */
          FIRST_DATA_MAX_CYCLE   = 200,      /* unit: ns, FIRST_DATA timeout threshold */
          T_RESET_CYCLE          = 50,       /* unit: ns, t_reset of AD7606 (refer to data sheet) */
          T1_CYCLE               = 40,       /* unit: ns, t1 of AD7606 (refer to data sheet) */
          T2_CYCLE               = 25,       /* unit: ns, t2 of AD7606 (refer to data sheet) */
          T10_CYCLE              = 25,       /* unit: ns, t10 of AD7606 (refer to data sheet) */
          T11_CYCLE              = 15,       /* unit: ns, t11 of AD7606 (refer to data sheet) */
          T14_CYCLE              = 25        /* unit: ns, t14 of AD7606 (refer to data sheet) */
)
(
    /* ------------------------------------------------ User interface ------------------------------------------------ */

    input wire         usr_trigger,                   /* Sample Enable, rising edge trigger */
    input wire         usr_clk,                       /* 50 MHz System Clock */
    input wire         usr_rst,                       /* Reset the module */

    output reg [15: 0] usr_channel1,
    output reg [15: 0] usr_channel2,
    output reg [15: 0] usr_channel3,
    output reg [15: 0] usr_channel4,
    output reg [15: 0] usr_channel5,
    output reg [15: 0] usr_channel6,
    output reg [15: 0] usr_channel7,
    output reg [15: 0] usr_channel8,

    output reg         usr_complete,                  /* output enable, determine whether the hw_data have been read to output */
    output reg         usr_error,                     /* read usr_error */
    output reg         usr_sampling,                  /* sampling, do not trigger */

    /* --------------------------------------------- Hardware interface ---------------------------------------------- */

    input wire         hw_busy,                       /* BUSY Pin of the AD7606 chip */
    input wire         hw_first_data,                 /* FIRSTDATA Pin of the AD7606 chip  */
    input wire [15: 0] hw_data,                       /* D0 - D15 Pins of the AD7606 chip */

    output reg         hw_convst,                     /* CONVRST_A and CONVRST_B are connect together on the board */
    output reg         hw_rd,                         /* RD Pin of the AD7606 chip */
    output reg         hw_cs,                         /* CS# Pin of the AD7606 chip */
    output reg         hw_range,                      /* Range select of the AD7606 chip */
    output reg [2: 0]  hw_os,                         /* OS0, OS1, OS2 Pins of the AD7606 */
    output reg         hw_mode_select,                /* PAR#/SER/BYTE_SEL Pin of the AD7606 chip */
    output reg         hw_reset,                      /* reset the AD7606 chip */
    output reg         hw_stby_n                      /* STBY# Pin of AD7606 */
);

/* --------------------------------------------- Local Parameters ----------------------------------------- */

localparam TIMEOUT_CLOCKS = TIMEOUT_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,
           T_RESET_CLOCKS = T_RESET_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,
           T1_CLOCKS      = T1_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,       /* BUSY to high after CONVST to high */
           T2_CLOCKS      = T2_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,       /* minium CONVST low pulse */
           T10_CLOCKS     = T10_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,      /* Low time of RD# */
           T11_CLOCKS     = T11_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,      /* High time of RD# */
           T14_CLOCKS     = T14_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2;      /* read hw_data after negative edge of RD# */

localparam FIRST_DATA_WAIT_CLOCKS = FIRST_DATA_MAX_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,
           BUSY_WAIT_CLOCKS       = BUSY_MAX_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2;

localparam TIMER_ENABLE          = 1'b1,
           TIMER_DISABLE         = 1'b0;

localparam RESET_TIMER           = 8'b0,
           RESET_TIMEOUT_TIMER   = 32'b0;

localparam HIGH                  = 1'b1,
           LOW                   = 1'b0;

localparam STATE_WAIT_FOR_USR_SAMPLE_EN         = 3'd0, 
           STATE_CREATE_CONVST_PULSE            = 3'd1,
           STATE_WAIT_BUSY_HIGH                 = 3'd2,
           STATE_WAIT_CONVERT_COMPLETE          = 3'd3,
           STATE_READ_CHANNELS                  = 3'd4,
           STATE_MEASURE_COMPLETE               = 3'd5;

localparam SUB_STATE_CREATE_RD_HIGH             = 3'd0,
           SUB_STATE_WAIT_DATA_READY            = 3'd1,
           SUB_STATE_READ_DATA                  = 3'd2,
           SUB_STATE_INTERVAL                   = 3'd3;

localparam RESET_STATE_CREATE_RESET_PULSE       = 2'd0,
           RESET_STATE_WAIT_RESET_HIGH          = 2'd1,
           RESET_STATE_CREATE_COMPLETE          = 2'd2;

reg [2: 0] usr_trigger_sync_list;
reg [1: 0] hw_busy_sync_list;
reg [1: 0] hw_first_data_sync_list;

reg [2: 0] system_state;
reg [2: 0] system_sub_state;
reg [1: 0] reset_state;

reg [7: 0] timer;
reg [7: 0] reset_timer;
reg [31: 0] timeout_timer;

reg [3: 0] current_channel;

reg timer_en;
reg reset_timer_en;
reg timeout_timer_en;

reg error_occurred;

wire posedge_trigger = usr_trigger_sync_list[1] && ~usr_trigger_sync_list[2];

/* -------------------------------------- Detect usr_trigger ------------------------------------------ */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        usr_trigger_sync_list <= 3'b0;
    end else begin
        usr_trigger_sync_list <= {usr_trigger_sync_list[1: 0], usr_trigger};
    end
end

/* ------------------------------------------- Detect hw_busy ------------------------------------------- */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        hw_busy_sync_list <= 2'b0;
    end else begin
        hw_busy_sync_list[1] <= hw_busy_sync_list[0];
        hw_busy_sync_list[0] <= hw_busy;
    end
end

/* -------------------------------------- Detect hw_first_data ------------------------------------------ */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        hw_first_data_sync_list <= 2'b0;
    end else begin
        hw_first_data_sync_list[1] <= hw_first_data_sync_list[0];
        hw_first_data_sync_list[0] <= hw_first_data;
    end
end

/* ----------------------------------------- Triger The Sequence ---------------------------------------  */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin

        usr_channel1 <= 16'b0;
        usr_channel2 <= 16'b0;
        usr_channel3 <= 16'b0;
        usr_channel4 <= 16'b0;
        usr_channel5 <= 16'b0;
        usr_channel6 <= 16'b0;
        usr_channel7 <= 16'b0;
        usr_channel8 <= 16'b0;

        usr_complete <= 1'b0;
        usr_error <= 1'b0;
        usr_sampling <= 1'b0;

        /* Hardware pins */

        hw_convst <= HIGH;                   /* CONVRST_A and CONVRST_B are connect together on the board */
        hw_rd <= HIGH;                       /* RD# Pin of the AD7606 chip */
        hw_cs <= HIGH;                       /* CS# Pin of the AD7606 chip */
        hw_range <= HIGH;                    /* Range select of the AD7606 chip */
        hw_os <= 3'b0;                       /* OS0, OS1, OS2 Pins of the AD7606 */
        hw_mode_select <= LOW;              /* PAR#/SER/BYTE_SEL Pin of the AD7606 chip */
        hw_reset <= LOW;                    /* reset the AD7606 chip */
        hw_stby_n <= HIGH;                   /* STBY# Pin of AD7606 */

        /* State flags */

        system_state <= STATE_WAIT_FOR_USR_SAMPLE_EN;
        system_sub_state <= SUB_STATE_CREATE_RD_HIGH;
        reset_state <= RESET_STATE_CREATE_RESET_PULSE;

        /* other signal */

        current_channel <= 4'b0;
        error_occurred <= 1'b0;

    end else begin
        case (system_state)

            STATE_WAIT_FOR_USR_SAMPLE_EN: begin
                if (posedge_trigger && reset_state == RESET_STATE_CREATE_COMPLETE) begin

                    /* Timer */

                    timer <= RESET_TIMER;
                    timer_en <= TIMER_ENABLE;

                    /* Timeout Timer */

                    timeout_timer <= RESET_TIMEOUT_TIMER;
                    timeout_timer_en <= TIMER_ENABLE;

                    hw_cs <= LOW;
                    hw_convst <= LOW;

                    usr_complete <= 1'b0;
                    usr_error <= 1'b0;
                    usr_sampling <= 1'b1;

                    error_occurred <= 1'b0;

                    system_state <= STATE_CREATE_CONVST_PULSE;
                end
            end

            STATE_CREATE_CONVST_PULSE: begin
                if (timer >= T2_CLOCKS) begin
                    hw_convst <= HIGH;

                    timer <= RESET_TIMER;
                    timer_en <= TIMER_ENABLE;

                    system_state <= STATE_WAIT_BUSY_HIGH;
                end
            end

            STATE_WAIT_BUSY_HIGH: begin
                if (timer >= T1_CLOCKS) begin

                    timer <= RESET_TIMER;
                    timer_en <= TIMER_ENABLE;

                    system_state <= STATE_WAIT_CONVERT_COMPLETE;
                end
            end

            STATE_WAIT_CONVERT_COMPLETE: begin
                if (!hw_busy_sync_list[1]) begin

                    /* Normal, read the data */

                    system_state <= STATE_READ_CHANNELS;
                    system_sub_state <= SUB_STATE_CREATE_RD_HIGH;

                    hw_rd <= HIGH;

                    timer <= RESET_TIMER;
                    timer_en <= TIMER_ENABLE;

                    current_channel <= 4'd0;

                end else begin
                
                    /* Error, try again */

                    if (timer >= BUSY_WAIT_CLOCKS) begin
                        error_occurred <= 1'b1;
                    end

                end
            end

            /* STATE_READ_CHANNELS deal */

            STATE_MEASURE_COMPLETE: begin

                usr_complete <= 1'b1;
                usr_sampling <= 1'b0;
                usr_error <= 1'b0;

                system_state <= STATE_WAIT_FOR_USR_SAMPLE_EN;

                hw_cs <= HIGH;

                timer <= RESET_TIMER;
                timer_en <= TIMER_DISABLE;
                
                timeout_timer <= RESET_TIMEOUT_TIMER;
                timeout_timer_en <= TIMER_DISABLE;
            end

            default: system_state <= STATE_WAIT_FOR_USR_SAMPLE_EN;
        endcase
    end
end

/* --------------------------------------------- Read Channels ------------------------------------------- */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        system_sub_state <= SUB_STATE_CREATE_RD_HIGH;
        current_channel <= 1'b0;
    end else begin
        if (system_state == STATE_READ_CHANNELS) begin
            case (system_sub_state)

                SUB_STATE_CREATE_RD_HIGH: begin
                    if (timer >= T11_CLOCKS) begin

                        timer <= RESET_TIMER;
                        timer_en <= TIMER_ENABLE;

                        hw_rd <= LOW;
                        system_sub_state <= SUB_STATE_WAIT_DATA_READY;
                    end
                end

                SUB_STATE_WAIT_DATA_READY: begin
                    if (timer >= T14_CLOCKS) begin

                        timer <= RESET_TIMER;
                        timer_en <= TIMER_ENABLE;

                        system_sub_state <= SUB_STATE_READ_DATA;
                    end
                end

                SUB_STATE_READ_DATA: begin
                    if (current_channel == 4'b0) begin
                        if (hw_first_data_sync_list[1] == 1'b1) begin
                            
                            /* Normal, FIRST_DATA is High */

                            usr_channel1 <= hw_data;   /* read channel V1 */

                            current_channel <= current_channel + 1;

                            timer <= RESET_TIMER;
                            timer_en <= TIMER_ENABLE;

                            system_sub_state <= SUB_STATE_INTERVAL;

                        end else if (timer >= FIRST_DATA_WAIT_CLOCKS) begin

                            /* Error */

                            error_occurred <= 1'b1;
                        end
                    end else begin

                        case (current_channel)
                            4'd1: usr_channel2 <= hw_data;
                            4'd2: usr_channel3 <= hw_data;
                            4'd3: usr_channel4 <= hw_data;
                            4'd4: usr_channel5 <= hw_data;
                            4'd5: usr_channel6 <= hw_data;
                            4'd6: usr_channel7 <= hw_data;
                            4'd7: usr_channel8 <= hw_data;
                            default: system_sub_state <= SUB_STATE_INTERVAL;
                        endcase

                        current_channel <= current_channel + 1;

                        timer <= RESET_TIMER;
                        timer_en <= TIMER_ENABLE;

                        system_sub_state <= SUB_STATE_INTERVAL;
                    end
                end

                SUB_STATE_INTERVAL: begin
                    if (timer >= T10_CLOCKS) begin

                        timer <= RESET_TIMER;
                        timer_en <= TIMER_ENABLE;

                        hw_rd <= HIGH;

                        if (current_channel >= 4'd8) begin

                            timer <= RESET_TIMER;
                            timer_en <= TIMER_DISABLE;

                            system_sub_state <= SUB_STATE_CREATE_RD_HIGH;
                            system_state <= STATE_MEASURE_COMPLETE;

                        end else begin

                            system_sub_state <= SUB_STATE_CREATE_RD_HIGH;

                        end
                    end
                end
                default: system_sub_state <= SUB_STATE_CREATE_RD_HIGH;
            endcase
        end
    end
end

/* ---------------------------------------------- Reset Pulse ------------------------------------------- */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        reset_state <= RESET_STATE_CREATE_RESET_PULSE;
    end else begin
        if (reset_state == RESET_STATE_CREATE_RESET_PULSE) begin

            reset_timer <= RESET_TIMER;
            reset_timer_en <= TIMER_ENABLE;

            hw_reset <= 1'b1;
            reset_state <= RESET_STATE_WAIT_RESET_HIGH;

        end else if (reset_state == RESET_STATE_WAIT_RESET_HIGH) begin
            if (reset_timer >= T_RESET_CLOCKS) begin

                reset_timer <= RESET_TIMER;
                reset_timer_en <= TIMER_DISABLE;

                hw_reset <= 1'b0;
                reset_state <= RESET_STATE_CREATE_COMPLETE;
            end
        end else begin
            reset_timer <= RESET_TIMER;
            reset_timer_en <= TIMER_DISABLE;

            hw_reset <= 1'b0;
            reset_state <= RESET_STATE_CREATE_COMPLETE;
        end
    end
end

/* ---------------------------------------------- Timer ------------------------------------------------- */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        timer <= RESET_TIMER;
        timer_en <= TIMER_DISABLE;
    end else begin
        if (timer_en) begin
            timer <= timer + 1;
        end else begin
            timer <= RESET_TIMER;
        end
    end
end

/* ------------------------------------------ Reset Timer ----------------------------------------------- */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        reset_timer <= RESET_TIMER;
        reset_timer_en <= TIMER_DISABLE;
    end else begin
        if (reset_timer_en) begin
            reset_timer <= reset_timer + 1;
        end else begin
            reset_timer <= RESET_TIMER;
        end
    end
end

/* ---------------------------------------------- Timeout ----------------------------------------------- */

always @(posedge usr_clk or negedge usr_rst) begin
    if (!usr_rst) begin
        timeout_timer <= RESET_TIMEOUT_TIMER;
        timeout_timer_en <= TIMER_DISABLE;
    end else begin
        if (timeout_timer_en) begin
            timeout_timer <= timeout_timer + 1;
        end else begin
            timeout_timer <= RESET_TIMEOUT_TIMER;
        end

        if (timeout_timer >= TIMEOUT_CLOCKS || error_occurred) begin
            system_state <= STATE_WAIT_FOR_USR_SAMPLE_EN;
            system_sub_state <= SUB_STATE_CREATE_RD_HIGH;

            timeout_timer <= RESET_TIMEOUT_TIMER;
            timeout_timer_en <= TIMER_DISABLE;

            timer <= RESET_TIMER;
            timer_en <= TIMER_DISABLE;

            current_channel <= 4'b0;
           
            usr_complete <= 1'b1;
            usr_error <= 1'b1;
            usr_sampling <= 1'b0;

            error_occurred <= 1'b0;
        end
    end
end

endmodule
