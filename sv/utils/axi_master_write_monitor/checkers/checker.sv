`ifndef AXI_MASTER_WRITE_CHECKER_SVH
`define AXI_MASTER_WRITE_CHECKER_SVH

/**
* Project : AXI UVC
*
* File : checker.sv
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
* Description : default checker
*
* Classes :	1.axi_master_write_checker
*
**/

//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_checker
//
//--------------------------------------------------------------------------------------
//
// DESCRIPTION:
//			axi_master_write_checker is default checker in axi_master_write einvironment
//			It checks if:
//
//				1. every data package ID has already been registerd on address bus and curretly active
//				(it is not complited)
//
//
//				2. on every ID last field active there is response.
//
//				3. burst is completed and currently waiting for response from slave, that there is no
//				new burst registration with same ID on address bus.
//
//				4. number of active bursts is in range of setted burst_deept
//
//				5. there is no OKAY or EXOKAY response from slave if burst is active
//
//
//
// CONFIGURATION:
//
//		1. axi_write_burst_deepth
//
//			to configure this field( axi4 supporst only axi_write_burst_deept = 1) You must use user_configuration
//			(for more information see user_configuration_skeleton in configurations )
//
//			1. registerConfiguration("general", "axi_3_support", TRUE);
//
//				if this is set as TRUE then axi_write_burst_deepth can have any unsigned integer value,
//				otherwise axi_write_burst_deepth == 1
//
//			2.registerConfiguration("general", "master_write_deepth", 10);
//
//				if previous configuration ( axi_3_support ) is TRUE then with this
//				registration you can set axi_write_burst_deepth value.
//
//
//
// REQUIREMENTS:
//
//			1. this class must extend axi_master_write_checker_base
//
//--------------------------------------------------------------------------------------





class axi_master_write_checker extends axi_master_write_checker_base;
	axi_depth_config								depth;
	axi_slave_write_addr_mssg						current_burst_queue[$];
	axi_slave_write_addr_mssg						waiting_rsp_burst_queue[$];
	semaphore 										sem;

	`uvm_component_utils(axi_master_write_checker)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		void'(main_monitor_instance.suscribeChecker(this, TRUE, TRUE, TRUE, TRUE, TRUE));
		depth = new();
		sem = new(1);
		depth.depth = global_config_obj.getMaster_write_deepth();
	endfunction : build_phase

	extern task main();

	extern task pushAddressItem(axi_write_address_collector_mssg mssg);
	extern task pushDataItem(axi_write_data_collector_mssg mssg);
	extern task pushResponseItem(axi_write_response_collector_mssg mssg);

	extern task reset();
	extern task printState();

endclass : axi_master_write_checker


	task axi_master_write_checker::pushAddressItem(input axi_write_address_collector_mssg mssg);
		axi_slave_write_addr_mssg status;
		int i;
		status = new();

		//check if there is already same ID in current bursts, if this is true rais an ERROR
		sem.get(1);
		foreach(current_burst_queue[i])
			begin
				if(current_burst_queue[i].getID() == mssg.getId())
					begin
						sem.put(1);
						`uvm_warning(get_name(),$sformatf("Recived already existing ID, monitor is REJECTING ID: %h",mssg.id))
						return;
					end
			end

		// if deepth exists and monitor recives new transfer that is deepth+1 than raise error
		if(depth.deept_exists == TRUE)
			begin
			if(depth.depth <= current_burst_queue.size())
				begin
					sem.put(1);
					`uvm_warning(get_name(),$sformatf("Recived more active IDs then is allowd by depth configuration, depth: %d, REJECTING ID", depth.getdepth()))
					return;
				end
			end
		sem.put(1);

		//if everythin is OK than add burst to current bursts
		status.setAddr(mssg.getAddr());
		status.setID(mssg.getId());
		status.setLast_one(FALSE);
		status.setLen(mssg.getLen());

//		`uvm_info(get_name(), $sformatf("Adding new ID from Address bus, ID: %h, start address: %h ", mssg.getId(), mssg.getAddr()), UVM_INFO)

		sem.get(1);
		current_burst_queue.push_front(status);
		sem.put(1);


	endtask

	task axi_master_write_checker::pushDataItem(input axi_write_data_collector_mssg mssg);
		int					i;
		int 				delete_tmp = -1;
		true_false_enum 	found_ID = FALSE;

		sem.get(1);
		foreach(current_burst_queue[i])
			begin
				if(current_burst_queue[i].getID() == mssg.getId())
					begin
						found_ID = TRUE;
						current_burst_queue[i].decrementLen(1);
						if(current_burst_queue[i].getLen() == 0 )
							begin
								waiting_rsp_burst_queue.push_front(current_burst_queue[i]);
								delete_tmp = i;
								//current_burst_queue.delete(i); // TODO ASK DARKO
							end
					end
			end
		if(delete_tmp != -1)
			current_burst_queue.delete(delete_tmp); // i can do this because this is sill protected by "mutex"
		sem.put(1);

		if(found_ID == FALSE)
			begin
				`uvm_warning(get_name(), $sformatf(" Recieived data with not registred ID: %h, monitor is REJECTING DATA PACKAGE",mssg.getId()))
			end

	endtask

	task axi_master_write_checker::pushResponseItem(input axi_write_response_collector_mssg mssg);
		int 				i;
		int 				delete_tmp = -1;
		true_false_enum 	found_ID = FALSE;
		sem.get(1);
		foreach(waiting_rsp_burst_queue[i])
			begin
				if(waiting_rsp_burst_queue[i].getID() == mssg.getId())
					begin
						found_ID = TRUE;
						delete_tmp = i;
					end
			end
		if(delete_tmp != -1)
			waiting_rsp_burst_queue.delete(delete_tmp);
		delete_tmp = -1;
		sem.put(1);

		sem.get(1);
		foreach(current_burst_queue[i])
			begin
				if(current_burst_queue[i].getID() == mssg.getId())
					begin
						if((mssg.getResp == DECERR) || ( mssg.getResp == SLVERR))
							begin
								delete_tmp = i;
								found_ID = TRUE;
							end
					end
			end
		if(delete_tmp != -1)
			current_burst_queue.delete(delete_tmp);
		sem.put(1);

		if(found_ID == FALSE)
			begin
				`uvm_warning(get_name(), $sformatf(" Recieived response with not registred ID: %h, monitor is REJECTING DATA PACKAGE",mssg.getId()))
			end
	endtask

	task axi_master_write_checker::main();


	endtask

	task axi_master_write_checker::reset();
		`uvm_info(get_name(),$sformatf("Recieved reset, deleting queues"), UVM_INFO)
	sem.get(1);
		current_burst_queue.delete();
		waiting_rsp_burst_queue.delete();
	sem.put(1);

	endtask

	task axi_master_write_checker::printState();
		int i;

	 	sem.get(1);
		`uvm_info(get_name(),$sformatf("number of acitve bursts : %d, waiting for rsp queues: %d ", current_burst_queue.size(), waiting_rsp_burst_queue.size()), UVM_INFO)
		foreach(current_burst_queue[i])
			begin
				`uvm_info(get_name(),$sformatf("Active burst no:%d ID: %h",i, current_burst_queue[i].getID()), UVM_INFO)
			end

		foreach(waiting_rsp_burst_queue[i])
			begin
				`uvm_info(get_name(),$sformatf("Waiting for rsp no:%d ID: %h",i, waiting_rsp_burst_queue[i].getID()), UVM_INFO)
			end

	endtask

`endif