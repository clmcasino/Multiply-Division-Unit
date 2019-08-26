vlib ../tbs/multiplierUnit/work

vlog -work ../tbs/multiplierUnit/work ../src/components/*.sv
vlog -work ../tbs/multiplierUnit/work ../src/MultiplierUnit.sv
vlog -work ../tbs/multiplierUnit/work ../src/MultiplierUnitDP.sv
vlog -work ../tbs/multiplierUnit/work ../tbs/multiplierUnit/tb_multiplierUnit.sv

vsim -c ../tbs/multiplierUnit/work.tb_multiplierUnit
run -all
