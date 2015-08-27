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

	// queue that holds master burst requests
	axi_read_whole_burst burst_req[$];
	// queue that holds single frames that are ready to be sent
	axi_read_single_frame ready_queue[$];

	// control bit for enabling ready randomization
	bit slave_ready_rand_enable = 1;
	ready_randomization ready_rand;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_driver)
		`uvm_field_int(slave_ready_rand_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		if(slave_ready_rand_enable)
			ready_rand = new();
	endfunction : new

	// class methods
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task get_and_drive();
	extern virtual task get_from_seq();
	extern virtual task reset();
	extern virtual task drive_addr_channel();
	extern virtual task drive_data_channel();

endclass : axi_slave_read_driver

	// build_phase
	function void axi_slave_read_driver::build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_slave_config)::get(this, "", "axi_slave_config", config_obj))
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
			reset();
			get_from_seq();
			drive_addr_channel();
			drive_data_channel();
		join
	endtask : get_and_drive

	// get new burst from sequencer
	task axi_slave_read_driver::get_from_seq();

		axi_read_base_frame item;
		axi_read_whole_burst req;
		axi_read_single_frame rsp;

		forever begin

			@(posedge vif.sig_clock);
			#1	// for simulation

			// phase 1 - send burst info to seq.
			seq_item_port.get_next_item(item);
			if ($cast(req, item))
				begin
					if (burst_req.size()) begin
						req.copy(burst_req.pop_front());
						req.valid = FRAME_VALID;
					end
					else begin
						req.valid = FRAME_NOT_VALID;
					end
				end
			else
				`uvm_error("CASTFAIL", "The recieved seq. item is not a request seq. item");
			seq_item_port.item_done();

			// phase 2 - get single frame from seq.
			seq_item_port.get_next_item(item);
			if ($cast(rsp, item))
				begin
					// put the frame in the ready queue
					if(rsp.valid == FRAME_VALID) begin
						ready_queue.push_back(rsp);
					end
				end
			else
				`uvm_error("CASTFAIL", "The recieved seq. item is not a response seq. item");
			seq_item_port.item_done();
		end
	endtask : get_from_seq

	// reset
	task axi_slave_read_driver::reset();
		forever begin
			@(negedge vif.sig_reset);
			`uvm_info(get_type_name(), "Reset", UVM_MEDIUM)
			@(posedge vif.sig_clock);	// reset can be asynchronous, but deassertion must be synchronous with clk

			// reset signals
			vif.rid <= {ID_WIDTH {1'b0}};
			vif.rdata <= {DATA_WIDTH {1'bz}};
			vif.rresp <= 2'h0;
			vif.rlast <= 1'b0;
			//vif.ruser
			vif.rvalid <= 1'b0;
			if (slave_ready_rand_enable)
				vif.arready <= ready_rand.getRandom();
			else
				vif.arready <= 1'b1;

			// TODO: reset queues

			// TODO: reset sequence

		end
	endtask : reset

	// address channel signals - collect burst request
	task axi_slave_read_driver::drive_addr_channel();

		axi_read_whole_burst burst_collected;

		forever begin
			burst_collected = axi_read_whole_burst::type_id::create("burst_collected");

			@ (posedge vif.sig_clock);
			if(vif.arready && vif.arvalid) begin
				if(config_obj.check_addr_range(vif.araddr)) begin
					// get info
					burst_collected.id = vif.arid;
					burst_collected.addr = vif.araddr;
					burst_collected.len = vif.arlen;
					burst_collected.size = vif.arsize;
					burst_collected.burst_type = vif.arburst;
					burst_collected.lock = vif.arlock;
					burst_collected.cache = vif.arcache;
					burst_collected.prot = vif.arprot;
					burst_collected.qos = vif.arqos;
					burst_collected.region = vif.arregion;
					// user

					burst_req.push_back(burst_collected);
				end

				// randomize ready
				if(slave_ready_rand_enable) begin
					#1	// for simulation
					vif.arready <= ready_rand.getRandom();
				end
			end
			else begin
				// randomize ready
				if(slave_ready_rand_enable) begin
					#1	// for simulation
					vif.arready <= ready_rand.getRandom();
				end
			end
			
		end
	endtask : drive_addr_channel

	// data channel signals - drive responses
	task axi_slave_read_driver::drive_data_channel();
		axi_read_single_frame rsp;

		// @clk only before first if-else check
		// after that, waiting for clk is done in the if-else branches
		@(posedge vif.sig_clock);
		#1	// for simulation
		forever begin
			// is there a frame waiting to be sent
			if (ready_queue.size()) begin
				rsp = ready_queue.pop_front();

				#1	// for simulation
				// vif signals
				vif.rid <= rsp.id;
				vif.rdata <= rsp.data;
				vif.rresp <= rsp.resp;
				vif.rlast <= rsp.last;
				// user
				vif.rvalid <= 1'b1;

				@(posedge vif.sig_clock iff vif.rready);	// wait for master
			end
			else begin
				#1	// for simulation
				vif.rvalid <= 1'b0;

				@(posedge vif.sig_clock);
			end
		end
	endtask : drive_data_channel

`endif