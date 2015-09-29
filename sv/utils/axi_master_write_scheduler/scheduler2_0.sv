`ifndef AXI_MASTER_WRITE_SCHEDULER2_0_SVH
`define AXI_MASTER_WRITE_SCHEDULER2_0_SVH

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
* Classes :	1.axi_master_write_scheduler_package2_0
******************************************************************/


//-------------------------------------------------------------------------------------
//
// CLASS: axi_master_write_scheduler_package2_0
//
//--------------------------------------------------------------------------------------
// DESCRIPTION:
//		axi_master_write_scheduler_package2_0 is as it say in name second revision of
//		axi write uvc scheduler.
//
// FEATURES:
//		1. axi3 data interleavig
//
//      2. axi4 one burst by one
//
//      3. configuration of data_correctnes
//
//		4. configuration of delay between data
//
// API:
//
//		1. task addBurst(axi_frame frame);
//
//			-this methode is used to add new burst for sending
//			-burst will not be added immediately. it can have maximal one clock delay
//
//		2. task getFrameForDrivingVif(output axi_mssg mssg);
//
//			-this methode is used to get next redy package for driving virtual interface
//			-methode as output returns axi_mssg that has status:
//
//				1. READY
//       		   	if status is READY there is data for driving interface and frame (axi_single_frame)
//					field will be filled with corresponding data
//
//				2. QUEUE_EMPYT
//					if status is READY there is no data for driving vif and frame field
//					will be NULL ( WARNING: potential null pointer if scheduler user do not
//					comply with the rules of scheduler usage)
//
//			-frame includes delays:
//
//				1. delay_addr
//					-this delay is created randomly in setted constraints( in user_configurations
//					for more info see user_configuratin_skeleton
//
//				2. delay_data
//					-this delay is created randomly in setted constraints( in user_configurations
//					for more info see user_configuratin_skeleton
//
//
//		3. task putResponseFromSlave(input axi_slave_response rsp)
//
//			-this methode is used to put recieved response from slave
//			-this inforamtion is used to define number of active bursts
//
//		4. task lastPackageSent(input bit[WID_WIDTH-1:0] sent_id)
//
//			-this methode is used to inform scheduler that last package of some burst is
//			sent
//			-this information is used to check if slave sent response before last package
//			is sent ( this can mean error )
//
//		5. task reset()
//
//			-this methode should be called whean reset is detected;
//
//
//REQUIREMENTS:
//
//		1. configuration
//			axi_write_conf configurations needs to be set brefore building scheduler in uvm_database in
// 			any scope and fiel name : "uvc_write_config"
//
//
//CONFIGURATIONS:
//
//		1. correct value
//
//			-for driving correct or incorrect data in user configuration ( see user_configuration_skeleton in
//			configurations ) you need to set corresponding option
//
//       	1. registerConfiguration("general", "correct_driving_vif", TRUE);
//
//				-this configuration will leave all fields in data correct and uvc will ignore other
//				registred option in data_correctnes scope ( see user_configurations_skeleton )
//
//			2. registerConfiguration("data_correctnes", "options", value);
//
//					example : registerConfiguration("data_correctnes", "awid_mode", 1);
//
//
// 				-options:
//					1. 	awid_mode 						value = __ [1 - 3]
//	 				2. 	awid_possibility_correct		value = __ [0 -  ]
// 					3. 	awid_possibility_incorrect 		value = __ [0 -  ]
//
//         		-mode:
//					 1.	correct 						value = 1
//					 2.	incorrect (default = 0)  		value = 2
//					 3. random correct vs. incorrect	value = 3
//
//
//			for next values are the same options and modes :
//
//				1. awid
//
//				2. awregion
//
//				3. awlen
//
//				4. awsize
//
//				5. awburst
//
//				6. awlock
//
//				7. awcache
//
//				8. awqos
//
//				9. wstrb
//
//
//		2. delays
//
//		-delay that is used in scheduler ( number of clocks  that must pass for currenct frame to be
//		ready for seanding ) and delays that scheduler generates ( addr_delay and data_delat ) can be configured
//		in user_configuration ( see user_configuration_skeleton )
//
//			1. retisterConfiguration("general","full_speed",[TRUE - FALSE])
//
//				-setting this to TRUE option in general scope will configure all delays to be 0
//				-if this option is setted to TRUE all below options will be ignored
//
//			2 delay_between_burst_packages
//
//				1. registerConfiguration("general", "delay_between_burst_packages", mode);
//
//				 	modes:
//						1. no delay  			mode = 1
//						2. costant delay 		mode = 2
//						3. random delay 		mode = 3
//
//				2.  registerConfiguration("general", "delay_between_packages_minimum",value);
//
//					-if delay mode is setted as random then minimal delay will be value setted
//					in this option
//
//				3. registerConfiguration("general", "delay_between_packages_maximum",value);
//
//					-if delay mode is setted as random then maximal delay will be value setted
//					in this option
//
//				4. registerConfiguration("general", "delay_between_packages_constant",value);
//
//					-if delay mode is setted as constatn delay mode then delay will be value
//					setted in this option
//
//				5. registerConfiguration("general", "delay_addr_package",[TRUE-FALSE]);
//
//					-if this is TRUE then delay_addr in oputput frame in getFrameForDrivingVif
//					methode will have random value in range[0 - 5] otherwise 0
//
//				6. registerConfiguration("general", "delay_data_package",[TRUE-FALSE]);
//
//					-if this is TRUE then delay_data in oputput frame in getFrameForDrivingVif
//					methode will have random value in range[0 - 5] otherwise 0
//
//
// ADITIONAL INFORMATION
//
//
//	LIFE OF BURST SCHEME
//																	?2
//																got rsp
//															 ------------------>
//															|					|
//  		 ?1  ----------------------------------------------------------------------------
// 			 ->	|    active     | waiting_to_send 	| wating_rsp 	| delete and put respose |
//  --------|	|---------------|------------------------------------------------------------
// |add new	|->	| inactive 		|	<-.					|	|					|
// 	--------|   |---------------|	  |-----------------	 ------------------>
// 			 ->	| duplicate ID 	|	<-'	slv_error > max	    response_latenes > max
// 				 ---------------	?3
//																	?2
//
// 		?1 scheduler will chose where to put new burst on two  conditions
//
//			1. is there already burst with same id
//			if this is true then burst will go -> duplicate ID otherwise
//			will procede to next condition
//
//			2. is number of active burst at the time smaller than burst-deepth
//			( this is only in AXI 3 supported ) burst will go -> active bursts
//			otherwise in inactive
//
//		?2 every burst can proceede to deletion from waiting response on two
//		conditions
//
//			1.if response is recieved
//				if resoponse is: SLVERR - scheduler will try one more time to
//								 OTHER - scheduler will detelete burst
//
//			2.if waiting for response is bigger than 10 000 clocks than
//			scheduler will delete burst
//
//		3? if slave sent SLVERR then if error counter is smaller then setted then
//		scheduler will reincarnate burst and send or in inactive or in duplicate
//		corespoing to current state. Otherwise if error counter of burst is bigger
//		than setted then scheduler will kill burst.
//
//	 _             _____ ___  __  __ _____
//	| |__  _   _  |_   _/ _ \|  \/  | ____|
//	| '_ \| | | |   | || | | | |\/| |  _|
//	| |_) | |_| |   | || |_| | |  | | |___
//	|_.__/ \__, |   |_| \___/|_|  |_|_____|
//  	   |___/
//
//
//-------------------------------------------------------------------------------------


