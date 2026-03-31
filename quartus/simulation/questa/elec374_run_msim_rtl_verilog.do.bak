transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/shra.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/shr.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/shl.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/SevenSegDisplay.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/SelectEncode.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/ror.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/rol.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/registers.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/ram.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/neg.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/mul.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/logic.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/div.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/control.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/CONFF.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/ClockDivider.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/Bus.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/alu.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/adder.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/Motherboard.v}
vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/DataPath.v}

vlog  -work work +incdir+C:/Users/Yehia/Documents/quartus {C:/Users/Yehia/Documents/quartus/mb_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  mb_tb

add wave *
view structure
view signals
run 5000000 ns
