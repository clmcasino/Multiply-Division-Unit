vlib ../tbs/divisorUnit/work

vlog -work ../tbs/divisorUnit/work ../src/components/*.sv
vlog -work ../tbs/divisorUnit/work ../src/DivisorUnit.sv
vlog -work ../tbs/divisorUnit/work ../src/DivisorUnitDP.sv
vlog -work ../tbs/divisorUnit/work ../tbs/divisorUnit/tb_divisorUnit.sv

vsim -c ../tbs/divisorUnit/work.tb_divisorUnit

run -all

quit -f
