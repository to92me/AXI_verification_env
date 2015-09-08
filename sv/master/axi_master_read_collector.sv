// -----------------------------------------------------------------------------
/**
* Project : AXI UVC
*
* File : axi_master_read_collector.sv
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
* Description : collector for read master
*
* Classes :	axi_master_read_collector
**/
// -----------------------------------------------------------------------------

`ifndef AXI_MASTER_READ_COLLECTOR_SV
`define AXI_MASTER_READ_COLLECTOR_SV

//------------------------------------------------------------------------------
//
// CLASS: axi_master_read_collector
//
//------------------------------------------------------------------------------
/**
* Description : collects transactions from the interface and sends them to the
*				monitor
*
* Functions :	1. new (string name, uvm_component parent)
*				2. void build_phase(uvm_phase phase)
*				3. report_phase(uvm_phase phase)
*
* Tasks :	1. run_phase(uvm_phase phase)
*			2. collect_transactions()
*			3. reset()
**/
// -----------------------------------------------------------------------------
class axi_master_read_collector extends uvm_monitor;

	// This property is the virtual interfaced needed for this component to drive
	// and view HDL signals.
	virtual axi_if vif;

	// configuration information
	axi_master_config config_obj;

	// TLM Ports
	uvm_analysis_port #(axi_read_single_frame) data_collected_port;
	uvm_analysis_port #(axi_read_burst_frame) addr_collected_port;

	// The following property holds the transaction information currently
	// begin captured (by the collect_address_phase and data_phase methods).
	axi_read_single_frame trans_data_channel;
	axi_read_burst_frame trans_addr_channel;

	// Number of transactions
	protected int unsigned num_single_frames = 0;
	protected int unsigned num_burst_frames = 0;

	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(axi_master_read_collector)
		`uvm_field_object(config_obj, UVM_DEFAULT | UVM_REFERENCE)
		`uvm_field_int(num_single_frames, UVM_DEFAULT)
		`uvm_field_int(num_burst_frames, UVM_DEFAULT)
	`uvm_component_utils_end

	// new - constructor
	function new (string name, uvm_component parent);
		super.new(name, parent);
		trans_data_channel = axi_read_single_frame::type_id::create("trans_data_channel");
		trans_addr_channel = axi_read_burst_frame::type_id::create("trans_addr_channel");
		data_collected_port = new("data_collected_port", this);
		addr_collected_port = new("addr_collected_port", this);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern virtual task collect_transactions();
	extern virtual function void report_phase(uvm_phase phase);
	extern virtual task reset();

endclass : axi_master_read_collector

//------------------------------------------------------------------------------
/**
* Function : build_phase
* Purpose : build - propagate the virtual interface and configuration object
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_collector::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

		// Propagate the configuration object
		if(!uvm_config_db#(axi_master_config)::get(this, "", "axi_master_config", config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".config_obj"})

	endfunction: build_phase

//------------------------------------------------------------------------------
/**
* Task : run_phase
* Purpose : wait for reset and then collect transactions
* Inputs : phase - uvm phase
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_collector::run_phase(uvm_phase phase);
		@(negedge vif.sig_reset);
		do
			@(posedge vif.sig_clock);
		while(vif.sig_reset!==1);
    	`uvm_info(get_type_name(), "Detected Reset Done", UVM_LOW)

    	fork
    		collect_transactions();
    		reset();
    	join
	endtask : run_phase

//------------------------------------------------------------------------------
/**
* Task : reset
* Purpose : reset
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_collector::reset();

    	forever begin
			@(negedge vif.sig_reset);
			do
				@(posedge vif.sig_clock);
			while(vif.sig_reset!==1);

			// reset counters
	    	num_single_frames = 0;
	    	num_burst_frames = 0;
    	end
	endtask : reset

//------------------------------------------------------------------------------
/**
* Task : collect_transactions
* Purpose : collects transactions on data and address channels when both valid
*			and ready signals are up
* Inputs :
* Outputs :
* Ref :
**/
//------------------------------------------------------------------------------
	task axi_master_read_collector::collect_transactions();
		forever begin
			@(posedge vif.sig_clock);

			// monitor address channel
			if (vif.arvalid && vif.arready)
				begin
					trans_addr_channel = axi_read_burst_frame::type_id::create("trans_addr_channel");
					trans_addr_channel.addr = vif.araddr;
					trans_addr_channel.id = vif.arid;
					trans_addr_channel.len = vif.arlen;
					trans_addr_channel.size = vif.arsize;
					trans_addr_channel.burst_type = vif.arburst;
					trans_addr_channel.lock = vif.arlock;
					trans_addr_channel.cache = vif.arcache;
					trans_addr_channel.prot = vif.arprot;
					trans_addr_channel.qos = vif.arqos;
					trans_addr_channel.region = vif.arregion;
					trans_addr_channel.user = vif.aruser;

					addr_collected_port.write(trans_addr_channel);
					num_burst_frames++;
				end

			// monitor data channel
			if (vif.rvalid && vif.rready)
				begin
					trans_data_channel = axi_read_single_frame::type_id::create("trans_data_channel");
					trans_data_channel.data = vif.rdata;
					trans_data_channel.id = vif.rid;
					trans_data_channel.resp = vif.rresp;
					trans_data_channel.last = vif.rlast;
					trans_data_channel.user = vif.ruser;

					data_collected_port.write(trans_data_channel);
					num_single_frames++;
				end
		end
	endtask : collect_transactions

//------------------------------------------------------------------------------
/**
* Function : report_phase
* Purpose : repost status - number of collected transactions
* Parameters :	phase - uvm phase
* Return :	void
**/
//------------------------------------------------------------------------------
	function void axi_master_read_collector::report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("Report: collected %0d bursts and %0d single frames", num_burst_frames, num_single_frames), UVM_LOW);
	endfunction : report_phase

`endif