`ifndef AXI_WRITE_TEST_TB_SVH
`define AXI_WRITE_TEST_TB_SVH

class  axi_master_write_tb extends uvm_env;

	// Env instance
	axi_master_write_env env;
	axi_config config_obj;

`uvm_component_utils_begin(axi_master_write_tb)
	 `uvm_field_object(env, UVM_ALL_ON)
	 `uvm_field_object(config_obj, UVM_ALL_ON)
 `uvm_component_utils_end


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	// build_phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		config_obj = axi_write_test_config::type_id::create("config",this);
		uvm_config_object::set(this, "env*", "axi_master", config_obj.master);
		uvm_config_object::set(this, "env*", "axi_slave0", config_obj.slave_list[0]);
		env  = axi_master_write_env::type_id::create("env", this);

	endfunction

	// connect_phase
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

	endfunction

endclass

`endif
