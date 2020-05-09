`include "constants.sv"

module DUT
(
// General 
	sdram_clk,
	sdram_clk_d,
	pad_clk,
	reset_n,

// Application Interface IN
	app_req,
	app_req_len,
	app_req_addr,
	app_req_wr_n,
	app_req_wrap,
	app_wr_data,
	app_wr_en_n,

// Application Interface OUT
	app_req_ack,
	app_wr_next_req,
	app_rd_data,
	app_rd_valid,
	app_last_rd,
	app_last_wr,

// SDRAM I/F OUT
	Dq,
	sdr_dout,
	pad_sdr_din,
	sdr_den_n,
	sdr_dqm,
	
	sdr_ba,
	sdr_addr,

	sdr_cs_n,
	sdr_cke,
	sdr_ras_n,
	sdr_cas_n,
	sdr_we_n,
	sdr_init_done
);

//-------------------------------------------
// General
//-------------------------------------------
input			sdram_clk;
input			sdram_clk_d;
input			pad_clk;	
input			reset_n;

//-------------------------------------------
// Application Inteface IN 
//-------------------------------------------
input                 app_req            ; // Application Request
input  	[8:0]         app_req_len        ; // Burst Request length
input 	[25:0]        app_req_addr       ; // Application Address
input                 app_req_wr_n       ; // 1 -> Read, 0 -> Write
input		      app_req_wrap	 ; // Address Wrap
input	[`APP_DW-1:0] app_wr_data	 ; // Write Data
input 	[`APP_BW-1:0] app_wr_en_n        ; // Byte-wise Write Enable


parameter      dw              = 32;  // data width
parameter      tw              = 8;   // tag id width
parameter      bl              = 5;   // burst_lenght_width 

//-------------------------------------------
// Application Interface OUT
//-------------------------------------------
output	reg          		 app_req_ack        	; // Application Request Ack
output	reg	     		 app_wr_next_req	; // next Write Data Request
output	reg [`APP_DW-1:0]        app_rd_data        	; // Read Data
output	reg	                 app_rd_valid       	; // Read Valid
output	reg                  	 app_last_rd        	; // Last Read Valid
output	reg                  	 app_last_wr        	; // Last Write Valid

//--------------------------------------------
// SDRAM I/F OUT 
//--------------------------------------------
// Data
`ifdef SDR_32BIT
output   wire [31:0]           Dq                 ; // SDRAM Read/Write Data Bus
output   wire [31:0]           sdr_dout           ; // SDRAM Data Out
output   wire [31:0]           pad_sdr_din        ; // SDRAM Data Input
output   wire [3:0]            sdr_den_n          ; // SDRAM Data Enable
output   wire [3:0]            sdr_dqm            ; // SDRAM DATA Mask
`elsif SDR_16BIT 
output   wire [15:0]           Dq                 ; // SDRAM Read/Write Data Bus
output   wire [15:0]           sdr_dout           ; // SDRAM Data Out
output   wire [15:0]           pad_sdr_din        ; // SDRAM Data Input
output   wire [1:0]            sdr_den_n          ; // SDRAM Data Enable
output   wire [1:0]            sdr_dqm            ; // SDRAM DATA Mask
`else 
output   wire [7:0]           Dq                 ; // SDRAM Read/Write Data Bus
output   wire [7:0]           sdr_dout           ; // SDRAM Data Out
output   wire [7:0]           pad_sdr_din        ; // SDRAM Data Input
output   wire [0:0]           sdr_den_n          ; // SDRAM Data Enable
output   wire [0:0]           sdr_dqm            ; // SDRAM DATA Mask
`endif
// address
output	wire [1:0]            sdr_ba             ; // SDRAM Bank Select
output	wire [12:0]           sdr_addr           ; // SDRAM ADRESS

// command
output 	reg			sdr_cs_n;
output	reg			sdr_cke;
output 	reg			sdr_ras_n;
output 	reg			sdr_cas_n;
output 	reg			sdr_we_n;	
output	reg			sdr_init_done      ; // SDRAM Init Done 


`ifdef SDR_32BIT
   sdrc_core #(.SDR_DW(32),.SDR_BW(4)) u_dut(
`elsif SDR_16BIT 
   sdrc_core #(.SDR_DW(16),.SDR_BW(2)) u_dut(
`else  // 8 BIT SDRAM
   sdrc_core #(.SDR_DW(8),.SDR_BW(1)) u_dut(
`endif
      // System 
          .clk                (sdram_clk          ),
          .reset_n            (reset_n             ),
          .pad_clk            (pad_clk            ), 