typedef axi_master_write_scheduler_package2_0	package_queue[$];


class axi_master_write_scheduler2_0 extends uvm_component;
	static axi_master_write_scheduler2_0	scheduler_instance;
	axi_master_write_driver					top_driver;
	axi_write_conf							config_obj;
	axi_write_global_conf					global_config_obj;
	semaphore 								sem;
	int 									response_counter = 0;

	//queues for manageing bursts lives
	axi_master_write_scheduler_package2_0	active_queue[$];
	axi_master_write_scheduler_package2_0	inactive_queue[$];
	axi_master_write_scheduler_package2_0	duplicate_ID_queue[$];
	axi_master_write_scheduler_package2_0	waiting_for_RSP_queue[$];
	axi_master_write_scheduler_package2_0	waiting_to_send_all_queue[$];

	//main driver gets packages from here
	axi_single_frame 						next_frame_for_sending[$];

	//queues for manageing burst statuses
	bit[WID_WIDTH -1 : 0]					empty_queue_id_queue[$]; // when queue is empyt here are stored his ID-s
	bit[WID_WIDTH -1 : 0]					rsp_latenes_exipired_id_queue[$]; // if response did not come after some time
	bit[WID_WIDTH -1 : 0]					recieved_all_send_mssg_id_queue[$]; // when queue is deleted check for duplocates
	bit[WID_WIDTH -1 : 0]					check_for_Id_duplicates_id_queue[$];

	axi_slave_response						recieved_response[$]; // this are recieved responses
	axi_frame								add_burst_frame_queue[$]; // waiting to add to some burst
	//burst_options
	burst_deepth_mode_enum 					burst_deepth_mode = MODE_1;
	int										burst_deepth = 5;
	int 									burst_active = 0;

	`uvm_component_utils_begin(axi_master_write_scheduler2_0)
	 `uvm_field_int(burst_deepth, UVM_DEFAULT)
 `uvm_component_utils_end

// constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		sem = new(1);
	endfunction : new

//get singleton instance
	static function axi_master_write_scheduler2_0 getSchedulerInstance(input uvm_component parent);
		if(scheduler_instance == null)
			begin
//				$display("Creating Sceduler 2.0");
				scheduler_instance = new("MasterWriteScheduler", parent);
			end
		return scheduler_instance;
	endfunction

//build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_write_conf)::get(this, "", "uvc_write_config", config_obj))
		 `uvm_fatal("NO UVC_CONFIG",{"uvc_write config must be set for ",get_full_name(),".uvc_write_config"})
		 configureScheduler();
	endfunction : build_phase

	extern function void setTopDriverInstance(input axi_master_write_driver top_driver_instance);

