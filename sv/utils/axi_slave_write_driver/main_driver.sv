`ifndef AXI_SLAVE_WRITE_MAIN_DRIVER_SVH
`define AXI_SLAVE_WRITE_MAIN_DRIVER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_slave_write_main_driver extends uvm_component;


//	axi_slave_write_addr_mssg					addr_mssg_queue[$];
//	axi_slave_write_data_mssg					data_mssg_queue[$];
	axi_slave_write_rsp_mssg					rsp_mssg;
	axi_slave_write_addr_mssg					burst_status_queue[$];
	event 										recived_something;
	semaphore 									sem;
	mailbox#(axi_slave_write_addr_mssg) 		addr_mbox;
	mailbox#(axi_slave_write_data_mssg)			data_mbox;

	axi_slave_write_address_driver				driver_addr;
	axi_slave_write_data_driver					driver_data;
	axi_slave_write_response_driver				driver_rsp;

	`uvm_component_utils(axi_slave_write_main_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		sem = new();
		addr_mbox = new();
		data_mbox = new();
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

//	extern static function axi_slave_write_main_driver getDriverInstance(uvm_component parent);

	extern task pushAddrMssg(input axi_slave_write_addr_mssg message);
	extern task pushDataMssg(input axi_slave_write_data_mssg message);

	extern task main();


endclass : axi_slave_write_main_driver
	/*
	function axi_slave_write_main_driver axi_slave_write_main_driver::getDriverInstance(uvm_component parent);
	    if(driverInstance == null )
		    begin
			    driverInstance = new("AxiSlaveWriteMainDriver", parent);
			    $display("Creating Axi Slave Write Main Driver ");
		    end
		return driverInstance;
	endfunction
	*/
`endif

	task axi_slave_write_main_driver::pushDataMssg(input axi_slave_write_data_mssg message);
		addr_mbox.put(message);
		sem.put(1);
	endtask

	task axi_slave_write_main_driver::pushAddrMssg(input axi_slave_write_addr_mssg message);
		data_mbox.put(message);
		sem.put(1);
	endtask

	task axi_slave_write_main_driver::main();
		axi_slave_write_addr_mssg 					addr_mssg;
		axi_slave_write_data_mssg					data_mssg;
		axi_slave_write_addr_mssg 					burst_status;
		forever begin
			sem.get(1);
			if(addr_mbox.num())
				begin
					burst_status = new();
					addr_mbox.get(burst_status);
					burst_status_queue.push_back(burst_status);
				end
			else if(data_mbox.num())
				begin
					data_mbox.get(message);
					
				end
		end
	endtask

