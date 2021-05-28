vsim -gui work.cpu
# INC
mem load -filltype value -filldata 0000111100000000 -fillradix symbolic /cpu/RAM_inst/ram(0)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(1)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(2)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(3)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(4)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(5)
# NEG
mem load -filltype value -filldata 0001000100000000 -fillradix symbolic /cpu/RAM_inst/ram(6)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(7)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(8)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(9)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(10)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(11)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(12)
add wave -position end  sim:/cpu/rst
add wave -position end  sim:/cpu/clk
add wave -position end sim:/cpu/IF_ID/q
add wave -position end sim:/cpu/ID_EX/q
add wave -position end sim:/cpu/EX_MEM/q
add wave -position end sim:/cpu/MEM_WB/q
add wave -position end sim:/cpu/SR/C
add wave -position end  sim:/cpu/RegFile/R(0)/R_reg/q

force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
run
force -freeze sim:/cpu/rst 0 0

# just ensure that that the control signals are zeros
run
run
run
run
run

run
run
run
run
run

run