`include "uvm_macros.svh"
package coverage;
import sequences::*;
import uvm_pkg::*;

class app_subscriber_in extends uvm_subscriber #(app_transaction_in);
    `uvm_component_utils(app_subscriber_in)
/*
    //Declare Variables
    logic [31:0] A;
    logic [31:0] B;
    logic [4:0] opcode;
    logic cin;

    //TODO: Add covergroups for the inputs
	covergroup inputs;
	cp_A : coverpoint A
	{
	bins one = {32'h5555_5555};
	bins two = {32'hFFFF_FFFF};
	bins three = {32'h5555_5555};
	bins four = {32'hAAAA_AAAA};
	bins five = {32'h5A5A_5A5A};
	bins six = {32'hA5A5_A5A5};
	}
	cp_B : coverpoint B
	{
	bins one_b = {32'h5555_5555};
	bins two_b = {32'hFFFF_FFFF};
	bins three_b = {32'h5555_5555};
	bins four_b = {32'hAAAA_AAAA};
	bins five_b = {32'h5A5A_5A5A};
	bins six_b = {32'hA5A5_A5A5};
	}
	cp_opcode : coverpoint opcode{
	bins logic_operation = {5'b00111, 5'b00011, 5'b00000, 5'b00101};
	bins compare_operation = { 5'b01100, 5'b01001, 5'b01110,5'b01011,5'b01111,5'b01010};
	bins arithmatic_operation = {5'b10101, 5'b10001, 5'b10100, 5'b10000, 5'b10111, 5'b10110};
	bins shift_operation = {5'b11010, 5'b11011, 5'b11100, 5'b11101, 5'b11000, 5'b11001};
	}
	cp_cin : coverpoint cin{
	bins zero_cin = {1'b0};
	bins one_cin = {1'b1};
	}
	
	point1: cross cp_A, cp_opcode;
	point2: cross cp_B, cp_opcode;
	point3: cross cp_A, cp_B, cp_opcode, cp_cin;
    endgroup: inputs


    function new(string name, uvm_component parent);
        super.new(name,parent);
        // TODO: Uncomment
         inputs=new;
        //
    endfunction: new

    function void write(alu_transaction_in t);
        A={t.A};
        B={t.B};
        opcode={t.opcode};
        cin={t.CIN};
        // TODO: Uncomment
         inputs.sample();
        //
    endfunction: write*/

endclass: app_subscriber_in

class app_subscriber_out extends uvm_subscriber #(app_transaction_out);
    `uvm_component_utils(app_subscriber_out)
/*
    logic [31:0] out;
    logic cout;
    logic vout;

    //TODO: Add covergroups for the outputs

    covergroup outputs;
	cp_out: coverpoint out;
	cp_cout: coverpoint cout;
	cp_vout: coverpoint vout;	
    endgroup: outputs
  

function new(string name, uvm_component parent);
    super.new(name,parent);
    //TODO: Uncomment
     outputs=new;
    //
endfunction: new

function void write(alu_transaction_out t);
    out={t.OUT};
    cout={t.COUT};
    vout={t.VOUT};
    //TODO: Uncomment
    outputs.sample();
    //
endfunction: write
*/
endclass: app_subscriber_out

class sdr_transaction_out extends uvm_subscriber #(sdr_transaction_out);
    `uvm_component_utils(sdr_transaction_out)
/*
    logic [31:0] out;
    logic cout;
    logic vout;

    //TODO: Add covergroups for the outputs

    covergroup outputs;
	cp_out: coverpoint out;
	cp_cout: coverpoint cout;
	cp_vout: coverpoint vout;	
    endgroup: outputs
  

function new(string name, uvm_component parent);
    super.new(name,parent);
    //TODO: Uncomment
     outputs=new;
    //
endfunction: new

function void write(alu_transaction_out t);
    out={t.OUT};
    cout={t.COUT};
    vout={t.VOUT};
    //TODO: Uncomment
    outputs.sample();
    //
endfunction: write
*/
endclass: sdr_transaction_out

endpackage: coverage
