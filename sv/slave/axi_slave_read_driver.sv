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

class axi_slave_read_driver extends uvm_driver #(axi_frame);

	// The virtual interface used to drive and view HDL signals.
	protected virtual axi_if vif;

	// Configuration object
	axi_slave_config config_obj;


	axi_slave_read_arbitration arbit;
	axi_read_single_frame one_frame;

	// Provide implmentations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_slave_read_driver)
    	`uvm_field_object(arbit, UVM_DEFAULT)
    	`uvm_field_object(one_frame, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		arbit = new();
		one_frame = new();
	endfunction : new

	// build_phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// Propagate the interface
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
			// Propagate the configuration object
			if(!uvm_config_db#(axi_slave_config)::get(this, "", "config_obj", config_obj))
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
	virtual task get_and_drive();
		fork
			get_from_seq();
			reset();
			dec_delay();
			drive_next_single_frame();
		join
	endtask : get_and_drive

	virtual task get_from_seq();
		forever begin
			seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
			rsp.set_id_info(req);

			// send burst info to arbitration where it will make
			// all the single frames and update the queues
			arbit.get_new_burst(rsp);

			seq_item_port.item_done();
			seq_item_port.put_response(rsp);
		end
	endtask : get_from_seq

	virtual task reset();
		forever begin
			@(negedge vif.sig_reset)
			`uvm_info(get_type_name(), "Reset", UVM_MEDIUM)

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

	virtual task drive_next_single_frame();
		forever begin
			@(posedge vif.sig_clock);
			// @ event
			if (arbit.ready_queue.size())
				begin
					one_frame = arbit.ready_queue.pop_front();

					// vif signals
					vif.rid <= one_frame.id;
					vif.rdata <= one_frame.data;
					vif.rresp <= response_enum::OKAY;
					vif.rlast <= one_frame.read_last;
					// user
					vif.rvalid <= 1'b1;
				end
			else
				vif.rvalid <= 1'b0;
		end
	endtask : drive_next_single_frame

	virtual task dec_delay();
		forever begin
			@(posedge vif.sig_clock);
			arbit.slave_read_dec_delay();
		end
	endtask : dec_delay

endclass : axi_slave_read_driver
