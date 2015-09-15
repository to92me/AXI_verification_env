// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_master_read_response.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : response calculation
*
* Classes :	axi_master_read_response
**/
// -----------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_RESPONSE_SV
`define AXI_MASTER_READ_RESPONSE_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_response
//
//------------------------------------------------------------------------------
/**
* Description : used by master for interpreting slave responses
*
* Functions :	1. new (string name = "axi_master_read_response",
*						uvm_component parent = null)
*				2. void build_phase(uvm_phase phase)
*
* Tasks :	1. check_response(axi_read_single_frame one_frame,
*							ref axi_read_burst_frame matching_burst)
*			2. new_burst(axi_read_burst_frame one_burst)
*			3. send_burst(axi_read_burst_frame one_burst)
*			4. get_num_of_bursts(output int num)
*			5. reset(ref axi_read_burst_frame burst)
*
* Usage :	1. when a new request is sent from the sequencer to the driver, the
*				"new_burst" task is called which then holds the original requests
*				in a queue
*			2. before the master driver sends a burst to the slave it must check
*				if the master pipe is full - the "get_num_of_bursts" return the
*				current number of bursts in the pipe
*			3. after the driver sends a burst to the slave the "send_burst" task
*				is called
*			4. when a master recieves a frame on the data channel (the slave
*				response), the "check_response" task is called which checks for
*				errors or burst completeness
*			5. if there is a reset, the "reset" task is called which return a
*				request burst from the seq. with the status field set to
*				UVM_TLM_INCOMPLETE_RESPONSE, which the driver then returns to the
*				seq.
**/
// -----------------------------------------------------------------------------
class axi_master_read_response extends uvm_component;

	// queue that holds all the sent bursts that have not been completed
	axi_read_whole_burst sent_bursts[$];
	// queue that holds original bursts sent from seq to driver
	// needed for sending responses back to seq.
	axi_read_burst_frame response_bursts[$];

	semaphore sem;

	// control bit to select whether early termination of bursts is supported
	// 1 - yes, 0 - no
	bit terminate_enable = 1;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_master_read_response)
    	`uvm_field_int(terminate_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name = "axi_master_read_response", uvm_component parent = null);
		super.new(name, parent);
		sem = new(1);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern virtual task check_response(axi_read_single_frame one_frame, ref axi_read_burst_frame matching_burst);
	extern virtual task new_burst(axi_read_burst_frame one_burst);
	extern virtual task send_burst(axi_read_burst_frame one_burst);
	extern virtual task get_num_of_bursts(output int num);
	extern virtual task reset(ref axi_read_burst_frame burst);

endclass : axi_master_read_response

//------------------------------------------------------------------------------
/**
* Task : check_response
* Purpose : for each frame that the slave sends to the master,
*			check if it has an error or if it completes the burst
* Inputs : one_frame - collected response from slave
* Outputs :
* Ref : matching burst - original burst sent from sequencer to driver
*			(if null - burst not complete, driver should not send response to sequencer)
**/
//------------------------------------------------------------------------------
task axi_master_read_response::check_response(axi_read_single_frame one_frame, ref axi_read_burst_frame matching_burst);
	int i, flag = 0;
	axi_read_single_addr tmp_frame;
	tmp_frame = axi_read_single_addr::type_id::create("tmp_frame");
	tmp_frame.copy(one_frame);

	sem.get(1);
	// find the burst with the matching id
	for(i = 0; i<sent_bursts.size(); i++) begin
		if(sent_bursts[i].id == one_frame.id) begin
			// push frame in the correct burst
			sent_bursts[i].single_frames.push_back(tmp_frame);

			// check for SLVERR or DECERR, check OKAY resp for EXCLUSIVE request
			if ((one_frame.resp == SLVERR) || (one_frame.resp == DECERR) || ((sent_bursts[i].lock == EXCLUSIVE) && (one_frame.resp == OKAY))) begin
				if(terminate_enable) begin
					matching_burst = response_bursts[i];
					matching_burst.valid = FRAME_NOT_VALID;
				end
				else begin
					sent_bursts[i].valid = FRAME_NOT_VALID;
					response_bursts[i].valid = FRAME_NOT_VALID;
				end
				flag = 1;
				break;
			end

			break;	// i holds the value for the burst with matching id
		end
	end

	// if there is a burst with a matching id
	if(i < sent_bursts.size()) begin
		if (terminate_enable && flag) begin
			sent_bursts.delete(i);
			response_bursts.delete(i);
			sem.put(1);
			return;
		end

		// check if burst is complete - recieved requested number of frames
		if((sent_bursts[i].len+1) == sent_bursts[i].single_frames.size()) begin
			matching_burst = response_bursts[i];
			sent_bursts.delete(i);
			response_bursts.delete(i);
			sem.put(1);
			return;
		end
	end
	sem.put(1);

	matching_burst = null;	// no errors

endtask : check_response

//------------------------------------------------------------------------------
/**
* Task : send_burst
* Purpose : when the master sends a new burst frame, put it in the queue
* Inputs : one_burst - burst request sent by master to slave
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
task axi_master_read_response::send_burst(axi_read_burst_frame one_burst);

	axi_read_whole_burst whole_burst;

	whole_burst = axi_read_whole_burst::type_id::create("whole_burst");
	whole_burst.copy(one_burst);

	sem.get(1);
	sent_bursts.push_back(whole_burst);	// copy (with single frames queue)
	sem.put(1);

endtask : send_burst

//------------------------------------------------------------------------------
/**
* Task : new_burst
* Purpose : when the master gets a new burst from the seq.
* Inputs : one_burst - burst from seq.
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
task axi_master_read_response::new_burst(axi_read_burst_frame one_burst);

	response_bursts.push_back(one_burst);

endtask : new_burst

//------------------------------------------------------------------------------
/**
* Task : get_num_of_bursts
* Purpose : number of burst currently waiting for responses (used for master
*			pipeline)
* Inputs :
* Outputs :	num - number of burst currently waiting for responses
* Ref :
**/
//------------------------------------------------------------------------------
task axi_master_read_response::get_num_of_bursts(output int num);
	
	sem.get(1);
	num = sent_bursts.size();
	sem.put(1);

endtask : get_num_of_bursts

//------------------------------------------------------------------------------
/**
* Task : reset
* Purpose : empty all queues
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
task axi_master_read_response::reset(ref axi_read_burst_frame burst);

	`uvm_info(get_type_name(), $sformatf("Reset"), UVM_LOW);

	sem.get(1);
		// return one burst to informe the seq. of the reset
		if(response_bursts.size()) begin
			burst = response_bursts.pop_front();
			burst.status = UVM_TLM_INCOMPLETE_RESPONSE;
		end

		sent_bursts.delete();
		response_bursts.delete();
	sem.put(1);

endtask : reset

`endif