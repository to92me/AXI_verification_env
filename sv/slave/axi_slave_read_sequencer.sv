/******************************************************************************
	* DVT CODE TEMPLATE: sequencer with reset handling
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_sequencer
//
//------------------------------------------------------------------------------

class axi_slave_read_sequencer extends uvm_sequencer #(axi_frame);

	// Configuration object
	axi_slave_config config_obj;

	// peek at monitor
	uvm_blocking_peek_port#(axi_frame) addr_trans_port;

	// Reset TLM FIFO(since this is a transaction level component the
	// reset should be fetched via a TLM analysis FIFO)
	tlm_analysis_fifo#(bit) reset_port;

	// register
	`uvm_object_utils_begin(axi_slave_read_sequencer)
		`uvm_field_object(config_obj, UVM_DEFAULT)
	`uvm_component_utils_end

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the configuration object
		if(!uvm_config_db#(axi_slave_config)::get(this, "", "config_obj", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
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
					reset_port.get(reset_status);
					stop_sequences();
					main.kill();
					reset_port.get(reset_status);
				end
			join
			if(test_finished) break;
		end
	endtask

	// new - constructor
	function new (string name = "axi_slave_read_sequencer", uvm_component parent = null);
		super.new(name, parent);
		addr_trans_port = new("addr_trans_port", this);
	endfunction : new

endclass : axi_slave_read_sequencer