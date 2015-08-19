`ifndef AXI_SLAVE_WRITE_BASE_DRIVER_SVH
`define AXI_SLAVE_WRITE_BASE_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_base_driver extends uvm_component;

	axi_slave_write_main_driver 		driver;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_slave_write_base_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		driver = axi_slave_write_main_driver::getDriverInstance(this);

	endfunction : build_phase

	extern virtual task main();
	extern virtual function void init();
	extern virtual function void  send();
	extern virtual task waitOnReady();
	extern virtual task completeTransaction();


endclass : axi_slave_write_base_driver

	task axi_slave_write_base_driver::main();
	    $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , task main NOT IMPELMENTED !, OVERIDE IT ");
	endtask

	function void axi_slave_write_base_driver::init();
	   $display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function init NOT IMPELMENTED !, OVERIDE IT ");
	endfunction

	function void axi_slave_write_base_driver::send();
		$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , function send NOT IMPELMENTED, OVERIDE IT  !");
	endfunction

	task axi_slave_write_base_driver::waitOnReady();
	   	$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , task waitOnReady send NOT IMPELMENTED, OVERIDE IT  !");
	endtask

	task axi_slave_write_base_driver::completeTransaction();
	    	$display("AXI_SLAVE_WRITE_BASE_DRIVER_SVH ERRIR , task complete transaction NOT IMPELMENTED, OVERIDE IT  !");
	endtask


`endif