vsim -gui work.cpu
# LDD R2, (5)R1 | R1 = 5
# Add R1,R1
# Add R1,R2 
mem load -filltype value -filldata 0001010100100001 -fillradix symbolic /cpu/RAM_inst/ram(0)
mem load -filltype value -filldata 0000000000000101 -fillradix symbolic /cpu/RAM_inst/ram(1)
mem load -filltype value -filldata 0000000100010001 -fillradix symbolic /cpu/RAM_inst/ram(2)
mem load -filltype value -filldata 0000000100100001 -fillradix symbolic /cpu/RAM_inst/ram(3)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(4)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(5)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(6)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(7)
mem load -filltype value -filldata 1111111111111111 -fillradix symbolic /cpu/RAM_inst/ram(10)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(11)
add wave -position end  sim:/cpu/rst
add wave -position end  sim:/cpu/clk
add wave -position end sim:/cpu/IF_ID/q
add wave -position end sim:/cpu/ID_EX/q
add wave -position end sim:/cpu/EX_MEM/q
add wave -position end sim:/cpu/MEM_WB/q
add wave -position end sim:/cpu/SR/C
add wave -position end  sim:/cpu/RegFile/R(2)/R_reg/q

force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
run
force -freeze sim:/cpu/rst 0 0
force -freeze sim:/cpu/RegFile/R_output(1) 10#5 0
force -freeze sim:/cpu/RegFile/R_output(2) 10#5 0

run
run
run
run
noforce sim:/cpu/RegFile/R_output
run
run
run