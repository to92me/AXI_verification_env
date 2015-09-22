`ifndef DUT_REGISTER_MODEL_LOWER_SEQUENCE_SVH
`define DUT_REGISTER_MODEL_LOWER_SEQUENCE_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class dut_register_model_lower_sequence extends uvm_sequence#(dut_frame);

	`uvm_component_utils(dut_register_model_lower_sequence)
	`uvm_declare_p_sequencer(dut_register_model_lower_sequencer)


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase


	extern function void  body();


endclass : dut_register_model_lower_sequence

	function void dut_register_model_lower_sequence::body();
	   forever begin
		    frame = new();
		    up_sequencer.get_next_item(frame);
		    if(frame.rw == AXI_WRITE)
			    begin
				    `uvm_do_on(frame, p_sequencer.write_sequencer)
			    end
		    else
			    begin
				    `uvm_do_on(frame, p_sequencer.read_sequencer)
			    end
			up_sequencer.item_done(frame);
	   end
	endfunction

`endif