// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
// Date        : Wed Apr  4 08:36:28 2018
// Host        : asusn76 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.v
// Design      : clock
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clock(CLK_OUT1, CLK_IN1)
/* synthesis syn_black_box black_box_pad_pin="CLK_OUT1,CLK_IN1" */;
  output CLK_OUT1;
  input CLK_IN1;
endmodule