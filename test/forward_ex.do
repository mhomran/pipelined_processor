vsim -gui work.cpu
# ADD R2, R1 | R1 = 4
# ADD R1,R1  | R1 = 8
mem load -filltype value -filldata 0000000100010010 -fillradix symbolic /cpu/RAM_inst/ram(0)
mem load -filltype value -filldata 0000000100010001 -fillradix symbolic /cpu/RAM_inst/ram(1)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(2)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(3)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(4)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(5)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(6)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(7)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(10)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(11)
add wave -position end  sim:/cpu/rst
add wave -position end  sim:/cpu/clk
add wave -position end sim:/cpu/IF_ID/q
add wave -position end sim:/cpu/ID_EX/q
add wave -position end sim:/cpu/EX_MEM/q
add wave -position end sim:/cpu/MEM_WB/q
add wave -position end sim:/cpu/SR/C
add wave -position end  sim:/cpu/RegFile/R(2)/R_reg/q
add wave -position end  sim:/cpu/RegFile/R(1)/R_reg/q
add wave -position end  sim:/cpu/EX_to_EX_Forwarding_Src
add wave -position end  sim:/cpu/EX_to_EX_Forwarding_Dst
add wave -position end  sim:/cpu/ALU_op1
add wave -position end  sim:/cpu/ALU_op2

force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
run
force -freeze sim:/cpu/rst 0 0
force -freeze sim:/cpu/RegFile/R(1)/R_reg/d 10#2 0
force -freeze sim:/cpu/RegFile/R(2)/R_reg/d 10#2 0
force -freeze sim:/cpu/RegFile/R(1)/R_reg/en 1 0
force -freeze sim:/cpu/RegFile/R(2)/R_reg/en 1 0

run
noforce sim:/cpu/RegFile/R(1)/R_reg/d 
noforce sim:/cpu/RegFile/R(2)/R_reg/d 
noforce sim:/cpu/RegFile/R(1)/R_reg/en 
noforce sim:/cpu/RegFile/R(2)/R_reg/en 
run
run
run
run
run