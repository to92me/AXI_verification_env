// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_master_read_agent.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : agent for read master
*
* Classes : axi_master_read_agent
**/
// -----------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_AGENT_SV
`define AXI_MASTER_READ_AGENT_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_agent
//
//------------------------------------------------------------------------------
/**
* Description : agent for master - contains monitor and collector; driver,
*				sequencer and coverage collector if needed
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
*				3. void connect_phase(uvm_phase phase)
*				4. void update_config(input axi_master_config config_obj)
**/
// -----------------------------------------------------------------------------
class axi_master_read_agent extends uvm_agent;

	// Configuration object
	axi_master_config config_obj;

	axi_master_read_driver driver;
	axi_master_read_sequencer sequencer;
	axi_master_read_monitor monitor;
	axi_master_read_collector collector;
	axi_master_read_coverage_collector coverage_coll;

	virtual axi_if vif;

	// control bit
	bit coverage_enable = 1;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_master_read_agent)
	    `uvm_field_object(monitor, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_object(coverage_coll, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_object(collector, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
	    `uvm_field_object(config_obj, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_object(driver, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_object(sequencer, UVM_DEFAULT | UVM_REFERENCE)
	    `uvm_field_int(coverage_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void update_config(input axi_master_config config_obj);

endclass : axi_master_read_agent

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build agant - always create monitor and collector; driver, sequencer
*			and coverage collector if needed
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_agent::build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor = axi_master_read_monitor::type_id::create("monitor", this);
		collector = axi_master_read_collector::type_id::create("collector", this);
		// create coverage collector if coverage is enabled
		if(coverage_enable)
			coverage_coll = axi_master_read_coverage_collector::type_id::create("coverage_coll", this);

		// Propagate the configuration object
		if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})

			if(config_obj.is_active == UVM_ACTIVE) begin
				sequencer = axi_master_read_sequencer::type_id::create("sequencer", this);
				driver = axi_master_read_driver::type_id::create("driver", this);
			end
	endfunction : build_phase

//------------------------------------------------------------------------------
/**
* Function : connect_phase
* Purpose : connect all components - collector to monitor, monitor to coverage
*			collector and driver to sequencer
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_agent::connect_phase(uvm_phase phase);
		// Get the agents virtual interface if set via get_config
		if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		// If the vif was set to the agent, apply it to its children
		uvm_config_db#(virtual axi_if)::set(this, "*", "vif", vif);

		// connect collector and monitor
		collector.addr_collected_port.connect(monitor.addr_channel_imp);
		collector.data_collected_port.connect(monitor.data_channel_imp);

		// connect monitor and coverage collector
		if (coverage_enable) begin
			monitor.addr_collected_port.connect(coverage_coll.addr_channel_port);
			monitor.data_collected_port.connect(coverage_coll.data_channel_port);
		end

		if(config_obj.is_active == UVM_ACTIVE) begin
			driver.seq_item_port.connect(sequencer.seq_item_export);
		end
	endfunction : connect_phase

//------------------------------------------------------------------------------
/**
* Function : update_config
* Purpose : update the configuration
* Parameters :	config_obj
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_agent::update_config(input axi_master_config config_obj);
		if (is_active == UVM_ACTIVE) begin
			sequencer.config_obj = config_obj;
		end
	endfunction : update_config

`endif