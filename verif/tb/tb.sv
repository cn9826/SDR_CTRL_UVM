`timescale 1ns / 100ps
`include "uvm_macros.svh"
`include "constants.sv"
`include "DUT.sv"
import uvm_pkg::*;
import modules_pkg::*;
import sequences::*;
//import coverage::*;
//import scoreboard::*;
import tests::*;

module dut(dut_in _in, dut_out _out);
CTRL_SDRAM u_CTRL_SDRAM(
// General 
	.sdram_clk(_in.sdram_clk),
	.reset_n(_in.reset_n),

// Application Interface IN
	.app_req(_in.app_req),
	.app_req_len(_in.app_req_len),
	.app_req_addr(_in.app_req_addr),
	.app_req_wr_n(_in.app_req_wr_n),
	.app_req_wrap(_in.app_req_wrap),
	.app_wr_data(_in.app_wr_data),
	.app_wr_en_n(_in.app_wr_en_n),

// Application Interface OUT
	.app_req_ack(_out.app_req_ack),
	.app_wr_next_req(_out.app_wr_next_req),
	.app_rd_data(_out.app_rd_data),
	.app_rd_valid(_out.app_rd_valid),
	.app_last_rd(_out.app_last_rd),
	.app_last_wr(_out.app_last_wr),

// SDRAM I/F OUT
	.Dq(_out.Dq),
	.sdr_dout(_out.sdr_dout),
	.pad_sdr_din(_out.pad_sdr_din),
	.sdr_den_n(_out.sdr_den_n),
	.sdr_dqm(_out.sdr_dqm),
	
	.sdr_ba(_out.sdr_ba),
	.sdr_addr(_out.sdr_addr),

	.sdr_cs_n(_out.sdr_cs_n),
	.sdr_cke(_out.sdr_cke),
	.sdr_ras_n(_out.sdr_ras_n),
	.sdr_cas_n(_out.sdr_cas_n),
	.sdr_we_n(_out.sdr_we_n),
	.sdr_init_done(_out.sdr_init_done)
);
endmodule:dut

module top;
parameter P_SYS = 10;	// 100 MHz

dut_in 	dut_in_0();
dut_out dut_out_0();
int 	num_self_checks;

queue_write	fifo_write;

initial begin
	dut_in_0.sdram_clk <= 1;
	forever begin
		#(P_SYS/2) dut_in_0.sdram_clk <=  ~dut_in_0.sdram_clk;
	end	
end


initial begin
	dut_out_0.sdram_clk <= 1;
	forever begin
		#(P_SYS/2) dut_out_0.sdram_clk <=  ~dut_out_0.sdram_clk;
	end	
end

dut u_dut(
	._in(dut_in_0),	
	._out(dut_out_0)
); 


initial begin
	num_self_checks = 2000;
	uvm_config_db #(virtual dut_in)::set(null,"uvm_test_top","dut_vi_in",dut_in_0);
	uvm_config_db #(virtual dut_out)::set(null,"uvm_test_top","dut_vi_out",dut_out_0);
		
	uvm_top.finish_on_completion = 1;
	
	if (num_self_checks == 1) 
		run_test("single_wr_rd_test");
	else begin
		fifo_write = new();
		uvm_config_db #(int)::set(null,"uvm_test_top.*","num_self_checks",num_self_checks);
		uvm_config_db #(queue_write)::set(null, "uvm_test_top.*", "queue_write", fifo_write);
		run_test("multi_wr_rd_test");
	end
end

endmodule: top
