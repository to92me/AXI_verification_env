`ifndef AXI_SLAVE_WRITE_DATA_DRIVER_SVH
`define AXI_SLAVE_WRITE_DATA_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_data_driver extends uvm_component;

	static axi_slave_write_data_driver 			driverInstance;


	`uvm_component_utils(axi_slave_write_data_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern static function axi_slave_write_data_driver getDriverInstance(uvm_component parent);

endclass : axi_slave_write_data_driver

	function axi_slave_write_data_driver axi_slave_write_data_driver::getDriverInstance(input uvm_component parent);
	   if(driverInstance == null)
		   begin
			   $display("Creating Axi Slave Write Data Driver");
			   driverInstance = new("AxiSlaveWriteDataDriver", parent);
		   end
		return driverInstance;
	endfunction

`endif