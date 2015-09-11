`ifndef AXI_SLAVE_WRITE_MAIN_DRIVER_SVH
`define AXI_SLAVE_WRITE_MAIN_DRIVER_SVH

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
* Classes :	1.axi_slave_write_main_driver
******************************************************************/

class axi_slave_write_main_driver extends uvm_component;


	axi_slave_write_rsp_mssg					rsp_mssg;
	axi_slave_write_addr_mssg					burst_status_queue[$];
	event 										recived_something;
	semaphore 									sem;
	mailbox#(axi_slave_write_addr_mssg) 		addr_mbox;
	mailbox#(axi_slave_write_data_mssg)			data_mbox;

	axi_slave_write_address_driver				driver_addr;
	axi_slave_write_data_driver					driver_data;
	axi_slave_write_response_driver				driver_rsp;
	axi_slave_config							config_obj;

	`uvm_component_utils(axi_slave_write_main_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
//		$display("Creating Axi Slave Write Main Driver");
		sem = new(0);
		addr_mbox = new();
		data_mbox = new();
		driver_addr = new("AxiSlaveWriteAddressDriver",this);
		driver_data = new("AxiSlaveWriteDataDriver",this);
		driver_rsp = new("AxiSlaveWriteRspDriver", this);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		driver_addr.putMainDriverInstance(this);
		driver_addr.setDataDriverInstance(driver_data);
		driver_data.putMainDriverInstance(this);
		driver_addr.setSlaveConfig(config_obj);
	endfunction : build_phase

//	extern static function axi_slave_write_main_driver getDriverInstance(uvm_component parent);

	extern task pushAddrMssg(input axi_slave_write_addr_mssg message);
	extern task pushDataMssg(input axi_slave_write_data_mssg message);
	extern task decrementLen(input axi_slave_write_data_mssg message);
	extern task addBurstStatus(input axi_slave_write_addr_mssg message);
	extern function void setSlaveCondig(input axi_slave_config cfg);
	extern task setTesting(input true_false_enum testing);
	extern task reset();
	extern task startDriver();
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

	function void axi_slave_write_main_driver::setSlaveCondig(input axi_slave_config cfg);
	    config_obj = cfg;
	endfunction

	task axi_slave_write_main_driver::setTesting(input true_false_enum testing);
	 	driver_addr.setTesting(testing);
		driver_data.setTesting(testing);
	endtask

	task axi_slave_write_main_driver::startDriver();
		fork
			this.main();
			this.driver_addr.main();
			this.driver_data.main();
			this.driver_rsp.main();
		join
	endtask

	task axi_slave_write_main_driver::reset();
		axi_slave_write_addr_mssg del_addr = new();
		axi_slave_write_data_mssg del_data = new();
		while(this.addr_mbox.try_get(del_addr));
		while(this.data_mbox.try_get(del_data));
	endtask

	task axi_slave_write_main_driver::pushDataMssg(input axi_slave_write_data_mssg message);
		data_mbox.put(message);
		sem.put(1);
	endtask

	task axi_slave_write_main_driver::pushAddrMssg(input axi_slave_write_addr_mssg message);
		addr_mbox.put(message);
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
					addBurstStatus(burst_status);
				end
			else if(data_mbox.num())
				begin
					data_mbox.get(data_mssg);
					decrementLen(data_mssg);
				end
		end
	endtask


	task axi_slave_write_main_driver::decrementLen(input axi_slave_write_data_mssg message);
	    true_false_enum found_match_ID;
		axi_slave_write_rsp_mssg rsp;
		int tmp = -1;
		int i = 0;

		if(message.last_one == TRUE)
			begin
//			$display("SLAVE MAIN: recieved last_one = TRUE");
			end

		foreach(burst_status_queue[i])
			begin
				if (burst_status_queue[i].ID == message.ID)
					begin
						burst_status_queue[i].len--;
						found_match_ID = TRUE;
						if(burst_status_queue[i].len == 0)
							begin
//								$display("SLAVE MAIN: sending done package to RSP DRIVER from dec delay ");
								rsp = new();
								rsp.setID(burst_status_queue[i].ID);
								rsp.rsp = OKAY;
								if(message.last_one == FALSE)
									begin
										$display("ERROR  DATA PACKAGE ADDING sending last but di not get last, iD: %d, count = %d", rsp.ID, burst_status_queue[i].len);
									end
								driver_rsp.pushRsp(rsp);
								tmp = i;
							end
					end
			end
		if(tmp != -1)
			burst_status_queue.delete(tmp);

		if(found_match_ID == FALSE)
			begin
				axi_slave_write_addr_mssg burst_status = new();
				burst_status.ID = message.ID;
				burst_status.len=-1;
				burst_status.last_one = message.last_one;
				burst_status_queue.push_back(burst_status);
				$display("                                                             new status, DATA, ID: %d , len: %d, last: %d", message.ID, burst_status.len, message.last_one);
			end
	endtask

	task axi_slave_write_main_driver::addBurstStatus(input axi_slave_write_addr_mssg message);
	 	int i;
		axi_slave_write_rsp_mssg rsp;
		int tmp = -1;
		true_false_enum found_match_ID = FALSE;

		if(message.last_one == TRUE)
			begin
//			$display("SLAVE MAIN: recieved last_one = TRUE");
			end

		foreach(burst_status_queue[i])
			begin
				if(burst_status_queue[i].ID == message.ID)
					begin
					 	found_match_ID = TRUE;
						burst_status_queue[i].len =  message.len + burst_status_queue[i].len;
						if(burst_status_queue[i].len == 0)
							begin
//								$display("SLAVE MAIN: sending done package to RSP DRIVER add burst status  ");
								rsp = new();
								rsp.setID(burst_status_queue[i].ID);
								rsp.rsp = OKAY;
								if(message.last_one == FALSE)
									begin
										$display("ERROR  ADDR PACKAGE ADDING sending last but di not get last, iD: %d, count = %d", rsp.ID, burst_status_queue[i].len);
									end
								driver_rsp.pushRsp(rsp);
								tmp = i;
							end
					end
			end
		if(tmp != -1)
			burst_status_queue.delete(tmp);

		if(found_match_ID == FALSE)
			begin
				burst_status_queue.push_back(message);
				$display("                                                                    new status, ADDR, ID: %d , len: %d", message.ID, message.len);
			end
	endtask
