`ifndef AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH
`define AXI_SLAVE_WRITE_ADDRESS_DRIVER_SVH

/****************************************************************
* Project : AXI UVC
*
* File : data_driver.sv
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
* Description : data bus driving util
*
* Classes :	1.axi_slave_write_data_driver
******************************************************************/

//-------------------------------------------------------------------------------------
//
// CLASS: axi_slave_write_address_driver
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//  		this class extends axi_slave_write_base_driver and overrides all virtual
//			methodes so it collects data from axi address vif and sends to data driver
//			ids for this slave
//
// API:
//
//
//------------------------------------------------------------------------------


class axi_slave_write_address_driver extends axi_slave_write_base_driver;

	axi_slave_write_addr_mssg				mssg;
	axi_slave_write_main_driver				main_driver;
	axi_slave_write_data_driver				data_driver;
	int 									item_counter = 0;

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
	extern task checkIDAddr(ref true_false_enum correct_slave);
	extern function void setDataDriverInstance(axi_slave_write_data_driver driver_isntance);
	extern task waitFrame(ref true_false_enum detected_frame);
	extern function void setBusReadConfiguration();


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
//	$display("           																			COLLECT ADDR ID: %h, count: %d", vif.awid, item_counter);
	item_counter++;
   	mssg = new();
   	mssg.setID(vif.awid);
   	mssg.setLen(vif.awlen);
	mssg.setAddr(vif.awaddr);
endtask

task axi_slave_write_address_driver::waitOnValid(ref true_false_enum ready);
	@(posedge vif.sig_clock iff vif.awvalid == 1);
	ready = TRUE;
//	if(vif.awvalid == 1)
//		ready = TRUE;
//	else
//		ready = FALSE;
endtask

task axi_slave_write_address_driver::getDelay(ref int delay);
	if(ready_default_randomization.ready == READY_DEFAULT_0)
		begin
	    	assert(delay_randomization.randomize());
	    	delay = delay_randomization.delay;
		end
	else
		begin
			delay = 0;
		end
endtask

task axi_slave_write_address_driver::setReady();
	if(vif.awready == 1'b1)
		begin
			#2;
    		vif.awready <= 1'b1;
		end
endtask

task axi_slave_write_address_driver::completeRecieve();
	#2
	assert(ready_default_randomization.randomize());
	if(ready_default_randomization.ready == READY_DEFAULT_0)
	   	vif.awready <= 1'b0;
	else
	   	vif.awready <= 1'b1;
endtask

task axi_slave_write_address_driver::checkIDAddr(ref true_false_enum correct_slave);
	if(config_obj.check_addr_range(mssg.getAddr()))
		begin
			data_driver.setSlaveID(mssg.ID);
			correct_slave = TRUE;
		end
	else
		begin
			correct_slave = FALSE;
		end
endtask

function void axi_slave_write_address_driver::setDataDriverInstance(input axi_slave_write_data_driver driver_isntance);
   this.data_driver = driver_isntance;
endfunction

task axi_slave_write_address_driver::waitFrame(ref true_false_enum detected_frame);
	@(posedge vif.sig_clock)
	if(vif.awvalid == 1 && vif.awready == 1)
		detected_frame = TRUE;
	else
		detected_frame = FALSE;

endtask

function void axi_slave_write_address_driver::setBusReadConfiguration();
    bus_read_config_obj = uvc_config_obj.getSlave_addr_config_object();
endfunction

`endif
