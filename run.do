vlib work
vlog *.*v
vsim -voptargs=+acc work.slave_tb
do wave.do
run -all