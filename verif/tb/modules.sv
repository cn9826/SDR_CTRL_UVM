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
			dut_vi_in.reset_n = app_tx_in.reset_n;
			dut_vi_in.app_req = app_tx_in.app_req;
                	dut_vi_in.app_wr_en_n = app_tx_in.app_wr_en_n;
                	dut_vi_in.app_req_wr_n = app_tx_in.app_req_wr_n;
                	dut_vi_in.app_req_len = app_tx_in.app_req_len;
                	dut_vi_in.app_req_addr = app_tx_in.app_req_addr;
                	dut_vi_in.app_wr_data = app_tx_in.app_wr_data;
                	dut_vi_in.app_req_wrap = app_tx_in.app_req_wrap;
		end
	endtask:run_phase
endclass:app_driver_in




endpackage:modules_pkg 
