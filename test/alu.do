vsim -gui work.alu(alu_0)

add wave -position end  sim:/alu/A
add wave -position end  sim:/alu/B
add wave -position end  sim:/alu/S
add wave -position end  sim:/alu/Cin
add wave -position end  sim:/alu/F
add wave -position end  sim:/alu/SetC
add wave -position end  sim:/alu/ClrC
add wave -position end  sim:/alu/SetZ
add wave -position end  sim:/alu/ClrZ
add wave -position end  sim:/alu/SetN
add wave -position end  sim:/alu/ClrN

force -freeze sim:/alu/S 0000 0
force -freeze sim:/alu/A 10#5 0
run
force -freeze sim:/alu/S 0001 0
force -freeze sim:/alu/B 10#6 0
run
force -freeze sim:/alu/S 0010 0
force -freeze sim:/alu/B 16#5 0
run
force -freeze sim:/alu/S 0011 0
run
force -freeze sim:/alu/S 0100 0
force -freeze sim:/alu/B 10#6 0
run
force -freeze sim:/alu/S 0101 0
run
force -freeze sim:/alu/S 0110 0
run
force -freeze sim:/alu/S 0111 0
force -freeze sim:/alu/Cin 1 0
run
force -freeze sim:/alu/S 1000 0
run
force -freeze sim:/alu/S 1001 0
run
force -freeze sim:/alu/S 1010 0
run
force -freeze sim:/alu/S 1011 0
run
force -freeze sim:/alu/S 1100 0
run
force -freeze sim:/alu/S 1110 0
run
force -freeze sim:/alu/S 1111 0
run