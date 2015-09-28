`ifndef AXI_WRITE_WRAPPER_SEQUENCE_SVH
`define AXI_WRITE_WRAPPER_SEQUENCE_SVH


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_wrapper_sequence extends uvm_sequence#(axi_frame);


	`uvm_object_utils(axi_write_wrapper_sequence)
	`uvm_declare_p_sequencer(axi_write_wrapper_low_sequencer)


	// new - constructor
	function new (string name = "AxiWriteWrapperSequence");
		super.new(name);
	endfunction : new



	extern task body();

endclass : axi_write_wrapper_sequence


	task axi_write_wrapper_sequence::body();
		forever begin
			dut_frame 	frame_dut;
			axi_frame 	frame_axi;
			int 		i;

			p_sequencer.upper_seq_item_port.get_next_item(frame_dut);

			$cast(frame_axi, frame_dut);

			$display("id: %h, len %0d, data: %h", frame_axi.id, frame_axi.len, frame_axi.data[0]);

			`uvm_do_with(req,
					    	{	req.addr		== frame_axi.addr;
						    	foreach(frame_axi.data[i])
						    		req.data[i] 	== frame_axi.data[i];
						    	req.len			== frame_axi.len;
								req.size 		== frame_axi.size;
						    	req.burst_type 	== frame_axi.burst_type;
						    	req.lock 		== frame_axi.lock;
						    	req.id			== frame_axi.id;
						    	req.cache 		== frame_axi.cache;
						    	req.prot		== frame_axi.prot;
						    	req.qos			== frame_axi.qos;
						    	req.region		== frame_axi.region;
						    	req.wuser		== frame_axi.wuser;
						    	req.awuser		== frame_axi.awuser;
						    	req.resp		== frame_axi.resp;
					    	}
						)


//			start_item(req, .sequencer(p_sequencer));

//			finish_item(req);


		 	get_response(frame_axi);

			frame_dut.resp = frame_axi.resp;

			p_sequencer.upper_seq_item_port.item_done(frame_dut);
		end
	endtask

`endif