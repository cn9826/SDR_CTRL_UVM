`define  APP_AW    26  // Application Address Width
`define  APP_DW    32  // Application Data Width 
`define  APP_BW    4  // Application Byte Width
`define  APP_RW    9  // Application Request Width

`define  SDR_DW    8 // SDR Data Width 
`define  SDR_BW    1   // SDR Byte Width

`define SDR_RFSH_TIMER_W 	12
`define SDR_RFSH_ROW_CNT_W	 3

// configuration parameters defined as constants
`define cfg_colbits		2'b00	// 8 Bit Column Address
`define cfg_sdr_tras_d		4'h4	// SDRAM ACTIVE to PRECHARGE, specified in clocks 
`define cfg_sdr_trp_d  		4'h4 	// SDRAM precharge command period (tRP), specified in clocks 
`define cfg_sdr_trcd_d 		4'h4	// SDRAM Row-to-Column latency, specified in clocks 
`define cfg_sdr_en  		1'b1   	// SDRAM controller enable 
`define cfg_req_depth   	2'h3	// how many req. buffer should hold
`define cfg_sdr_mode_reg	13'h033	// SDRAM Mode Register
`define cfg_sdr_cas    		3'h3	// CAS latency 
`define cfg_sdr_trcar_d 	4'h7	// SDRAM ACTIVE to ACVITE/AUTO-REFRESH command period (tRC)
`define cfg_sdr_twr_d  		4'h1 	// SDRAM write recover time (tWR)
`define cfg_sdr_rfsh;		12'h100	// period between AUTO-REFRESH commands issued by the controller
`define cfg_sdr_rfmax;		3'h6	// maximum number of rows to be refreshed at a time (tRFSH)