`ifdef SDR_32BIT
          .sdr_width          (2'b00              ), // 32 BIT SDRAM
`elsif SDR_16BIT
          .sdr_width          (2'b01              ), // 16 BIT SDRAM
`else 
          .sdr_width          (2'b10              ), // 8 BIT SDRAM
`endif
          .cfg_colbits        (2'b00              ), // 8 Bit Column Address


/* Request from app */
          .app_req            (app_req            ),	// Transfer Request
          .app_req_addr       (app_req_addr       ),	// SDRAM Address
          .app_req_len        (app_req_len        ),	// Burst Length (in 16 bit words)
          .app_req_wrap       (app_req_wrap       ),	// Wrap mode request (xfr_len = 4)
          .app_req_wr_n       (app_req_wr_n       ),	// 0 => Write request, 1 => read req
          .app_req_ack        (app_req_ack        ),	// Request has been accepted
		
          .app_wr_data        (app_wr_data        ),
          .app_wr_en_n        (app_wr_en_n        ),
          .app_rd_data        (app_rd_data        ),
          .app_last_rd        (app_last_rd        ),
          .app_last_wr        (app_last_wr        ),
          .app_rd_valid       (app_rd_valid       ),
          .app_wr_next_req    (app_wr_next_req    ),
          .app_req_dma_last   (app_req            ),

/* Interface to SDRAMs */
          .sdr_cs_n           (sdr_cs_n           ),
          .sdr_cke            (sdr_cke            ),
          .sdr_ras_n          (sdr_ras_n          ),
          .sdr_cas_n          (sdr_cas_n          ),
          .sdr_we_n           (sdr_we_n           ),
          .sdr_dqm            (sdr_dqm            ),
          .sdr_ba             (sdr_ba             ),
          .sdr_addr           (sdr_addr           ), 
          .pad_sdr_din        (Dq                 ),
          .sdr_dout           (sdr_dout           ),
          .sdr_den_n          (sdr_den_n          ),

    /* Parameters */
          .sdr_init_done      (sdr_init_done      ),
          .cfg_req_depth      (2'h3               ),	        //how many req. buffer should hold
          .cfg_sdr_en         (1'b1               ),
          .cfg_sdr_mode_reg   (13'h033            ),
          .cfg_sdr_tras_d     (4'h4               ),
          .cfg_sdr_trp_d      (4'h2               ),
          .cfg_sdr_trcd_d     (4'h2               ),
          .cfg_sdr_cas        (3'h3               ),
          .cfg_sdr_trcar_d    (4'h7               ),
          .cfg_sdr_twr_d      (4'h1               ),
          .cfg_sdr_rfsh       (12'h100            ), // reduced from 12'hC35
          .cfg_sdr_rfmax      (3'h6               )

);


`ifdef SDR_32BIT
  assign Dq[7:0]    = (sdr_den_n[0] == 1'b0) ? sdr_dout[7:0]   : 8'hZZ;
  assign Dq[15:8]   = (sdr_den_n[1] == 1'b0) ? sdr_dout[15:8]  : 8'hZZ;
  assign Dq[23:16]  = (sdr_den_n[2] == 1'b0) ? sdr_dout[23:16] : 8'hZZ;
  assign Dq[31:24]  = (sdr_den_n[3] == 1'b0) ? sdr_dout[31:24] : 8'hZZ;
mt48lc2m32b2 #(.data_bits(32)) u_sdram32 (
          .Dq                 (Dq                 ) , 
          .Addr               (sdr_addr[10:0]     ), 
          .Ba                 (sdr_ba             ), 
          .Clk                (sdram_clk_d        ), 
          .Cke                (sdr_cke            ), 
          .Cs_n               (sdr_cs_n           ), 
          .Ras_n              (sdr_ras_n          ), 
          .Cas_n              (sdr_cas_n          ), 
          .We_n               (sdr_we_n           ), 
          .Dqm                (sdr_dqm            )
     );

`elsif SDR_16BIT

assign Dq[7:0]  = (sdr_den_n[0] == 1'b0) ? sdr_dout[7:0]  : 8'hZZ;
assign Dq[15:8] = (sdr_den_n[1] == 1'b0) ? sdr_dout[15:8] : 8'hZZ;

   IS42VM16400K u_sdram16 (
          .dq                 (Dq                 ), 
          .addr               (sdr_addr[11:0]     ), 
          .ba                 (sdr_ba             ), 
          .clk                (sdram_clk_d        ), 
          .cke                (sdr_cke            ), 
          .csb                (sdr_cs_n           ), 
          .rasb               (sdr_ras_n          ), 
          .casb               (sdr_cas_n          ), 
          .web                (sdr_we_n           ), 
          .dqm                (sdr_dqm            )
    );
`else 

assign Dq[7:0]  = (sdr_den_n[0] == 1'b0) ? sdr_dout[7:0]  : 8'hZZ;

mt48lc8m8a2 #(.data_bits(8)) u_sdram8 (
          .Dq                 (Dq                 ) , 
          .Addr               (sdr_addr[11:0]     ), 
          .Ba                 (sdr_ba             ), 
          .Clk                (sdram_clk_d        ), 
          .Cke                (sdr_cke            ), 
          .Cs_n               (sdr_cs_n           ), 
          .Ras_n              (sdr_ras_n          ), 
          .Cas_n              (sdr_cas_n          ), 
          .We_n               (sdr_we_n           ), 
          .Dqm                (sdr_dqm            )
     );
`endif
endmodule
