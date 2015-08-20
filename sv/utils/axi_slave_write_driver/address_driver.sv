`ifndef AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
`define AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_address_driver extends axi_slave_write_base_driver;


	static axi_slave_write_address_driver 	driverInstance;
	axi_write_slave_addr_mssg				mssg;

	`uvm_component_utils(axi_slave_write_address_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

//	extern static function axi_slave_write_address_driver getDriverInstance(input uvm_component parent);

	extern function void init();
	extern function void  send();
	extern task waitOnValid(ref true_false_enum ready);
	extern task getData();
	extern task completeRecieve();
	extern task setReady();
	extern task getDelay(ref int delay);

endclass : axi_slave_write_address_driver

/*
function axi_slave_write_address_driver axi_slave_write_address_driver::getDriverInstance(input uvm_component parent);
	if(driverInstance == null)
		begin
			$display("Creating axi slave write address driver");
			driverInstance = new("AxiSlaveWriteAddressDriver",parent);
		end
	return driverInstance;
endfunction
*/

function void axi_slave_write_address_driver::init();
	vif.awready = 1'b1;
endfunction

function void axi_slave_write_address_driver::send();
	
endfunction

task axi_slave_write_address_driver::getData();
   mssg = new();
   mssg.setID(vif.awid);
   mssg.setLen(vif.awlen);
endtask


`endif
