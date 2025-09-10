module vuprs_adc_top
(
    /* Basic hardware pins */

    (* keep = "true" *) input wire clk,           /* Clock 50 MHz */
    (* keep = "true" *) input wire rst,           /* Reset pin */

    /* ADC hardware pins */

    (* keep = "true" *) input wire         adc_busy,                       /* BUSY pin of the AD7606 chip */
    (* keep = "true" *) input wire         adc_first_data,                 /* FIRSTDATA pin of the AD7606 chip  */
    (* keep = "true" *) input wire [15: 0] adc_data,                       /* D0 - D15 Pins of the AD7606 chip */

    (* keep = "true" *) output wire         adc_convst,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    (* keep = "true" *) output wire         adc_rd,                         /* RD# pin of the AD7606 chip */
    (* keep = "true" *) output wire         adc_cs,                         /* CS# pin of the AD7606 chip */
    (* keep = "true" *) output wire         adc_range,                      /* RANGE pin of the AD7606 chip */
    (* keep = "true" *) output wire [2: 0]  adc_os,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    (* keep = "true" *) output wire         adc_mode_select,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    (* keep = "true" *) output wire         adc_reset,                      /* RESET pin of the AD7606 chip */
    (* keep = "true" *) output wire         adc_stby_n                      /* STBY# pin of the AD7606 */
);

(* keep = "true" *) wire [15: 0] ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8;

(* keep = "true" *) wire adc_complete;
(* keep = "true" *) wire adc_error;
(* keep = "true" *) wire adc_sampling;
(* keep = "true" *) wire adc_reset_down;

(* keep = "true" *) reg [24: 0] sampling_timer = 25'b0;
(* keep = "true" *) reg sampling_trigger = 1'b0;

wire sampling_signal = sampling_trigger;

localparam sample_frequency_Hz = 20000,
           system_clk_frequency_Hz = 50_000_000;

localparam sample_clock_setting = system_clk_frequency_Hz / (sample_frequency_Hz * 2) - 1;  // 20000 Hz sample rate (clk = 50 MHz)

/* AD7606 controller */

ad7606 system_adc_controller
(
    /* ------------------------------------------------ User interface ------------------------------------------------ */

    .usr_trigger(sampling_signal),                   /* Sample Enable, rising edge trigger USR_SYSTEM_CLOCK_CYCLE */
    .usr_clk(clk),                       /* System Clock, corresponding to  */
    .usr_rst(rst),                       /* Reset this module, falling edge trigger */

    .usr_channel1(ch1),                  /* Data of channel V1, 16 bit */
    .usr_channel2(ch2),                  /* Data of channel V2, 16 bit */
    .usr_channel3(ch3),                  /* Data of channel V3, 16 bit */
    .usr_channel4(ch4),                  /* Data of channel V4, 16 bit */
    .usr_channel5(ch5),                  /* Data of channel V5, 16 bit */
    .usr_channel6(ch6),                  /* Data of channel V6, 16 bit */
    .usr_channel7(ch7),                  /* Data of channel V7, 16 bit */
    .usr_channel8(ch8),                  /* Data of channel V8, 16 bit */

    .usr_complete(adc_complete),                  /* Read complete, 1 = in reading; 0 = complete reading */
    .usr_error(adc_error),                     /* Error flag, 1 = error occurred; 0 = normal */
    .usr_sampling(adc_sampling),                  /* sampling, 1 = in sampling, do not trigger; 0 = is idle */
    .usr_reset_down(adc_reset_down),                /* Reset is down (complete to create a HIGH pulse for RESET pin) */

    /* --------------------------------------------- Hardware interface ---------------------------------------------- */

    .hw_busy(adc_busy),                       /* BUSY pin of the AD7606 chip */
    .hw_first_data(adc_first_data),                 /* FIRSTDATA pin of the AD7606 chip  */
    .hw_data(adc_data),                       /* D0 - D15 Pins of the AD7606 chip */

    .hw_convst(adc_convst),                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    .hw_rd(adc_rd),                         /* RD# pin of the AD7606 chip */
    .hw_cs(adc_cs),                         /* CS# pin of the AD7606 chip */
    .hw_range(adc_range),                      /* RANGE pin of the AD7606 chip */
    .hw_os(adc_os),                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    .hw_mode_select(adc_mode_select),                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    .hw_reset(adc_reset),                      /* RESET pin of the AD7606 chip */
    .hw_stby_n(adc_stby_n)                      /* STBY# pin of the AD7606 */
);

vuprs_ila_0 system_ila (
	.clk(clk), // input wire clk


	.probe0(adc_data), // input wire [15:0]  probe0  
	
	.probe1(sampling_signal), // input wire [0:0]  probe1 
	.probe2(adc_rd), // input wire [0:0]  probe2 
	.probe3(adc_convst), // input wire [0:0]  probe3 
	.probe4(adc_busy), // input wire [0:0]  probe4 
	.probe5(adc_cs), // input wire [0:0]  probe5
	.probe6(system_adc_controller.system_state), // input wire [2:0]  probe6 
	.probe7(system_adc_controller.current_channel) // input wire [2:0]  probe7
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
