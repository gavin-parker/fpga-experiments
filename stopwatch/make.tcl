set script_path [ file dirname [ file normalize [ info script ] ] ]
puts $script_path
cd $script_path

set outputDir ./build
file mkdir $outputDir

read_vhdl [ glob ./src/*.vhd ]
read_vhdl [ glob ../libs/io/*.vhd ]
read_vhdl [ glob ../libs/utils/*.vhd ]
read_xdc ./constraints/Basys3_Master.xdc

synth_design -top stopwatch -part xc7a35tcpg236-1
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt

opt_design
place_design
report_clock_utilization -file $outputDir/clock_util.rpt

if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
 puts "Found setup timing violations => running physical optimization"
 phys_opt_design
}

write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt

route_design
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt

write_bitstream -force $outputDir/cpu.bit
