vlib ../tbs/multiplierUnit/work

vlog -work ../tbs/multiplierUnit/work ../src/components/*.sv
vlog -work ../tbs/multiplierUnit/work ../src/MultiplierUnit.sv
vlog -work ../tbs/multiplierUnit/work ../src/MultiplierUnitDP.sv
vlog -work ../tbs/multiplierUnit/work ../tbs/multiplierUnit/tb_multiplierUnit.sv

vsim -c ../tbs/multiplierUnit/work.tb_multiplierUnit

add wave sim:/tb_multiplierUnit/DUT/present_state sim:/tb_multiplierUnit/DUT/next_state
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/clk
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/rst_n
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/usigned
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/multiplier
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/signCorrection_to_MultiplierReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/multiplicand
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/signCorrection_to_MultipicandReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/notMultiplicand_to_kernelLogic
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/multiplicand_to_kernelLogic
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/sum_to_csa
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/carry_to_csa
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/kl_to_csa
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/sumL_to_newSumL
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/csaSum_to_outReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/csaCarry_to_outReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/multiplicandMux_to_sumHReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/sumLMux_to_sumLReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/leftOpleftAdd
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/rightOpleftAdd
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/leftAdder_to_outReg
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/prodL
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/prodH
add wave sim:/tb_multiplierUnit/DUT/multiplierDP/product

run -all