// MAIN
	extern task main(input int clocks);

//	API
	extern task addBurst(axi_frame frame);
	extern task getFrameForDrivingVif(output axi_mssg mssg);
	extern task putResponseFromSlave(input axi_slave_response rsp);
	extern task lastPackageSent(input bit[WID_WIDTH-1:0] sent_id);
	extern task reset();


// LOCAL METHODES
	extern local task checkUniqueID(input bit[WID_WIDTH-1 : 0] id_to_check, package_queue queue_to_check, output true_false_enum existing_id);
	extern local task checkForDone();
	extern local task searchReadyFrame();
	extern local task delayCalculator();
	extern local task responseLatnesCalculator();
	extern local task manageBurstStatus();
	extern local task addBurstPackage(input axi_frame frame);
	extern local function void configureScheduler();
	extern local task addBurstGeneratedPackage(input axi_master_write_scheduler_package2_0 new_burst);

	extern local function true_false_enum findeIndexFromID(input bit[WID_WIDTH-1 : 0] id_to_check, package_queue queue_to_check, ref int index);

// PUT RESPONSE METHODES
	extern local task gotOkayResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
	extern local task gotExOkayResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
	extern local task gotSlaveErrorResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
	extern local task gotDecErrorResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);

// TESTING
	extern local function void PrintActive();
endclass




task axi_master_write_scheduler2_0::main(input int clocks);
   repeat(clocks)
	   begin
		   this.searchReadyFrame();
		   this.delayCalculator();
		   this.responseLatnesCalculator();
		   this.manageBurstStatus();
		   this.checkForDone();
	   end
endtask

task axi_master_write_scheduler2_0::addBurst(input axi_frame frame);
	sem.get(1);
    add_burst_frame_queue.push_back(frame);
	sem.put(1);
endtask




task axi_master_write_scheduler2_0::addBurstPackage(input axi_frame frame);

    axi_master_write_scheduler_package2_0 	new_burst;
	new_burst = new("SchedulerPackage",config_obj);

//	$display("ADDING NEW BURST");
	new_burst.addBurst(frame);
	addBurstGeneratedPackage(new_burst);

endtask

