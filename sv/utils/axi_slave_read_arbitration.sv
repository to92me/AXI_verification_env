/******************************************************************************
	* DVT CODE TEMPLATE: component
	* Created by root on Aug 5, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_arbitration
//
//------------------------------------------------------------------------------

class axi_slave_read_arbitration extends uvm_component;

	// TODO: Add fields here
	axi_data data;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_slave_read_arbitration)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	// create item with data and delay
	function axi_data create_new_item(axi_frame);

	endfunction : create_new_item

	// push data to queue, shortest delay first
	function void push_to_queue(axi_data data);

	endfunction : push_to_queue

	// get burst information
	static function void get_burst_info(ref axi_frame burst_frame);
		for (int i=0; i<burst_frame.len; i++) begin
			data = create_new_item(burst_frame.size);
			push_to_queue(data);
		end
	endfunction : get_burst_info

endclass : axi_slave_read_arbitration
