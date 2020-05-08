`include "uvm_macros.svh"
`include "constants.sv"
package modules_pkg;


import uvm_pkg::*;
import sequences::*;

typedef uvm_sequencer #(app_transaction_in) app_sequencer_in;

class sdr_dut_config extends uvm_object;
	`uvm_object_utils(sdr_dut_config)
	
	virtual dut_in	dut_vi_in;
	virtual	dut_out	dut_vi_out;

endclass:sdr_dut_config

class app_driver_in extends uvm_driver#(app_transaction_in); 
	`uvm_component_utils(app_driver_in)
	
	sdr_dut_config	dut_config_0;
	virtual	dut_in	dut_vi_in;

	function new (string name, uvm_component parent);
		super.name(name, parent);
	endfunction:new

	function void build_phase(uvm_phase phase);
		assert (uvm_config_db #(sdr_dut_config)::get(this, "", "dut_config", dut_config_0));
		dut_vi_in = dut_config_0.dut_vi_in;
	endfunction: buid_phase
	
	task run_phase(uvm_phase phase);
		forever begin
			dut_vi_in.sdram_clk_d = #2 dut_vi_in.sdram_clk;
			dut_vi_in.pad_clk = #1 sdram_clk_d;
			
			//drive dut_vi_in signals from transactions
			app_transaction_in app_tx_in;
			@ (negedge dut_vi_in.sdram_clk);
			seq_item_port.get(app_tx_in);
			dut_vi_in.reset_n 	= 	app_tx_in.reset_n;
			dut_vi_in.app_req 	= 	app_tx_in.app_req;
                	dut_vi_in.app_wr_en_n 	= 	app_tx_in.app_wr_en_n;
                	dut_vi_in.app_req_wr_n 	= 	app_tx_in.app_req_wr_n;
                	dut_vi_in.app_req_len 	= 	app_tx_in.app_req_len;
                	dut_vi_in.app_req_addr 	= 	app_tx_in.app_req_addr;
                	dut_vi_in.app_wr_data 	= 	app_tx_in.app_wr_data;
                	dut_vi_in.app_req_wrap 	= 	app_tx_in.app_req_wrap;
		end
	endtask:run_phase
endclass:app_driver_in

class app_monitor_in extends uvm_monitor;
// responsible for capturing signal activity from the design interface 
// and translate it into transaction level data objects that can be sent to other components
// It requires a virtual interface handle
// and TLM Analysis Port declarations to broadcast captured data to others
	`uvm_component_utils(app_monitor_in);
	uvm_analysis_port #(app_transaction_in) aport;
	virtual dut_in 	dut_vi_in;		

	function new(string name, uvm_component parent);
		super.new(name, parent);	
	endfunction:new

	function void build_phase(uvm_phase phase);
		//dut_config_0 = sdr_dut_config::type_id::create("config");
		aport = new("aport",this);
		assert( uvm_config_db#(sdr_dut_config)::get(this, "", "dut_config", dut_config_0));
		dut_vi_in = dut_config_0.dut_vi_in; 
	endfunction:build_phase
	
	task run_phase(uvm_phase phase);
		// to introduce 1 clk cycle delay after the interface signal wiggles have happend 
		@(negedge dut_vi_in.sdram_clk);
		forever begin
			app_transaction_in app_tx_in;
			@(negedge dut_vi_in.sdram_clk);
			app_tx_in.reset_n	=	dut_vi_in.reset_n;     
			app_tx_in.app_req       =       dut_vi_in.app_req;     
			app_tx_in.app_wr_en_n   =       dut_vi_in.app_wr_en_n; 
			app_tx_in.app_req_wr_n  =       dut_vi_in.app_req_wr_n;
			app_tx_in.app_req_len   =       dut_vi_in.app_req_len; 
			app_tx_in.app_req_addr  =       dut_vi_in.app_req_addr;
			app_tx_in.app_wr_data   =       dut_vi_in.app_wr_data; 
			app_tx_in.app_req_wrap  =       dut_vi_in.app_req_wrap;
			// send specified values to all connected interface
			aport.write(app_tx_in);
		end
	endtask: run_phase
endclass:app_monitor_in

class app_monitor_out extends uvm_monitor;
	`uvm_component_utils(app_monitor_out)
	uvm_analysis_port #(app_transaction_out) aport;
	sdr_dut_config	dut_config_0;
	virtual dut_out	dut_vi_out;

	function new(string name, uvm_component parent);
		super.new(name, parent)
	endfunction:new

	function void build_phase(uvm_phase phase);
		//dut_config_0 = sdr_dut_config::type_id::create("config");
		aport = new("aport", this);	
		assert ( uvm_config_db#(sdr_dut_config)::get(this, "", "dut_config", dut_config_0));
		dut_vi_out = dut_config_0.dut_vi_out;	
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		@(negedge dut_vi_out.sdram_clk);	
		@(negedge dut_vi_out.sdram_clk);
		forever begin
			app_transaction_out	app_tx_out;
			
			@(negedge dut_vi_out.sdram_clk);
			// command
			app_tx_out.sdr_cs_n		=	dut_vi_out.sdr_cs_n;		
        	        app_tx_out.sdr_cke      	=	dut_vi_out.sdr_cke;
        	        app_tx_out.sdr_ras_n    	=	dut_vi_out.sdr_ras_n;
        	        app_tx_out.sdr_cas_n    	=	dut_vi_out.sdr_cas_n;
        	        app_tx_out.sdr_we_n     	=	dut_vi_out.sdr_we_n;	
        	        app_tx_out.sdr_init_done	=	dut_vi_out.sdr_init_done;
        	        
			//address
			app_tx_out.sdr_ba  		=	dut_vi_out.sdr_ba;
        	        app_tx_out.sdr_addr		=	dut_vi_out.sdr_addr;
        	       
		       	//
			app_tx_out.sdr_dqm 		=	dut_vi_out.sdr_dqm; 	
        	        app_tx_out.pad_sdr_din		=	dut_vi_out.pad_sdr_din;	
        	        app_tx_out.sdr_dout		=	dut_vi_out.sdr_dout;	
        	        app_tx_out.sdr_den_n		=	dut_vi_out.sdr_den_n;	
		end
	endtask:run_phase
endclass:app_moniter_out




endpackage:modules_pkg 
