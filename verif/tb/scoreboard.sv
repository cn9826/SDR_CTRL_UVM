`include "uvm_macros.svh"
`include "constants.sv"
package scoreboard; 
import uvm_pkg::*;
import sequences::*;

class app_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(app_scoreboard)

    uvm_analysis_export #(app_transaction_in) app_sb_in;
    uvm_analysis_export #(app_transaction_out) app_sb_out;

    uvm_tlm_analysis_fifo #(app_transaction_in) fifo_in;
    uvm_tlm_analysis_fifo #(app_transaction_out) fifo_out;
    queue_write		fifo_write;

    app_transaction_in app_tx_in;
    app_transaction_out app_tx_out;

    sdr_dut_config dut_config_0;
    virtual dut_in 	dut_vi_in;
    virtual dut_out	dut_vi_out;
    
    int 	burst_write_cnt;
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
        app_tx_in=new("app_tx_in");
        app_tx_out=new("app_tx_out");
	burst_write_cnt = 0;
    endfunction: new

    function void build_phase(uvm_phase phase);
        app_sb_in=new("app_sb_in",this);
        app_sb_out=new("app_sb_out",this);
        fifo_in=new("fifo_in",this);
        fifo_out=new("fifo_out",this);
        assert (uvm_config_db #(sdr_dut_config)::get(this, "", "dut_config", dut_config_0));//
        dut_vi_in  = dut_config_0.dut_vi_in;
	dut_vi_out = dut_config_0.dut_vi_out;
	fifo_write = queue_write::type_id::create("fifo_write"); 
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        app_sb_in.connect(fifo_in.analysis_export);
        app_sb_out.connect(fifo_out.analysis_export);
    endfunction: connect_phase

    task run();
        forever begin
		@(negedge dut_vi_in.sdram_clk);
        		if (dut_vi_in.app_req && dut_vi_in.app_req_wr_n == 0) begin
				burst_write_cnt = dut_vi_in.app_req_len - 1;
				fifo_in.get(app_tx_in);
				fifo_write.push_addr_data_idx(app_tx_in.app_req_addr, app_tx_in.app_wr_data, 1);	
			end
			
			if (burst_write_cnt > 0 && dut_vi_out.app_wr_next_req == 1) begin
				@(negedge dut_vi_in.sdram_clk);
				@(posedge dut_vi_in.sdram_clk);
				fifo_in.get(app_tx_in);	
				burst_write_cnt--;
				//`uvm_info("FIFO_IN_GET",$sformatf("Address: %8h    Written Data: %8h    Burst Write Idx: %2d", app_tx_in.app_req_addr, app_tx_in.app_wr_data, (dut_vi_in.app_req_len-burst_write_cnt)), UVM_LOW);
				fifo_write.push_addr_data_idx(app_tx_in.app_req_addr, app_tx_in.app_wr_data, (dut_vi_in.app_req_len - burst_write_cnt));	
			end

			if (dut_vi_out.app_rd_valid) begin
				fifo_out.get(app_tx_out);		
				compare();
			end
        end
    endtask: run

//    extern virtual function [31:0] getresult; 
    extern virtual function void compare; 
        
endclass: app_scoreboard

function void app_scoreboard::compare;
    	logic	[`APP_AW-1 : 0]	app_req_addr_exp = fifo_write.pop_addr();
    	logic 	[`APP_DW-1:  0]	app_rd_data_exp = fifo_write.pop_data();
	int			burst_wr_idx 	= fifo_write.pop_idx();
	
	if (app_rd_data_exp == app_tx_out.app_rd_data) begin
		`uvm_info("PASS", $sformatf("PASS: Address: %8h    Written Data: %8h    Read Data: %8h    Burst Write Idx: %2d", app_req_addr_exp, app_rd_data_exp, app_tx_out.app_rd_data, burst_wr_idx), UVM_LOW);
	end
	else begin
		`uvm_info("FAIL", $sformatf("FAIL: Address: %8h    Written Data: %8h    Read Data: %8h    Burst Write Idx: %2d", app_req_addr_exp, app_rd_data_exp, app_tx_out.app_rd_data, burst_wr_idx), UVM_LOW);
	end

endfunction

endpackage: scoreboard
