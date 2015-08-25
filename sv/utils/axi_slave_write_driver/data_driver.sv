`ifndef AXI_SLAVE_WRITE_DATA_DRIVER_SVH
`define AXI_SLAVE_WRITE_DATA_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_data_driver extends axi_slave_write_base_driver;

	axi_slave_write_data_mssg				mssg;
	axi_slave_write_main_driver				main_driver;
	int 									item_counter = 0;

	`uvm_component_utils(axi_slave_write_address_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void putMainDriverInstance(axi_slave_write_main_driver driver_instance);

	extern task init();
	extern task send();
	extern task waitOnValid(ref true_false_enum ready);
	extern task getData();
	extern task completeRecieve();
	extern task setReady();
	extern task getDelay(ref int delay);

endclass : axi_slave_write_data_driver

function void axi_slave_write_data_driver::putMainDriverInstance(input axi_slave_write_main_driver driver_instance);
	main_driver = driver_instance;
endfunction


task axi_slave_write_data_driver::init();

	assert(ready_default_randomization.randomize());
   if(ready_default_randomization.ready == READY_DEFAULT_0)
	   vif.wready <= 1'b0;
   else
	   vif.wready <= 1'b1;
endtask

task axi_slave_write_data_driver::send();
 	main_driver.pushDataMssg(mssg);
endtask

task axi_slave_write_data_driver::getData();
//	$display("SLAVE: DATA recived and collected data, item_conter = %d ", item_counter);
	mssg = new();
   	mssg.setID(vif.wid);
	mssg.setLast_one(vif.wlast);
//	item_counter++;
endtask

task axi_slave_write_data_driver::waitOnValid(ref true_false_enum ready);
//	if(vif.wvalid == 1)
//		begin
//		ready = TRUE;
//		$display("SLAVE DATA:  read : %d",vif.wvalid);
//		end
//	else
//		begin
//		ready = FALSE;
//		end
//	    $display("                 				 	               SLAVE DATA  vaiting valid");
@(posedge vif.sig_clock iff vif.wvalid == 1);
	ready = TRUE;
endtask

task axi_slave_write_data_driver::getDelay(ref int delay);
	    assert(delay_randomization.randomize());
	    delay = delay_randomization.delay;
endtask

task axi_slave_write_data_driver::setReady();
    vif.wready <= 1'b1;
endtask

task axi_slave_write_data_driver::completeRecieve();
	ready_default_randomization.ready_random = TRUE;
   assert(ready_default_randomization.randomize());
   if(ready_default_randomization.ready == READY_DEFAULT_0)
	   vif.wready <= 1'b0;
   else
	   vif.wready <= 1'b0;
endtask

`endif