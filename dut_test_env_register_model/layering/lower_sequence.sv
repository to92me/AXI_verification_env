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


		     dut_frame frame = new();

		     $display("");
		   	$display(" WAITING FRAME ");
		   $display("");


		    p_sequencer.upper_seq_item_port.get_next_item(frame);

		   $display("");
		   	$display("GOT FRAME ");
		   $display("");

		    if(frame.rw == AXI_WRITE)
			    begin
				     $display("AXI_WRITE ");
//				    `uvm_do_on(frame, p_sequencer.write_sequencer)
				     //start_item(.item(frame), .sequencer(p_sequencer.write_sequencer));
				    `uvm_do_on_with(req,p_sequencer.write_sequencer, {req.id == frame.id; req.data[0] == frame.data[0]; req.len == frame.len;
								req.size == frame.size; req.burst_type == FIXED;})
				     //$display("POSLATO");
				     //finish_item(frame);
				     $display("AXI_WRITE DONE ");

			    end
		    else
			    begin
				     $display("AXI READ ");
				    `uvm_do_on(frame, p_sequencer.read_sequencer)
			    end
			p_sequencer.upper_seq_item_port.item_done(frame);
	   end
	endtask

`endif