task axi_master_write_scheduler2_0::addBurstGeneratedPackage(input axi_master_write_scheduler_package2_0 new_burst);
	true_false_enum  						unique_id1;
	true_false_enum  						unique_id2;


	checkUniqueID(new_burst.getID(), active_queue,unique_id1);
	checkUniqueID(new_burst.getID(), inactive_queue, unique_id2);

	// if this is duplicate ID then store it to corresponding queue
	if(unique_id1 == TRUE || unique_id2 == TRUE)
		begin
			duplicate_ID_queue.push_back(new_burst);
			return;
		end

	if(burst_active < burst_deepth)
		begin
			burst_active++;
		// if active queue is empyt
			if(active_queue.size() == 0)
				begin
					new_burst.setLock_state(QUEUE_UNLOCKED);
				end
			else if(active_queue[active_queue.size()-1].getFirst_status == FIRST_SENT)
					begin
						new_burst.setLock_state(QUEUE_UNLOCKED);
					end
			else
					begin
						new_burst.setLock_state(QUEUE_LOCKED);
					end
			active_queue.push_back(new_burst);
		end
	else
		begin
			inactive_queue.push_back(new_burst);
		end
endtask


task axi_master_write_scheduler2_0::checkUniqueID(input bit[WID_WIDTH-1:0] id_to_check, input package_queue queue_to_check, output true_false_enum existing_id);
    int i;
    foreach(queue_to_check[i])
	    begin
		    if(queue_to_check[i].getID == id_to_check)
			    begin
			    	existing_id = TRUE;

				    return;
			    end
	    end
	 existing_id = FALSE;
	 return;
endtask


task axi_master_write_scheduler2_0::searchReadyFrame();
	axi_mssg rsp_mssg;
	int id;
	int i;
	rsp_mssg = new();
	foreach(active_queue[i])
		begin
		 	active_queue[i].getNextSingleFrame(rsp_mssg);
			if(rsp_mssg.state == READY)
				begin
