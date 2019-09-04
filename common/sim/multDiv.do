vlib ../tbs/divmultUnit/work

vlog -work ../tbs/divmultUnit/work ../src/components/*.sv
vlog -work ../tbs/divmultUnit/work ../src/MultDivUnit.sv
vlog -work ../tbs/divmultUnit/work ../src/MultDivUnitDP.sv
vlog -work ../tbs/divmultUnit/work ../tbs/divmultUnit/tb_divMultUnit.sv

vsim -c ../tbs/divmultUnit/work.tb_multDivUnit

add wave sim:/tb_multDivUnit/DUT/present_state sim:/tb_multDivUnit/DUT/next_state
add wave sim:/tb_multDivUnit/DUT/DP/clk
add wave sim:/tb_multDivUnit/DUT/DP/rst_n
add wave sim:/tb_multDivUnit/DUT/DP/opCode
add wave sim:/tb_multDivUnit/DUT/DP/rOp
add wave sim:/tb_multDivUnit/DUT/DP/signCorrection_to_rOpReg
add wave sim:/tb_multDivUnit/DUT/DP/lOp
add wave sim:/tb_multDivUnit/DUT/DP/signCorrection_to_lOpReg
add wave sim:/tb_multDivUnit/DUT/DP/notLOp_to_kernelLogic
add wave sim:/tb_multDivUnit/DUT/DP/lOp_to_kernelLogic
add wave sim:/tb_multDivUnit/DUT/DP/sumH
add wave sim:/tb_multDivUnit/DUT/DP/carryH
add wave sim:/tb_multDivUnit/DUT/DP/kl_to_csa
add wave sim:/tb_multDivUnit/DUT/DP/sumL
add wave sim:/tb_multDivUnit/DUT/DP/csaSum_to_outReg
add wave sim:/tb_multDivUnit/DUT/DP/csaCarry_to_outReg
add wave sim:/tb_multDivUnit/DUT/DP/sumHMux_to_sumHReg
add wave sim:/tb_multDivUnit/DUT/DP/sumMux_sel
add wave sim:/tb_multDivUnit/DUT/DP/sumLMux_to_sumLReg
add wave sim:/tb_multDivUnit/DUT/DP/leftOpleftAdd
add wave sim:/tb_multDivUnit/DUT/DP/rightOpleftAdd
add wave sim:/tb_multDivUnit/DUT/DP/leftAdder_to_outReg
add wave sim:/tb_multDivUnit/DUT/DP/rResOutReg
add wave sim:/tb_multDivUnit/DUT/DP/lResOutReg
add wave sim:/tb_multDivUnit/DUT/DP/res
add wave sim:/tb_multDivUnit/DUT/done
add wave sim:/tb_multDivUnit/DUT/DP/prevLOp
add wave sim:/tb_multDivUnit/DUT/DP/lEquality
add wave sim:/tb_multDivUnit/DUT/DP/prevROp
add wave sim:/tb_multDivUnit/DUT/DP/rEquality
add wave sim:/tb_multDivUnit/DUT/DP/opEquality
add wave sim:/tb_multDivUnit/DUT/DP/res_ready

run -all
