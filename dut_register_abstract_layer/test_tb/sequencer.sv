`ifndef DUT_REGISTER_MODEL_VIRTUAL_SEQUENCER_SVH
`define DUT_REGISTER_MODEL_VIRTUAL_SEQUENCER_SVH

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_sequencer
//
//------------------------------------------------------------------------------

class dut_register_model_sequencer extends uvm_sequencer;


	axi_config config_obj;

	axi_master_read_sequencer 	read_seqr;
	axi_master_write_sequencer 	write_seqr;

	`uvm_component_utils(dut_register_model_sequencer)


	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);

endclass : dut_register_model_sequencer



function dut_register_model_sequencer::build_phase(input uvm_phase phase);
    super.build_phase(phase);

		if(!uvm_config_db#(axi_config)::get(this, "", "axi_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})

endfunction


`endif