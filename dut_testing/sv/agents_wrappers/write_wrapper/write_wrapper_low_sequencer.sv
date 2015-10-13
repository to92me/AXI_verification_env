`ifndef AXI_WRITE_WRAPPER_LOW_SEQUENCER_SVH_
`define AXI_WRITE_WRAPPER_LOW_SEQUENCER_SVH_

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : write_wrapper_low_sequencer.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description :low sequencer that is passing sequence items to real agent
*
*/
// -----------------------------------------------------------------------------
class axi_write_wrapper_low_sequencer extends uvm_sequencer#(axi_frame);

	uvm_seq_item_pull_port#(dut_frame)		upper_seq_item_port;
	axi_master_write_sequencer				write_sequencer;


	`uvm_component_utils(axi_write_wrapper_low_sequencer)


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		upper_seq_item_port = new("AxiWriteWrapperLowSequencerUpperPullPort",this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	function void setWriteSequencer(input axi_master_write_sequencer sqr_instance);
		this.write_sequencer = sqr_instance;
	endfunction

endclass : axi_write_wrapper_low_sequencer


`endif