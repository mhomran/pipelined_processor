vsim -gui work.cpu
add wave -position end sim:/cpu/RegFile/*
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(1)
mem load -filltype value -filldata {0000000000100001 } -fillradix symbolic /cpu/RAM_inst/ram(0)
mem load -filltype value -filldata {0000000000100001 } -fillradix symbolic /cpu/RAM_inst/ram(2)
mem load -filltype value -filldata {0000000000100001 } -fillradix symbolic /cpu/RAM_inst/ram(3)
add wave -position end  sim:/cpu/rst
add wave -position end  sim:/cpu/clk
add wave -position end sim:/cpu/ID_EX/*
add wave -position end  sim:/cpu/IMM_VAL_extended
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
run
force -freeze sim:/cpu/rst 0 0
force -freeze sim:/cpu/RegFile/R_output(1) 10#1 0
force -freeze sim:/cpu/RegFile/R_output(2) 10#2 0
add wave -position end sim:/cpu/IF_ID/*
run

run


-----------------------------------------------------------
vsim -gui work.cpu
add wave -position end sim:/cpu/RegFile/*
mem load -filltype value -filldata {0001010100100001 } -fillradix symbolic /cpu/RAM_inst/ram(0)
mem load -filltype value -filldata 0000000000000101 -fillradix symbolic /cpu/RAM_inst/ram(1)
mem load -filltype value -filldata {0000000000100001 } -fillradix symbolic /cpu/RAM_inst/ram(2)
mem load -filltype value -filldata {0000000000100001 } -fillradix symbolic /cpu/RAM_inst/ram(3)
mem load -filltype value -filldata {1111111111111111 } -fillradix symbolic /cpu/RAM_inst/ram(10)
mem load -filltype value -filldata {1111111111111111 } -fillradix symbolic /cpu/RAM_inst/ram(11)
force -freeze sim:/cpu/RegFile/R_output(1) 10#5 0
force -freeze sim:/cpu/RegFile/R_output(2) 10#5 0
add wave -position end  sim:/cpu/rst
add wave -position end  sim:/cpu/clk
add wave -position end sim:/cpu/ID_EX/*
add wave -position end sim:/cpu/ControlUnit/*
add wave -position end  sim:/cpu/IMM_VAL_extended
add wave -position end sim:/cpu/EX_MEM/*
add wave -position end sim:/cpu/ALU_inst/*
add wave -position 40 sim:/cpu/SR/*
add wave -position 37 sim:/cpu/MEM_WB/*
add wave -position end  sim:/cpu/RAM_inst/dataout
add wave -position end  sim:/cpu/RAM_inst/datain
add wave -position end  sim:/cpu/RAM_inst/address

force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
run
force -freeze sim:/cpu/rst 0 0

add wave -position end sim:/cpu/IF_ID/*
run
run
run
run