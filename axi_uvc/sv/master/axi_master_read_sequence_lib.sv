// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_master_read_sequence_lib.sv
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
* Description : sequences for master sequencer
*
* Classes :	1. axi_master_read_base_seq
*			2. axi_master_read_multiple_addr
*			3. axi_master_read_no_err_count
*			4. axi_master_read_dut_counter_seq
**/
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_base_seq
//
//------------------------------------------------------------------------------
/**
* Description : raises/drops objections in the pre/post_body so that root
*				sequences raise objections but subsequences do not
*
* Functions :	1. new(string name="axi_master_read_base_seq")
*
* Tasks :	1. pre_body()
*			2. post_body()
**/
// -----------------------------------------------------------------------------
class axi_master_read_base_seq extends uvm_sequence #(axi_read_whole_burst);

	`uvm_object_utils(axi_master_read_base_seq)
	`uvm_declare_p_sequencer(axi_master_read_sequencer)

	// new - constructor
	function new(string name="axi_master_read_base_seq");
		super.new(name);
	endfunction

	// Raise in pre_body so the objection is only raised for root sequences.
	// There is no need to raise for sub-sequences since the root sequence
	// will encapsulate the sub-sequence.
	virtual task pre_body();
		if (starting_phase!=null) begin
			starting_phase.raise_objection(this);
			//uvm_test_done.set_drain_time(this, 200ns);
		end
	endtask

	// Drop the objection in the post_body so the objection is removed when
	// the root sequence is complete.
	virtual task post_body();
		if (starting_phase!=null) begin
			starting_phase.drop_objection(this);
		end
	endtask

