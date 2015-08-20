`ifndef AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
`define AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_address_driver extends uvm_component;

	protected virtual axi_if 				vif;
	static axi_slave_write_address_driver 	driverInstance;
	axi_slave_write_main_driver 			main_driver;



	`uvm_component_utils(axi_slave_write_address_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern static function axi_slave_write_address_driver getDriverInstance(input uvm_component parent);
	extern task main();

endclass : axi_slave_write_address_driver

function axi_slave_write_address_driver axi_slave_write_address_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
		begin
			$display("Creating axi slave write address driver");
			driverInstance = new("AxiSlaveWriteAddressDriver",parent);
		end
	return driverInstance;
endfunction

task axi_slave_write_address_driver::main();
    // TODO Auto-generated task stub

endtask

`endif
