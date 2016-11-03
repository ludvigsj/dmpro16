set out_dir .
set sources [glob -nocomplain $env(TOPDIR)/src/*.v]
create_project -force sudoku out_dir/sudoku -part xc7a35tcsg324-1
add_files ../verilog/
update_compile_order -fileset sources_1
import_files -fileset constrs_1 -force ../work/sudoku.xdc
synth_design -part xc7a35tcsg324-1
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
