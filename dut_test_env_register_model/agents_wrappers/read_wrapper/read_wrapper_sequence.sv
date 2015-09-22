`ifndef AXI_READ_WRAPPER_SEQUENCE_SVH
`define AXI_READ_WRAPPER_SEQUENCE_SVH


class axi_read_wrapper_sequence extends uvm_sequence#(dut_frame);

	`uvm_component_utils(axi_read_wrapper_sequence)
	`uvm_declare_p_sequencer(axi_read_wrapper_low_sequencer)

	axi_read_burst_frame  read_frame;


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase


	extern task body();

endclass : axi_read_wrapper_sequence


	task axi_read_wrapper_sequence::body();
	    forever begin
		    p_sequencer.upper_seq_item_port.get_next_item(req);

		    read_frame = new();
		    read_frame.addr 		= req.addr;
		    read_frame.id			= req.id;
		    read_frame.len			= req.len;
		    read_frame.size 		= req.size;
		    read_frame.burst_type 	= req.burst_type;

		    `uvm_do(read_frame);

		     p_sequencer.upper_seq_item_port.item_done(req);

	    end
	endtask

`endif