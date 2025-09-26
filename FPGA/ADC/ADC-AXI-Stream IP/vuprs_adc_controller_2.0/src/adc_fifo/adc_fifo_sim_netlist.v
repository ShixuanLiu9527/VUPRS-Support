// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Wed Sep 24 15:46:38 2025
// Host        : LSXxiaoxinPro14 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/11827/Desktop/VUPRS_FPGA/vuprs_ip_repo/vuprs_adc_controller_2.0/src/adc_fifo/adc_fifo_sim_netlist.v
// Design      : adc_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tfgg484-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "adc_fifo,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module adc_fifo
   (rst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    almost_full,
    empty,
    almost_empty,
    wr_rst_busy,
    rd_rst_busy);
  input rst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input rd_clk;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [31:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [31:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE ALMOST_FULL" *) output almost_full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ ALMOST_EMPTY" *) output almost_empty;
  output wr_rst_busy;
  output rd_rst_busy;

  wire almost_empty;
  wire almost_full;
  wire [31:0]din;
  wire [31:0]dout;
  wire empty;
  wire full;
  wire rd_clk;
  wire rd_en;
  wire rd_rst_busy;
  wire rst;
  wire wr_clk;
  wire wr_en;
  wire wr_rst_busy;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [9:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [9:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "10" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "32" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "32" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "1" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_FULL_FLAGS_RST_VAL = "1" *) 
  (* C_HAS_ALMOST_EMPTY = "1" *) 
  (* C_HAS_ALMOST_FULL = "1" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "1" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "2" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "2" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "2" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "2" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "1" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "2" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "3" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1021" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1020" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "10" *) 
  (* C_RD_DEPTH = "1024" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "10" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "10" *) 
  (* C_WR_DEPTH = "1024" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "10" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  adc_fifo_fifo_generator_v13_2_5 U0
       (.almost_empty(almost_empty),
        .almost_full(almost_full),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[9:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[9:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(rd_rst_busy),
        .rst(rst),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(wr_clk),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[9:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(wr_rst_busy));
endmodule

(* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_gray" *) 
(* REG_OUTPUT = "1" *) (* SIM_ASSERT_CHK = "0" *) (* SIM_LOSSLESS_GRAY_CHK = "0" *) 
(* VERSION = "0" *) (* WIDTH = "10" *) (* XPM_MODULE = "TRUE" *) 
(* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) (* xpm_cdc = "GRAY" *) 
module adc_fifo_xpm_cdc_gray
   (src_clk,
    src_in_bin,
    dest_clk,
    dest_out_bin);
  input src_clk;
  input [9:0]src_in_bin;
  input dest_clk;
  output [9:0]dest_out_bin;

  wire [9:0]async_path;
  wire [8:0]binval;
  wire dest_clk;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [9:0]\dest_graysync_ff[0] ;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [9:0]\dest_graysync_ff[1] ;
  wire [9:0]dest_out_bin;
  wire [8:0]gray_enc;
  wire src_clk;
  wire [9:0]src_in_bin;

  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[0]),
        .Q(\dest_graysync_ff[0] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[1]),
        .Q(\dest_graysync_ff[0] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[2]),
        .Q(\dest_graysync_ff[0] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[3]),
        .Q(\dest_graysync_ff[0] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[4]),
        .Q(\dest_graysync_ff[0] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[5]),
        .Q(\dest_graysync_ff[0] [5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][6] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[6]),
        .Q(\dest_graysync_ff[0] [6]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][7] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[7]),
        .Q(\dest_graysync_ff[0] [7]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][8] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[8]),
        .Q(\dest_graysync_ff[0] [8]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][9] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[9]),
        .Q(\dest_graysync_ff[0] [9]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [0]),
        .Q(\dest_graysync_ff[1] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [1]),
        .Q(\dest_graysync_ff[1] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [2]),
        .Q(\dest_graysync_ff[1] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [3]),
        .Q(\dest_graysync_ff[1] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [4]),
        .Q(\dest_graysync_ff[1] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [5]),
        .Q(\dest_graysync_ff[1] [5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][6] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [6]),
        .Q(\dest_graysync_ff[1] [6]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][7] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [7]),
        .Q(\dest_graysync_ff[1] [7]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][8] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [8]),
        .Q(\dest_graysync_ff[1] [8]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][9] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [9]),
        .Q(\dest_graysync_ff[1] [9]),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h96696996)) 
    \dest_out_bin_ff[0]_i_1 
       (.I0(\dest_graysync_ff[1] [0]),
        .I1(\dest_graysync_ff[1] [2]),
        .I2(binval[4]),
        .I3(\dest_graysync_ff[1] [3]),
        .I4(\dest_graysync_ff[1] [1]),
        .O(binval[0]));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[1]_i_1 
       (.I0(\dest_graysync_ff[1] [1]),
        .I1(\dest_graysync_ff[1] [3]),
        .I2(binval[4]),
        .I3(\dest_graysync_ff[1] [2]),
        .O(binval[1]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[2]_i_1 
       (.I0(\dest_graysync_ff[1] [2]),
        .I1(binval[4]),
        .I2(\dest_graysync_ff[1] [3]),
        .O(binval[2]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[3]_i_1 
       (.I0(\dest_graysync_ff[1] [3]),
        .I1(binval[4]),
        .O(binval[3]));
  LUT6 #(
    .INIT(64'h6996966996696996)) 
    \dest_out_bin_ff[4]_i_1 
       (.I0(\dest_graysync_ff[1] [4]),
        .I1(\dest_graysync_ff[1] [6]),
        .I2(\dest_graysync_ff[1] [8]),
        .I3(\dest_graysync_ff[1] [9]),
        .I4(\dest_graysync_ff[1] [7]),
        .I5(\dest_graysync_ff[1] [5]),
        .O(binval[4]));
  LUT5 #(
    .INIT(32'h96696996)) 
    \dest_out_bin_ff[5]_i_1 
       (.I0(\dest_graysync_ff[1] [5]),
        .I1(\dest_graysync_ff[1] [7]),
        .I2(\dest_graysync_ff[1] [9]),
        .I3(\dest_graysync_ff[1] [8]),
        .I4(\dest_graysync_ff[1] [6]),
        .O(binval[5]));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[6]_i_1 
       (.I0(\dest_graysync_ff[1] [6]),
        .I1(\dest_graysync_ff[1] [8]),
        .I2(\dest_graysync_ff[1] [9]),
        .I3(\dest_graysync_ff[1] [7]),
        .O(binval[6]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[7]_i_1 
       (.I0(\dest_graysync_ff[1] [7]),
        .I1(\dest_graysync_ff[1] [9]),
        .I2(\dest_graysync_ff[1] [8]),
        .O(binval[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[8]_i_1 
       (.I0(\dest_graysync_ff[1] [8]),
        .I1(\dest_graysync_ff[1] [9]),
        .O(binval[8]));
  FDRE \dest_out_bin_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[0]),
        .Q(dest_out_bin[0]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[1]),
        .Q(dest_out_bin[1]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[2]),
        .Q(dest_out_bin[2]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[3]),
        .Q(dest_out_bin[3]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[4]),
        .Q(dest_out_bin[4]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[5]),
        .Q(dest_out_bin[5]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[6] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[6]),
        .Q(dest_out_bin[6]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[7] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[7]),
        .Q(dest_out_bin[7]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[8] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[8]),
        .Q(dest_out_bin[8]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[9] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[1] [9]),
        .Q(dest_out_bin[9]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[0]_i_1 
       (.I0(src_in_bin[1]),
        .I1(src_in_bin[0]),
        .O(gray_enc[0]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[1]_i_1 
       (.I0(src_in_bin[2]),
        .I1(src_in_bin[1]),
        .O(gray_enc[1]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[2]_i_1 
       (.I0(src_in_bin[3]),
        .I1(src_in_bin[2]),
        .O(gray_enc[2]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[3]_i_1 
       (.I0(src_in_bin[4]),
        .I1(src_in_bin[3]),
        .O(gray_enc[3]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[4]_i_1 
       (.I0(src_in_bin[5]),
        .I1(src_in_bin[4]),
        .O(gray_enc[4]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[5]_i_1 
       (.I0(src_in_bin[6]),
        .I1(src_in_bin[5]),
        .O(gray_enc[5]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[6]_i_1 
       (.I0(src_in_bin[7]),
        .I1(src_in_bin[6]),
        .O(gray_enc[6]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[7]_i_1 
       (.I0(src_in_bin[8]),
        .I1(src_in_bin[7]),
        .O(gray_enc[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[8]_i_1 
       (.I0(src_in_bin[9]),
        .I1(src_in_bin[8]),
        .O(gray_enc[8]));
  FDRE \src_gray_ff_reg[0] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[0]),
        .Q(async_path[0]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[1] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[1]),
        .Q(async_path[1]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[2] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[2]),
        .Q(async_path[2]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[3] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[3]),
        .Q(async_path[3]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[4] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[4]),
        .Q(async_path[4]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[5] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[5]),
        .Q(async_path[5]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[6] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[6]),
        .Q(async_path[6]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[7] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[7]),
        .Q(async_path[7]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[8] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[8]),
        .Q(async_path[8]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[9] 
       (.C(src_clk),
        .CE(1'b1),
        .D(src_in_bin[9]),
        .Q(async_path[9]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_gray" *) 
(* REG_OUTPUT = "1" *) (* SIM_ASSERT_CHK = "0" *) (* SIM_LOSSLESS_GRAY_CHK = "0" *) 
(* VERSION = "0" *) (* WIDTH = "10" *) (* XPM_MODULE = "TRUE" *) 
(* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) (* xpm_cdc = "GRAY" *) 
module adc_fifo_xpm_cdc_gray__2
   (src_clk,
    src_in_bin,
    dest_clk,
    dest_out_bin);
  input src_clk;
  input [9:0]src_in_bin;
  input dest_clk;
  output [9:0]dest_out_bin;

  wire [9:0]async_path;
  wire [8:0]binval;
  wire dest_clk;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [9:0]\dest_graysync_ff[0] ;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "GRAY" *) wire [9:0]\dest_graysync_ff[1] ;
  wire [9:0]dest_out_bin;
  wire [8:0]gray_enc;
  wire src_clk;
  wire [9:0]src_in_bin;

  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[0]),
        .Q(\dest_graysync_ff[0] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[1]),
        .Q(\dest_graysync_ff[0] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[2]),
        .Q(\dest_graysync_ff[0] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[3]),
        .Q(\dest_graysync_ff[0] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[4]),
        .Q(\dest_graysync_ff[0] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[5]),
        .Q(\dest_graysync_ff[0] [5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][6] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[6]),
        .Q(\dest_graysync_ff[0] [6]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][7] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[7]),
        .Q(\dest_graysync_ff[0] [7]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][8] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[8]),
        .Q(\dest_graysync_ff[0] [8]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[0][9] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(async_path[9]),
        .Q(\dest_graysync_ff[0] [9]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [0]),
        .Q(\dest_graysync_ff[1] [0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [1]),
        .Q(\dest_graysync_ff[1] [1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [2]),
        .Q(\dest_graysync_ff[1] [2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [3]),
        .Q(\dest_graysync_ff[1] [3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [4]),
        .Q(\dest_graysync_ff[1] [4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [5]),
        .Q(\dest_graysync_ff[1] [5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][6] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [6]),
        .Q(\dest_graysync_ff[1] [6]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][7] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [7]),
        .Q(\dest_graysync_ff[1] [7]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][8] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [8]),
        .Q(\dest_graysync_ff[1] [8]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "GRAY" *) 
  FDRE \dest_graysync_ff_reg[1][9] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[0] [9]),
        .Q(\dest_graysync_ff[1] [9]),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h96696996)) 
    \dest_out_bin_ff[0]_i_1 
       (.I0(\dest_graysync_ff[1] [0]),
        .I1(\dest_graysync_ff[1] [2]),
        .I2(binval[4]),
        .I3(\dest_graysync_ff[1] [3]),
        .I4(\dest_graysync_ff[1] [1]),
        .O(binval[0]));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[1]_i_1 
       (.I0(\dest_graysync_ff[1] [1]),
        .I1(\dest_graysync_ff[1] [3]),
        .I2(binval[4]),
        .I3(\dest_graysync_ff[1] [2]),
        .O(binval[1]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[2]_i_1 
       (.I0(\dest_graysync_ff[1] [2]),
        .I1(binval[4]),
        .I2(\dest_graysync_ff[1] [3]),
        .O(binval[2]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[3]_i_1 
       (.I0(\dest_graysync_ff[1] [3]),
        .I1(binval[4]),
        .O(binval[3]));
  LUT6 #(
    .INIT(64'h6996966996696996)) 
    \dest_out_bin_ff[4]_i_1 
       (.I0(\dest_graysync_ff[1] [4]),
        .I1(\dest_graysync_ff[1] [6]),
        .I2(\dest_graysync_ff[1] [8]),
        .I3(\dest_graysync_ff[1] [9]),
        .I4(\dest_graysync_ff[1] [7]),
        .I5(\dest_graysync_ff[1] [5]),
        .O(binval[4]));
  LUT5 #(
    .INIT(32'h96696996)) 
    \dest_out_bin_ff[5]_i_1 
       (.I0(\dest_graysync_ff[1] [5]),
        .I1(\dest_graysync_ff[1] [7]),
        .I2(\dest_graysync_ff[1] [9]),
        .I3(\dest_graysync_ff[1] [8]),
        .I4(\dest_graysync_ff[1] [6]),
        .O(binval[5]));
  LUT4 #(
    .INIT(16'h6996)) 
    \dest_out_bin_ff[6]_i_1 
       (.I0(\dest_graysync_ff[1] [6]),
        .I1(\dest_graysync_ff[1] [8]),
        .I2(\dest_graysync_ff[1] [9]),
        .I3(\dest_graysync_ff[1] [7]),
        .O(binval[6]));
  LUT3 #(
    .INIT(8'h96)) 
    \dest_out_bin_ff[7]_i_1 
       (.I0(\dest_graysync_ff[1] [7]),
        .I1(\dest_graysync_ff[1] [9]),
        .I2(\dest_graysync_ff[1] [8]),
        .O(binval[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \dest_out_bin_ff[8]_i_1 
       (.I0(\dest_graysync_ff[1] [8]),
        .I1(\dest_graysync_ff[1] [9]),
        .O(binval[8]));
  FDRE \dest_out_bin_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[0]),
        .Q(dest_out_bin[0]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[1]),
        .Q(dest_out_bin[1]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[2]),
        .Q(dest_out_bin[2]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[3]),
        .Q(dest_out_bin[3]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[4]),
        .Q(dest_out_bin[4]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[5] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[5]),
        .Q(dest_out_bin[5]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[6] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[6]),
        .Q(dest_out_bin[6]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[7] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[7]),
        .Q(dest_out_bin[7]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[8] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(binval[8]),
        .Q(dest_out_bin[8]),
        .R(1'b0));
  FDRE \dest_out_bin_ff_reg[9] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(\dest_graysync_ff[1] [9]),
        .Q(dest_out_bin[9]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[0]_i_1 
       (.I0(src_in_bin[1]),
        .I1(src_in_bin[0]),
        .O(gray_enc[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[1]_i_1 
       (.I0(src_in_bin[2]),
        .I1(src_in_bin[1]),
        .O(gray_enc[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[2]_i_1 
       (.I0(src_in_bin[3]),
        .I1(src_in_bin[2]),
        .O(gray_enc[2]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[3]_i_1 
       (.I0(src_in_bin[4]),
        .I1(src_in_bin[3]),
        .O(gray_enc[3]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[4]_i_1 
       (.I0(src_in_bin[5]),
        .I1(src_in_bin[4]),
        .O(gray_enc[4]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[5]_i_1 
       (.I0(src_in_bin[6]),
        .I1(src_in_bin[5]),
        .O(gray_enc[5]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[6]_i_1 
       (.I0(src_in_bin[7]),
        .I1(src_in_bin[6]),
        .O(gray_enc[6]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[7]_i_1 
       (.I0(src_in_bin[8]),
        .I1(src_in_bin[7]),
        .O(gray_enc[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \src_gray_ff[8]_i_1 
       (.I0(src_in_bin[9]),
        .I1(src_in_bin[8]),
        .O(gray_enc[8]));
  FDRE \src_gray_ff_reg[0] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[0]),
        .Q(async_path[0]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[1] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[1]),
        .Q(async_path[1]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[2] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[2]),
        .Q(async_path[2]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[3] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[3]),
        .Q(async_path[3]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[4] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[4]),
        .Q(async_path[4]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[5] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[5]),
        .Q(async_path[5]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[6] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[6]),
        .Q(async_path[6]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[7] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[7]),
        .Q(async_path[7]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[8] 
       (.C(src_clk),
        .CE(1'b1),
        .D(gray_enc[8]),
        .Q(async_path[8]),
        .R(1'b0));
  FDRE \src_gray_ff_reg[9] 
       (.C(src_clk),
        .CE(1'b1),
        .D(src_in_bin[9]),
        .Q(async_path[9]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "5" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_single" *) 
(* SIM_ASSERT_CHK = "0" *) (* SRC_INPUT_REG = "0" *) (* VERSION = "0" *) 
(* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) 
(* xpm_cdc = "SINGLE" *) 
module adc_fifo_xpm_cdc_single
   (src_clk,
    src_in,
    dest_clk,
    dest_out);
  input src_clk;
  input src_in;
  input dest_clk;
  output dest_out;

  wire dest_clk;
  wire src_in;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "SINGLE" *) wire [4:0]syncstages_ff;

  assign dest_out = syncstages_ff[4];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(src_in),
        .Q(syncstages_ff[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[0]),
        .Q(syncstages_ff[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[1]),
        .Q(syncstages_ff[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[2]),
        .Q(syncstages_ff[3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[3]),
        .Q(syncstages_ff[4]),
        .R(1'b0));
endmodule

(* DEST_SYNC_FF = "5" *) (* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_single" *) 
(* SIM_ASSERT_CHK = "0" *) (* SRC_INPUT_REG = "0" *) (* VERSION = "0" *) 
(* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) 
(* xpm_cdc = "SINGLE" *) 
module adc_fifo_xpm_cdc_single__2
   (src_clk,
    src_in,
    dest_clk,
    dest_out);
  input src_clk;
  input src_in;
  input dest_clk;
  output dest_out;

  wire dest_clk;
  wire src_in;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "SINGLE" *) wire [4:0]syncstages_ff;

  assign dest_out = syncstages_ff[4];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(src_in),
        .Q(syncstages_ff[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[0]),
        .Q(syncstages_ff[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[1]),
        .Q(syncstages_ff[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[2]),
        .Q(syncstages_ff[3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SINGLE" *) 
  FDRE \syncstages_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[3]),
        .Q(syncstages_ff[4]),
        .R(1'b0));
endmodule

(* DEF_VAL = "1'b1" *) (* DEST_SYNC_FF = "5" *) (* INIT = "1" *) 
(* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_sync_rst" *) (* SIM_ASSERT_CHK = "0" *) 
(* VERSION = "0" *) (* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) 
(* keep_hierarchy = "true" *) (* xpm_cdc = "SYNC_RST" *) 
module adc_fifo_xpm_cdc_sync_rst
   (src_rst,
    dest_clk,
    dest_rst);
  input src_rst;
  input dest_clk;
  output dest_rst;

  wire dest_clk;
  wire src_rst;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "SYNC_RST" *) wire [4:0]syncstages_ff;

  assign dest_rst = syncstages_ff[4];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(src_rst),
        .Q(syncstages_ff[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[0]),
        .Q(syncstages_ff[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[1]),
        .Q(syncstages_ff[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[2]),
        .Q(syncstages_ff[3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[3]),
        .Q(syncstages_ff[4]),
        .R(1'b0));
endmodule

(* DEF_VAL = "1'b1" *) (* DEST_SYNC_FF = "5" *) (* INIT = "1" *) 
(* INIT_SYNC_FF = "0" *) (* ORIG_REF_NAME = "xpm_cdc_sync_rst" *) (* SIM_ASSERT_CHK = "0" *) 
(* VERSION = "0" *) (* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) 
(* keep_hierarchy = "true" *) (* xpm_cdc = "SYNC_RST" *) 
module adc_fifo_xpm_cdc_sync_rst__2
   (src_rst,
    dest_clk,
    dest_rst);
  input src_rst;
  input dest_clk;
  output dest_rst;

  wire dest_clk;
  wire src_rst;
  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "SYNC_RST" *) wire [4:0]syncstages_ff;

  assign dest_rst = syncstages_ff[4];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(src_rst),
        .Q(syncstages_ff[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[0]),
        .Q(syncstages_ff[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[2] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[1]),
        .Q(syncstages_ff[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[3] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[2]),
        .Q(syncstages_ff[3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "SYNC_RST" *) 
  FDRE #(
    .INIT(1'b1)) 
    \syncstages_ff_reg[4] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(syncstages_ff[3]),
        .Q(syncstages_ff[4]),
        .R(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2020.2"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
QGLtnqZzRetDH6gCWT4Js6wuLlZfrNx/VJp3sfR2NF+cxypO5AxN0oDKLJJtmdrtE/ueNDg+Qf7Z
TqBNRojORA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
B6Ger3hRvfjHkaJ+W8639Kl3TzC9TogLuklOXEiMNdc4Im+DjEUzxb3DKlzu0VW3zxZqjJ3+wsW/
LnRmPCESi5Y9eRJaLFXg79EMfoj4X+nTdHAP6yCfltBADKegZ12gpnB/8ey5yn2KA74LUtPC7jna
iyjqSfsWLGnz6UdXzwk=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BX+DxgMPRyZbYojCUR9Sk8Lq+3ZigBz4yMFHQkmurfdfDzyTPJCE827eGiPyTenK1QPVhEtf9g06
0BFXq/0COPuU1BWJwdkz1c4dE6/exDwhvEh+hPx3vRY6z8fDEf6aGVIXrHDvrmddehe7yMSIpo+k
aXHR06EEdfHCFY4TggYwhcJVXjkE+ApsVuyfmEfPmYjo8hCWyQyBsUWIOY03q1+MvUjjsmTwgs9g
fh5MY9ToaLfoJxPKdCpsqrBX4LJ+VDGFlAqIcqHTE2jCmPiToZAFXB7fzf1wDjFCBlJyFVDBGi0i
m+CouLSb7X1mvVhdDZgNrZDJMV688Bu3o54vew==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DaIU/Ddc8USbZ2mURzujJDWDH1JbHl5tFVOOQ2aVaUPIA71yyE38OXVLEtF8rNmujYH30nEeQ+FV
LVJ16aaHw+iiuaqorTM3K5KLohVlN+WlcEtSXHuPNHjw8ddqtzpaX7pH1zqZH+YmfCL5oaNLqDH4
rkBnUl0/Gm/hzSwKjYhXGQFYQ+gGP99OjXakzrAqZzp/Iq4gt+Z5902/JV9thd/isHQImJ0QyK8M
EKM579iPAfXGes2mbiNYHcvDmSPYmW1zlhOE++N1EKeea7j/msnKeyhlC+hGE4Xfn4TVvqgQexCT
rp/wS/MosY6WH1aKFQlFH2hEppA7KXUaQlvG+w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
XmWoAt4X8hrCJ5yTyug4ajJW5UhfkLNibzjihWzZ4Cr9hQSvWZoTc8rjGsLPbz6Le+/9iI5KxecS
eR0wiAO+G2IkwhZgVBeZdKoFnlnTVAyLjk9wMAFXNyJZM6b1NDbfXlPcUsC6JePvPlwwdWknkSsC
r3KvgkWAS+O3xvRmaNw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hw3Y+rShKrXiUViyNU1/O2qv6TgheLHBnFMj1i9MUGrHYqh9pLfLYUgWR7S2vj4jv4S+Ks0BpP4p
dKEqVAFmTCfQNEUHaVcFPkOHgig6L4mhLY6HUUKJoRgiQepgLi/W3V+ZZPQSQFkB3CU4MsJzhXvR
yLcpDriZy8cnAHD87Zi5DrNGBzj3kigJeM0du6lCQbxtF5aEdoaNP+YTnIFtcqYhoYnswQlYt0sV
HKgFA8VzqzL5WYnpH7+1IKmFkJBHkyqHCa9wPK0qCKnxkuDj70YzPVqQ+cocdKU+/gNdpCOdZlci
F2HTxrgfrXndJru3TiDqu4UavqAe0MNuFp3t0w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XPVggoWL6aXz+MpODTOZhEUQDa0vfEnUDaYeEHXm2vGyqKJujN2c/FFAFBeBYdJATLsIsQ+BqoPc
pBbcFYXDBfOtFIW2dH6Y1OoD65KyJ/hAq8coa21kFgq4hFat5vzZ2iIfkCpTUr4vDZO7Xne8cZO9
WsHffoTCt5rS59wWm2b8I5R8Eh2TUbQg3RCyrcnD66cvcEnlXe1CNMQ4/loVJpA4IBinBf820Wjc
vw2fZbGI0jXC+ACSHOviH63Xwmn+aRV5Ppkup7IYoon/ieKapRQeASu3TTY37xSBXiInSdtMTzJ6
+4GfO4eSHVriCk/sWbuTBzfRzoSShrnHjzz5LA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2020_08", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L78XuiswVcgO2gtebzL7SA9BC/jJGAM0v6S9pzmyqL+QYzRneiYeGyDmsW33jEVVSTuNjTXkBLY7
yTOKQruatwe4V0OLi6174saSAmPgerSV1GyLP7KhmusLV/N61avC9TPam+tekhKeE0tds4EnJ3et
4JdLh+SE4Z4pcuqCjB5MFneIYKKWDx7siU6oesAQtoSJOesfMchX63MhOjOHFP/ch+1gHv3T45hg
IGF7V7TrdREVE4f9631tlVJ1o2Dypsmo/76Itz5WCGlTMjAnWXN8IXxKN+PZ3dyt1wjrZm2P/td+
xiGszFnSLrRvw/HferwtSmRx8q0fiHZ88roGTw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kDX5kq2QEe25429T6vQqBCFvV1McKTJRYfK99ymVNK2GGvGLXSzgwJHwB2fj9rM0wme3zYYY0vQR
x+9F4L7KLlOVY6qY3LB59uDzyXBI3mMZaS905HXHJkdZHWtQWpfHhl27LqL+8FSluaD6F+KFfYOV
CwIOVuCIp/XjxFXpNBik7YiPt4kHOlDA97IXNLnYUn/g1csGqeNWce4UTne50ggWvLYGbTFGmTjT
N67TpUiGRVRCSv8Tax72GWFIMFZk3Tlp68ZUSQEybZMWX1U9XdMdtxfvNGhf8mi5jQJ2SupSzKu4
T/+53IN9T8aLePAiGBKKG1ZBj4y1ZyYA7XYvjw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 127888)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
