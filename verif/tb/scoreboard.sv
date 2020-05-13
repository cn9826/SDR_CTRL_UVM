`include "uvm_macros.svh"
package scoreboard; 
import uvm_pkg::*;
import sequences::*;

class app_scoreboard extends uvm_scoreboard;//
    `uvm_component_utils(app_scoreboard)

    uvm_analysis_export #(app_transaction_in) sb_in;//
    uvm_analysis_export #(app_transaction_out) sb_out;//

    uvm_tlm_analysis_fifo #(app_transaction_in) fifo_in;//
    uvm_tlm_analysis_fifo #(app_transaction_out) fifo_out;//

    app_transaction_in tx_in;//
    app_transaction_out tx_out;//

    sdr_dut_config dut_config_0;//
    virtual dut_in dut_vi_in;//

    function new(string name, uvm_component parent);
        super.new(name,parent);
        tx_in=new("tx_in");
        tx_out=new("tx_out");
    endfunction: new

    function void build_phase(uvm_phase phase);
        sb_in=new("sb_in",this);
        sb_out=new("sb_out",this);
        fifo_in=new("fifo_in",this);
        fifo_out=new("fifo_out",this);
        assert (uvm_config_db #(sdr_dut_config)::get(this, "", "dut_config", dut_config_0));//
        dut_vi_in = dut_config_0.dut_vi_in;//
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        sb_in.connect(fifo_in.analysis_export);
        sb_out.connect(fifo_out.analysis_export);
    endfunction: connect_phase

    task run();
        forever begin
            fifo_in.get(tx_in);
            fifo_out.get(tx_out);
            compare();
        end
    endtask: run

    extern virtual function [31:0] getresult; 
    extern virtual function void compare; 
        
endclass: app_scoreboard

function void app_scoreboard::compare;
    //TODO: Write this function to check whether the output of the DUT matches
    //the spec.
    //Use the getresult() function to get the spec output.
    //Consider using `uvm_info(ID,MSG,VERBOSITY) in this function to print the
    //results of the comparison.
    //You can use tx_in.convert2string() and tx_out.convert2string() for
    //debugging purposes
    logic [31 : 0] temp = tx_out.app_rd_data;
    logic [31 : 0] answer = getresult();
    if(temp != answer)  begin
       tx_in.convert2string();
       tx_out.convert2string();
        uvm_report_info("Write: ", tx_in.convert2string(), UVM_LOW);
        uvm_report_info("Read ", tx_out.convert2string(), UVM_LOW);
        $display("Correct Read Data should be: %h", answer[31:0]);
    end

endfunction

function [31:0] app_scoreboard::getresult;
    //TODO: Remove the statement below
    //Modify this function to return a 34-bit result {VOUT, COUT,OUT[31:0]} which is
    //consistent with the given spec.
	//logic [31:0]i;
	//logic [31:0] A,B;
	//logic rst;
	//logic CIN;
	//logic [31:0] OUT;
	//logic VOUT,COUT;
	//logic [1:0] opcode_2;
	//logic [2:0] opcode_3;
	//logic less,equal,greater;
    //logic [32:0] temp;
    //logic [31:0] temp_B;
        //logic [4:0]amount=0;
    logic clk;
    logic reset_n;
    logic app_req;
    logic app_wr_en_n;
    logic app_req_wr_n;
    logic app_req_len;
    logic app_req_addr;
    logic app_wr_data;
    logic app_req_wrap;
    logic rd_data;
   logic  [31:0] temp;
   temp = 32'hFFFF;
   

    //reset_n = 

	//A = tx_in.A;
	//B = tx_in.B;
	//rst = tx_in.rst;
	//CIN = tx_in.CIN;
	//opcode_2 = tx_in.opcode[4:3];
	//opcode_3 = tx_in.opcode[2:0];

	return temp;

endfunction

endpackage: scoreboard
