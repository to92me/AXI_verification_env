/******************************************************************************
	* DVT CODE TEMPLATE: agent
	* Created by andrea on Aug 10, 2015
	* uvc_company = axi, uvc_name = master_read
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_agent
//
//------------------------------------------------------------------------------

class axi_master_read_agent extends uvm_agent;

	// Configuration object
	axi_master_config config_obj;

	axi_master_read_driver driver;
	axi_master_read_sequencer sequencer;
	axi_master_read_monitor monitor;

	virtual axi_if vif;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_agent)
	    `uvm_field_object(monitor, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
	    `uvm_field_object(config_obj, UVM_DEFAULT | UVM_REFERENCE)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor = axi_master_read_monitor::type_id::create("monitor", this);

		// Propagate the configuration object
		if(!uvm_config_db#(axi_master_config)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})

			if(config_obj.is_active == UVM_ACTIVE) begin
				sequencer = axi_master_read_sequencer::type_id::create("sequencer", this);
				driver = axi_master_read_driver::type_id::create("driver", this);
			end
	endfunction : build_phase

	// connect_phase
	function void connect_phase(uvm_phase phase);
		// Get the agents virtual interface if set via get_config
		if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
		`uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		// If the vif was set to the agent, apply it to its children
		uvm_config_db#(virtual axi_if)::set(this, "*", "vif", vif);

		if(config_obj.is_active == UVM_ACTIVE) begin
			driver.seq_item_port.connect(sequencer.seq_item_export);
		end
	endfunction : connect_phase

	// update config
	function void update_config(input axi_slave_config cfg);
		if (is_active == UVM_ACTIVE) begin
			sequencer.config_obj = cfg;
		end
	endfunction : update_config

endclass : axi_master_read_agent
