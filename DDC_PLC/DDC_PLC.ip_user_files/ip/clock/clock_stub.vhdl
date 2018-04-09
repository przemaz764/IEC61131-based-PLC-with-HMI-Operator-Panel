-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
-- Date        : Wed Apr  4 08:36:28 2018
-- Host        : asusn76 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.vhdl
-- Design      : clock
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock is
  Port ( 
    CLK_OUT1 : out STD_LOGIC;
    CLK_IN1 : in STD_LOGIC
  );

end clock;

architecture stub of clock is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK_OUT1,CLK_IN1";
begin
end;
