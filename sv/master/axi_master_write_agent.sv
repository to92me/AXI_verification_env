`ifndef AXI_MASTER_WRITE_AGENT_SVH
`define AXI_MASTER_WRITE_AGENT_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_agent
//
//------------------------------------------------------------------------------

class axi_master_write_agent extends uvm_agent;

	// Configuration object
	axi_master_config config_obj;

	axi_master_write_driver driver;
	axi_master_write_sequencer sequencer;
//	uvc_company_uvc_name_monitor monitor; //TODO

	// TODO: Add fields here


	// Provide implementations of virtual methods such as get_type_name and create
`uvm_component_utils_begin(axi_master_write_agent)
	 `uvm_field_object(config_obj, UVM_DEFAULT)
	 `uvm_field_object(driver, UVM_DEFAULT)
	 `uvm_field_object(sequencer, UVM_DEFAULT)
 `uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
//		monitor = uvc_company_uvc_name_monitor::type_id::create("monitor", this);

//		 Propagate the configuration object
		if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"}) // FIXME CONFIG

			if(config_obj.is_active == UVM_ACTIVE) begin  // FIXME CONFIG
				sequencer = axi_master_write_sequencer::type_id::create("sequencer", this);
				driver = axi_master_write_driver::type_id::create("driver", this);
			end // FIXME
	endfunction : build_phase

	// connect_phase
	function void connect_phase(uvm_phase phase);
//		if(config_obj.is_active == UVM_ACTIVE) begin // FIXME CONFIG
			driver.seq_item_port.connect(sequencer.seq_item_export);
//		end
	endfunction : connect_phase

endclass : axi_master_write_agent

`endif