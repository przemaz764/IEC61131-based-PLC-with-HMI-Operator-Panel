// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
// Date        : Wed Apr  4 10:56:56 2018
// Host        : asusn76 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/blk_mem_gen_0_synth_1/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_6,Vivado 2017.2" *)
module blk_mem_gen_0(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[5:0],dina[0:0],douta[0:0],clkb,enb,web[0:0],addrb[2:0],dinb[7:0],doutb[7:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [5:0]addra;
  input [0:0]dina;
  output [0:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [2:0]addrb;
  input [7:0]dinb;
  output [7:0]doutb;
endmodule
