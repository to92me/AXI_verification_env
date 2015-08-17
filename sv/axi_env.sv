/******************************************************************************
	* DVT CODE TEMPLATE: env
	* Created by root on Aug 2, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_env
//
//------------------------------------------------------------------------------

`ifndef AXI_ENV_SV
`define AXI_ENV_SV

class axi_env extends uvm_env;

	// Virtual Interface variable
	protected virtual interface axi_if vif;

	// Control properties
	protected int num_agents = 0;

	// Components of the environment
	axi_slave_read_agent read_slaves[];
	axi_master_read_agent read_master;
	axi_read_monitor read_monitor;

	// Configuration
	axi_config config_obj;

	// control bits
	bit checks_enable;
	bit coverage_enable;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_env)
		`uvm_field_int(num_agents, UVM_DEFAULT)
		`uvm_field_object(config_obj, UVM_DEFAULT)
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

endclass : axi_env

	// build_phase
	function void axi_env::build_phase(uvm_phase phase);

		super.build_phase(phase);

		if(config_obj == null) //begin
			if (!uvm_config_db#(axi_config)::get(this, "", "config_obj", config_obj)) begin
				`uvm_info("NOCONFIG", "Using default_axi_config", UVM_MEDIUM)
				$cast(config_obj, factory.create_object_by_name("axi_config","config_obj"));
			end

		// set the master config
		uvm_config_object::set(this, "*", "config_obj", config_obj);
		// set the slave configs
		foreach(config_obj.slave_list[i]) begin
			string sname;
			sname = $sformatf("read_slave[%0d]*", i);
			uvm_config_object::set(this, sname, "config_obj", config_obj.slave_list[i]);
		end

		read_monitor = axi_read_monitor::type_id::create("read_monitor",this);
		read_master = axi_master_read_agent::type_id::create(config_obj.master.name,this);
		read_slaves = new[config_obj.slave_list.size()];
		for(int i = 0; i < config_obj.slave_list.size(); i++) begin
			read_slaves[i] = axi_slave_read_agent::type_id::create($sformatf("read_slave[%0d]", i), this);
		end

	endfunction : build_phase

	function void axi_env::connect_phase(input uvm_phase phase);
		super.connect_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

		read_master.monitor = read_monitor;
		foreach(read_slaves[i]) begin
			read_slaves[i].monitor = read_monitor;
			if (read_slaves[i].is_active == UVM_ACTIVE)
				read_slaves[i].driver.addr_trans_port.connect(read_monitor.addr_trans_export);
		end
	endfunction


	// UVM start_of_simulation_phase
	function void axi_env::start_of_simulation_phase(uvm_phase phase);
		set_report_id_action_hier("CFGOVR", UVM_DISPLAY);
		set_report_id_action_hier("CFGSET", UVM_DISPLAY);
		check_config_usage();
	endfunction : start_of_simulation_phase

// update_config() method
function void axi_env::update_config(axi_config config_obj);
  read_monitor.config_obj = config_obj;
  read_master.update_config(config_obj);
  foreach(read_slaves[i])
    read_slaves[i].update_config(config_obj.slave_list[i]);
endfunction : update_config

// update_vif_enables
task axi_env::update_vif_enables();
	vif.has_checks <= checks_enable;
	vif.has_coverage <= coverage_enable;
	forever begin
		@(checks_enable || coverage_enable);
    	vif.has_checks <= checks_enable;
    	vif.has_coverage <= coverage_enable;
	end
endtask : update_vif_enables

//UVM run_phase()
task axi_env::run_phase(uvm_phase phase);
  fork
    update_vif_enables();
  join
endtask : run_phase

`endif