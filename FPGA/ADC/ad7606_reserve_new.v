/**
 * Author: Shixuan Liu
 * Date:   2025-8
 * Note:   1. Before performing any operation, it must be reset (apply a falling edge pulse to [usr_rst] and maintain a LOW level for 2 clock cycles);
 *         2. After resetting, apply a rising edge to [usr_trigger] and maintain a HIGH level for 2 clock cycles to start sampling.
 *            If [usr_sampling] is high, do not trigger sampling!
 *         3. If [usr_complete] becomes high, it means the sampling is complete;
 *         4. If [usr_error] becomes high, it means some error occurred in sampling process;
 */

module ad7606 
#(

/* --------------------------------------------- Parameters ---------------------------------------------- */
/*  
 * Condition: 1. V_DRIVE = 3.3 V;
 *            2. CONVST_A & CONVST_B are connected together;
 *            3. No Oversampling;
 */

parameter USR_CLK_CYCLE_NS = 20,                      /* unit: ns, clock cycle of [usr_clk] (e.g. 50 MHz -> 20 ns) */
               
          T_CYCLE_NS       = 5000,                    /* unit: ns, t_cycle of AD7606 (refer to data sheet) */
          T_RESET_NS       = 50,                      /* unit: ns, t_reset of AD7606 (refer to data sheet) */
          T_CONV_MIN_NS    = 3450,                    /* unit: ns, min t_conv of AD7606 (refer to data sheet) */
          T_CONV_MAX_NS    = 4150,                    /* unit: ns, max t_conv of AD7606 (refer to data sheet) */
          T1_NS            = 40,                      /* unit: ns, t1 of AD7606 (refer to data sheet) */
          T2_NS            = 25,                      /* unit: ns, t2 of AD7606 (refer to data sheet) */
          T10_NS           = 25,                      /* unit: ns, t10 of AD7606 (refer to data sheet) */
          T11_NS           = 15,                      /* unit: ns, t11 of AD7606 (refer to data sheet) */
          T14_NS           = 25,                      /* unit: ns, t14 of AD7606 (refer to data sheet) */
          T15_NS           = 6,                       /* unit: ns, t15 of AD7606 (refer to data sheet) */
          T26_NS           = 25                       /* unit: ns, t15 of AD7606 (refer to data sheet) */
)
(

    /* ------------------------------------------------ User interface ------------------------------------------------ */

    input wire         usr_trigger,                   /* Sample Enable, rising edge trigger, must be smaller than 100 kHz */
    input wire         usr_clk,                       /* System Clock, corresponding to USR_CLK_CYCLE_NS  */
    input wire         usr_rst,                       /* Reset this module, falling edge trigger */

    output reg [15: 0] usr_channel1,                  /* Data of channel-V1, 16 bit */
    output reg [15: 0] usr_channel2,                  /* Data of channel-V2, 16 bit */
    output reg [15: 0] usr_channel3,                  /* Data of channel-V3, 16 bit */
    output reg [15: 0] usr_channel4,                  /* Data of channel-V4, 16 bit */
    output reg [15: 0] usr_channel5,                  /* Data of channel-V5, 16 bit */
    output reg [15: 0] usr_channel6,                  /* Data of channel-V6, 16 bit */
    output reg [15: 0] usr_channel7,                  /* Data of channel-V7, 16 bit */
    output reg [15: 0] usr_channel8,                  /* Data of channel-V8, 16 bit */

    output reg         usr_complete,                  /* Read Complete, 1 = in reading;                   0 = complete reading */
    output reg         usr_error,                     /* Error flag,    1 = error occurred;               0 = normal */
    output reg         usr_sampling,                  /* sampling,      1 = in sampling (do not trigger); 0 = is idle */

    output reg         usr_reset_down,                /* Reset Down,    1 = complete to create a HIGH pulse for hardware RESET pin */

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

localparam CONVERT_COMPLETE_MAX_CYCLE                = T_CONV_MAX_NS + 500,
           WAIT_BUSY_TO_HIGH_MAX_CYCLE               = ((T1_NS + 100) > T_CONV_MIN_NS)? (T_CONV_MIN_NS / 2): (T1_NS + 100),
           FIRST_DATA_MAX_CYCLE                      = T26_NS + 100,
           TIMEOUT_CYCLE                             = T_CYCLE_NS + 500;

/* ORIGIN parameters */

/* ORIGIN chip parameters, all refer to data-sheet */

localparam TIMEOUT_CLOCKS_ORIGIN                     = (TIMEOUT_CYCLE  + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           T_RESET_CLOCKS_ORIGIN                     = (T_RESET_NS + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           T1_CLOCKS_ORIGIN                          = (T1_NS  + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           T2_CLOCKS_ORIGIN                          = (T2_NS  + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           T10_CLOCKS_ORIGIN                         = (T10_NS  + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           T11_CLOCKS_ORIGIN                         = (T11_NS + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           T14_CLOCKS_ORIGIN                         = (T14_NS + T15_NS  + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS + 2;  // +2: wait sync

/* ORIGIN timeout parameters */

localparam FIRST_DATA_WAIT_CLOCKS_ORIGIN             = (FIRST_DATA_MAX_CYCLE + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           WAIT_BUSY_TO_HIGH_MAX_CLOCKS_ORIGIN       = (WAIT_BUSY_TO_HIGH_MAX_CYCLE + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS,
           CONVERT_COMPLETE_WAIT_CLOCKS_ORIGIN       = (CONVERT_COMPLETE_MAX_CYCLE + USR_CLK_CYCLE_NS - 1) / USR_CLK_CYCLE_NS;

/* FINAL parameters */

/* FINAL chip parameters, all refer to data-sheet */

localparam TIMEOUT_CLOCKS                            = (TIMEOUT_CLOCKS_ORIGIN < 1)? 1: TIMEOUT_CLOCKS_ORIGIN,
           T_RESET_CLOCKS                            = (T_RESET_CLOCKS_ORIGIN < 1)? 1: T_RESET_CLOCKS_ORIGIN,
           T1_CLOCKS                                 = (T1_CLOCKS_ORIGIN < 1)? 1: T1_CLOCKS_ORIGIN,
           T2_CLOCKS                                 = (T2_CLOCKS_ORIGIN < 1)? 1: T2_CLOCKS_ORIGIN,
           T10_CLOCKS                                = (T10_CLOCKS_ORIGIN < 1)? 1: T10_CLOCKS_ORIGIN,
           T11_CLOCKS                                = (T11_CLOCKS_ORIGIN < 1)? 1: T11_CLOCKS_ORIGIN,
           T14_CLOCKS                                = (T14_CLOCKS_ORIGIN < 1)? 1: T14_CLOCKS_ORIGIN;

/* FINAL timeout parameters */

localparam FIRST_DATA_WAIT_CLOCKS                    = (FIRST_DATA_WAIT_CLOCKS_ORIGIN < 1)? 1: FIRST_DATA_WAIT_CLOCKS_ORIGIN,
           WAIT_BUSY_TO_HIGH_MAX_CLOCKS              = (WAIT_BUSY_TO_HIGH_MAX_CLOCKS_ORIGIN < 1)? 1: WAIT_BUSY_TO_HIGH_MAX_CLOCKS_ORIGIN,
           CONVERT_COMPLETE_WAIT_CLOCKS              = (CONVERT_COMPLETE_WAIT_CLOCKS_ORIGIN < 1)? 1: CONVERT_COMPLETE_WAIT_CLOCKS_ORIGIN;

/* Power On Reset Setting */

localparam POWER_ON_RESET_CLOCKS                     = 8'd4;

/* ----------------------------------------------- status value ------------------------------------------- */

/* timer reset values */

localparam RESET_TIMER_16BIT                         = 16'b0,
           RESET_TIMER_8BIT                          = 8'b0;

/* channels */

localparam CHANNEL_POINTER__CH1                      = 4'd0,
           CHANNEL_POINTER__CH2                      = 4'd1,
           CHANNEL_POINTER__CH3                      = 4'd2,
           CHANNEL_POINTER__CH4                      = 4'd3,
           CHANNEL_POINTER__CH5                      = 4'd4,
           CHANNEL_POINTER__CH6                      = 4'd5,
           CHANNEL_POINTER__CH7                      = 4'd6,
           CHANNEL_POINTER__CH8                      = 4'd7,
           CHANNEL_POINTER__NONE                     = 4'd8;

/* Logic parameters for hardware pins */

localparam HIGH                                      = 1'b1,
           LOW                                       = 1'b0;

/* Logic parameters for signals */

localparam TRUE                                      = 1'b1,
           FALSE                                     = 1'b0;

/* system state choice */

localparam STATE_WAIT_FOR_USR_SAMPLE_TRIGGER         = 3'd0, 
           STATE_CREATE_CONVST_PULSE                 = 3'd1,
           STATE_WAIT_BUSY_READY                     = 3'd2,
           STATE_WAIT_CONVERT_COMPLETE               = 3'd3,
           STATE_READ_CHANNELS                       = 3'd4;

/* system sub state choice */

localparam SUB_STATE_CREATE_RD_HIGH_PULSE            = 3'd0,
           SUB_STATE_WAIT_DATA_READY                 = 3'd1,
           SUB_STATE_READ_DATA                       = 3'd2,
           SUB_STATE_RD_LOW_PULSE_INTERVAL           = 3'd3;

/* system reset state choice */

localparam RESET_STATE_CREATE_RESET_PULSE            = 2'd0,
           RESET_STATE_WAIT_RESET_HIGH               = 2'd1,
           RESET_STATE_CREATE_COMPLETE               = 2'd2;

/* ----------------------------------------------- registers ---------------------------------------------- */

/* system auto reset */

reg [7: 0] power_on_timer                            = RESET_TIMER_8BIT;
reg system_power_on_reset                            = TRUE;

/* sync registers */

reg [2: 0] usr_trigger_sync_list                     = 3'b0;
reg [1: 0] hw_busy_sync_list                         = 2'b0;
reg [1: 0] hw_first_data_sync_list                   = 2'b0;

reg [15: 0] hw_data_sync1                            = 16'b0;
reg [15: 0] hw_data_sync2                            = 16'b0;

/* state flags */

reg [2: 0] system_state                              = STATE_WAIT_FOR_USR_SAMPLE_TRIGGER;
reg [2: 0] system_sub_state                          = SUB_STATE_CREATE_RD_HIGH_PULSE;
reg [1: 0] reset_state                               = RESET_STATE_CREATE_RESET_PULSE;

/* timer counters */

reg [15: 0] pulse_timer                              = RESET_TIMER_16BIT;
reg [15: 0] running_timer                            = RESET_TIMER_16BIT;
reg [15: 0] reset_timer                              = RESET_TIMER_16BIT;
reg [15: 0] timeout_timer                            = RESET_TIMER_16BIT;

/* channel reading pointer */

reg [3: 0] current_channel                           = CHANNEL_POINTER__CH1;

/* timer power control flag */

reg running_timer_en                                 = FALSE;
reg reset_timer_en                                   = FALSE;
reg timeout_timer_en                                 = FALSE;
reg pulse_timer_en                                   = FALSE;

reg error_condition__convert_timeout                 = FALSE, 
    error_condition__first_data_wait_timeout         = FALSE, 
    error_condition__channel_pointer_error           = FALSE, 
    error_condition__first_data_wrong_status         = FALSE, 
    error_condition__timeout                         = FALSE,
    error_condition__unable_to_start_convert         = FALSE;
    
reg one_state_trigger_occur                          = FALSE;
reg one_reset_state_trigger_occur                    = FALSE;

wire posedge_trigger = usr_trigger_sync_list[1] && ~usr_trigger_sync_list[2];

/* ------------------------------------------------ define -------------------------------------------- */

`define HW_BUSY_SYNCED hw_busy_sync_list[1]
`define HW_FIRST_DATA_SYNCED hw_first_data_sync_list[1]
`define HW_PARALLEL_DATA_SYNCED hw_data_sync2

`define PULSE_TIMER_HAVE_RESET            (pulse_timer == RESET_TIMER_16BIT)
`define RUNNING_TIMER_HAVE_RESET          (running_timer == RESET_TIMER_16BIT)
`define RESET_TIMER_HAVE_RESET            (reset_timer == RESET_TIMER_16BIT)
`define TIMEOUT_TIMER_HAVE_RESET          (timeout_timer == RESET_TIMER_16BIT)

`define INCREASE_CHANNEL \
        case (current_channel) \
            CHANNEL_POINTER__CH1: current_channel <= CHANNEL_POINTER__CH2; \
            CHANNEL_POINTER__CH2: current_channel <= CHANNEL_POINTER__CH3; \
            CHANNEL_POINTER__CH3: current_channel <= CHANNEL_POINTER__CH4; \
            CHANNEL_POINTER__CH4: current_channel <= CHANNEL_POINTER__CH5; \
            CHANNEL_POINTER__CH5: current_channel <= CHANNEL_POINTER__CH6; \
            CHANNEL_POINTER__CH6: current_channel <= CHANNEL_POINTER__CH7; \
            CHANNEL_POINTER__CH7: current_channel <= CHANNEL_POINTER__CH8; \
            CHANNEL_POINTER__CH8: current_channel <= CHANNEL_POINTER__NONE; \
            default: current_channel <= CHANNEL_POINTER__NONE; \
        endcase \

`define ERROR_OCCURRED (error_condition__convert_timeout || \
                        error_condition__first_data_wait_timeout || \
                        error_condition__channel_pointer_error || \
                        error_condition__first_data_wrong_status || \
                        error_condition__timeout || \
                        error_condition__unable_to_start_convert)

`define CHANNEL_POINTER_VALID (current_channel == CHANNEL_POINTER__CH1 || \
                               current_channel == CHANNEL_POINTER__CH2 || \
                               current_channel == CHANNEL_POINTER__CH3 || \
                               current_channel == CHANNEL_POINTER__CH4 || \
                               current_channel == CHANNEL_POINTER__CH5 || \
                               current_channel == CHANNEL_POINTER__CH6 || \
                               current_channel == CHANNEL_POINTER__CH7 || \
                               current_channel == CHANNEL_POINTER__CH8)

`define SYSTEM_RESET_CONDITION (!usr_rst || `ERROR_OCCURRED || system_power_on_reset)

`define HARDWARE_RESET \
    hw_convst <= HIGH;                   /* CONVRST_A and CONVRST_B are connect together on the board */\
    hw_rd <= HIGH;                       /* RD# pin of the AD7606 chip */\
    hw_cs <= HIGH;                       /* CS# pin of the AD7606 chip */\
    hw_range <= HIGH;                    /* Range select of the AD7606 chip */\
    hw_os <= {LOW, LOW, LOW};            /* OS0, OS1, OS2 Pins of the AD7606 */\
    hw_mode_select <= LOW;               /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */\
    hw_stby_n <= HIGH;                   /* STBY# pin of AD7606 */\

`define STATE_FLAGS_RESET \
    system_state <= STATE_WAIT_FOR_USR_SAMPLE_TRIGGER; \
    system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE; \
    one_state_trigger_occur <= FALSE; \
    pulse_timer_en <= FALSE; \
    running_timer_en <= FALSE; \
    timeout_timer_en <= FALSE; \
    current_channel <= 4'd0; \

`define RESET_OUTPUT_CHANNELS \
    usr_channel1 <= 16'b0; \
    usr_channel2 <= 16'b0; \
    usr_channel3 <= 16'b0; \
    usr_channel4 <= 16'b0; \
    usr_channel5 <= 16'b0; \
    usr_channel6 <= 16'b0; \
    usr_channel7 <= 16'b0; \
    usr_channel8 <= 16'b0; \

/* -------------------------------------- Detect usr_trigger (posedge) ------------------------------------------ */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        usr_trigger_sync_list <= 3'b0;

    end else begin

        usr_trigger_sync_list <= {usr_trigger_sync_list[1: 0], usr_trigger};

    end

end

/* ------------------------------------------- Detect hw_busy ------------------------------------------- */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        hw_busy_sync_list <= 2'b0;

    end else begin

        hw_busy_sync_list[1] <= hw_busy_sync_list[0];
        hw_busy_sync_list[0] <= hw_busy;

    end

end

/* -------------------------------------- Detect hw_first_data ------------------------------------------ */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        hw_first_data_sync_list <= 2'b0;

    end else begin

        hw_first_data_sync_list[1] <= hw_first_data_sync_list[0];
        hw_first_data_sync_list[0] <= hw_first_data;

    end

end

/* -------------------------------------- Detect hw_data ------------------------------------------ */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        hw_data_sync1 <= 16'b0;
        hw_data_sync2 <= 16'b0;

    end else begin

        hw_data_sync2 <= hw_data_sync1;
        hw_data_sync1 <= hw_data;

    end

end

/* ----------------------------------------- Triger The Sequence ---------------------------------------  */

`define COMPLETE_SEQUENCE 

always @(posedge usr_clk) begin
    
    if (`SYSTEM_RESET_CONDITION) begin

        /* reset output channels */

        `RESET_OUTPUT_CHANNELS

        /* reset output signal flags */

        usr_complete <= FALSE;
        usr_sampling <= FALSE;

        /* reset error conditions */

        if (`ERROR_OCCURRED) begin

            usr_error <= TRUE;

            error_condition__convert_timeout <= FALSE;
            error_condition__first_data_wait_timeout <= FALSE;
            error_condition__channel_pointer_error <= FALSE;
            error_condition__first_data_wrong_status <= FALSE;
            
            error_condition__unable_to_start_convert <= FALSE;

        end

        else begin

            usr_error <= FALSE;

        end

        /* reset hardware pins */

        `HARDWARE_RESET

        /* state flags */

        `STATE_FLAGS_RESET

    end else begin

        /* main state machine */

        case (system_state)

            STATE_WAIT_FOR_USR_SAMPLE_TRIGGER: begin

                /* catch [rise edge of posedge_trigger] */

                if (posedge_trigger && reset_state == RESET_STATE_CREATE_COMPLETE && !one_state_trigger_occur) begin

                    one_state_trigger_occur = TRUE;

                end

                /* after catch [rise edge of posedge_trigger] */

                if (one_state_trigger_occur) begin

                    /* reset timers: running timer & timeout timer */

                    if (!`RUNNING_TIMER_HAVE_RESET || !`TIMEOUT_TIMER_HAVE_RESET) begin

                        running_timer_en <= FALSE;
                        timeout_timer_en <= FALSE;

                    end

                    /* after timers reset: running_timer & timeout_timer */

                    else begin

                        /* restart timers: running_timer & timeout_timer */

                        running_timer_en <= TRUE;
                        timeout_timer_en <= TRUE;

                        /* release catch flag */

                        one_state_trigger_occur <= FALSE;

                        /* hardware control */

                        hw_cs <= LOW;      // CS# to LOW
                        hw_convst <= LOW;  // set CONVST to LOW to make a LOW pulse

                        /* user signals control */

                        usr_complete <= FALSE;
                        usr_error <= FALSE;
                        usr_sampling <= TRUE;

                        /* system state jump */

                        system_state <= STATE_CREATE_CONVST_PULSE;

                    end

                end

            end

            /* 
             * ... ...
             *
             * create a LOW pulse for CONVST
             *
             * ... ...
             */

            STATE_CREATE_CONVST_PULSE: begin

                /* catch condition */

                if (running_timer >= T2_CLOCKS && !one_state_trigger_occur) begin

                    one_state_trigger_occur <= TRUE;

                end

                /* after catch */

                if (one_state_trigger_occur) begin

                    /* reset running_timer */
                  
                    if (!`RUNNING_TIMER_HAVE_RESET) begin

                        running_timer_en <= FALSE;

                    end

                    /* after running_timer reset */

                    else begin

                        /* release catch flag */

                        one_state_trigger_occur <= FALSE;

                        /* hardware control*/

                        hw_convst <= HIGH;   // set CONVST to HIGH, complete to create a LOW pulse

                        /* [running timer]: start up */

                        running_timer_en <= TRUE;

                        /* system state jump */

                        system_state <= STATE_WAIT_BUSY_READY;

                    end

                end

            end

            /* 
             * ... ...
             *
             * make a delay, wait for a moment before detect BUSY
             *
             * ... ...
             */

            STATE_WAIT_BUSY_READY: begin

                /* catch condition */

                if ((running_timer >= T1_CLOCKS && `HW_BUSY_SYNCED == HIGH) && !one_state_trigger_occur) begin

                    one_state_trigger_occur <= TRUE;

                end 

                /* detect error, BUSY cannot become HIGH */

                else if (running_timer >= WAIT_BUSY_TO_HIGH_MAX_CLOCKS && `HW_BUSY_SYNCED == LOW) begin

                    error_condition__unable_to_start_convert <= TRUE;

                end

                /* after catch */

                if (one_state_trigger_occur) begin

                    /* reset running_timer */

                    if (!`RUNNING_TIMER_HAVE_RESET) begin

                        running_timer_en <= FALSE;

                    end

                    /* after running_timer reset */

                    else begin

                        /* release catch flag */

                        one_state_trigger_occur <= FALSE;

                        /* [running timer]: reset & start up */

                        running_timer_en <= TRUE;

                        /* system state jump */

                        system_state <= STATE_WAIT_CONVERT_COMPLETE;

                    end

                end

            end

            /* 
             * ... ...
             *
             * wait convert complete (detect BUSY until BUSY to LOW)
             *
             * ... ...
             */

            STATE_WAIT_CONVERT_COMPLETE: begin

                /* catch condition */

                if (`HW_BUSY_SYNCED == LOW && !one_state_trigger_occur) begin

                    one_state_trigger_occur <= TRUE;

                end

                /* detect error, BUSY cannot become LOW */

                else if (running_timer >= CONVERT_COMPLETE_WAIT_CLOCKS && `HW_BUSY_SYNCED == HIGH) begin
                    
                    error_condition__convert_timeout <= TRUE;

                end

                /* after catch */

                if (one_state_trigger_occur) begin

                    /* reset running_timer */

                    if (!`RUNNING_TIMER_HAVE_RESET) begin

                        running_timer_en <= FALSE;

                    end

                    /* after running_timer reset */

                    else begin

                        /* release catch flag */

                        one_state_trigger_occur <= FALSE;

                        /* read the data in the AD7606 chip, jump to sub-state */

                        system_state <= STATE_READ_CHANNELS;
                        system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE;

                        /* hardware control*/

                        hw_rd <= HIGH;  // RD# to HIGH

                        /* [running timer]: reset & start up */

                        running_timer_en <= TRUE;

                        /* channel pointer to channel-1 */

                        current_channel <= CHANNEL_POINTER__CH1;

                    end

                end

            end

            /*
             * ... ...
             *
             * read all channels (RD# is HIGH)
             *
             * ... ...
             */

            /* ----------------------------------- read channels ------------------------------------ */

            STATE_READ_CHANNELS: begin

                /* main sub-state machine */

                case (system_sub_state)

                    /*
                     * ... ...
                     *
                     * RD# is high
                     *
                     * ... ...
                     */

                    SUB_STATE_CREATE_RD_HIGH_PULSE: begin

                        /* catch condition */

                        if (running_timer >= T11_CLOCKS && !one_state_trigger_occur) begin

                            one_state_trigger_occur <= TRUE;

                        end

                        /* after catch */

                        if (one_state_trigger_occur) begin

                            /* reset running timer */

                            if (!`RUNNING_TIMER_HAVE_RESET || !`PULSE_TIMER_HAVE_RESET) begin

                                running_timer_en <= FALSE;
                                pulse_timer_en <= FALSE;

                            end

                            /* after running_timer reset */

                            else begin

                                /* release catch flag */

                                one_state_trigger_occur <= FALSE;

                                /* 
                                 * [running timer]: reset & start up 
                                 * [pulse timer]: reset & start up
                                 */

                                running_timer_en <= TRUE;
                                pulse_timer_en <= TRUE;

                                /* hardware setting, RD# to LOW */

                                hw_rd <= LOW;  // make a falling edge for RD# 

                                /* sub-state jump */

                                system_sub_state <= SUB_STATE_WAIT_DATA_READY;

                            end

                        end

                    end

                    /*
                     * ... ...
                     *
                     * waiting for data ready (make a delay)
                     *
                     * ... ...
                     */

                    SUB_STATE_WAIT_DATA_READY: begin

                        /* catch condition */

                        if ((running_timer >= T14_CLOCKS || pulse_timer >= T14_CLOCKS) && !one_state_trigger_occur) begin

                            one_state_trigger_occur <= TRUE;

                        end

                        /* after catch */

                        if (one_state_trigger_occur) begin

                            /* reset running_timer */

                            if (!`RUNNING_TIMER_HAVE_RESET) begin

                                running_timer_en <= FALSE;

                            end

                            /* after running_timer reset */

                            else begin

                                /* release catch flag */

                                one_state_trigger_occur <= FALSE;

                                /* [running timer]: reset & start up */

                                running_timer_en <= TRUE;

                                /* sub-state jump */

                                system_sub_state <= SUB_STATE_READ_DATA;

                            end

                        end

                    end

                    SUB_STATE_READ_DATA: begin

                        /* for channel-1 FIRST_DATA must be HIGH */

                        if (current_channel == CHANNEL_POINTER__CH1) begin

                            /* catch condition (FIRST_DATA is HIGH) */

                            if (`HW_FIRST_DATA_SYNCED == HIGH && !one_state_trigger_occur) begin

                                one_state_trigger_occur <= TRUE;

                            end

                            /* error condition (FIRST_DATA is LOW) */

                            else if (running_timer >= FIRST_DATA_WAIT_CLOCKS && `HW_FIRST_DATA_SYNCED == LOW) begin

                                error_condition__first_data_wait_timeout <= TRUE;

                            end

                            /* after catch */

                            if (one_state_trigger_occur) begin

                                /* reset running_timer */

                                if (!`RUNNING_TIMER_HAVE_RESET) begin

                                    running_timer_en <= FALSE;

                                end

                                /* after running_timer reset */

                                else begin

                                    /* release catch flag */

                                    one_state_trigger_occur <= FALSE;

                                    /* FIRST_DATA is High, read channel-1 */

                                    usr_channel1 <= `HW_PARALLEL_DATA_SYNCED;

                                    /* channel pointer to channel-2 */

                                    `INCREASE_CHANNEL

                                    /* [running timer]: reset & start up */

                                    running_timer_en <= TRUE;

                                    /* sub-state jump */

                                    system_sub_state <= SUB_STATE_RD_LOW_PULSE_INTERVAL;

                                end

                            end

                        end

                        /* for channel-2 to channel-8 */

                        else begin

                            /* catch condition */

                            if (`HW_FIRST_DATA_SYNCED == LOW && !one_state_trigger_occur) begin

                                one_state_trigger_occur <= TRUE;

                            end

                            else if (running_timer >= FIRST_DATA_WAIT_CLOCKS && `HW_FIRST_DATA_SYNCED == HIGH) begin
                            
                                error_condition__first_data_wrong_status <= TRUE;

                            end

                            /* after catch */

                            if (one_state_trigger_occur) begin

                                /* reset running_timer */

                                if (!`RUNNING_TIMER_HAVE_RESET) begin

                                    running_timer_en <= FALSE;

                                end

                                /* after running_timer reset */

                                else begin

                                    /* release catch flag */

                                    one_state_trigger_occur <= FALSE;

                                    /* read channel */

                                    case (current_channel)

                                        CHANNEL_POINTER__CH2: usr_channel2 <= `HW_PARALLEL_DATA_SYNCED;
                                        CHANNEL_POINTER__CH3: usr_channel3 <= `HW_PARALLEL_DATA_SYNCED;
                                        CHANNEL_POINTER__CH4: usr_channel4 <= `HW_PARALLEL_DATA_SYNCED;
                                        CHANNEL_POINTER__CH5: usr_channel5 <= `HW_PARALLEL_DATA_SYNCED;
                                        CHANNEL_POINTER__CH6: usr_channel6 <= `HW_PARALLEL_DATA_SYNCED;
                                        CHANNEL_POINTER__CH7: usr_channel7 <= `HW_PARALLEL_DATA_SYNCED;
                                        CHANNEL_POINTER__CH8: usr_channel8 <= `HW_PARALLEL_DATA_SYNCED;

                                        default: error_condition__channel_pointer_error <= TRUE;

                                    endcase

                                    /* channel pointer to next channel */

                                    `INCREASE_CHANNEL

                                    /* [running timer]: reset & shut down */

                                    running_timer_en <= FALSE;

                                    /* sub-state jump */

                                    system_sub_state <= SUB_STATE_RD_LOW_PULSE_INTERVAL;

                                end

                            end

                        end

                    end

                    /*
                     * ... ...
                     *
                     * make a LOW pulse for RD#
                     *
                     * ... ...
                     */

                    SUB_STATE_RD_LOW_PULSE_INTERVAL: begin

                        /* catch condition */

                        if ((running_timer >= T10_CLOCKS && !one_state_trigger_occur) || pulse_timer >= T10_CLOCKS) begin

                            one_state_trigger_occur <= TRUE;

                        end

                        /* after catch */

                        if (one_state_trigger_occur) begin

                            /* hardware setting, RD# to HIGH */

                            hw_rd <= HIGH;

                            /* reset timers */

                            pulse_timer_en <= FALSE;
                            running_timer_en <= FALSE;

                            /* read continue */

                            if (`CHANNEL_POINTER_VALID) begin

                                /* reset running timer */

                                if (!`RUNNING_TIMER_HAVE_RESET) begin
                                    
                                    running_timer_en <= FALSE;

                                end

                                else begin

                                    /* release catch flag */

                                    one_state_trigger_occur <= FALSE;
                                
                                    /* [running timer]: reset & start up */

                                    running_timer_en <= TRUE;

                                    /* sub-state jump */

                                    system_sub_state <= SUB_STATE_CREATE_RD_HIGH_PULSE;

                                end

                            end

                            /* read complete */

                            else begin

                                /* -------------------------- complete all ----------------------- */

                                /* set output signals */

                                usr_complete <= TRUE;
                                usr_sampling <= FALSE;
                                usr_error <= FALSE;

                                /* reset hardware pins */

                                `HARDWARE_RESET

                                /* state flags */

                                `STATE_FLAGS_RESET

                            end 

                        end

                    end

                    default: error_condition__channel_pointer_error <= TRUE;

                endcase

            end

            default: error_condition__channel_pointer_error <= TRUE;

        endcase
    end
end

/* ---------------------------------------------- Reset Logic ------------------------------------------- */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        reset_state <= RESET_STATE_CREATE_RESET_PULSE;
        hw_reset <= LOW;                    /* reset the AD7606 chip */
        usr_reset_down <= FALSE;
        one_reset_state_trigger_occur <= FALSE;
        
        reset_timer_en <= FALSE;

    end else begin

        /* main reset-state machine */

        case(reset_state)

            RESET_STATE_CREATE_RESET_PULSE: begin

                /* reset reset_timer */

                if (!`RESET_TIMER_HAVE_RESET) begin

                    reset_timer_en <= FALSE;

                end

                /* after reset_timer reset */

                else begin

                    /* [reset timer]: reset & start up */

                    reset_timer_en <= TRUE;

                    /* hardware setting, RESET to HIGH */

                    hw_reset <= HIGH;

                    /* reset-state jump */

                    reset_state <= RESET_STATE_WAIT_RESET_HIGH;

                end

            end 

            /*
            * ... ...
            *
            * RESET is HIGH
            *
            * ... ...
            */

            RESET_STATE_WAIT_RESET_HIGH: begin

                /* catch condition */

                if (reset_timer >= T_RESET_CLOCKS && !one_reset_state_trigger_occur) begin

                    one_reset_state_trigger_occur <= TRUE;

                end

                /* after catch */

                if (one_reset_state_trigger_occur) begin

                    /* reset reset_timer */

                    if (!`RESET_TIMER_HAVE_RESET) begin

                        reset_timer_en <= FALSE;

                    end

                    /* after reset_timer reset */

                    else begin

                        /* [reset timer]: reset & shut down */

                        reset_timer_en <= FALSE;

                        /* hardware setting, RESET to LOW */

                        hw_reset <= LOW;

                        /* reset-state jump */

                        reset_state <= RESET_STATE_CREATE_COMPLETE;

                    end

                end

            end 

            RESET_STATE_CREATE_COMPLETE: begin

                /* reset reset_timer */

                if (!`RESET_TIMER_HAVE_RESET) begin

                    reset_timer_en <= FALSE;

                end

                /* after reset_timer reset */

                else begin

                    /* [reset timer]: reset & shut down */
    
                    reset_timer_en <= FALSE;

                    /* hardware setting, RESET to LOW */

                    hw_reset <= LOW;

                    /* usr_reset_down to TRUE */

                    usr_reset_down <= TRUE;

                    /* reset-state jump */

                    reset_state <= RESET_STATE_CREATE_COMPLETE;
                end
            end

            default: begin

                if (!`RESET_TIMER_HAVE_RESET) begin

                    reset_timer_en <= FALSE;

                end

                else begin

                    /* [reset timer]: reset & shut down */
    
                    reset_timer_en <= FALSE;

                    /* hardware setting, RESET to LOW */

                    hw_reset <= LOW;

                    usr_reset_down <= TRUE;

                    reset_state <= RESET_STATE_CREATE_COMPLETE;

                end
            end

        endcase
    end
end

/* ---------------------------------------------- Running Timer ------------------------------------------------- */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        running_timer <= RESET_TIMER_16BIT;

    end

    else begin

        if (running_timer_en) begin

            running_timer <= running_timer + 1;

        end else begin

            running_timer <= RESET_TIMER_16BIT;

        end

    end

end

/* ---------------------------------------------- Pulse Timer ------------------------------------------------- */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        pulse_timer <= RESET_TIMER_16BIT;

    end

    else begin

        if (pulse_timer_en) begin

            pulse_timer <= pulse_timer + 1;

        end else begin

            pulse_timer <= RESET_TIMER_16BIT;

        end

    end

end

/* ------------------------------------------ Reset Timer ----------------------------------------------- */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        reset_timer <= RESET_TIMER_16BIT;

    end 

    else begin

        if (reset_timer_en) begin

            reset_timer <= reset_timer + 1;

        end else begin

            reset_timer <= RESET_TIMER_16BIT;

        end

    end

end

/* ---------------------------------------------- Timeout Timer ----------------------------------------------- */

always @(posedge usr_clk) begin

    if (`SYSTEM_RESET_CONDITION) begin

        timeout_timer <= RESET_TIMER_16BIT;

        if (`ERROR_OCCURRED) begin

            error_condition__timeout <= FALSE;

        end

    end else begin

        if (timeout_timer_en) begin

            timeout_timer <= timeout_timer + 1;

        end 

        else begin

            timeout_timer <= RESET_TIMER_16BIT;

        end

        if (timeout_timer >= TIMEOUT_CLOCKS) begin

            error_condition__timeout <= TRUE;

        end
    end
end

/* ---------------------------------------------- Power On Reset Timer ----------------------------------------------- */

always @(posedge usr_clk) begin

    if (!usr_rst) begin

        power_on_timer <= RESET_TIMER_8BIT;
        system_power_on_reset <= TRUE;

    end else begin

        if (system_power_on_reset) begin

            if (power_on_timer >= POWER_ON_RESET_CLOCKS) begin

                system_power_on_reset <= FALSE;

            end else begin

                power_on_timer <= power_on_timer + 1;

            end

        end

    end

end

endmodule
