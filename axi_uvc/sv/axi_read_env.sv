// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_read_env.sv
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
* Description : environment for read
*
* Classes : axi_read_env
**/
// -----------------------------------------------------------------------------

`ifndef axi_read_env_SV
`define axi_read_env_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_read_env
//
//------------------------------------------------------------------------------
/**
* Description : read environment - contains master and slave agents
*
* Functions :	1. new(string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
*				3. connect_phase(uvm_phase phase)
*				4. start_of_simulation_phase(uvm_phase phase)
*				5. update_config(axi_config config_obj)
*
* Tasks :	1. run_phase(uvm_phase phase)
*			2. update_vif_enables()
**/
// -----------------------------------------------------------------------------
class axi_read_env extends uvm_env;

	// Virtual Interface variable
	protected virtual interface axi_if vif;

	// Control properties
	protected int num_agents = 0;

	// Components of the environment
	axi_slave_read_agent read_slaves[];
	axi_master_read_agent read_master;

	// Configuration
	axi_config config_obj;

	// control bits
	bit checks_enable = 1;
	bit coverage_enable = 1;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_read_env)
		`uvm_field_int(num_agents, UVM_DEFAULT)
		`uvm_field_object(config_obj, UVM_DEFAULT)
		`uvm_field_object(read_master, UVM_DEFAULT)
		`uvm_field_sarray_object(read_slaves, UVM_DEFAULT)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
		`uvm_field_int(coverage_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// Additional class methods
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void start_of_simulation_phase(uvm_phase phase);
	extern virtual function void update_config(axi_config config_obj);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task update_vif_enables();

endclass : axi_read_env

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : propagate configuration object, set config for master and slave
*			and create master and slave agents
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_read_env::build_phase(uvm_phase phase);

		super.build_phase(phase);

		if(config_obj == null) //begin
			if (!uvm_config_db#(axi_config)::get(this, "", "axi_config", config_obj)) begin
				`uvm_info("NOCONFIG", "Using default_axi_config", UVM_MEDIUM)
				$cast(config_obj, factory.create_object_by_name("axi_config","config_obj"));
			end

		// set the master config
		uvm_config_db#(axi_master_config)::set(this, "*", "axi_master_config", config_obj.master);
		// set the slave configs
		foreach(config_obj.slave_list[i]) begin
			string sname;
			sname = $sformatf("read_slave[%0d]*", i);
			uvm_config_db#(axi_slave_config)::set(this, sname, "axi_slave_config", config_obj.slave_list[i]);
		end

		// create agents
		read_master = axi_master_read_agent::type_id::create("read_master",this);
		read_slaves = new[config_obj.slave_list.size()];
		for(int i = 0; i < config_obj.slave_list.size(); i++) begin
			read_slaves[i] = axi_slave_read_agent::type_id::create($sformatf("read_slave[%0d]", i), this);
		end

	endfunction : build_phase

//------------------------------------------------------------------------------
/**
* Function : connect_phase
* Purpose : propagate virtual interface
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_read_env::connect_phase(input uvm_phase phase);
		super.connect_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

	endfunction

//------------------------------------------------------------------------------
/**
* Function : start_of_simulation_phase
* Purpose : start simulation
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_read_env::start_of_simulation_phase(uvm_phase phase);
		set_report_id_action_hier("CFGOVR", UVM_DISPLAY);
		set_report_id_action_hier("CFGSET", UVM_DISPLAY);
		check_config_usage();
	endfunction : start_of_simulation_phase

//------------------------------------------------------------------------------
/**
* Function : update_config
* Purpose : update configuration
* Parameters :	config_obj
* Return :	void
**/
//------------------------------------------------------------------------------
function void axi_read_env::update_config(axi_config config_obj);
  read_master.update_config(config_obj.master);
  foreach(read_slaves[i])
    read_slaves[i].update_config(config_obj.slave_list[i]);
endfunction : update_config

//------------------------------------------------------------------------------
/**
* Task : update_vif_enables
* Purpose : update vif
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
task axi_read_env::update_vif_enables();
	vif.has_checks <= checks_enable;
	vif.has_coverage <= coverage_enable;
	forever begin
		@(checks_enable || coverage_enable);
    	vif.has_checks <= checks_enable;
    	vif.has_coverage <= coverage_enable;
	end
endtask : update_vif_enables

//------------------------------------------------------------------------------
/**
* Task : run_phase
* Purpose : create thread for update_vif_enables
* Inputs :	phase - uvm phase
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
task axi_read_env::run_phase(uvm_phase phase);
  fork
    update_vif_enables();
  join
endtask : run_phase

`endif