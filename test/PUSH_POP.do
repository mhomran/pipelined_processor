vsim -gui work.cpu
add wave -position end sim:/cpu/rst
add wave -position end sim:/cpu/clk
add wave -position end sim:/cpu/IF_ID/q
add wave -position end sim:/cpu/ID_EX/q
add wave -position end sim:/cpu/EX_MEM/q
add wave -position end sim:/cpu/MEM_WB/q
add wave -position end sim:/cpu/SR/C
add wave -position end sim:/cpu/SR/N
add wave -position end sim:/cpu/SR/Z
add wave -position end  sim:/cpu/Load_Use
add wave -position end sim:/cpu/RegFile/R(1)/R_reg/q
add wave -position end sim:/cpu/RegFile/R(2)/R_reg/q
add wave -position end sim:/cpu/RegFile/R(3)/R_reg/q
add wave -position end sim:/cpu/RegFile/R(4)/R_reg/q
add wave -position end sim:/cpu/RegFile/R(5)/R_reg/q
add wave -position end sim:/cpu/RegFile/R(6)/R_reg/q
add wave -position end sim:/cpu/PC/q
add wave -position end sim:/cpu/IN_PORT/q
add wave -position end sim:/cpu/OUT_PORT/q
add wave -position end sim:/cpu/ALU_inst/*
mem load -i D:/Arch_project/pipelined_processor/test_cases/PUSH_POP.mem /cpu/RAM_inst/ram


force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
run
force -freeze sim:/cpu/rst 0 0
run
run
run
force -freeze sim:/cpu/IN_PORT/q 16#1 0
run
force -freeze sim:/cpu/IN_PORT/q 16#2 0
run

run
run
run
run
run