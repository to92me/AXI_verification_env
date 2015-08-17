/******************************************************************************
* DVT CODE TEMPLATE: TB class
* Created by root on Aug 17, 2015
* uvc_company = uvc_company, uvc_name = uvc_name uvc_if = uvc_if
*******************************************************************************/

class  axi_master_write_tb extends uvm_env;

	// Env instance
	uvc_company_uvc_name_env env;

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	// build_phase
	virtual function void build_phase(uvm_phase phase);
		uvc_company_uvc_name_config_obj config_obj;
		// Configuration object
		super.build_phase(phase);
		// TODO : set the number of agents

		set_config_int("env","num_agents",3);
		// TODO : set other configuration parameters(config objects)
		config_obj = new;
		// TODO : set config object fields
		// ...
		// Propagate config objects to the components that need them
		uvm_config_db#(uvc_company_uvc_name_config_obj)::set(uvm_root::get(), "*", "config_obj", config_obj);
		// Create the env instance
		env=uvc_company_uvc_name_env::type_id::create("env",this);
	endfunction

	// connect_phase
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// TODO : make the necessary connections(TLM ports, events,
		// scoreboards, etc.)
	endfunction

endclass
