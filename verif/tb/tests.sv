package tests;
`include "uvm_macros.svh"
import modules_pkg::*;
import uvm_pkg::*
import sequences::*
//import scoreboard::*;

class app_layer_test1 extends app_only_test; 
	`uvm_component_utils(app_layer_test1)
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction:new

	task run_phase(uvm_phase phase);
		seq_of_commands 	seq_of_commands_0;
		seq_of_commands_0	= seq_of_commands::type_id::create("seq_of_commands_0");
		//assert(seq_of_commands_0.randomize());
		phase.raise_objection(this);
		seq_of_commands_0.start(top_env_0.app_agent_in_0.app_sequencer_in_0);
		phase.drop_objection(this);	
	endtask:run_phase
endclass: app_layer_test1
endpackage tests
