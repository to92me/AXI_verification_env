`ifndef AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
`define AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_address_driver extends axi_slave_write_base_driver;

	axi_slave_write_addr_mssg				mssg;
	axi_slave_write_main_driver				main_driver;

	`uvm_component_utils(axi_slave_write_address_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

//	extern static function axi_slave_write_address_driver getDriverInstance(input uvm_component parent);
	extern function void putMainDriverInstance(axi_slave_write_main_driver driver_instance);

	extern task init();
	extern task send();
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
function void axi_slave_write_address_driver::putMainDriverInstance(input axi_slave_write_main_driver driver_instance);
	main_driver = driver_instance;
endfunction

task axi_slave_write_address_driver::init();
	assert(ready_default_randomization.randomize());
   if(ready_default_randomization.ready == READY_DEFAULT_0)
	   vif.awready <= 1'b0;
   else
	   vif.awready <= 1'b1;
endtask

task axi_slave_write_address_driver::send();
 	main_driver.pushAddrMssg(mssg);
endtask

task axi_slave_write_address_driver::getData();
//   $display("SLAVE: ADDR recived and collected data");
   mssg = new();
   mssg.setID(vif.awid);
   mssg.setLen(vif.awlen);
endtask

task axi_slave_write_address_driver::waitOnValid(ref true_false_enum ready);
	@(posedge vif.sig_clock iff vif.awvalid == 1);
	ready = TRUE;
endtask

task axi_slave_write_address_driver::getDelay(ref int delay);
	    assert(delay_randomization.randomize());
	    delay = delay_randomization.delay;
endtask

task axi_slave_write_address_driver::setReady();
    vif.awready <= 1'b1;
endtask

task axi_slave_write_address_driver::completeRecieve();
//   assert(ready_default_randomization.randomize());
//   if(ready_default_randomization.ready == READY_DEFAULT_0)
//	   vif.awready <= 1'b0;
//   else
	   vif.awready <= 1'b0;
endtask


`endif
