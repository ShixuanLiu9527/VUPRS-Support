module vuprs_adc_top
(
    /* Basic hardware pins */

    (* keep = "true" *) input wire clk,           /* Clock 50 MHz */
    (* keep = "true" *) input wire rst,           /* Reset pin */

    /* ADC-A hardware pins */

    (* keep = "true" *) input wire         adc_busy_a,                       /* BUSY pin of the AD7606 chip */
    (* keep = "true" *) input wire         adc_first_data_a,                 /* FIRSTDATA pin of the AD7606 chip  */
    (* keep = "true" *) input wire [15: 0] adc_data_a,                       /* D0 - D15 Pins of the AD7606 chip */

    (* keep = "true" *) output wire        adc_convst_a,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    (* keep = "true" *) output wire        adc_rd_a,                         /* RD# pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_cs_a,                         /* CS# pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_range_a,                      /* RANGE pin of the AD7606 chip */
    (* keep = "true" *) output wire [2: 0] adc_os_a,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    (* keep = "true" *) output wire        adc_mode_select_a,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_reset_a,                      /* RESET pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_stby_n_a,                      /* STBY# pin of the AD7606 */

    /* ADC-B hardware pins */

    (* keep = "true" *) input wire         adc_busy_b,                       /* BUSY pin of the AD7606 chip */
    (* keep = "true" *) input wire         adc_first_data_b,                 /* FIRSTDATA pin of the AD7606 chip  */
    (* keep = "true" *) input wire [15: 0] adc_data_b,                       /* D0 - D15 Pins of the AD7606 chip */

    (* keep = "true" *) output wire        adc_convst_b,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    (* keep = "true" *) output wire        adc_rd_b,                         /* RD# pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_cs_b,                         /* CS# pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_range_b,                      /* RANGE pin of the AD7606 chip */
    (* keep = "true" *) output wire [2: 0] adc_os_b,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    (* keep = "true" *) output wire        adc_mode_select_b,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_reset_b,                      /* RESET pin of the AD7606 chip */
    (* keep = "true" *) output wire        adc_stby_n_b                      /* STBY# pin of the AD7606 */
);

(* keep = "true" *) wire [15: 0] ch1_a, ch2_a, ch3_a, ch4_a, ch5_a, ch6_a, ch7_a, ch8_a;
(* keep = "true" *) wire [15: 0] ch1_b, ch2_b, ch3_b, ch4_b, ch5_b, ch6_b, ch7_b, ch8_b;

(* keep = "true" *) wire adc_complete_a;
(* keep = "true" *) wire adc_error_a;
(* keep = "true" *) wire adc_sampling_a;
(* keep = "true" *) wire adc_reset_down_a;

(* keep = "true" *) wire adc_complete_b;
(* keep = "true" *) wire adc_error_b;
(* keep = "true" *) wire adc_sampling_b;
(* keep = "true" *) wire adc_reset_down_b;

(* keep = "true" *) reg [24: 0] sampling_timer = 25'b0;
(* keep = "true" *) reg sampling_trigger = 1'b0;

wire sampling_signal = sampling_trigger;

localparam sample_frequency_Hz = 100_000,
           system_clk_frequency_Hz = 50_000_000;

localparam sample_clock_setting = system_clk_frequency_Hz / (sample_frequency_Hz * 2) - 1;  // 20000 Hz sample rate (clk = 50 MHz)

/* ADC-A controller */

ad7606 adc_a_controller
(
    /* ------------------------------------------------ User interface ------------------------------------------------ */

    .usr_trigger(sampling_signal),                   /* Sample Enable, rising edge trigger USR_SYSTEM_CLOCK_CYCLE */
    .usr_clk(clk),                       /* System Clock, corresponding to  */
    .usr_rst(rst),                       /* Reset this module, falling edge trigger */

    .usr_channel1(ch1_a),                  /* Data of channel V1, 16 bit */
    .usr_channel2(ch2_a),                  /* Data of channel V2, 16 bit */
    .usr_channel3(ch3_a),                  /* Data of channel V3, 16 bit */
    .usr_channel4(ch4_a),                  /* Data of channel V4, 16 bit */
    .usr_channel5(ch5_a),                  /* Data of channel V5, 16 bit */
    .usr_channel6(ch6_a),                  /* Data of channel V6, 16 bit */
    .usr_channel7(ch7_a),                  /* Data of channel V7, 16 bit */
    .usr_channel8(ch8_a),                  /* Data of channel V8, 16 bit */

    .usr_complete(adc_complete_a),                  /* Read complete, 1 = in reading; 0 = complete reading */
    .usr_error(adc_error_a),                     /* Error flag, 1 = error occurred; 0 = normal */
    .usr_sampling(adc_sampling_a),                  /* sampling, 1 = in sampling, do not trigger; 0 = is idle */
    .usr_reset_down(adc_reset_down_a),                /* Reset is down (complete to create a HIGH pulse for RESET pin) */

    /* --------------------------------------------- Hardware interface ---------------------------------------------- */

    .hw_busy(adc_busy_a),                       /* BUSY pin of the AD7606 chip */
    .hw_first_data(adc_first_data_a),                 /* FIRSTDATA pin of the AD7606 chip  */
    .hw_data(adc_data_a),                       /* D0 - D15 Pins of the AD7606 chip */

    .hw_convst(adc_convst_a),                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    .hw_rd(adc_rd_a),                         /* RD# pin of the AD7606 chip */
    .hw_cs(adc_cs_a),                         /* CS# pin of the AD7606 chip */
    .hw_range(adc_range_a),                      /* RANGE pin of the AD7606 chip */
    .hw_os(adc_os_a),                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    .hw_mode_select(adc_mode_select_a),                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    .hw_reset(adc_reset_a),                      /* RESET pin of the AD7606 chip */
    .hw_stby_n(adc_stby_n_a)                      /* STBY# pin of the AD7606 */
);

