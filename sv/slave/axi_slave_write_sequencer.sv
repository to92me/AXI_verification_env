`ifndef AXI_SLAVE_WRITE_SEQUENCER_SVH
`define AXI_SLAVE_WRITE_SEQUENCER_SVH


/**
* Project : AXI UVC
*
* File : axi_slave_write_sequencer.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Tomislav Tumbas
*
* E-Mail : tomislav.tumbas@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : axi_slave_write_sequencer
*
* Classes :	1. axi_slave_write_sequencer
*
**/

//------------------------------------------------------------------------------
//
// CLASS: uvc_company_uvc_name_sequencer
//
//------------------------------------------------------------------------------

class axi_slave_write_sequencer extends uvm_sequencer #(axi_frame);

	// Configuration object
	axi_slave_config config_obj;

	// Reset TLM FIFO(since this is a transaction level component the
	// reset should be fetched via a TLM analysis FIFO)
//	tlm_analysis_fifo#(bit) reset_port;

	// TODO: The reset event can also be fetched in other ways


	`uvm_component_utils_begin(axi_slave_write_sequencer)
		`uvm_field_object(config_obj, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end


	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	// Run phase with reset handling mechanism
	// When a reset is detected the default sequence of the sequencer is killed
	// and restarted
	// This method might not always be safe to use so it is not recommended
	virtual task run_phase(uvm_phase phase);
		process main;
		bit reset_status;
		bit test_finished=0;
		super.run_phase(phase);
		forever begin
			fork
				// Main process
				begin
					main=process::self();
					start_default_sequence();
					test_finished=1;
				end
				// Reset process
				begin
//					reset_port.get(reset_status);
					stop_sequences();
					main.kill();
//					reset_port.get(reset_status);
				end
			join
			if(test_finished) break;
		end
	endtask

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : axi_slave_write_sequencer

`endif
