`ifndef DUT_REGISTER_MODEL_LOWER_SEQUENCE_SVH
`define DUT_REGISTER_MODEL_LOWER_SEQUENCE_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_lower_sequence extends uvm_sequence#(dut_frame);

	function new (string name = "DutRegisterModelLowerSequence");
		super.new(name);
	endfunction : new


	`uvm_object_utils(dut_register_model_lower_sequence)
	`uvm_declare_p_sequencer(dut_register_model_lower_sequencer)

	extern virtual task body();


endclass : dut_register_model_lower_sequence

	task  dut_register_model_lower_sequence::body();
	   forever begin
		   int i;
		   dut_frame frame = new();

		    p_sequencer.upper_seq_item_port.get_next_item(frame);

		    if(frame.rw == AXI_WRITE)
			    begin
				    // constrin all fields to recieved frame fiels
				    `uvm_do_on_with(req,p_sequencer.write_sequencer,
					    	{	req.addr		== frame.addr;
						    	foreach(frame.data[i])
						    		req.data[i] 	== frame.data[i];
						    	req.len			== frame.len;
								req.size 		== frame.size;
						    	req.burst_type 	== frame.burst_type;
						    	req.lock 		== frame.lock;
						    	req.id			== frame.id;
						    	req.cache 		== frame.cache;
						    	req.prot		== frame.prot;
						    	req.qos			== frame.qos;
						    	req.region		== frame.region;
						    	req.wuser		== frame.wuser;
						    	req.awuser		== frame.awuser;
						    	//req.resp		== frame.resp;
					    	}
					  )
			    end
		    else
			    begin
				    // constrin all fields to recieved frame fiels
				    `uvm_do_on_with(req,p_sequencer.read_sequencer,
					    	{	req.addr		== frame.addr;
						    	//req.data[0] 	== frame.data[0];
						    	req.len			== frame.len;
								req.size 		== frame.size;
						    	req.burst_type 	== frame.burst_type;
						    	req.lock 		== frame.lock;
						    	req.id			== frame.id;
						    	req.cache 		== frame.cache;
						    	req.prot		== frame.prot;
						    	req.qos			== frame.qos;
						    	req.region		== frame.region;
						    	req.wuser		== frame.wuser;
						    	req.awuser		== frame.awuser;
						    	//req.resp		== frame.resp;
					    	}
					    )
			    end
			frame.copyDutFrame(req);
			p_sequencer.upper_seq_item_port.item_done(frame);
	   end
	endtask

`endif