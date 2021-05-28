vsim -gui work.cpu(cpu_0)
mem load -filltype value -filldata 0000000000000000 -fillradix symbolic /cpu/RAM_inst/ram(0)
mem load -filltype value -filldata 0000000000000001 -fillradix symbolic /cpu/RAM_inst/ram(1)
mem load -filltype value -filldata 0000000000000010 -fillradix symbolic /cpu/RAM_inst/ram(2)
add wave -position insertpoint  \
sim:/cpu/RAM_output \
sim:/cpu/RAM_address \
sim:/cpu/PC_output \
sim:/cpu/PC_input_en \
sim:/cpu/PC_input \
sim:/cpu/PC_increment \
sim:/cpu/IF_ID_output \
sim:/cpu/IF_ID_input
add wave -position end  sim:/cpu/clk
add wave -position end  sim:/cpu/EX_MEM_Use_Memory
add wave -position end  sim:/cpu/rst
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/rst 1 0
run
force -freeze sim:/cpu/rst 0 0
run
add wave -position end  sim:/cpu/is_imm_instruction
force -freeze sim:/cpu/is_imm_instruction 1 0
run