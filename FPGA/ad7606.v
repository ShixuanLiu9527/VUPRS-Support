/**
 * Author: Shixuan Liu
 * Date:   2025-8
 * Note:   1. Before performing any operation, it must be reset (apply a falling edge pulse to usr_rst);
 *         2. After resetting, apply a rising edge to usr_trigger to enable sampling.
 *            If usr_sampling is high, do not trigger sampling!
 *         3. If usr_complete becomes high, it means the sampling is complete;
 *         4. If usr_error becomes high, it means some error occurred in sampling process;
 */

module ad7606 
#(
/* --------------------------------------------- Parameters ---------------------------------------------- */

parameter USR_SYSTEM_CLOCK_CYCLE = 20,       /* unit: ns, system frequency cycle (50 MHz -> 20 ns) */
          TIMEOUT_CYCLE          = 20000,     /* unit: ns, total timeout threshold */
          BUSY_MAX_CYCLE         = 5000,      /* unit: ns, BUSY timeout threshold */
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

    input wire         usr_trigger,                   /* Sample Enable, rising edge trigger USR_SYSTEM_CLOCK_CYCLE */
    input wire         usr_clk,                       /* System Clock, corresponding to  */
    input wire         usr_rst,                       /* Reset this module, falling edge trigger */

    output reg [15: 0] usr_channel1,                  /* Data of channel V1, 16 bit */
    output reg [15: 0] usr_channel2,                  /* Data of channel V2, 16 bit */
    output reg [15: 0] usr_channel3,                  /* Data of channel V3, 16 bit */
    output reg [15: 0] usr_channel4,                  /* Data of channel V4, 16 bit */
    output reg [15: 0] usr_channel5,                  /* Data of channel V5, 16 bit */
    output reg [15: 0] usr_channel6,                  /* Data of channel V6, 16 bit */
    output reg [15: 0] usr_channel7,                  /* Data of channel V7, 16 bit */
    output reg [15: 0] usr_channel8,                  /* Data of channel V8, 16 bit */

    output reg         usr_complete,                  /* Read complete, 1 = in reading; 0 = complete reading */
    output reg         usr_error,                     /* Error flag, 1 = error occurred; 0 = normal */
    output reg         usr_sampling,                  /* sampling, 1 = in sampling, do not trigger; 0 = is idle */
    output reg         usr_reset_down,                /* Reset is down (complete to create a HIGH pulse for RESET pin) */

    /* --------------------------------------------- Hardware interface ---------------------------------------------- */

    input wire         hw_busy,                       /* BUSY pin of the AD7606 chip */
    input wire         hw_first_data,                 /* FIRSTDATA pin of the AD7606 chip  */
    input wire [15: 0] hw_data,                       /* D0 - D15 Pins of the AD7606 chip */

    output reg         hw_convst,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    output reg         hw_rd,                         /* RD# pin of the AD7606 chip */
    output reg         hw_cs,                         /* CS# pin of the AD7606 chip */
    output reg         hw_range,                      /* RANGE pin of the AD7606 chip */
    output reg [2: 0]  hw_os,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    output reg         hw_mode_select,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    output reg         hw_reset,                      /* RESET pin of the AD7606 chip */
    output reg         hw_stby_n                      /* STBY# pin of the AD7606 */
);

/* --------------------------------------------- Local Parameters ----------------------------------------- */

/* chip parameters, all refer to data-sheet */

localparam TIMEOUT_CLOCKS = TIMEOUT_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,
           T_RESET_CLOCKS = T_RESET_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,
           T1_CLOCKS      = T1_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,       /* BUSY to high after CONVST to high */
           T2_CLOCKS      = T2_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,       /* minium CONVST low pulse */
           T10_CLOCKS     = T10_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,      /* Low time of RD# */
           T11_CLOCKS     = T11_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,      /* High time of RD# */
           T14_CLOCKS     = T14_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2;      /* read hw_data after negative edge of RD# */

/* timeout parameters */

localparam FIRST_DATA_WAIT_CLOCKS = FIRST_DATA_MAX_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2,
           BUSY_WAIT_CLOCKS       = BUSY_MAX_CYCLE / USR_SYSTEM_CLOCK_CYCLE + 2;

/* timer working status */

localparam TIMER_ENABLE                              = 1'b1,
           TIMER_DISABLE                             = 1'b0;

/* timer reset values */

