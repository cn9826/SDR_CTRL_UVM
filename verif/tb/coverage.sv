`include "uvm_macros.svh"
package coverage;
import sequences::*;
import uvm_pkg::*;

class app_subscriber_in extends uvm_subscriber #(app_transaction_in);
    `uvm_component_utils(app_subscriber_in)
	logic				reset_n;
	logic				app_req;
	logic	   [`APP_BW-1:0]	app_wr_en_n;
	logic				app_req_wr_n;
	logic	   [`APP_RW-1:0]  	app_req_len;	// can be random later
	rand logic [`APP_AW-1 : 0]	app_req_addr;
	rand logic [`APP_DW-1:  0]	app_wr_data;
	logic				app_req_wrap;	// can be random later
	// local variables
	logic [`APP_AW-1 : 0]	prev_req_addr;
	logic sample 
	/*covergroup inputs;
	
	cpi_A : coverpoint iA{
	}
	endgroup inputs;
	function new(string name, uvm_component parent);
        super.new(name,parent);
        // TODO: Uncomment
       //  inputs=new;
        //
    endfunction: new*/
	cover property(@(sample) $rose(app_req)##[1:*]$fell(app_req)##[1:*]$rose|-->  && app_req_addr == prev_req_addr);

    function void write(app_subscriber_in t);
        reset_n={t.reset_n};
        app_req={t.app_req};
        app_wr_en_n={t.app_wr_en_n};
        app_req_wr_n={t.app_req_wr_n};
        app_req_len={t.app_req_len};
        app_req_addr={t.app_req_addr};
        app_wr_data={t.app_wr_data};
        app_req_wrap={t.app_req_wrap};
		sample = ! sample; //this should trigger the cover immediatlym before prev_req_addr is updated?
		if($rose(app_req))//if new request
			prev_req_addr = app_req_addr={t.app_req_addr};
        // TODO: Uncomment if using cover group
        // inputs.sample();
        //
    endfunction: write

endclass: app_subscriber_in

class app_subscriber_out extends uvm_subscriber #(app_transaction_out);
    `uvm_component_utils(app_subscriber_out)
	logic				app_req_ack;
	logic				app_wr_next_req;
	logic	[`APP_DW-1 : 0]		app_rd_data;
	logic				app_rd_valid;
	//internal signals
	//logic sample; 
	logic [`APP_DW-1 : 0] zero = 0;
	covergroup outputs;
	
	cpo_rd_data : coverpoint app_rd_data{
		bins zero = zero; // read empty. cover to check if stuck at 1
		bins full = {~zero}; //read all ones. cover to check if stuck at 0
	}
	endgroup outputs;
	function new(string name, uvm_component parent);
        super.new(name,parent);
        // DONE: Uncomment if using covergroup
         outputs=new;
        
    endfunction: new*/ //can't use cover group because of complex temporal logic
	
	function void write(app_subscriber_in t);
        app_req_ack={t.app_req_ack};
        app_wr_next_req={t.app_wr_next_req};
        app_rd_data={t.app_rd_data};
        app_rd_valid={t.app_rd_valid};
        // DONE: Uncomment if using covergroup 
         outputs.sample();
        
		sample = ! sample;
    endfunction: write
	
endclass: app_subscriber_out

class sdr_subscriber_out extends uvm_subscriber #(sdr_transaction_out);
    `uvm_component_utils(sdr_subscriber_out)
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
	covergroup sdr;
	cpo_sdr_dout : coverpoint sdr_dout{
		bins zero = zero; // read empty. cover to check if stuck at 1
		bins full = {~zero}; //read all ones. cover to check if stuck at 0
	}
	endgroup sdr;
	function new(string name, uvm_component parent);
        super.new(name,parent);
         sdr=new;
        //
    endfunction: new
	 function void write(sdr_transaction_out t);
        sdr_cs_n={t.sdr_cs_n};
        sdr_cke={t.sdr_cke};
        sdr_ras_n={t.sdr_ras_n};
        sdr_cas_n={t.sdr_cas_n};
        sdr_we_n={t.sdr_we_n};
        sdr_init_done={t.sdr_init_done};
        sdr_ba={t.sdr_ba};
        sdr_addr={t.sdr_addr};
        // TODO: Uncomment
         sdr.sample();
        //
    endfunction: write
	

endclass: sdr_subscriber_out

endpackage: coverage
