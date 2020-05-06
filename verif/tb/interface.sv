
parameter  APP_AW   = 26;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  APP_RW   = 9;   // Application Request Width

parameter  SDR_DW   = 8;  // SDR Data Width 
parameter  SDR_BW   = 1;   // SDR Byte Width

interface dut_in;
//for the clocks, 
//always #(P_SYS/2) sdram_clk = !sdram_clk;
//wire #(2.0) sdram_clk_d = sdram_clk;
//wire #(1.0) pad_clk     = sdram_clk_d;
//-----------------------------------------------
// Global Signal
// ----------------------------------------------
typedef struct {
	logic                 			 	sdram_clk; 		// SDRAM Clock
	logic						sdram_clk_d;		// #2 delay from sdram_clk 
	logic                   			pad_clk; 		// #1 delay from sdram_clk_d SDRAM Clock from Pad, used for registering Read Data
	logic                   			reset_n             ; // Reset Signal
	logic [1:0]             			sdr_width           ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
} GLOBAL_SIGNALS;

GLOBAL_SIGNALS global_signals;	


//------------------------------------------------
// Request from app
//------------------------------------------------
typedef struct {
	logic 						app_req             ; // Application Request
	logic [APP_AW-1:0] 				app_req_addr        ; // Address 
	logic [APP_RW-1:0]				app_req_len         ; // Application Burst Request length in 32 bit 
	logic 						app_req_wr_n        ; // 0 - Write, 1 - Read
	logic                   			app_req_wrap        ; // Address Wrap	
	logic [APP_DW-1:0] 				app_wr_data         ; // Write Data
	logic [APP_BW-1:0] 				app_wr_en_n         ; // Byte wise Write Enable
} APP_REQUEST_SIGNALS;
APP_REQUEST_SIGNALS app_req_signals;

		
//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
typedef struct {
	logic [1:0]             			cfg_colbits         ; // 2'b00 - 8 Bit column address, 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits
	logic [3:0] 					cfg_sdr_tras_d      ; // Active to precharge delay
	logic [3:0]             			cfg_sdr_trp_d       ; // Precharge to active delay
	logic [3:0]            				cfg_sdr_trcd_d      ; // Active to R/W delay
	logic 						cfg_sdr_en          ; // Enable SDRAM controller
	logic [1:0] 					cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
	logic [12:0] 					cfg_sdr_mode_reg    ;
	logic [2:0] 					cfg_sdr_cas         ; // SDRAM CAS Latency
	logic [3:0] 					cfg_sdr_trcar_d     ; // Auto-refresh period
	logic [3:0]            				cfg_sdr_twr_d       ; // Write recovery delay
	logic [`SDR_RFSH_TIMER_W-1 : 0] 		cfg_sdr_rfsh;
	logic [`SDR_RFSH_ROW_CNT_W -1 : 0] 		cfg_sdr_rfmax;
	//logic                   			app_req_dma_last;    // this signal should close the bank
} CONFIG_SIGNALS;
CONFIG_SIGNALS cfg_signals;


endinterface: dut_in

interface dut_out;
//------------------------------------------------
//	SDRAM IF signals
//------------------------------------------------
typedef struct {
	// command 
	logic			sdr_cs_n;
	logic			sdr_cke;
	logic			sdr_ras_n;
	logic			sdr_cas_n;
	logic			sdr_we_n;	
	logic			sdr_init_done;
	
	// address
	logic			sdr_ba;	
	logic			sdr_addr;
	
	// data
	logic	[SDR_BW-1:0]	sdr_dqm; 	//SDRAM Data Mask
	logic	[SDR_DW-1:0]	pad_sdr_din; 	//data read from SDRAM 
	logic	[SDR_DW-1:0]	sdr_dout;	//data written to SDRAM 
	logic	[SDR_BW-1:0]	sdr_den_n;	//SDRAM Data Enable
} SDRAM_IF_SIGNALS;
SDRAM_IF_SIGNALS sdr_signals;
//------------------------------------------------
//	Application IF signals
//------------------------------------------------
typedef struct {
	logic			app_req_ack;
	logic 			app_wr_next_req;// next Write Data Request
	logic	[APP_DW-1:0]	app_rd_data;				
	logic			app_rd_valid;
	logic			app_last_rd;	// last Read Valid
	logic 			app_last_wr;	// last Write Valid
} APP_OUT_SIGNALS;
APP_OUT_SIGNALS app_out_signals;

endinterface: dut_out

