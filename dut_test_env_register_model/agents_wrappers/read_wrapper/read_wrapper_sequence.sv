`ifndef AXI_READ_WRAPPER_SEQUENCE_SVH
`define AXI_READ_WRAPPER_SEQUENCE_SVH


class axi_read_wrapper_sequence extends uvm_sequence#(axi_read_whole_burst);

	axi_read_whole_burst  read_frame;

		// new - constructor
	function new(string name="axi_read_wrapper_sequence");
		super.new(name);
	endfunction

//AxiReadWrapperSequence

	`uvm_object_utils(axi_read_wrapper_sequence)
	`uvm_declare_p_sequencer(axi_read_wrapper_low_sequencer)

	virtual task pre_body();
	endtask

	extern virtual task body();

	virtual task post_body();
	endtask

endclass : axi_read_wrapper_sequence


	task axi_read_wrapper_sequence::body();
	    forever begin
		    dut_frame frame;

		    $display("Waiting Read Wrapper frame");

		    p_sequencer.upper_seq_item_port.get_next_item(frame);


		    read_frame = new();
		    read_frame.addr 		= frame.addr;
		    read_frame.id			= frame.id;
		    read_frame.len			= frame.len;
		    read_frame.size 		= frame.size;
		    read_frame.burst_type 	= frame.burst_type;

		    `uvm_do(read_frame);

		    get_response(read_frame);

		    frame.data[0] = read_frame.single_frames[0].upper_byte_lane;

		    p_sequencer.upper_seq_item_port.item_done(frame);

	    end
	endtask

`endif