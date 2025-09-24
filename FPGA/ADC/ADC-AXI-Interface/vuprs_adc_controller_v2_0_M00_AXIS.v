`timescale 1 ns / 1 ps

module vuprs_adc_controller_v2_0_M00_AXIS #
(
		
	parameter integer USR_CLK_CYCLE_NS   = 20,                      /* unit: ns, clock cycle of [usr_clk] (e.g. 20 ns for 50 MHz) */
              		  T_CYCLE_NS         = 5000,                    /* unit: ns, t_cycle of AD7606 (refer to data sheet) */
          	  		  T_RESET_NS         = 50,                      /* unit: ns, t_reset of AD7606 (refer to data sheet) */
          	  		  T_CONV_MIN_NS      = 3450,                    /* unit: ns, min t_conv of AD7606 (refer to data sheet) */
          	  		  T_CONV_MAX_NS      = 4150,                    /* unit: ns, max t_conv of AD7606 (refer to data sheet) */
          	  		  T1_NS              = 40,                      /* unit: ns, t1 of AD7606 (refer to data sheet) */
          	  		  T2_NS              = 25,                      /* unit: ns, t2 of AD7606 (refer to data sheet) */
          	  		  T10_NS             = 25,                      /* unit: ns, t10 of AD7606 (refer to data sheet) */
          	  		  T11_NS             = 15,                      /* unit: ns, t11 of AD7606 (refer to data sheet) */
          	  		  T14_NS             = 25,                      /* unit: ns, t14 of AD7606 (refer to data sheet) */
          	  		  T15_NS             = 6,                       /* unit: ns, t15 of AD7606 (refer to data sheet) */
          	  		  T26_NS             = 25,                      /* unit: ns, t15 of AD7606 (refer to data sheet) */

	parameter CONTROL_REGISTER_WIDTH = 32,                  /* control register width */

	// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.

	parameter integer C_M_AXIS_TDATA_WIDTH	= 32,

	// Start init_count is the number of clock cycles the master will wait before initiating/issuing any transaction.

	parameter integer C_M_START_COUNT	= 32

)
(
	// Users to add ports here
	
	output wire [(C_M_AXIS_TDATA_WIDTH / 8) - 1: 0] M_AXIS_TKEEP,
	output wire [CONTROL_REGISTER_WIDTH - 1: 0] error_flags,
	
	input wire [CONTROL_REGISTER_WIDTH - 1: 0] sampling_clk_increment,
	input wire [CONTROL_REGISTER_WIDTH - 1: 0] sampling_points,

	input wire          sampling_trigger,              /* rising edge to trigger one sample */
	output wire         ready,
	input wire          rst_n,
	
	input wire          hw_busy,                       /* BUSY pin of the AD7606 chip */
    input wire          hw_first_data,                 /* FIRSTDATA pin of the AD7606 chip */
    input wire [15: 0]  hw_data,                       /* D0 - D15 Pins of the AD7606 chip */
    output wire         hw_convst,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    output wire         hw_rd,                         /* RD# pin of the AD7606 chip */
    output wire         hw_cs,                         /* CS# pin of the AD7606 chip */
    output wire         hw_range,                      /* RANGE pin of the AD7606 chip */
    output wire [2: 0]  hw_os,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    output wire         hw_mode_select,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    output wire         hw_reset,                      /* RESET pin of the AD7606 chip */
    output wire         hw_stby_n,                     /* STBY# pin of the AD7606 */

	// User ports ends
	// Do not modify the ports beyond this line
	// Global ports
	input wire  M_AXIS_ACLK,
	// 
	input wire  M_AXIS_ARESETN,
	// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
	output wire  M_AXIS_TVALID,
	// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
	output wire [C_M_AXIS_TDATA_WIDTH - 1: 0] M_AXIS_TDATA,
	// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
	output wire [(C_M_AXIS_TDATA_WIDTH / 8) - 1: 0] M_AXIS_TSTRB,
	// TLAST indicates the boundary of a packet.
	output wire  M_AXIS_TLAST,
	// TREADY indicates that the slave can accept a transfer in the current cycle.
	input wire  M_AXIS_TREADY
);
	
	// function called clogb2 that returns an integer which has the
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction
	                                                                                     
	// WAIT_COUNT_BITS is the width of the wait counter.                                 
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT - 1);
	                                                                                     
	// BIT_NUM gives the minimum number of bits needed to address 'depth' size of FIFO.  
	localparam BIT_NUM  = CONTROL_REGISTER_WIDTH + 1; 
	localparam FIFO_RESET_CLOCK_COUNT = 10;
	localparam FIFO_RESET_WAIT_MAX_COUNT = 150;
	                                                                                  
	/*  
		Define the states of state machine
		The control state machine oversees the writing of input streaming data to the FIFO,
		and outputs the streaming data from the FIFO
	*/
	localparam [1: 0] EXEC_STATE__IDLE = 2'b00,          // This is the initial/idle state               
	                                                                                     
	                  EXEC_STATE__INIT_COUNTER  = 2'b01, // This state initializes the counter, once
	                                        			 // the counter reaches C_M_START_COUNT init_count,
	                                        			 // the state machine changes state to SEND_STREAM
	                  EXEC_STATE__SEND_STREAM   = 2'b10; // In this state the
	                                        			 // stream data is output through M_AXIS_TDATA

	localparam FIFO_WRITE_STATE__IDLE             = 3'd0,
	           FIFO_WRITE_STATE__WRITE_FIFO       = 3'd1;

	localparam INVALID_DATA                       = {(C_M_AXIS_TDATA_WIDTH){1'b1}};

	localparam INVALID_SAMPLING_PARAM             = {(CONTROL_REGISTER_WIDTH){1'b1}};

	localparam BUFFER_RESET_VALUE                 = {(C_M_AXIS_TDATA_WIDTH){1'b1}};

	localparam HIGH                               = 1'b1,
			   LOW                                = 1'b0;

	localparam TRUE                               = 1'b1,
			   FALSE                              = 1'b0;

	reg [1: 0] mst_exec_state;  // State variable
	
	reg [BIT_NUM - 1: 0] data_send_count;  // indicate the quantity of sended data, BIT_NUM

	reg [BIT_NUM - 1: 0] sampling_clk_counter;
	reg sampling_clk = LOW;

	// AXI Stream internal signals

	
	reg [WAIT_COUNT_BITS-1 : 0] 	init_count;  // wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	
	reg  							    axis_tvalid;  // streaming data valid
	reg  	                            axis_tlast;   // t_last
	reg [C_M_AXIS_TDATA_WIDTH - 1 : 0] 	axis_tdata;    // FIFO implementation signals

	reg module_ready;

	reg [CONTROL_REGISTER_WIDTH - 1: 0] module_error_flags;   /* [3: 0] adc error; [5: 4] module error */
	
	wire fifo_rd_en;
	reg [C_M_AXIS_TDATA_WIDTH - 1: 0] current_fifo_read_data;

	reg [CONTROL_REGISTER_WIDTH - 1: 0] current_sampling_clk_increment;
	reg [CONTROL_REGISTER_WIDTH - 1: 0] current_sampling_points;

	reg sampling_trigger_sync1;
	reg sampling_trigger_sync2;
	
	wire fifo_almost_full;
	wire fifo_full;
	wire fifo_empty;
	wire fifo_almost_empty;

	wire fifo_wr_rst_busy;
	wire fifo_rd_rst_busy;

	reg fifo_reset = LOW;
	
	wire [15: 0] adc_ch1;
	wire [15: 0] adc_ch2;
	wire [15: 0] adc_ch3;
	wire [15: 0] adc_ch4;
	wire [15: 0] adc_ch5;
	wire [15: 0] adc_ch6;
	wire [15: 0] adc_ch7;
	wire [15: 0] adc_ch8;
	
	wire adc_sampling;
	wire adc_ready;
	wire [3: 0] adc_err;

	/* FIFO write logic  */
	
	reg [2: 0] fifo_write_state = FIFO_WRITE_STATE__IDLE;
	
	reg [2: 0] fifo_adc_channel_write_pointer = 3'b0;
	reg [C_M_AXIS_TDATA_WIDTH - 1: 0] current_fifo_write_data = INVALID_DATA;
	
	reg fifo_write_en = 1'b0;
	reg adc_data_have_pushed = 1'b0;

	/* User Registers end */

	// I/O Connections assignments

	assign M_AXIS_TVALID = axis_tvalid;
	assign M_AXIS_TDATA	 = axis_tdata;
	assign M_AXIS_TLAST	 = axis_tlast;

	assign ready = module_ready;
	assign error_flags = module_error_flags;

	wire axis_hand_shake = axis_tvalid && M_AXIS_TREADY;

	`define ONE_VALID_DATA_SEND_AT_THAT_TIME (axis_hand_shake && !fifo_empty)

	/* ------------------------------------------- Error Flags ------------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			module_error_flags <= 0;
		end else begin
			module_error_flags[3: 0] <= adc_err;
		end
	end

	/* ------------------------------------------- Data Input -------------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			current_sampling_clk_increment <= CONTROL_REGISTER_WIDTH;
			current_sampling_points <= CONTROL_REGISTER_WIDTH;
		end else begin
			if (mst_exec_state == EXEC_STATE__IDLE) begin
				current_sampling_clk_increment <= sampling_clk_increment;
				current_sampling_points <= sampling_points;
			end
		end
	end

	/* ----------------------------------------- Detect rising edge --------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			sampling_trigger_sync1 <= LOW;
			sampling_trigger_sync2 <= LOW;
		end else begin
			sampling_trigger_sync1 <= sampling_trigger;
			sampling_trigger_sync2 <= sampling_trigger_sync1;
		end
	end

	wire sampling_trigger_rising_edge = sampling_trigger_sync1 && (~sampling_trigger_sync2);

	/* ---------------------------------------- System state --------------------------------------------------- */

	/* Flags */
	
	always @(posedge M_AXIS_ACLK) begin
	
		if (!M_AXIS_ARESETN) begin

			mst_exec_state <= EXEC_STATE__IDLE;
			init_count <= 0;
			axis_tvalid <= LOW;

		end else begin
			case (mst_exec_state)

				EXEC_STATE__IDLE: begin
					axis_tvalid <= LOW;
					if (sampling_trigger_rising_edge) begin
						mst_exec_state <= EXEC_STATE__INIT_COUNTER;
						module_ready <= FALSE;
						init_count <= 0;
						fifo_reset <= HIGH;  // start reset fifo
					end else begin
						module_ready <= TRUE;
					end
				end

				EXEC_STATE__INIT_COUNTER: begin

					axis_tvalid <= LOW;
					
					if (init_count >= C_M_START_COUNT) begin

						if ((!fifo_full && !fifo_empty) || init_count >= FIFO_RESET_WAIT_MAX_COUNT) begin 
							mst_exec_state <= EXEC_STATE__SEND_STREAM;  // reset fifo
						end

					end else begin
						init_count <= init_count + 1;
						if (init_count >= FIFO_RESET_CLOCK_COUNT) begin
							fifo_reset <= LOW;  // detect full & empty
						end
					end

				end

				EXEC_STATE__SEND_STREAM: begin
					axis_tvalid <= HIGH;
					if (data_send_count >= current_sampling_points - 1 && `ONE_VALID_DATA_SEND_AT_THAT_TIME) begin
						mst_exec_state <= EXEC_STATE__IDLE;
					end
				end

				default: begin
					mst_exec_state <= EXEC_STATE__IDLE;
					init_count <= 0;
				end

			endcase
		end

	end

	/* Registers */

	assign fifo_rd_en = `ONE_VALID_DATA_SEND_AT_THAT_TIME;
	assign M_AXIS_TSTRB	 = {(C_M_AXIS_TDATA_WIDTH/8){!fifo_empty}};
	assign M_AXIS_TKEEP  = {(C_M_AXIS_TDATA_WIDTH/8){!fifo_empty}};

	always @(posedge M_AXIS_ACLK) begin
	
		if (!M_AXIS_ARESETN) begin

			data_send_count <= 0;
			axis_tdata <= INVALID_DATA;
			axis_tlast <= LOW;
			
		end else begin

			axis_tdata <= current_fifo_read_data;

			case (mst_exec_state)

				EXEC_STATE__SEND_STREAM: begin

					if (`ONE_VALID_DATA_SEND_AT_THAT_TIME) begin  // one valid data send at that time

						data_send_count <= data_send_count + 1;

						/*
							current_sampling_points - 1 number of data have been send, (current data is the last one)
							T_LAST should be HIGH to indicate last data
						*/

						if (data_send_count == current_sampling_points - 2) begin  

							axis_tlast <= HIGH;

						/* last data send successfully, T_LAST should be LOW */

						end else if (data_send_count == current_sampling_points - 1) begin  // all data have been send

							axis_tlast <= LOW;

						end
					end

				end

				default: begin
					data_send_count <= 0;
					axis_tlast <= LOW;
				end

			endcase

		end

	end

	/* ---------------------------------------------- AD sampling clock -------------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			sampling_clk_counter <= 0;
			sampling_clk <= LOW;
		end else begin

			/* Generate sample clock at SEND STREAM state */

			if (mst_exec_state == EXEC_STATE__SEND_STREAM) begin
				if (sampling_clk_counter >= current_sampling_clk_increment - 1) begin
					sampling_clk_counter <= 0;
					sampling_clk = ~sampling_clk;
				end else begin
					sampling_clk_counter <= sampling_clk_counter + 1;
				end
			end else begin
				sampling_clk_counter <= 0;
				sampling_clk <= LOW;
			end
		end
	end

	/* ---------------------------------------- AD sample (FIFO write logic) --------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
	   	if (!M_AXIS_ARESETN) begin                                        
	        fifo_write_state <= FIFO_WRITE_STATE__IDLE;
	        fifo_write_en <= FALSE;
	        adc_data_have_pushed <= FALSE;
	    end else begin
	       
	       	case(fifo_write_state)
	       
	           	FIFO_WRITE_STATE__IDLE: begin

	                if (adc_sampling) begin

	                    fifo_write_en <= FALSE;
	                    adc_data_have_pushed <= FALSE;
	                    fifo_write_state <= FIFO_WRITE_STATE__IDLE;
						fifo_adc_channel_write_pointer <= 3'b0;

	                end else begin

						if (!adc_data_have_pushed && !fifo_full) begin

	                        fifo_write_state <= FIFO_WRITE_STATE__WRITE_FIFO;
	                        fifo_write_en <= TRUE;
	                        current_fifo_write_data <= {adc_ch2, adc_ch1};

	                        fifo_adc_channel_write_pointer <= 3'd1;

	                    end else begin

	                        fifo_write_en <= FALSE;
	                        fifo_adc_channel_write_pointer <= 3'd0;

	                    end

					end
	            end
	               
	           	FIFO_WRITE_STATE__WRITE_FIFO: begin

	                if (!fifo_almost_full) begin

	                    case(fifo_adc_channel_write_pointer)

	                        3'd1: begin

	                            current_fifo_write_data <= {adc_ch4, adc_ch3};
	                            fifo_write_en <= TRUE;
	                            fifo_adc_channel_write_pointer <= 3'd2;

	                        end

	                        3'd2: begin

	                            current_fifo_write_data <= {adc_ch6, adc_ch5};
	                            fifo_write_en <= TRUE;
	                            fifo_adc_channel_write_pointer <= 3'd3;

	                        end

	                         3'd3: begin

	                            current_fifo_write_data <= {adc_ch8, adc_ch7};
	                            fifo_write_en <= TRUE;
	                            adc_data_have_pushed <= TRUE;
	                            fifo_write_state <= FIFO_WRITE_STATE__IDLE;

	                        end
	                               
	                        default: fifo_write_state <= FIFO_WRITE_STATE__IDLE;
	                    endcase
	                end else begin

	                    fifo_write_en <= FALSE;

	                end
	            end
	               
	           	default: fifo_write_state <= FIFO_WRITE_STATE__IDLE;
	       
	       	endcase
	    end
	end
	
	adc_fifo vuprs_adc_fifo (
  		.rst(fifo_reset),                    // input wire rst
  		.wr_clk(M_AXIS_ACLK),              // input wire wr_clk
  		.rd_clk(M_AXIS_ACLK),              // input wire rd_clk
  		.din(current_fifo_write_data),                    // input wire [31 : 0] din
  		.wr_en(fifo_write_en),                // input wire wr_en
  		.rd_en(fifo_rd_en),                // input wire rd_en
  		.dout(current_fifo_read_data),                  // output wire [31 : 0] dout
  		.full(fifo_full),                  // output wire full
  		.almost_full(fifo_almost_full),    // output wire almost_full
  		.empty(fifo_empty),                // output wire empty
  		.almost_empty(fifo_almost_empty),  // output wire almost_empty
  		.wr_rst_busy(fifo_wr_rst_busy),    // output wire wr_rst_busy
  		.rd_rst_busy(fifo_rd_rst_busy)    // output wire rd_rst_busy
	);
    
    ad7606 #(

        .USR_CLK_CYCLE_NS(USR_CLK_CYCLE_NS),                      /* unit: ns, clock cycle of [usr_clk] (e.g. 20 ns for 50 MHz) */
        .T_CYCLE_NS(T_CYCLE_NS),                    /* unit: ns, t_cycle of AD7606 (refer to data sheet) */
        .T_RESET_NS(T_RESET_NS),                      /* unit: ns, t_reset of AD7606 (refer to data sheet) */
        .T_CONV_MIN_NS(T_CONV_MIN_NS),                    /* unit: ns, min t_conv of AD7606 (refer to data sheet) */
        .T_CONV_MAX_NS(T_CONV_MAX_NS),                    /* unit: ns, max t_conv of AD7606 (refer to data sheet) */
        .T1_NS(T1_NS),                      /* unit: ns, t1 of AD7606 (refer to data sheet) */
        .T2_NS(T2_NS),                      /* unit: ns, t2 of AD7606 (refer to data sheet) */
        .T10_NS(T10_NS),                      /* unit: ns, t10 of AD7606 (refer to data sheet) */
        .T11_NS(T11_NS),                      /* unit: ns, t11 of AD7606 (refer to data sheet) */
        .T14_NS(T14_NS),                      /* unit: ns, t14 of AD7606 (refer to data sheet) */
        .T15_NS(T15_NS),                       /* unit: ns, t15 of AD7606 (refer to data sheet) */
        .T26_NS(T26_NS)                       /* unit: ns, t15 of AD7606 (refer to data sheet) */

    )
    vuprs_ad7606(

        /* -------------------------------------------- User interface ------------------------------------------ */

        .usr_trigger(sampling_clk),                   /* Sample Enable, rising edge trigger, must be smaller than 100 kHz */
        .usr_clk(M_AXIS_ACLK),                       /* System Clock, corresponding to USR_CLK_CYCLE_NS  */
        .usr_rst(rst_n),                       /* Reset this module, falling edge trigger */

        .usr_channel1(adc_ch1),                  /* Data of channel-V1, 16 bit */
        .usr_channel2(adc_ch2),                  /* Data of channel-V2, 16 bit */
        .usr_channel3(adc_ch3),                  /* Data of channel-V3, 16 bit */
        .usr_channel4(adc_ch4),                  /* Data of channel-V4, 16 bit */
        .usr_channel5(adc_ch5),                  /* Data of channel-V5, 16 bit */
        .usr_channel6(adc_ch6),                  /* Data of channel-V6, 16 bit */
        .usr_channel7(adc_ch7),                  /* Data of channel-V7, 16 bit */
        .usr_channel8(adc_ch8),                  /* Data of channel-V8, 16 bit */

        .usr_error(adc_err),                     /* Error flags */

        .usr_sampling(adc_sampling),                  /* sampling,      1 = in sampling (do not trigger); 0 = is idle */
        .usr_ready(adc_ready),                     /* Reset Down,    1 = complete to create a HIGH pulse for hardware RESET pin */

        /* ------------------------------------------ Hardware interface ---------------------------------------- */

        .hw_busy(hw_busy),                       /* BUSY pin of the AD7606 chip */
        .hw_first_data(hw_first_data),                 /* FIRSTDATA pin of the AD7606 chip  */
        .hw_data(hw_data),                       /* D0 - D15 Pins of the AD7606 chip */

        .hw_convst(hw_convst),                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
        .hw_rd(hw_rd),                         /* RD# pin of the AD7606 chip */
        .hw_cs(hw_cs),                         /* CS# pin of the AD7606 chip */
        .hw_range(hw_range),                      /* RANGE pin of the AD7606 chip */
        .hw_os(hw_os),                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
        .hw_mode_select(hw_mode_select),                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
        .hw_reset(hw_reset),                      /* RESET pin of the AD7606 chip */
        .hw_stby_n(hw_stby_n)                      /* STBY# pin of the AD7606 */

    );

	// User logic ends

endmodule