//					$display("Frmame");
					sem.get(1);
						next_frame_for_sending.push_back(rsp_mssg.frame);
					sem.put(1);

					if(active_queue[i+1] != null)
						begin
							active_queue[i+1].setLock_state(QUEUE_UNLOCKED);
						end
				end
			else if(rsp_mssg.state == QUEUE_EMPTY)
				begin
					int index;
					id = rsp_mssg.frame.id;
					void'(findeIndexFromID(id, active_queue, index));
					empty_queue_id_queue.push_back(id);
				if(active_queue[index].single_frame_queue.size() != 0)
					begin
						`uvm_fatal("Fatal","-1")
					end
				end
		end
endtask

task axi_master_write_scheduler2_0::delayCalculator();
	int i;
    foreach(active_queue[i])
	    begin
		    active_queue[i].decrementDelay();
	    end
endtask

task axi_master_write_scheduler2_0::lastPackageSent(input bit[WID_WIDTH-1:0] sent_id);
	sem.get(1);
	recieved_all_send_mssg_id_queue.push_back(sent_id);
	sem.put(1);
endtask


task axi_master_write_scheduler2_0::checkForDone();
//	$display("CHECK FOR DONE : active_queue: %0d, inactive_queue: %0d, waiting_to_send_all_queue: %0d,\
//				waiting_for_RSP_queue: %0d,duplicate_ID_queue: %0d",active_queue.size(),inactive_queue.size(),
//				waiting_to_send_all_queue.size(),  waiting_for_RSP_queue.size(), duplicate_ID_queue.size());

    if(active_queue.size() == 0 &&
	    inactive_queue.size() == 0 &&
	    waiting_to_send_all_queue.size() == 0 &&
	    waiting_for_RSP_queue.size() == 0 &&
	    duplicate_ID_queue.size() == 0)
	    begin

//		    top_driver.putResponseToSequencer();

	    end

endtask

task axi_master_write_scheduler2_0::responseLatnesCalculator();
	int i;
  	foreach(waiting_for_RSP_queue[i])
	  	begin
		  	if(waiting_for_RSP_queue[i].decrementResponseLatenesCounter() == TRUE)
			  	begin
			  		rsp_latenes_exipired_id_queue.push_back(waiting_for_RSP_queue[i].getID());
			  	end
	  	end
endtask

// ================================== MANAGE BURST LIFE =====================================
//
// LIFE OF BUST SCHEME
//
//  			 ----------------------------------------------------------------------------
// 				|    active     | waiting_to_send 	| wating_rsp 	| delete and put respose |
//   -----------|---------------|------------------------------------------------------------
// 	|add new	| inactive 		|
// 	 -----------|---------------|
// 				| duplicate ID 	|
// 				 ---------------
//
task axi_master_write_scheduler2_0::manageBurstStatus();
	int 					index;
	bit[WID_WIDTH - 1 : 0]	id;


//  			 ----------------------------------------------------------------------------
// 			 	|    	      	| 					| 			 	|						 |
//   -----------|---------------|------------------------------------------------------------
// 	|add new	| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//
//	sem.get(1);
	while(add_burst_frame_queue.size() != 0)
		begin
			sem.get(1);
			addBurstPackage(add_burst_frame_queue.pop_front());
			sem.put(1);
		end
//	sem.put(1);


//  ACTIVE QUEUE IS EMPYT ->
//
// 				 ---------------------------------------------------------------------------
// 			 	|    current    ->waiting to send all| 			 	|						|
//   -----------|---------------|-----------------------------------------------------------
// 	| done 		| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//
	while(empty_queue_id_queue.size() != 0)
		begin
			id = empty_queue_id_queue.pop_front();
//			$display("Recieved empty Queue item ID: %0h",id );
			if(findeIndexFromID(id,active_queue, index) == FALSE)
				begin
					`uvm_fatal("Fatal","0")
				end
			if(active_queue[index].single_frame_queue.size() != 0)
				begin
					`uvm_fatal("Fatal","1")
				end
			waiting_to_send_all_queue.push_back(active_queue[index]);
			active_queue.delete(index);
			// if burst mode2 =  dont wait to recieve rsp just add new queue
			if(burst_deepth_mode == MODE_2)
				begin
				//	burst_active--;
				end
		end

//GOT ALL_SENT_MSSG -> WAIT FOR RSP
//
//               ---------------------------------------------------------------------------
//   			|    done       |waiting to send all->waitin_to_rsp|						|
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//

	while(recieved_all_send_mssg_id_queue.size() !=0)
		begin
			sem.get(1);
			id = recieved_all_send_mssg_id_queue.pop_front();
			sem.put(1);
//			$display("Recieved Sent Last item ID: %0d",id );
			if(findeIndexFromID(id,waiting_to_send_all_queue, index) == FALSE)
				begin
					`uvm_fatal("MasterWriteScheduler","waiting to send all packages ")
				end
			waiting_for_RSP_queue.push_back(waiting_to_send_all_queue[index]);
			waiting_to_send_all_queue.delete(index);
		end


// GOT RPS -> DELET QUEUE ( check duplicate and decrement active burst )
//																got rsp
//															 ------------------>
//															|					|
//               ---------------------------------------------------------------------------
//   			|    done       |    done 				|waitin_to_rsp -> delete			|
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|
// 	 -----------|---------------|
// 				| 			 	|
// 				 ---------------
//
	while(recieved_response.size() != 0)
		begin
			int 				where_is_found;
			true_false_enum		found;

			response_enum		rsp_info;
			axi_slave_response 	rsp;
			rsp = recieved_response.pop_front();
			id = rsp.getID();
			rsp_info = rsp.getRsp();

//			$display("MAIN RECIEVED RSP NO: %0d, ID %h", response_counter, id);

			if( findeIndexFromID(id, waiting_for_RSP_queue, index) == TRUE)
				begin

					found = TRUE;
					where_is_found = 1;
				end
			else if( findeIndexFromID(id, waiting_to_send_all_queue, index) == TRUE)
				begin
					//`uvm_fatal("oD ", "2")
					found = TRUE;
					where_is_found = 2;
				end

			else if(findeIndexFromID(id, active_queue, index) == TRUE)
				begin
					`uvm_fatal("oD ", "3")
					found = TRUE;
					where_is_found = 3;
				end
			if(found == TRUE)
				begin
//					$display(" ");
//					$display("MAIN RECIEVED RSP NO: %0d, ID %h", response_counter, id);
//					$display(" ");
					response_counter++;
					// id mode = 1 :
					if(burst_deepth_mode == MODE_1)
						begin
							burst_active--;
						end

					//push ID to check for duplicates

					check_for_Id_duplicates_id_queue.push_back(id);


					`uvm_info(get_name(),$sformatf("Recieved Valid ID Response: %h, option: %0d, response: %h", id, where_is_found, rsp_info ), UVM_INFO)


