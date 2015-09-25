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
			dut_frame frame_dut;
			axi_frame frame_axi;

			$display("WRPPER WAITING FOR FRAME");

			p_sequencer.upper_seq_item_port.get_next_item(frame_dut);

			$display("id: %h, len %0d, data: %h", frame_dut.id, frame_dut.len, frame_dut.data[0]);

			$cast(frame_axi, frame_dut);

			$display("id: %h, len %0d, data: %h", frame_axi.id, frame_axi.len, frame_axi.data[0]);

			`uvm_do_with(req, {req.id == frame_axi.id; req.data[0] == frame_axi.data[0]; req.len == frame_axi.len;
								req.size == frame_axi.size; req.burst_type == FIXED;})

//			start_item(frame_axi);
//
//			finish_item(frame_axi);

			 get_response(frame_axi);

			frame_dut.resp = frame_axi.resp;

			p_sequencer.upper_seq_item_port.item_done(frame_dut);
		end
	endtask

`endif