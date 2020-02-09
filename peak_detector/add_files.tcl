set path [ file dirname [ file normalize [ info script ] ] ]

read_vhdl [ glob $path/src/*.vhd ]
read_vhdl [ glob $path/../libs/io/*.vhd ]
read_vhdl [ glob $path/../libs/utils/*.vhd ]
read_xdc $path/constraints/Basys3_Master.xdc