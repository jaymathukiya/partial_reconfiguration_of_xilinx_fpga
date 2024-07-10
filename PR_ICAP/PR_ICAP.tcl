#This TCL file can be run directly form Vivado TCL Consol (without opening the project)
#It can be also run from command line by commenting out the 'set origin_dir' and adding the path to  'generate_target all' function

#Before running the script the block design should have been already created and floorplanning should have been already saved in the xdc file

#add the path of this project in below function
set origin_dir "."

open_project $origin_dir/Vivado_design/PR_ICAP.xpr

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z010clg400-1 -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
}
set obj [get_runs synth_1]

generate_target all [get_files  $origin_dir/Vivado_design/PR_ICAP.srcs/sources_1/bd/design_1/design_1.bd]
if {![file exists $origin_dir/Vivado_design/PR_ICAP.sdk]} {
      file mkdir $origin_dir/Vivado_design/PR_ICAP.sdk
}
write_hwdef -force  -file $origin_dir/Vivado_design/PR_ICAP.sdk/design_1_wrapper.hdf
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1

if {![file exists $origin_dir/netlists/static]} {
      file mkdir $origin_dir/netlists/static
}
write_checkpoint -force $origin_dir/netlists/static/static.dcp

read_checkpoint -cell [get_cells design_1_i/reconfig_module_0/inst] $origin_dir/netlists/adder/adder.dcp
opt_design
place_design
route_design
if {![file exists $origin_dir/netlists/adder_config]} {
      file mkdir $origin_dir/netlists/adder_config
}
write_checkpoint -force $origin_dir/netlists/adder_config/adder_config_routed.dcp

update_design  -cell [get_cells design_1_i/reconfig_module_0] -black_box
lock_design -level routing
write_checkpoint -force $origin_dir/netlists/static/static_routed.dcp

read_checkpoint -cell [get_cells design_1_i/reconfig_module_0] $origin_dir/netlists/multiplier/multiplier.dcp
opt_design
place_design
route_design
if {![file exists $origin_dir/netlists/multiplier_config]} {
      file mkdir $origin_dir/netlists/multiplier_config
}
write_checkpoint -force $origin_dir/netlists/multiplier_config/multiplier_config_routed.dcp

update_design  -cell [get_cells design_1_i/reconfig_module_0] -black_box
read_checkpoint -cell [get_cells design_1_i/reconfig_module_0] $origin_dir/netlists/Subtractor/subtractor.dcp
opt_design
place_design
route_design
if {![file exists $origin_dir/netlists/subtractor_config]} {
      file mkdir $origin_dir/netlists/subtractor_config
}
write_checkpoint -force $origin_dir/netlists/subtractor_config/subtractor_config_routed.dcp

if {![file exists $origin_dir/bitstreams]} {
      file mkdir $origin_dir/bitstreams
}

if {![file exists $origin_dir/bitstreams/subtractor]} {
      file mkdir $origin_dir/bitstreams/subtractor
}
write_bitstream -force -bin_file $origin_dir/bitstreams/subtractor/full_subtractor.bit
open_checkpoint $origin_dir/netlists/adder_config/adder_config_routed.dcp
if {![file exists $origin_dir/bitstreams/adder]} {
      file mkdir $origin_dir/bitstreams/adder
}
write_bitstream -force -bin_file $origin_dir/bitstreams/adder/full_adder.bit
close_design
if {![file exists $origin_dir/bitstreams/multiplier]} {
      file mkdir $origin_dir/bitstreams/multiplier
}
open_checkpoint $origin_dir/netlists/multiplier_config/multiplier_config_routed.dcp
write_bitstream -force -bin_file $origin_dir/bitstreams/multiplier/full_multiplier.bit
close_design