localparam RESET_TIMER                               = 8'b0,
           RESET_TIMEOUT_TIMER                       = 32'b0;

/* Logic parameters for hardware pins */

localparam HIGH                                      = 1'b1,
           LOW                                       = 1'b0;

/* Logic parameters for signals */

localparam TRUE                                      = 1'b1,
           FALSE                                     = 1'b0;

/* system state choice */

localparam STATE_WAIT_FOR_USR_SAMPLE_TRIGGER         = 3'd0, 
           STATE_CREATE_CONVST_PULSE                 = 3'd1,
           STATE_WAIT_BUSY_HIGH                      = 3'd2,
           STATE_WAIT_CONVERT_COMPLETE               = 3'd3,
           STATE_READ_CHANNELS                       = 3'd4,
           STATE_MEASURE_COMPLETE                    = 3'd5;

/* system sub state choice */

localparam SUB_STATE_CREATE_RD_HIGH_PULSE            = 3'd0,
           SUB_STATE_WAIT_DATA_READY                 = 3'd1,
           SUB_STATE_READ_DATA                       = 3'd2,
           SUB_STATE_RD_LOW_PULSE_INTERVAL           = 3'd3;

/* system reset state choice */

localparam RESET_STATE_CREATE_RESET_PULSE            = 2'd0,
           RESET_STATE_WAIT_RESET_HIGH               = 2'd1,
           RESET_STATE_CREATE_COMPLETE               = 2'd2;

/* sync registers */

reg [2: 0] usr_trigger_sync_list;
reg [1: 0] hw_busy_sync_list;
reg [1: 0] hw_first_data_sync_list;

/* state flags */

reg [2: 0] system_state;
reg [2: 0] system_sub_state;
reg [1: 0] reset_state;

/* timer counters */

reg [7: 0] running_timer;
reg [7: 0] reset_timer;
reg [31: 0] timeout_timer;

/* channel reading pointer */

reg [3: 0] current_channel;

/* timer power control flag */

reg running_timer_en;
reg reset_timer_en;
reg timeout_timer_en;

reg running_timer_reset;
reg running_timer_need_reset;

reg reset_timer_reset;
reg reset_timer_need_reset;

reg timeout_timer_reset;
reg timeout_timer_need_reset;

reg error_occurred_condition_1, error_occurred_condition_2, error_occurred_condition_3, error_occurred_condition_4, error_occurred_condition_5;

reg one_state_trigger_occur;
reg one_reset_state_trigger_occur;

wire posedge_trigger = usr_trigger_sync_list[1] && ~usr_trigger_sync_list[2];

