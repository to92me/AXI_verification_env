`ifndef AXI_slave_WRITE_COVERAGE_BASE_SVH
`define AXI_slave_WRITE_COVERAGE_BASE_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_coverage_map extends uvm_component;
	int 									coverage_id;
	axi_slave_write_coverage_base 			suscribed_coverage_instace;
	true_false_enum							suscribed_to_address_sample;
	true_false_enum							suscribed_to_data_sample;
	true_false_enum							suscribed_to_response_sample;


	`uvm_component_utils(axi_slave_write_coverage_map)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase


	// Get coverage_id
	function int getCoverage_id();
		return coverage_id;
	endfunction

	// Set coverage_id
	function void setCoverage_id(int coverage_id);
		this.coverage_id = coverage_id;
	endfunction

	// Get suscribed_coverage_instace
	function axi_slave_write_coverage_base getSuscribed_coverage_instace();
		return suscribed_coverage_instace;
	endfunction

	// Set suscribed_coverage_instace
	function void setSuscribed_coverage_instace(axi_slave_write_coverage_base suscribed_coverage_instace);
		this.suscribed_coverage_instace = suscribed_coverage_instace;
	endfunction

	// Get suscribed_to_address_sample
	function true_false_enum getSuscribed_to_address_sample();
		return suscribed_to_address_sample;
	endfunction

	// Set suscribed_to_address_sample
	function void setSuscribed_to_address_sample(true_false_enum suscribed_to_address_sample);
		this.suscribed_to_address_sample = suscribed_to_address_sample;
	endfunction

	// Get suscribed_to_data_sample
	function true_false_enum getSuscribed_to_data_sample();
		return suscribed_to_data_sample;
	endfunction

	// Set suscribed_to_data_sample
	function void setSuscribed_to_data_sample(true_false_enum suscribed_to_data_sample);
		this.suscribed_to_data_sample = suscribed_to_data_sample;
	endfunction

	// Get suscribed_to_response_sample
	function true_false_enum getSuscribed_to_response_sample();
		return suscribed_to_response_sample;
	endfunction

	// Set suscribed_to_response_sample
	function void setSuscribed_to_response_sample(true_false_enum suscribed_to_response_sample);
		this.suscribed_to_response_sample = suscribed_to_response_sample;
	endfunction


endclass



class axi_slave_write_coverage_base  extends uvm_component;

	axi_slave_write_main_monitor				main_monitor_instance;

	axi_write_address_collector_mssg 	addr_item;
	axi_write_data_collector_mssg		data_item;
	axi_write_response_collector_mssg	response_item;


	`uvm_component_utils(axi_slave_write_coverage_base)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		addr_item = new();
		data_item = new();
		response_item = new();

	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		main_monitor_instance = axi_slave_write_main_monitor::getMonitorMainInstance(this);

	endfunction : build_phase


	extern task pushAddrItem(input axi_write_address_collector_mssg mssg);
	extern task pushDatatItem(input axi_write_data_collector_mssg mssg);
	extern task pushResponseItem(input axi_write_response_collector_mssg mssg);

	extern virtual task sampleAddr();
	extern virtual task sampleData();
	extern virtual task sampleResponse();


endclass : axi_slave_write_coverage_base

	task axi_slave_write_coverage_base::pushAddrItem(input axi_write_address_collector_mssg mssg);
		addr_item = mssg;
		this.sampleAddr();
	endtask

	task axi_slave_write_coverage_base::pushDatatItem(input axi_write_data_collector_mssg mssg);
		data_item = mssg;
		this.sampleData();
	endtask

	task axi_slave_write_coverage_base::pushResponseItem(input axi_write_response_collector_mssg mssg);
		response_item = mssg;
		this.sampleResponse();
	endtask

	task axi_slave_write_coverage_base::sampleAddr();
	   	$display("axi_slave_write_coverage_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	task axi_slave_write_coverage_base::sampleData();
	   	$display("axi_slave_write_coverage_base: methode suscribed to but did not redefine it  !!! ");
	endtask

	task axi_slave_write_coverage_base::sampleResponse();
	   	$display("axi_slave_write_coverage_base: methode suscribed to but did not redefine it  !!! ");
	endtask


`endif