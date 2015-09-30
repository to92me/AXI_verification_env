`ifndef AXI_MASTER_WRITE_AGENT_SVH
`define AXI_MASTER_WRITE_AGENT_SVH


/**
* Project : AXI UVC
*
* File : axi_master_write_agent.sv
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
* Description : master write agent
*
* Classes :	1. axi_master_write_agent
*
**/

//--------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_agent
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		-UVM_AGENT class ( for more information see uvm_cookbook )
//		-
//--------------------------------------------------------------------------------------

class axi_master_write_agent extends uvm_agent;

	// Configuration object
	axi_master_config config_obj;

	axi_master_write_driver driver;
	axi_master_write_sequencer sequencer;
	axi_master_write_main_monitor monitor;


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

		monitor = axi_master_write_main_monitor::getMonitorMainInstance(this);
//		 Propagate the configuration object
		if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})

			if(config_obj.is_active == UVM_ACTIVE) begin
				sequencer = axi_master_write_sequencer::type_id::create("sequencer", this);
				driver = axi_master_write_driver::type_id::create("driver", this);
			end
	endfunction : build_phase

	// connect_phase
	function void connect_phase(uvm_phase phase);
		if(config_obj.is_active == UVM_ACTIVE) begin
			driver.seq_item_port.connect(sequencer.seq_item_export);

		end
	endfunction : connect_phase

endclass : axi_master_write_agent

`endif
