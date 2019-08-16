vlib ../tbs/divisorUnit/work

vlog -work ../tbs/divisorUnit/work ../src/components/*.sv
vlog -work ../tbs/divisorUnit/work ../src/DivisorUnit.sv
vlog -work ../tbs/divisorUnit/work ../src/DivisorUnitDP.sv
vlog -work ../tbs/divisorUnit/work ../tbs/divisorUnit/tb_divisorUnit.sv

vsim -c ../tbs/divisorUnit/work.tb_divisorUnit

add wave sim:/tb_divisorUnit/DUT/present_state sim:/tb_divisorUnit/DUT/next_state
add wave sim:/tb_divisorUnit/DUT/divisorDP/clk
add wave sim:/tb_divisorUnit/DUT/divisorDP/usigned
add wave sim:/tb_divisorUnit/DUT/divisorDP/divisor
add wave sim:/tb_divisorUnit/DUT/divisorDP/dividend
add wave sim:/tb_divisorUnit/DUT/divisorDP/quotient
add wave sim:/tb_divisorUnit/DUT/divisorDP/reminder
add wave sim:/tb_divisorUnit/DUT/divisorDP/reminderOutReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/signCorrection_to_DivisorReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/divisor_to_kernelLogic
add wave sim:/tb_divisorUnit/DUT/divisorDP/divisor_en
add wave sim:/tb_divisorUnit/DUT/divisorDP/divisor_lShift
add wave sim:/tb_divisorUnit/DUT/divisorDP/notDivisor_to_kernelLogic
add wave sim:/tb_divisorUnit/DUT/divisorDP/notDivisor_en
add wave sim:/tb_divisorUnit/DUT/divisorDP/signCorrection_to_DividendReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/csaSum_to_outReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/dividendMux_to_sumHReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/sumH_to_cond
add wave sim:/tb_divisorUnit/DUT/divisorDP/sum_to_csa
add wave sim:/tb_divisorUnit/DUT/divisorDP/csaCarry_to_outReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/carryH_to_cond
add wave sim:/tb_divisorUnit/DUT/divisorDP/carry_to_csa
add wave sim:/tb_divisorUnit/DUT/divisorDP/kl_to_csa
add wave sim:/tb_divisorUnit/DUT/divisorDP/Non0
add wave sim:/tb_divisorUnit/DUT/divisorDP/SignSel
add wave sim:/tb_divisorUnit/DUT/divisorDP/sumL_to_newQBitAdder
add wave sim:/tb_divisorUnit/DUT/divisorDP/newQBitAdder_to_sumL
add wave sim:/tb_divisorUnit/DUT/divisorDP/carryL_to_newQBitAdder
add wave sim:/tb_divisorUnit/DUT/divisorDP/newQBitAdder_to_carryL
add wave sim:/tb_divisorUnit/DUT/divisorDP/quotientCorrectBit
add wave sim:/tb_divisorUnit/DUT/divisorDP/rightOprightAdd
add wave sim:/tb_divisorUnit/DUT/divisorDP/reminderOutReg
add wave sim:/tb_divisorUnit/DUT/signS
add wave sim:/tb_divisorUnit/DUT/signZ
add wave sim:/tb_divisorUnit/DUT/res_ready
add wave sim:/tb_divisorUnit/DUT/magnitudeD
add wave sim:/tb_divisorUnit/DUT/load1
add wave sim:/tb_divisorUnit/DUT/divisorReady
add wave sim:/tb_divisorUnit/DUT/divisorDP/counterOut_to_counterReg
add wave sim:/tb_divisorUnit/DUT/divisorDP/counterMux_to_counter
add wave sim:/tb_divisorUnit/DUT/divisorDP/counterRegOut
add wave sim:/tb_divisorUnit/DUT/divisorDP/KL/tempU 
add wave sim:/tb_divisorUnit/DUT/divisorDP/KL/temp

run -all
