/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by andrea on Aug 20, 2015
* uvc_company = axi, uvc_name = virtual
* uvc_trans = uvc_trans
*******************************************************************************/

`ifndef AXI_VIRTUAL_SEQUENCE_LIB_SV
`define AXI_VIRTUAL_SEQUENCE_LIB_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_virtual_base_seq
//
//------------------------------------------------------------------------------
// This sequence raises/drops objections in the pre/post_body so that root
// sequences raise objections but subsequences do not.
class virtual_base_sequence extends uvm_sequence;

	`uvm_object_utils(virtual_base_sequence)
	`uvm_declare_p_sequencer(axi_virtual_sequencer)

	// new - constructor
	function new(string name="virtual_base_seq");
		super.new(name);
	endfunction

	// Raise in pre_body so the objection is only raised for root sequences.
	// There is no need to raise for sub-sequences since the root sequence
	// will encapsulate the sub-sequence.
	virtual task pre_body();
		if (starting_phase!=null) begin
			starting_phase.raise_objection(this);
		end
	endtask

	// Drop the objection in the post_body so the objection is removed when
	// the root sequence is complete.
	virtual task post_body();
		if (starting_phase!=null) begin
			starting_phase.drop_objection(this);
		end
	endtask

endclass : virtual_base_sequence

//------------------------------------------------------------------------------
//
// SEQUENCE: virtual_transfer_seq
//
//------------------------------------------------------------------------------
class virtual_transfer_seq extends virtual_base_sequence;

	`uvm_object_utils(virtual_transfer_seq)

	bit[ADDR_WIDTH-1 : 0] dummy;

	// new - constructor
	function new(string name="virtual_transfer_seq");
		super.new(name);
	endfunction

	// axi read master
	axi_master_read_transfer_seq read_seq;

	virtual task body();
		dummy = p_sequencer.config_obj.slave_list[0].start_address;
		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {addr_rand == dummy;})
	endtask

endclass : virtual_transfer_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: virtual_transfer_multiple_addr
//
//------------------------------------------------------------------------------
class virtual_transfer_multiple_addr extends virtual_base_sequence;

	`uvm_object_utils(virtual_transfer_multiple_addr)

	bit[ADDR_WIDTH-1 : 0] slave_addr[];	// packed array for storing addresses

	// new - constructor
	function new(string name="virtual_transfer_multiple_addr");
		super.new(name);
	endfunction

	// axi read master
	axi_master_read_multiple_addr read_seq;

	virtual task body();
		slave_addr = new[3];
		slave_addr[0] = p_sequencer.config_obj.slave_list[0].start_address;
		slave_addr[1] = p_sequencer.config_obj.slave_list[0].start_address;
		slave_addr[2] = p_sequencer.config_obj.slave_list[0].start_address;

		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {
				foreach (slave_addr[i])
					address[i] == slave_addr[i];
				address.size() == slave_addr.size();
		})
	endtask

endclass : virtual_transfer_multiple_addr

`endif