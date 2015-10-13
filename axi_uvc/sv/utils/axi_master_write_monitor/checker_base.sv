`ifndef AXI_MASTER_WRITE_CHECKER_BASE_SVH
`define AXI_MASTER_WRITE_CHECKER_BASE_SVH

/**
* Project : AXI UVC
*
* File : checker base.sv
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
* Description :it is virtual checker that every checker needs to extend
*
*
**/


class axi_master_write_checker_map extends uvm_component;
	int 									checker_id 						= 0;
	axi_master_write_checker_base 			suscribed_checker_base_instance;
	true_false_enum							suscribed_to_address_items 		= FALSE;
	true_false_enum							suscribed_to_data_items			= FALSE;
	true_false_enum							suscrived_to_response_items		= FALSE;
	true_false_enum							suscribed_to_reset_event		= FALSE;
	true_false_enum							suscribed_to_print_event		= FALSE;

	`uvm_component_utils(axi_master_write_checker_map)


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase


	// Get driver_instance
	function axi_master_write_checker_base getSuscribed_checker_base_instance();
		return suscribed_checker_base_instance;
	endfunction

	// Set driver_instance
	function void setSuscribed_checker_base_instance(axi_master_write_checker_base suscribed_checker_base_instance);
		this.suscribed_checker_base_instance = suscribed_checker_base_instance;
	endfunction

	// Get suscribed_to_address_items
	function true_false_enum getSuscribed_to_address_items();
		return suscribed_to_address_items;
	endfunction

	// Set suscribed_to_address_items
	function void setSuscribed_to_address_items(true_false_enum suscribed_to_address_items);
		this.suscribed_to_address_items = suscribed_to_address_items;
	endfunction

	// Get suscribed_to_data_items
	function true_false_enum getSuscribed_to_data_items();
		return suscribed_to_data_items;
	endfunction

	// Set suscribed_to_data_items
	function void setSuscribed_to_data_items(true_false_enum suscribed_to_data_items);
		this.suscribed_to_data_items = suscribed_to_data_items;
	endfunction

	// Get suscribed_to_reset_event
	function true_false_enum getSuscribed_to_reset_event();
		return suscribed_to_reset_event;
	endfunction

	// Set suscribed_to_reset_event
	function void setSuscribed_to_reset_event(true_false_enum suscribed_to_reset_event);
		this.suscribed_to_reset_event = suscribed_to_reset_event;
	endfunction

	// Get checker_id
	function int getChecker_id();
		return checker_id;
	endfunction

	// Set checker_id
	function void setChecker_id(int checker_id);
		this.checker_id = checker_id;
	endfunction

	// Get suscribed_to_print_event
	function true_false_enum getSuscribed_to_print_event();
		return suscribed_to_print_event;
	endfunction

	// Set suscribed_to_print_event
	function void setSuscribed_to_print_event(true_false_enum suscribed_to_print_event);
		this.suscribed_to_print_event = suscribed_to_print_event;
	endfunction

	// Get suscrived_to_response_items
	function true_false_enum getSuscrived_to_response_items();
		return suscrived_to_response_items;
	endfunction

	// Set suscrived_to_response_items
	function void setSuscrived_to_response_items(true_false_enum suscrived_to_response_items);
		this.suscrived_to_response_items = suscrived_to_response_items;
	endfunction



endclass




class axi_master_write_checker_base extends uvm_component;
	axi_write_conf								config_obj;
	axi_write_global_conf						global_config_obj;
	axi_master_write_main_monitor				main_monitor_instance;

	`uvm_component_utils(axi_master_write_coverage_base)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		main_monitor_instance = axi_master_write_main_monitor::getMonitorMainInstance(this);
		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", config_obj))
		 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})
		 configureChecker();
	endfunction : build_phase

	extern virtual task pushAddressItem(axi_write_address_collector_mssg mssg);
	extern virtual task pushDataItem(axi_write_data_collector_mssg mssg);
	extern virtual task pushResponseItem(axi_write_response_collector_mssg mssg);

	extern virtual task reset();
	extern virtual task printState();

	extern local function  void configureChecker();

endclass


	task axi_master_write_checker_base::printState();
		$display("axi_master_write_checker_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	task axi_master_write_checker_base::pushAddressItem(input axi_write_address_collector_mssg mssg);
		$display("axi_master_write_checker_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	task axi_master_write_checker_base::pushDataItem(input axi_write_data_collector_mssg mssg);
		$display("axi_master_write_checker_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	task axi_master_write_checker_base::pushResponseItem(input axi_write_response_collector_mssg mssg);
		$display("axi_master_write_checker_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	task axi_master_write_checker_base::reset();
		$display("axi_master_write_checker_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	function void axi_master_write_checker_base::configureChecker();
		global_config_obj = config_obj.getGlobal_config_object();
	endfunction


`endif