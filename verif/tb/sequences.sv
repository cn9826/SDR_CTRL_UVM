`include "uvm_macros.svh"
`include "constants.sv"
package sequences;

import uvm_pkg::*;

class sdr_dut_config extends uvm_object;
	`uvm_object_utils(sdr_dut_config)
	
	virtual dut_in	dut_vi_in;
	virtual	dut_out	dut_vi_out;

endclass:sdr_dut_config

class queue_write extends uvm_object;
	`uvm_object_utils(queue_write)

	// fifo to store and pop app layer write address
	logic	[`APP_AW-1:0]	fifo_wr_addr_in[$];
	// fifo to store and pop app layer write data	
	logic	[`APP_DW-1:0]	fifo_wr_data_in[$];	
	// index of the burst write sequence
	int			fifo_wr_idx_in[$];
	function void push_addr_data_idx(input logic [`APP_AW-1:0] wr_addr, 
				     input logic [`APP_DW-1:0] wr_data,
				     int burst_wr_idx);
		fifo_wr_addr_in.push_back(wr_addr);
		fifo_wr_data_in.push_back(wr_data);
		fifo_wr_idx_in.push_back(burst_wr_idx);
	endfunction: push_addr_data_idx
	
	function logic [`APP_AW-1:0] pop_addr();
		return (fifo_wr_addr_in.pop_front());
	endfunction: pop_addr
	
	function logic [`APP_DW-1:0] pop_data();
		return (fifo_wr_data_in.pop_front());
	endfunction: pop_data
	
	function int pop_idx();
		return (fifo_wr_idx_in.pop_front());
	endfunction: pop_idx

endclass:queue_write

