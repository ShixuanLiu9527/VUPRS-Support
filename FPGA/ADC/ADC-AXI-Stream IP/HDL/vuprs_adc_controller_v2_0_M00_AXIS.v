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

	parameter integer C_M_START_COUNT	= 32,

	parameter integer C_M_AXIS_BUFFER_SIZE = 32

)
(
	// Users to add ports here
	
	output wire [(C_M_AXIS_TDATA_WIDTH / 8) - 1: 0] M_AXIS_TKEEP,
	output wire [CONTROL_REGISTER_WIDTH - 1: 0] error_flags,
	
	input wire [CONTROL_REGISTER_WIDTH - 1: 0] sampling_clk_increment,
	input wire [CONTROL_REGISTER_WIDTH - 1: 0] sampling_points,

	input wire          one_frame_sampling_trigger,              /* rising edge to trigger one sample */
	input wire          adc_clk,                                 /* clock for ADC, 100 MHz or 50 MHz */
	output wire         ready,
	input wire          rst_n,

	/* ADC-A hardware signals */
	
	input wire          adc_a_hw_busy,                       /* BUSY pin of the AD7606 chip */
    input wire          adc_a_hw_first_data,                 /* FIRSTDATA pin of the AD7606 chip */
    input wire [15: 0]  adc_a_hw_data,                       /* D0 - D15 Pins of the AD7606 chip */

    output wire         adc_a_hw_convst,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    output wire         adc_a_hw_rd,                         /* RD# pin of the AD7606 chip */
    output wire         adc_a_hw_cs,                         /* CS# pin of the AD7606 chip */
    output wire         adc_a_hw_range,                      /* RANGE pin of the AD7606 chip */
    output wire [2: 0]  adc_a_hw_os,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    output wire         adc_a_hw_mode_select,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    output wire         adc_a_hw_reset,                      /* RESET pin of the AD7606 chip */
    output wire         adc_a_hw_stby_n,                     /* STBY# pin of the AD7606 */

	input wire          adc_b_hw_busy,                       /* BUSY pin of the AD7606 chip */
    input wire          adc_b_hw_first_data,                 /* FIRSTDATA pin of the AD7606 chip */
    input wire [15: 0]  adc_b_hw_data,                       /* D0 - D15 Pins of the AD7606 chip */

	/* ADC-B hardware signals */

    output wire         adc_b_hw_convst,                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
    output wire         adc_b_hw_rd,                         /* RD# pin of the AD7606 chip */
    output wire         adc_b_hw_cs,                         /* CS# pin of the AD7606 chip */
    output wire         adc_b_hw_range,                      /* RANGE pin of the AD7606 chip */
    output wire [2: 0]  adc_b_hw_os,                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
    output wire         adc_b_hw_mode_select,                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
    output wire         adc_b_hw_reset,                      /* RESET pin of the AD7606 chip */
    output wire         adc_b_hw_stby_n,                     /* STBY# pin of the AD7606 */

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
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT);
	localparam integer BUFFER_POINTER_BITS = clogb2(C_M_AXIS_BUFFER_SIZE) + 1;
	                                                                                     
	// BIT_NUM gives the minimum number of bits needed to address 'depth' size of FIFO.  
	localparam BIT_NUM  = CONTROL_REGISTER_WIDTH + 1; 

	localparam FIFO_RESET_CLOCK_COUNT = 10;
	localparam FIFO_RESET_CLOCK_COUNT_2 = 65;
	localparam FIFO_RESET_WAIT_MAX_COUNT = 150;

	localparam BUFFER_RESET_CLOCK_COUNT = 3;
	                                                                                  
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

	localparam INVALID_BUFFER_POINTER             = C_M_AXIS_BUFFER_SIZE + 1;

	reg [1: 0] mst_exec_state;  // State variable
	
	reg [BIT_NUM - 1: 0] data_send_count;  // indicate the quantity of sended data, BIT_NUM

	// AXI Stream internal signals

	
	reg [WAIT_COUNT_BITS - 1: 0] init_count;  // wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	reg [WAIT_COUNT_BITS - 1: 0] fifo_reset_count;
	
	reg  							    axis_tvalid;  // streaming data valid
	reg  	                            axis_tlast;   // t_last
	reg [C_M_AXIS_TDATA_WIDTH - 1 : 0] 	axis_tdata;    // FIFO implementation signals

	reg module_ready;

	reg fifo_rd_en = FALSE;
	wire [C_M_AXIS_TDATA_WIDTH - 1: 0] current_fifo_read_data;

	reg [CONTROL_REGISTER_WIDTH - 1: 0] current_sampling_points;

	reg one_frame_sampling_trigger_sync1;
	reg one_frame_sampling_trigger_sync2;
	
	wire fifo_almost_full;
	wire fifo_full;
	wire fifo_empty;
	wire fifo_almost_empty;

	wire fifo_wr_rst_busy;
	wire fifo_rd_rst_busy;

	reg fifo_reset = LOW;

	reg [C_M_AXIS_TDATA_WIDTH - 1: 0] send_buffer[0: C_M_AXIS_BUFFER_SIZE - 1];
	reg [BUFFER_POINTER_BITS -1: 0] buffer_pointer;
	reg reset_buffer = FALSE;

	reg buffer_over_flow = FALSE;
	reg buffer_pointer_error = FALSE;
	
	wire [15: 0] adc_a_ch1;
	wire [15: 0] adc_a_ch2;
	wire [15: 0] adc_a_ch3;
	wire [15: 0] adc_a_ch4;
	wire [15: 0] adc_a_ch5;
	wire [15: 0] adc_a_ch6;
	wire [15: 0] adc_a_ch7;
	wire [15: 0] adc_a_ch8;

	wire [15: 0] adc_b_ch1;
	wire [15: 0] adc_b_ch2;
	wire [15: 0] adc_b_ch3;
	wire [15: 0] adc_b_ch4;
	wire [15: 0] adc_b_ch5;
	wire [15: 0] adc_b_ch6;
	wire [15: 0] adc_b_ch7;
	wire [15: 0] adc_b_ch8;
	
	wire adc_a_sampling;
	wire adc_a_ready;
	wire [3: 0] adc_a_err;

	wire adc_b_sampling;
	wire adc_b_ready;
	wire [3: 0] adc_b_err;

	/* User Registers end */

	// I/O Connections assignments

	assign M_AXIS_TVALID = (buffer_pointer != INVALID_BUFFER_POINTER);
	assign M_AXIS_TDATA	 = axis_tdata;
	assign M_AXIS_TLAST	 = axis_tlast;

	assign ready = module_ready;
	assign error_flags = {{(CONTROL_REGISTER_WIDTH - 8){1'b0}}, buffer_pointer_error, buffer_over_flow, adc_b_err[3: 0], adc_a_err[3: 0]};

	wire axis_hand_shake = M_AXIS_TVALID && M_AXIS_TREADY;

	`define ONE_VALID_DATA_SEND_AT_THAT_TIME (axis_hand_shake)

	/* --------------------------------------------------------------------------------------------------------- */
	/* ---------------------------------------- AXI-Stream CLOCK DOMAIN ---------------------------------------- */
	/* --------------------------------------------------------------------------------------------------------- */

	/* ---------------------------------------------- Buffer --------------------------------------------------- */

	integer i;

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN || reset_buffer || buffer_pointer_error) begin

			for (i = 0; i <= C_M_AXIS_BUFFER_SIZE - 1; i = i + 1) begin
				send_buffer[i] <= 0;
			end
			buffer_pointer <= INVALID_BUFFER_POINTER;

			buffer_over_flow <= FALSE;
			buffer_pointer_error <= FALSE;

		end else begin

			/* push buffer at first */

			if (buffer_pointer == INVALID_BUFFER_POINTER) begin  // t_valid = LOW at that moment

				if(!fifo_almost_empty) fifo_rd_en <= TRUE;
				else fifo_rd_en <= FALSE;

				if (fifo_rd_en) begin
					send_buffer[0] <= current_fifo_read_data;
					buffer_pointer <= 0;
				end else begin
					buffer_pointer <= buffer_pointer;
				end

			end 

			/* if buffer will be full, stop read */

			else if (buffer_pointer <= C_M_AXIS_BUFFER_SIZE - 1) begin

				if (fifo_rd_en) begin
					
					if (buffer_pointer >= C_M_AXIS_BUFFER_SIZE - 2) fifo_rd_en <= FALSE;  // stop read
					else begin
						if (!fifo_almost_empty) fifo_rd_en <= TRUE;  // continue read
						else fifo_rd_en <= FALSE;
					end


					for (i = 0; i <= C_M_AXIS_BUFFER_SIZE - 2; i = i + 1) begin
						send_buffer[i + 1] <= send_buffer[i];
					end
					send_buffer[0] <= current_fifo_read_data;
					
					if (!`ONE_VALID_DATA_SEND_AT_THAT_TIME) begin

						if (buffer_pointer <= C_M_AXIS_BUFFER_SIZE - 2) buffer_pointer <= buffer_pointer + 1;
						else buffer_over_flow <= TRUE;  // CRITICAL: BUFFER OVER FLOW !!!!!

					end else begin

						buffer_pointer <= buffer_pointer;  // do nothing for pointer

					end

				end else begin

					/* start read */

					if(!fifo_almost_empty) begin
						if (buffer_pointer == C_M_AXIS_BUFFER_SIZE - 1) fifo_rd_en <= FALSE;  // cannot read any more
						else fifo_rd_en <= TRUE;
					end
					else fifo_rd_en <= FALSE;

					if (!`ONE_VALID_DATA_SEND_AT_THAT_TIME) begin
						buffer_pointer <= buffer_pointer;  // do nothing for pointer
					end else begin
						if (buffer_pointer == 0) buffer_pointer <= INVALID_BUFFER_POINTER;
						else buffer_pointer <= buffer_pointer - 1;
					end

				end
			end

			else begin

				buffer_pointer_error <= TRUE;  // CRITICAL: BUFFER POINTER ERROR !!!!!

			end
		end
	end

	/* ------------------------------------------- Data Input -------------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			current_sampling_points <= CONTROL_REGISTER_WIDTH;
		end else begin
			if (mst_exec_state == EXEC_STATE__IDLE) begin
				current_sampling_points <= sampling_points;
			end
		end
	end

	/* ----------------------------------------- Detect rising edge --------------------------------------------- */

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			one_frame_sampling_trigger_sync1 <= LOW;
			one_frame_sampling_trigger_sync2 <= LOW;
		end else begin
			one_frame_sampling_trigger_sync1 <= one_frame_sampling_trigger;
			one_frame_sampling_trigger_sync2 <= one_frame_sampling_trigger_sync1;
		end
	end

	wire one_frame_sampling_trigger_rising_edge = one_frame_sampling_trigger_sync1 && (~one_frame_sampling_trigger_sync2);

	/* ---------------------------------------- System state --------------------------------------------------- */

	/* Flags */
	
	always @(posedge M_AXIS_ACLK) begin
	
		if (!M_AXIS_ARESETN) begin

			mst_exec_state <= EXEC_STATE__IDLE;
			init_count <= 0;
			fifo_reset_count <= 0;
			axis_tvalid <= LOW;

			module_ready <= TRUE;

			fifo_reset <= HIGH;  // start reset fifo
			reset_buffer <= TRUE;  // start reset buffer

		end else begin
			case (mst_exec_state)

				EXEC_STATE__IDLE: begin

					axis_tvalid <= LOW;

					if (one_frame_sampling_trigger_rising_edge) begin

						mst_exec_state <= EXEC_STATE__INIT_COUNTER;
						module_ready <= FALSE;

						init_count <= 0;
						fifo_reset_count <= 0;

						fifo_reset <= HIGH;  // start reset fifo
						reset_buffer <= TRUE;  // start reset buffer

					end else begin

						module_ready <= TRUE;

					end
				end

				EXEC_STATE__INIT_COUNTER: begin  // reset fifo

					axis_tvalid <= LOW;

					if (init_count >= FIFO_RESET_CLOCK_COUNT + 1) begin

						fifo_reset_count <= fifo_reset_count + 1;

						if (((!fifo_wr_rst_busy && !fifo_rd_rst_busy) && buffer_pointer == INVALID_BUFFER_POINTER && fifo_reset_count >= FIFO_RESET_CLOCK_COUNT_2) || 
							fifo_reset_count >= FIFO_RESET_WAIT_MAX_COUNT) begin 
							mst_exec_state <= EXEC_STATE__SEND_STREAM;  // reset fifo
						end

					end else begin

						init_count <= init_count + 1;

						if (init_count >= BUFFER_RESET_CLOCK_COUNT) reset_buffer <= FALSE;
						else if (init_count >= FIFO_RESET_CLOCK_COUNT) fifo_reset <= LOW;  // detect full & empty
						else fifo_reset_count <= 0;  // to 0
						
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

	assign M_AXIS_TSTRB	 = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	assign M_AXIS_TKEEP  = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

	always @(posedge M_AXIS_ACLK) begin
	
		if (!M_AXIS_ARESETN) begin

			data_send_count <= 0;
			axis_tdata <= INVALID_DATA;
			axis_tlast <= LOW;
			
		end else begin

			if (buffer_pointer != INVALID_BUFFER_POINTER) axis_tdata <= send_buffer[buffer_pointer];
			else axis_tdata <= INVALID_DATA;

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

	/* --------------------------------------------------------------------------------------------------------- */
	/* -------------------------------------------- ADC CLOCK DOMAIN ------------------------------------------- */
	/* --------------------------------------------------------------------------------------------------------- */

	reg [BIT_NUM - 1: 0] sampling_clk_counter;
	reg sampling_clk = LOW;

	reg sampling_clk_increment_sync;
	reg mst_exec_state_sync;

	/* FIFO write logic registers  */
	
	reg [2: 0] fifo_write_state = FIFO_WRITE_STATE__IDLE;
	
	reg [3: 0] fifo_pushed_number = 4'd0;
	reg [C_M_AXIS_TDATA_WIDTH - 1: 0] current_fifo_write_data = INVALID_DATA;
	
	reg fifo_write_en = 1'b0;
	reg adc_data_have_pushed = 1'b0;

	/* sync 1 */

	always @(posedge adc_clk) begin
		if (!rst_n) sampling_clk_increment_sync <= 0;
		else if (mst_exec_state_sync == EXEC_STATE__IDLE) sampling_clk_increment_sync <= sampling_clk_increment;
	end

	/* sync 2 */

	always @(posedge adc_clk) begin
		if (!rst_n) mst_exec_state_sync <= EXEC_STATE__IDLE;
		else mst_exec_state_sync <= mst_exec_state;
	end

	/* ---------------------------------------- AD sampling clock ---------------------------------------------- */

	always @(posedge adc_clk) begin
		if (!rst_n) begin
			sampling_clk_counter <= 0;
			sampling_clk <= LOW;
		end else begin

			/* Generate sample clock at SEND STREAM state */

			if (mst_exec_state_sync == EXEC_STATE__SEND_STREAM) begin
				if (sampling_clk_counter >= sampling_clk_increment_sync - 1) begin
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

	/* Flags */

	`define ONE_VALID_DATA_PUSHED_IN_FIFO (fifo_write_en && !fifo_full)

	always @(posedge adc_clk) begin

	   	if (!rst_n) begin

	        fifo_write_state <= FIFO_WRITE_STATE__IDLE;
			adc_data_have_pushed <= FALSE;
	        
	    end else begin

			case (fifo_write_state)

			FIFO_WRITE_STATE__IDLE: begin
			
				if (!adc_a_sampling && !adc_b_sampling) begin  // sampling complete

					if (!adc_data_have_pushed) fifo_write_state <= FIFO_WRITE_STATE__WRITE_FIFO;  // write the adc data to FIFO
					else fifo_write_state <= FIFO_WRITE_STATE__IDLE;

				end else begin // sampling not complete, update adc_data_have_pushed flag

					fifo_write_state <= FIFO_WRITE_STATE__IDLE;
					adc_data_have_pushed <= FALSE;

				end

			end

			FIFO_WRITE_STATE__WRITE_FIFO: begin
				
				if (fifo_pushed_number >= 4'd7 && `ONE_VALID_DATA_PUSHED_IN_FIFO) begin

					fifo_write_state <= FIFO_WRITE_STATE__IDLE;
					adc_data_have_pushed <= TRUE;

				end

			end
			
			default: fifo_write_state <= FIFO_WRITE_STATE__IDLE;

			endcase
				
		end
	end

	/* Registers */

	always @(posedge adc_clk) begin
	   	if (!rst_n) begin

	        fifo_write_en <= FALSE;
			current_fifo_write_data <= {(C_M_AXIS_TDATA_WIDTH){1'b1}};
			fifo_pushed_number <= 0;

	    end else begin
	       
	       	case(fifo_write_state)
	       
	           	FIFO_WRITE_STATE__IDLE: begin

	                fifo_pushed_number <= 0;
					fifo_write_en <= FALSE;

					if (!adc_a_sampling && !adc_b_sampling && !adc_data_have_pushed) begin  // state jump situation

						current_fifo_write_data <= {adc_a_ch2, adc_a_ch1};

						if (fifo_almost_full) fifo_write_en <= FALSE;
						else fifo_write_en <= TRUE;

					end else begin

						current_fifo_write_data <= {(C_M_AXIS_TDATA_WIDTH){1'b1}};

					end

	            end
	               
	           	FIFO_WRITE_STATE__WRITE_FIFO: begin

					if (fifo_write_en) begin

						if (`ONE_VALID_DATA_PUSHED_IN_FIFO) begin

							fifo_pushed_number <= fifo_pushed_number + 1;  // push one data

							case (fifo_pushed_number)
								4'd0: begin
									current_fifo_write_data <= {adc_a_ch4, adc_a_ch3};

									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd1: begin
									current_fifo_write_data <= {adc_a_ch6, adc_a_ch5};

									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd2: begin
									current_fifo_write_data <= {adc_a_ch8, adc_a_ch7};

									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd3: begin
									current_fifo_write_data <= {adc_b_ch2, adc_b_ch1};

									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd4: begin
									current_fifo_write_data <= {adc_b_ch4, adc_b_ch3};

									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd5: begin
									current_fifo_write_data <= {adc_b_ch6, adc_b_ch5};

									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd6: begin
									current_fifo_write_data <= {adc_b_ch8, adc_b_ch7};
									
									if (fifo_almost_full) fifo_write_en <= FALSE;  // last data of the fifo pushed at that time
									else fifo_write_en <= TRUE;
								end
								4'd7: begin  // all data have pushed, state jump
									fifo_write_en <= FALSE;
									current_fifo_write_data <= {(C_M_AXIS_TDATA_WIDTH){1'b1}};
								end
								default: current_fifo_write_data <= {(C_M_AXIS_TDATA_WIDTH){1'b1}};
							endcase
						end
									
					end else begin

						if (fifo_almost_full) fifo_write_en <= FALSE;  // the last data pushed at that time
						else fifo_write_en <= TRUE;

					end

	            end
	              
	       	endcase
	    end
	end

	adc_fifo vuprs_adc_fifo (
  		.rst(fifo_reset),                    // input wire rst
  		.wr_clk(adc_clk),              // input wire wr_clk
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
    vuprs_adc_a(

        /* -------------------------------------------- User interface ------------------------------------------ */

        .usr_trigger(sampling_clk),                   /* Sample Enable, rising edge trigger, must be smaller than 100 kHz */
        .usr_clk(adc_clk),                       /* System Clock, corresponding to USR_CLK_CYCLE_NS  */
        .usr_rst(rst_n),                       /* Reset this module, falling edge trigger */

        .usr_channel1(adc_a_ch1),                  /* Data of channel-V1, 16 bit */
        .usr_channel2(adc_a_ch2),                  /* Data of channel-V2, 16 bit */
        .usr_channel3(adc_a_ch3),                  /* Data of channel-V3, 16 bit */
        .usr_channel4(adc_a_ch4),                  /* Data of channel-V4, 16 bit */
        .usr_channel5(adc_a_ch5),                  /* Data of channel-V5, 16 bit */
        .usr_channel6(adc_a_ch6),                  /* Data of channel-V6, 16 bit */
        .usr_channel7(adc_a_ch7),                  /* Data of channel-V7, 16 bit */
        .usr_channel8(adc_a_ch8),                  /* Data of channel-V8, 16 bit */

        .usr_error(adc_a_err),                     /* Error flags */

        .usr_sampling(adc_a_sampling),                  /* sampling,      1 = in sampling (do not trigger); 0 = is idle */
        .usr_ready(adc_a_ready),                     /* Reset Down,    1 = complete to create a HIGH pulse for hardware RESET pin */

        /* ------------------------------------------ Hardware interface ---------------------------------------- */

        .hw_busy(adc_a_hw_busy),                       /* BUSY pin of the AD7606 chip */
        .hw_first_data(adc_a_hw_first_data),                 /* FIRSTDATA pin of the AD7606 chip  */
        .hw_data(adc_a_hw_data),                       /* D0 - D15 Pins of the AD7606 chip */

        .hw_convst(adc_a_hw_convst),                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
        .hw_rd(adc_a_hw_rd),                         /* RD# pin of the AD7606 chip */
        .hw_cs(adc_a_hw_cs),                         /* CS# pin of the AD7606 chip */
        .hw_range(adc_a_hw_range),                      /* RANGE pin of the AD7606 chip */
        .hw_os(adc_a_hw_os),                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
        .hw_mode_select(adc_a_hw_mode_select),                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
        .hw_reset(adc_a_hw_reset),                      /* RESET pin of the AD7606 chip */
        .hw_stby_n(adc_a_hw_stby_n)                      /* STBY# pin of the AD7606 */

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
    vuprs_adc_b(

        /* -------------------------------------------- User interface ------------------------------------------ */

        .usr_trigger(sampling_clk),                   /* Sample Enable, rising edge trigger, must be smaller than 100 kHz */
        .usr_clk(adc_clk),                       /* System Clock, corresponding to USR_CLK_CYCLE_NS  */
        .usr_rst(rst_n),                       /* Reset this module, falling edge trigger */

        .usr_channel1(adc_b_ch1),                  /* Data of channel-V1, 16 bit */
        .usr_channel2(adc_b_ch2),                  /* Data of channel-V2, 16 bit */
        .usr_channel3(adc_b_ch3),                  /* Data of channel-V3, 16 bit */
        .usr_channel4(adc_b_ch4),                  /* Data of channel-V4, 16 bit */
        .usr_channel5(adc_b_ch5),                  /* Data of channel-V5, 16 bit */
        .usr_channel6(adc_b_ch6),                  /* Data of channel-V6, 16 bit */
        .usr_channel7(adc_b_ch7),                  /* Data of channel-V7, 16 bit */
        .usr_channel8(adc_b_ch8),                  /* Data of channel-V8, 16 bit */

        .usr_error(adc_b_err),                     /* Error flags */

        .usr_sampling(adc_b_sampling),                  /* sampling,      1 = in sampling (do not trigger); 0 = is idle */
        .usr_ready(adc_b_ready),                     /* Reset Down,    1 = complete to create a HIGH pulse for hardware RESET pin */

        /* ------------------------------------------ Hardware interface ---------------------------------------- */

        .hw_busy(adc_b_hw_busy),                       /* BUSY pin of the AD7606 chip */
        .hw_first_data(adc_b_hw_first_data),                 /* FIRSTDATA pin of the AD7606 chip  */
        .hw_data(adc_b_hw_data),                       /* D0 - D15 Pins of the AD7606 chip */

        .hw_convst(adc_b_hw_convst),                     /* CONVST pin of the AD7606 chip (CONVRST_A and CONVRST_B are connected together) */
        .hw_rd(adc_b_hw_rd),                         /* RD# pin of the AD7606 chip */
        .hw_cs(adc_b_hw_cs),                         /* CS# pin of the AD7606 chip */
        .hw_range(adc_b_hw_range),                      /* RANGE pin of the AD7606 chip */
        .hw_os(adc_b_hw_os),                         /* OS0 - OS2 pins of the AD7606 chip (Not used) */
        .hw_mode_select(adc_b_hw_mode_select),                /* PAR#/SER/BYTE_SEL pin of the AD7606 chip */
        .hw_reset(adc_b_hw_reset),                      /* RESET pin of the AD7606 chip */
        .hw_stby_n(adc_b_hw_stby_n)                      /* STBY# pin of the AD7606 */

     );

	// User logic ends

endmodule