//					$display("CHECK FOR DONE : active_queue: %0d, inactive_queue: %0d, waiting_to_send_all_queue: %0d,\
//					waiting_for_RSP_queue: %0d,duplicate_ID_queue: %0d",active_queue.size(),inactive_queue.size(),
//					waiting_to_send_all_queue.size(),  waiting_for_RSP_queue.size(), duplicate_ID_queue.size());


					case(rsp_info)
						OKAY:
						begin
//							$display("OKAY");
							gotOkayResponse(id, index, where_is_found);
						end

						EXOKAY:
						begin
//							$display("EXOKAY");
							gotExOkayResponse(id, index, where_is_found);
						end

						SLVERR:
						begin
//							$display("SLVERR");
							gotSlaveErrorResponse(id, index, where_is_found);
						end

						DECERR:
						begin
//							$display("DECERR");
							gotDecErrorResponse(id, index, where_is_found);
						end

					endcase
				end
			else
				begin
					$display("MasterWriteScheduler [ERROR] Error in recieved response from NON EXISTING burst id: %h",id);
					//`uvm_warning("MasterWriteScheduler [ERROR]: ", $sformat("Error in recieved response from NON EXISTING burst id: %h",id))
				end
		end


// DID NOT GET RSP IN RESPONSE LATENES TIME -> DELET QUEUE ( check duplicate and decrement active burst )
//
//
//
//               ---------------------------------------------------------------------------
//   			|    done       |   	 done 				|waitin_to_rsp -> delete		|
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| 		 		|							|					|
// 	 -----------|---------------|							 ------------------>
// 				| 			 	|							 response_latenes = 0
// 				 ---------------
//

		while(rsp_latenes_exipired_id_queue.size() != 0)
			begin
				id = rsp_latenes_exipired_id_queue.pop_front();

				burst_active--;
				check_for_Id_duplicates_id_queue.push_back(id);
				top_driver.putResponseToSequencer(id, SLVERR);
				void'(findeIndexFromID(id,waiting_for_RSP_queue, index));
				waiting_for_RSP_queue.delete(index);
				//`uvm_warning("MasterWriteScheduler [ERROR]: ", $sformat(" did not recieved response for quite a longe time for burst id: %h",id))
			end


//  DUPLICATE ID CHECK
//
//
//
//               ---------------------------------------------------------------------------
//   			|    	        |           	  			|       			|   	    |
//   -----------|---------------|-----------------------------------------------------------
// 	|  done 	| inactive 		|
// 	 -----------|--		|	 ---|
// 				| duplicate ID 	|
// 				 ---------------
//

		if(duplicate_ID_queue.size() != 0)
			begin
				while(check_for_Id_duplicates_id_queue.size() != 0)
					begin
						id = check_for_Id_duplicates_id_queue.pop_front();
						if(this.findeIndexFromID(id, duplicate_ID_queue, index) == TRUE)
							begin
								// if there is duplicate of this id translate it to inactive queue
								inactive_queue.push_back(duplicate_ID_queue[index]);
								duplicate_ID_queue.delete(index);
							end

					end
			end
		else
			begin
				check_for_Id_duplicates_id_queue.delete();
			end

