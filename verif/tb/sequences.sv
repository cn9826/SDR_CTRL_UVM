`include "uvm_macros.svh"
`include "constants.sv"
package sequences;
import uvm_pkg::*;

class app_transaction_in extends uvm_sequence_item;	
	`uvm_object_utils (app_transaction_in)
	logic				reset_n;
	logic				app_req;
	logic	   [`APP_BW-1:0]	app_wr_en_n;
	logic				app_req_wr_n;
	rand logic			app_req_len;
	rand logic [`APP_AW-1 : 0]	app_req_addr;
	rand logic 			app_wr_data;
	rand logic			app_req_wrap;

	function new (string name = "");
		super.new(name);
	endfunction

endclass: app_transaction_in

class app_transaction_out extends uvm_sequence_item;
	`uvm_object_utils (app_transaction_out)
	logic				app_req_ack;
	logic				app_wr_next_req;
	logic	[`APP_DW-1 : 0]		app_rd_data;

	function new (string name = "")
		super.new(name);
	endfunction

endclass: app_transaction_out

class sdr_transaction_out extends uvm_sequence_item;
	`uvm_object_utils (sdr_transaction_out)

	// command
	logic			sdr_cs_n;
	logic			sdr_cke;
	logic			sdr_ras_n;
	logic			sdr_cas_n;
	logic			sdr_we_n;	
	logic			sdr_init_done;
	
	//address
	logic			sdr_ba;
	logic			sdr_addr;

	// data
	logic	[`SDR_BW-1:0]	sdr_dqm; 	//SDRAM Data Mask
	logic	[`SDR_DW-1:0]	pad_sdr_din; 	//data read from SDRAM 
	logic	[`SDR_DW-1:0]	sdr_dout;	//data written to SDRAM 
	logic	[`SDR_BW-1:0]	sdr_den_n;	//SDRAM Data Enable
	
	function new (string name = "")
		super.new(name);
	endfunction

endclass: sdr_transaction_out

class reset_seq extends uvm_sequence #(app_transaction_in);
	`uvm_object_utils(reset_seq)
	o
	function new(string name = "");
		super.new(name);
	endfunction

	task body;
		app_transaction_in 	app_tx_in;
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	0;
		app_tx_in.app_req	=	0;o
		app_tx_in.app_req_addr	=	0;
		app_tx_in.app_req_wr_n	=	0;
		app_tx_in.app_req_wrap 	=	1;
		app_tx_in.app_wr_data	= 	0;
		app_tx_in.app_wr_en_n	=	4'hF;
		app_tx_in.app_req_len 	=	0;
		finish_item(app_tx_in);
	endtask: body
endclass:reset_seq

class seq_of_commands extends uvm_sequence #(app_transaction_in)
	`uvm_object_utils(seq_of_commands)

	// declare a p_sequencer handle
	`uvm_declare_p_sequencer(uvm_sequencer#(app_transaction_in))

	function new (string name = "");
		super.new(name);
	endfunction

	task body;
		// reset sequence
		for (int i = 0; i<10; i++)begin
			reset_seq seq1 = reset_seq::type_id::create("seq1");
			seq1.start(p_sequencer);
		end
		
		// initialization sequence
		for (int i = 0; i<10000; i++)begin
			init_seq seq2 = init_seq::type_id::create("seq2");
			seq2.start(p_sequencer);
		end
		
		// write sequence
		for (int i = 0; i<10; i++)begin
			wr_seq seq3 = init_seq::type_id::create("seq3");
			assert(seq3.randomize());
			seq3.start(p_sequencer);
		end
		
		// read sequence
		for (int i = 0; i<10; i++)begin
			rd_seq seq4 = init_seq::type_id::create("seq4");
			seq4.start(p_sequencer);
		end
	endtask:body
endclass:seq_of_commands

endpackage: sequences;
