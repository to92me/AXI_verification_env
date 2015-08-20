`ifndef AXI_WRITE_TEST_TB_SVH
`define AXI_WRITE_TEST_TB_SVH

class  axi_master_write_tb extends uvm_env;

	// Env instance
	axi_master_write_env env;
	axi_write_test_config config_obj;

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
		config_obj = axi_write_test_config::type_id::create("config_obj",this);
//		uvm_config_object::set(this, "axi_master_write_env.slave*", "axi_config", config_obj.slave_list[0]);
//		uvm_config_object::set(this, "axi_master_write_env*", "axi_config", config_obj.slave_list[1]);
		uvm_config_db#(axi_config)::set(this, "*", "axi_config", config_obj);
		uvm_config_db#(axi_master_config)::set(this, "*", "axi_master_config", config_obj.master);

		env  = axi_master_write_env::type_id::create("env", this);
		$display("TOME TB TB TB ");

	endfunction

	// connect_phase
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

	endfunction

endclass

`endif
