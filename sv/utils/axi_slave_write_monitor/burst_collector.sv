`ifndef AXI_SLAVE_WRITE_BURST_COLLECOTOR
`define AXI_SLAVE_WRITE_BURST_COLLECOTOR

class axi_master_write_burst_collector extends axi_slave_write_checker_base;
	axi_frame				axi_queue;

	`uvm_component_utils(axi_master_write_burst_collector)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
//		void'(main_monitor_instance.suscribeChecker(this, TRUE, TRUE, TRUE, TRUE, TRUE));
	endfunction : build_phase

//	extern task main();

	extern task pushAddressItem(axi_write_address_collector_mssg mssg);
	extern task pushDataItem(axi_write_data_collector_mssg mssg);
	extern task pushResponseItem(axi_write_response_collector_mssg mssg);

	extern task reset();
	extern task printState();

endclass : axi_master_write_burst_collector


`endif