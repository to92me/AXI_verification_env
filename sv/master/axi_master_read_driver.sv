/******************************************************************************
	* DVT CODE TEMPLATE: driver
	* Created by root on Aug 4, 2015
	* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_driver
//
//------------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_DRIVER_SV
`define AXI_MASTER_READ_DRIVER_SV

class axi_master_read_driver extends uvm_driver #(axi_read_burst_frame);

	// The virtual interface used to drive and view HDL signals.
	virtual axi_if vif;

	// Configuration object
	axi_master_config config_obj;

	// for sending correct responses
	axi_master_read_response resp;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils(axi_master_read_driver)

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		resp = new();
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
				`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

	// run_phase
	virtual task run_phase(uvm_phase phase);
		// The driving should be triggered by an initial reset pulse
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);
		// Start driving here
		get_and_drive();
	endtask : run_phase

	// get_and_drive
	virtual protected task get_and_drive();
		fork
			reset();
			read_addr_channel();
			read_data_channel();
		join
	endtask : get_and_drive

	extern virtual task read_data_channel();
	extern virtual task read_addr_channel();
	extern virtual task reset();

endclass : axi_master_read_driver

	// reset
	task axi_master_read_driver::reset();
		forever begin
			@(negedge vif.sig_reset)
			`uvm_info(get_type_name(), "Reset", UVM_MEDIUM)
			@(posedge vif.sig_clock)	// reset can be asynchronous, but deassertion must be synchronous with clk

			vif.arid <= {ID_WIDTH {1'b0}};
			vif.araddr <= {ADDR_WIDTH {1'b0}};
			vif.arlen <= 8'h0;
			vif.arsize <= 3'h0;
			vif.arburst <= 2'h0;
			vif.arlock <= 1'b0;
			vif.arcache <= 4'h0;
			vif.arprot <= 3'h0;
			vif.arqos <= 4'h0;
			vif.arregion <= 4'h0;
			// user
			vif.arvalid <= 1'b0;

			vif.rready <= 1'b1;
		end
	endtask : reset

	// monitoring the data channel and sending responses back to the seq.
	task axi_master_read_driver::read_data_channel();
		axi_read_single_frame data_frame;
		axi_read_burst_frame burst_frame;

		forever begin
			data_frame = axi_read_single_frame::type_id::create("data_frame");
			burst_frame = axi_read_burst_frame::type_id::create("burst_frame");

			@(posedge vif.sig_clock iff vif.rvalid);
			//vif.rready <= 1'b1;

			// get info
			data_frame.id = vif.rid;
			data_frame.resp = vif.rresp;
			data_frame.data = vif.rdata;
			data_frame.last = vif.rlast;

			resp.check_response(data_frame, burst_frame);
			if (burst_frame != null) begin
				seq_item_port.put(burst_frame);
			end

			//@(posedge vif.sig_clock);
			//vif.rready <= 1'b0;
		end
	endtask : read_data_channel

	// get from seq. and drive signals to the address channel
	task axi_master_read_driver::read_addr_channel();
		forever begin
			seq_item_port.get(req);

			@(posedge vif.sig_clock)
			vif.arid <= req.id;
			vif.araddr <= req.addr;
			vif.arlen <= req.len;
			vif.arsize <= req.size;
			vif.arburst <= req.burst_type;
			vif.arlock <= req.lock;
			vif.arcache <= req.cache;
			vif.arprot <= req.prot;
			vif.arqos <= req.qos;
			vif.arregion <= req.region;
			// user
			vif.arvalid <= 1'b1;

			resp.new_burst(req);

			@(posedge vif.sig_clock);
			vif.arvalid <= 1'b0;	// TODO : ??
		end
	endtask : read_addr_channel

`endif