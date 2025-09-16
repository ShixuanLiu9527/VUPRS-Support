/**
 *
 * Author:            Shixuan Liu, Tongji University
 * Brief:             Sampling clock generator
 * Date:              2025-9
 *
 *
 */

module sampling_clock_generator
#(
    parameter MAXIMUM_CLK_FREQ_HZ = 150_000               /* Maximum frequency of the output clock */
 )
 (
    input wire         clk_100mhz,                        /* Input clock, 100 MHz */
    input wire         rst_n,                             /* Reset */
    input wire         out_en,                            /* Output enable */
    input wire [15: 0] target_freq,                       /* Target frequency */

    output reg         sampling_clk                       /* Output sampling clock */
 );

localparam INPUT_CLK_FREQ_HZ   = 100_000_000;             /* Clock cycle of [clk] (e.g. 20 ns for 50 MHz) */
localparam LOW_PULSE_COUNT     = INPUT_CLK_FREQ_HZ / MAXIMUM_CLK_FREQ_HZ + 10;

localparam STATE_SHUT_DOWN        = 2'd0,
           STATE_OUTPUT_LOW_PULSE = 2'd1,
           STATE_OUTPUT_ENABLE    = 2'd2;

localparam TRUE                   = 1'b1,
           FALSE                  = 1'b0;

localparam HIGH                   = 1'b1,
           LOW                    = 1'b0;

reg [1: 0] logic_state = STATE_SHUT_DOWN;

reg [31: 0] phase_increment = 32'hFFFFFFFF;

reg [15: 0] target_freq_sync1 = 16'b0;
reg [15: 0] target_freq_sync2 = 16'b0;

reg [31: 0] phase_timer = 32'b0;
reg [31: 0] logic_timer = 32'b0;

reg logic_timer_en = FALSE;

wire frequency_change = (target_freq_sync1 != target_freq_sync2);

/* ------------------------------------------ Target Frequency Sync ---------------------------------------------- */

always @(posedge clk_100mhz or negedge rst_n) begin

   if (!rst_n) begin
   
      target_freq_sync1 <= 16'b0;
      target_freq_sync2 <= 16'b0;

   end else begin
   
      if (target_freq > MAXIMUM_CLK_FREQ_HZ) target_freq_sync1 <= MAXIMUM_CLK_FREQ_HZ;
      else target_freq_sync1 <= target_freq;
      
      target_freq_sync2 <= target_freq_sync1;

   end
   
end

/* -------------------------------------------- Phase Timer --------------------------------------------------- */

always @(posedge clk_100mhz or negedge rst_n) begin

   if (!rst_n) begin

      phase_timer <= 32'b0;
   
   end else begin

      if (out_en && logic_state == STATE_OUTPUT_ENABLE) begin

         if (target_freq_sync2 > 0) begin
            if (phase_timer >= phase_increment) begin
               phase_timer <= 32'b0;
               sampling_clk <= ~sampling_clk;
            end else begin
               phase_timer <= phase_timer + 1;
            end
         end else begin
            sampling_clk <= LOW;
         end

      end else begin 
         phase_timer <= 32'b0;
         sampling_clk <= LOW;
      end
      
   end

end

/* -------------------------------------------- Logic Timer --------------------------------------------------- */

always @(posedge clk_100mhz or negedge rst_n) begin

   if (!rst_n) begin

      logic_timer <= 32'b0;
   
   end else begin

      if (logic_timer_en) logic_timer <= logic_timer + 1;
      else logic_timer <= 32'b0;
      
   end

end

/* ------------------------------------------------ Logic State ------------------------------------------- */

/* State Flag */

always @(posedge clk_100mhz or negedge rst_n) begin

   if (!rst_n) logic_state <= STATE_SHUT_DOWN;
   else begin

      case (logic_state)

         STATE_SHUT_DOWN: begin
            if (frequency_change) begin 
               logic_state <= STATE_OUTPUT_LOW_PULSE;
               logic_timer_en <= TRUE;
            end
         end

         STATE_OUTPUT_LOW_PULSE: begin
            if (logic_timer >= LOW_PULSE_COUNT) begin
               logic_timer_en <= FALSE;
               logic_state <= STATE_OUTPUT_ENABLE;
            end
         end

         STATE_OUTPUT_ENABLE: begin
            if (frequency_change) logic_state <= STATE_OUTPUT_LOW_PULSE;
         end

         default: logic_state <= STATE_SHUT_DOWN;
         
      endcase
   
   end
   
end

/* Registers */

always @(posedge clk_100mhz or negedge rst_n) begin

   if (!rst_n) begin

      phase_increment <= 32'hFFFFFFFF;
      
   end else begin

      case (logic_state)

         STATE_SHUT_DOWN: phase_increment <= 32'hFFFFFFFF;
         
         STATE_OUTPUT_LOW_PULSE: phase_increment <= 32'hFFFFFFFF;
         
         STATE_OUTPUT_ENABLE: begin
            if (target_freq_sync2 > 0) phase_increment <= INPUT_CLK_FREQ_HZ / (target_freq_sync2 * 2) - 1;
            else phase_increment <= 32'hFFFFFFFF;
         end

         default: phase_increment <= 32'hFFFFFFFF;
            
      endcase
   
   end
   
end

endmodule