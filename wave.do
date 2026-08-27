onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb /slave_tb/clk_tb
add wave -noupdate -expand -group tb /slave_tb/rst_tb
add wave -noupdate -expand -group tb /slave_tb/sda_s_in_tb
add wave -noupdate -expand -group tb /slave_tb/scl_s_in_tb
add wave -noupdate -expand -group tb /slave_tb/sda_s_out_tb
add wave -noupdate -expand -group tb /slave_tb/test_num
add wave -noupdate -expand -group slave_file -color Magenta /slave_tb/DUT/sda_s_in
add wave -noupdate -expand -group slave_file -color Cyan /slave_tb/DUT/scl_s_in
add wave -noupdate -expand -group slave_file /slave_tb/DUT/clk
add wave -noupdate -expand -group slave_file /slave_tb/DUT/rst
add wave -noupdate -expand -group slave_file /slave_tb/DUT/sda_s_out
add wave -noupdate -expand -group slave_file /slave_tb/DUT/cs
add wave -noupdate -expand -group slave_file /slave_tb/DUT/ns
add wave -noupdate -expand -group slave_file /slave_tb/DUT/i
add wave -noupdate -expand -group slave_file /slave_tb/DUT/sda_s_d
add wave -noupdate -expand -group slave_file /slave_tb/DUT/scl_s_d
add wave -noupdate -expand -group slave_file -color Yellow -radix unsigned /slave_tb/DUT/bit_cnt
add wave -noupdate -expand -group slave_file /slave_tb/DUT/sent_addr
add wave -noupdate -expand -group slave_file /slave_tb/DUT/data_out
add wave -noupdate -expand -group slave_file /slave_tb/DUT/cnt
add wave -noupdate -expand -group slave_file /slave_tb/DUT/r_or_w
add wave -noupdate -expand -group slave_file /slave_tb/DUT/cont
add wave -noupdate -expand -group slave_file /slave_tb/DUT/data_in
add wave -noupdate -expand -group slave_file -color Pink /slave_tb/DUT/start_cond
add wave -noupdate -expand -group slave_file -color Pink /slave_tb/DUT/stop_cond
add wave -noupdate -expand -group slave_file -color Pink /slave_tb/DUT/edge_detection
add wave -noupdate /slave_tb/clk_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6570906 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5688255 ps} {7092782 ps}
