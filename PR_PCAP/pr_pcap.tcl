#This TCL file can be run directly form Vivado TCL Consol (without opening the project)
#It can be also run from command line by commenting out the 'set origin_dir' and adding the path to  'generate_target all' function

#Before running the script the block design should have been already created and floorplanning should have been already saved in the xdc file

#add the path of this project in below function
set origin_dir "."

#Opening the project
open_project $origin_dir/Vivado_design/PR_PCAP.xpr

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z010clg400-1 -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
}
set obj [get_runs synth_1]

#Create all the required files
generate_target all [get_files  $origin_dir/Vivado_design/PR_PCAP.srcs/sources_1/bd/design_1/design_1.bd]
if {![file exists $origin_dir/Vivado_design/PR_PCAP.sdk]} {
      file mkdir $origin_dir/Vivado_design/PR_PCAP.sdk
}
write_hwdef -force  -file $origin_dir/Vivado_design/PR_PCAP.sdk/design_1_wrapper.hdf
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1

if {![file exists $origin_dir/netlists/static]} {
      file mkdir $origin_dir/netlists/static
}
write_checkpoint -force $origin_dir/netlists/static/static.dcp

#//Stitch Static design with the first netlist (adder)
read_checkpoint -cell [get_cells design_1_i/reconfig_module_0/inst] $origin_dir/netlists/adder/adder.dcp

#//Place and route the design
opt_design
place_design
route_design

#//Generate the first place and routed netlist (adder)
if {![file exists $origin_dir/netlists/adder_config]} {
      file mkdir $origin_dir/netlists/adder_config
}
write_checkpoint -force $origin_dir/netlists/adder_config/adder_config_routed.dcp

#//remove the PR and generate place and routed netlist of  static region
update_design  -cell [get_cells design_1_i/reconfig_module_0] -black_box
#//preserve the static design
lock_design -level routing
write_checkpoint -force $origin_dir/netlists/static/static_routed.dcp

#//Stitch Static design with the second netlist (multiplier)
read_checkpoint -cell [get_cells design_1_i/reconfig_module_0] $origin_dir/netlists/multiplier/multiplier.dcp
opt_design
place_design
route_design

#//Generate the second place and routed netlist (multiplier)
if {![file exists $origin_dir/netlists/multiplier_config]} {
      file mkdir $origin_dir/netlists/multiplier_config
}
write_checkpoint -force $origin_dir/netlists/multiplier_config/multiplier_config_routed.dcp

update_design  -cell [get_cells design_1_i/reconfig_module_0] -black_box

#//Stitch Static design with the third netlist (subtractor)
read_checkpoint -cell [get_cells design_1_i/reconfig_module_0] $origin_dir/netlists/Subtractor/subtractor.dcp
opt_design
place_design
route_design

#//Generate the third place and routed netlist (subtractor)
if {![file exists $origin_dir/netlists/subtractor_config]} {
      file mkdir $origin_dir/netlists/subtractor_config
}
write_checkpoint -force $origin_dir/netlists/subtractor_config/subtractor_config_routed.dcp

#//Create bitstreams for all three modules
if {![file exists $origin_dir/bitstreams]} {
      file mkdir $origin_dir/bitstreams
}

if {![file exists $origin_dir/bitstreams/subtractor]} {
      file mkdir $origin_dir/bitstreams/subtractor
}
write_bitstream $origin_dir/bitstreams/subtractor/full_subtractor.bit
open_checkpoint $origin_dir/netlists/adder_config/adder_config_routed.dcp
if {![file exists $origin_dir/bitstreams/adder]} {
      file mkdir $origin_dir/bitstreams/adder
}
write_bitstream $origin_dir/bitstreams/adder/full_adder.bit
close_design
if {![file exists $origin_dir/bitstreams/multiplier]} {
      file mkdir $origin_dir/bitstreams/multiplier
}
open_checkpoint $origin_dir/netlists/multiplier_config/multiplier_config_routed.dcp
write_bitstream $origin_dir/bitstreams/multiplier/full_multiplier.bit
close_design

#//Bitstream conversion for PCAP (.bit to .bin)
write_cfgmem -force -format BIN -interface SMAPx32 -loadbit "up 0x0 $origin_dir/bitstreams/adder/full_adder_pblock_inst_partial.bit" "$origin_dir/bitstreams/adder/partial_adder.bin"
write_cfgmem -force -format BIN -interface SMAPx32 -loadbit "up 0x0 $origin_dir/bitstreams/multiplier/full_multiplier_pblock_inst_partial.bit" "$origin_dir/bitstreams/multiplier/partial_multiplier.bin"
write_cfgmem -force -format BIN -interface SMAPx32 -loadbit "up 0x0 $origin_dir/bitstreams/subtractor/full_subtractor_pblock_inst_partial.bit" "$origin_dir/bitstreams/subtractor/partial_subtractor.bin"
