/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by andrea on Aug 17, 2015
	* uvc_company = axi_master_read, uvc_name = response
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_response
//
//------------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_RESPONSE_SV
`define AXI_MASTER_READ_RESPONSE_SV

class axi_master_read_response extends uvm_component;

	// queue that holds all the sent bursts that have not been completed
	axi_read_burst_frame sent_bursts[$];

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

endclass : axi_master_read_response

// for each frame that the slave sends to the master, check if it has an error or if it completes the burst
task axi_master_read_response::check_response(axi_read_single_frame one_frame, ref axi_read_burst_frame matching_burst);
	int i, flag = 0;

	// if a frame returns with a bad resp, return the matching burst (same id)
	if (one_frame.resp == SLVERR || one_frame.resp == DECERR) begin
		sem.get(1);
		for (i=0; i<sent_bursts.size(); i++) begin
			if (sent_bursts[i].id == one_frame.id) begin
				if(terminate_enable) begin
					matching_burst = sent_bursts[i];
					matching_burst.valid = FRAME_NOT_VALID;
				end
				else
					sent_bursts[i].valid = FRAME_NOT_VALID;
				break;
			end
		end
		if(terminate_enable)
			sent_bursts.delete(i);
		sem.put(1);
		if(terminate_enable)
			return;
	end

	// check OKAY resp for EXCLUSIVE request
	sem.get(1);
	for (i=0; i<sent_bursts.size(); i++) begin
		if (sent_bursts[i].id == one_frame.id)
			if (sent_bursts[i].lock == EXCLUSIVE && one_frame.resp == OKAY) begin
				if(terminate_enable) begin
					matching_burst = sent_bursts[i];
					matching_burst.valid = FRAME_NOT_VALID;
				end
				else
					sent_bursts[i].valid = FRAME_NOT_VALID;
				flag = 1;
				break;
			end
	end
	if (flag) begin
		if(terminate_enable) begin
			sent_bursts.delete(i);
			sem.put(1);
			return;
		end
	end
	sem.put(1);

	// check if a burst is complete - recieved frame with rlast set
	if (one_frame.last) begin

		sem.get(1);
		for (i=0; i<sent_bursts.size(); i++) begin
			if (sent_bursts[i].id == one_frame.id) begin
				matching_burst = sent_bursts[i];
				if(terminate_enable)
					matching_burst.valid = FRAME_VALID;
				else matching_burst.valid = sent_bursts[i].valid;
				// to get correct error response
				flag = 1;
				break;
			end
		end
		if(flag) begin
			sent_bursts.delete(i);
			sem.put(1);
			return;
		end
		sem.put(1);
	end

	matching_burst = null;	// no errors
endtask : check_response

// when the master sends a new burst frame, put it in the queue
task axi_master_read_response::new_burst(axi_read_burst_frame one_burst);

	sem.get(1);
	sent_bursts.push_back(one_burst);
	sem.put(1);

endtask : new_burst

`endif