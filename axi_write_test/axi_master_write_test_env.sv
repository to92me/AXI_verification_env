`ifndef AXI_MASTER_WRITE_ENV
`define AXI_MASTER_WRITE_ENV
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_env
//
//------------------------------------------------------------------------------

class axi_master_write_env extends uvm_env;

	// Virtual Interface variable
	protected virtual interface axi_if vif;

	bit checks_enable = 1;
	bit coverage_enable = 1;
	axi_config config_obj;
	axi_master_write_agent master;



	// Provide implementations of virtual methods such as get_type_name and create
`uvm_component_utils_begin(axi_master_write_env)
	 `uvm_field_int(checks_enable, UVM_DEFAULT | UVM_UNSIGNED)
	 `uvm_field_int(coverage_enable, UVM_DEFAULT | UVM_UNSIGNED)
	 `uvm_field_object(config_obj, UVM_DEFAULT)
	 `uvm_field_object(master, UVM_DEFAULT)
 `uvm_component_utils_end


	// new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern function void start_of_simulation_phase(uvm_phase phase);
	extern function void update_config(axi_config config_obj);
	extern task run_phase(uvm_phase phase);
	extern task update_vif_enables();


endclass : axi_master_write_env


function void axi_master_write_env::build_phase(uvm_phase phase);

		super.build_phase(phase);

		if(config_obj == null) //begin
			if (!uvm_config_db#(axi_config)::get(this, "", "config_obj", config_obj)) begin
				`uvm_info("NOCONFIG", "Using default_axi_config", UVM_MEDIUM)
				$cast(config_obj, factory.create_object_by_name("axi_config","config_obj"));
			end

		uvm_config_object::set(this, "*", "axi_config", config_obj);

		foreach(config_obj.slave_list[i]) begin
			string sname;
			sname = $sformatf("read_slave[%0d]*", i);
			uvm_config_object::set(this, sname, "config_obj", config_obj.slave_list[i]);
		end

		master = axi_master_write_agent::type_id::create("master write agent",this);

endfunction : build_phase


function void axi_master_write_env::connect_phase(input uvm_phase phase);
		super.connect_phase(phase);

		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

	endfunction


	// UVM start_of_simulation_phase
	function void axi_master_write_env::start_of_simulation_phase(uvm_phase phase);
		set_report_id_action_hier("CFGOVR", UVM_DISPLAY);
		set_report_id_action_hier("CFGSET", UVM_DISPLAY);
		check_config_usage();
	endfunction : start_of_simulation_phase

// update_config() method
function void axi_master_write_env::update_config(axi_config config_obj);

endfunction : update_config

// update_vif_enables
task axi_master_write_env::update_vif_enables();
	vif.has_checks <= checks_enable;
	vif.has_coverage <= coverage_enable;
	forever begin
		@(checks_enable || coverage_enable);
    	vif.has_checks <= checks_enable;
    	vif.has_coverage <= coverage_enable;
	end
endtask : update_vif_enables

//UVM run_phase()
task axi_master_write_env::run_phase(uvm_phase phase);
  fork
    update_vif_enables();
  join
endtask : run_phase

`endif
