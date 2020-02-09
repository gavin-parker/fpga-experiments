set script_path [ file dirname [ file normalize [ info script ] ] ]
cd $script_path

source stopwatch/add_files.tcl

check_syntax