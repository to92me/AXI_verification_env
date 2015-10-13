`ifndef AXI_WRITE_WAPPER_AGENT_SVH_
`define AXI_WRITE_WAPPER_AGENT_SVH_

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : write_wrapper_agent.sv
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
* Description : write agent wrapper is adapter to convert register model interface ( dut_frame )
* 				to axi_write interface ( axi frame )
*
*
*/
// -----------------------------------------------------------------------------

class axi_write_wrapper_agent extends uvm_subscriber#(dut_frame);


	axi_write_wrapper_monitor 			wrapper_monitor;
	axi_write_wrapper_top_sequencer		wrapper_top_sequencer;
	axi_write_wrapper_sequence			wrapper_sequence;
	axi_write_wrapper_low_sequencer		wrapper_low_sequencer;

	axi_master_write_agent				axi_write_agent_p;

	`uvm_component_utils(axi_write_wrapper_agent)

	// new - constructor
	function new (string name = "AxiWriteWrapperAgent", uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

//		wrapper_sequence 		= axi_write_wrapper_sequence::type_id::create("axi_write_wrapper_sequence", this);

		wrapper_monitor 		= axi_write_wrapper_monitor::type_id::create("AxiWriteWrapperMonitor", this);
		wrapper_top_sequencer 	= axi_write_wrapper_top_sequencer::type_id::create("AxiWriteWrapperTopSequencer", this);
		wrapper_low_sequencer 	= axi_write_wrapper_low_sequencer::type_id::create("AxiWriteWrapperLowSequencer", this);

//		set_config_string("wrapper_low_sequencer", "default_sequence", "axi_write_wrapper_sequence");


	endfunction : build_phase

	virtual function void write(T t);
		$display("USRALI SMO MOTKU 1");
	endfunction


	function void setAxiWriteAgent(input axi_master_write_agent agent_instance);
		this.axi_write_agent_p = agent_instance;
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		wrapper_low_sequencer.upper_seq_item_port.connect(wrapper_top_sequencer.seq_item_export);
		wrapper_low_sequencer.setWriteSequencer(axi_write_agent_p.sequencer);
		axi_write_agent_p.monitor.burst_port.connect(wrapper_monitor.write_monitor_import);
	endfunction

	function axi_write_wrapper_top_sequencer getTopSequencer();
		return wrapper_top_sequencer;
	endfunction


endclass : axi_write_wrapper_agent


`endif