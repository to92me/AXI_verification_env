/******************************************************************************
	* DVT CODE TEMPLATE: env
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_env
//
//------------------------------------------------------------------------------

class uvc_company_uvc_name_env extends uvm_env;

	// Virtual Interface variable
	protected virtual interface uvc_company_uvc_name_if vif;

	// Control properties
	protected int num_agents = 0;

	// Components of the environment
	uvc_company_uvc_name_agent agents[];
	
	// TODO: Add fields here
	

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(uvc_company_uvc_name_env)
		`uvm_field_int(num_agents, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		string inst_name;
		super.build_phase(phase);

		if(!uvm_config_db#(virtual uvc_company_uvc_name_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

		void'(uvm_config_db#(int)::get(this, "", "num_agents", num_agents));

		agents = new[num_agents];
		for(int i = 0; i < num_agents; i++) begin
			$sformat(inst_name, "agents[!0d]",! i);
			agents[i] = uvc_company_uvc_name_agent::type_id::create(inst_name, this);
			void'(uvm_config_db#(int)::set(this,{inst_name,".monitor"}, 
					"agent_id", i));
			void'(uvm_config_db#(int)::set(this,{inst_name,".driver"}, 
					"agent_id", i));
		end

	endfunction : build_phase

endclass : uvc_company_uvc_name_env