/* ADC-A controller */

ad7606 adc_b_controller
(
    /* ------------------------------------------------ User interface ------------------------------------------------ */

    .usr_trigger(sampling_signal),                   /* Sample Enable, rising edge trigger USR_SYSTEM_CLOCK_CYCLE */
    .usr_clk(clk),                       /* System Clock, corresponding to  */
    .usr_rst(rst),                       /* Reset this module, falling edge trigger */

    .usr_channel1(ch1_b),                  /* Data of channel V1, 16 bit */
    .usr_channel2(ch2_b),                  /* Data of channel V2, 16 bit */
    .usr_channel3(ch3_b),                  /* Data of channel V3, 16 bit */
    .usr_channel4(ch4_b),                  /* Data of channel V4, 16 bit */
    .usr_channel5(ch5_b),                  /* Data of channel V5, 16 bit */
    .usr_channel6(ch6_b),                  /* Data of channel V6, 16 bit */
    .usr_channel7(ch7_b),                  /* Data of channel V7, 16 bit */
    .usr_channel8(ch8_b),                  /* Data of channel V8, 16 bit */

    .usr_complete(adc_complete_b),                  /* Read complete, 1 = in reading; 0 = complete reading */
    .usr_error(adc_error_b),                     /* Error flag, 1 = error occurred; 0 = normal */
    .usr_sampling(adc_sampling_b),                  /* sampling, 1 = in sampling, do not trigger; 0 = is idle */
    .usr_reset_down(adc_reset_down_b),                /* Reset is down (complete to create a HIGH pulse for RESET pin) */

    /* --------------------------------------------- Hardware interface ---------------------------------------------- */

    .hw_busy(adc_busy_b),                       /* BUSY pin of the AD7606 chip */
    .hw_first_data(adc_first_data_b),                 /* FIRSTDATA pin of the AD7606 chip  */
    .hw_data(adc_data_b),                       /* D0 - D15 Pins of the AD7606 chip */

    .hw_convst(adc_convst_b),                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    .hw_rd(adc_rd_b),                         /* RD# pin of the AD7606 chip */
    .hw_cs(adc_cs_b),                         /* CS# pin of the AD7606 chip */
    .hw_range(adc_range_b),                      /* RANGE pin of the AD7606 chip */
    .hw_os(adc_os_b),                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    .hw_mode_select(adc_mode_select_b),                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    .hw_reset(adc_reset_b),                      /* RESET pin of the AD7606 chip */
    .hw_stby_n(adc_stby_n_b)                      /* STBY# pin of the AD7606 */
);

vuprs_ila_0 system_ila (
	.clk(clk), // input wire clk


	.probe0(adc_a_controller.hw_data_sync2), // input wire [15:0]  probe0  
	.probe1(adc_b_controller.hw_data_sync2), // input wire [15:0]  probe1 
	.probe2(adc_a_controller.system_state), // input wire [2:0]  probe2 
	.probe3(adc_b_controller.system_state), // input wire [2:0]  probe3 
	.probe4(adc_a_controller.system_sub_state), // input wire [2:0]  probe4 
	.probe5(adc_b_controller.system_sub_state), // input wire [2:0]  probe5 
	.probe6(adc_rd_a), // input wire [0:0]  probe6 
	.probe7(adc_rd_b), // input wire [0:0]  probe7 
	.probe8(adc_busy_a), // input wire [0:0]  probe8 
	.probe9(adc_busy_b), // input wire [0:0]  probe9 
	.probe10(adc_first_data_a), // input wire [0:0]  probe10 
	.probe11(adc_first_data_b) // input wire [0:0]  probe11
);

/* sampling clock */

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        sampling_trigger <= 1'b0;
        sampling_timer <= 25'b0;
    end
    else begin

        if (sampling_timer >= sample_clock_setting) begin
            sampling_trigger <= ~sampling_trigger;
            sampling_timer <= 25'b0;
        end
        else begin
            sampling_timer <= sampling_timer + 1;
        end

    end
end

endmodule
