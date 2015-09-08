// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_master_read_driver.sv
*
* Language : SystemVerilog
*
* Company : Elsys Eastern Europe
*
* Author : Andrea Erdeljan
*
* E-Mail : andrea.erdeljan@elsys-eastern.com
*
* Mentor : Darko Tomusilovic
*
* Description : driver for read master
*
* Classes :	axi_master_read_driver
**/
// -----------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_DRIVER_SV
`define AXI_MASTER_READ_DRIVER_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_driver
//
//------------------------------------------------------------------------------
/**
* Description : drives new burst requests to the address channel and gets
*				responses on the data channel (which it sends to the seq.)
*
* Functions :	1. new (string name, uvm_component parent);
*				2. void build_phase(uvm_phase phase)
*
* Tasks :	1. run_phase(uvm_phase phase)
*			2. get_and_drive()
*			3. read_data_channel()
*			4. drive_addr_channel()
*			5. reset()
**/
// -----------------------------------------------------------------------------
class axi_master_read_driver extends uvm_driver #(axi_read_burst_frame);

	// The virtual interface used to drive and view HDL signals.
	virtual axi_if vif;

	// Configuration object
	axi_master_config config_obj;

	// for sending correct responses
	axi_master_read_response resp;

	// control bit to enable ready randomization (else - default = 1)
	bit master_ready_rand_enable = 1;
	ready_randomization ready_rand;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_master_read_driver)
		`uvm_field_object(resp, UVM_DEFAULT)
		`uvm_field_int(master_ready_rand_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		resp = axi_master_read_response::type_id::create("resp", this);
		if(master_ready_rand_enable)
			ready_rand = new();
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task get_and_drive();
	extern virtual task read_data_channel();
	extern virtual task drive_addr_channel();
	extern virtual task reset();

endclass : axi_master_read_driver

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build - propagate the virtual interface and configuration object
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_driver::build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
				`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})
	endfunction: build_phase

//------------------------------------------------------------------------------
/**
* Task : run_phase
* Purpose : wait for reset and then drive transactions
* Inputs : phase - uvm phase
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_driver::run_phase(uvm_phase phase);
		// The driving should be triggered by an initial reset pulse
		@(negedge vif.sig_reset);
		do
			reset();
		while(vif.sig_reset!==1);
		// Start driving here
		get_and_drive();
	endtask : run_phase

//------------------------------------------------------------------------------
/**
* Task : get_and_drive
* Purpose : create tasks for reset, address channel and data channel
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_driver::get_and_drive();
		fork
			forever begin
				@(negedge vif.sig_reset);
				reset();
			end
			drive_addr_channel();
			read_data_channel();
		join
	endtask : get_and_drive

//------------------------------------------------------------------------------
/**
* Task : reset
* Purpose : reset
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_driver::reset();

		axi_read_burst_frame resp_burst;
		resp_burst = axi_read_burst_frame::type_id::create("resp_burst");

		`uvm_info(get_type_name(), "Reset", UVM_MEDIUM)

		@(posedge vif.sig_clock);	// reset can be asynchronous, but deassertion must be synchronous with clk
		#1	// for simulation

		vif.arid <= {RID_WIDTH {1'b0}};
		vif.araddr <= {ADDR_WIDTH {1'b0}};
		vif.arlen <= 8'h0;
		vif.arsize <= 3'h0;
		vif.arburst <= 2'h0;
		vif.arlock <= 1'b0;
		vif.arcache <= 4'h0;
		vif.arprot <= 3'h0;
		vif.arqos <= 4'h0;
		vif.arregion <= 4'h0;
		vif.aruser <= {ARUSER_WIDTH {1'b0}};
		vif.arvalid <= 1'b0;

		if (master_ready_rand_enable)
			vif.rready <= ready_rand.getRandom();
		else
			vif.rready <= 1'b1;
		
		// send responses to seq. for all outstanding bursts
		// resp_burst will have a UVM_TLM_INCOMPLETE_RESPONSE which will reset the seq.
		// else - seq. is not waiting for any responses
		resp.reset(resp_burst);
		if(resp_burst.status == UVM_TLM_INCOMPLETE_RESPONSE)
			seq_item_port.put(resp_burst);

	endtask : reset

//------------------------------------------------------------------------------
/**
* Task : read_data_channel
* Purpose : monitors the data channel and sends responses back to the seq.
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_driver::read_data_channel();
		axi_read_single_frame data_frame;
		axi_read_burst_frame burst_frame;

		forever begin
			data_frame = axi_read_single_frame::type_id::create("data_frame");
			burst_frame = axi_read_burst_frame::type_id::create("burst_frame");

			@(posedge vif.sig_clock iff vif.sig_reset == 1);
			if(vif.rready && vif.rvalid) begin
				// get info
				data_frame.id = vif.rid;
				data_frame.resp = vif.rresp;
				data_frame.data = vif.rdata;
				data_frame.last = vif.rlast;
				data_frame.user = vif.ruser;

				resp.check_response(data_frame, burst_frame);	// check if the burst is complete or if there is an error
				if (burst_frame != null) begin
					seq_item_port.put(burst_frame);
				end

				// randomize ready
				if(master_ready_rand_enable) begin
					#1	// for simulation
					vif.rready <= ready_rand.getRandom();
				end
			end
			else begin
				// randomize ready
				if(master_ready_rand_enable) begin
					#1	// for simulation
					vif.rready <= ready_rand.getRandom();
				end
			end
		end
	endtask : read_data_channel

//------------------------------------------------------------------------------
/**
* Task : drive_addr_channel
* Purpose : gets items from seq., checks delay and pipe and then drives signals
*			to the address channel
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_driver::drive_addr_channel();
		int bursts_in_pipe;

		@(posedge vif.sig_clock iff vif.sig_reset == 1);	// only for the first time

		forever begin
			// get from seq
			seq_item_port.get(req);

			// wait if there is a delay
			if(req.delay > 0) begin
				repeat(req.delay) @(posedge vif.sig_clock iff vif.sig_reset == 1);
			end

			// check if pipe is full and wait until it is freed up
			resp.get_num_of_bursts(bursts_in_pipe);
			if(bursts_in_pipe >= MASTER_PIPE_SIZE) begin
				do begin
					@ (posedge vif.sig_clock);
					resp.get_num_of_bursts(bursts_in_pipe);
				end
				while(bursts_in_pipe >= MASTER_PIPE_SIZE);
			end

			#1	// for simulation

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
			vif.aruser <= req.user;
			vif.arvalid <= 1'b1;

			resp.new_burst(req);	// send burst to resp so responses can be calculated

			@(posedge vif.sig_clock iff vif.arready);	// wait for slave
			#1	// for simulation
			vif.arvalid <= 1'b0;

		end
	endtask : drive_addr_channel

`endif