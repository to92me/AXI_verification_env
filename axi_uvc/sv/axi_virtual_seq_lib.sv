// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_virtual_seq_lib.sv
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
* Description : contains virtual sequences
*
* Classes :	1. virtual_base_sequence
*			2. virtual_transfer_multiple_addr
*			3. virtual_transfer_single_burst
*			4. virtual_dut_seq
**/
// -----------------------------------------------------------------------------

`ifndef AXI_VIRTUAL_SEQUENCE_LIB_SV
`define AXI_VIRTUAL_SEQUENCE_LIB_SV

//------------------------------------------------------------------------------
//
// CLASS: virtual_base_sequence
//
//------------------------------------------------------------------------------
/**
* Description : raises/drops objections in the pre/post_body so that root
*				sequences raise objections but subsequences do not
*
* Functions :	1. new(string name="virtual_base_sequence")
*
* Tasks :	1. pre_body()
*			2. post_body()
**/
// -----------------------------------------------------------------------------
class virtual_base_sequence extends uvm_sequence;

	`uvm_object_utils(virtual_base_sequence)
	`uvm_declare_p_sequencer(axi_virtual_sequencer)

	// new - constructor
	function new(string name="virtual_base_sequence");
		super.new(name);
	endfunction

	// Raise in pre_body so the objection is only raised for root sequences.
	// There is no need to raise for sub-sequences since the root sequence
	// will encapsulate the sub-sequence.
	virtual task pre_body();
		if (starting_phase!=null) begin
			starting_phase.raise_objection(this);
			uvm_test_done.set_drain_time(this, 200ns);
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
// SEQUENCE: virtual_transfer_multiple_addr
//
//------------------------------------------------------------------------------
/**
* Description : gets address information from configuration and send it to
*				master seq.
*
* Functions :	1. new(string name="virtual_transfer_multiple_addr")
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class virtual_transfer_multiple_addr extends virtual_base_sequence;

	`uvm_object_utils(virtual_transfer_multiple_addr)

	bit[ADDR_WIDTH-1 : 0] slave_addr[$];	// queue for storing addresses

	// new - constructor
	function new(string name="virtual_transfer_multiple_addr");
		super.new(name);
	endfunction

	// axi read master
	axi_master_read_multiple_addr read_seq;

	virtual task body();

		for(int i = 0; i < 10; i++) begin
			slave_addr.push_back(p_sequencer.config_obj.slave_list[0].start_address);
		end

		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {
				foreach (slave_addr[i])
					address[i] == slave_addr[i];
				address.size() == slave_addr.size();
		})
		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {
				foreach (slave_addr[i])
					address[i] == slave_addr[i];
				address.size() == slave_addr.size();
		})
		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {
				foreach (slave_addr[i])
					address[i] == slave_addr[i];
				address.size() == slave_addr.size();
		})
	endtask

endclass : virtual_transfer_multiple_addr

//------------------------------------------------------------------------------
//
// SEQUENCE: virtual_transfer_single_burst
//
//------------------------------------------------------------------------------
/**
* Description : gets address information from configuration and send it to
*				master seq.
*
* Functions :	1. new(string name="virtual_transfer_single_burst")
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class virtual_transfer_single_burst extends virtual_base_sequence;

	`uvm_object_utils(virtual_transfer_single_burst)

	bit[ADDR_WIDTH-1 : 0] slave_addr[$];	// queue for storing addresses

	// new - constructor
	function new(string name="virtual_transfer_single_burst");
		super.new(name);
	endfunction

	// axi read master
	axi_master_read_multiple_addr read_seq;

	virtual task body();

		slave_addr.push_back(p_sequencer.config_obj.slave_list[0].start_address);

		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {
				foreach (slave_addr[i])
					address[i] == slave_addr[i];
				address.size() == slave_addr.size();
		})
	endtask

endclass : virtual_transfer_single_burst

//------------------------------------------------------------------------------
//
// SEQUENCE: virtual_dut_seq
//
//------------------------------------------------------------------------------
/**
* Description : for dut
*
* Functions :	1. new(string name="virtual_dut_seq")
*
* Tasks :	1. body()
**/
// -----------------------------------------------------------------------------
class virtual_dut_seq extends virtual_base_sequence;

	`uvm_object_utils(virtual_dut_seq)

	// new - constructor
	function new(string name="virtual_dut_seq");
		super.new(name);
	endfunction

	// axi read master
	axi_master_read_dut_counter_seq read_seq;

	// WRITE
	axi_master_write_dut_counter_seq write_seq;

	virtual task body();

		// MORA PRVO READ ZBOG RESETA!!!!!!!!!!!!!!!!!!
		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {count == 1; address == 12;})

		#20
		// counter enable, direction down
		`uvm_do_on_with(write_seq, p_sequencer.write_seqr, {count == 1; address == 8; write_data == 16'hffff;})
		// match
		`uvm_do_on_with(write_seq, p_sequencer.write_seqr, {count == 1; address == 14; write_data == 16'hffff;})
		// IM
		`uvm_do_on_with(write_seq, p_sequencer.write_seqr, {count == 1; address == 2; write_data == 16'hffff;})

		#100
		// read counter
		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {count == 1; address == 16;})
		// clear interrupt (IIR)
		`uvm_do_on_with(read_seq, p_sequencer.read_seqr, {count == 1; address == 12;})

	endtask

endclass : virtual_dut_seq

`endif