endclass : axi_master_read_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_master_read_multiple_addr
//
//------------------------------------------------------------------------------
/**
* Description : sends multiple requests to driver, gets responses and for
*				responses that had an error, sends that request again
*
* Functions :	1. new(string name="axi_master_read_multiple_addr")
*				2. void response_handler(uvm_sequence_item response)
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class axi_master_read_multiple_addr extends axi_master_read_base_seq;

	`uvm_object_utils(axi_master_read_multiple_addr)

	int count = 0;
	int num_of_err = 0;
	axi_read_whole_burst error_bursts[$];	// a queue for holding bursts that returned an error

	rand bit [ADDR_WIDTH-1 : 0] address[$];	// slave addresses

	// new - constructor
	function new(string name="axi_master_read_multiple_addr");
		super.new(name);
	endfunction

	virtual task body();

		use_response_handler(1);

		count = address.size();	// number of bursts to be sent

		for(int i = 0; i < address.size(); i++) begin
			if (count)	// if there was a reset, count will be set to 0
				`uvm_do_with(req, {req.addr == address[i];})
			else
				break;
		end

		wait(!count);	// wait for all responses before finishing simulation

		// if there was an error, send those frames again
		num_of_err = error_bursts.size();
		count = num_of_err;
		while (num_of_err--) begin
			req = error_bursts.pop_front();
			// send it again, no randomization
			start_item(req);
			finish_item(req);
			// if there is an error once, the burst will be sent again
			// but if there is an error again, it will not be sent again
		end

		wait(!count);

	endtask

	extern virtual function void response_handler(uvm_sequence_item response);

endclass : axi_master_read_multiple_addr

//------------------------------------------------------------------------------
/**
* Function : response_handler
* Purpose : called by the sequencer for each response that arrives for this
*			sequence; checks if there was an error and decrement the number
*			of requests waiting for responses
* Parameters :	response - uvm seq. item that the driver put
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_multiple_addr::response_handler(uvm_sequence_item response);

		if(!($cast(rsp, response)))
			`uvm_error("CASTFAIL", "The recieved response item is not a burst frame");

		count--;	// keep track of number of responses

		// if there was an error put the burst in the error queue so it will be sent agian
		if (rsp.valid == FRAME_NOT_VALID) begin
			rsp.single_frames.delete();	// delete the error frames
			error_bursts.push_back(rsp);
		end

		// check if there was a reset
		if(rsp.status == UVM_TLM_INCOMPLETE_RESPONSE) begin
			`uvm_info(get_type_name(), "Reset detected", UVM_MEDIUM)
			count = 0;	// do not wait for any more responses
			error_bursts.delete();	// do not try to send bursts again
		end

	endfunction: response_handler

//------------------------------------------------------------------------------
//
// SEQUENCE: axi_master_read_no_err_count
//
//------------------------------------------------------------------------------
/**
* Description : sends multiple requests to driver, gets responses and for
*				responses that had an error, sends that request again
*
* Functions :	1. new(string name="axi_master_read_no_err_count")
*				2. void response_handler(uvm_sequence_item response)
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class axi_master_read_no_err_count extends axi_master_read_base_seq;

	`uvm_object_utils(axi_master_read_no_err_count)

	int count = 0;
	int num_of_err = 0;

	rand bit [ADDR_WIDTH-1 : 0] address[$];	// slave addresses

	// new - constructor
	function new(string name="axi_master_read_no_err_count");
		super.new(name);
	endfunction

	virtual task body();

		use_response_handler(1);

		count = address.size();	// number of bursts to be sent

		for(int i = 0; i < address.size(); i++) begin
			if (count)	// if there was a reset, count will be set to 0
				`uvm_do_with(req, {req.addr == address[i];})
			else
				break;
		end

		wait(!count);	// wait for all responses before finishing simulation

	endtask : body

	extern virtual function void response_handler(uvm_sequence_item response);

endclass : axi_master_read_no_err_count

//------------------------------------------------------------------------------
/**
* Function : response_handler
* Purpose : called by the sequencer for each response that arrives for this
*			sequence; decrement the number of requests waiting for responses
* Parameters :	response - uvm seq. item that the driver put
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_no_err_count::response_handler(uvm_sequence_item response);

		if(!($cast(rsp, response)))
			`uvm_error("CASTFAIL", "The recieved response item is not a burst frame");

		count--;	// keep track of number of responses

		// check if there was a reset
		if(rsp.status == UVM_TLM_INCOMPLETE_RESPONSE) begin
			`uvm_info(get_type_name(), "Reset detected", UVM_MEDIUM)
			count = 0;	// do not wait for any more responses
		end
		
	endfunction: response_handler


//------------------------------------------------------------------------------
//
// SEQUENCE: axi_master_read_dut_counter_seq
//
//------------------------------------------------------------------------------
/**
* Description : simple sequence
*
* Functions :	1. new(string name="axi_master_read_dut_counter_seq")
*				2. void response_handler(uvm_sequence_item response)
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class axi_master_read_dut_counter_seq extends axi_master_read_base_seq;

	`uvm_object_utils(axi_master_read_dut_counter_seq)

	rand int count;
	rand int address;

	// new - constructor
	function new(string name="axi_master_read_dut_counter_seq");
		super.new(name);
	endfunction

	virtual task body();

		use_response_handler(1);

		repeat(count)
			begin
				`uvm_do_with (req, {req.addr == address; req.valid_burst == 1; req.burst_type == FIXED; req.size == 1; req.len == 0; req.delay == 0; req.id == 0;})
			end

		wait(!count);	// wait for all responses before finishing simulation

	endtask : body

	extern virtual function void response_handler(uvm_sequence_item response);

endclass : axi_master_read_dut_counter_seq

//------------------------------------------------------------------------------
/**
* Function : response_handler
* Purpose : called by the sequencer for each response that arrives for this
*			sequence; decrement the number of requests waiting for responses
* Parameters :	response - uvm seq. item that the driver put
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_dut_counter_seq::response_handler(uvm_sequence_item response);

		if(!($cast(rsp, response)))
			`uvm_error("CASTFAIL", "The recieved response item is not a burst frame");

		count--;	// keep track of number of responses

		// check if there was a reset
		if(rsp.status == UVM_TLM_INCOMPLETE_RESPONSE) begin
			`uvm_info(get_type_name(), "Reset detected", UVM_MEDIUM)
			count = 0;	// do not wait for any more responses
		end
		
	endfunction: response_handler