add wave -position insertpoint /tb_core/RESETN
add wave -position insertpoint /tb_core/sdram_clk
add wave -position insertpoint /tb_core/sdram_clk_d

# application layer signals
add wave -position insertpoint -group "application layer" /tb_core/app_req 
add wave -position insertpoint -group "application layer" /tb_core/app_req_ack 
add wave -position insertpoint -group "application layer" /tb_core/app_req_addr
add wave -position insertpoint -group "application layer" /tb_core/app_wr_next_req
add wave -position insertpoint -group "application layer" /tb_core/app_req_wr_n
add wave -position insertpoint -group "application layer" /tb_core/app_wr_en_n
add wave -position insertpoint -group "application layer" /tb_core/app_wr_data
add wave -position insertpoint -group "application layer" /tb_core/app_last_wr
add wave -position insertpoint -group "application layer" /tb_core/app_rd_data
add wave -position insertpoint -group "application layer" /tb_core/app_rd_valid
add wave -position insertpoint -group "application layer" /tb_core/app_last_rd

# SDRAM IF signals
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_init_done
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_cke
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_addr
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_cs_n
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_ras_n
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_cas_n
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_we_n
add wave -position insertpoint -group "SDRAM IF" /tb_core/sdr_dout
add wave -position insertpoint -group "SDRAM IF" /tb_core/Dq

restart
run -all 