//  ADD TO ACTIVE IF THERE IS PLACE IN ACTIVE SPOT
//
//
//
//               ---------------------------------------------------------------------------
//   			|    active     |          	  				|       			|		    |
//   -----------|----   |  -----|-----------------------------------------------------------
// 	|  done 	| 	inactive	|
// 	 -----------|---------------|
// 				| 	 	 	 	|
// 				 ---------------
//
		while(burst_active < burst_deepth && inactive_queue.size() > 0)
			begin
				axi_master_write_scheduler_package2_0 burst;
				burst = inactive_queue.pop_front();

				if(active_queue.size() == 0)
					begin
						burst.setLock_state(QUEUE_UNLOCKED);
					end
				else if(active_queue[active_queue.size()-1].getFirst_status == FIRST_SENT)
					begin
						burst.setLock_state(QUEUE_UNLOCKED);
					end
				else
					begin
						burst.setLock_state(QUEUE_LOCKED);
					end

					active_queue.push_back(burst);

					burst_active++;

			end

endtask
// ================================== END BURST MAnAGMENT =============================================


function true_false_enum axi_master_write_scheduler2_0::findeIndexFromID(input bit[WID_WIDTH-1:0] id_to_check, input package_queue queue_to_check, ref int index);
   int i;

//	$display("finde index");
//	PrintActive();
	foreach(queue_to_check[i])
		begin
			if(queue_to_check[i].getID() == id_to_check)
				begin
//					$display("found index = %0d, searching id: %h", i, id_to_check);
					index = i;
					return TRUE;
				end
		end
	index = -1;
	return FALSE;
endfunction


// ==================================== MANAGE RESPONSE ============================================

task axi_master_write_scheduler2_0::gotOkayResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);
//   	rsp_queue.delete(index);
//	top_driver.putResponseToSequencer(rsp_id);

	case(where_is_burst_found)
		1:
		begin
			top_driver.putResponseToSequencer(waiting_for_RSP_queue[index].getID(),OKAY);
			waiting_for_RSP_queue.delete(index);
		end

		2:
		begin
			top_driver.putResponseToSequencer(waiting_to_send_all_queue[index].getID(),SLVERR);
			waiting_to_send_all_queue.delete(index);
		end

		3:
		begin
			top_driver.putResponseToSequencer(active_queue[index].getID(),SLVERR);
			active_queue.delete(index);
			`uvm_warning("AxiMasterWriteScheduler [UW]","Recieved  OKAY or EXOKAYresponse from slave and burst did not sent last")
		end
	endcase

endtask

task axi_master_write_scheduler2_0::gotExOkayResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index, input int where_is_burst_found);

	case(where_is_burst_found)
		1:
		begin
			top_driver.putResponseToSequencer(waiting_for_RSP_queue[index].getID(), EXOKAY);
			waiting_for_RSP_queue.delete(index);
		end

		2:
		begin
			top_driver.putResponseToSequencer(waiting_to_send_all_queue[index].getID(), SLVERR);
			waiting_to_send_all_queue.delete(index);
		end

		3:
		begin
			top_driver.putResponseToSequencer(active_queue[index].getID(), SLVERR);
			active_queue.delete(index);
			`uvm_warning("AxiMasterWriteScheduler [UW]","Recieved  OKAY or EXOKAYresponse from slave and burst did not sent last")
		end
	endcase

//	top_driver.putResponseToSequencer(rsp_id);
endtask

task axi_master_write_scheduler2_0::gotDecErrorResponse(input bit[WID_WIDTH-1 : 0] rsp_id, int index,  input int where_is_burst_found);
	case(where_is_burst_found)
		1:
		begin
			top_driver.putResponseToSequencer(waiting_for_RSP_queue[index].getID(),DECERR);
			waiting_for_RSP_queue.delete(index);
		end

		2:
		begin
			top_driver.putResponseToSequencer(waiting_to_send_all_queue[index].getID(),SLVERR);
			waiting_to_send_all_queue.delete(index);
		end

		3:
		begin
			top_driver.putResponseToSequencer(active_queue[index].getID(),SLVERR);
			active_queue.delete(index);
		end
	endcase


//	top_driver.putResponseToSequencer(rsp_id);
endtask

task axi_master_write_scheduler2_0::gotSlaveErrorResponse(input bit[WID_WIDTH-1:0] rsp_id, input int index, input int where_is_burst_found);
	case(where_is_burst_found)
		1:
		begin
			if(waiting_for_RSP_queue[index].decrementError_counter() == FALSE)
				begin
					waiting_for_RSP_queue[index].reincarnateBurstData();
					addBurstGeneratedPackage(waiting_for_RSP_queue[index]);
