/******************************************************************************
	* DVT CODE TEMPLATE: driver
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_slave_read_driver
//
//------------------------------------------------------------------------------

`ifndef AXI_SLAVE_READ_DRIVER_SV
`define AXI_SLAVE_READ_DRIVER_SV

class axi_slave_read_driver extends uvm_driver #(axi_read_base_frame, axi_read_base_frame);

	// The virtual interface used to drive and view HDL signals.
	protected virtual axi_if vif;

	// Configuration object
	axi_slave_config config_obj;

	uvm_blocking_peek_port#(axi_read_burst_frame) addr_trans_port;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_driver)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		addr_trans_port = new("addr_trans_port", this);
	endfunction : new

	// class methods
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task get_and_drive();
	extern virtual task get_from_seq();
	extern virtual task reset();
	extern virtual task drive_next_single_frame(axi_read_single_frame rsp);

endclass : axi_slave_read_driver

	// build_phase
	function void axi_slave_read_driver::build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_slave_config)::get(this, "", "config_obj", config_obj))
				`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// run_phase
	task axi_slave_read_driver::run_phase(uvm_phase phase);
		// The driving should be triggered by an initial reset pulse
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);
		// Start driving here
		get_and_drive();
	endtask : run_phase

	// get_and_drive
	task axi_slave_read_driver::get_and_drive();
		fork
			get_from_seq();
			reset();
		join
	endtask : get_and_drive

	// get new burst from sequencer
	task axi_slave_read_driver::get_from_seq();

		axi_read_base_frame item;
		axi_read_burst_frame req;
		axi_read_single_frame rsp;

		forever begin

			// phase 1
			seq_item_port.get_next_item(item);
			if ($cast(req, item))
				begin
					// TODO : uzmi od monitora, ako ima
				end
			else
				`uvm_error("CASTFAIL", "The recieved seq. item is not a request seq. item");
			seq_item_port.item_done();

			// phase 2
			seq_item_port.get_next_item(item);
			if ($cast(rsp, item))
				begin
					drive_next_single_frame(rsp);
				end
			else
				`uvm_error("CASTFAIL", "The recieved seq. item is not a response seq. item");
			seq_item_port.item_done();
		end
	endtask : get_from_seq

	// reset
	task axi_slave_read_driver::reset();
		forever begin
			@(negedge vif.sig_reset)
			`uvm_info(get_type_name(), "Reset", UVM_MEDIUM)
			@(posedge vif.sig_clock)	// reset can be asynchronous, but deassertion must be synchronous with clk

			// reset signals
			vif.rid <= {ID_WIDTH {1'b0}};
			vif.rdata <= {DATA_WIDTH {1'bz}};
			vif.rresp <= 2'h0;
			vif.rlast <= 1'b0;
			//vif.ruser
			vif.rvalid <= 1'b0;
			vif.arready <= 1'b1;

			// TODO: reset queues

			// TODO: reset sequence

		end
	endtask : reset

	// drive next single frame
	task axi_slave_read_driver::drive_next_single_frame(axi_read_single_frame rsp);
			@(posedge vif.sig_clock);
			if (rsp.valid == FRAME_VALID) begin
					// vif signals
					vif.rid <= rsp.id;
					vif.rdata <= rsp.data;
					vif.rresp <= rsp.resp;
					vif.rlast <= rsp.last;
					// user
					vif.rvalid <= 1'b1;
				end
			else begin
				vif.rvalid <= 1'b0;
			end
	endtask : drive_next_single_frame

`endif