`ifndef AXI_WRITE_WRAPPER_SEQUENCE_SVH
`define AXI_WRITE_WRAPPER_SEQUENCE_SVH


//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_component
//
//------------------------------------------------------------------------------

class axi_write_wrapper_sequence extends uvm_sequence#(dut_frame);


	`uvm_component_utils(axi_write_wrapper_sequence)
	`uvm_declare_p_sequencer(axi_write_wrapper_low_sequencer)


	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	extern task body();

endclass : axi_write_wrapper_sequence


	task axi_write_wrapper_sequence::body();
		forever begin
			axi_frame = frame;

			p_sequencer.upper_seq_item_port.get_next_item(req);;

			$cast(frame, req);
			`uvm_do(frame);

			p_sequencer.upper_seq_item_port.item_done(req);
		end
	endtask

`endif