//					addBurst(waiting_for_RSP_queue[index].getFrameCopy());
			 		waiting_for_RSP_queue.delete(index);
				end
			else
				begin
					top_driver.putResponseToSequencer(waiting_for_RSP_queue[index].getID(), SLVERR);
					waiting_for_RSP_queue.delete(index);
				end
		end

		2:
		begin
			if(waiting_to_send_all_queue[index].decrementError_counter() == FALSE)
				begin
					waiting_to_send_all_queue[index].reincarnateBurstData();
					addBurstGeneratedPackage(waiting_to_send_all_queue[index]);
//					addBurst(waiting_to_send_all_queue[index].getFrameCopy());
			 		waiting_to_send_all_queue.delete(index);
				end
			else
				begin
					top_driver.putResponseToSequencer(waiting_to_send_all_queue[index].getID(),SLVERR);
					waiting_to_send_all_queue.delete(index);
				end
		end

		3:
		begin
			if(active_queue[index].decrementError_counter() == FALSE)
				begin
					active_queue[index].reincarnateBurstData();
					addBurstGeneratedPackage(active_queue[index]);
//					addBurst(active_queue[index].getFrameCopy());
			 		active_queue.delete(index);
				end
			else
				begin
					top_driver.putResponseToSequencer(active_queue[index].getID(),SLVERR);
					active_queue.delete(index);
				end
		end
	endcase


//	if(rsp_queue[index].decrementError_counter == FALSE)
//		begin
//			addBurst(rsp_queue[index].getFrameCopy());
//			 rsp_queue.delete(index);
//		end
//	else
//		begin
//			 rsp_queue.delete(index);
//		end
//	top_driver.putResponseToSequencer(rsp_id);
endtask


function void axi_master_write_scheduler2_0::configureScheduler();
	global_config_obj = config_obj.getGlobal_config_object();
    this.burst_deepth = global_config_obj.getMaster_write_deepth();
endfunction


// ==================================== INSTANCES ====================================================

function void axi_master_write_scheduler2_0::setTopDriverInstance(input axi_master_write_driver top_driver_instance);
    this.top_driver = top_driver_instance;
endfunction

// ================================ API IMPLEMENTATION ===============================================


task axi_master_write_scheduler2_0::putResponseFromSlave(input axi_slave_response rsp);
  sem.get(1);
	recieved_response.push_back(rsp);
	sem.put(1);
endtask

task axi_master_write_scheduler2_0::getFrameForDrivingVif(output axi_mssg mssg);
	axi_mssg send;
	int tmp;
	send = new();

	sem.get(1);
	tmp = next_frame_for_sending.size();
	sem.put(1);

	if(tmp > 0)
		begin
			sem.get(1);
			send.frame  = next_frame_for_sending.pop_back();
	    	send.state = READY;
			sem.put(1);
		end
	else
		begin
			sem.get(1);
			send.state = QUEUE_EMPTY;
			send.frame = null;
		    sem.put(1);
		end

		mssg = send;

endtask

task axi_master_write_scheduler2_0::reset();
	`uvm_info(get_name(),"Recieved Reset signal deleting everything", UVM_MEDIUM);
   	active_queue.delete();
	inactive_queue.delete();
	duplicate_ID_queue.delete();
	waiting_for_RSP_queue.delete();
	waiting_to_send_all_queue.delete();
	next_frame_for_sending.delete();
	empty_queue_id_queue.delete();
	rsp_latenes_exipired_id_queue.delete();
	recieved_all_send_mssg_id_queue.delete();
	check_for_Id_duplicates_id_queue.delete();
	recieved_response.delete();
	add_burst_frame_queue.delete();
endtask

function void axi_master_write_scheduler2_0::PrintActive();
    int i;
    foreach(active_queue[i])
	    begin
		    $display("inedx : %0d, ID: %h, items: %0d ",i, active_queue[i].getID(), active_queue[i].single_frame_queue.size() );
	    end

endfunction

`endif
