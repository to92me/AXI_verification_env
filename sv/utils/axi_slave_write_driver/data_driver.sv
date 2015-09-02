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
		slave_ID = new();
	endfunction

	extern function void putMainDriverInstance(axi_slave_write_main_driver driver_instance);

	extern task init();
	extern task send();
	extern task waitOnValid(ref true_false_enum ready);
	extern task getData();
	extern task completeRecieve();
	extern task setReady();
	extern task getDelay(ref int delay);
	extern task setSlaveID(input bit[ID_WIDTH - 1 : 0] ID);
	extern task checkIDAddr(ref true_false_enum correct_slave);
	extern task waitFrame(ref true_false_enum detected_frame);

endclass : axi_slave_write_data_driver

function void axi_slave_write_data_driver::putMainDriverInstance(input axi_slave_write_main_driver driver_instance);
	main_driver = driver_instance;
endfunction


task axi_slave_write_data_driver::init();
	#2
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
//	$display("           																	COLLECT DATA ID: %h, count: %d", vif.wid, item_counter);
	item_counter++;
	mssg = new();
   	mssg.setID(vif.wid);
	mssg.setLast_one(vif.wlast);
	mssg.setData(vif.wdata);
	mssg.setStrobe(vif.wstrb);
endtask

task axi_slave_write_data_driver::waitOnValid(ref true_false_enum ready);
//if(vif.wvalid == 1)
//	begin
//		ready = TRUE;
//		return;
//	end

@(posedge vif.sig_clock iff vif.wvalid == 1);
	ready = TRUE;
//	if(vif.wvalid == 1)
//		ready = TRUE;
//	else
//		ready = FALSE;
endtask

task axi_slave_write_data_driver::getDelay(ref int delay);
	if(vif.wready != 1)
		begin
	    	assert(delay_randomization.randomize());
	    	delay = delay_randomization.delay;
	    	delay = 0;
		end
	else
		begin
			delay = 0;
		end
endtask

task axi_slave_write_data_driver::setReady();
	if(vif.wready != 1'b1)
		begin
//			@(posedge vif.sig_clock);
			#2
    		vif.wready <= 1'b1;
		end
endtask

task axi_slave_write_data_driver::completeRecieve();
	#2
	ready_default_randomization.ready_random = TRUE;
   assert(ready_default_randomization.randomize());
   if(ready_default_randomization.ready == READY_DEFAULT_0)
	   vif.wready <= 1'b0;
   else
	   vif.wready <= 1'b1;
endtask

task axi_slave_write_data_driver::setSlaveID(input bit[ID_WIDTH-1:0] ID);
	sem.get(1);
    this.slave_ID.setID(ID);
	this.slave_ID.setID_setted(TRUE);
	sem.put(1);
endtask


task axi_slave_write_data_driver::checkIDAddr(ref true_false_enum correct_slave);
    sem.get(1);
	if (this.slave_ID.ID_setted == TRUE && this.slave_ID.ID == mssg.getID())
		begin
			correct_slave = TRUE;
		end
	else
		begin
			correct_slave = FALSE;
		end
endtask

task axi_slave_write_data_driver::waitFrame(ref true_false_enum detected_frame);
	@(posedge vif.sig_clock)
	if(vif.wvalid == 1 && vif.wready == 1)
		detected_frame = TRUE;
	else
		detected_frame = FALSE;

endtask

`endif