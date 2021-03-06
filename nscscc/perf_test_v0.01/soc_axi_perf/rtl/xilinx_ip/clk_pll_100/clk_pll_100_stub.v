// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Sun Aug  1 14:51:46 2021
// Host        : cyy-pc running 64-bit Debian GNU/Linux 11 (bullseye)
// Command     : write_verilog -force -mode synth_stub
//               /home/cyy/EternalCPU/nscscc/perf_test_v0.01/soc_axi_perf/rtl/xilinx_ip/clk_pll_100/clk_pll_100_stub.v
// Design      : clk_pll_100
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_pll_100(cpu_clk, sys_clk, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="cpu_clk,sys_clk,clk_in1" */;
  output cpu_clk;
  output sys_clk;
  input clk_in1;
endmodule
