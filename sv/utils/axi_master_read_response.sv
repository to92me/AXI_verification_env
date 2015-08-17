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

	axi_read_burst_frame sent_bursts[$];

	semaphore sem;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_master_read_response)

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


task axi_master_read_response::check_response(axi_read_single_frame one_frame, ref axi_read_burst_frame matching_burst);

	int i, flag = 0;

	// if a frame returns with a bad resp, return the matching burst (same id)
	if (one_frame.resp == SLVERR || one_frame.resp == DECERR) begin
		sem.get(1);
		for (i=0; i<sent_bursts.size(); i++) begin
			if (sent_bursts[i].id == one_frame.id)
				matching_burst = sent_bursts[i];
				matching_burst.valid = FRAME_NOT_VALID;
			break;
		end
		sent_bursts.delete(i);
		sem.put(1);
		return;
	end

	// check OKAY resp for EXCLUSIVE request
	sem.get(1);
	for (i=0; i<sent_bursts.size(); i++) begin
		if (sent_bursts[i].id == one_frame.id)
			if (sent_bursts[i].lock == EXCLUSIVE && one_frame.resp == OKAY) begin
				matching_burst = sent_bursts[i];
				matching_burst.valid = FRAME_NOT_VALID;
				flag = 1;
			end
			break;
	end
	if (flag) begin
		sent_bursts.delete(i);
		sem.put(1);
		return;
	end
	sem.put(1);

	// check if a burst is complete - recieved frame with rlast set
	if (one_frame.last == one_frame.last_mode) begin
		sem.get(1);
		for (i=0; i<sent_bursts.size(); i++) begin
			if (sent_bursts[i].id == one_frame.id)
				matching_burst = sent_bursts[i];
				matching_burst.valid = FRAME_VALID;
			break;
		end
		sent_bursts.delete(i);
		sem.put(1);
		return;
	end

	matching_burst = null;	// no errors
endtask : check_response

task axi_master_read_response::new_burst(axi_read_burst_frame one_burst);

	sem.get(1);
	sent_bursts.push_back(one_burst);
	sem.put(1);

endtask : new_burst

`endif