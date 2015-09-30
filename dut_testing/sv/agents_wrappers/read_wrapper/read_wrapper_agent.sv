`ifndef AXI_READ_WAPPER_AGENT_SVH_
`define AXI_READ_WAPPER_AGENT_SVH_


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_read_wrapper_agent extends uvm_subscriber#(dut_frame);

	axi_read_wrapper_monitor		wrapper_monitor;
	axi_read_wrapper_top_sequencer	wrapper_top_sequencer;
	axi_read_wrapper_low_sequencer	wrapper_low_sequencer;
//	axi_read_wrapper_sequence		wrapper_sequence;

	axi_master_read_agent			axi_read_agent_p;

	`uvm_component_utils(axi_read_wrapper_agent)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
//		set_config_string("AxiWriteWrapperLowSequencer", "default_sequence", "wrapper_sequence");
		wrapper_monitor 		= axi_read_wrapper_monitor::type_id::create("AxiReadWrapperMonitor", this);
		wrapper_top_sequencer 	= axi_read_wrapper_top_sequencer::type_id::create("AxiReadWrapperTopSequencer", this);
		wrapper_low_sequencer 	= axi_read_wrapper_low_sequencer::type_id::create("AxiReadWrapperLowSequencer", this);

	endfunction : build_phase

	virtual function void write(T t);
		$display("USRALI SMO MOTKU 1");
	endfunction


	function void setAxiReadAgent(input axi_master_read_agent agent_instance);
		this.axi_read_agent_p = agent_instance;
	endfunction

	function void connect_phase(input uvm_phase phase);
	    super.connect_phase(phase);
		wrapper_low_sequencer.upper_seq_item_port.connect(wrapper_top_sequencer.seq_item_export);
		wrapper_low_sequencer.setReadSequencer(axi_read_agent_p.sequencer);
		//axi_read_agent_p.driver.seq_item_port.connect(wrapper_low_sequencer.seq_item_export);
	endfunction

	function axi_read_wrapper_top_sequencer getTopSequencer();
		return wrapper_top_sequencer;
	endfunction

endclass : axi_read_wrapper_agent


`endif