`define ERROR_OCCURRED (error_occurred_condition_1 || error_occurred_condition_2 || error_occurred_condition_3 || error_occurred_condition_4 || error_occurred_condition_5)

/* -------------------------------------------------- Key registers --------------------------------------------- */



/* -------------------------------------- Detect usr_trigger (posedge) ------------------------------------------ */

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        usr_trigger_sync_list <= 3'b0;
    end else begin
        usr_trigger_sync_list <= {usr_trigger_sync_list[1: 0], usr_trigger};
    end
end

/* ------------------------------------------- Detect hw_busy ------------------------------------------- */

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        hw_busy_sync_list <= 2'b0;
    end else begin
        hw_busy_sync_list[1] <= hw_busy_sync_list[0];
        hw_busy_sync_list[0] <= hw_busy;
    end
end

/* -------------------------------------- Detect hw_first_data ------------------------------------------ */

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        hw_first_data_sync_list <= 2'b0;
    end else begin
        hw_first_data_sync_list[1] <= hw_first_data_sync_list[0];
        hw_first_data_sync_list[0] <= hw_first_data;
    end
end

/* ----------------------------------------- Triger The Sequence ---------------------------------------  */

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin

        current_channel <= 4'd0;

        /* reset output channels */

        usr_channel1 <= 16'b0;
        usr_channel2 <= 16'b0;
        usr_channel3 <= 16'b0;
        usr_channel4 <= 16'b0;
        usr_channel5 <= 16'b0;
        usr_channel6 <= 16'b0;
        usr_channel7 <= 16'b0;
        usr_channel8 <= 16'b0;

        /* reset output state flags */

        usr_complete <= FALSE;
        usr_sampling <= FALSE;

        if (`ERROR_OCCURRED) begin
            usr_error <= TRUE;
            error_occurred_condition_1 <= FALSE;
            error_occurred_condition_2 <= FALSE;
            error_occurred_condition_3 <= FALSE;
            error_occurred_condition_4 <= FALSE;
        end
        else begin
            usr_error <= FALSE;
        end

        /* reset hardware pins */

        hw_convst <= HIGH;                   /* CONVRST_A and CONVRST_B are connect together on the board */
        hw_rd <= HIGH;                       /* RD# pin of the AD7606 chip */
        hw_cs <= HIGH;                       /* CS# pin of the AD7606 chip */
        hw_range <= HIGH;                    /* Range select of the AD7606 chip */
        hw_os <= {LOW, LOW, LOW};            /* OS0, OS1, OS2 Pins of the AD7606 */
        hw_mode_select <= LOW;               /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
        hw_stby_n <= HIGH;                   /* STBY# pin of AD7606 */

        /* state flags */

        system_state <= STATE_WAIT_FOR_USR_SAMPLE_TRIGGER;
        system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE;

        one_state_trigger_occur <= FALSE;

        running_timer_need_reset <= TRUE;
        timeout_timer_need_reset <= TRUE;

        running_timer_en <= TIMER_DISABLE;
        timeout_timer_en <= TIMER_DISABLE;

    end else begin
        case (system_state)

            STATE_WAIT_FOR_USR_SAMPLE_TRIGGER: begin
                if (posedge_trigger && reset_state == RESET_STATE_CREATE_COMPLETE && !one_state_trigger_occur) begin
                    one_state_trigger_occur = TRUE;
                end
                if (one_state_trigger_occur) begin

                    if (!running_timer_is_in_reset || !timeout_timer_is_in_reset) begin
                        running_timer_need_reset <= TRUE;
                        timeout_timer_need_reset <= TRUE;
                    end
                    else begin
                        running_timer_need_reset <= FALSE;
                        timeout_timer_need_reset <= FALSE;

                        one_state_trigger_occur <= FALSE;

                        /* [running timer]: reset & start up */

                        running_timer_en <= TIMER_ENABLE;

                        /* [timeout timer]: reset & start up */

                        timeout_timer_en <= TIMER_ENABLE;

                        /* hardware setting */

                        hw_cs <= LOW;      // CS# to LOW
                        hw_convst <= LOW;  // set CONVST to LOW to make a LOW pulse

                        /* output flags setting */

                        usr_complete <= 1'b0;
                        usr_error <= 1'b0;
                        usr_sampling <= 1'b1;

                        system_state <= STATE_CREATE_CONVST_PULSE;
                    end

                end
            end

            /* 
             * ... ...
             * create a LOW pulse of CONVST
             * ... ...
             */

            STATE_CREATE_CONVST_PULSE: begin
                if (running_timer >= T2_CLOCKS && !one_state_trigger_occur) begin
                    one_state_trigger_occur <= TRUE;
                end
                if (one_state_trigger_occur) begin
                  
                    if (!running_timer_is_in_reset) begin
                        running_timer_need_reset <= TRUE;
                    end
                    else begin

                        running_timer_need_reset <= FALSE;
                        one_state_trigger_occur <= FALSE;

                        /* hardware setting */

                        hw_convst <= HIGH;   // set CONVST to HIGH, complete to create a LOW pulse

                        /* [running timer]: start up */

                        running_timer_en <= TIMER_ENABLE;

                        system_state <= STATE_WAIT_BUSY_HIGH;
                    end

                end
            end

            /* 
             * ... ...
             * make a delay, wait BUSY to HIGH
             * ... ...
             */

            STATE_WAIT_BUSY_HIGH: begin
                if (running_timer >= T1_CLOCKS && !one_state_trigger_occur) begin
                    one_state_trigger_occur <= TRUE;
                end
                if (one_state_trigger_occur) begin

                    if (!running_timer_is_in_reset) begin
                        running_timer_need_reset <= TRUE;
                    end
                    else begin

                        running_timer_need_reset <= FALSE;
                        one_state_trigger_occur <= FALSE;

                        /* [running timer]: reset & start up */

                        running_timer_en <= TIMER_ENABLE;

                        system_state <= STATE_WAIT_CONVERT_COMPLETE;
                    end
                end
            end

            /* 
             * ... ...
             * wait convert complete (BUSY to LOW)
             * ... ...
             */

            STATE_WAIT_CONVERT_COMPLETE: begin
                if (hw_busy_sync_list[1] == LOW && !one_state_trigger_occur) begin
                    one_state_trigger_occur <= TRUE;
                end
                if (one_state_trigger_occur) begin

                    if (!running_timer_is_in_reset) begin
                        running_timer_need_reset <= TRUE;
                    end
                    else begin

                        running_timer_need_reset <= FALSE;
                        one_state_trigger_occur <= FALSE;

                        /* read the data in the AD7606 chip, jump to sub-state */

                        system_state <= STATE_READ_CHANNELS;
                        system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE;

                        /* hardware setting */

                        hw_rd <= HIGH;  // RD# to HIGH

                        /* [running timer]: reset & start up */

                        running_timer_en <= TIMER_ENABLE;

                        /* channel pointer to channel-1 */

                        current_channel <= 4'd0;
                    end

                end 
                else begin
                
                    /* Error, BUSY is always HIGH */

                    if (running_timer >= BUSY_WAIT_CLOCKS && !(!usr_rst || `ERROR_OCCURRED)) begin
                        error_occurred_condition_1 <= TRUE;
                    end

                end
            end

            /*
             * ... ...
             * read all channels (RD# is HIGH)
             * ... ...
             */

            STATE_READ_CHANNELS: begin
                case (system_sub_state)

                    /*
                     * ... ...
                     * RD# is high
                     * ... ...
                     */

                    SUB_STATE_CREATE_RD_HIGH_PULSE: begin
                        if (running_timer >= T11_CLOCKS && !one_state_trigger_occur) begin
                            one_state_trigger_occur <= TRUE;
                        end
                        if (one_state_trigger_occur) begin

                            if (!running_timer_is_in_reset) begin
                                running_timer_need_reset <= TRUE;
                            end
                            else begin

                                running_timer_need_reset <= FALSE;
                                one_state_trigger_occur <= FALSE;

                                /* [running timer]: reset & start up */

                                running_timer_en <= TIMER_ENABLE;

                                /* hardware setting, RD# to LOW */

                                hw_rd <= LOW;

                                system_sub_state <= SUB_STATE_WAIT_DATA_READY;
                            end
                        end
                    end

                    /*
                     * ... ...
                     * waiting for data ready (make a delay)
                     * ... ...
                     */

                    SUB_STATE_WAIT_DATA_READY: begin
                        if (running_timer >= T14_CLOCKS && !one_state_trigger_occur) begin
                            one_state_trigger_occur <= TRUE;
                        end
                        if (one_state_trigger_occur) begin

                            if (!running_timer_is_in_reset) begin
                                running_timer_need_reset <= TRUE;
                            end
                            else begin

                                running_timer_need_reset <= FALSE;
                                one_state_trigger_occur <= FALSE;

                                /* [running timer]: reset & start up */

                                running_timer_en <= TIMER_ENABLE;

                                system_sub_state <= SUB_STATE_READ_DATA;
                            end
                        end
                    end

                    SUB_STATE_READ_DATA: begin
                        if (current_channel == 4'b0) begin
                            if (hw_first_data_sync_list[1] == HIGH && !one_state_trigger_occur) begin
                                one_state_trigger_occur <= TRUE;
                            end
                            if (one_state_trigger_occur) begin

                                if (!running_timer_is_in_reset) begin
                                    running_timer_need_reset <= TRUE;
                                end
                                else begin

                                    running_timer_need_reset <= FALSE;
                                    one_state_trigger_occur <= FALSE;
                                    /* FIRST_DATA is High, read channel-1 */

                                    usr_channel1 <= hw_data;

                                    /* channel pointer to channel-2 */

                                    current_channel <= current_channel + 1;

                                    /* [running timer]: reset & start up */

                                    running_timer_en <= TIMER_ENABLE;

                                    system_sub_state <= SUB_STATE_RD_LOW_PULSE_INTERVAL;

                                end
                            end

                            else begin

                                /* error, FIRST_DATA is LOW and timeout */

                                if (running_timer >= FIRST_DATA_WAIT_CLOCKS  && !(!usr_rst || `ERROR_OCCURRED)) begin
                                    error_occurred_condition_2 <= TRUE;
                                end

                            end
                        end 
                        else begin

                            if (hw_first_data_sync_list[1] == LOW && !one_state_trigger_occur) begin  /* must be low */
                                one_state_trigger_occur <= TRUE;
                            end
                            if (one_state_trigger_occur) begin

                                if (!running_timer_is_in_reset) begin
                                    running_timer_need_reset <= TRUE;
                                end
                                else begin

                                    running_timer_need_reset <= FALSE;
                                    one_state_trigger_occur <= FALSE;

                                    case (current_channel)
                                        4'd1: usr_channel2 <= hw_data;
                                        4'd2: usr_channel3 <= hw_data;
                                        4'd3: usr_channel4 <= hw_data;
                                        4'd4: usr_channel5 <= hw_data;
                                        4'd5: usr_channel6 <= hw_data;
                                        4'd6: usr_channel7 <= hw_data;
                                        4'd7: usr_channel8 <= hw_data;
                                        default: begin
                                            if (!(!usr_rst || `ERROR_OCCURRED)) begin
                                                error_occurred_condition_3 <= TRUE;
                                            end
                                        end
                                    endcase

                                    /* channel pointer to next channel */

                                    current_channel <= current_channel + 1;

                                    /* [running timer]: reset & start up */

                                    running_timer_en <= TIMER_ENABLE;

                                    system_sub_state <= SUB_STATE_RD_LOW_PULSE_INTERVAL;
                                end
                            end

                            else begin

                                /* error, FIRST_DATA is LOW and timeout */

                                if (running_timer >= FIRST_DATA_WAIT_CLOCKS && !(!usr_rst || `ERROR_OCCURRED)) begin
                                    error_occurred_condition_4 <= TRUE;
                                end

                            end
                        end
                    end

                    /*
                     * ... ...
                     * make a LOW pulse for RD#
                     * ... ...
                     */

                    SUB_STATE_RD_LOW_PULSE_INTERVAL: begin
                        if (running_timer >= T10_CLOCKS && !one_state_trigger_occur) begin
                            one_state_trigger_occur <= TRUE;
                        end
                        if (one_state_trigger_occur) begin
                            if (!running_timer_is_in_reset) begin
                                    running_timer_need_reset <= TRUE;
                            end
                            else begin

                                running_timer_need_reset <= FALSE;
                                one_state_trigger_occur <= FALSE;

                                /* hardware setting, RD# to HIGH */

                                hw_rd <= HIGH;

                                system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE;

                                if (current_channel < 4'd8) begin

                                    /* [running timer]: reset & start up */

                                    running_timer_en <= TIMER_ENABLE;

                                end
                                else begin

                                    /* [running timer]: reset & shut down */

                                    running_timer_en <= TIMER_DISABLE;

                                    /* read complete */

                                    system_state <= STATE_MEASURE_COMPLETE;

                                end 
                            end
                        end
                    end

                    default: system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE;

                endcase
            end

            /* 
             * ... ...
             * read channels
             * ... ...
             */

            STATE_MEASURE_COMPLETE: begin

                usr_complete <= 1'b1;
                usr_sampling <= 1'b0;
                usr_error <= 1'b0;

                system_state <= STATE_WAIT_FOR_USR_SAMPLE_TRIGGER;

                /* hardware setting, CS# to HIGH */

                hw_cs <= HIGH;

                /* [running timer]: reset & shut down */

                running_timer_en <= TIMER_DISABLE;

                /* [timeout timer]: reset & shut down */
                
                timeout_timer_en <= TIMER_DISABLE;
            end

            default: system_state <= STATE_WAIT_FOR_USR_SAMPLE_TRIGGER;
        endcase
    end
end

/* ---------------------------------------------- Reset Logic ------------------------------------------- */

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        reset_state <= RESET_STATE_CREATE_RESET_PULSE;
        hw_reset <= LOW;                    /* reset the AD7606 chip */
        usr_reset_down <= 1'b0;
        one_reset_state_trigger_occur <= FALSE;
        reset_timer_need_reset <= TRUE;

        reset_timer_en <= FALSE;
    end else begin
        case(reset_state)

            RESET_STATE_CREATE_RESET_PULSE: begin

                if (!reset_timer_is_in_reset) begin
                    reset_timer_need_reset <= TRUE;
                end
                else begin

                    reset_timer_need_reset <= FALSE;

                    /* [reset timer]: reset & start up */

                    reset_timer_en <= TIMER_ENABLE;

                    /* hardware setting, RESET to HIGH */

                    hw_reset <= HIGH;

                    reset_state <= RESET_STATE_WAIT_RESET_HIGH;
                end

            end 

            /*
            * ... ...
            * RESET is HIGH
            * ... ...
            */

            RESET_STATE_WAIT_RESET_HIGH: begin
                if (reset_timer >= T_RESET_CLOCKS && !one_reset_state_trigger_occur) begin
                    one_reset_state_trigger_occur <= TRUE;
                end
                if (one_reset_state_trigger_occur) begin

                    if (!reset_timer_is_in_reset) begin
                        reset_timer_need_reset <= TRUE;
                    end
                    else begin

                        reset_timer_need_reset <= FALSE;

                        /* [reset timer]: reset & shut down */

                        reset_timer_en <= TIMER_DISABLE;

                        /* hardware setting, RESET to LOW */

                        hw_reset <= LOW;

                        reset_state <= RESET_STATE_CREATE_COMPLETE;
                    end
                end
            end 

            RESET_STATE_CREATE_COMPLETE: begin
                if (!reset_timer_is_in_reset) begin
                    reset_timer_need_reset <= TRUE;
                end
                else begin

                    reset_timer_need_reset <= FALSE;

                    /* [reset timer]: reset & shut down */
    
                    reset_timer_en <= TIMER_DISABLE;

                    /* hardware setting, RESET to LOW */

                    hw_reset <= LOW;

                    usr_reset_down <= 1'b1;

                    reset_state <= RESET_STATE_CREATE_COMPLETE;
                end
            end

            default: begin
                if (!reset_timer_is_in_reset) begin
                    reset_timer_need_reset <= TRUE;
                end
                else begin

                    reset_timer_need_reset <= FALSE;

                    /* [reset timer]: reset & shut down */
    
                    reset_timer_en <= TIMER_DISABLE;

                    /* hardware setting, RESET to LOW */

                    hw_reset <= LOW;

                    usr_reset_down <= 1'b1;

                    reset_state <= RESET_STATE_CREATE_COMPLETE;
                end
            end

        endcase
    end
end

/* ---------------------------------------------- Running Timer ------------------------------------------------- */

wire running_timer_is_in_reset = (running_timer == RESET_TIMER);

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        running_timer_reset <= FALSE;
    end else begin
        if (running_timer_need_reset) begin
            running_timer_reset <= TRUE;
        end else begin
            running_timer_reset <= FALSE;
        end
    end
end

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        running_timer <= RESET_TIMER;
    end
    else begin
        if (running_timer_reset) begin
            running_timer <= RESET_TIMER;
        end else if (running_timer_en) begin
            running_timer <= running_timer + 1;
        end else begin
            running_timer <= RESET_TIMER;
        end
    end
end

/* ------------------------------------------ Reset Timer ----------------------------------------------- */

wire reset_timer_is_in_reset = (reset_timer == RESET_TIMER);

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        reset_timer_reset <= FALSE;
    end else begin
        if (reset_timer_need_reset) begin
            reset_timer_reset <= TRUE;
        end else begin
            reset_timer_reset <= FALSE;
        end
    end
end

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        reset_timer <= RESET_TIMER;
    end 
    else begin
        if (reset_timer_reset) begin
            reset_timer <= RESET_TIMER;
        end else if (reset_timer_en) begin
            reset_timer <= reset_timer + 1;
        end else begin
            reset_timer <= RESET_TIMER;
        end
    end
end

/* ---------------------------------------------- Timeout Timer ----------------------------------------------- */

wire timeout_timer_is_in_reset = (timeout_timer == RESET_TIMEOUT_TIMER);

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        timeout_timer_reset <= FALSE;
    end else begin
        if (timeout_timer_need_reset) begin
            timeout_timer_reset <= TRUE;
        end else begin
            timeout_timer_reset <= FALSE;
        end
    end
end

always @(posedge usr_clk) begin
    if (!usr_rst || `ERROR_OCCURRED) begin
        timeout_timer <= RESET_TIMEOUT_TIMER;
        if (`ERROR_OCCURRED) begin
            error_occurred_condition_5 <= FALSE;
        end
    end else begin

        if (timeout_timer_reset) begin
            timeout_timer <= RESET_TIMEOUT_TIMER;
        end 
        else if (timeout_timer_en) begin
            timeout_timer <= timeout_timer + 1;
        end 
        else begin
            timeout_timer <= RESET_TIMEOUT_TIMER;
        end

        if (timeout_timer >= TIMEOUT_CLOCKS && !(!usr_rst || `ERROR_OCCURRED)) begin
            error_occurred_condition_5 <= TRUE;
        end
    end
end

endmodule
