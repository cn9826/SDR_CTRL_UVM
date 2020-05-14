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
	covergroup inputs;
	
	cpi_A : coverpoint iA{
	}
	endgroup inputs;
	function new(string name, uvm_component parent);
        super.new(name,parent);
        // TODO: Uncomment
         inputs=new;
        //
    endfunction: new

    function void write(app_subscriber_in t);
        reset_n={t.reset_n};
        app_req={t.app_req};
        app_wr_en_n={t.app_wr_en_n};
        app_req_wr_n={t.app_req_wr_n};
        app_req_len={t.app_req_len};
        app_req_addr={t.app_req_addr};
        app_wr_data={t.app_wr_data};
        app_req_wrap={t.app_req_wrap};
		
        // TODO: Uncomment
         inputs.sample();
        //
    endfunction: write*/

endclass: app_subscriber_in

class app_subscriber_out extends uvm_subscriber #(app_transaction_out);
    `uvm_component_utils(app_subscriber_out)
	logic				app_req_ack;
	logic				app_wr_next_req;
	logic	[`APP_DW-1 : 0]		app_rd_data;
	logic				app_rd_valid;
	covergroup outputs;
	
	cpo_A : coverpoint oA{
	}
	endgroup outputs;
	function new(string name, uvm_component parent);
        super.new(name,parent);
        // TODO: Uncomment
         outputs=new;
        //
    endfunction: new
	 function void write(app_subscriber_in t);
        app_req_ack={t.app_req_ack};
        app_wr_next_req={t.app_wr_next_req};
        app_rd_data={t.app_rd_data};
        app_rd_valid={t.app_rd_valid};
        // TODO: Uncomment
         outputs.sample();
        //
    endfunction: write*/
	
endclass: app_subscriber_out

class sdr_transaction_out extends uvm_subscriber #(sdr_transaction_out);
    `uvm_component_utils(sdr_transaction_out)

endclass: sdr_transaction_out

endpackage: coverage
