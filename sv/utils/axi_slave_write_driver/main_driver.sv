`ifndef AXI_SLAVE_WRITE_MAIN_DRIVER_SVH
`define AXI_SLAVE_WRITE_MAIN_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_main_driver extends uvm_component;

	static axi_slave_write_main_driver driverInstance;


	`uvm_component_utils(axi_slave_write_main_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern static function axi_slave_write_main_driver getDriverInstance(uvm_component parent);

endclass : axi_slave_write_main_driver

	function axi_slave_write_main_driver axi_slave_write_main_driver::getDriverInstance(uvm_component parent);
	    if(driverInstance == null )
		    begin
			    driverInstance = new("AxiSlaveWriteMainDriver", parent);
			    $display("Creating Axi Slave Write Main Driver ");
		    end
		return driverInstance;
	endfunction

`endif