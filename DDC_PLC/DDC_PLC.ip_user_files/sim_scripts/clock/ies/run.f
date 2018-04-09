-makelib ies/xil_defaultlib -sv \
  "Z:/Vivado_2017_2/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies/xpm \
  "Z:/Vivado_2017_2/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../ip/clock/clock_clk_wiz.v" \
  "../../../ip/clock/clock.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

