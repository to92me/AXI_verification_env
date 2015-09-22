`ifndef AXI_WRITE_WAPPER_AGENT_SVH
`define AXI_WRITE_WAPPER_AGENT_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_wrapper_agent extends uvm_subscriber#(dut_frame);


	axi_write_wrapper_monitor 			wrapper_monitor;
	axi_write_wrapper_top_sequencer		wrapper_top_sequencer;
	axi_write_wrapper_sequence			wrapper_sequence;
	axi_write_wrapper_low_sequencer		wrapper_low_sequencer;

	axi_master_write_agent				axi_write_agent_p;

	`uvm_component_utils(axi_write_wrapper_agent)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		set_config_string("wrapper_low_sequencer", "default_sequence", "wrapper_sequence");
		wrapper_monitor 		= axi_write_wrapper_monitor::type_id::create("AxiWriteWrapperMonitor", this);
		wrapper_top_sequencer 	= axi_write_wrapper_top_sequencer::type_id::create("AxiWriteWrapperTopSequencer", this);
		wrapper_low_sequencer 	= axi_write_wrapper_low_sequencer::type_id::create("AxiWriteWrapperLowSequencer", this);

	endfunction : build_phase

	function void setAxiWriteAgent(input axi_master_write_agent agent_instance);
		this.axi_write_agent_p = agent_instance;
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		wrapper_low_sequencer.upper_seq_item_port.connect(wrapper_top_sequencer.seq_item_export);
		axi_write_agent_p.driver.seq_item_port.connect(wrapper_low_sequencer.seq_item_export);
	endfunction


endclass : axi_write_wrapper_agent


`endif