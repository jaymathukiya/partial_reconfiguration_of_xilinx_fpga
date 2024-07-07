create_pblock pblock_inst
add_cells_to_pblock [get_pblocks pblock_inst] [get_cells -quiet [list design_1_i/reconfig_module_0]]
resize_pblock [get_pblocks pblock_inst] -add {SLICE_X0Y0:SLICE_X13Y49}
resize_pblock [get_pblocks pblock_inst] -add {DSP48_X0Y0:DSP48_X0Y19}
resize_pblock [get_pblocks pblock_inst] -add {RAMB18_X0Y0:RAMB18_X0Y19}
resize_pblock [get_pblocks pblock_inst] -add {RAMB36_X0Y0:RAMB36_X0Y9}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_inst]
set_property SNAPPING_MODE ON [get_pblocks pblock_inst]
set_property HD.RECONFIGURABLE true [get_cells design_1_i/reconfig_module_0]