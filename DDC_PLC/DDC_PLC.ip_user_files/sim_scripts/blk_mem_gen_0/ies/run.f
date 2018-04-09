-makelib ies/xil_defaultlib -sv \
  "Z:/Vivado_2017_2/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "Z:/Vivado_2017_2/Vivado/2017.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "Z:/Vivado_2017_2/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/blk_mem_gen_v8_3_6 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_3.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../ip/blk_mem_gen_0/sim/blk_mem_gen_0.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

