vlib ../tbs/divmultUnit/work

vlog -work ../tbs/divmultUnit/work ../src/components/*.sv
vlog -work ../tbs/divmultUnit/work ../src/MultDivUnit.sv
vlog -work ../tbs/divmultUnit/work ../src/MultDivUnitDP.sv
vlog -work ../tbs/divmultUnit/work ../tbs/divmultUnit/tb_divMultUnit.sv

vsim -c ../tbs/divmultUnit/work.tb_multDivUnit

run -all
