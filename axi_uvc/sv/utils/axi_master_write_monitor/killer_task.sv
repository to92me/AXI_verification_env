`ifndef AXI_MASTER_KILLER_TASK
`define AXI_MASTER_KILLER_TASK

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_master_killer_task extends uvm_component;

	virtual interface axi_if	vif;
	axi_write_conf				uvc_config_obj;

	`uvm_component_utils(axi_master_killer_task)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			 `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", uvc_config_obj))
			 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})

	endfunction : build_phase



endclass : axi_master_killer_task


`endif