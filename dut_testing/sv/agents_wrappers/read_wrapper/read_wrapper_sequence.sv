`ifndef AXI_READ_WRAPPER_SEQUENCE_SVH_
`define AXI_READ_WRAPPER_SEQUENCE_SVH_


class axi_read_wrapper_sequence extends uvm_sequence#(axi_read_whole_burst);

	axi_read_whole_burst  read_frame;

		// new - constructor
	function new(string name="axi_read_wrapper_sequence");
		super.new(name);
	endfunction

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


		    p_sequencer.upper_seq_item_port.get_next_item(frame);


		    `uvm_do_on_with(req, p_sequencer.read_sequencer,
							{	req.addr		== frame.addr;
						    	req.len			== frame.len;
								req.size 		== frame.size;
						    	req.burst_type 	== frame.burst_type;
						    	req.lock 		== frame.lock;
						    	req.id			== frame.id;
						    	req.cache 		== frame.cache;
						    	req.prot		== frame.prot;
						    	req.qos			== frame.qos;
						    	req.region		== frame.region;
							}
						)

		    get_response(req);

		    // TODO
		    // budj treba da se reis da se prosledjuje sve kao u write, ne znam trenutno kako
		    frame.data[0] = req.single_frames[0].data;
			frame.resp 	  = req.single_frames[0].resp;


		    p_sequencer.upper_seq_item_port.item_done(frame);

	    end
	endtask

`endif