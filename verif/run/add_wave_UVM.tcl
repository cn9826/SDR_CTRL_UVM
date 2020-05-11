add wave -position insertpoint /top/dut_in_0/reset_n
add wave -position insertpoint /top/dut_in_0/sdram_clk

# application layer input I/F signals
add wave -position insertpoint -group "app layer input I/F" /top/dut_in_0/app_req 
add wave -position insertpoint -group "app layer input I/F" /top/dut_in_0/app_req_addr
add wave -position insertpoint -group "app layer input I/F" /top/dut_in_0/app_wr_data
add wave -position insertpoint -group "app layer input I/F" /top/dut_in_0/app_req_len
add wave -position insertpoint -group "app layer input I/F" /top/dut_in_0/app_req_wr_n
add wave -position insertpoint -group "app layer input I/F" /top/dut_in_0/app_wr_en_n



# application layer output I/F signals
add wave -position insertpoint -group "app layer output I/F" /top/dut_out_0/app_req_ack 
add wave -position insertpoint -group "app layer output I/F" /top/dut_out_0/app_wr_next_req
add wave -position insertpoint -group "app layer output I/F" /top/dut_out_0/app_rd_data
add wave -position insertpoint -group "app layer output I/F" /top/dut_out_0/app_rd_valid

restart
run -all 