class app_transaction_in extends uvm_sequence_item;	
	`uvm_object_utils (app_transaction_in)
	logic				reset_n;
	logic				app_req;
	logic	   [`APP_BW-1:0]	app_wr_en_n;
	logic				app_req_wr_n;
	logic	   [`APP_RW-1:0]  	app_req_len;	// can be random later
	rand logic [`APP_AW-1 : 0]	app_req_addr;
	rand logic [`APP_DW-1:  0]	app_wr_data;
	logic				app_req_wrap;	// can be random later

	function new (string name = "");
		super.new(name);
	endfunction

endclass: app_transaction_in

class app_transaction_out extends uvm_sequence_item;
	`uvm_object_utils (app_transaction_out)
	logic				app_req_ack;
	logic				app_wr_next_req;
	logic	[`APP_DW-1 : 0]		app_rd_data;

	function new (string name = "");
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
	
	function new (string name = "");
		super.new(name);
	endfunction

endclass: sdr_transaction_out

class reset_seq extends uvm_sequence #(app_transaction_in);
	`uvm_object_utils(reset_seq)
	
	function new(string name = "");
		super.new(name);
	endfunction

	task body;
		app_transaction_in 	app_tx_in;
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	0;
		app_tx_in.app_req	=	0;
		app_tx_in.app_req_addr	=	0;
		app_tx_in.app_req_wr_n	=	0;
		app_tx_in.app_req_wrap 	=	1;
		app_tx_in.app_wr_data	= 	0;
		app_tx_in.app_wr_en_n	=	4'hF;
		app_tx_in.app_req_len 	=	0;
		finish_item(app_tx_in);
	endtask: body
endclass:reset_seq

class init_seq extends uvm_sequence #(app_transaction_in);
	`uvm_object_utils(init_seq)
	
	task body;
		app_transaction_in app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;
		app_tx_in.app_req	=	0;
		app_tx_in.app_req_addr	=	0;
		app_tx_in.app_req_wr_n	=	0;
		app_tx_in.app_req_wrap 	=	1;
		app_tx_in.app_wr_data	= 	0;
		app_tx_in.app_wr_en_n	=	4'hF;
		app_tx_in.app_req_len 	=	0;
		finish_item(app_tx_in);
	endtask:body
endclass:init_seq

class write_seq_row2col extends uvm_sequence #(app_transaction_in);
	`uvm_object_utils(write_seq_row2col)
	app_transaction_in app_tx_in;

	task body;	
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		assert(app_tx_in.randomize());
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	1;	
		app_tx_in.app_req_wr_n	=	0;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		uvm_config_db #(app_transaction_in)::set(null,"uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_row2col_tx_in", app_tx_in);
		finish_item(app_tx_in);
	endtask: body
endclass:write_seq_row2col

class write_seq_row2col_reqheld extends uvm_sequence #(app_transaction_in);
	`uvm_object_utils(write_seq_row2col_reqheld)
	 app_transaction_in		row2col_tx_in;
	task body;
		app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_row2col_tx_in", row2col_tx_in))
			`uvm_error("ROW2COL_REQHELD_PREV_TX", "Could not get the previous randomized requested app_tx_in in \"write_seq_row2col_reqheld\" sequence")
				
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	1;	
		app_tx_in.app_req_wr_n	=	0;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	row2col_tx_in.app_req_addr;
		app_tx_in.app_wr_data	=	row2col_tx_in.app_wr_data;
		finish_item(app_tx_in);
	endtask: body
endclass:write_seq_row2col_reqheld

class write_seq_wait1 extends uvm_sequence #(app_transaction_in);
// wait sequence after the intial row2col write request is acknowledged in burst write
// both "app_req_addr" and "app_wr_data" remain the same as in row2col_tx_in
	`uvm_object_utils(write_seq_wait1)
	 app_transaction_in		row2col_tx_in;
	
	task body;
		app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_row2col_tx_in", row2col_tx_in))
			`uvm_error("WAIT1_SEQ_PREV_TX", "Could not get the previous randomized requested app_tx_in in \"write_seq_wait1\" sequence")
				
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	0;	
		app_tx_in.app_req_wr_n	=	0;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	row2col_tx_in.app_req_addr;
		app_tx_in.app_wr_data	=	row2col_tx_in.app_wr_data;
		finish_item(app_tx_in);
	endtask: body
endclass:write_seq_wait1

class write_seq_col extends uvm_sequence #(app_transaction_in);
// subsequent burst write requests after the initial row2col request
// "app_req_addr" remains the same as in row2col_tx_in
// "app_wr_data" is randomized again
	`uvm_object_utils(write_seq_col)
	app_transaction_in		row2col_tx_in;
	app_transaction_in		app_tx_in;

	task body;
		//app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_row2col_tx_in", row2col_tx_in))
			`uvm_error("COL_PREV_TX", "Could not get the previous randomized requested app_tx_in in \"write_seq_col\" sequence")
				
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		app_tx_in.app_req_addr.rand_mode(0);
		start_item(app_tx_in);
		assert(app_tx_in.randomize());	// app_wr_data is randomized	
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	0;	
		app_tx_in.app_req_wr_n	=	0;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	row2col_tx_in.app_req_addr;
		uvm_config_db #(app_transaction_in)::set(null,"uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_col_tx_in", app_tx_in);
		finish_item(app_tx_in);
	endtask: body
endclass:write_seq_col

class write_seq_wait2 extends uvm_sequence #(app_transaction_in);
// wait sequence between subsequent write_seq_col sequences 
// both "app_req_addr" and "app_wr_data" remain the same as in col_tx_in
	`uvm_object_utils(write_seq_wait2)
	 app_transaction_in		col_tx_in;
	
	task body;
		app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_col_tx_in", col_tx_in))
			`uvm_error("WAIT2_SEQ_PREV_TX", "Could not get the previous randomized requested app_tx_in in \"write_seq_wait2\" sequence")
				
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	0;	
		app_tx_in.app_req_wr_n	=	0;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	col_tx_in.app_req_addr;
		app_tx_in.app_wr_data	=	col_tx_in.app_wr_data;
		finish_item(app_tx_in);
	endtask: body
endclass:write_seq_wait2

class write_read_intld extends uvm_sequence #(app_transaction_in);
// interlude sequence between the end of write sequence
// and the beginning of read sequence
// app_wr_data is held the same as in the last burst write
	`uvm_object_utils(write_read_intld)
	 
	app_transaction_in		col_tx_in;
	
	task body;
		app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_col_tx_in", col_tx_in))
			`uvm_error("INTLD_SEQ_PREV_TX", "Could not get the previous randomized requested app_tx_in in \"write_read_intld\" sequence")
				
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	0;	
		app_tx_in.app_req_wr_n	=	1'hx;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'hx;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	`APP_AW'hx;
		app_tx_in.app_wr_data	=	col_tx_in.app_wr_data;
		finish_item(app_tx_in);
	endtask: body

endclass: write_read_intld

class read_seq_row2col extends uvm_sequence #(app_transaction_in);
// the initial row2col read request
// both "app_wr_data", "app_req_addr" remains the same as in row2col_tx_in
	`uvm_object_utils(read_seq_row2col)
	app_transaction_in		row2col_tx_in;
	int				num_self_checks;
	queue_write			fifo_write;	

	task body;
		app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "write_seq_row2col_tx_in", row2col_tx_in))
			`uvm_error("READ_ROW2COL_SEQ_PREV_TX", "Could not get the previous randomized requested app_tx_in in \"read_seq_row2col\" sequence")

		// get num_self_checks;
		if (!uvm_config_db #(int)::get(null, "uvm_test_top.top_env_0.*", "num_self_checks", num_self_checks))
			`uvm_fatal("READ_SEQ_ROW2COL_SEQ_NUM_CHECKS", "Could not find \"num_self_checks\" from config DB")
		if (num_self_checks > 1) begin
			// get queue fifo for write seuqnece;
			if (!uvm_config_db #(queue_write)::get(null, "uvm_test_top.top_env_0.*", "queue_write", fifo_write))
				`uvm_fatal("READ_SEQ_RWO2COL_NUM_CHECKS", "Could not find \"fifo_write\" from config DB")
		end
		
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	1;	
		app_tx_in.app_req_wr_n	=	1;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	(num_self_checks == 1) ? row2col_tx_in.app_req_addr : (fifo_write.pop_addr());
		app_tx_in.app_wr_data   = 	row2col_tx_in.app_wr_data;
		if (num_self_checks > 1) begin
			fifo_write.pop_data();
			fifo_write.pop_idx();
			// pop additional app_req_len - 1 times from queue fifo
			for (int i= 0; i < app_tx_in.app_req_len-1; i++) begin
				fifo_write.pop_addr();
				fifo_write.pop_data();
				fifo_write.pop_idx();
			end
			uvm_config_db #(queue_write)::set(null, "uvm_test_top.*", "queue_write", fifo_write);	
		end
		uvm_config_db #(app_transaction_in)::set(null,"uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "read_seq_row2col_tx_in", app_tx_in);
		finish_item(app_tx_in);
	endtask: body
endclass:read_seq_row2col

class read_seq_row2col_reqheld extends uvm_sequence #(app_transaction_in);
// to follow "read_seq_row2col" sequence if request is not acknowledged 
	`uvm_object_utils(read_seq_row2col_reqheld)
	 app_transaction_in		row2col_tx_in;
	task body;
		app_transaction_in app_tx_in;
		
		if (!uvm_config_db#(app_transaction_in)::get(null, "uvm_test_top.top_env_0.app_agent_in_0.app_sequencer_in_0.*", "read_seq_row2col_tx_in", row2col_tx_in))
			`uvm_error("ROW2COL_REQHELD_PREV_TX", "Could not get the previous randomized requested \"read_seq_row2col_tx_in\" in \"read_seq_row2col_reqheld\" sequence")
				
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	1;	
		app_tx_in.app_req_wr_n	=	1;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		app_tx_in.app_req_addr	=	row2col_tx_in.app_req_addr;
		app_tx_in.app_wr_data	=	row2col_tx_in.app_wr_data;
		finish_item(app_tx_in);
	endtask: body
endclass:read_seq_row2col_reqheld


class read_seq_wait1 extends uvm_sequence #(app_transaction_in);
// wait sequence after the intial row2col read request is acknowledged in burst read 
// both "app_req_addr" and "app_wr_data" don't need to be driven 
	`uvm_object_utils(read_seq_wait1)
//	 app_transaction_in		row2col_tx_in;
	
	task body;
		app_transaction_in app_tx_in;
		
		app_tx_in = app_transaction_in::type_id::create("app_tx_in");
		start_item(app_tx_in);
		app_tx_in.reset_n	=	1;	
		app_tx_in.app_req	=	0;	
		app_tx_in.app_req_wr_n	=	1;	
		app_tx_in.app_req_wrap 	=	0;
		app_tx_in.app_wr_en_n	=	4'h0;	
		app_tx_in.app_req_len 	=	9'h4;
		//app_tx_in.app_req_addr	=	row2col_tx_in.app_req_addr;
		//app_tx_in.app_wr_data	=	row2col_tx_in.app_wr_data;
		finish_item(app_tx_in);
	endtask: body
endclass:read_seq_wait1


class seq_of_commands_single extends uvm_sequence #(app_transaction_in);
	`uvm_object_utils(seq_of_commands_single)

	// declare a p_sequencer handle
	`uvm_declare_p_sequencer(uvm_sequencer#(app_transaction_in))

	sdr_dut_config 		dut_config_0;
	virtual dut_out 	dut_vi_out;
	virtual dut_in		dut_vi_in;
	
	int	rd_valid_cnt;	

	function new (string name = "");
		super.new(name);
	endfunction

	task body;

		reset_seq 			seq1;
		init_seq 			seq2;
		write_seq_row2col 		seq3;
		write_seq_row2col_reqheld	seq4;
		write_seq_wait1			seq5;
		write_seq_col			seq6;
		write_seq_wait2			seq7;
		write_read_intld		seq8;
		read_seq_row2col		seq9;
		read_seq_row2col_reqheld	seq10;
		read_seq_wait1			seq11;

		if (!uvm_config_db #(sdr_dut_config)::get(null, "uvm_test_top.top_env_0.*", "dut_config", dut_config_0))
			`uvm_error("SEQ_COMMD_CONFIG", "Could not find a \"sdr_dut_config\" handle")
		
		dut_vi_in  = dut_config_0.dut_vi_in;
		dut_vi_out = dut_config_0.dut_vi_out;

		//---------------------------
		// reset sequence
		//---------------------------
		for (int i = 0; i<4; i++) begin
			seq1 = reset_seq::type_id::create("seq1");
			seq1.start(p_sequencer);
		end
		//---------------------------
		//initialization sequence:
		//---------------------------
		//150 cycles before sdr_init_done is HIGH
		for (int i = 0; i<151; i++) begin
			seq2 = init_seq::type_id::create("seq2");
			seq2.start(p_sequencer);
		end

		//---------------------------
		// Burst Write Sequence:		
		//---------------------------
		// write sequence row2column called once
		seq3 = write_seq_row2col::type_id::create("seq3");
		assert(seq3.randomize());	
		seq3.start(p_sequencer);

		// write sequence row2column reqheld called until app_req_ack is HIGH 
		while (!dut_vi_out.app_req_ack) begin
			seq4 = write_seq_row2col_reqheld::type_id::create("seq4");
			seq4.start(p_sequencer);
		end

		// wait1 sequence called between when initial row2col write request is acknowledged
		// and subsequent burst write requests 
		while (!dut_vi_out.app_wr_next_req) begin
			seq5 = write_seq_wait1::type_id::create("seq5");
			seq5.start(p_sequencer);
		end
	
		// subsequent burst write sequences	
		for (int i = 0; i < (dut_vi_in.app_req_len-1); i++) begin
			// subsequent burst write sequence called
			seq6 = write_seq_col::type_id::create("seq6");
			seq6.start(p_sequencer);
			`uvm_info("ITER_VAR",$sformatf("Iteration Var i = %2d", i), UVM_LOW);
			`uvm_info("APP_REQ_LEN",$sformatf("dut_vi_in.app_req_len = %3h", dut_vi_in.app_req_len), UVM_LOW);
			while (!dut_vi_out.app_wr_next_req) begin
				// wait2 sequence called between subsequent burst write sequences	
				seq7 = write_seq_wait2::type_id::create("seq7");	
				seq7.start(p_sequencer);
			end
		end

		//Interlude Sequence between Write and Read
		for (int i = 0; i < 5; i++) begin
			seq8 = write_read_intld::type_id::create("seq8");
			seq8.start(p_sequencer);
		end

		//---------------------------
		//Burst Read Sequence
		//---------------------------
		// read sequence row2column called once
		seq9 = read_seq_row2col::type_id::create("seq9");
		seq9.start(p_sequencer);
		
		// read sequence row2column reqheld called until app_req_ack is HIGH 
		while (!dut_vi_out.app_req_ack) begin
			seq10 = read_seq_row2col_reqheld::type_id::create("seq10");
			seq10.start(p_sequencer);
		end

		// read wait sequence is called until rd_valid_cnt == app_req_len
		rd_valid_cnt = 0;
			while (rd_valid_cnt < dut_vi_in.app_req_len) begin
				seq11 = read_seq_wait1::type_id::create("seq11");
				seq11.start(p_sequencer);
				@(negedge dut_vi_out.sdram_clk);
				if (dut_vi_out.app_rd_valid)
					rd_valid_cnt++;
			end
		
	endtask:body
endclass:seq_of_commands_single


class seq_of_commands_multi extends  uvm_sequence #(app_transaction_in);
// combination of write sequences iterated for multiple burst write accesses	
	`uvm_object_utils(seq_of_commands_multi)
	
	// declare a p_sequencer handle
	`uvm_declare_p_sequencer(uvm_sequencer#(app_transaction_in))
		
	queue_write		fifo_write;
	int			num_self_checks;
	sdr_dut_config		dut_config_0;
	virtual dut_out		dut_vi_out;
	virtual dut_in		dut_vi_in;
	int			rd_valid_cnt;

	task body;
		reset_seq			seq_reset;
		init_seq			seq_init;
		write_seq_row2col		seq1;
		write_seq_row2col_reqheld	seq2;
		write_seq_wait1			seq3;
		write_seq_col			seq4;
		write_seq_wait2			seq5;
		write_read_intld		seq6;
		read_seq_row2col		seq7;
		read_seq_row2col_reqheld	seq8;
		read_seq_wait1			seq9;

		// get virtual interfaces
		if (!uvm_config_db #(sdr_dut_config)::get(null, "uvm_test_top.top_env_0.*", "dut_config", dut_config_0))
			`uvm_fatal("CONSCTV_BURST_WR_SEQ_CONFIG", "Could not find a \"sdr_dut_config\" handle")
		
		dut_vi_in  = dut_config_0.dut_vi_in;
		dut_vi_out = dut_config_0.dut_vi_out;

		// get num_self_checks;
		if (!uvm_config_db #(int)::get(null, "uvm_test_top.top_env_0.*", "num_self_checks", num_self_checks))
			`uvm_fatal("CONSCTV_BURST_WR_SEQ_NUM_CHECKS", "Could not find \"num_self_checks\" from config DB")
			
		// get queue fifo for write seuqnece;
		if (!uvm_config_db #(queue_write)::get(null, "uvm_test_top.top_env_0.*", "queue_write", fifo_write))
			`uvm_fatal("CONSCTV_BURST_WR_SEQ_NUM_CHECKS", "Could not find \"fifo_write\" from config DB")
				
		//---------------------------
		// reset sequence
		//---------------------------
		for (int i = 0; i<4; i++) begin
			seq_reset = reset_seq::type_id::create("seq_reset");
			seq_reset.start(p_sequencer);
		end
		//---------------------------
		//initialization sequence:
		//---------------------------
		//150 cycles before sdr_init_done is HIGH
		for (int i = 0; i<151; i++) begin
			seq_init = init_seq::type_id::create("seq_init");
			seq_init.start(p_sequencer);
		end

		
		for (int i = 1; i <= num_self_checks; i++) begin
			//---------------------------
			// Burst Write Sequence:		
			//---------------------------
			// write sequence row2column called once
			seq1 = write_seq_row2col::type_id::create("seq1");
			assert(seq1.randomize());
			seq1.start(p_sequencer);
			fifo_write.push_addr_data_idx(seq1.app_tx_in.app_req_addr,
						      seq1.app_tx_in.app_wr_data,
						      i);

			// write sequence row2column reqheld called until app_req_ack is HIGH 
			while (!dut_vi_out.app_req_ack) begin
				seq2 = write_seq_row2col_reqheld::type_id::create("seq4");
				seq2.start(p_sequencer);
			end

			// wait1 sequence called between when initial row2col write request is acknowledged
			// and subsequent burst write requests 
			while (!dut_vi_out.app_wr_next_req) begin
				seq3 = write_seq_wait1::type_id::create("seq3");
				seq3.start(p_sequencer);
			end
			
			// subsequent burst write sequences	
			for (int j = 0; j < (dut_vi_in.app_req_len-1); j++) begin
				// subsequent burst write sequence called
				seq4 = write_seq_col::type_id::create("seq4");
				seq4.start(p_sequencer);
				fifo_write.push_addr_data_idx(seq4.app_tx_in.app_req_addr,
							      seq4.app_tx_in.app_wr_data,
							      i);

				while (!dut_vi_out.app_wr_next_req) begin
					// wait2 sequence called between subsequent burst write sequences	
					seq5 = write_seq_wait2::type_id::create("seq5");	
					seq5.start(p_sequencer);
				end
			end
		end
		uvm_config_db#(queue_write)::set(null, "uvm_test_top.*", "queue_write", fifo_write);
		
		//Interlude Sequence between Write and Read
		for (int i = 0; i < 5; i++) begin
			seq6 = write_read_intld::type_id::create("seq6");
			seq6.start(p_sequencer);
		end

		for (int i = 1; i <= num_self_checks; i++) begin
			//---------------------------
			// Burst Read Sequence:		
			//---------------------------
			// read sequence row2column called once
			seq7 = read_seq_row2col::type_id::create("seq7");
			seq7.start(p_sequencer);

			// read sequence row2column reqheld called until app_req_ack is HIGH 
			while (!dut_vi_out.app_req_ack) begin
				seq8 = read_seq_row2col_reqheld::type_id::create("seq8");
				seq8.start(p_sequencer);
			end
			// read wait sequence is called until rd_valid_cnt == app_req_len
			rd_valid_cnt = 0;
				while (rd_valid_cnt < dut_vi_in.app_req_len) begin
					seq9 = read_seq_wait1::type_id::create("seq9");
					seq9.start(p_sequencer);
					@(negedge dut_vi_out.sdram_clk);
					if (dut_vi_out.app_rd_valid)
						rd_valid_cnt++;
				end
		end
	endtask:body
endclass: seq_of_commands_multi

endpackage: sequences
