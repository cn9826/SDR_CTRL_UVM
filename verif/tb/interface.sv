interface dut_in;
//for the clocks, 
//always #(P_SYS/2) sdram_clk = !sdram_clk;
//wire #(2.0) sdram_clk_d = sdram_clk;
//wire #(1.0) pad_clk     = sdram_clk_d;
parameter  APP_AW   = 26;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  APP_RW   = 9;   // Application Request Width

parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
//-----------------------------------------------
// Global Variable
// ----------------------------------------------
logic                 			 	clk                 ; // SDRAM Clock 
logic                   			pad_clk             ; // SDRAM Clock from Pad, used for registering Read Data
logic                   			reset_n             ; // Reset Signal
logic [1:0]             			sdr_width           ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
logic [1:0]             			cfg_colbits         ; // 2'b00 - 8 Bit column address, 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits
//------------------------------------------------
// Request from app
//------------------------------------------------
logic 								app_req             ; // Application Request
logic [APP_AW-1:0] 					app_req_addr        ; // Address 
logic 								app_req_wr_n        ; // 0 - Write, 1 - Read
logic                   			app_req_wrap        ; // Address Wrap	
logic [APP_DW-1:0] 					app_wr_data         ; // Write Data
logic [APP_BW-1:0] 					app_wr_en_n         ; // Byte wise Write Enable

		
//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
output                  			sdr_init_done       ; // Indicate SDRAM Initialisation Done
logic [3:0] 						cfg_sdr_tras_d      ; // Active to precharge delay
logic [3:0]             			cfg_sdr_trp_d       ; // Precharge to active delay
logic [3:0]            				cfg_sdr_trcd_d      ; // Active to R/W delay
logic 								cfg_sdr_en          ; // Enable SDRAM controller
logic [1:0] 						cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
logic [APP_RW-1:0]					app_req_len         ; // Application Burst Request length in 32 bit 
logic [12:0] 						cfg_sdr_mode_reg    ;
logic [2:0] 						cfg_sdr_cas         ; // SDRAM CAS Latency
logic [3:0] 						cfg_sdr_trcar_d     ; // Auto-refresh period
logic [3:0]            				cfg_sdr_twr_d       ; // Write recovery delay
logic [`SDR_RFSH_TIMER_W-1 : 0] 	cfg_sdr_rfsh;
logic [`SDR_RFSH_ROW_CNT_W -1 : 0] 	cfg_sdr_rfmax;
logic                   			app_req_dma_last;    // this signal should close the bank

endinterface: dut_in

interface dut_out;
//------------------------------------------------
// Request from app
//------------------------------------------------
output                 				app_req_ack         ; // Application Request Ack
output 		        				app_wr_next_req     ; // Next Write Data Request、
output                  			app_last_wr         ; // Last Write trannsfer of a given Burst
output [APP_DW-1:0] 				app_rd_data         ; // Read Data
output                  			app_rd_valid        ; // Read Valid
output                  			app_last_rd         ; // Last Read Transfer of a given Burst
endinterface: dut_out

