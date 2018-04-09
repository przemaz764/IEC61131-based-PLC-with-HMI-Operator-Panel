set_property SRC_FILE_INFO {cfile:z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xdc rfile:../../../DDC_PLC.srcs/sources_1/ip/clock/clock.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports CLK_IN1]] 0.1
