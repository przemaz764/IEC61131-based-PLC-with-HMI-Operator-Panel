# 
# Synthesis run script generated by Vivado
# 

set_param project.vivado.isBlockSynthRun true
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir Z:/PLC/plc/DDC_PLC/DDC_PLC.cache/wt [current_project]
set_property parent.project_path Z:/PLC/plc/DDC_PLC/DDC_PLC.xpr [current_project]
set_property XPM_LIBRARIES XPM_CDC [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo z:/PLC/plc/DDC_PLC/DDC_PLC.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_ip -quiet Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci
set_property used_in_implementation false [get_files -all z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock_board.xdc]
set_property used_in_implementation false [get_files -all z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xdc]
set_property used_in_implementation false [get_files -all z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock_ooc.xdc]
set_property is_locked true [get_files Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

set cached_ip [config_ip_cache -export -no_bom -use_project_ipc -dir Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1 -new_name clock -ip [get_ips clock]]

if { $cached_ip eq {} } {

synth_design -top clock -part xc7a35tcpg236-1 -mode out_of_context

#---------------------------------------------------------
# Generate Checkpoint/Stub/Simulation Files For IP Cache
#---------------------------------------------------------
catch {
 write_checkpoint -force -noxdef -rename_prefix clock_ clock.dcp

 set ipCachedFiles {}
 write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ clock_stub.v
 lappend ipCachedFiles clock_stub.v

 write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ clock_stub.vhdl
 lappend ipCachedFiles clock_stub.vhdl

 write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ clock_sim_netlist.v
 lappend ipCachedFiles clock_sim_netlist.v

 write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ clock_sim_netlist.vhdl
 lappend ipCachedFiles clock_sim_netlist.vhdl

 config_ip_cache -add -dcp clock.dcp -move_files $ipCachedFiles -use_project_ipc -ip [get_ips clock]
}

rename_ref -prefix_all clock_

write_checkpoint -force -noxdef clock.dcp

catch { report_utilization -file clock_utilization_synth.rpt -pb clock_utilization_synth.pb }

if { [catch {
  write_verilog -force -mode synth_stub Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}


} else {


}; # end if cached_ip 

add_files Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.v -of_objects [get_files Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci]

add_files Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.vhdl -of_objects [get_files Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci]

add_files Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_sim_netlist.v -of_objects [get_files Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci]

add_files Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_sim_netlist.vhdl -of_objects [get_files Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci]

add_files Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock.dcp -of_objects [get_files Z:/PLC/plc/DDC_PLC/DDC_PLC.srcs/sources_1/ip/clock/clock.xci]

if {[file isdir Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock]} {
  catch { 
    file copy -force Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_sim_netlist.v Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock
  }
}

if {[file isdir Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock]} {
  catch { 
    file copy -force Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_sim_netlist.vhdl Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock
  }
}

if {[file isdir Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock]} {
  catch { 
    file copy -force Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.v Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock
  }
}

if {[file isdir Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock]} {
  catch { 
    file copy -force Z:/PLC/plc/DDC_PLC/DDC_PLC.runs/clock_synth_1/clock_stub.vhdl Z:/PLC/plc/DDC_PLC/DDC_PLC.ip_user_files/ip/clock
  }
}
