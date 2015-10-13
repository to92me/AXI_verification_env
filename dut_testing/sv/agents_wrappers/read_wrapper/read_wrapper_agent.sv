`ifndef AXI_READ_WAPPER_AGENT_SVH_
`define AXI_READ_WAPPER_AGENT_SVH_

// -----------------------------------------------------------------------------
/**
* Project :  DUT TESTING WITH REGISTER MODEL
*
* File : read_wrapper_agent.sv
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
* Description : read agent wrapper is adapter to convert register model interface ( dut_frame )
* 				to axi_read interface ( axi_read_whole_burst_frame )
*
*
*/
// -----------------------------------------------------------------------------

class axi_read_wrapper_agent extends uvm_subscriber#(dut_frame);

	axi_read_wrapper_monitor		wrapper_monitor;
	axi_read_wrapper_top_sequencer	wrapper_top_sequencer;
	axi_read_wrapper_low_sequencer	wrapper_low_sequencer;

	axi_master_read_agent			axi_read_agent_p;

	`uvm_component_utils(axi_read_wrapper_agent)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		wrapper_monitor 		= axi_read_wrapper_monitor::type_id::create("AxiReadWrapperMonitor", this);
		wrapper_top_sequencer 	= axi_read_wrapper_top_sequencer::type_id::create("AxiReadWrapperTopSequencer", this);
		wrapper_low_sequencer 	= axi_read_wrapper_low_sequencer::type_id::create("AxiReadWrapperLowSequencer", this);

	endfunction : build_phase

	virtual function void write(T t);
	endfunction


	function void setAxiReadAgent(input axi_master_read_agent agent_instance);
		this.axi_read_agent_p = agent_instance;
	endfunction

	function void connect_phase(input uvm_phase phase);
	    super.connect_phase(phase);
		wrapper_low_sequencer.upper_seq_item_port.connect(wrapper_top_sequencer.seq_item_export);
		wrapper_low_sequencer.setReadSequencer(axi_read_agent_p.sequencer);
		axi_read_agent_p.monitor.burst_collected_port.connect(wrapper_monitor.read_monitor_import);
	endfunction

	function axi_read_wrapper_top_sequencer getTopSequencer();
		return wrapper_top_sequencer;
	endfunction

endclass : axi_read_wrapper_agent


`endif