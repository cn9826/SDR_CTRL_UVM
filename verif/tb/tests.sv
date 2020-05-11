package tests;
`include "uvm_macros.svh"
import modules_pkg::*;
import uvm_pkg::*;
import sequences::*;
//import scoreboard::*;

class single_wr_rd_test extends app_only_test; 
	`uvm_component_utils(single_wr_rd_test)
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction:new

	task run_phase(uvm_phase phase);
		seq_of_commands_single 	seq_of_commands_0;
		seq_of_commands_0	= seq_of_commands_single::type_id::create("seq_of_commands_0");
		assert(seq_of_commands_0.randomize());
		phase.raise_objection(this);
		seq_of_commands_0.start(top_env_0.app_agent_in_0.app_sequencer_in_0);
		phase.drop_objection(this);	
	endtask:run_phase
endclass: single_wr_rd_test

class multi_wr_rd_test extends app_only_test;
	`uvm_component_utils(multi_wr_rd_test)
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction:new
	
	task run_phase(uvm_phase phase);
		seq_of_commands_multi		seq_of_commands_0;
		seq_of_commands_0 	= seq_of_commands_multi::type_id::create("seq_of_commands_0");
		assert(seq_of_commands_0.randomize());
		phase.raise_objection(this);
		seq_of_commands_0.start(top_env_0.app_agent_in_0.app_sequencer_in_0);
		phase.drop_objection(this);	
	endtask:run_phase 

endclass:multi_wr_rd_test

endpackage: tests
